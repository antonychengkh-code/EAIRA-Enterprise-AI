[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RoslynCscPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputRoot,

    [ValidateNotNullOrEmpty()]
    [string]$ReferenceAssemblyRoot = 'C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8',

    [switch]$DevelopmentProbe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Reflection.Metadata

function Get-Sha256 {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)
    return (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Get-PeMachine {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    $stream = [System.IO.File]::Open($LiteralPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    try {
        $reader = New-Object System.IO.BinaryReader($stream)
        if ($reader.ReadUInt16() -ne 0x5A4D) { throw "Not an MZ executable: $LiteralPath" }
        $stream.Position = 0x3C
        $peOffset = $reader.ReadInt32()
        if ($peOffset -lt 0x40) { throw "Invalid PE offset: $LiteralPath" }
        $stream.Position = $peOffset
        if ($reader.ReadUInt32() -ne 0x00004550) { throw "Missing PE signature: $LiteralPath" }
        return ('0x{0:X4}' -f $reader.ReadUInt16())
    }
    finally {
        $stream.Dispose()
    }
}

function Assert-NoForbiddenBinaryMetadata {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    $bytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    $metadataText = [System.Text.Encoding]::UTF8.GetString($bytes) + "`n" + [System.Text.Encoding]::Unicode.GetString($bytes)
    $forbiddenMetadata = @(
        'System.Net',
        'NamedPipe',
        'TcpClient',
        'UdpClient',
        'HttpClient',
        'ProcessStartInfo',
        'Microsoft.Win32',
        'DllImportAttribute',
        'WriteAllText',
        'WriteAllBytes',
        'AppendAllText',
        'CreateDirectory',
        'OpenWrite',
        'CreateText',
        'AppendText',
        'WriteAllLines',
        'AppendAllLines',
        'SetAttributes',
        'SetCreationTime',
        'SetLastAccessTime',
        'SetLastWriteTime',
        'FileStream',
        'StreamWriter'
    )
    foreach ($token in $forbiddenMetadata) {
        if ($metadataText.IndexOf($token, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "Compiled output contains prohibited metadata token '$token': $LiteralPath"
        }
    }
}

function Get-SystemIoMemberReferences {
    param([Parameter(Mandatory = $true)][string]$LiteralPath)

    $stream = [System.IO.File]::OpenRead($LiteralPath)
    $peReader = [System.Reflection.PortableExecutable.PEReader]::new($stream)
    try {
        $metadataReader = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($peReader)
        $references = @()
        foreach ($handle in $metadataReader.MemberReferences) {
            $memberReference = $metadataReader.GetMemberReference($handle)
            if ($memberReference.Parent.Kind -ne [System.Reflection.Metadata.HandleKind]::TypeReference) { continue }

            $typeReference = $metadataReader.GetTypeReference(
                [System.Reflection.Metadata.TypeReferenceHandle]$memberReference.Parent
            )
            $namespace = $metadataReader.GetString($typeReference.Namespace)
            if ($namespace -cne 'System.IO' -and -not $namespace.StartsWith('System.IO.', [StringComparison]::Ordinal)) { continue }

            $typeName = $metadataReader.GetString($typeReference.Name)
            $memberName = $metadataReader.GetString($memberReference.Name)
            $references += "$namespace.$typeName::$memberName"
        }
        return @($references | Sort-Object -Unique)
    }
    finally {
        $peReader.Dispose()
        $stream.Dispose()
    }
}

function Assert-SystemIoMemberReferencePolicy {
    param(
        [Parameter(Mandatory = $true)][string]$LiteralPath,
        [switch]$AllowServiceHostReadOnly
    )

    $references = @(Get-SystemIoMemberReferences -LiteralPath $LiteralPath)
    if (-not $AllowServiceHostReadOnly) {
        if ($references.Count -ne 0) {
            throw "Compiled output contains prohibited System.IO member reference(s): $($references -join ', '): $LiteralPath"
        }
        return
    }

    $allowedReferences = @(
        'System.IO.File::Exists',
        'System.IO.Path::IsPathRooted'
    )
    $unexpectedReferences = @($references | Where-Object { $allowedReferences -cnotcontains $_ })
    if ($unexpectedReferences.Count -ne 0 -or
        $references.Count -ne $allowedReferences.Count -or
        @($allowedReferences | Where-Object { $references -cnotcontains $_ }).Count -ne 0) {
        throw "Compiled service host System.IO member references do not match the exact read-only allowlist: $($references -join ', '): $LiteralPath"
    }
}

function Invoke-ExitCodeTest {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Arguments
    )

    $output = @(& $Executable @Arguments 2>&1)
    return [ordered]@{
        exitCode = $LASTEXITCODE
        output = ($output -join "`n")
    }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$componentRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptRoot '..'))
$buildScriptPath = [System.IO.Path]::GetFullPath($MyInvocation.MyCommand.Path)
$sourcePath = Join-Path $componentRoot 'src\AgentServiceHost.cs'
$coreSourcePath = Join-Path $componentRoot 'src\AgentCore.cs'
$providerSourcePath = Join-Path $componentRoot 'src\ModelProviders.cs'
$taskIntakeSourcePath = Join-Path $componentRoot 'src\LocalTaskIntake.cs'
$taskIntakeHostSourcePath = Join-Path $componentRoot 'src\AgentTaskIntakeHost.cs'
$harnessSourcePath = Join-Path $componentRoot 'tests\AgentCoreHarness.cs'
$taskIntakeHarnessSourcePath = Join-Path $componentRoot 'tests\LocalTaskIntakeHarness.cs'
$functionalContractPath = Join-Path $componentRoot 'contracts\EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1.md'
$taskIntakeContractPath = Join-Path $componentRoot 'contracts\EAIRA_LOCAL_TASK_INTAKE_V1.md'
$profilePath = Join-Path $componentRoot 'release\gate25-unsigned-release-profile.json'

if (-not (Test-Path -LiteralPath $buildScriptPath -PathType Leaf)) { throw "Build script missing: $buildScriptPath" }
if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Source file missing: $sourcePath" }
if (-not (Test-Path -LiteralPath $coreSourcePath -PathType Leaf)) { throw "Core source file missing: $coreSourcePath" }
if (-not (Test-Path -LiteralPath $providerSourcePath -PathType Leaf)) { throw "Provider source file missing: $providerSourcePath" }
if (-not (Test-Path -LiteralPath $taskIntakeSourcePath -PathType Leaf)) { throw "Task-intake source file missing: $taskIntakeSourcePath" }
if (-not (Test-Path -LiteralPath $taskIntakeHostSourcePath -PathType Leaf)) { throw "Task-intake host source file missing: $taskIntakeHostSourcePath" }
if (-not (Test-Path -LiteralPath $harnessSourcePath -PathType Leaf)) { throw "Harness source file missing: $harnessSourcePath" }
if (-not (Test-Path -LiteralPath $taskIntakeHarnessSourcePath -PathType Leaf)) { throw "Task-intake harness source file missing: $taskIntakeHarnessSourcePath" }
if (-not (Test-Path -LiteralPath $functionalContractPath -PathType Leaf)) { throw "Functional contract missing: $functionalContractPath" }
if (-not (Test-Path -LiteralPath $taskIntakeContractPath -PathType Leaf)) { throw "Task-intake contract missing: $taskIntakeContractPath" }
if (-not (Test-Path -LiteralPath $profilePath -PathType Leaf)) { throw "Release profile missing: $profilePath" }
if (-not (Test-Path -LiteralPath $RoslynCscPath -PathType Leaf)) { throw "Compiler missing: $RoslynCscPath" }

$resolvedCompiler = (Resolve-Path -LiteralPath $RoslynCscPath).Path
$resolvedReferences = (Resolve-Path -LiteralPath $ReferenceAssemblyRoot).Path
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputRoot)
$outputRootOnly = [System.IO.Path]::GetPathRoot($resolvedOutput)
if ([String]::Equals($resolvedOutput.TrimEnd('\'), $outputRootOnly.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputRoot cannot be a filesystem root.'
}
if (Test-Path -LiteralPath $resolvedOutput) { throw "OutputRoot already exists; refusing overwrite: $resolvedOutput" }

$profile = Get-Content -Raw -LiteralPath $profilePath | ConvertFrom-Json
if ($profile.schemaVersion -ne 1) { throw 'Unsupported release profile schema.' }
if (@($profile.roles).Count -ne 5) { throw 'Release profile must contain exactly five roles.' }
if ($profile.functionalSlice.contract -ne 'EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1') { throw 'Functional slice contract mismatch.' }
if ($profile.functionalSlice.revision -ne 5) { throw 'Functional slice revision mismatch.' }
if ($profile.taskIntake.contract -ne 'EAIRA_LOCAL_TASK_INTAKE_V1') { throw 'Task-intake contract mismatch.' }
if ($profile.taskIntake.transport -ne 'LOCAL_COMMAND_LINE_ONLY' -or
    $profile.taskIntake.output -ne 'EAIRA.AgentTask.Cli.exe' -or
    $profile.taskIntake.mockProvider -ne 'ENABLED' -or
    $profile.taskIntake.realProvider -ne 'FAIL_CLOSED_DISABLED' -or
    $profile.taskIntake.network -ne 'NONE' -or
    $profile.taskIntake.writes -ne 'NONE') { throw 'Task-intake policy mismatch.' }

$compilerHash = Get-Sha256 -LiteralPath $resolvedCompiler
$compilerSignature = Get-AuthenticodeSignature -LiteralPath $resolvedCompiler
if ($compilerHash -ne ([string]$profile.compilerPolicy.sha256).ToUpperInvariant()) { throw 'Compiler SHA-256 is not approved by the release profile.' }
if ($compilerSignature.Status.ToString() -ne [string]$profile.compilerPolicy.authenticodeStatus) { throw 'Compiler Authenticode status does not match the release profile.' }
if ($null -eq $compilerSignature.SignerCertificate) { throw 'Compiler signer certificate is absent.' }
if ($compilerSignature.SignerCertificate.Subject -ne [string]$profile.compilerPolicy.signerSubject) { throw 'Compiler signer subject does not match the release profile.' }
if ($compilerSignature.SignerCertificate.Thumbprint.ToUpperInvariant() -ne ([string]$profile.compilerPolicy.signerThumbprint).ToUpperInvariant()) { throw 'Compiler signer thumbprint does not match the release profile.' }
$compilerPolicyPass = $true

$functionalSourceText = @(
    (Get-Content -Raw -LiteralPath $coreSourcePath),
    (Get-Content -Raw -LiteralPath $providerSourcePath),
    (Get-Content -Raw -LiteralPath $taskIntakeSourcePath),
    (Get-Content -Raw -LiteralPath $taskIntakeHostSourcePath),
    (Get-Content -Raw -LiteralPath $harnessSourcePath),
    (Get-Content -Raw -LiteralPath $taskIntakeHarnessSourcePath)
) -join "`n"
$serviceHostSourceText = Get-Content -Raw -LiteralPath $sourcePath
$allRuntimeSourceText = $serviceHostSourceText + "`n" + $functionalSourceText
$forbiddenFunctionalPatterns = @(
    'System.IO',
    'System.Net',
    'System.Diagnostics',
    'Microsoft.Win32',
    'DllImport',
    'Assembly.Load',
    'NamedPipe',
    'TcpClient',
    'UdpClient',
    'HttpClient',
    'Socket',
    'Process.Start',
    'Environment.SetEnvironmentVariable'
)
foreach ($pattern in $forbiddenFunctionalPatterns) {
    if ($functionalSourceText.IndexOf($pattern, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "Functional core or harness contains prohibited implementation token: $pattern"
    }
}
$forbiddenRuntimeWritePatterns = @(
    '(?i)\b(?:System\.IO\.)?File\s*\.\s*(?:Create|Delete|Move|Copy|Replace|Open|OpenWrite|CreateText|AppendText|WriteAllText|WriteAllBytes|WriteAllLines|AppendAllText|AppendAllLines|SetAttributes|SetCreationTime|SetLastAccessTime|SetLastWriteTime|Encrypt|Decrypt)\s*\(',
    '(?i)\b(?:System\.IO\.)?Directory\s*\.\s*(?:CreateDirectory|Delete|Move|SetCreationTime|SetLastAccessTime|SetLastWriteTime)\s*\(',
    '(?i)\b(?:System\.IO\.)?(?:FileStream|StreamWriter|BinaryWriter|FileInfo|DirectoryInfo)\b'
)
foreach ($pattern in $forbiddenRuntimeWritePatterns) {
    if ($allRuntimeSourceText -match $pattern) { throw "Runtime source contains prohibited write implementation pattern: $pattern" }
}

# The functional sources permit no System.IO at all. The service host has a
# deliberately narrower read-only allowlist: one namespace import, one
# File.Exists call and two Path.IsPathRooted calls. Any alias, qualified IO
# type, additional File/Directory/Path call, or instance IO type fails closed.
$ioUsingPattern = '(?m)^\s*using\s+System\.IO\s*;\s*$'
if ([regex]::Matches($serviceHostSourceText, $ioUsingPattern).Count -ne 1) { throw 'Service-host System.IO import does not match the exact read-only allowlist.' }
if ($serviceHostSourceText -match '(?im)^\s*using\s+(?:static\s+|[A-Za-z_][A-Za-z0-9_]*\s*=).*System\.IO') { throw 'Service-host System.IO alias or static import is prohibited.' }
$serviceHostWithoutAllowedImport = [regex]::Replace($serviceHostSourceText, $ioUsingPattern, '', [System.Text.RegularExpressions.RegexOptions]::Multiline)
if ($serviceHostWithoutAllowedImport -match '(?i)\bSystem\.IO\b') { throw 'Service-host qualified System.IO usage is outside the read-only allowlist.' }
if ($serviceHostSourceText -match '(?i)\b(?:FileInfo|DirectoryInfo|FileStream|StreamWriter|BinaryWriter)\b') { throw 'Service-host instance IO types are prohibited.' }
$ioCallMatches = [regex]::Matches($serviceHostSourceText, '(?i)\b(?:File|Directory|Path)\s*\.\s*[A-Za-z_][A-Za-z0-9_]*\s*\(')
$normalizedIoCalls = @($ioCallMatches | ForEach-Object { $_.Value -replace '\s', '' })
if ($normalizedIoCalls.Count -ne 3 -or
    @($normalizedIoCalls | Where-Object { $_ -ceq 'File.Exists(' }).Count -ne 1 -or
    @($normalizedIoCalls | Where-Object { $_ -ceq 'Path.IsPathRooted(' }).Count -ne 2) {
    throw 'Service-host IO calls do not match the exact read-only allowlist.'
}
$runtimeIoAllowlistCheckPass = $true

$referenceEvidence = @()
foreach ($reference in @($profile.referenceAssemblies)) {
    $path = Join-Path $resolvedReferences ([string]$reference.file)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Reference assembly missing: $($reference.file)" }
    $actualHash = Get-Sha256 -LiteralPath $path
    if ($actualHash -ne ([string]$reference.sha256).ToUpperInvariant()) {
        throw "Reference assembly hash mismatch: $($reference.file)"
    }
    $item = Get-Item -LiteralPath $path
    $referenceEvidence += [ordered]@{
        file = [string]$reference.file
        bytes = $item.Length
        sha256 = $actualHash
        productVersion = $item.VersionInfo.ProductVersion
    }
}

$compilerHelp = @(& $resolvedCompiler /? 2>&1) -join "`n"
$supportsDeterministic = $compilerHelp -match '(?i)[/-]deterministic'
$supportsPathMap = $compilerHelp -match '(?i)[/-]pathmap'
if (-not $DevelopmentProbe -and (-not $supportsDeterministic -or -not $supportsPathMap)) {
    throw 'Compiler lacks /deterministic and/or /pathmap. Release build stopped fail-closed; use -DevelopmentProbe only for non-acceptance diagnostics.'
}

New-Item -ItemType Directory -Path $resolvedOutput | Out-Null
$buildRoots = @(
    (Join-Path $resolvedOutput 'clean-build-a'),
    (Join-Path $resolvedOutput 'clean-build-b')
)
foreach ($buildRoot in $buildRoots) { New-Item -ItemType Directory -Path $buildRoot | Out-Null }

$sourceHash = Get-Sha256 -LiteralPath $sourcePath
$coreSourceHash = Get-Sha256 -LiteralPath $coreSourcePath
$providerSourceHash = Get-Sha256 -LiteralPath $providerSourcePath
$taskIntakeSourceHash = Get-Sha256 -LiteralPath $taskIntakeSourcePath
$taskIntakeHostSourceHash = Get-Sha256 -LiteralPath $taskIntakeHostSourcePath
$harnessSourceHash = Get-Sha256 -LiteralPath $harnessSourcePath
$taskIntakeHarnessSourceHash = Get-Sha256 -LiteralPath $taskIntakeHarnessSourcePath
$allBuildEvidence = @()

for ($buildIndex = 0; $buildIndex -lt $buildRoots.Count; $buildIndex++) {
    $buildRoot = $buildRoots[$buildIndex]
    $roleEvidence = @()
    $harnessOutputPath = Join-Path $buildRoot 'EAIRA.AgentCore.Harness.exe'
    $harnessArguments = @(
        '/nologo',
        '/noconfig',
        '/target:exe',
        '/platform:x64',
        '/optimize+',
        '/debug-',
        '/checked+',
        '/highentropyva+',
        '/warn:4',
        '/warnaserror+',
        '/nostdlib+',
        "/reference:$resolvedReferences\mscorlib.dll",
        "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.Tests.AgentCoreHarness',
        "/out:$harnessOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $harnessArguments += '/deterministic+'
        $harnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $harnessArguments += $coreSourcePath
    $harnessArguments += $providerSourcePath
    $harnessArguments += $harnessSourcePath
    $harnessCompilerOutput = @(& $resolvedCompiler @harnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Functional harness compiler failed: $($harnessCompilerOutput -join "`n")" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $harnessOutputPath
    Assert-SystemIoMemberReferencePolicy -LiteralPath $harnessOutputPath

    $harnessSelfTest = Invoke-ExitCodeTest -Executable $harnessOutputPath -Arguments @('--self-test')
    $harnessInvalidTest = Invoke-ExitCodeTest -Executable $harnessOutputPath -Arguments @('--invalid')
    $harnessSignature = Get-AuthenticodeSignature -LiteralPath $harnessOutputPath
    try { $harnessJson = $harnessSelfTest.output | ConvertFrom-Json } catch { throw 'Functional harness output is not valid JSON.' }
    $harnessPass = $harnessSelfTest.exitCode -eq 0 -and
                   $harnessInvalidTest.exitCode -eq 64 -and
                   $harnessJson.status -eq 'PASS' -and
                   $harnessJson.contract -eq 'EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1' -and
                   $harnessJson.testsPassed -eq 34 -and
                   $harnessJson.network -eq 'NONE' -and
                   $harnessJson.ipc -eq 'NONE' -and
                   $harnessJson.writes -eq 'NONE' -and
                   $harnessJson.childProcess -eq 'NONE' -and
                   (Get-PeMachine -LiteralPath $harnessOutputPath) -eq '0x8664' -and
                   $harnessSignature.Status.ToString() -eq 'NotSigned'
    $harnessItem = Get-Item -LiteralPath $harnessOutputPath
    $harnessEvidence = [ordered]@{
        file = $harnessItem.Name
        bytes = $harnessItem.Length
        sha256 = Get-Sha256 -LiteralPath $harnessOutputPath
        peMachine = Get-PeMachine -LiteralPath $harnessOutputPath
        authenticode = $harnessSignature.Status.ToString()
        selfTestExitCode = $harnessSelfTest.exitCode
        invalidArgumentExitCode = $harnessInvalidTest.exitCode
        testsPassed = [int]$harnessJson.testsPassed
        offlineTestsPass = [bool]$harnessPass
    }

    $taskIntakeHarnessOutputPath = Join-Path $buildRoot 'EAIRA.LocalTaskIntake.Harness.exe'
    $taskIntakeHarnessArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.Tests.LocalTaskIntakeHarness', "/out:$taskIntakeHarnessOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $taskIntakeHarnessArguments += '/deterministic+'
        $taskIntakeHarnessArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $taskIntakeHarnessArguments += $coreSourcePath
    $taskIntakeHarnessArguments += $providerSourcePath
    $taskIntakeHarnessArguments += $taskIntakeSourcePath
    $taskIntakeHarnessArguments += $taskIntakeHarnessSourcePath
    $taskIntakeHarnessCompilerOutput = @(& $resolvedCompiler @taskIntakeHarnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Task-intake harness compiler failed: $($taskIntakeHarnessCompilerOutput -join "`n")" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $taskIntakeHarnessOutputPath
    Assert-SystemIoMemberReferencePolicy -LiteralPath $taskIntakeHarnessOutputPath
    $taskIntakeHarnessSelfTest = Invoke-ExitCodeTest -Executable $taskIntakeHarnessOutputPath -Arguments @('--self-test')
    $taskIntakeHarnessInvalidTest = Invoke-ExitCodeTest -Executable $taskIntakeHarnessOutputPath -Arguments @('--invalid')
    $taskIntakeHarnessSignature = Get-AuthenticodeSignature -LiteralPath $taskIntakeHarnessOutputPath
    try { $taskIntakeHarnessJson = $taskIntakeHarnessSelfTest.output | ConvertFrom-Json } catch { throw 'Task-intake harness output is not valid JSON.' }
    $taskIntakeHarnessPass = $taskIntakeHarnessSelfTest.exitCode -eq 0 -and
                             $taskIntakeHarnessInvalidTest.exitCode -eq 64 -and
                             $taskIntakeHarnessJson.status -eq 'PASS' -and
                             $taskIntakeHarnessJson.contract -eq 'EAIRA_LOCAL_TASK_INTAKE_V1' -and
                             $taskIntakeHarnessJson.testsPassed -eq 14 -and
                             $taskIntakeHarnessJson.network -eq 'NONE' -and
                             $taskIntakeHarnessJson.writes -eq 'NONE' -and
                             $taskIntakeHarnessJson.realProvider -eq 'BLOCKED' -and
                             (Get-PeMachine -LiteralPath $taskIntakeHarnessOutputPath) -eq '0x8664' -and
                             $taskIntakeHarnessSignature.Status.ToString() -eq 'NotSigned'
    $taskIntakeHarnessItem = Get-Item -LiteralPath $taskIntakeHarnessOutputPath
    $taskIntakeHarnessEvidence = [ordered]@{
        file = $taskIntakeHarnessItem.Name
        bytes = $taskIntakeHarnessItem.Length
        sha256 = Get-Sha256 -LiteralPath $taskIntakeHarnessOutputPath
        peMachine = Get-PeMachine -LiteralPath $taskIntakeHarnessOutputPath
        authenticode = $taskIntakeHarnessSignature.Status.ToString()
        selfTestExitCode = $taskIntakeHarnessSelfTest.exitCode
        invalidArgumentExitCode = $taskIntakeHarnessInvalidTest.exitCode
        testsPassed = [int]$taskIntakeHarnessJson.testsPassed
        offlineTestsPass = [bool]$taskIntakeHarnessPass
    }

    $taskIntakeOutputPath = Join-Path $buildRoot ([string]$profile.taskIntake.output)
    $taskIntakeArguments = @(
        '/nologo', '/noconfig', '/target:exe', '/platform:x64', '/optimize+', '/debug-', '/checked+', '/highentropyva+',
        '/warn:4', '/warnaserror+', '/nostdlib+',
        "/reference:$resolvedReferences\mscorlib.dll", "/reference:$resolvedReferences\System.dll",
        '/main:EAIRA.AgentServices.TaskIntake.AgentTaskIntakeHost', "/out:$taskIntakeOutputPath"
    )
    if (-not $DevelopmentProbe) {
        $taskIntakeArguments += '/deterministic+'
        $taskIntakeArguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
    }
    $taskIntakeArguments += $coreSourcePath
    $taskIntakeArguments += $providerSourcePath
    $taskIntakeArguments += $taskIntakeSourcePath
    $taskIntakeArguments += $taskIntakeHostSourcePath
    $taskIntakeCompilerOutput = @(& $resolvedCompiler @taskIntakeArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Task-intake CLI compiler failed: $($taskIntakeCompilerOutput -join "`n")" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $taskIntakeOutputPath
    Assert-SystemIoMemberReferencePolicy -LiteralPath $taskIntakeOutputPath

    $allowedArgs = @('--provider','mock','--trace','ABCDEF0123456789ABCDEF0123456789','--goal','prepare bounded release plan')
    $taskAllowed = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments $allowedArgs
    $taskAllowedRepeat = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments $allowedArgs
    $taskDenied = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','mock','--trace','1234567890ABCDEF1234567890ABCDEF','--goal','write file')
    $taskReal = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','real','--trace','11111111222222223333333344444444','--goal','prepare bounded release plan')
    $taskInvalid = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','unknown','--trace','ABCDEF0123456789ABCDEF0123456789','--goal','prepare bounded release plan')
    $taskInvalidUnicode = Invoke-ExitCodeTest -Executable $taskIntakeOutputPath -Arguments @('--provider','mock','--trace','ABCDEF0123456789ABCDEF0123456789','--goal',(new-object string ([char]0xD800, 1)))
    try { $taskAllowedJson = $taskAllowed.output | ConvertFrom-Json } catch { throw 'Allowed task-intake output is not valid JSON.' }
    try { $taskDeniedJson = $taskDenied.output | ConvertFrom-Json } catch { throw 'Denied task-intake output is not valid JSON.' }
    try { $taskRealJson = $taskReal.output | ConvertFrom-Json } catch { throw 'Real-provider task-intake output is not valid JSON.' }
    try { $taskInvalidJson = $taskInvalid.output | ConvertFrom-Json } catch { throw 'Invalid task-intake output is not valid JSON.' }
    try { $taskInvalidUnicodeJson = $taskInvalidUnicode.output | ConvertFrom-Json } catch { throw 'Invalid-Unicode task-intake output is not valid JSON.' }
    $taskIntakeSignature = Get-AuthenticodeSignature -LiteralPath $taskIntakeOutputPath
    $taskIntakePass = $taskAllowed.exitCode -eq 0 -and
                      $taskAllowedRepeat.exitCode -eq 0 -and
                      $taskAllowed.output -eq $taskAllowedRepeat.output -and
                      $taskAllowedJson.status -eq 'PASS' -and $taskAllowedJson.provider -eq 'mock-v1' -and
                      $taskAllowedJson.network -eq 'NONE' -and $taskAllowedJson.writes -eq 'NONE' -and
                      $taskDenied.exitCode -eq 77 -and $taskDeniedJson.status -eq 'DENIED' -and
                      $taskReal.exitCode -eq 78 -and $taskRealJson.status -eq 'PROVIDER_BLOCKED' -and
                       $taskInvalid.exitCode -eq 64 -and $taskInvalidJson.status -eq 'INVALID_REQUEST' -and
                       $taskInvalidUnicode.exitCode -eq 64 -and $taskInvalidUnicodeJson.status -eq 'INVALID_REQUEST' -and
                      (Get-PeMachine -LiteralPath $taskIntakeOutputPath) -eq '0x8664' -and
                      $taskIntakeSignature.Status.ToString() -eq 'NotSigned'
    $taskIntakeItem = Get-Item -LiteralPath $taskIntakeOutputPath
    $taskIntakeEvidence = [ordered]@{
        file = $taskIntakeItem.Name
        bytes = $taskIntakeItem.Length
        sha256 = Get-Sha256 -LiteralPath $taskIntakeOutputPath
        peMachine = Get-PeMachine -LiteralPath $taskIntakeOutputPath
        authenticode = $taskIntakeSignature.Status.ToString()
        allowedExitCode = $taskAllowed.exitCode
        deniedExitCode = $taskDenied.exitCode
        realProviderExitCode = $taskReal.exitCode
        invalidRequestExitCode = $taskInvalid.exitCode
        invalidUnicodeExitCode = $taskInvalidUnicode.exitCode
        deterministicOutput = [bool]($taskAllowed.output -eq $taskAllowedRepeat.output)
        offlineTestsPass = [bool]$taskIntakePass
    }

    foreach ($role in @($profile.roles)) {
        $outputPath = Join-Path $buildRoot ([string]$role.output)
        $arguments = @(
            '/nologo',
            '/noconfig',
            '/target:exe',
            '/platform:x64',
            '/optimize+',
            '/debug-',
            '/checked+',
            '/highentropyva+',
            '/warn:4',
            '/warnaserror+',
            '/nostdlib+',
            "/reference:$resolvedReferences\mscorlib.dll",
            "/reference:$resolvedReferences\System.dll",
            "/reference:$resolvedReferences\System.ServiceProcess.dll",
            "/define:$([string]$role.symbol)",
            "/out:$outputPath"
        )

        if (-not $DevelopmentProbe) {
            $arguments += '/deterministic+'
            $arguments += "/pathmap:$componentRoot=/_/EAIRA/apps/agent-services"
        }
        $arguments += $sourcePath
        $arguments += $coreSourcePath
        $arguments += $providerSourcePath

        $compilerOutput = @(& $resolvedCompiler @arguments 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "Compiler failed for $($role.role): $($compilerOutput -join "`n")"
        }
        if (-not (Test-Path -LiteralPath $outputPath -PathType Leaf)) { throw "Expected output absent: $($role.output)" }
        Assert-NoForbiddenBinaryMetadata -LiteralPath $outputPath
        Assert-SystemIoMemberReferencePolicy -LiteralPath $outputPath -AllowServiceHostReadOnly

        $selfTest = Invoke-ExitCodeTest -Executable $outputPath -Arguments @('--self-test')
        $invalidTest = Invoke-ExitCodeTest -Executable $outputPath -Arguments @('--invalid')
        $interactiveTest = Invoke-ExitCodeTest -Executable $outputPath -Arguments @()
        $signature = Get-AuthenticodeSignature -LiteralPath $outputPath
        $selfTestJson = $null
        try { $selfTestJson = $selfTest.output | ConvertFrom-Json } catch { throw "Self-test output is not valid JSON: $($role.output)" }

        $testsPass = $selfTest.exitCode -eq 0 -and
                     $selfTestJson.status -eq 'PASS' -and
                     $selfTestJson.role -eq $role.role -and
                     $selfTestJson.service -eq $role.serviceName -and
                     $selfTestJson.contract -eq $profile.buildContract -and
                     $selfTestJson.functional_slice -eq 'OFFLINE_TEST_ONLY' -and
                     $selfTestJson.network -eq 'NONE' -and
                     $selfTestJson.ipc -eq 'PROHIBITED' -and
                     $selfTestJson.child_process -eq 'PROHIBITED' -and
                     $invalidTest.exitCode -eq 64 -and
                     $interactiveTest.exitCode -eq 65 -and
                     (Get-PeMachine -LiteralPath $outputPath) -eq '0x8664' -and
                     $signature.Status.ToString() -eq 'NotSigned'

        $file = Get-Item -LiteralPath $outputPath
        $roleEvidence += [ordered]@{
            role = [string]$role.role
            serviceName = [string]$role.serviceName
            file = [string]$role.output
            bytes = $file.Length
            sha256 = Get-Sha256 -LiteralPath $outputPath
            peMachine = Get-PeMachine -LiteralPath $outputPath
            authenticode = $signature.Status.ToString()
            selfTestExitCode = $selfTest.exitCode
            invalidArgumentExitCode = $invalidTest.exitCode
            interactiveNoArgumentExitCode = $interactiveTest.exitCode
            offlineTestsPass = [bool]$testsPass
        }
    }

    $allBuildEvidence += [ordered]@{
        build = if ($buildIndex -eq 0) { 'A' } else { 'B' }
        functionalHarness = $harnessEvidence
        taskIntakeHarness = $taskIntakeHarnessEvidence
        taskIntakeCli = $taskIntakeEvidence
        outputs = $roleEvidence
    }
}

$reproducible = $true
if ($allBuildEvidence[0].functionalHarness.file -ne $allBuildEvidence[1].functionalHarness.file -or
    $allBuildEvidence[0].functionalHarness.bytes -ne $allBuildEvidence[1].functionalHarness.bytes -or
    $allBuildEvidence[0].functionalHarness.sha256 -ne $allBuildEvidence[1].functionalHarness.sha256) {
    $reproducible = $false
}
if ($allBuildEvidence[0].taskIntakeHarness.sha256 -ne $allBuildEvidence[1].taskIntakeHarness.sha256 -or
    $allBuildEvidence[0].taskIntakeCli.sha256 -ne $allBuildEvidence[1].taskIntakeCli.sha256) {
    $reproducible = $false
}
for ($index = 0; $index -lt @($profile.roles).Count; $index++) {
    $a = $allBuildEvidence[0].outputs[$index]
    $b = $allBuildEvidence[1].outputs[$index]
    if ($a.file -ne $b.file -or $a.bytes -ne $b.bytes -or $a.sha256 -ne $b.sha256) { $reproducible = $false }
}

$roleTestsPass = (@($allBuildEvidence | ForEach-Object { $_.outputs } | Where-Object { -not $_.offlineTestsPass }).Count -eq 0)
$functionalTestsPass = (@($allBuildEvidence | Where-Object { -not $_.functionalHarness.offlineTestsPass }).Count -eq 0)
$taskIntakeTestsPass = (@($allBuildEvidence | Where-Object { -not $_.taskIntakeHarness.offlineTestsPass -or -not $_.taskIntakeCli.offlineTestsPass }).Count -eq 0)
$offlineTestsPass = $roleTestsPass -and $functionalTestsPass -and $taskIntakeTestsPass
$m4TechnicalChecksPass = -not $DevelopmentProbe -and $compilerPolicyPass -and $supportsDeterministic -and $supportsPathMap -and $reproducible -and $offlineTestsPass
$releaseOutputs = @()

if ($m4TechnicalChecksPass) {
    $releaseRoot = Join-Path $resolvedOutput 'unsigned-release'
    New-Item -ItemType Directory -Path $releaseRoot | Out-Null
    foreach ($role in @($profile.roles)) {
        $sourceOutput = Join-Path $buildRoots[0] ([string]$role.output)
        $destinationOutput = Join-Path $releaseRoot ([string]$role.output)
        Copy-Item -LiteralPath $sourceOutput -Destination $destinationOutput
        $releaseOutputs += [ordered]@{
            file = [string]$role.output
            bytes = (Get-Item -LiteralPath $destinationOutput).Length
            sha256 = Get-Sha256 -LiteralPath $destinationOutput
            authenticode = (Get-AuthenticodeSignature -LiteralPath $destinationOutput).Status.ToString()
        }
    }
    $taskIntakeReleasePath = Join-Path $releaseRoot ([string]$profile.taskIntake.output)
    Copy-Item -LiteralPath (Join-Path $buildRoots[0] ([string]$profile.taskIntake.output)) -Destination $taskIntakeReleasePath
    $releaseOutputs += [ordered]@{
        file = [string]$profile.taskIntake.output
        bytes = (Get-Item -LiteralPath $taskIntakeReleasePath).Length
        sha256 = Get-Sha256 -LiteralPath $taskIntakeReleasePath
        authenticode = (Get-AuthenticodeSignature -LiteralPath $taskIntakeReleasePath).Status.ToString()
    }
}

$compilerItem = Get-Item -LiteralPath $resolvedCompiler
$manifest = [ordered]@{
    schemaVersion = 1
    generatedUtc = [DateTime]::UtcNow.ToString('o')
    classification = if ($DevelopmentProbe) { 'DEVELOPMENT_PROBE_ONLY' } else { 'M4_FUNCTIONAL_AGENT_MVP_SLICE_1_UNSIGNED_CANDIDATE' }
    status = if ($m4TechnicalChecksPass) { 'M4_SLICE_1_UNSIGNED_TECHNICAL_CHECKS_PASS' } elseif ($DevelopmentProbe -and -not $reproducible) { 'BLOCKED_NONDETERMINISTIC_COMPILER' } else { 'FAIL_CLOSED' }
    gate25Complete = $false
    externalSigningEligible = $false
    signatureOnlyBlocked = $false
    source = [ordered]@{
        buildScriptFile = 'build/Invoke-Gate25UnsignedRelease.ps1'
        buildScriptSha256 = Get-Sha256 -LiteralPath $buildScriptPath
        functionalContractFile = 'contracts/EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1.md'
        functionalContractSha256 = Get-Sha256 -LiteralPath $functionalContractPath
        taskIntakeContractFile = 'contracts/EAIRA_LOCAL_TASK_INTAKE_V1.md'
        taskIntakeContractSha256 = Get-Sha256 -LiteralPath $taskIntakeContractPath
        file = 'src/AgentServiceHost.cs'
        sha256 = $sourceHash
        coreFile = 'src/AgentCore.cs'
        coreSha256 = $coreSourceHash
        providerFile = 'src/ModelProviders.cs'
        providerSha256 = $providerSourceHash
        taskIntakeFile = 'src/LocalTaskIntake.cs'
        taskIntakeSha256 = $taskIntakeSourceHash
        taskIntakeHostFile = 'src/AgentTaskIntakeHost.cs'
        taskIntakeHostSha256 = $taskIntakeHostSourceHash
        harnessFile = 'tests/AgentCoreHarness.cs'
        harnessSha256 = $harnessSourceHash
        taskIntakeHarnessFile = 'tests/LocalTaskIntakeHarness.cs'
        taskIntakeHarnessSha256 = $taskIntakeHarnessSourceHash
        releaseProfileSha256 = Get-Sha256 -LiteralPath $profilePath
    }
    compiler = [ordered]@{
        file = $compilerItem.Name
        bytes = $compilerItem.Length
        sha256 = $compilerHash
        productVersion = $compilerItem.VersionInfo.ProductVersion
        authenticode = $compilerSignature.Status.ToString()
        signerSubject = $compilerSignature.SignerCertificate.Subject
        signerThumbprint = $compilerSignature.SignerCertificate.Thumbprint.ToUpperInvariant()
        releaseProfilePolicyMatch = [bool]$compilerPolicyPass
        supportsDeterministic = [bool]$supportsDeterministic
        supportsPathMap = [bool]$supportsPathMap
    }
    references = $referenceEvidence
    cleanBuilds = $allBuildEvidence
    reproducibleByteForByte = [bool]$reproducible
    offlineTestsPass = [bool]$offlineTestsPass
    functionalSlice = [ordered]@{
        contract = 'EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1'
        revision = [int]$profile.functionalSlice.revision
        execution = 'OFFLINE_IN_MEMORY_TEST_ONLY'
        staticForbiddenTokenCheckPass = $true
        runtimeIoAllowlistCheckPass = [bool]$runtimeIoAllowlistCheckPass
        structuredPeIoMemberReferenceCheckPass = $true
        compiledMetadataForbiddenTokenCheckPass = $true
        cleanBuildHarnessReproducible = [bool](
            $allBuildEvidence[0].functionalHarness.sha256 -eq $allBuildEvidence[1].functionalHarness.sha256
        )
        testsPass = [bool]$functionalTestsPass
    }
    taskIntake = [ordered]@{
        contract = 'EAIRA_LOCAL_TASK_INTAKE_V1'
        transport = 'LOCAL_COMMAND_LINE_ONLY'
        mockProvider = 'ENABLED'
        realProvider = 'FAIL_CLOSED_DISABLED'
        network = 'NONE'
        writes = 'NONE'
        cleanBuildHarnessReproducible = [bool]($allBuildEvidence[0].taskIntakeHarness.sha256 -eq $allBuildEvidence[1].taskIntakeHarness.sha256)
        cleanBuildCliReproducible = [bool]($allBuildEvidence[0].taskIntakeCli.sha256 -eq $allBuildEvidence[1].taskIntakeCli.sha256)
        testsPass = [bool]$taskIntakeTestsPass
    }
    releaseOutputs = $releaseOutputs
    signing = [ordered]@{
        performed = $false
        certificateAccessed = $false
        privateKeyAccessed = $false
        requiredForGate25Completion = $true
    }
    windowsMutation = [ordered]@{
        service = $false
        identity = $false
        membership = $false
        directoryAcl = $false
        tpm = $false
    }
}

$manifestPath = Join-Path $resolvedOutput 'gate25-unsigned-build-manifest.json'
$manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
$manifestHash = Get-Sha256 -LiteralPath $manifestPath

Write-Output ("STATUS=" + $manifest.status)
Write-Output ("REPRODUCIBLE_BYTE_FOR_BYTE=" + $reproducible.ToString().ToUpperInvariant())
Write-Output ("OFFLINE_TESTS_PASS=" + $offlineTestsPass.ToString().ToUpperInvariant())
Write-Output ("FUNCTIONAL_SLICE_TESTS_PASS=" + $functionalTestsPass.ToString().ToUpperInvariant())
Write-Output ("TASK_INTAKE_TESTS_PASS=" + $taskIntakeTestsPass.ToString().ToUpperInvariant())
Write-Output 'EXTERNAL_SIGNING_ELIGIBLE=FALSE'
Write-Output 'SIGNATURE_ONLY_BLOCKED=FALSE'
Write-Output ("MANIFEST_SHA256=" + $manifestHash)

if (-not $m4TechnicalChecksPass) { exit 2 }
