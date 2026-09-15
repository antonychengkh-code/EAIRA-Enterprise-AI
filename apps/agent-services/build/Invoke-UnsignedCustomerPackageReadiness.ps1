[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$RoslynCscPath,
    [Parameter(Mandatory=$true)][string]$WorkEvidenceRoot,
    [Parameter(Mandatory=$true)][string]$PackageEvidenceRootA,
    [Parameter(Mandatory=$true)][string]$PackageEvidenceRootB,
    [Parameter(Mandatory=$true)][ValidateSet('Build','Verify')][string]$Mode,
    [ValidateSet('DISCOVERY','SEALED_FINAL')][string]$EvidencePhase='DISCOVERY',
    [string]$ExpectedRepositoryInputsSha256='NONE'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceRoot = 'C:\Temp\EAIRA_M5S4_SEALED_FINAL_003\unsigned-release'
$profilePath = Join-Path (Split-Path -Parent $PSScriptRoot) 'release\unsigned-customer-package-profile.json'
$repoAgentRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $repoAgentRoot '..\..')).Path
$profileSha = 'CDDF0BA541888222681DBA5BE9C60F92648C25C8D8ADF92CF6C20E57C62B4C67'
$sourceManifestSha = '4B9C72AC8A8134F4596CBA024F8A4C6EC21766F85084CB8174EBD77A33A04D85'
$caseNamesSha = 'F559B2767F8C258FC0E1C0BED56C42F15FB7229DFDF50FB91AA02EA90499EF38'
$specimenNamesSha = 'B6559DB36F5CD9FABC6590AF0950E9B8E36251822F028B094800E98CA17A1988'
$specimenSourcesSha = '99CB422F73D3A0F20CFAAB0C4123465DF8A3DDBABD422AED897150D2207AFFA1'
$faultProjectionSha = '3FF61A7E3CE9B4E81D0476769080F669D8EF61072AE95DA4874C5577DEE72996'
$argvGoldenSha = 'E75A281A92B34925C943CC3FF050C82422B3E3F3E9CD47126A2FF7D78B408DD1'
$contentSha = 'DD51108C50DD4C1069695593DBEFF39C12927148E7DDBFEE98939CFD16B19DAB'

$manifest = @(
 'apps/agent-services/README.md',
 'apps/agent-services/build/Invoke-UnsignedCustomerPackageReadiness.ps1',
 'apps/agent-services/contracts/EAIRA_UNSIGNED_CUSTOMER_PACKAGE_V1.md',
 'apps/agent-services/release/unsigned-customer-package-profile.json',
 'apps/agent-services/src/UnsignedCustomerPackageReadiness.cs',
 'apps/agent-services/tests/UnsignedCustomerPackageHarness.cs',
 'docs/project/planning/EAIRA_M5_SLICE5_BOUNDED_UNSIGNED_CUSTOMER_PACKAGE_READINESS_PACKAGE.md',
 'docs/project/planning/EAIRA_M5_SLICE5_EXACT_IMPLEMENTATION_DESIGN.md',
 'docs/project/strategy/EAIRA_M5_SLICE5_SCOPE_DECISION.md'
)

$payloads = @(
 [pscustomobject]@{File='EAIRA.Planning.Service.exe';Bytes=29184;Sha='2767AD2DE938083F575C705BCC835D54E4419FC49D53E2A62AFD7CB04FC2708E'},
 [pscustomobject]@{File='EAIRA.Operations.Service.exe';Bytes=29184;Sha='7251BDEB23CDAC25A7BECE110D4A6101BD89C3112733358E3171A206AAD3C983'},
 [pscustomobject]@{File='EAIRA.Verification.Service.exe';Bytes=29184;Sha='B0BD6714FC7048CBD46998433CADEB9913E2C0EE6822EE7AE2C0EE7B5E5892FC'},
 [pscustomobject]@{File='EAIRA.Guard.Service.exe';Bytes=28672;Sha='D32C265F72222C52383399908273B1E1F574C84DEE32BF6FBC5776F4AE878D46'},
 [pscustomobject]@{File='EAIRA.Audit.Service.exe';Bytes=28672;Sha='01EAA5FC43A4B1D49D915CE1459C8661F04A6CAA6440BC85FF44BFF577D9AE10'},
 [pscustomobject]@{File='EAIRA.AgentTask.Cli.exe';Bytes=72192;Sha='04EDEDDA8755F4B5FC76E7DB473C37CB49F67A53DA28A9AA83C167A521E9C752'},
 [pscustomobject]@{File='EAIRA.ProjectKnowledge.Cli.exe';Bytes=22016;Sha='08ABD5E90A0AAAB219639A7724A6B9C8EDE532199B23E84D459BE9DD40FD0F9A'},
 [pscustomobject]@{File='EAIRA.ProjectQa.Cli.exe';Bytes=97280;Sha='C4C786CABE71CFB0034D6B2F58937906A5D2649E4E1AE81BA2F339EE762C3288'},
 [pscustomobject]@{File='EAIRA.LocalOperator.Cli.exe';Bytes=139264;Sha='85F718BBCCDA14972B864F045F00D408BFD434C748141F50C692DD89F3481BA4'}
)

