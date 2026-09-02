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
        'FileStream',
        'StreamWriter'
    )
    foreach ($token in $forbiddenMetadata) {
        if ($metadataText.IndexOf($token, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "Compiled output contains prohibited metadata token '$token': $LiteralPath"
        }
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
$sourcePath = Join-Path $componentRoot 'src\AgentServiceHost.cs'
$coreSourcePath = Join-Path $componentRoot 'src\AgentCore.cs'
$harnessSourcePath = Join-Path $componentRoot 'tests\AgentCoreHarness.cs'
$profilePath = Join-Path $componentRoot 'release\gate25-unsigned-release-profile.json'

if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Source file missing: $sourcePath" }
if (-not (Test-Path -LiteralPath $coreSourcePath -PathType Leaf)) { throw "Core source file missing: $coreSourcePath" }
if (-not (Test-Path -LiteralPath $harnessSourcePath -PathType Leaf)) { throw "Harness source file missing: $harnessSourcePath" }
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
if ($profile.functionalSlice.revision -ne 3) { throw 'Functional slice revision mismatch.' }

$compilerHash = Get-Sha256 -LiteralPath $resolvedCompiler
$compilerSignature = Get-AuthenticodeSignature -LiteralPath $resolvedCompiler
if ($compilerHash -ne ([string]$profile.compilerPolicy.sha256).ToUpperInvariant()) { throw 'Compiler SHA-256 is not approved by the release profile.' }
if ($compilerSignature.Status.ToString() -ne [string]$profile.compilerPolicy.authenticodeStatus) { throw 'Compiler Authenticode status does not match the release profile.' }
if ($null -eq $compilerSignature.SignerCertificate) { throw 'Compiler signer certificate is absent.' }
if ($compilerSignature.SignerCertificate.Subject -ne [string]$profile.compilerPolicy.signerSubject) { throw 'Compiler signer subject does not match the release profile.' }
if ($compilerSignature.SignerCertificate.Thumbprint.ToUpperInvariant() -ne ([string]$profile.compilerPolicy.signerThumbprint).ToUpperInvariant()) { throw 'Compiler signer thumbprint does not match the release profile.' }
$compilerPolicyPass = $true

$functionalSourceText = (Get-Content -Raw -LiteralPath $coreSourcePath) + "`n" + (Get-Content -Raw -LiteralPath $harnessSourcePath)
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
$harnessSourceHash = Get-Sha256 -LiteralPath $harnessSourcePath
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
    $harnessArguments += $harnessSourcePath
    $harnessCompilerOutput = @(& $resolvedCompiler @harnessArguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Functional harness compiler failed: $($harnessCompilerOutput -join "`n")" }
    Assert-NoForbiddenBinaryMetadata -LiteralPath $harnessOutputPath

    $harnessSelfTest = Invoke-ExitCodeTest -Executable $harnessOutputPath -Arguments @('--self-test')
    $harnessInvalidTest = Invoke-ExitCodeTest -Executable $harnessOutputPath -Arguments @('--invalid')
    $harnessSignature = Get-AuthenticodeSignature -LiteralPath $harnessOutputPath
    try { $harnessJson = $harnessSelfTest.output | ConvertFrom-Json } catch { throw 'Functional harness output is not valid JSON.' }
    $harnessPass = $harnessSelfTest.exitCode -eq 0 -and
                   $harnessInvalidTest.exitCode -eq 64 -and
                   $harnessJson.status -eq 'PASS' -and
                   $harnessJson.contract -eq 'EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1' -and
                   $harnessJson.testsPassed -ge 20 -and
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

        $compilerOutput = @(& $resolvedCompiler @arguments 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "Compiler failed for $($role.role): $($compilerOutput -join "`n")"
        }
        if (-not (Test-Path -LiteralPath $outputPath -PathType Leaf)) { throw "Expected output absent: $($role.output)" }
        Assert-NoForbiddenBinaryMetadata -LiteralPath $outputPath

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
        outputs = $roleEvidence
    }
}

$reproducible = $true
if ($allBuildEvidence[0].functionalHarness.file -ne $allBuildEvidence[1].functionalHarness.file -or
    $allBuildEvidence[0].functionalHarness.bytes -ne $allBuildEvidence[1].functionalHarness.bytes -or
    $allBuildEvidence[0].functionalHarness.sha256 -ne $allBuildEvidence[1].functionalHarness.sha256) {
    $reproducible = $false
}
for ($index = 0; $index -lt @($profile.roles).Count; $index++) {
    $a = $allBuildEvidence[0].outputs[$index]
    $b = $allBuildEvidence[1].outputs[$index]
    if ($a.file -ne $b.file -or $a.bytes -ne $b.bytes -or $a.sha256 -ne $b.sha256) { $reproducible = $false }
}

$roleTestsPass = (@($allBuildEvidence | ForEach-Object { $_.outputs } | Where-Object { -not $_.offlineTestsPass }).Count -eq 0)
$functionalTestsPass = (@($allBuildEvidence | Where-Object { -not $_.functionalHarness.offlineTestsPass }).Count -eq 0)
$offlineTestsPass = $roleTestsPass -and $functionalTestsPass
$readyForExternalSigning = -not $DevelopmentProbe -and $compilerPolicyPass -and $supportsDeterministic -and $supportsPathMap -and $reproducible -and $offlineTestsPass
$releaseOutputs = @()

if ($readyForExternalSigning) {
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
}

$compilerItem = Get-Item -LiteralPath $resolvedCompiler
$manifest = [ordered]@{
    schemaVersion = 1
    generatedUtc = [DateTime]::UtcNow.ToString('o')
    classification = if ($DevelopmentProbe) { 'DEVELOPMENT_PROBE_ONLY' } else { 'GATE25_UNSIGNED_RELEASE_CANDIDATE' }
    status = if ($readyForExternalSigning) { 'NON_SIGNING_GATE25_CHECKS_PASS_READY_FOR_EXTERNAL_SIGNING' } elseif ($DevelopmentProbe -and -not $reproducible) { 'BLOCKED_NONDETERMINISTIC_COMPILER' } else { 'FAIL_CLOSED' }
    gate25Complete = $false
    signatureOnlyBlocked = [bool]$readyForExternalSigning
    source = [ordered]@{
        file = 'src/AgentServiceHost.cs'
        sha256 = $sourceHash
        coreFile = 'src/AgentCore.cs'
        coreSha256 = $coreSourceHash
        harnessFile = 'tests/AgentCoreHarness.cs'
        harnessSha256 = $harnessSourceHash
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
        revision = 3
        execution = 'OFFLINE_IN_MEMORY_TEST_ONLY'
        staticForbiddenTokenCheckPass = $true
        compiledMetadataForbiddenTokenCheckPass = $true
        cleanBuildHarnessReproducible = [bool](
            $allBuildEvidence[0].functionalHarness.sha256 -eq $allBuildEvidence[1].functionalHarness.sha256
        )
        testsPass = [bool]$functionalTestsPass
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
Write-Output ("SIGNATURE_ONLY_BLOCKED=" + $readyForExternalSigning.ToString().ToUpperInvariant())
Write-Output ("MANIFEST_SHA256=" + $manifestHash)

if (-not $readyForExternalSigning) { exit 2 }