function Get-Sha([string]$Path) { $handle=Open-AbsoluteNative $Path $false $true 1;try{Get-ByteSha (Read-NativeBytes $handle 16777216)}finally{Close-NativeHandle $handle} }
function Get-TextSha([string]$Value) {
    $sha=[Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Value)))).Replace('-','') }
    finally { $sha.Dispose() }
}
function Get-ByteSha([byte[]]$Bytes) {
    $sha=[Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','') }
    finally { $sha.Dispose() }
}
function Get-ObjectIdentitySha([string]$Path,[bool]$Directory) {
    $flags=[uint32]0x00300000;if($Directory){$flags=[uint32]0x02300000}
    $handle=$script:Native::CreateFileW($Path,[uint32]0x00100080,3,[IntPtr]::Zero,3,$flags,[IntPtr]::Zero)
    if($handle-eq[IntPtr]::Zero-or$handle-eq[IntPtr](-1)){throw 'IDENTITY_OPEN'}
    $tag=[IntPtr]::Zero;$identity=[IntPtr]::Zero
    try {
        $tag=[Runtime.InteropServices.Marshal]::AllocHGlobal(8);for($i=0;$i-lt8;$i++){[Runtime.InteropServices.Marshal]::WriteByte($tag,$i,0)}
        if(-not$script:Native::GetFileInformationByHandleEx($handle,9,$tag,8)){throw 'IDENTITY_TAG'}
        if(([uint32][Runtime.InteropServices.Marshal]::ReadInt32($tag,0)-band[uint32]0x400)-ne0){throw 'IDENTITY_REPARSE'}
        $final=[Text.StringBuilder]::new(32768);$length=$script:Native::GetFinalPathNameByHandleW($handle,$final,32768,0)
        if($length-lt4-or$length-ge32768-or$final.ToString()-cne('\\?\'+$Path)){throw 'IDENTITY_FINAL_PATH'}
        $identity=[Runtime.InteropServices.Marshal]::AllocHGlobal(24);for($i=0;$i-lt24;$i++){[Runtime.InteropServices.Marshal]::WriteByte($identity,$i,0)}
        if(-not$script:Native::GetFileInformationByHandleEx($handle,18,$identity,24)){throw 'IDENTITY_FILE_ID'}
        $domain=[Text.Encoding]::ASCII.GetBytes('EAIRA_M5_SLICE5_OBJECT_IDENTITY_V1');$bytes=[byte[]]::new($domain.Length+1+24)
        [Array]::Copy($domain,0,$bytes,0,$domain.Length);[Runtime.InteropServices.Marshal]::Copy($identity,$bytes,$domain.Length+1,24)
        Get-ByteSha $bytes
    } finally {if($tag-ne[IntPtr]::Zero){[Runtime.InteropServices.Marshal]::FreeHGlobal($tag)};if($identity-ne[IntPtr]::Zero){[Runtime.InteropServices.Marshal]::FreeHGlobal($identity)};[void]$script:Native::CloseHandle($handle)}
}
function Assert-File([string]$Path,[long]$Bytes,[string]$Sha,[bool]$AllowHydratedCloud=$false) {
    $handle=Open-AbsoluteNative $Path $false $AllowHydratedCloud 1
    try{$actual=Read-NativeBytes $handle ([int]$Bytes);if($actual.Length-ne$Bytes-or(Get-ByteSha $actual)-cne$Sha){throw 'FILE_IDENTITY_MISMATCH'};$script:pinnedInputHandles.Add($handle);$handle=[IntPtr]::Zero}
    finally{if($handle-ne[IntPtr]::Zero){Close-NativeHandle $handle}}
}
function Assert-Root([string]$Path,[string]$Pattern,[bool]$MustExist) {
    if(-not [IO.Path]::IsPathFullyQualified($Path)){throw 'ROOT_NOT_ABSOLUTE'}
    $full=[IO.Path]::GetFullPath($Path)
    if($full -cne $Path -or [IO.Path]::GetDirectoryName($full) -ine 'C:\Temp' -or [IO.Path]::GetFileName($full) -cnotmatch $Pattern){throw 'ROOT_INVALID'}
    $handle=$script:Native::CreateFileW($full,[uint32]0x00100080,3,[IntPtr]::Zero,3,[uint32]0x02300000,[IntPtr]::Zero)
    $exists=$handle-ne[IntPtr]::Zero-and$handle-ne[IntPtr](-1)
    try { if($exists){[void](Get-NativeIdentity $handle $full $true $false)} }
    finally { if($exists){[void]$script:Native::CloseHandle($handle)} }
    if($exists-ne$MustExist){throw 'ROOT_EXISTENCE_MISMATCH'}
}
function Quote-Arg([string]$Value) {
    if($null -eq $Value -or $Value.IndexOf([char]0) -ge 0 -or $Value.Contains("`r") -or $Value.Contains("`n")){throw 'ARG_INVALID'}
    $b=[Text.StringBuilder]::new();[void]$b.Append('"');$slashes=0
    foreach($ch in $Value.ToCharArray()){
        if($ch -eq '\'){ $slashes++; continue }
        if($ch -eq '"'){[void]$b.Append(('\' * (2*$slashes+1)));[void]$b.Append('"');$slashes=0;continue}
        if($slashes){[void]$b.Append(('\' * $slashes));$slashes=0};[void]$b.Append($ch)
    }
    if($slashes){[void]$b.Append(('\' * (2*$slashes)))};[void]$b.Append('"');$b.ToString()
}
function Initialize-NativeBridge {
    $assemblyName=[Reflection.AssemblyName]::new('EAIRA.M5S5.NativeBridge')
    $assembly=[Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly($assemblyName,[Reflection.Emit.AssemblyBuilderAccess]::Run)
    $module=$assembly.DefineDynamicModule('EAIRA.M5S5.NativeBridge')
    $builder=$module.DefineType('EAIRA.M5S5.Native',[Reflection.TypeAttributes]'Public,Abstract,Sealed')
    $methodAttributes=[Reflection.MethodAttributes]'Public,Static,PinvokeImpl'
    $standard=[Reflection.CallingConventions]::Standard
    $winapi=[Runtime.InteropServices.CallingConvention]::Winapi
    function Add-NativeMethod([string]$Name,[string]$Library,[Type]$ReturnType,[Type[]]$Parameters,[Runtime.InteropServices.CharSet]$CharSet) {
        $method=$builder.DefinePInvokeMethod($Name,$Library,$methodAttributes,$standard,$ReturnType,$Parameters,$winapi,$CharSet)
        $method.SetImplementationFlags($method.GetMethodImplementationFlags() -bor [Reflection.MethodImplAttributes]::PreserveSig)
        $attributeType=[Runtime.InteropServices.DllImportAttribute]
        $fields=[Reflection.FieldInfo[]]@($attributeType.GetField('EntryPoint'),$attributeType.GetField('ExactSpelling'),$attributeType.GetField('SetLastError'),$attributeType.GetField('PreserveSig'),$attributeType.GetField('CallingConvention'),$attributeType.GetField('CharSet'))
        $values=[object[]]@($Name,$true,($Library-cne'ntdll.dll'),$true,$winapi,$CharSet)
        $method.SetCustomAttribute([Reflection.Emit.CustomAttributeBuilder]::new($attributeType.GetConstructor([Type[]]@([string])),[object[]]@($Library),$fields,$values))
        $marshalCtor=[Runtime.InteropServices.MarshalAsAttribute].GetConstructor([Type[]]@([Runtime.InteropServices.UnmanagedType]))
        if($ReturnType-eq[bool]){$method.DefineParameter(0,[Reflection.ParameterAttributes]::Retval,$null).SetCustomAttribute([Reflection.Emit.CustomAttributeBuilder]::new($marshalCtor,[object[]]@([Runtime.InteropServices.UnmanagedType]::Bool)))}
        for($parameterIndex=0;$parameterIndex-lt$Parameters.Length;$parameterIndex++){
            if($Parameters[$parameterIndex]-eq[bool]){
                $unmanaged=if($Library-ceq'ntdll.dll'){[Runtime.InteropServices.UnmanagedType]::U1}else{[Runtime.InteropServices.UnmanagedType]::Bool}
                $method.DefineParameter($parameterIndex+1,[Reflection.ParameterAttributes]::None,$null).SetCustomAttribute([Reflection.Emit.CustomAttributeBuilder]::new($marshalCtor,[object[]]@($unmanaged)))
            }
            elseif($Name-ceq'ReadFile'-and$parameterIndex-eq1){[void]$method.DefineParameter(2,[Reflection.ParameterAttributes]::Out,'buffer')}
        }
    }
    $intptrRef=[IntPtr].MakeByRefType();$uintRef=[uint32].MakeByRefType();$uintptrRef=[UIntPtr].MakeByRefType();$longRef=[int64].MakeByRefType()
    Add-NativeMethod 'CreateJobObjectW' 'kernel32.dll' ([IntPtr]) @([IntPtr],[string]) ([Runtime.InteropServices.CharSet]::Unicode)
    Add-NativeMethod 'SetInformationJobObject' 'kernel32.dll' ([bool]) @([IntPtr],[int],[IntPtr],[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'AssignProcessToJobObject' 'kernel32.dll' ([bool]) @([IntPtr],[IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'QueryInformationJobObject' 'kernel32.dll' ([bool]) @([IntPtr],[int],[IntPtr],[uint32],$uintRef) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'TerminateJobObject' 'kernel32.dll' ([bool]) @([IntPtr],[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'TerminateProcess' 'kernel32.dll' ([bool]) @([IntPtr],[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'CreateProcessW' 'kernel32.dll' ([bool]) @([string],[Text.StringBuilder],[IntPtr],[IntPtr],[bool],[uint32],[IntPtr],[string],[IntPtr],[IntPtr]) ([Runtime.InteropServices.CharSet]::Unicode)
    Add-NativeMethod 'InitializeProcThreadAttributeList' 'kernel32.dll' ([bool]) @([IntPtr],[int],[uint32],$uintptrRef) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'UpdateProcThreadAttribute' 'kernel32.dll' ([bool]) @([IntPtr],[uint32],[UIntPtr],[IntPtr],[UIntPtr],[IntPtr],[IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'DeleteProcThreadAttributeList' 'kernel32.dll' ([void]) @([IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'ResumeThread' 'kernel32.dll' ([uint32]) @([IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'WaitForSingleObject' 'kernel32.dll' ([uint32]) @([IntPtr],[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'GetExitCodeProcess' 'kernel32.dll' ([bool]) @([IntPtr],$uintRef) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'CreatePipe' 'kernel32.dll' ([bool]) @($intptrRef,$intptrRef,[IntPtr],[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'SetHandleInformation' 'kernel32.dll' ([bool]) @([IntPtr],[uint32],[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'GetFileType' 'kernel32.dll' ([uint32]) @([IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'CloseHandle' 'kernel32.dll' ([bool]) @([IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'CreateFileW' 'kernel32.dll' ([IntPtr]) @([string],[uint32],[uint32],[IntPtr],[uint32],[uint32],[IntPtr]) ([Runtime.InteropServices.CharSet]::Unicode)
    Add-NativeMethod 'GetFileInformationByHandleEx' 'kernel32.dll' ([bool]) @([IntPtr],[int],[IntPtr],[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'GetFileInformationByHandle' 'kernel32.dll' ([bool]) @([IntPtr],[IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'GetFinalPathNameByHandleW' 'kernel32.dll' ([uint32]) @([IntPtr],[Text.StringBuilder],[uint32],[uint32]) ([Runtime.InteropServices.CharSet]::Unicode)
    Add-NativeMethod 'ReadFile' 'kernel32.dll' ([bool]) @([IntPtr],[byte[]],[uint32],$uintRef,[IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'WriteFile' 'kernel32.dll' ([bool]) @([IntPtr],[byte[]],[uint32],$uintRef,[IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'FlushFileBuffers' 'kernel32.dll' ([bool]) @([IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'SetFilePointerEx' 'kernel32.dll' ([bool]) @([IntPtr],[int64],$longRef,[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'GetFileSizeEx' 'kernel32.dll' ([bool]) @([IntPtr],$longRef) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'NtCreateFile' 'ntdll.dll' ([int]) @([IntPtr],[uint32],[IntPtr],[IntPtr],[IntPtr],[uint32],[uint32],[uint32],[uint32],[IntPtr],[uint32]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'NtQueryDirectoryFile' 'ntdll.dll' ([int]) @([IntPtr],[IntPtr],[IntPtr],[IntPtr],[IntPtr],[IntPtr],[uint32],[int],[bool],[IntPtr],[bool]) ([Runtime.InteropServices.CharSet]::None)
    Add-NativeMethod 'CommandLineToArgvW' 'shell32.dll' ([IntPtr]) @([string],[IntPtr]) ([Runtime.InteropServices.CharSet]::Unicode)
    Add-NativeMethod 'LocalFree' 'kernel32.dll' ([IntPtr]) @([IntPtr]) ([Runtime.InteropServices.CharSet]::None)
    $script:Native=$builder.CreateType()
}
Initialize-NativeBridge

function Close-NativeHandle([IntPtr]$Handle) { if($Handle-ne[IntPtr]::Zero-and$Handle-ne[IntPtr](-1)){if(-not$script:Native::CloseHandle($Handle)){throw 'HANDLE_CLOSE'}} }
function Get-NativeIdentity([IntPtr]$Handle,[string]$ExpectedPath,[bool]$Directory,[bool]$AllowCloud) {
    $tag=[Runtime.InteropServices.Marshal]::AllocHGlobal(8);$info=[Runtime.InteropServices.Marshal]::AllocHGlobal(52);$id=[Runtime.InteropServices.Marshal]::AllocHGlobal(24)
    try {
        foreach($pair in @(@($tag,8),@($info,52),@($id,24))){for($i=0;$i-lt$pair[1];$i++){[Runtime.InteropServices.Marshal]::WriteByte($pair[0],$i,0)}}
        if(-not$script:Native::GetFileInformationByHandleEx($Handle,9,$tag,8)){throw 'HANDLE_TAG'}
        $attributes=[uint32]([int64][Runtime.InteropServices.Marshal]::ReadInt32($tag,0)-band 0xFFFFFFFFL);$reparseTag=[uint32]([int64][Runtime.InteropServices.Marshal]::ReadInt32($tag,4)-band 0xFFFFFFFFL)
        if(($attributes-band[uint32]0x00441000)-ne0){throw 'HANDLE_OFFLINE_OR_RECALL'}
        if(($attributes-band[uint32]0x400)-eq0-and$reparseTag-ne0){throw 'HANDLE_UNEXPECTED_TAG'}
        if(($attributes-band[uint32]0x400)-ne0-and(-not$AllowCloud-or$reparseTag-notin[uint32[]]@(2415976474,2415943706))){throw 'HANDLE_REPARSE'}
        if(((($attributes-band[uint32]0x10)-ne0))-ne$Directory){throw 'HANDLE_KIND'}
        if(-not$script:Native::GetFileInformationByHandle($Handle,$info)){throw 'HANDLE_INFO'}
        if(-not$Directory-and[uint32][Runtime.InteropServices.Marshal]::ReadInt32($info,40)-ne1){throw 'HANDLE_LINKS'}
        if(-not$script:Native::GetFileInformationByHandleEx($Handle,18,$id,24)){throw 'HANDLE_FILE_ID'}
        $final=[Text.StringBuilder]::new(32768);$length=$script:Native::GetFinalPathNameByHandleW($Handle,$final,32768,0)
        if($length-lt4-or$length-ge32768-or$final.ToString()-cne('\\?\'+$ExpectedPath)){throw 'HANDLE_FINAL_PATH'}
        $bytes=[byte[]]::new(24);[Runtime.InteropServices.Marshal]::Copy($id,$bytes,0,24);Get-ByteSha $bytes
    } finally {[Runtime.InteropServices.Marshal]::FreeHGlobal($tag);[Runtime.InteropServices.Marshal]::FreeHGlobal($info);[Runtime.InteropServices.Marshal]::FreeHGlobal($id)}
}
function Open-AbsoluteNative([string]$Path,[bool]$Directory,[bool]$AllowCloud,[uint32]$Share=1) {
    $flags=if($Directory){[uint32]0x02300000}else{[uint32]0x00300000};$handle=$script:Native::CreateFileW($Path,[uint32]0x00100081,$Share,[IntPtr]::Zero,3,$flags,[IntPtr]::Zero)
    if($handle-eq[IntPtr]::Zero-or$handle-eq[IntPtr](-1)){throw 'ABSOLUTE_OPEN'}
    try{[void](Get-NativeIdentity $handle $Path $Directory $AllowCloud);$handle}catch{Close-NativeHandle $handle;throw}
}
function Open-RelativeNative([IntPtr]$Parent,[string]$ParentPath,[string]$Leaf,[uint32]$Access,[uint32]$Share,[uint32]$Disposition,[uint32]$Options,[uint64]$ExpectedInformation,[bool]$Directory,[bool]$AllowCloud) {
    if([string]::IsNullOrEmpty($Leaf)-or$Leaf.IndexOfAny([char[]]'\/:')-ge0-or$Leaf-in@('.','..')){throw 'RELATIVE_LEAF'}
    $text=[Runtime.InteropServices.Marshal]::StringToHGlobalUni($Leaf);$unicode=[Runtime.InteropServices.Marshal]::AllocHGlobal(16);$oa=[Runtime.InteropServices.Marshal]::AllocHGlobal(48);$outHandle=[Runtime.InteropServices.Marshal]::AllocHGlobal(8);$io=[Runtime.InteropServices.Marshal]::AllocHGlobal(16)
    try {
        foreach($pair in @(@($unicode,16),@($oa,48),@($outHandle,8),@($io,16))){for($i=0;$i-lt$pair[1];$i++){[Runtime.InteropServices.Marshal]::WriteByte($pair[0],$i,0)}}
        [Runtime.InteropServices.Marshal]::WriteInt16($unicode,0,[int16]($Leaf.Length*2));[Runtime.InteropServices.Marshal]::WriteInt16($unicode,2,[int16]($Leaf.Length*2));[Runtime.InteropServices.Marshal]::WriteIntPtr($unicode,8,$text)
        [Runtime.InteropServices.Marshal]::WriteInt32($oa,0,48);[Runtime.InteropServices.Marshal]::WriteIntPtr($oa,8,$Parent);[Runtime.InteropServices.Marshal]::WriteIntPtr($oa,16,$unicode);[Runtime.InteropServices.Marshal]::WriteInt32($oa,24,0x40)
        $status=$script:Native::NtCreateFile($outHandle,$Access,$oa,$io,[IntPtr]::Zero,0,$Share,$Disposition,$Options,[IntPtr]::Zero,0);$handle=[Runtime.InteropServices.Marshal]::ReadIntPtr($outHandle);$information=[uint64][Runtime.InteropServices.Marshal]::ReadInt64($io,8)
        if($status-ne0-or$handle-eq[IntPtr]::Zero-or$handle-eq[IntPtr](-1)-or$information-ne$ExpectedInformation){if($handle-ne[IntPtr]::Zero-and$handle-ne[IntPtr](-1)){Close-NativeHandle $handle};throw 'RELATIVE_OPEN'}
        try{[void](Get-NativeIdentity $handle (Join-Path $ParentPath $Leaf) $Directory $AllowCloud);$handle}catch{Close-NativeHandle $handle;throw}
    } finally {foreach($p in @($text,$unicode,$oa,$outHandle,$io)){[Runtime.InteropServices.Marshal]::FreeHGlobal($p)}}
}
function Read-NativeBytes([IntPtr]$Handle,[int]$Maximum) {
    $size=[int64]0;if(-not$script:Native::GetFileSizeEx($Handle,[ref]$size)-or$size-lt0-or$size-gt$Maximum){throw 'READ_SIZE'};$position=[int64]-1;if(-not$script:Native::SetFilePointerEx($Handle,0,[ref]$position,0)-or$position-ne0){throw 'READ_SEEK'}
    $bytes=[byte[]]::new([int]$size);$read=[uint32]0;if($bytes.Length-and(-not$script:Native::ReadFile($Handle,$bytes,$bytes.Length,[ref]$read,[IntPtr]::Zero)-or$read-ne$bytes.Length)){throw 'READ_BYTES'}
    $extra=[byte[]]::new(1);if(-not$script:Native::ReadFile($Handle,$extra,1,[ref]$read,[IntPtr]::Zero)-or$read-ne0){throw 'READ_EOF'};$bytes
}
function Write-NativeBytes([IntPtr]$Handle,[byte[]]$Bytes) {
    $position=[int64]-1;if(-not$script:Native::SetFilePointerEx($Handle,0,[ref]$position,0)-or$position-ne0){throw 'WRITE_SEEK'};$written=[uint32]0
    if($Bytes.Length-and(-not$script:Native::WriteFile($Handle,$Bytes,$Bytes.Length,[ref]$written,[IntPtr]::Zero)-or$written-ne$Bytes.Length)){throw 'WRITE_BYTES'}
    if(-not$script:Native::FlushFileBuffers($Handle)){throw 'WRITE_FLUSH'}
    if((Get-ByteSha (Read-NativeBytes $Handle $Bytes.Length))-cne(Get-ByteSha $Bytes)){throw 'WRITE_VERIFY'}
}
function Get-NativeNames([IntPtr]$Directory) {
    $buffer=[Runtime.InteropServices.Marshal]::AllocHGlobal(65536);$io=[Runtime.InteropServices.Marshal]::AllocHGlobal(16);$names=[Collections.Generic.List[string]]::new();$restart=$true
    try {
        while($true){[Runtime.InteropServices.Marshal]::Copy([byte[]]::new(65536),0,$buffer,65536);for($i=0;$i-lt16;$i++){[Runtime.InteropServices.Marshal]::WriteByte($io,$i,0)}
            $status=$script:Native::NtQueryDirectoryFile($Directory,[IntPtr]::Zero,[IntPtr]::Zero,[IntPtr]::Zero,$io,$buffer,65536,12,$false,[IntPtr]::Zero,$restart);$restart=$false;$used=[int][Runtime.InteropServices.Marshal]::ReadInt64($io,8)
            if($status-eq-2147483642){if($used-ne0){throw 'ENUM_EOF'};break};if($status-ne0-or$used-lt12-or$used-gt65536){throw 'ENUM_STATUS'};$offset=0
            while($true){if($offset+12-gt$used){throw 'ENUM_BOUNDS'};$next=[Runtime.InteropServices.Marshal]::ReadInt32($buffer,$offset);$length=[Runtime.InteropServices.Marshal]::ReadInt32($buffer,$offset+8);if($length-lt0-or($length-band1)-ne0-or$offset+12+$length-gt$used){throw 'ENUM_NAME'};$name=[Runtime.InteropServices.Marshal]::PtrToStringUni([IntPtr]::Add($buffer,$offset+12),$length/2);if($name-notin@('.','..')){if($names.Contains($name)-or$names.Count-ge256){throw 'ENUM_DUP'};$names.Add($name)};if($next-eq0){break};if(($next-band3)-ne0-or$next-lt12-or$offset+$next-ge$used){throw 'ENUM_NEXT'};$offset+=$next}
        };$result=$names.ToArray();[Array]::Sort($result,[StringComparer]::Ordinal);$result
    } finally {[Runtime.InteropServices.Marshal]::FreeHGlobal($buffer);[Runtime.InteropServices.Marshal]::FreeHGlobal($io)}
}

$script:pinnedInputHandles=[Collections.Generic.List[IntPtr]]::new()
$script:workHandles=[Collections.Generic.List[IntPtr]]::new()
$script:workDirectoryHandles=[Collections.Generic.Dictionary[string,IntPtr]]::new([StringComparer]::OrdinalIgnoreCase)
$script:compilerGuardHandles=[Collections.Generic.List[IntPtr]]::new()
$script:expectedChildren=[Collections.Generic.Dictionary[string,Collections.Generic.List[string]]]::new([StringComparer]::OrdinalIgnoreCase)
$script:workTreeChecks=0
$script:workFileRecords=[Collections.Generic.List[object]]::new()
function Register-ExpectedChild([string]$ParentPath,[string]$Leaf) {
    if($ParentPath-ceq'C:\Temp'){return}
    if(-not$script:expectedChildren.ContainsKey($ParentPath)){$script:expectedChildren.Add($ParentPath,[Collections.Generic.List[string]]::new())}
    if($script:expectedChildren[$ParentPath].Contains($Leaf)){throw 'WORK_DUPLICATE_REGISTRATION'}
    $script:expectedChildren[$ParentPath].Add($Leaf)
}
function Assert-WorkTree {
    foreach($entry in $script:workDirectoryHandles.GetEnumerator()){
        if($entry.Key-ceq'C:\Temp'){continue}
        [void](Get-NativeIdentity $entry.Value $entry.Key $true $false)
        $actual=@(Get-NativeNames $entry.Value)
        $expected=[string[]]@();if($script:expectedChildren.ContainsKey($entry.Key)){$expected=$script:expectedChildren[$entry.Key].ToArray()}
        [Array]::Sort($expected,[StringComparer]::Ordinal)
        if(($actual-join'|')-cne($expected-join'|')){throw 'WORK_TREE_CLOSED_SET'}
    }
    if(@(Get-NativeNames $script:workDirectoryHandles[$tempRoot]).Count-ne0){throw 'WORK_TEMP_NOT_EMPTY'}
    foreach($record in $script:workFileRecords){
        if((Get-NativeIdentity $record.Handle $record.Path $false $false)-cne$record.Identity-or(Get-ByteSha (Read-NativeBytes $record.Handle $record.Bytes))-cne$record.Sha){throw 'WORK_FILE_POSTCHECK'}
    }
    $script:workTreeChecks++
}
function Register-WorkHandle([IntPtr]$Handle) {$script:workHandles.Add($Handle);$Handle}
function Close-WorkHandle([IntPtr]$Handle) {if($script:workHandles.Remove($Handle)){Close-NativeHandle $Handle}}
function New-WorkDirectory([string]$ParentPath,[string]$Leaf) {
    $parent=$script:workDirectoryHandles[$ParentPath];$path=Join-Path $ParentPath $Leaf
    $handle=Open-RelativeNative $parent $ParentPath $Leaf 0x001001A7 3 2 0x00200021 2 $true $false
    [void](Register-WorkHandle $handle);$script:workDirectoryHandles.Add($path,$handle);$path
    Register-ExpectedChild $ParentPath $Leaf
}
function New-WorkFile([string]$Path,[byte[]]$Bytes) {
    $parentPath=Split-Path -Parent $Path;$leaf=Split-Path -Leaf $Path;$parent=$script:workDirectoryHandles[$parentPath]
    $writer=Open-RelativeNative $parent $parentPath $leaf 0x00100183 1 2 0x00200060 2 $false $false;[void](Register-WorkHandle $writer)
    Register-ExpectedChild $parentPath $leaf
    Write-NativeBytes $writer $Bytes
    $identity=Get-NativeIdentity $writer $Path $false $false;$expectedSha=Get-ByteSha $Bytes
    $bridge=Open-RelativeNative $parent $parentPath $leaf 0x00100081 3 1 0x00200060 1 $false $false;[void](Register-WorkHandle $bridge)
    if((Get-NativeIdentity $bridge $Path $false $false)-cne$identity-or(Get-ByteSha (Read-NativeBytes $bridge $Bytes.Length))-cne$expectedSha){throw 'WORK_BRIDGE_IDENTITY'}
    Close-WorkHandle $writer
    $guard=Open-RelativeNative $parent $parentPath $leaf 0x00100081 1 1 0x00200060 1 $false $false;[void](Register-WorkHandle $guard)
    if((Get-NativeIdentity $guard $Path $false $false)-cne$identity-or(Get-ByteSha (Read-NativeBytes $guard $Bytes.Length))-cne$expectedSha){throw 'WORK_GUARD_IDENTITY'}
    Close-WorkHandle $bridge
    $script:workFileRecords.Add([pscustomobject]@{Handle=$guard;Path=$Path;Identity=$identity;Bytes=$Bytes.Length;Sha=$expectedSha})
    $guard
}
function New-CompilerOutputLease([string]$Path) {
    $parentPath=Split-Path -Parent $Path;$leaf=Split-Path -Leaf $Path;$parent=$script:workDirectoryHandles[$parentPath]
    $handle=Open-RelativeNative $parent $parentPath $leaf 0x00100080 3 2 0x00200060 2 $false $false;[void](Register-WorkHandle $handle)
    Register-ExpectedChild $parentPath $leaf
    [pscustomobject]@{Handle=$handle;Identity=(Get-NativeIdentity $handle $Path $false $false);Path=$Path;Parent=$parent;ParentPath=$parentPath;Leaf=$leaf}
}
function Seal-CompilerOutput($Lease) {
    $guard=Open-RelativeNative $Lease.Parent $Lease.ParentPath $Lease.Leaf 0x00100081 1 1 0x00200060 1 $false $false;[void](Register-WorkHandle $guard)
    if((Get-NativeIdentity $Lease.Handle $Lease.Path $false $false)-cne(Get-NativeIdentity $guard $Lease.Path $false $false)){throw 'COMPILER_OUTPUT_IDENTITY'}
    Close-WorkHandle $Lease.Handle;$script:compilerGuardHandles.Add($guard);$guard
}
function Close-AllNativeHandles {
    for($i=$script:compilerGuardHandles.Count-1;$i-ge0;$i--){$h=$script:compilerGuardHandles[$i];if($script:workHandles.Remove($h)){Close-NativeHandle $h}};$script:compilerGuardHandles.Clear()
    for($i=$script:workHandles.Count-1;$i-ge0;$i--){Close-NativeHandle $script:workHandles[$i]};$script:workHandles.Clear()
    for($i=$script:pinnedInputHandles.Count-1;$i-ge0;$i--){Close-NativeHandle $script:pinnedInputHandles[$i]};$script:pinnedInputHandles.Clear()
}

function Invoke-Child([string]$File,[string[]]$Arguments,[string]$WorkingDirectory,[int]$TimeoutSeconds) {
    $script:childCount++
    Assert-WorkTree
    $fileGuard=Open-AbsoluteNative $File $false $false 1;$fileIdentity=Get-NativeIdentity $fileGuard $File $false $false;$fileSha=Get-Sha $File
    $job=[IntPtr]::Zero;$process=[IntPtr]::Zero;$thread=[IntPtr]::Zero;$stdin=[IntPtr]::Zero
    $outRead=[IntPtr]::Zero;$outWrite=[IntPtr]::Zero;$errRead=[IntPtr]::Zero;$errWrite=[IntPtr]::Zero
    $limits=[IntPtr]::Zero;$accounting=[IntPtr]::Zero;$security=[IntPtr]::Zero;$attribute=[IntPtr]::Zero
    $handleList=[IntPtr]::Zero;$startup=[IntPtr]::Zero;$processInfo=[IntPtr]::Zero;$environment=[IntPtr]::Zero;$limitQuery=[IntPtr]::Zero;$argcPointer=[IntPtr]::Zero;$argvPointer=[IntPtr]::Zero
    $attributeInitialized=$false;$outStream=$null;$errStream=$null;$outBytes=$null;$errBytes=$null
    $assigned=$false;$completed=$false
    try {
        $job=$script:Native::CreateJobObjectW([IntPtr]::Zero,$null);if($job -eq [IntPtr]::Zero){throw 'JOB_CREATE'}
        $limits=[Runtime.InteropServices.Marshal]::AllocHGlobal(144);for($i=0;$i-lt144;$i++){[Runtime.InteropServices.Marshal]::WriteByte($limits,$i,0)}
        [Runtime.InteropServices.Marshal]::WriteInt32($limits,16,0x2408);[Runtime.InteropServices.Marshal]::WriteInt32($limits,40,1)
        if(-not $script:Native::SetInformationJobObject($job,9,$limits,144)){throw 'JOB_SET'}
        $limitQuery=[Runtime.InteropServices.Marshal]::AllocHGlobal(144);for($i=0;$i-lt144;$i++){[Runtime.InteropServices.Marshal]::WriteByte($limitQuery,$i,0)};$limitReturned=[uint32]0
        if(-not$script:Native::QueryInformationJobObject($job,9,$limitQuery,144,[ref]$limitReturned)-or$limitReturned-ne144-or[Runtime.InteropServices.Marshal]::ReadInt32($limitQuery,16)-ne0x2408-or[Runtime.InteropServices.Marshal]::ReadInt32($limitQuery,40)-ne1){throw 'JOB_LIMIT_REQUERY'}
        $security=[Runtime.InteropServices.Marshal]::AllocHGlobal(24);for($i=0;$i-lt24;$i++){[Runtime.InteropServices.Marshal]::WriteByte($security,$i,0)}
        [Runtime.InteropServices.Marshal]::WriteInt32($security,0,24);[Runtime.InteropServices.Marshal]::WriteInt32($security,16,1)
        if(-not $script:Native::CreatePipe([ref]$outRead,[ref]$outWrite,$security,0) -or -not $script:Native::SetHandleInformation($outRead,1,0)){throw 'STDOUT_PIPE'}
        if(-not $script:Native::CreatePipe([ref]$errRead,[ref]$errWrite,$security,0) -or -not $script:Native::SetHandleInformation($errRead,1,0)){throw 'STDERR_PIPE'}
        $stdin=$script:Native::CreateFileW('NUL',[uint32]2147483648,3,$security,3,0x80,[IntPtr]::Zero)
        if($stdin -eq [IntPtr]::Zero -or $stdin -eq [IntPtr](-1) -or $script:Native::GetFileType($stdin) -ne 2){throw 'STDIN_NUL'}
        $size=[UIntPtr]::Zero
        $queryResult=$script:Native::InitializeProcThreadAttributeList([IntPtr]::Zero,1,0,[ref]$size)
        $queryError=[Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if($queryResult-or$queryError-ne122-or$size.ToUInt64()-lt1-or$size.ToUInt64()-gt65536){throw 'ATTRIBUTE_QUERY'}
        $attribute=[Runtime.InteropServices.Marshal]::AllocHGlobal([int]$size.ToUInt64());for($i=0;$i-lt[int]$size.ToUInt64();$i++){[Runtime.InteropServices.Marshal]::WriteByte($attribute,$i,0)}
        if(-not $script:Native::InitializeProcThreadAttributeList($attribute,1,0,[ref]$size)) {throw 'ATTRIBUTE_INIT'};$attributeInitialized=$true
        $handleList=[Runtime.InteropServices.Marshal]::AllocHGlobal(24);[Runtime.InteropServices.Marshal]::WriteInt64($handleList,0,$stdin.ToInt64());[Runtime.InteropServices.Marshal]::WriteInt64($handleList,8,$outWrite.ToInt64());[Runtime.InteropServices.Marshal]::WriteInt64($handleList,16,$errWrite.ToInt64())
        if(-not $script:Native::UpdateProcThreadAttribute($attribute,0,[UIntPtr]0x00020002,$handleList,[UIntPtr]24,[IntPtr]::Zero,[IntPtr]::Zero)){throw 'ATTRIBUTE_UPDATE'}
        $startup=[Runtime.InteropServices.Marshal]::AllocHGlobal(112);for($i=0;$i-lt112;$i++){[Runtime.InteropServices.Marshal]::WriteByte($startup,$i,0)}
        [Runtime.InteropServices.Marshal]::WriteInt32($startup,0,112);[Runtime.InteropServices.Marshal]::WriteInt32($startup,60,0x100)
        [Runtime.InteropServices.Marshal]::WriteInt64($startup,80,$stdin.ToInt64());[Runtime.InteropServices.Marshal]::WriteInt64($startup,88,$outWrite.ToInt64());[Runtime.InteropServices.Marshal]::WriteInt64($startup,96,$errWrite.ToInt64());[Runtime.InteropServices.Marshal]::WriteInt64($startup,104,$attribute.ToInt64())
        $processInfo=[Runtime.InteropServices.Marshal]::AllocHGlobal(24);for($i=0;$i-lt24;$i++){[Runtime.InteropServices.Marshal]::WriteByte($processInfo,$i,0)}
        $pairs=@();foreach($name in @('SystemRoot','TEMP','TMP','WINDIR')|Sort-Object -CaseSensitive){$value=if($name-in@('TEMP','TMP')){$tempRoot}else{[Environment]::GetEnvironmentVariable($name)};$pairs+=($name+'='+$value)}
        $environmentBytes=[Text.Encoding]::Unicode.GetBytes(($pairs-join[char]0)+[char]0+[char]0);$environment=[Runtime.InteropServices.Marshal]::AllocHGlobal($environmentBytes.Length);[Runtime.InteropServices.Marshal]::Copy($environmentBytes,0,$environment,$environmentBytes.Length)
        $commandLine=[Text.StringBuilder]::new(((@($File)+$Arguments|ForEach-Object{Quote-Arg $_})-join' '))
        $argcPointer=[Runtime.InteropServices.Marshal]::AllocHGlobal(4);[Runtime.InteropServices.Marshal]::WriteInt32($argcPointer,0,0);$argvPointer=$script:Native::CommandLineToArgvW($commandLine.ToString(),$argcPointer);if($argvPointer-eq[IntPtr]::Zero){throw 'ARGV_PARSE'}
        $argc=[Runtime.InteropServices.Marshal]::ReadInt32($argcPointer);$expectedArgv=@($File)+$Arguments;if($argc-ne$expectedArgv.Count){throw 'ARGV_COUNT'};for($i=0;$i-lt$argc;$i++){$value=[Runtime.InteropServices.Marshal]::PtrToStringUni([Runtime.InteropServices.Marshal]::ReadIntPtr($argvPointer,$i*[IntPtr]::Size));if($value-cne$expectedArgv[$i]){throw 'ARGV_ROUNDTRIP'}}
        [void]$script:Native::LocalFree($argvPointer);$argvPointer=[IntPtr]::Zero
        if(-not $script:Native::CreateProcessW($File,$commandLine,[IntPtr]::Zero,[IntPtr]::Zero,$true,0x08080404,$environment,$WorkingDirectory,$startup,$processInfo)){throw 'PROCESS_CREATE'}
        $process=[Runtime.InteropServices.Marshal]::ReadIntPtr($processInfo,0);$thread=[Runtime.InteropServices.Marshal]::ReadIntPtr($processInfo,8)
        if(-not $script:Native::AssignProcessToJobObject($job,$process)){throw 'JOB_ASSIGN'};$assigned=$true
        if($script:Native::ResumeThread($thread) -eq 0xFFFFFFFF){[void]$script:Native::TerminateJobObject($job,1);throw 'PROCESS_RESUME'}
        [void]$script:Native::CloseHandle($thread);$thread=[IntPtr]::Zero
        [void]$script:Native::CloseHandle($stdin);$stdin=[IntPtr]::Zero;[void]$script:Native::CloseHandle($outWrite);$outWrite=[IntPtr]::Zero;[void]$script:Native::CloseHandle($errWrite);$errWrite=[IntPtr]::Zero
        $outSafe=[Microsoft.Win32.SafeHandles.SafeFileHandle]::new($outRead,$true);$outRead=[IntPtr]::Zero;$errSafe=[Microsoft.Win32.SafeHandles.SafeFileHandle]::new($errRead,$true);$errRead=[IntPtr]::Zero
        $outStream=[IO.FileStream]::new($outSafe,[IO.FileAccess]::Read,4096,$false);$errStream=[IO.FileStream]::new($errSafe,[IO.FileAccess]::Read,4096,$false);$outBytes=[IO.MemoryStream]::new();$errBytes=[IO.MemoryStream]::new();$outBuffer=[byte[]]::new(4096);$errBuffer=[byte[]]::new(4096)
        $outTask=$outStream.ReadAsync($outBuffer,0,$outBuffer.Length);$errTask=$errStream.ReadAsync($errBuffer,0,$errBuffer.Length);$outDone=$false;$errDone=$false;$timer=[Diagnostics.Stopwatch]::StartNew()
        while($true){
            if(-not$outDone-and$outTask.IsCompleted){$n=$outTask.GetAwaiter().GetResult();if($n-eq0){$outDone=$true}else{if($n-lt0-or$n-gt(65536-$outBytes.Length)){throw 'STDOUT_CAP'};$outBytes.Write($outBuffer,0,$n);$outTask=$outStream.ReadAsync($outBuffer,0,$outBuffer.Length)}}
            if(-not$errDone-and$errTask.IsCompleted){$n=$errTask.GetAwaiter().GetResult();if($n-eq0){$errDone=$true}else{if($n-lt0-or$n-gt(65536-$errBytes.Length)){throw 'STDERR_CAP'};$errBytes.Write($errBuffer,0,$n);$errTask=$errStream.ReadAsync($errBuffer,0,$errBuffer.Length)}}
            $wait=$script:Native::WaitForSingleObject($process,0);if($wait-ne0-and$wait-ne258){throw 'CHILD_WAIT'};if($wait-eq0-and$outDone-and$errDone){break};if($timer.Elapsed.TotalSeconds-ge$TimeoutSeconds){[void]$script:Native::TerminateJobObject($job,1);[void]$script:Native::WaitForSingleObject($process,5000);throw 'CHILD_TIMEOUT'};Start-Sleep -Milliseconds 2
        }
        $exit=[uint32]259;if(-not $script:Native::GetExitCodeProcess($process,[ref]$exit) -or $exit-eq259){throw 'CHILD_EXIT_QUERY'}
        $utf8=[Text.UTF8Encoding]::new($false,$true);$stdout=$utf8.GetString($outBytes.ToArray());$stderr=$utf8.GetString($errBytes.ToArray())
        $accounting=[Runtime.InteropServices.Marshal]::AllocHGlobal(48);for($i=0;$i-lt48;$i++){[Runtime.InteropServices.Marshal]::WriteByte($accounting,$i,0)};$returned=[uint32]0
        $active=-1
        for($attempt=0;$attempt-lt100;$attempt++){
            if(-not $script:Native::QueryInformationJobObject($job,1,$accounting,48,[ref]$returned) -or $returned-ne48){throw 'JOB_ACCOUNTING'}
            $active=[Runtime.InteropServices.Marshal]::ReadInt32($accounting,40)
            if($active-eq0){break};Start-Sleep -Milliseconds 50
        }
        $total=[Runtime.InteropServices.Marshal]::ReadInt32($accounting,36);$terminated=[Runtime.InteropServices.Marshal]::ReadInt32($accounting,44)
        if($total-ne2-or$active-ne0-or$terminated-ne0){throw ('JOB_ACCOUNTING_T'+$total+'_A'+$active+'_X'+$terminated)}
        $completed=$true
        $script:descendantCount+=($total-1)
        if((Get-NativeIdentity $fileGuard $File $false $false)-cne$fileIdentity-or(Get-Sha $File)-cne$fileSha){throw 'EXECUTABLE_IDENTITY_CHANGE'}
        $argumentSha=Get-TextSha (($Arguments|ForEach-Object{([Text.Encoding]::UTF8.GetByteCount($_)).ToString()+'|'+$_})-join"`n");$script:childRows.Add((Split-Path -Leaf $File)+'|'+$fileSha+'|'+$argumentSha+'|'+$exit+'|'+$outBytes.Length+'|'+(Get-ByteSha $outBytes.ToArray())+'|'+$errBytes.Length+'|'+(Get-ByteSha $errBytes.ToArray())+'|'+$total+'|'+$active+'|'+$terminated)
        Assert-WorkTree
        [pscustomobject]@{Exit=[int]$exit;Stdout=$stdout;Stderr=$stderr}
    } catch {
        if($process-ne[IntPtr]::Zero-and-not$completed){
            $terminatedOk=if($assigned){$script:Native::TerminateJobObject($job,1)}else{$script:Native::TerminateProcess($process,1)}
            if(-not$terminatedOk-or$script:Native::WaitForSingleObject($process,5000)-ne0){throw 'CHILD_TERMINATION_UNVERIFIED'}
            if($assigned){
                $failureAccounting=[Runtime.InteropServices.Marshal]::AllocHGlobal(48)
                try{
                    $failureActive=-1
                    for($attempt=0;$attempt-lt100;$attempt++){
                        $failureReturned=[uint32]0
                        if(-not$script:Native::QueryInformationJobObject($job,1,$failureAccounting,48,[ref]$failureReturned)-or$failureReturned-ne48){throw 'JOB_TERMINATION_QUERY'}
                        $failureActive=[Runtime.InteropServices.Marshal]::ReadInt32($failureAccounting,40)
                        if($failureActive-eq0){break};Start-Sleep -Milliseconds 50
                    }
                    if($failureActive-ne0){throw 'JOB_TERMINATION_UNVERIFIED'}
                }finally{[Runtime.InteropServices.Marshal]::FreeHGlobal($failureAccounting)}
            }
        }
        throw
    } finally {
        if($outStream){$outStream.Dispose()};if($errStream){$errStream.Dispose()};if($outBytes){$outBytes.Dispose()};if($errBytes){$errBytes.Dispose()}
        foreach($h in @($thread,$process,$stdin,$outRead,$outWrite,$errRead,$errWrite,$job)){if($h-ne[IntPtr]::Zero){[void]$script:Native::CloseHandle($h)}}
        if($attributeInitialized){$script:Native::DeleteProcThreadAttributeList($attribute)}
        if($argvPointer-ne[IntPtr]::Zero){[void]$script:Native::LocalFree($argvPointer)}
        foreach($p in @($limits,$limitQuery,$accounting,$security,$attribute,$handleList,$startup,$processInfo,$environment,$argcPointer)){if($p-ne[IntPtr]::Zero){[Runtime.InteropServices.Marshal]::FreeHGlobal($p)}}
        Close-NativeHandle $fileGuard
    }
}
function Invoke-Compile([string]$Output,[string]$Main,[string[]]$Sources,[switch]$Harness,[string[]]$ExtraReferences) {
    $lease=New-CompilerOutputLease $Output
    $args=@('/nologo','/noconfig','/nostdlib+','/deterministic+','/platform:x64','/target:exe','/optimize+','/debug-','/checked+','/highentropyva+','/warn:4','/warnaserror+','/codepage:65001')
    if($Harness){$args+='/define:EAIRA_PACKAGE_TEST_SEAMS'}
    $args+="/reference:$mscorlib";$args+="/reference:$system";foreach($r in $ExtraReferences){$args+="/reference:$r"}
    $args+="/pathmap:$snapshot=/_/EAIRA/apps/agent-services";$args+="/main:$Main";$args+="/out:$Output";$args+=$Sources
    $result=Invoke-Child $RoslynCscPath $args $tempRoot 30
    if($result.Exit -ne 0 -or $result.Stdout.Length -ne 0 -or $result.Stderr.Length -ne 0){throw 'COMPILE_FAIL'}
    [void](Seal-CompilerOutput $lease)
}
function Invoke-Exact([string]$File,[string[]]$ChildArguments,[string]$Expected) {
    $result=Invoke-Child $File $ChildArguments $tempRoot 60
    $label=($ChildArguments[0] -replace '[^A-Za-z0-9]','_').ToUpperInvariant()
    if($result.Exit -ne 0){throw ('CHANNEL_EXIT_'+$label)}
    if($result.Stderr.Length -ne 0){throw ('CHANNEL_STDERR_'+$label)}
    if($result.Stdout -cne ($Expected+"`n")){throw ('CHANNEL_STDOUT_'+$label)}
}
function Get-TreeSha([string]$Root) {
    $rootHandle=Open-AbsoluteNative $Root $true $false 3;$opened=[Collections.Generic.List[IntPtr]]::new();$rows=[Collections.Generic.List[string]]::new()
    try {
        $top=Get-NativeNames $rootHandle;$expectedTop=@('EAIRA_UNSIGNED_CUSTOMER_PACKAGE_MANIFEST_V1.json','README.txt','payload');[Array]::Sort($expectedTop,[StringComparer]::Ordinal);if(($top-join'|')-cne($expectedTop-join'|')){throw 'PACKAGE_TREE_TOP'}
        foreach($name in @('EAIRA_UNSIGNED_CUSTOMER_PACKAGE_MANIFEST_V1.json','README.txt')){$h=Open-RelativeNative $rootHandle $Root $name 0x00100081 1 1 0x00200060 1 $false $false;$opened.Add($h);$b=Read-NativeBytes $h 65536;$rows.Add($name+'|'+$b.Length+'|'+(Get-ByteSha $b))}
        $payloadPath=Join-Path $Root 'payload';$payload=Open-RelativeNative $rootHandle $Root 'payload' 0x00100081 3 1 0x00200021 1 $true $false;$opened.Add($payload)
        $names=Get-NativeNames $payload;foreach($name in $names){$h=Open-RelativeNative $payload $payloadPath $name 0x00100081 1 1 0x00200060 1 $false $false;$opened.Add($h);$b=Read-NativeBytes $h 1048576;$rows.Add('payload/'+$name+'|'+$b.Length+'|'+(Get-ByteSha $b))}
        $ordered=$rows.ToArray();[Array]::Sort($ordered,[StringComparer]::Ordinal);Get-TextSha (($ordered-join"`n")+"`n")
    } finally {for($i=$opened.Count-1;$i-ge0;$i--){Close-NativeHandle $opened[$i]};Close-NativeHandle $rootHandle}
}
function Get-TypeRefName($Reader,$Handle,[int]$Depth=0) {
    if($Depth-gt32){throw 'TYPEREF_DEPTH'}
    $row=$Reader.GetTypeReference($Handle);$name=$Reader.GetString($row.Name);$ns=$Reader.GetString($row.Namespace)
    if($row.ResolutionScope.Kind -eq [System.Reflection.Metadata.HandleKind]::TypeReference){return (Get-TypeRefName $Reader ([System.Reflection.Metadata.TypeReferenceHandle]$row.ResolutionScope) ($Depth+1))+'+'+$name}
    if([string]::IsNullOrEmpty($ns)){return $name};$ns+'.'+$name
}
function Assert-MetadataToken($Reader,[int]$Token,[string[]]$Allowed,[int]$Depth=0) {
    if($Depth-gt32){throw 'METADATA_RECURSION'}
    $handle=[System.Reflection.Metadata.Ecma335.MetadataTokens]::EntityHandle($Token)
    $kind=$handle.Kind.ToString();$row=$Token-band0x00FFFFFF;$table=($Token-shr24)-band255
    if($row-eq0-or$kind-cnotin$Allowed-or$row-gt[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetTableRowCount($Reader,[System.Reflection.Metadata.Ecma335.TableIndex]$table)){throw 'METADATA_TOKEN'}
    if($script:metadataVisited.Contains($Token)){return}
    if(-not$script:metadataActive.Add($Token)){throw 'METADATA_CYCLE'}
    try{
    switch($kind){
        'TypeDefinition' {$d=$Reader.GetTypeDefinition([System.Reflection.Metadata.TypeDefinitionHandle]$handle);[void]$Reader.GetString($d.Name);[void]$Reader.GetString($d.Namespace);if(-not$d.BaseType.IsNil){Assert-MetadataToken $Reader ([System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($d.BaseType)) @('TypeDefinition','TypeReference','TypeSpecification') ($Depth+1)}}
        'TypeReference' {$d=$Reader.GetTypeReference([System.Reflection.Metadata.TypeReferenceHandle]$handle);[void]$Reader.GetString($d.Name);[void]$Reader.GetString($d.Namespace);Assert-MetadataToken $Reader ([System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($d.ResolutionScope)) @('ModuleDefinition','ModuleReference','AssemblyReference','TypeReference') ($Depth+1)}
        'TypeSpecification' {$d=$Reader.GetTypeSpecification([System.Reflection.Metadata.TypeSpecificationHandle]$handle);Assert-MetadataSignature $Reader ($Reader.GetBlobBytes($d.Signature)) 'Type' ($Depth+1)}
        'MethodDefinition' {$d=$Reader.GetMethodDefinition([System.Reflection.Metadata.MethodDefinitionHandle]$handle);[void]$Reader.GetString($d.Name);Assert-MetadataSignature $Reader ($Reader.GetBlobBytes($d.Signature)) 'Method' ($Depth+1)}
        'FieldDefinition' {$d=$Reader.GetFieldDefinition([System.Reflection.Metadata.FieldDefinitionHandle]$handle);[void]$Reader.GetString($d.Name);Assert-MetadataSignature $Reader ($Reader.GetBlobBytes($d.Signature)) 'Field' ($Depth+1)}
        'MemberReference' {$d=$Reader.GetMemberReference([System.Reflection.Metadata.MemberReferenceHandle]$handle);[void]$Reader.GetString($d.Name);Assert-MetadataToken $Reader ([System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($d.Parent)) @('TypeDefinition','TypeReference','TypeSpecification','MethodDefinition','ModuleReference') ($Depth+1);Assert-MetadataSignature $Reader ($Reader.GetBlobBytes($d.Signature)) 'Member' ($Depth+1)}
        'MethodSpecification' {
            $d=$Reader.GetMethodSpecification([System.Reflection.Metadata.MethodSpecificationHandle]$handle)
            Assert-MetadataToken $Reader ([System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($d.Method)) @('MethodDefinition','MemberReference') ($Depth+1)
            if($d.Method.Kind.ToString()-ceq'MemberReference'){
                $target=$Reader.GetMemberReference([System.Reflection.Metadata.MemberReferenceHandle]$d.Method);if($target.GetKind().ToString()-cne'Method'){throw 'METHODSPEC_TARGET'}
            }else{$target=$Reader.GetMethodDefinition([System.Reflection.Metadata.MethodDefinitionHandle]$d.Method)}
            $signature=$Reader.GetBlobBytes($target.Signature);if($signature.Length-lt2-or($signature[0]-band16)-eq0){throw 'METHODSPEC_GENERIC_TARGET'}
            $targetPosition=1;$arity=Read-SignatureNumber $signature ([ref]$targetPosition)
            $instantiation=$Reader.GetBlobBytes($d.Signature);$argumentPosition=1;$arguments=Read-SignatureNumber $instantiation ([ref]$argumentPosition)
            if($arity-ne$arguments){throw 'METHODSPEC_ARITY'}
            Assert-MetadataSignature $Reader $instantiation 'MethodSpec' ($Depth+1)
        }
        'StandaloneSignature' {$d=$Reader.GetStandaloneSignature([System.Reflection.Metadata.StandaloneSignatureHandle]$handle);Assert-MetadataSignature $Reader ($Reader.GetBlobBytes($d.Signature)) 'Standalone' ($Depth+1)}
        'AssemblyReference' {$d=$Reader.GetAssemblyReference([System.Reflection.Metadata.AssemblyReferenceHandle]$handle);[void]$Reader.GetString($d.Name);[void]$Reader.GetString($d.Culture);[void]$Reader.GetBlobBytes($d.PublicKeyOrToken);[void]$Reader.GetBlobBytes($d.HashValue)}
        'ModuleReference' {$d=$Reader.GetModuleReference([System.Reflection.Metadata.ModuleReferenceHandle]$handle);[void]$Reader.GetString($d.Name)}
        'ModuleDefinition' {if($row-ne1){throw 'METADATA_MODULE'};[void]$Reader.GetString($Reader.GetModuleDefinition().Name)}
        default {throw 'METADATA_TOKEN_KIND'}
    }
    [void]$script:metadataVisited.Add($Token)
    }finally{[void]$script:metadataActive.Remove($Token)}
}
function Read-SignatureNumber([byte[]]$Bytes,[ref]$Position,[switch]$Signed) {
    if($Position.Value-ge$Bytes.Length){throw 'SIGNATURE_BOUNDS'}
    $first=[int]$Bytes[$Position.Value];$Position.Value++
    $remaining=if(($first-band128)-eq0){0}elseif(($first-band192)-eq128){1}elseif(($first-band224)-eq192){3}else{throw 'SIGNATURE_NUMBER'}
    if($Position.Value+$remaining-gt$Bytes.Length){throw 'SIGNATURE_BOUNDS'}
    $value=$first-band$(if($remaining-eq0){127}elseif($remaining-eq1){63}else{31})
    for($k=0;$k-lt$remaining;$k++){$value=($value-shl8)-bor$Bytes[$Position.Value];$Position.Value++}
    if($Signed){
        $negative=($value-band1)-ne0;$value=$value-shr1
        if($negative){$value-=1-shl$(if($remaining-eq0){6}elseif($remaining-eq1){13}else{28})}
        if(($remaining-eq1-and$value-ge-64-and$value-le63)-or($remaining-eq3-and$value-ge-8192-and$value-le8191)){throw 'SIGNATURE_NONCANONICAL'}
    }elseif(($remaining-eq1-and$value-lt128)-or($remaining-eq3-and$value-lt16384)){throw 'SIGNATURE_NONCANONICAL'}
    $value
}
function Assert-SignatureNumberControls {
    foreach($signed in @($false,$true)){
        $values=if($signed){@(-268435456,-8193,-8192,-65,-64,-1,0,1,63,64,8191,8192,268435455)}else{@(0,1,127,128,16383,16384,536870911)}
        foreach($value in $values){
            $builder=[System.Reflection.Metadata.BlobBuilder]::new()
            if($signed){$builder.WriteCompressedSignedInteger($value)}else{$builder.WriteCompressedInteger($value)}
            $bytes=$builder.ToArray();$position=0;$decoded=Read-SignatureNumber $bytes ([ref]$position) -Signed:$signed
            if($decoded-ne$value-or$position-ne$bytes.Length){throw 'SIGNATURE_NUMBER_GOLDEN'}
        }
        foreach($bytes in @([byte[]]@(128,0),[byte[]]@(192,0,0,0))){
            $position=0;$rejected=$false
            try{[void](Read-SignatureNumber $bytes ([ref]$position) -Signed:$signed)}
            catch{if($_.Exception.Message-cne'SIGNATURE_NONCANONICAL'){throw};$rejected=$true}
            if(-not$rejected){throw 'SIGNATURE_NUMBER_NEGATIVE'}
        }
    }
}
function Read-SignatureType($Reader,[byte[]]$Bytes,[ref]$Position,[int]$Depth,[bool]$AllowVoid=$false) {
    if($Depth-gt32-or$Position.Value-ge$Bytes.Length){throw 'SIGNATURE_DEPTH'}
    $code=[int]$Bytes[$Position.Value];$Position.Value++
    switch($code){
        1 {if(-not$AllowVoid){throw 'SIGNATURE_VOID'};return}
        {$_-ge2-and$_-le14} {return}
        {$_-in@(22,24,25,28)} {return}
        {$_-in@(15,16,29,69)} {Read-SignatureType $Reader $Bytes $Position ($Depth+1) ($code-eq15);return}
        {$_-in@(17,18,31,32)} {
            $coded=Read-SignatureNumber $Bytes $Position;$tag=$coded-band3;$rid=$coded-shr2
            if($tag-gt2-or$rid-eq0){throw 'SIGNATURE_TYPE_TOKEN'}
            $table=@(2,1,27)[$tag];Assert-MetadataToken $Reader (($table-shl24)-bor$rid) @('TypeDefinition','TypeReference','TypeSpecification') ($Depth+1)
            if($code-in@(31,32)){Read-SignatureType $Reader $Bytes $Position ($Depth+1) $AllowVoid};return
        }
        {$_-in@(19,30)} {[void](Read-SignatureNumber $Bytes $Position);return}
        20 {
            Read-SignatureType $Reader $Bytes $Position ($Depth+1)
            $rank=Read-SignatureNumber $Bytes $Position;if($rank-lt1-or$rank-gt32){throw 'SIGNATURE_ARRAY'}
            $sizes=Read-SignatureNumber $Bytes $Position;if($sizes-gt$rank){throw 'SIGNATURE_ARRAY'};for($k=0;$k-lt$sizes;$k++){[void](Read-SignatureNumber $Bytes $Position)}
            $bounds=Read-SignatureNumber $Bytes $Position;if($bounds-gt$rank){throw 'SIGNATURE_ARRAY'};for($k=0;$k-lt$bounds;$k++){[void](Read-SignatureNumber $Bytes $Position -Signed)};return
        }
        21 {
            if($Position.Value-ge$Bytes.Length-or$Bytes[$Position.Value]-notin@(17,18)){throw 'SIGNATURE_GENERIC_TYPE'}
            Read-SignatureType $Reader $Bytes $Position ($Depth+1)
            $count=Read-SignatureNumber $Bytes $Position;if($count-lt1-or$count-gt256){throw 'SIGNATURE_GENERIC_COUNT'}
            for($k=0;$k-lt$count;$k++){Read-SignatureType $Reader $Bytes $Position ($Depth+1)};return
        }
        27 {Read-MethodSignature $Reader $Bytes $Position ($Depth+1);return}
        default {throw 'SIGNATURE_ELEMENT'}
    }
}
function Read-MethodSignature($Reader,[byte[]]$Bytes,[ref]$Position,[int]$Depth) {
    if($Depth-gt32-or$Position.Value-ge$Bytes.Length){throw 'SIGNATURE_METHOD'}
    $header=[int]$Bytes[$Position.Value];$Position.Value++
    if(($header-band128)-ne0-or($header-band15)-notin@(0,1,2,3,4,5)){throw 'SIGNATURE_CALLING_CONVENTION'}
    if(($header-band16)-ne0){$generic=Read-SignatureNumber $Bytes $Position;if($generic-lt1-or$generic-gt256){throw 'SIGNATURE_GENERIC_COUNT'}}
    $count=Read-SignatureNumber $Bytes $Position;if($count-gt4096){throw 'SIGNATURE_PARAMETER_COUNT'}
    Read-SignatureType $Reader $Bytes $Position ($Depth+1) $true
    $sentinel=$false
    for($k=0;$k-lt$count;$k++){
        if($Position.Value-lt$Bytes.Length-and$Bytes[$Position.Value]-eq65){if($sentinel-or($header-band15)-ne5){throw 'SIGNATURE_SENTINEL'};$sentinel=$true;$Position.Value++}
        Read-SignatureType $Reader $Bytes $Position ($Depth+1)
    }
}
function Assert-MetadataSignature($Reader,[byte[]]$Bytes,[string]$Kind,[int]$Depth) {
    if($Bytes.Length-lt1-or$Bytes.Length-gt65536-or$Depth-gt32){throw 'SIGNATURE_SIZE'}
    $position=0
    if($Kind-ceq'Type'){Read-SignatureType $Reader $Bytes ([ref]$position) ($Depth+1)}
    elseif($Kind-ceq'MethodSpec'){
        if($Bytes[$position++]-ne10){throw 'SIGNATURE_METHODSPEC'}
        $count=Read-SignatureNumber $Bytes ([ref]$position);if($count-lt1-or$count-gt256){throw 'SIGNATURE_GENERIC_COUNT'}
        for($k=0;$k-lt$count;$k++){Read-SignatureType $Reader $Bytes ([ref]$position) ($Depth+1)}
    }
    elseif($Kind-ceq'Field'-or($Kind-ceq'Member'-and$Bytes[0]-eq6)){
        if($Bytes[$position++]-ne6){throw 'SIGNATURE_FIELD'};Read-SignatureType $Reader $Bytes ([ref]$position) ($Depth+1)
    }
    elseif($Kind-ceq'Standalone'-and$Bytes[0]-eq7){
        $position++;$count=Read-SignatureNumber $Bytes ([ref]$position);if($count-gt4096){throw 'SIGNATURE_LOCALS'}
        for($k=0;$k-lt$count;$k++){Read-SignatureType $Reader $Bytes ([ref]$position) ($Depth+1)}
    }
    else{Read-MethodSignature $Reader $Bytes ([ref]$position) ($Depth+1)}
    if($position-ne$Bytes.Length){throw 'SIGNATURE_TRAILING'}
}
function Assert-MetadataAndIl($Reader,$Pe,[bool]$Production) {
    $script:metadataVisited=[Collections.Generic.HashSet[int]]::new()
    $script:metadataActive=[Collections.Generic.HashSet[int]]::new()
    $opcodeMap=@{}
    foreach($field in [Reflection.Emit.OpCodes].GetFields([Reflection.BindingFlags]'Public,Static')){
        $op=$field.GetValue($null);if($op.OpCodeType.ToString()-cne'Nternal'){$opcodeMap[([int]$op.Value-band65535)]=$op}
    }
    $tables=@(@(0,'ModuleDefinition'),@(1,'TypeReference'),@(2,'TypeDefinition'),@(4,'FieldDefinition'),@(6,'MethodDefinition'),@(10,'MemberReference'),@(17,'StandaloneSignature'),@(26,'ModuleReference'),@(27,'TypeSpecification'),@(35,'AssemblyReference'),@(43,'MethodSpecification'))
    foreach($pair in $tables){
        $count=[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetTableRowCount($Reader,[System.Reflection.Metadata.Ecma335.TableIndex]$pair[0])
        if($count-gt16384){throw 'METADATA_TABLE_CAP'}
        for($rid=1;$rid-le$count;$rid++){Assert-MetadataToken $Reader (([int]$pair[0]-shl24)-bor$rid) @($pair[1])}
    }
    $assemblyNames=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach($h in $Reader.AssemblyReferences){
        $a=$Reader.GetAssemblyReference($h);$name=$Reader.GetString($a.Name);$token=[BitConverter]::ToString($Reader.GetBlobBytes($a.PublicKeyOrToken)).Replace('-','')
        $expectedVersion=if($name-ceq'System.Net.Http'){'4.2.0.0'}else{'4.0.0.0'}
        $expectedToken=if($name-in@('System.Net.Http','System.ServiceProcess')){'B03F5F7F11D50A3A'}else{'B77A5C561934E089'}
        if(-not$assemblyNames.Add($name)-or$Reader.GetString($a.Culture)-cne''-or$a.Version.ToString()-cne$expectedVersion-or$token-cne$expectedToken-or$name-cnotin@('mscorlib','System','System.Net.Http','System.ServiceProcess')){throw 'ASSEMBLY_REFERENCE'}
        if($Production-and($name-cnotin@('mscorlib','System')-or$token-cne'B77A5C561934E089')){throw 'PRODUCTION_ASSEMBLY_REFERENCE'}
    }
    $strings=[Collections.Generic.List[string]]::new();$methods=0;$instructions=0;$calls=0
    $heapSize=[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetHeapSize($Reader,[System.Reflection.Metadata.Ecma335.HeapIndex]::UserString)
    if($heapSize-gt1048576){throw 'USER_STRING_HEAP_CAP'}
    if($heapSize-gt1){
        $stringHandle=[System.Reflection.Metadata.Ecma335.MetadataTokens]::UserStringHandle(1)
        while(-not$stringHandle.IsNil){
            $value=$Reader.GetUserString($stringHandle);if($value.Length-gt65536-or$strings.Count-ge16384){throw 'USER_STRING_CAP'};$strings.Add($value)
            $next=[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetNextHandle($Reader,$stringHandle)
            if(-not$next.IsNil-and[System.Reflection.Metadata.Ecma335.MetadataTokens]::GetHeapOffset($next)-le[System.Reflection.Metadata.Ecma335.MetadataTokens]::GetHeapOffset($stringHandle)){throw 'USER_STRING_PROGRESS'}
            $stringHandle=$next
        }
    }
    foreach($h in $Reader.MethodDefinitions){
        $method=$Reader.GetMethodDefinition($h)
        if($method.RelativeVirtualAddress-eq0){continue}
        $body=[System.Reflection.Metadata.PEReaderExtensions]::GetMethodBody($Pe,$method.RelativeVirtualAddress);$il=$body.GetILBytes()
        if($il.Length-lt1-or$il.Length-gt1048576){throw 'IL_SIZE'}
        if(-not$body.LocalSignature.IsNil){Assert-MetadataToken $Reader ([System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken([System.Reflection.Metadata.EntityHandle]$body.LocalSignature)) @('StandaloneSignature')}
        $position=0;$starts=[Collections.Generic.HashSet[int]]::new();$targets=[Collections.Generic.List[int]]::new()
        while($position-lt$il.Length){
            [void]$starts.Add($position);$code=[int]$il[$position++]
            if($code-eq254){if($position-ge$il.Length){throw 'IL_OPCODE_BOUNDS'};$code=0xFE00-bor$il[$position++]}
            if(-not$opcodeMap.ContainsKey($code)){throw 'IL_OPCODE'}
            $op=$opcodeMap[$code];$operand=$op.OperandType.ToString();$size=switch($operand){'InlineNone'{0};'ShortInlineI'{1};'ShortInlineVar'{1};'ShortInlineBrTarget'{1};'InlineVar'{2};'InlineI8'{8};'InlineR'{8};'InlineSwitch'{-1};{$_-in@('InlineI','ShortInlineR','InlineBrTarget','InlineField','InlineMethod','InlineSig','InlineString','InlineTok','InlineType')}{4};default{throw 'IL_OPERAND_KIND'}}
            if($size-eq-1){
                if($position+4-gt$il.Length){throw 'IL_SWITCH'};$count=[BitConverter]::ToInt32($il,$position);$position+=4
                if($count-lt0-or$count-gt16384-or$position+4*$count-gt$il.Length){throw 'IL_SWITCH'}
                $end=$position+4*$count
                for($k=0;$k-lt$count;$k++){$target=[long]$end+[BitConverter]::ToInt32($il,$position);if($target-lt0-or$target-ge$il.Length){throw 'IL_BRANCH'};$targets.Add([int]$target);$position+=4}
            }else{
                if($position+$size-gt$il.Length){throw 'IL_OPERAND_BOUNDS'}
                if($operand-in@('InlineMethod','InlineField','InlineType','InlineTok','InlineSig')){
                    $token=[BitConverter]::ToInt32($il,$position)
                    $allowed=switch($operand){'InlineMethod'{@('MethodDefinition','MemberReference','MethodSpecification')};'InlineField'{@('FieldDefinition','MemberReference')};'InlineType'{@('TypeDefinition','TypeReference','TypeSpecification')};'InlineSig'{@('StandaloneSignature')};default{@('TypeDefinition','TypeReference','TypeSpecification','MethodDefinition','MemberReference','FieldDefinition')}}
                    Assert-MetadataToken $Reader $token $allowed
                    if(($token-band0xFF000000)-eq0x0A000000-and$operand-in@('InlineMethod','InlineField')){
                        $member=$Reader.GetMemberReference([System.Reflection.Metadata.MemberReferenceHandle][System.Reflection.Metadata.Ecma335.MetadataTokens]::EntityHandle($token))
                        $expectedKind=if($operand-ceq'InlineField'){'Field'}else{'Method'};if($member.GetKind().ToString()-cne$expectedKind){throw 'IL_MEMBER_KIND'}
                    }
                    if($operand-ceq'InlineMethod'){$calls++}
                }elseif($operand-ceq'InlineString'){
                    $token=[BitConverter]::ToInt32($il,$position);if(($token-band0xFF000000)-ne0x70000000-or($token-band0x00FFFFFF)-eq0){throw 'IL_STRING_TOKEN'}
                    $value=$Reader.GetUserString([System.Reflection.Metadata.Ecma335.MetadataTokens]::UserStringHandle($token-band0x00FFFFFF))
                    if($value.Length-gt65536-or-not$strings.Contains($value)){throw 'USER_STRING_CAP_OR_UNENUMERATED_TOKEN'}
                }elseif($operand-in@('InlineBrTarget','ShortInlineBrTarget')){
                    $delta=if($size-eq1){if($il[$position]-ge128){[int]$il[$position]-256}else{[int]$il[$position]}}else{[BitConverter]::ToInt32($il,$position)}
                    $target=[long]$position+$size+$delta;if($target-lt0-or$target-ge$il.Length){throw 'IL_BRANCH'};$targets.Add([int]$target)
                }
                if($op.Name-ceq'calli'-and$Production){throw 'PRODUCTION_CALLI'}
                $position+=$size
            }
            $instructions++;if($instructions-gt1048576){throw 'IL_INSTRUCTION_CAP'}
        }
        foreach($target in $targets){if(-not$starts.Contains($target)){throw 'IL_BRANCH_BOUNDARY'}}
        foreach($region in $body.ExceptionRegions){
            foreach($range in @(@($region.TryOffset,$region.TryLength),@($region.HandlerOffset,$region.HandlerLength))){
                $end=[long]$range[0]+$range[1];if($range[1]-le0-or-not$starts.Contains($range[0])-or$end-gt$il.Length-or($end-ne$il.Length-and-not$starts.Contains([int]$end))){throw 'IL_EH_BOUNDS'}
            }
            if($region.Kind.ToString()-ceq'Catch'){Assert-MetadataToken $Reader ([System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($region.CatchType)) @('TypeDefinition','TypeReference','TypeSpecification')}
            elseif($region.Kind.ToString()-ceq'Filter'){if(-not$starts.Contains($region.FilterOffset)-or$region.FilterOffset-ge$region.HandlerOffset){throw 'IL_FILTER'}}
        }
        $methods++
    }
    [pscustomobject]@{Methods=$methods;Instructions=$instructions;Calls=$calls;UserStrings=$strings.ToArray();Assemblies=$assemblyNames.Count}
}
function Assert-MetadataNegativeControls([byte[]]$Original) {
    $stream=[IO.MemoryStream]::new($Original,$false);$pe=[System.Reflection.PortableExecutable.PEReader]::new($stream)
    try{
        $reader=[System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe);$start=-1;$length=0;$localToken=0
        foreach($h in $reader.MethodDefinitions){
            $method=$reader.GetMethodDefinition($h);if($method.RelativeVirtualAddress-eq0){continue}
            $body=[System.Reflection.Metadata.PEReaderExtensions]::GetMethodBody($pe,$method.RelativeVirtualAddress)
            if(-not$body.LocalSignature.IsNil){$localToken=[System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken([System.Reflection.Metadata.EntityHandle]$body.LocalSignature)}
            if($start-ge0-or$body.GetILBytes().Length-lt8){continue}
            foreach($section in $pe.PEHeaders.SectionHeaders){
                $relative=$method.RelativeVirtualAddress-$section.VirtualAddress
                if($relative-ge0-and$relative-lt$section.SizeOfRawData){
                    $offset=$section.PointerToRawData+$relative
                    $header=if(($Original[$offset]-band3)-eq2){1}elseif(($Original[$offset]-band3)-eq3){([BitConverter]::ToUInt16($Original,$offset)-shr12)*4}else{throw 'NEGATIVE_HEADER'}
                    $start=$offset+$header;$length=$body.GetILBytes().Length;break
                }
            }
        }
        $methodSpecOffset=$pe.PEHeaders.MetadataStartOffset+[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetTableMetadataOffset($reader,[System.Reflection.Metadata.Ecma335.TableIndex]::MethodSpec)
        $typeRefOffset=$pe.PEHeaders.MetadataStartOffset+[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetTableMetadataOffset($reader,[System.Reflection.Metadata.Ecma335.TableIndex]::TypeRef)
        if($start-lt0-or$localToken-eq0-or[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetTableRowCount($reader,[System.Reflection.Metadata.Ecma335.TableIndex]::MethodSpec)-lt1){throw 'NEGATIVE_ANCHOR'}
        $rows=@(
            @('IL_OPCODE',$start,[byte[]]@(255)),
            @('IL_OPERAND_BOUNDS',($start+$length-1),[byte[]]@(33)),
            @('METADATA_TOKEN',$start,[byte[]]@(40,255,255,255,6)),
            @('PRODUCTION_CALLI',$start,([byte[]]@(41)+[BitConverter]::GetBytes([int]$localToken))),
            @('IL_BRANCH',$start,[byte[]]@(56,255,255,255,127)),
            @('METADATA_TOKEN',$methodSpecOffset,[byte[]]@(255,255)),
            @('METADATA_CYCLE',$typeRefOffset,[byte[]]@(7,0))
        )
        $passed=0
        foreach($row in $rows){
            $copy=[byte[]]$Original.Clone();[Array]::Copy([byte[]]$row[2],0,$copy,[int]$row[1],$row[2].Length)
            $testStream=[IO.MemoryStream]::new($copy,$false);$testPe=$null;$rejected=$false
            try{$testPe=[System.Reflection.PortableExecutable.PEReader]::new($testStream);$testReader=[System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($testPe);[void](Assert-MetadataAndIl $testReader $testPe $true)}
            catch{if($_.Exception.Message-cne$row[0]){throw 'NEGATIVE_WRONG_REJECTION'};$rejected=$true}
            finally{if($testPe){$testPe.Dispose()};$testStream.Dispose();[Array]::Clear($copy,0,$copy.Length)}
            if(-not$rejected){throw 'NEGATIVE_ACCEPTED'};$passed++
        }
        if($passed-ne7){throw 'NEGATIVE_COUNT'}
    }finally{$pe.Dispose();$stream.Dispose()}
}
function Get-TypeDefName($Reader,$Handle,[int]$Depth=0) {
    if($Depth-gt32){throw 'TYPEDEF_DEPTH'}
    $d=$Reader.GetTypeDefinition($Handle);$name=$Reader.GetString($d.Name);$parent=$d.GetDeclaringType()
    if(-not$parent.IsNil){return (Get-TypeDefName $Reader $parent ($Depth+1))+'+'+$name}
    $ns=$Reader.GetString($d.Namespace);if($ns){return $ns+'.'+$name};$name
}
function Assert-NativeInventory($Reader) {
    $prefix='EAIRA.AgentServices.Packaging.'
    $expected=@(
        'OwnedFileHandle|CloseHandle|kernel32.dll|CloseHandle|321|8337|128|00010218|0:8192:02,1:0:',
        'NativePackageFileSystem|CreateFileW|kernel32.dll|CreateFileW|325|8337|128|000712100E090918090918|1:0:,2:0:,3:0:,4:0:,5:0:,6:0:,7:0:',
        'NativePackageFileSystem|GetFileInformationByHandleEx|kernel32.dll|GetFileInformationByHandleEx|321|8337|128|00040212100810113409|0:8192:02,1:0:,2:0:,3:2:,4:0:',
        'NativePackageFileSystem|GetFileIdInformation|kernel32.dll|GetFileInformationByHandleEx|321|8337|128|0004021210081809|0:8192:02,1:0:,2:0:,3:0:,4:0:',
        'NativePackageFileSystem|GetFileInformationByHandle|kernel32.dll|GetFileInformationByHandle|321|8337|128|000202121010113C|0:8192:02,1:0:,2:2:',
        'NativePackageFileSystem|GetFinalPathNameByHandleW|kernel32.dll|GetFinalPathNameByHandleW|325|8337|128|0004091210122D0909|1:0:,2:0:,3:0:,4:0:',
        'NativePackageFileSystem|ReadFile|kernel32.dll|ReadFile|321|8337|128|00050212101D0509100918|0:8192:02,1:0:,2:0:,3:0:,4:2:,5:0:',
        'NativePackageFileSystem|WriteFile|kernel32.dll|WriteFile|321|8337|128|00050212101D0509100918|0:8192:02,1:0:,2:0:,3:0:,4:2:,5:0:',
        'NativePackageFileSystem|FlushFileBuffers|kernel32.dll|FlushFileBuffers|321|8337|128|0001021210|0:8192:02,1:0:',
        'NativePackageFileSystem|SetFilePointerEx|kernel32.dll|SetFilePointerEx|321|8337|128|00040212100A100A09|0:8192:02,1:0:,2:0:,3:2:,4:0:',
        'NativePackageFileSystem|GetFileSizeEx|kernel32.dll|GetFileSizeEx|321|8337|128|0002021210100A|0:8192:02,1:0:,2:2:',
        'NativePackageFileSystem|NtCreateFile|ntdll.dll|NtCreateFile|257|8337|128|000B081012100910112C10113018090909091809|1:2:,2:0:,3:0:,4:2:,5:0:,6:0:,7:0:,8:0:,9:0:,10:0:,11:0:',
        'NativePackageFileSystem|NtQueryDirectoryFile|ntdll.dll|NtQueryDirectoryFile|257|8337|128|000B081210181818101130180908021802|1:0:,2:0:,3:0:,4:0:,5:2:,6:0:,7:0:,8:0:,9:8192:04,10:0:,11:8192:04',
        'NativePackageFileSystem|NtSetInformationFile|ntdll.dll|NtSetInformationFile|257|8337|128|0005081210101130180908|1:0:,2:2:,3:0:,4:0:,5:0:',
        'UnsignedCustomerPackage|GetFileInformationByHandleEx|kernel32.dll|GetFileInformationByHandleEx|321|8337|128|00040212100810114409|0:8192:02,1:0:,2:0:,3:2:,4:0:'
    )
    $rows=[Collections.Generic.List[string]]::new()
    foreach($h in $Reader.MethodDefinitions){
        $m=$Reader.GetMethodDefinition($h);if(($m.Attributes-band[Reflection.MethodAttributes]::PinvokeImpl)-eq0){continue}
        $import=$m.GetImport();$parameters=[Collections.Generic.List[string]]::new()
        foreach($ph in $m.GetParameters()){
            $p=$Reader.GetParameter($ph)
            $parameters.Add($p.SequenceNumber.ToString()+':'+[int]$p.Attributes+':'+[BitConverter]::ToString($Reader.GetBlobBytes($p.GetMarshallingDescriptor())).Replace('-',''))
        }
        $rows.Add((Get-TypeDefName $Reader $m.GetDeclaringType())+'|'+$Reader.GetString($m.Name)+'|'+$Reader.GetString($Reader.GetModuleReference($import.Module).Name)+'|'+$Reader.GetString($import.Name)+'|'+[int]$import.Attributes+'|'+[int]$m.Attributes+'|'+[int]$m.ImplAttributes+'|'+[BitConverter]::ToString($Reader.GetBlobBytes($m.Signature)).Replace('-','')+'|'+($parameters-join','))
    }
    if($rows.Count-ne15){throw 'NATIVE_METHOD_COUNT'}
    for($i=0;$i-lt15;$i++){if($rows[$i]-cne($prefix+$expected[$i])){throw 'NATIVE_METHOD_ROW'}}
    $bindings=@(
        @(16,($prefix+'OwnedFileHandle')),
        @(52,($prefix+'NativePackageFileSystem+AttributeTagInfo')),
        @(60,($prefix+'NativePackageFileSystem+ByHandleInfo')),
        @(45,'System.Text.StringBuilder'),
        @(44,($prefix+'NativePackageFileSystem+ObjectAttributes')),
        @(48,($prefix+'NativePackageFileSystem+IoStatusBlock')),
        @(68,($prefix+'UnsignedCustomerPackage+FileAttributeTagInfo'))
    )
    foreach($pair in $bindings){
        $tag=[int]$pair[0]-band3;$rid=[int]$pair[0]-shr2;$table=@(2,1,27)[$tag]
        $h=[System.Reflection.Metadata.Ecma335.MetadataTokens]::EntityHandle(($table-shl24)-bor$rid)
        $name=if($tag-eq0){Get-TypeDefName $Reader ([System.Reflection.Metadata.TypeDefinitionHandle]$h)}else{Get-TypeRefName $Reader ([System.Reflection.Metadata.TypeReferenceHandle]$h)}
        if($name-cne$pair[1]){throw 'NATIVE_SIGNATURE_TYPE_BINDING'}
    }
}
function Assert-NativeNegativeControls([byte[]]$Original) {
    $stream=[IO.MemoryStream]::new($Original,$false);$pe=[System.Reflection.PortableExecutable.PEReader]::new($stream)
    try{
        $reader=[System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
        $blobStart=$pe.PEHeaders.MetadataStartOffset+[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetHeapMetadataOffset($reader,[System.Reflection.Metadata.Ecma335.HeapIndex]::Blob)
        $importOffset=$pe.PEHeaders.MetadataStartOffset+[System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetTableMetadataOffset($reader,[System.Reflection.Metadata.Ecma335.TableIndex]::ImplMap)
        $signatureOffset=-1;$marshalOffset=-1
        foreach($h in $reader.MethodDefinitions){
            $m=$reader.GetMethodDefinition($h)
            if(($m.Attributes-band[Reflection.MethodAttributes]::PinvokeImpl)-eq0){continue}
            $signatureOffset=$blobStart+[System.Reflection.Metadata.Ecma335.MetadataTokens]::GetHeapOffset($m.Signature)
            foreach($ph in $m.GetParameters()){$p=$reader.GetParameter($ph);if($p.SequenceNumber-eq0){$marshalOffset=$blobStart+[System.Reflection.Metadata.Ecma335.MetadataTokens]::GetHeapOffset($p.GetMarshallingDescriptor());break}}
            break
        }
        if($signatureOffset-lt0-or$marshalOffset-lt0-or$Original[$signatureOffset]-ne4-or$Original[$marshalOffset]-ne1){throw 'NATIVE_NEGATIVE_ANCHOR'}
        $rows=@(@($importOffset,[byte]1),@(($signatureOffset+3),[byte]8),@(($marshalOffset+1),[byte]4))
        foreach($row in $rows){
            $copy=[byte[]]$Original.Clone();$copy[[int]$row[0]]=$row[1]
            $testStream=[IO.MemoryStream]::new($copy,$false);$testPe=$null;$rejected=$false
            try{$testPe=[System.Reflection.PortableExecutable.PEReader]::new($testStream);$testReader=[System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($testPe);Assert-NativeInventory $testReader}
            catch{if($_.Exception.Message-cne'NATIVE_METHOD_ROW'){throw 'NATIVE_NEGATIVE_WRONG_REJECTION'};$rejected=$true}
            finally{if($testPe){$testPe.Dispose()};$testStream.Dispose();[Array]::Clear($copy,0,$copy.Length)}
            if(-not$rejected){throw 'NATIVE_NEGATIVE_ACCEPTED'}
        }
    }finally{$pe.Dispose();$stream.Dispose()}
}
function Assert-MetadataRuntime([switch]$Initialize) {
    if([Environment]::ProcessPath-cne$pwsh){throw 'HOST_PROCESS_IMAGE'}
    if((Get-Item -LiteralPath $pwsh).VersionInfo.ProductVersion-cne'7.6.5 SHA: ea554a8f9c6085f54fb2828f7ea286c65c35599f+ea554a8f9c6085f54fb2828f7ea286c65c35599f'){throw 'HOST_PRODUCT_VERSION'}
    $hostHandle=Open-AbsoluteNative $pwsh $false $false 1
    try{
        $hostIdentity=Get-NativeIdentity $hostHandle $pwsh $false $false
        if((Get-ByteSha (Read-NativeBytes $hostHandle 301368))-cne'362A356CE7F0940EC74F73A8FC2C990A2CC24A38A11C90BBD8ECA947110AD139'){throw 'HOST_IMAGE_HASH'}
        if($Initialize){$script:metadataHostIdentity=$hostIdentity}elseif($hostIdentity-cne$script:metadataHostIdentity){throw 'HOST_IMAGE_IDENTITY'}
    }finally{Close-NativeHandle $hostHandle}
    foreach($dep in $metadataDependencies){
        $path=Join-Path $PSHOME $dep[0];$name=[IO.Path]::GetFileNameWithoutExtension($dep[0])
        $key=if($name-in@('System.Memory','System.Buffers')){'cc7b13ffcd2ddd51'}else{'b03f5f7f11d50a3a'}
        $expectedFullName=$name+', Version=10.0.0.0, Culture=neutral, PublicKeyToken='+$key
        $loaded=@([AppDomain]::CurrentDomain.GetAssemblies()|Where-Object {$_.GetName().Name-ceq$name})
        if($loaded.Count-eq0-and$Initialize){[void][Reflection.Assembly]::LoadFrom($path);$loaded=@([AppDomain]::CurrentDomain.GetAssemblies()|Where-Object {$_.GetName().Name-ceq$name})}
        if($loaded.Count-ne1-or$loaded[0].IsDynamic-or$loaded[0].Location-cne$path-or$loaded[0].FullName-cne$expectedFullName){throw 'METADATA_LOADED_IDENTITY'}
        $handle=Open-AbsoluteNative $loaded[0].Location $false $false 1
        try{
            $identity=Get-NativeIdentity $handle $path $false $false
            if((Get-ByteSha (Read-NativeBytes $handle ([int]$dep[1])))-cne$dep[2]-or(Get-Item -LiteralPath $path).VersionInfo.ProductVersion-cne'10.0.11+e2f47b0110ed922f21a1522da67279133ce28f32'){throw 'METADATA_LOADED_BYTES'}
            if($Initialize){$script:metadataLoadedIdentities.Add($name,$identity)}elseif($script:metadataLoadedIdentities[$name]-cne$identity){throw 'METADATA_LOADED_FILE_ID'}
        }finally{Close-NativeHandle $handle}
    }
}
function Assert-PackageToolPolicy([string]$Path) {
    $handle=Open-AbsoluteNative $Path $false $false 1
    $pe=$null;$stream=$null
    try {
        $bytes=Read-NativeBytes $handle 2097152;$stream=[IO.MemoryStream]::new([byte[]]$bytes,$false)
        $pe=[System.Reflection.PortableExecutable.PEReader]::new($stream)
        if(-not$pe.HasMetadata){throw 'TOOL_METADATA'}
        $reader=[System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
        $inspection=Assert-MetadataAndIl $reader $pe $true
        Assert-SignatureNumberControls
        Assert-NativeInventory $reader
        Assert-NativeNegativeControls $bytes
        Assert-MetadataNegativeControls $bytes
        if($inspection.Methods-lt1-or$inspection.Instructions-lt1){throw 'PRODUCTION_IL_EMPTY'}
        foreach($value in $inspection.UserStrings){
            foreach($forbidden in @('\\server\share','\\?\C:\device','\\?\Volume{00000000-0000-0000-0000-000000000000}\','C:\x:ads','C:\a\.\b','C:\a.','C:\a ','C:\PROGRA~1','UTF8_BOM','JSON_SPACE','lowercase_digest','duplicate_member','unknown_member','reordered_member')){
                if($value.Contains($forbidden)){throw 'PRODUCTION_FORBIDDEN_STRING'}
            }
        }
        foreach($h0 in $reader.TypeDefinitions){
            $d=$reader.GetTypeDefinition([System.Reflection.Metadata.TypeDefinitionHandle]$h0);$name=$reader.GetString($d.Name)
            if($name-match'PackageTest|PackageFaultRuntime|TestSeam|InjectedPackageFault|FakePackage'){throw 'PRODUCTION_TEST_TYPE'}
            $namespace=$reader.GetString($d.Namespace)
            if($namespace-match'^(System\.Net|System\.Security\.AccessControl|System\.IO\.Compression|EAIRA\.Forbidden\.PathMutation)(\.|$)'){throw 'PRODUCTION_FORBIDDEN_TYPEDEF'}
        }
        foreach($h0 in $reader.TypeReferences){
            $name=Get-TypeRefName $reader ([System.Reflection.Metadata.TypeReferenceHandle]$h0)
            if($name-match'^(System\.Net\.|System\.Reflection\.|System\.Diagnostics\.Process|System\.Security\.AccessControl\.|System\.Security\.Cryptography\.X509Certificates\.|System\.ServiceProcess\.|System\.IO\.(File$|Directory$|FileStream$|Compression\.)|Microsoft\.Win32\.Registry)'){throw 'PRODUCTION_FORBIDDEN_TYPE'}
        }
        foreach($h0 in $reader.MemberReferences){
            $m=$reader.GetMemberReference([System.Reflection.Metadata.MemberReferenceHandle]$h0)
            if($m.Parent.Kind-eq[System.Reflection.Metadata.HandleKind]::TypeReference){
                $parent=Get-TypeRefName $reader ([System.Reflection.Metadata.TypeReferenceHandle]$m.Parent);$name=$reader.GetString($m.Name)
                if($parent-ceq'System.Runtime.InteropServices.Marshal'-and$name-in@('GetDelegateForFunctionPointer','GetFunctionPointerForDelegate','BindToMoniker','GetActiveObject')){throw 'PRODUCTION_DYNAMIC_CAPABILITY'}
            }
        }
        $allowed=@('kernel32.dll|CloseHandle','kernel32.dll|CreateFileW','kernel32.dll|GetFileInformationByHandleEx','kernel32.dll|GetFileInformationByHandle','kernel32.dll|GetFinalPathNameByHandleW','kernel32.dll|ReadFile','kernel32.dll|WriteFile','kernel32.dll|FlushFileBuffers','kernel32.dll|SetFilePointerEx','kernel32.dll|GetFileSizeEx','ntdll.dll|NtCreateFile','ntdll.dll|NtQueryDirectoryFile','ntdll.dll|NtSetInformationFile')
        $observed=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach($h0 in $reader.MethodDefinitions){
            $method=$reader.GetMethodDefinition([System.Reflection.Metadata.MethodDefinitionHandle]$h0)
            if(($method.Attributes-band[Reflection.MethodAttributes]::PinvokeImpl)-ne0){
                $import=$method.GetImport();$library=$reader.GetString($reader.GetModuleReference($import.Module).Name);$name=$reader.GetString($import.Name)
                $key=$library+'|'+$name;if($key-cnotin$allowed){throw 'PRODUCTION_PINVOKE_ALLOWLIST'};[void]$observed.Add($key)
                if(([int]$import.Attributes-band1)-ne1){throw 'PRODUCTION_PINVOKE_EXACT_SPELLING'}
            }
        }
        if($observed.Count-ne$allowed.Count){throw 'PRODUCTION_PINVOKE_INVENTORY'}
    }finally{if($pe){$pe.Dispose()};if($stream){$stream.Dispose()};Close-NativeHandle $handle}
}
function Get-SpecimenRule([string]$Path) {
    $stream=[IO.File]::Open($Path,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
    $pe=$null
    try {
        $pe=[System.Reflection.PortableExecutable.PEReader]::new($stream)
        if(-not$pe.HasMetadata){throw 'SPECIMEN_NO_METADATA'};$reader=[System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
        $inspection=Assert-MetadataAndIl $reader $pe $false
        $typeRefs=@();foreach($h0 in $reader.TypeReferences){$typeRefs+=(Get-TypeRefName $reader ([System.Reflection.Metadata.TypeReferenceHandle]$h0))}
        $typeDefs=@();foreach($h0 in $reader.TypeDefinitions){$d=$reader.GetTypeDefinition([System.Reflection.Metadata.TypeDefinitionHandle]$h0);$n=$reader.GetString($d.Name);$ns=$reader.GetString($d.Namespace);$typeDefs+=($(if($ns){$ns+'.'+$n}else{$n}))}
        $members=@();foreach($h0 in $reader.MemberReferences){$h=[System.Reflection.Metadata.MemberReferenceHandle]$h0;$m=$reader.GetMemberReference($h);$parent='UNKNOWN';if($m.Parent.Kind-eq[System.Reflection.Metadata.HandleKind]::TypeReference){$parent=Get-TypeRefName $reader ([System.Reflection.Metadata.TypeReferenceHandle]$m.Parent)};$members+=($parent+'::'+$reader.GetString($m.Name))}
        $pinvokes=@();foreach($h0 in $reader.MethodDefinitions){$m=$reader.GetMethodDefinition([System.Reflection.Metadata.MethodDefinitionHandle]$h0);if(($m.Attributes-band[Reflection.MethodAttributes]::PinvokeImpl)-ne0){$import=$m.GetImport();$pinvokes+=$reader.GetString($import.Name)}}
        $bytes=[IO.File]::ReadAllBytes($Path);$ascii=[Text.Encoding]::ASCII.GetString($bytes);$unicode=[Text.Encoding]::Unicode.GetString($bytes)
        $hits=@()
        if($pinvokes -contains 'LoadLibraryW'){$hits+='PAYLOAD_NATIVE_LOADLIBRARY'}
        if($pinvokes -contains 'ShellExecuteW'){$hits+='PAYLOAD_SHELLEXECUTE'}
        if($members -contains 'System.Diagnostics.Process::Start'){$hits+='PAYLOAD_PROCESS_START'}
        if($members -contains 'System.Reflection.Assembly::Load'){$hits+='PAYLOAD_ASSEMBLY_LOAD'}
        if($members -contains 'System.Reflection.MethodBase::Invoke' -or $members -contains 'System.Reflection.MethodInfo::Invoke'){$hits+='PAYLOAD_REFLECTION_INVOKE'}
        if($members -contains 'System.Runtime.InteropServices.Marshal::GetDelegateForFunctionPointer'){$hits+='PAYLOAD_DELEGATE_FUNCTION_POINTER'}
        if($hits.Count-eq0){
            if($members -contains 'System.IO.File::Create'){$hits+='UNSAFE_FILE_CREATE'}
            elseif($members -contains 'System.IO.File::Move'){$hits+='UNSAFE_FILE_MOVE'}
            elseif($members -contains 'System.IO.File::Delete'){$hits+='UNSAFE_FILE_DELETE'}
            elseif($members -contains 'System.IO.Directory::Delete'){$hits+='UNSAFE_DIRECTORY_DELETE_RECURSIVE'}
        }
        if($hits.Count-eq0){
            if($typeRefs -contains 'System.Net.Http.HttpClient'){$hits+='FORBIDDEN_HTTPCLIENT'}
            elseif($typeRefs -contains 'System.Diagnostics.Process'){$hits+='FORBIDDEN_PROCESS'}
            elseif($typeRefs -contains 'Microsoft.Win32.Registry'){$hits+='FORBIDDEN_REGISTRY'}
            elseif($typeRefs -contains 'System.ServiceProcess.ServiceController'){$hits+='FORBIDDEN_SERVICE_CONTROLLER'}
            elseif($typeRefs -contains 'System.Security.Cryptography.X509Certificates.X509Certificate2'){$hits+='FORBIDDEN_X509_SIGNING'}
            elseif($typeDefs|Where-Object{$_ -like 'System.Net.*'}){$hits+='FORBIDDEN_SYSTEM_NET'}
            elseif($typeDefs|Where-Object{$_ -like 'System.Security.AccessControl.*'}){$hits+='FORBIDDEN_ACCESS_CONTROL'}
            elseif($typeDefs|Where-Object{$_ -like 'System.IO.Compression.*'}){$hits+='FORBIDDEN_ZIP_INSTALLER'}
            elseif($typeDefs -contains 'EAIRA.Forbidden.PathMutation.CreateCheckThenUse'){$hits+='PATH_CREATE_CHECK_THEN_USE'}
            elseif($typeDefs -contains 'EAIRA.Forbidden.PathMutation.OpenCheckThenUse'){$hits+='PATH_OPEN_CHECK_THEN_USE'}
            elseif($typeDefs -contains 'EAIRA.Forbidden.PathMutation.RenameCheckThenUse'){$hits+='PATH_RENAME_CHECK_THEN_USE'}
            elseif($typeDefs -contains 'EAIRA.Forbidden.PathMutation.DeleteCheckThenUse'){$hits+='PATH_DELETE_CHECK_THEN_USE'}
        }
        if($hits.Count-eq0){
            $combined=$ascii+"`n"+$unicode+"`n"+($inspection.UserStrings-join"`n")
            if($combined.Contains('\\server\share')){$hits+='NAMESPACE_UNC_LITERAL'}
            elseif($combined.Contains('\\?\C:\device')){$hits+='NAMESPACE_DEVICE_LITERAL'}
            elseif($combined.Contains('\\?\Volume{00000000-0000-0000-0000-000000000000}\')){$hits+='NAMESPACE_VOLUME_GUID_LITERAL'}
            elseif($combined.Contains('C:\x:ads')){$hits+='NAMESPACE_ADS_LITERAL'}
            elseif($combined.Contains('C:\a\.\b')){$hits+='NAMESPACE_DOT_SEGMENT_LITERAL'}
            elseif($combined.Contains('C:\a.')){$hits+='NAMESPACE_TRAILING_DOT_LITERAL'}
            elseif($combined.Contains('C:\a ')){$hits+='NAMESPACE_TRAILING_SPACE_LITERAL'}
            elseif($combined.Contains('C:\PROGRA~1')){$hits+='NAMESPACE_SHORT_NAME_LITERAL'}
            elseif($combined.Contains('UTF8_BOM')){$hits+='JSON_BOM_WRITER'}
            elseif($combined.Contains('JSON_SPACE')){$hits+='JSON_NONCANONICAL_WHITESPACE'}
            elseif($combined.Contains('lowercase_digest')){$hits+='JSON_LOWERCASE_DIGEST'}
            elseif($combined.Contains('duplicate_member')){$hits+='JSON_DUPLICATE_MEMBER'}
            elseif($combined.Contains('unknown_member')){$hits+='JSON_UNKNOWN_MEMBER'}
            elseif($combined.Contains('reordered_member')){$hits+='JSON_REORDERED_MEMBER'}
        }
        if($hits.Count-ne1){throw 'SPECIMEN_CLASSIFICATION_COUNT'};$hits[0]
    } finally {if($pe){$pe.Dispose()};$stream.Dispose()}
}

try {
Assert-Root $WorkEvidenceRoot '^EAIRA_M5S5_WORK_[A-Z0-9]{12}$' $false
Assert-Root $PackageEvidenceRootA '^EAIRA_M5S5_PACKAGE_A_[A-Z0-9]{12}$' ($Mode -eq 'Verify')
Assert-Root $PackageEvidenceRootB '^EAIRA_M5S5_PACKAGE_B_[A-Z0-9]{12}$' ($Mode -eq 'Verify')
if($WorkEvidenceRoot -ieq $PackageEvidenceRootA -or $WorkEvidenceRoot -ieq $PackageEvidenceRootB -or $PackageEvidenceRootA -ieq $PackageEvidenceRootB){throw 'ROOT_ALIAS'}
Assert-File $RoslynCscPath 60200 '2DC1461B1A6E95BE9C1BECEB4B263141B7BB90E704029344A0C2D1A5693D9007'
$cscItem=Get-Item -LiteralPath $RoslynCscPath
if($cscItem.VersionInfo.ProductVersion -cne '4.14.0-3.25262.10+8edf7bcd4f1594c3d68a6a567469f41dbd33dd1b'){throw 'COMPILER_VERSION'}
$cscSig=Get-AuthenticodeSignature -LiteralPath $RoslynCscPath
if($cscSig.Status -ne 'Valid' -or $cscSig.SignerCertificate.Thumbprint -cne 'A3FF353E77E624540BEEB83335690535BE8DF56B'){throw 'COMPILER_SIGNATURE'}
$referenceRoot='C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8'
$mscorlib=Join-Path $referenceRoot 'mscorlib.dll';$system=Join-Path $referenceRoot 'System.dll'
$systemHttp=Join-Path $referenceRoot 'System.Net.Http.dll';$systemService=Join-Path $referenceRoot 'System.ServiceProcess.dll'
Assert-File $mscorlib 2731056 '6B35530467B914B0B195146CA1D1485DDD219AFAAD6461103F16F54E952F75A9'
Assert-File $system 1477168 '2FE343569F794F2CA92EE14A41875571A9F21BF92637B8F8EE86306534209CCA'
Assert-File $systemHttp 86576 'F5737983CF08DDCCA1F09F93409DC7B85D233643A6AA3A5C550C51EF733E2670'
Assert-File $systemService 59952 '21B013050B46016F8E6D9E92A2986E32E3CFB19487DCE05D672D4A3AB7EDF00C'
Assert-File $profilePath 1594 $profileSha $true
$pwsh=Join-Path $PSHOME 'pwsh.exe';Assert-File $pwsh 301368 '362A356CE7F0940EC74F73A8FC2C990A2CC24A38A11C90BBD8ECA947110AD139'
$pwshSignature=Get-AuthenticodeSignature -LiteralPath $pwsh;if($pwshSignature.Status-ne'Valid'-or$pwshSignature.SignerCertificate.Thumbprint-cne'AB172913A2960A224809EE8A0C371CD47A079B72'){throw 'PWSH_SIGNATURE'}
$metadataDependencies=@(@('System.Reflection.Metadata.dll',1156904,'97152D5C07E1E5D7F080F871EFF211CCDBECB2496E4EB1B086005CBD3656D431'),@('System.Collections.Immutable.dll',976680,'623AD5FA5AC38C460DF0073F37FBB649E219AC486C926B822F77EBF02676D56C'),@('System.Memory.dll',161576,'58A4DC8A9EFAC1FE0EE67138B0DDA35B2B812ADDC14C5D8251CC222B278A5C2D'),@('System.Buffers.dll',15144,'7EFC8DFEF9548771EC328610DE7B8E5C4308A8EA6B1CA73021F336FC00653176'),@('System.Runtime.CompilerServices.Unsafe.dll',15144,'6F396205ABE594C9C72E618F4278657B4FF9DA9CD2BC17D8083481B287838ECC'))
foreach($dep in $metadataDependencies){Assert-File (Join-Path $PSHOME $dep[0]) ([long]$dep[1]) $dep[2]}
$script:metadataLoadedIdentities=[Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)
Assert-MetadataRuntime -Initialize
Assert-MetadataRuntime
$sourceAnchor=Open-AbsoluteNative $sourceRoot $true $false 3;$script:pinnedInputHandles.Add($sourceAnchor)
$sourceNames=@(Get-NativeNames $sourceAnchor)
$expectedNames=@($payloads|ForEach-Object File);[Array]::Sort($expectedNames,[StringComparer]::Ordinal)
if(($sourceNames -join '|') -cne ($expectedNames -join '|')){throw 'SOURCE_INVENTORY'}
foreach($row in $payloads){Assert-File (Join-Path $sourceRoot $row.File) $row.Bytes $row.Sha}

$tempAnchor=Open-AbsoluteNative 'C:\Temp' $true $false 3;[void](Register-WorkHandle $tempAnchor);$script:workDirectoryHandles.Add('C:\Temp',$tempAnchor)
[void](New-WorkDirectory 'C:\Temp' (Split-Path -Leaf $WorkEvidenceRoot))
$snapshot=Join-Path $WorkEvidenceRoot 'snapshot';$buildA=Join-Path $WorkEvidenceRoot 'build-a';$buildB=Join-Path $WorkEvidenceRoot 'build-b';$specimenRoot=Join-Path $WorkEvidenceRoot 'specimens';$tempRoot=Join-Path $WorkEvidenceRoot 'temp'
foreach($leaf in @('snapshot','build-a','build-b','specimens','temp')){[void](New-WorkDirectory $WorkEvidenceRoot $leaf)}
$snapshotApps=Join-Path $snapshot 'apps';$snapshotAgent=Join-Path $snapshotApps 'agent-services';$snapshotDocs=Join-Path $snapshot 'docs';$snapshotProject=Join-Path $snapshotDocs 'project'
$directoryRows=@(
 @($snapshot,'apps'),@($snapshotApps,'agent-services'),@($snapshotAgent,'build'),@($snapshotAgent,'contracts'),@($snapshotAgent,'release'),@($snapshotAgent,'src'),@($snapshotAgent,'tests'),
 @($snapshot,'docs'),@($snapshotDocs,'project'),@($snapshotProject,'planning'),@($snapshotProject,'strategy')
)
foreach($row in $directoryRows){[void](New-WorkDirectory $row[0] $row[1])}
$sourceHashes=@();$sourceHashRows=@();$snapshotBytes=[Collections.Generic.Dictionary[string,byte[]]]::new([StringComparer]::Ordinal)
$heldRepositoryInputs=[Collections.Generic.List[object]]::new()
foreach($rel in $manifest){
    $source=Join-Path $repoRoot $rel;$sourceHandle=Open-AbsoluteNative $source $false $true 1;$script:pinnedInputHandles.Add($sourceHandle);$bytes=Read-NativeBytes $sourceHandle 2097152;$sha=Get-ByteSha $bytes
    $dest=Join-Path $snapshot $rel;[void](New-WorkFile $dest $bytes);$snapshotBytes.Add($rel,$bytes)
    $sourceHashes+=[pscustomobject]@{path=$rel;bytes=$bytes.Length;sha256=$sha};$sourceHashRows+=($rel+'|'+$bytes.Length+'|'+$sha)
    $heldRepositoryInputs.Add([pscustomobject]@{handle=$sourceHandle;path=$source;bytes=$bytes.Length;sha256=$sha;identity=(Get-NativeIdentity $sourceHandle $source $false $true)})
}
$repositoryInputsSha=Get-TextSha (($sourceHashRows-join"`n")+"`n")
if($EvidencePhase-eq'SEALED_FINAL'){if($ExpectedRepositoryInputsSha256-cnotmatch'^[A-F0-9]{64}$'-or$ExpectedRepositoryInputsSha256-cne$repositoryInputsSha){throw 'SEALED_INPUT_BINDING'}}elseif($ExpectedRepositoryInputsSha256-cne'NONE'){throw 'DISCOVERY_INPUT_BINDING'}
$toolSource=Join-Path $snapshot 'apps/agent-services/src/UnsignedCustomerPackageReadiness.cs';$harnessSource=Join-Path $snapshot 'apps/agent-services/tests/UnsignedCustomerPackageHarness.cs'
$toolA=Join-Path $buildA 'EAIRA.UnsignedCustomerPackage.Readiness.exe';$toolB=Join-Path $buildB 'EAIRA.UnsignedCustomerPackage.Readiness.exe'
$harnessA=Join-Path $buildA 'EAIRA.UnsignedCustomerPackage.Harness.exe';$harnessB=Join-Path $buildB 'EAIRA.UnsignedCustomerPackage.Harness.exe'
$script:childCount=0
$script:descendantCount=0
$script:childRows=[Collections.Generic.List[string]]::new()
Invoke-Compile $toolA 'EAIRA.AgentServices.Packaging.UnsignedCustomerPackageProgram' @($toolSource) -ExtraReferences @()
Invoke-Compile $toolB 'EAIRA.AgentServices.Packaging.UnsignedCustomerPackageProgram' @($toolSource) -ExtraReferences @()
Invoke-Compile $harnessA 'EAIRA.AgentServices.Packaging.UnsignedCustomerPackageHarness' @($toolSource,$harnessSource) -Harness -ExtraReferences @()
Invoke-Compile $harnessB 'EAIRA.AgentServices.Packaging.UnsignedCustomerPackageHarness' @($toolSource,$harnessSource) -Harness -ExtraReferences @()
if((Get-Sha $toolA) -cne (Get-Sha $toolB) -or (Get-Sha $harnessA) -cne (Get-Sha $harnessB)){throw 'AB_BINARY_MISMATCH'}
Assert-PackageToolPolicy $toolA
Assert-PackageToolPolicy $toolB
$suite='{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_HARNESS_V1","status":"PASS","tests":64,"caseNamesSha256":"'+$caseNamesSha+'","network":"NONE"}'
Invoke-Exact $harnessA @('Suite') $suite;Invoke-Exact $harnessB @('Suite') $suite
$argv='{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_ARGV_ECHO_V1","status":"PASS","count":5,"sha256":"'+$argvGoldenSha+'"}'
Invoke-Exact $harnessA @('ArgvEcho','','a b','C:\x\','a"b','a\"b') $argv

$designText=[Text.Encoding]::UTF8.GetString($snapshotBytes['docs/project/planning/EAIRA_M5_SLICE5_EXACT_IMPLEMENTATION_DESIGN.md'])
$matches=[regex]::Matches($designText,'(?m)^(?<name>[A-Z0-9_]+)\|(?<bytes>[0-9]+)\|(?<sha>[A-F0-9]{64})\|(?<b64>[A-Za-z0-9+/=]+)$')
if($matches.Count -ne 36){throw 'SPECIMEN_COUNT'}
$specimenNames=@();$specimenSourceTotal=0;$script:specimenVerified=0
foreach($m in $matches){
 $name=$m.Groups['name'].Value;$specimenNames+=$name;$bytes=[Convert]::FromBase64String($m.Groups['b64'].Value);$specimenSourceTotal+=$bytes.Length
 if($bytes.Length -ne [int]$m.Groups['bytes'].Value){throw 'SPECIMEN_BYTES'}
 $sourceFile=Join-Path $specimenRoot (($specimenNames.Count).ToString('D2')+'-'+$name+'.cs');[void](New-WorkFile $sourceFile $bytes)
 if((Get-Sha $sourceFile) -cne $m.Groups['sha'].Value){throw 'SPECIMEN_SHA'}
 $refs=@();if($name -eq 'FORBIDDEN_HTTPCLIENT'){$refs=@($systemHttp)}elseif($name -eq 'FORBIDDEN_SERVICE_CONTROLLER'){$refs=@($systemService)}
 Invoke-Compile (Join-Path $specimenRoot (($specimenNames.Count).ToString('D2')+'-'+$name+'.exe')) 'EAIRA.PackageSpecimen.Program' @($sourceFile) -ExtraReferences $refs
 $rule=Get-SpecimenRule (Join-Path $specimenRoot (($specimenNames.Count).ToString('D2')+'-'+$name+'.exe'));if($rule-cne$name){throw 'SPECIMEN_RULE'};$script:specimenVerified++
}
if($specimenSourceTotal -ne 5596-or$script:specimenVerified-ne36){throw 'SPECIMEN_TOTAL'}

$toolExpected='{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1","status":"PASS","mode":"'+$Mode+'","classification":"UNSIGNED_READINESS_ONLY_NOT_INSTALLABLE","releaseVersion":"5.5.0-readiness.1","payloadCount":9,"packageContentSha256":"'+$contentSha+'","network":"NONE","writes":"'+$(if($Mode -eq 'Build'){'OUTPUT_ROOT_ONLY'}else{'NONE'})+'","cleanup":"NOT_REQUIRED","persistentOutput":"PACKAGE","signing":"NONE","installation":"NONE","authority":"PACKAGE_NOT_RELEASE_AUTHORITY"}'
Invoke-Exact $toolA @($Mode,'--package-evidence-root',$PackageEvidenceRootA) $toolExpected
Invoke-Exact $toolB @($Mode,'--package-evidence-root',$PackageEvidenceRootB) $toolExpected
if($script:childCount -ne 45){throw 'CHILD_COUNT'}
Assert-MetadataRuntime
foreach($inputRecord in $heldRepositoryInputs){
    if((Get-NativeIdentity $inputRecord.handle $inputRecord.path $false $true)-cne$inputRecord.identity-or(Get-ByteSha (Read-NativeBytes $inputRecord.handle $inputRecord.bytes))-cne$inputRecord.sha256){throw 'HELD_INPUT_POSTCHECK'}
}
if($script:workTreeChecks-ne90){throw 'WORK_TREE_CHECK_COUNT'}
foreach($childRow in $script:childRows){
    if($childRow-cnotmatch'^[A-Za-z0-9._-]+\|[A-F0-9]{64}\|[A-F0-9]{64}\|[0-9]+\|[0-9]+\|[A-F0-9]{64}\|[0-9]+\|[A-F0-9]{64}\|2\|0\|0$'){throw 'CHILD_EVIDENCE_SCHEMA'}
}
$childEvidenceSha=Get-TextSha (($script:childRows-join"`n")+"`n");if($script:childRows.Count-ne45){throw 'CHILD_EVIDENCE_COUNT'}
$treeA=Get-TreeSha (Join-Path $PackageEvidenceRootA 'package');$treeB=Get-TreeSha (Join-Path $PackageEvidenceRootB 'package');if($treeA -cne $treeB){throw 'PACKAGE_AB_MISMATCH'}
$packageRootA=Get-ObjectIdentitySha $PackageEvidenceRootA $true;$packageRootB=Get-ObjectIdentitySha $PackageEvidenceRootB $true
$packageA=Get-ObjectIdentitySha (Join-Path $PackageEvidenceRootA 'package') $true;$packageB=Get-ObjectIdentitySha (Join-Path $PackageEvidenceRootB 'package') $true;$workIdentity=Get-ObjectIdentitySha $WorkEvidenceRoot $true
$summary='{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_WRAPPER_EVIDENCE_V1","status":"PASS","phase":"'+$EvidencePhase+'","finalEvidence":'+$(if($EvidencePhase-eq'SEALED_FINAL'){'true'}else{'false'})+',"profileSha256":"'+$profileSha+'","sourceManifestSha256":"'+$sourceManifestSha+'","repositoryInputCount":9,"repositoryInputsSha256":"'+$repositoryInputsSha+'","compilerSha256":"'+(Get-Sha $RoslynCscPath)+'","mscorlibSha256":"'+(Get-Sha $mscorlib)+'","systemSha256":"'+(Get-Sha $system)+'","toolSha256":"'+(Get-Sha $toolA)+'","harnessSha256":"'+(Get-Sha $harnessA)+'","workRootIdentitySha256":"'+$workIdentity+'","wrapperWrites":"WORK_EVIDENCE_ROOT_ONLY","workPersistentOutput":"EVIDENCE","toolWritesA":"'+$(if($Mode -eq 'Build'){'OUTPUT_ROOT_ONLY'}else{'NONE'})+'","toolWritesB":"'+$(if($Mode -eq 'Build'){'OUTPUT_ROOT_ONLY'}else{'NONE'})+'","packageRootIdentitySha256A":"'+$packageRootA+'","packageRootIdentitySha256B":"'+$packageRootB+'","packageIdentitySha256A":"'+$packageA+'","packageIdentitySha256B":"'+$packageB+'","directChildCount":'+$script:childCount+',"descendantCount":'+$script:descendantCount+',"childEvidenceCount":'+$script:childRows.Count+',"childEvidenceSha256":"'+$childEvidenceSha+'","workTreeCheckCount":90,"heldInputPostcheckCount":9,"faultBackend":"PRODUCTION_FLOW_IN_MEMORY_IO","caseCount":64,"caseNamesSha256":"'+$caseNamesSha+'","specimenCount":'+$script:specimenVerified+',"specimenNamesSha256":"'+$specimenNamesSha+'","specimenSourcesSha256":"'+$specimenSourcesSha+'","faultSubcaseCount":76,"faultProjectionCount":380,"argvGoldenCount":5,"argvGoldenSha256":"'+$argvGoldenSha+'","argvEchoPass":true,"faultProjectionMaskSha256":"'+$faultProjectionSha+'","packageTreeSha256A":"'+$treeA+'","packageTreeSha256B":"'+$treeB+'","abEqual":true,"network":"NONE","signing":"NONE","installation":"NONE","authority":"PACKAGE_NOT_RELEASE_AUTHORITY"}'
$summaryPath=Join-Path $WorkEvidenceRoot ('EAIRA_M5S5_'+$Mode.ToUpperInvariant()+'_SUMMARY.json')
[void](New-WorkFile $summaryPath ([Text.UTF8Encoding]::new($false).GetBytes($summary+"`n")))
$summary
} finally { Close-AllNativeHandles }
