# EAIRA M5 Slice 5A Exact Implementation Design

## 1. Control

| Field | Value |
| --- | --- |
| Design ID | `EAIRA_M5_SLICE5_A_EXACT_IMPLEMENTATION_DESIGN_V14` |
| Date | `2026-09-15` |
| Baseline | `e57307269e012afd9d01c45102c01e7eda2f2501` |
| Scope | `M5S5_A_BOUNDED_UNSIGNED_CUSTOMER_PACKAGE_READINESS` |
| Scope review | `R2R1 CLOSEABLE; P0=0; P1=0; P2=0` |
| State | `GATE8_R4_REMEDIATION_REVIEW_PENDING` |
| Implementation authority | `CONSUMED_FROM_PROJECT_OWNER_FULL_LIFECYCLE_AUTHORIZATION` |
| Recording authority | `GRANTED_BY_PROJECT_OWNER_FULL_LIFECYCLE_AUTHORIZATION_PENDING_GATE_SEQUENCE` |
| Next Gate | `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE5_A_GATE8_R4_IMPLEMENTATION_REMEDIATION_REVIEW` |

## 2. Exact nine-path manifest

Only these paths may change: `apps/agent-services/README.md`,
`apps/agent-services/build/Invoke-UnsignedCustomerPackageReadiness.ps1`,
`apps/agent-services/contracts/EAIRA_UNSIGNED_CUSTOMER_PACKAGE_V1.md`,
`apps/agent-services/release/unsigned-customer-package-profile.json`,
`apps/agent-services/src/UnsignedCustomerPackageReadiness.cs`,
`apps/agent-services/tests/UnsignedCustomerPackageHarness.cs`, this design,
`docs/project/planning/EAIRA_M5_SLICE5_BOUNDED_UNSIGNED_CUSTOMER_PACKAGE_READINESS_PACKAGE.md`,
and `docs/project/strategy/EAIRA_M5_SLICE5_SCOPE_DECISION.md`.

The existing runtime source/harness and Gate25 verifier/profile are immutable. The
excluded integration, Claude, root-test and Obsidian scopes remain unread/unchanged.

## 3. Wrapper, compiler and child-process contract

The wrapper accepts exactly `-RoslynCscPath`, `-WorkEvidenceRoot`,
`-PackageEvidenceRootA`, `-PackageEvidenceRootB`, `-Mode Build|Verify`,
`-EvidencePhase DISCOVERY|SEALED_FINAL`, and `-ExpectedRepositoryInputsSha256`.
Discovery requires the expected aggregate to be `NONE`; sealed final requires the
independently accepted exact-nine aggregate. Source root
is the constant `C:\Temp\EAIRA_M5S4_SEALED_FINAL_003\unsigned-release`; profile path
is resolved from `$PSScriptRoot`; neither is caller-overridable. Work root must be a
new direct child of `C:\Temp` with leaf `EAIRA_M5S5_WORK_[A-Z0-9]{12}`. Package roots
are distinct direct children with leaves `EAIRA_M5S5_PACKAGE_A_[A-Z0-9]{12}` and
`EAIRA_M5S5_PACKAGE_B_[A-Z0-9]{12}`. Build requires both package roots not to exist;
Verify requires both to exist with exact child `package`. Root existence and identity
are checked through a native directory handle, not `Test-Path`. All roots must be
pairwise non-aliasing, on the same volume, and neither equal nor contain another.

The supplied compiler must match the sealed baseline: `csc.exe`, 60,200 bytes,
SHA-256 `2DC1461B1A6E95BE9C1BECEB4B263141B7BB90E704029344A0C2D1A5693D9007`,
product version `4.14.0-3.25262.10+8edf7bcd4f1594c3d68a6a567469f41dbd33dd1b`,
valid Microsoft `.NET` Authenticode signature and thumbprint
`A3FF353E77E624540BEEB83335690535BE8DF56B`. Reference root is the constant
`C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8`.
Production and harness allow only `mscorlib.dll` (2,731,056 bytes, SHA-256
`6B35530467B914B0B195146CA1D1485DDD219AFAAD6461103F16F54E952F75A9`) and
`System.dll` (1,477,168 bytes, SHA-256
`2FE343569F794F2CA92EE14A41875571A9F21BF92637B8F8EE86306534209CCA`). Specimens
allow those two plus, only for their named row, `System.Net.Http.dll` (86,576 bytes,
SHA-256 `F5737983CF08DDCCA1F09F93409DC7B85D233643A6AA3A5C550C51EF733E2670`) or
`System.ServiceProcess.dll` (59,952 bytes, SHA-256
`21B013050B46016F8E6D9E92A2986E32E3CFB19487DCE05D672D4A3AB7EDF00C`). Compiler
and references are final-handle/reparse/identity verified and held without
write/delete share across all use; no environment or registry resolution occurs.

Every `.cs` snapshot and specimen is UTF-8 without BOM, LF-only, with one terminal
LF. Compiler argv begins as an element array and is serialized once to the required
mutable UTF-16 `CreateProcessW.lpCommandLine`. Common elements, in
exact order, are `/nologo`, `/noconfig`, `/nostdlib+`, `/deterministic+`,
`/platform:x64`, `/target:exe`, `/optimize+`, `/debug-`, `/checked+`,
`/highentropyva+`, `/warn:4`, `/warnaserror+`, `/codepage:65001`, then two exact
absolute `/reference:` elements, exact `/pathmap:<snapshot>=/_/EAIRA/apps/agent-services`,
one `/main:`, one `/out:` and one or two ordinal absolute source paths. Tool A uses
`/out:<work>\build-a\EAIRA.UnsignedCustomerPackage.Readiness.exe`; Tool B replaces
`build-a` with `build-b`. Both use main
`EAIRA.AgentServices.Packaging.UnsignedCustomerPackageProgram` and source
`<snapshot>\src\UnsignedCustomerPackageReadiness.cs`. Harness A/B add
`/define:EAIRA_PACKAGE_TEST_SEAMS`, use main
`EAIRA.AgentServices.Packaging.UnsignedCustomerPackageHarness`, corresponding
`build-a|build-b\EAIRA.UnsignedCustomerPackage.Harness.exe`, and sources in exact
order tool source then `<snapshot>\tests\UnsignedCustomerPackageHarness.cs`.
Specimen NN uses main `EAIRA.PackageSpecimen.Program`, exact source
`<work>\specimens\NN-NAME.cs` and matching `.exe`; its named optional reference is
inserted after `System.dll`. No response file exists. Successful compile has exit 0
and empty stdout/stderr. Angle-bracket terms are defined path variables above and are
substituted as single argv elements after final-handle identity validation.
`lpApplicationName` is the exact held executable final path and argv[0] is the same
path. Each element rejects NUL/CR/LF. Serialization always adds quotes: a run of N
backslashes before a quote becomes 2N+1 backslashes then the quote; a terminal run of
N backslashes becomes 2N backslashes before the closing quote; other characters copy
unchanged; elements join by one space. Golden round trips through
`CommandLineToArgvW` and a managed argv echo are defined without display escaping by
the ordered UTF-8 base64 values ``, `YSBi`, `QzpceFw=`, `YSJi`, `YVwiYg==`. Framing
domain `EAIRA_M5_SLICE5_ARGV_GOLDEN_V1`, 0x00, then five UInt32LE-length fields is 66
bytes with SHA-256 `E75A281A92B34925C943CC3FF050C82422B3E3F3E9CD47126A2FF7D78B408DD1`.
The environment block is UTF-16LE in exact
case-insensitive sorted order `SystemRoot`, `TEMP`, `TMP`, `WINDIR`, each
`NAME=value` plus NUL and one additional final NUL. Names/values reject NUL, CR/LF
and `=` in names. Failed quote or environment golden vectors stop before creation.

Harness A/B suite children receive exact sole argument `Suite` and must emit exactly
one LF-terminated canonical line
`{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_HARNESS_V1\",\"status\":\"PASS\",\"tests\":64,\"caseNamesSha256\":\"F559B2767F8C258FC0E1C0BED56C42F15FB7229DFDF50FB91AA02EA90499EF38\",\"network\":\"NONE\"}`,
zero stderr and exit 0. One additional Harness A child receives `ArgvEcho` followed
by the five decoded vectors and must emit exactly
`{\"schema\":\"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_ARGV_ECHO_V1\",\"status\":\"PASS\",\"count\":5,\"sha256\":\"E75A281A92B34925C943CC3FF050C82422B3E3F3E9CD47126A2FF7D78B408DD1\"}` plus LF,
zero stderr and exit 0. Tool A/B argv after argv[0] is exactly `Build
--package-evidence-root <PACKAGE_A|B>` or `Verify --package-evidence-root
<PACKAGE_A|B>`; profile/source are compiled constants. Each emits exactly one result
line from section 8, zero stderr and the specified exit. Lines are captured, not
forwarded.

One wrapper invocation creates exactly 45 direct children: tool compile A/B (2),
harness compile A/B (2), suite execution A/B plus argv-echo A (3), 36 isolated specimen compiles,
and Tool A then Tool B in lexical order with the same mode (2). A complete A/B cycle
is one Build invocation with one work root and two new package roots, followed by one
Verify invocation with a different new work root and those same existing package
roots: exactly 90 direct children. Discovery and sealed-final cycles use disjoint
work/package roots. Tool A is always paired to Package A and Tool B to Package B;
cross-pairing is rejected.
The Job Object ActiveProcessLimit=1 is retained and no unsupported compiler switch is
used. Native feasibility evidence shows every pinned compiler and compiled .NET
Framework invocation has exactly one sequential descendant in the same non-breakaway
Job and must finish with TotalProcesses=2, ActiveProcesses=0 and
TotalTerminatedProcesses=0. One invocation therefore has 45 direct children and
exactly 45 observed Job-contained descendants; a Build+Verify cycle has 90 direct
children and exactly 90 contained descendants. Any other accounting tuple fails
closed.

Each direct child is created suspended by an in-process Reflection.Emit P/Invoke
bridge (no `Add-Type`, helper file or helper process), assigned before resume to its
own Job Object with `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`,
`JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION`, ActiveProcessLimit=1, and then resumed
under `CREATE_SUSPENDED|CREATE_UNICODE_ENVIRONMENT|CREATE_NO_WINDOW`. Breakaway flags
are absent. Unbounded or concurrent descendant creation is denied by the job limit;
the exact pinned compiler tuple above is the only accepted sequential descendant.
Timeout, stream cap or
failure terminates the whole job and waits for ActiveProcesses=0; accounting must
prove the operation-specific exact tuple before close. Compile timeout is 30 seconds; harness/tool is
60 seconds. Stdout/stderr drain concurrently from process start into separate 64 KiB
capped buffers and are never forwarded. Child executable handles are final-path,
hash, reparse and identity checked and held without write/delete share through exit.
The bridge exposes only CreateJobObjectW, SetInformationJobObject,
AssignProcessToJobObject, QueryInformationJobObject, TerminateJobObject, TerminateProcess,
CreateProcessW, InitializeProcThreadAttributeList, UpdateProcThreadAttribute,
DeleteProcThreadAttributeList, ResumeThread, WaitForSingleObject, GetExitCodeProcess,
CreatePipe, SetHandleInformation, GetFileType, LocalFree and CloseHandle from kernel32, plus
`CommandLineToArgvW` from shell32; all use ExactSpelling/Winapi with
SetLastError=true and Win32 Boolean marshalling. Startup asserts x64 sizes:

```text
IntPtr CreateJobObjectW(IntPtr,string)
bool SetInformationJobObject(IntPtr,int,IntPtr,uint)
bool AssignProcessToJobObject(IntPtr,IntPtr)
bool QueryInformationJobObject(IntPtr,int,IntPtr,uint,out uint)
bool TerminateJobObject(IntPtr,uint)
bool TerminateProcess(IntPtr,uint)
bool CreateProcessW(string,StringBuilder,IntPtr,IntPtr,bool,uint,IntPtr,string,ref STARTUPINFOEX,out PROCESS_INFORMATION)
bool InitializeProcThreadAttributeList(IntPtr,int,uint,ref UIntPtr)
bool UpdateProcThreadAttribute(IntPtr,uint,UIntPtr,IntPtr,UIntPtr,IntPtr,IntPtr)
void DeleteProcThreadAttributeList(IntPtr)
uint ResumeThread(IntPtr)
uint WaitForSingleObject(IntPtr,uint)
bool GetExitCodeProcess(IntPtr,out uint)
bool CreatePipe(out IntPtr,out IntPtr,ref SECURITY_ATTRIBUTES,uint)
bool SetHandleInformation(IntPtr,uint,uint)
uint GetFileType(IntPtr)
IntPtr LocalFree(IntPtr)
bool CloseHandle(IntPtr)
IntPtr CommandLineToArgvW(string,out int)
```

CreateJobObjectW/CreateProcessW/CommandLineToArgvW use Unicode strings; all applicable
Win32 Boolean returns are `[return: MarshalAs(UnmanagedType.Bool)]` and Boolean inputs
are `[MarshalAs(UnmanagedType.Bool)]`. CreateProcessW receives a mutable StringBuilder
for lpCommandLine, null process/thread security pointers, the exact environment block,
the held work-temp final path and `ref STARTUPINFOEX`.
SECURITY_ATTRIBUTES=24 with offsets `nLength@0/securityDescriptor@8/inherit@16`;
STARTUPINFO=104 with `cb@0` and std handles at 80/88/96; STARTUPINFOEX=112 with
attribute-list pointer@104; PROCESS_INFORMATION=24 with process/thread handles@0/8
and IDs@16/20;
JOBOBJECT_BASIC_LIMIT_INFORMATION=64,
JOBOBJECT_EXTENDED_LIMIT_INFORMATION=144 and
JOBOBJECT_BASIC_ACCOUNTING_INFORMATION=48.
`IO_COUNTERS` is six UInt64 values at offsets 0/8/16/24/32/40: read/write/other
operation counts, then read/write/other transfer counts. STARTUPINFO.cb=112,
dwFlags@60 is exactly STARTF_USESTDHANDLES, cbReserved2=0, lpReserved2=null, and
hStdInput/hStdOutput/hStdError are the three allowlisted handles only.
Exact constants are ACTIVE_PROCESS=0x8,
DIE_ON_UNHANDLED_EXCEPTION=0x400, KILL_ON_JOB_CLOSE=0x2000,
JobObjectExtendedLimitInformation=9, JobObjectBasicAccountingInformation=1,
CREATE_SUSPENDED=0x4, CREATE_UNICODE_ENVIRONMENT=0x400,
CREATE_NO_WINDOW=0x08000000, EXTENDED_STARTUPINFO_PRESENT=0x00080000,
STARTF_USESTDHANDLES=0x100, PROC_THREAD_ATTRIBUTE_HANDLE_LIST=0x00020002,
HANDLE_FLAG_INHERIT=1, WAIT_OBJECT_0=0, WAIT_TIMEOUT=258 and STILL_ACTIVE=259.
The two-call attribute-list size query/allocation is exact; UpdateProcThreadAttribute
supplies exactly three inheritable handles: read-only `NUL` stdin, stdout pipe write
and stderr pipe write. `bInheritHandles=true`; every parent pipe end and every other
PowerShell-host handle is absent from the allowlist, and parent write ends close
immediately after resume. Any ABI, allocation, update, assignment, resume, wait,
query or close mismatch fails
closed; job close remains the final kill-on-close backstop.
The first `InitializeProcThreadAttributeList(null,1,0,ref size)` must return false,
set Win32 error `ERROR_INSUFFICIENT_BUFFER=122`, and produce size 1..65,536. The
wrapper allocates exactly that many zeroed HGlobal bytes; the second call must return
true. State is ALLOCATED -> INITIALIZED -> UPDATED -> DELETED -> FREED. Delete
executes exactly once only after successful initialization; FreeHGlobal executes
exactly once on every allocated path after Delete when applicable. Failure before
initialization frees without Delete; failure after initialization deletes then frees.
No pointer is reused or freed while CreateProcessW may reference it.
The Reflection.Emit bridge also exposes the section 6 CreateFileW/NtCreateFile,
NtQueryDirectoryFile, GetFinalPathNameByHandleW, GetFileInformationByHandleEx,
GetFileInformationByHandle, ReadFile, WriteFile, FlushFileBuffers, SetFilePointerEx
and GetFileSizeEx. Wrapper IntPtr handles are checked by Close-NativeHandle; the
compiled tool uses OwnedFileHandle. The wrapper has no NtSetInformationFile import
or filesystem rename/delete authority. Shared layouts/attributes remain exact;
there is no PowerShell pathname mutation fallback.
`JOBOBJECT_BASIC_LIMIT_INFORMATION` fields/offsets are PerProcessUserTime@0,
PerJobUserTime@8, LimitFlags@16, MinimumWorkingSet@24, MaximumWorkingSet@32,
ActiveProcessLimit@40, Affinity@48, PriorityClass@56, SchedulingClass@60.
`JOBOBJECT_EXTENDED_LIMIT_INFORMATION` contains BasicLimitInformation@0,
IO_COUNTERS@64, ProcessMemoryLimit@112, JobMemoryLimit@120,
PeakProcessMemoryUsed@128 and PeakJobMemoryUsed@136. Basic accounting offsets are
TotalUserTime@0, TotalKernelTime@8, ThisPeriodUserTime@16,
ThisPeriodKernelTime@24, TotalPageFaultCount@32, TotalProcesses@36,
ActiveProcesses@40 and TotalTerminatedProcesses@44. Startup rechecks LimitFlags
exactly `0x2408` and ActiveProcessLimit=1 using QueryInformationJobObject.

The NUL stdin handle is opened only through bridge `CreateFileW` with exact device
name `NUL`, GENERIC_READ=0x80000000, share READ|WRITE, OPEN_EXISTING=3,
FILE_ATTRIBUTE_NORMAL=0x80 and a 24-byte SECURITY_ATTRIBUTES whose inherit Boolean
is true. File type must be FILE_TYPE_CHAR=2. The handle is parent-owned until
successful attribute-list update/resume, then explicitly closed after the parent
pipe write ends; the child owns only its inherited duplicate. Every ownership and
inherit-state transition is recorded and double-close fails closed.

Working directory and both `TEMP`/`TMP` are `<work>\temp`. The exact new environment
contains only validated `SystemRoot`, `WINDIR`, `TEMP` and `TMP`. Wrapper writes are
classified separately as `WORK_EVIDENCE_ROOT_ONLY`; tool JSON `writes` describes only
package-tool effects. Build Tool A/B may write only their paired package root. Verify
Tool A/B requests no mutation access and emits `writes=NONE`. Wrapper evidence records
both classifications, every child count/exit/hash and cleanup state, so compiler,
snapshot, TEMP and specimen artifacts are never represented as package output.

The wrapper applies the same absolute-anchor, FileIdInfo and no-reparse checks as the
tool to `C:\Temp`, then creates and holds work root, `snapshot`, `build-a`, `build-b`,
`specimens` and `temp` through handle-relative NtCreateFile. Every known source,
snapshot, generated specimen and compiler-output leaf is created handle-relatively,
verified as a regular non-reparse same-volume single-link file and entered in a
closed inventory before a path is exposed to csc. Snapshot/specimen inputs stay held
without write/delete share. Each compiler output is precreated empty and held by a
write lease that permits compiler READ|WRITE but never DELETE; file ID/link count are
checked before and after compilation. Before the lease closes, a second guard handle
with share READ only is acquired and proved to be the same file ID; that guard denies
write/delete and stays open through metadata inspection and execution. The temp
directory must remain empty after every child; every compiler output is a predeclared
held leaf. The complete tree is enumerated after each child; any reparse, hardlink,
unexpected name, identity change or path outside held work root fails. No compiled
path is executed without its guard. Work roots deliberately persist as bounded
out-of-tree evidence on both success and failure; the wrapper never requests DELETE,
disposition, rename or cleanup authority for them, and reports
`workPersistentOutput=EVIDENCE`. Later removal is outside this lifecycle.

Persistent-work native rows are exact and distinct from package rows:

| Work object | DesiredAccess | Share | Disposition | Options |
| --- | --- | --- | --- | --- |
| work root/subdirectory | `LIST_DIRECTORY|ADD_FILE|ADD_SUBDIRECTORY|TRAVERSE|READ_ATTRIBUTES|WRITE_ATTRIBUTES|SYNCHRONIZE` | `READ|WRITE` | `FILE_CREATE` | `DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |
| snapshot/generated source writer | `READ_DATA|WRITE_DATA|READ_ATTRIBUTES|WRITE_ATTRIBUTES|SYNCHRONIZE` | `READ` | `FILE_CREATE` | `NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |
| snapshot/generated source transitional guard | `READ_DATA|READ_ATTRIBUTES|SYNCHRONIZE` | `READ|WRITE` | `FILE_OPEN` | `NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |
| snapshot/generated source guard | `READ_DATA|READ_ATTRIBUTES|SYNCHRONIZE` | `READ` | `FILE_OPEN` | `NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |
| final wrapper-summary writer | `READ_DATA|WRITE_DATA|READ_ATTRIBUTES|WRITE_ATTRIBUTES|SYNCHRONIZE` | `READ` | `FILE_CREATE` | `NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |

`ADD_FILE=0x2` and `ADD_SUBDIRECTORY=0x4`. A source writer follows
CREATE_EMPTY -> WRITE -> FLUSH -> HASH -> OPEN_TRANSITIONAL_GUARD -> VERIFY_ID_BYTES
-> CLOSE_WRITER -> OPEN_FINAL_GUARD -> VERIFY_ORIGINAL_ID_BYTES -> CLOSE_TRANSITIONAL.
At least one handle denying DELETE sharing remains open throughout. The transitional
read handle permits WRITE sharing only to coexist with the original writer. The final
read handle shares READ only, so an already-open writer causes rejection. Exact final
path, original FileId, byte length and intended SHA are checked through both guards.
No consumer receives the path before the final immutable guard is established. It
remains open through every consumer; Assert-WorkTree revalidates its identity and bytes
before and after every child. Failure retains registered handles until teardown.
This addresses ordinary handle/path replacement and writer races, not hostile writable
mapped sections surviving a closed writer handle or malicious code within this process;
Job Objects and share modes are not a security boundary against the account owner. Directories
close children-first only after the final wrapper summary is flushed. No work object
ever requests DELETE, rename or disposition; failure leaves the evidence tree in place.

The compiler-output lease has its own exact row and never reuses the package-created
file row: DesiredAccess=`READ_ATTRIBUTES|SYNCHRONIZE`, ShareAccess=`READ|WRITE`,
Disposition=`FILE_CREATE`, Options=`NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE`.
It creates a zero-length regular leaf and holds its file identity while csc opens the
same path for write. After csc exit, while the lease remains open, the guard is opened
with DesiredAccess=`READ_DATA|READ_ATTRIBUTES|SYNCHRONIZE`, ShareAccess=`READ`,
Disposition=`FILE_OPEN`, Options=`NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE|NO_RECALL`;
identity/link-count equality is required before the lease closes. State is
LEASE_CREATED_EMPTY -> COMPILER_WRITING -> COMPILER_EXITED -> GUARD_PINNED ->
LEASE_CLOSED -> INSPECTED -> EXECUTED_OR_SPECIMEN_REJECTED -> GUARD_CLOSED.
Any mismatch leaves the non-authoritative work evidence in place and fails; no
DELETE access is ever acquired, so cleanup capability is neither claimed nor needed.


## 4. Profile and non-circular bootstrap

The profile is canonical UTF-8 no BOM, LF-only, one terminal LF, maximum 64 KiB. It
contains, in order, schema `EAIRA_UNSIGNED_CUSTOMER_PACKAGE_PROFILE_V1`, release
`5.5.0-readiness.1`, classification `UNSIGNED_READINESS_ONLY_NOT_INSTALLABLE`,
authority `PACKAGE_NOT_RELEASE_AUTHORITY`, product commit
`872e9b7916c24a09eb52cee8a894d69c0221295d`, source-manifest SHA-256
`4B9C72AC8A8134F4596CBA024F8A4C6EC21766F85084CB8174EBD77A33A04D85`, network `NONE`, writes
`OUTPUT_ROOT_ONLY`, signing `NONE`, installation `NONE`, and the exact ordered nine
filename/byte-count/SHA-256 rows from the R2R1 readiness package.

There is no profile-discovery bypass. Bootstrap is: materialize this fully static
profile; independently hash/review raw bytes; insert only that hash into wrapper/tool
constants; compile A/B; independently review; then run sealed final. The 64 case and
36 specimen constants below are design-time constants, not profile fields. The
profile never hashes source/script/tool that embeds the profile hash, so no cycle
exists. Profile is held, limited, raw-hashed before parse, and those same bytes parse.
Because the repository is OneDrive-backed, the compiled tool's fixed profile and the
wrapper's exact nine enumerated repository inputs may be hydrated Cloud Files with
only tags 0x9000E01A or 0x9000601A. Offline/Recall flags fail. This does not authorize
any additional input path or hydration. Compiler, references, sealed payloads and all
package/work outputs reject every reparse point. The two exceptions have different
call sites: the compiled tool reads only its fixed profile; the wrapper snapshots only
the nine literal manifest paths and rehashes their held handles after all children.

## 5. Exact repository-input snapshot

Evidence records relative path, byte count and SHA-256 for all nine paths in section
2. Runtime compilation enforcement is distinct: every input is opened without
write/delete share, final-handle/reparse/identity checked, copied from that held handle
to a protected evidence staging tree, source and snapshot hashes compared, and only
snapshots compile. Held source bytes are rehashed after A/B compile. The wrapper's
hash is externally recorded/reviewed, never embedded in itself.

## 6. Native ABI and handle authority

Target is x64 .NET Framework 4.8 on Windows 10 22H2 or later. Exact imports are
`CreateFileW`, `GetFinalPathNameByHandleW`, `GetFileInformationByHandleEx`,
`GetFileInformationByHandle`, `ReadFile`, `WriteFile`, `FlushFileBuffers`,
`SetFilePointerEx` and `GetFileSizeEx` from kernel32, and `NtCreateFile`,
`NtQueryDirectoryFile`, `NtSetInformationFile` from ntdll. The C# tool uses sealed
`DllImport` declarations with exact spelling and explicit Boolean marshaling. The
PowerShell wrapper creates an in-process Reflection.Emit PInvokeImpl bridge whose
entry names, libraries, parameter widths and calling convention are fixed; it never
consults last-error state, dynamically resolves a symbol or falls back to another API.
Exact managed signatures include:

```text
OwnedFileHandle CreateFileW(string,uint,uint,IntPtr,uint,uint,IntPtr)
uint GetFinalPathNameByHandleW(SafeFileHandle,StringBuilder,uint,uint)
bool GetFileInformationByHandleEx(SafeFileHandle,int,IntPtr,uint)
bool GetFileInformationByHandle(SafeFileHandle,out BY_HANDLE_FILE_INFORMATION)
bool ReadFile(SafeFileHandle,byte[],uint,out uint,IntPtr)
bool WriteFile(SafeFileHandle,byte[],uint,out uint,IntPtr)
bool FlushFileBuffers(SafeFileHandle)
bool SetFilePointerEx(SafeFileHandle,long,out long,uint)
bool GetFileSizeEx(SafeFileHandle,out long)
bool CloseHandle(IntPtr)
int NtCreateFile(out OwnedFileHandle,uint,ref OBJECT_ATTRIBUTES,out IO_STATUS_BLOCK,IntPtr,uint,uint,uint,uint,IntPtr,uint)
int NtQueryDirectoryFile(SafeFileHandle,IntPtr,IntPtr,IntPtr,out IO_STATUS_BLOCK,IntPtr,uint,int,bool,IntPtr,bool)
int NtSetInformationFile(SafeFileHandle,out IO_STATUS_BLOCK,IntPtr,uint,int)
```

The two `NtQueryDirectoryFile` Boolean parameters are
`[MarshalAs(UnmanagedType.U1)]`; Event, ApcRoutine, ApcContext and FileName are always
null; ReturnSingleEntry is false. `GetFileInformationByHandleEx` uses only
FileAttributeTagInfo=9 and FileIdInfo=18; unsupported FileIdInfo is a hard failure.
No string output buffer is trusted until length and terminal bounds are validated.
No fallback, dynamic load, reflection dispatch or function pointer exists.

All structs use `[StructLayout(LayoutKind.Sequential, Pack=0)]`. `UNICODE_STRING` is
`ushort Length`, `ushort MaximumLength`, `IntPtr Buffer`, size 16, offsets 0/2/8.
`OBJECT_ATTRIBUTES` is `int Length`, `IntPtr RootDirectory`, `IntPtr ObjectName`,
`uint Attributes`, `IntPtr SecurityDescriptor`, `IntPtr SecurityQualityOfService`,
size 48, offsets 0/8/16/24/32/40. `IO_STATUS_BLOCK` is `IntPtr Status`,
`UIntPtr Information`, size 16, offsets 0/8. `FILE_ATTRIBUTE_TAG_INFO` is two uints,
size 8. `FILE_ID_128` is a fixed `[ByValArray(SizeConst=16, ArraySubType=U1)] byte[]`,
size 16; `FILE_ID_INFO` is `ulong VolumeSerialNumber` plus `FILE_ID_128 FileId`, size
24, offsets 0/8. `BY_HANDLE_FILE_INFORMATION` is uint attributes, three FILETIME,
uint volume serial, uint size high/low, uint links and uint index high/low, size 52.
Startup asserts every size/offset and fails before mutation on mismatch. Variable
buffers are zeroed and manually bounds-checked.

Constants: OBJ_CASE_INSENSITIVE=0x40; FILE_LIST_DIRECTORY/READ_DATA=1,
WRITE_DATA=2, TRAVERSE=0x20, DELETE_CHILD=0x40, READ_ATTRIBUTES=0x80,
WRITE_ATTRIBUTES=0x100, DELETE=0x10000, SYNCHRONIZE=0x100000; share
READ=1/WRITE=2 and never DELETE; FILE_OPEN=1,
FILE_CREATE=2; DIRECTORY_FILE=1, SYNCHRONOUS_IO_NONALERT=0x20,
NON_DIRECTORY_FILE=0x40, OPEN_REPARSE_POINT=0x200000, OPEN_NO_RECALL=0x400000.
For `CreateFileW`: OPEN_EXISTING=3, FILE_FLAG_OPEN_NO_RECALL=0x00100000,
FILE_FLAG_OPEN_REPARSE_POINT=0x00200000 and FILE_FLAG_BACKUP_SEMANTICS=0x02000000.
Absolute anchor directories use access `LIST_DIRECTORY|READ_ATTRIBUTES|SYNCHRONIZE`,
share READ|WRITE, OPEN_EXISTING and all three flags. Absolute regular-file anchors use
`READ_DATA|READ_ATTRIBUTES|SYNCHRONIZE`, share READ, OPEN_EXISTING, OPEN_REPARSE and
OPEN_NO_RECALL. All descendants use the NtCreateFile table below; no absolute-path
mutation API exists.

Per-operation access/share/options are exact:

| Object | DesiredAccess | Share | Disposition | Options |
| --- | --- | --- | --- | --- |
| Existing local output directory/ancestor | `LIST_DIRECTORY|READ_ATTRIBUTES|SYNCHRONIZE` | `READ|WRITE` | `OPEN` | `DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |
| Profile/source payload | `READ_DATA|READ_ATTRIBUTES|SYNCHRONIZE` | `READ` | `OPEN` | `NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE|NO_RECALL` |
| Created directory | `LIST_DIRECTORY|ADD_FILE|ADD_SUBDIRECTORY|TRAVERSE|READ_ATTRIBUTES|WRITE_ATTRIBUTES|DELETE|SYNCHRONIZE` | `READ|WRITE` | `CREATE` | `DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |
| Created payload/README/manifest | `READ_DATA|WRITE_DATA|READ_ATTRIBUTES|WRITE_ATTRIBUTES|DELETE|SYNCHRONIZE` | `READ` | `CREATE` | `NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |
| Verify file | `READ_DATA|READ_ATTRIBUTES|SYNCHRONIZE` | `READ` | `OPEN` | `NON_DIRECTORY|SYNC_NONALERT|OPEN_REPARSE` |

WRITE share never applies to files. Every created handle is inserted into the ledger
before exposure; synchronous `ReadFile`/`WriteFile` operate directly on that handle,
verify an explicit file-position reset, exact byte count, EOF and flush; explicit state is
OPEN_VALIDATED -> WRITING -> FLUSHED -> VERIFIED -> PUBLISHED_OR_DISPOSED. A handle
closes explicitly after children. Any unobserved finalizer close cannot establish
cleanup completion.

Directory enumeration is synchronous `NtQueryDirectoryFile`, information class
`FileNamesInformation=12`, zeroed 65,536-byte buffer, RestartScan true once, then
false. The first call is exactly once with RestartScan=true; every later call is false.
STATUS_SUCCESS requires `IO_STATUS_BLOCK.Information` in 12..65536 and at least one
valid record; STATUS_NO_MORE_FILES=0x80000006 requires Information=0 and terminates.
STATUS_BUFFER_OVERFLOW=0x80000005, STATUS_BUFFER_TOO_SMALL=0xC0000023 and every other
status fail without retry or buffer resize. Records are NextEntryOffset@0,
FileIndex@4, FileNameLength@8, UTF-16 name@12.
Overflow/truncation, odd length, invalid/aligned-out-of-range offset, duplicate or more
than 32 entries fails. `.`/`..` alone are ignored.

`NtCreateFile` always uses held RootDirectory plus one separator/colon-free leaf,
OBJ_CASE_INSENSITIVE, FILE_CREATE, synchronous non-alert plus exact directory or
non-directory/open-reparse/no-recall options. Rename uses
FileRenameInformation=10, ReplaceIfExists=false, held evidence-root RootDirectory and
leaf `package`. Cleanup uses FileDispositionInformation=13 Boolean true on the held
ledger handle. Children close before parents. Unexpected NTSTATUS fails; mapped raw
codes remain private.
Rename buffer x64 is zeroed `FILE_RENAME_INFORMATION`: ReplaceIfExists byte@0=false,
seven padding bytes, RootDirectory IntPtr@8, FileNameLength uint@16, UTF-16 name@20;
buffer size is `20 + nameBytes`; the name begins at offset 20. Disposition buffer is one zeroed byte
set to 1, size 1, class 13. `IO_STATUS_BLOCK.Information` must match FILE_OPENED=1
for FILE_OPEN and FILE_CREATED=2 for FILE_CREATE. Rename success is NTSTATUS zero;
its Information field is not interpreted. Disposition additionally requires Information
zero. FILE_SUPERSEDED=0, FILE_OVERWRITTEN=3,
FILE_EXISTS=4 and FILE_DOES_NOT_EXIST=5 fail. Rename transitions VERIFIED->PUBLISHED
only after NTSTATUS=0 and revalidation of the same held handle under the
new parent/name. Disposition transitions to DISPOSITION_SET only after status 0/info
0, then parent closes after children. Failure leaves the handle open, marks
CLEANUP_INCOMPLETE after the bounded retry policy in section 12; path fallback and
recursive deletion are forbidden.

`OwnedFileHandle` derives from SafeHandleZeroOrMinusOneIsInvalid; its sole
`ReleaseHandle` calls pinned `CloseHandle` and records the Boolean return. Closing a
delete-pending ledger handle is explicitly a filesystem mutation and the only point
where disposition cleanup completes. State therefore transitions
DISPOSITION_SET->CLOSE_DELETE_COMPLETION->DELETION_REENUMERATED_ABSENT before cleanup
may be `COMPLETE`. Close failure, finalizer close, unhandled termination, or absence
not independently re-enumerated is always `INCOMPLETE/POSSIBLE`. The wrapper treats a
child that exits without its canonical final result the same way. Explicit Dispose
results are checked; no close retry, pathname fallback, recursive delete or claim of
non-mutating finalization exists.

Every accepted path is absolute DOS-drive syntax with exact GetFullPath equality.
UNC/device/volume-GUID/ADS/dot/trailing-dot-space/8.3 aliases fail. `C:\Temp`, every
ancestor and final object is held and checked non-reparse with final path and volume/
file identity. Every destination create/open is handle-relative; child containment is
verified before any write; write uses that handle; publish uses same-parent relative
rename; cleanup uses still-held handles. Check-then-path mutation is forbidden.

## 7. Build and Verify flow

Build validates argv/profile/source with no write; holds each source payload from
hash/size validation through copy; creates its paired package evidence root,
`package.building` and
payload handle-relatively; creates each file new, verifies its handle before writing,
flushes and rehashes; writes fixed README; generates canonical manifest; writes it
last; explicitly closes descendant handles as required for NTFS directory rename;
renames building to package handle-relatively; then runs Verify. Before the first
child close, failure cleanup uses only original held handles and original FileIds,
checked disposition, checked close and a held-parent absence check. From the first
child close onward, failure never reopens children for deletion: it retains the tree
and reports INCOMPLETE/POSSIBLE. This conservative boundary applies to rename and
post-publication Verify failures, even when some descendants were already verified.

Verify receives the existing paired package evidence root and requests no create,
write, delete, rename or metadata mutation. It enumerates through held
directory handles, requires exact package/payload tree, regenerates expected README
and manifest bytes, hashes payloads, snapshots identities/content before/after, and
requires equality. Tool `OUTPUT_ROOT` is exactly `<PACKAGE_EVIDENCE_ROOT>\package`.
Work-root creation and compilation is wrapper evidence and never attributed to this
tool field. Before/after snapshots prove Verify changed neither paired package tree.
Build and Verify each compute two sanitized identity digests while holding the package
root and published package directory. The digest is SHA-256 over ASCII domain
`EAIRA_M5_SLICE5_OBJECT_IDENTITY_V1`, one 0x00 byte, UInt64LE volume serial and the
exact 16 FileIdInfo bytes. Raw volume/file IDs and paths never enter evidence.
`packageRootIdentitySha256A/B` and `packageIdentitySha256A/B` from Verify must equal
the corresponding Build summary values before tree/content equality is considered.
This is the cross-invocation object binding; no claim of retaining handles between
separate wrapper processes is made.
Each invocation also records `workRootIdentitySha256` with the same identity-digest
domain and held-handle construction. The Build and Verify work-root digests in one
cycle must be unequal; equality fails before accepting the composite evidence.

## 8. Canonical bytes and result

README is the eight exact ASCII LF-terminated lines in the R2R1 scope. Manifest has
exact ordered members: schema, releaseVersion, classification, authority,
productCommit, sourceManifestSha256, profileSha256, network, writes, signing,
installation, payloadCount, payloads, readmeSha256, packageContentSha256. Row order
and members are exact. Fixed templates emit ASCII; quote/backslash escape with `\`;
control bytes use lowercase `\u00xx`; non-ASCII is impossible. One final LF is byte
0x0A. Verify regenerates bytes rather than permissively parsing the manifest.

Content digest is SHA-256 of ASCII domain
`EAIRA_UNSIGNED_CUSTOMER_PACKAGE_CONTENT_V1`, actual 0x00, then FIELD of release,
product commit, source-manifest SHA, profile SHA, README SHA and each ordered row's
filename, unsigned base-10 byte-count text and SHA. FIELD is UInt32LE UTF-8 length
plus UTF-8 bytes. Empty/one-row/nine-row golden hashes are frozen during implementation
from the exact design vectors and independently reviewed before final; production
accepts only nine rows.

The frozen implementation vectors use the exact 469-byte README with SHA-256
`4F61B0E332411DE31EB12AE85E9737706C505428542453D6AA861C2341EF47FF`.
The empty conceptual list is 312 framed bytes with SHA-256
`E37536C1237A92A57BF09C756C4CBD4B6B7D0C39086323E70014BB1DEAEB5288`;
the first-row-only vector is 419 framed bytes with SHA-256
`81861F03E883AF0542BEA8299CAED6BEF430232494D24F17C43F8C92B6933522`;
and the production nine-row vector is 1,275 framed bytes with SHA-256
`DD51108C50DD4C1069695593DBEFF39C12927148E7DDBFEE98939CFD16B19DAB`.

Success result is one canonical line with schema
`EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1`, PASS, mode, classification, release,
payloadCount=9, packageContentSha256, network=NONE, writes (Build
OUTPUT_ROOT_ONLY; Verify NONE), signing=NONE, installation=NONE and authority.

Invalid argv exits 64. Other failure exits 1. Verify/pre-mutation Build failure emits
writes=NONE, cleanup=NOT_REQUIRED, persistentOutput=NONE. After first destination
create attempt, failure emits writes=OUTPUT_ROOT_ONLY and cleanup COMPLETE/INCOMPLETE;
persistentOutput is NONE only after proven complete cleanup, otherwise POSSIBLE.
Stderr is empty. No raw child output, path, exception, native value or partial digest
is emitted.

Exact canonical result templates, in member order and with `<H>` replaced by one
uppercase 64-hex digest, are:

```text
{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1","status":"PASS","mode":"Build","classification":"UNSIGNED_READINESS_ONLY_NOT_INSTALLABLE","releaseVersion":"5.5.0-readiness.1","payloadCount":9,"packageContentSha256":"<H>","network":"NONE","writes":"OUTPUT_ROOT_ONLY","cleanup":"NOT_REQUIRED","persistentOutput":"PACKAGE","signing":"NONE","installation":"NONE","authority":"PACKAGE_NOT_RELEASE_AUTHORITY"}
{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1","status":"PASS","mode":"Verify","classification":"UNSIGNED_READINESS_ONLY_NOT_INSTALLABLE","releaseVersion":"5.5.0-readiness.1","payloadCount":9,"packageContentSha256":"<H>","network":"NONE","writes":"NONE","cleanup":"NOT_REQUIRED","persistentOutput":"PACKAGE","signing":"NONE","installation":"NONE","authority":"PACKAGE_NOT_RELEASE_AUTHORITY"}
{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1","status":"INVALID_REQUEST","mode":"NONE","network":"NONE","writes":"NONE","cleanup":"NOT_REQUIRED","persistentOutput":"NONE","signing":"NONE","installation":"NONE","authority":"PACKAGE_NOT_RELEASE_AUTHORITY"}
{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1","status":"FAIL","mode":"<Build|Verify>","network":"NONE","writes":"NONE","cleanup":"NOT_REQUIRED","persistentOutput":"NONE","signing":"NONE","installation":"NONE","authority":"PACKAGE_NOT_RELEASE_AUTHORITY"}
{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1","status":"FAIL","mode":"Build","network":"NONE","writes":"OUTPUT_ROOT_ONLY","cleanup":"COMPLETE","persistentOutput":"NONE","signing":"NONE","installation":"NONE","authority":"PACKAGE_NOT_RELEASE_AUTHORITY"}
{"schema":"EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1","status":"FAIL","mode":"Build","network":"NONE","writes":"OUTPUT_ROOT_ONLY","cleanup":"INCOMPLETE","persistentOutput":"POSSIBLE","signing":"NONE","installation":"NONE","authority":"PACKAGE_NOT_RELEASE_AUTHORITY"}
```

Every displayed line ends with one actual LF byte 0x0A; the code fence renders the
line break, not two backslash/n characters. No other member or ordering is accepted.

## 9. Exact 64-case baseline

Ordered case names are:

```text
PROFILE_EXACT_HASH_PASS|PROFILE_WRONG_HASH_FAIL|PROFILE_OVERSIZE_FAIL|PROFILE_REPARSE_FAIL|PROFILE_SCHEMA_ORDER_FAIL|README_CANONICAL_GOLDEN|MANIFEST_CANONICAL_GOLDEN|CONTENT_DIGEST_THREE_GOLDENS
PATH_SOURCE_EXACT_PASS|PATH_EVIDENCE_LEAF_PASS|PATH_RELATIVE_FAIL|PATH_UNC_FAIL|PATH_DEVICE_FAIL|PATH_VOLUME_GUID_FAIL|PATH_ADS_FAIL|PATH_DOT_SEGMENT_FAIL|PATH_TRAILING_DOT_FAIL|PATH_TRAILING_SPACE_FAIL|PATH_SHORT_NAME_FAIL|PATH_CONTAINMENT_FAIL
SOURCE_EXACT_INVENTORY_PASS|SOURCE_MISSING_FAIL|SOURCE_EXTRA_FAIL|SOURCE_RENAMED_FAIL|SOURCE_SIZE_FAIL|SOURCE_HASH_FAIL|SOURCE_REPARSE_FAIL|SOURCE_SWAP_AFTER_OPEN_FAIL|PROFILE_SWAP_AFTER_OPEN_FAIL|SOURCE_SAME_HANDLE_COPY_PASS
OUTPUT_PARENT_HELD_PASS|OUTPUT_CREATE_RELATIVE_PASS|OUTPUT_CHILD_CHECK_BEFORE_WRITE|OUTPUT_WRITE_HELD_HANDLE_ONLY|OUTPUT_RENAME_RELATIVE_PASS|OUTPUT_DISPOSITION_HANDLE_ONLY|OUTPUT_CREATE_RACE_FAIL|OUTPUT_OPEN_RACE_FAIL|OUTPUT_RENAME_RACE_FAIL|OUTPUT_DISPOSITION_RACE_FAIL|OUTPUT_FOREIGN_LEDGER_RETAINED|OUTPUT_NO_RECURSIVE_CLEANUP
BUILD_A_PASS|BUILD_B_PASS|BUILD_AB_TREE_EQUAL|VERIFY_A_PASS|VERIFY_B_PASS|VERIFY_ZERO_WRITE_PASS|VERIFY_CHANGED_PAYLOAD_FAIL|VERIFY_EXTRA_ENTRY_FAIL|VERIFY_MISSING_ENTRY_FAIL|VERIFY_CHANGED_README_FAIL|VERIFY_CHANGED_MANIFEST_FAIL|VERIFY_MANIFEST_BOM_FAIL|VERIFY_TRAILING_TOKEN_FAIL
CHANNEL_BUILD_SUCCESS_SANITIZED|CHANNEL_VERIFY_SUCCESS_SANITIZED|CHANNEL_PREMUTATION_FAILURE_NONE|CHANNEL_POSTMUTATION_FAILURE_CONSERVATIVE|CHANNEL_INVALID_ARGV_64|CAPABILITY_NO_NETWORK|CAPABILITY_NO_PAYLOAD_EXECUTION|CAPABILITY_NO_SIGN_INSTALL|PAYLOAD_EXACT_NINE_BASELINE
```

Framing is domain `EAIRA_M5_SLICE5_CASE_NAMES_V1`, 0x00, then UInt32LE length and
UTF-8 name: count 64, bytes 1,777, SHA-256
`F559B2767F8C258FC0E1C0BED56C42F15FB7229DFDF50FB91AA02EA90499EF38`.
PASS/GOLDEN names require exit 0/invariant; FAIL names inject only their named fault
and require sanitized exit 1; INVALID_ARGV requires 64. Race/fault cases use
`EAIRA_PACKAGE_TEST_SEAMS` to replace native I/O with an in-memory filesystem.
Every fault/race test calls the production Build/Verify orchestration, serializers,
identity ledger and cleanup code. The test backend models nodes, identities, open
handles and disposition; it is not an independent copy of the Build action sequence.
Native A/B Build/Verify separately exercise the real filesystem. Memory tests do not
claim adversarial native scheduling coverage. Production PE review rejects test-only
types and enforces the native import and forbidden-capability allowlists.

`OUTPUT_CREATE_RACE_FAIL`, `OUTPUT_OPEN_RACE_FAIL`, `OUTPUT_RENAME_RACE_FAIL`,
`OUTPUT_DISPOSITION_RACE_FAIL` and `CHANNEL_POSTMUTATION_FAILURE_CONSERVATIVE`
iterate this exact internal ordered fault set:

```text
CREATE_EVIDENCE_ROOT|CREATE_PACKAGE_BUILDING|CREATE_PAYLOAD_DIRECTORY|CREATE_PAYLOAD_01|CREATE_PAYLOAD_02|CREATE_PAYLOAD_03|CREATE_PAYLOAD_04|CREATE_PAYLOAD_05|CREATE_PAYLOAD_06|CREATE_PAYLOAD_07|CREATE_PAYLOAD_08|CREATE_PAYLOAD_09|WRITE_PAYLOAD_01|WRITE_PAYLOAD_02|WRITE_PAYLOAD_03|WRITE_PAYLOAD_04|WRITE_PAYLOAD_05|WRITE_PAYLOAD_06|WRITE_PAYLOAD_07|WRITE_PAYLOAD_08|WRITE_PAYLOAD_09|FLUSH_PAYLOAD_01|FLUSH_PAYLOAD_02|FLUSH_PAYLOAD_03|FLUSH_PAYLOAD_04|FLUSH_PAYLOAD_05|FLUSH_PAYLOAD_06|FLUSH_PAYLOAD_07|FLUSH_PAYLOAD_08|FLUSH_PAYLOAD_09|CREATE_README|WRITE_README|FLUSH_README|CREATE_MANIFEST|WRITE_MANIFEST|FLUSH_MANIFEST|RENAME_PACKAGE|VERIFY_PACKAGE
```

Framing domain `EAIRA_M5_SLICE5_FAULT_SUBCASES_V1`: count 38, bytes 802,
SHA-256 `B541622BA7E0F25C10CE33C015D222C1652A080ABB7D2A1EFA7E6D8BA474BAC1`.
For each row a test-only hook at the corresponding production Build boundary throws
before/after the operation, yielding 76 deterministic subcases. Each applicable race
projection makes a separate Build call that inserts a collision/replacement or passes
a mismatched identity to the same disposition adapter. Assertions inspect remaining
objects, foreign-object retention, writes, checked closes and the production failure
channel; they do not infer success from a static count. Rename/Verify faults retain
the tree and require INCOMPLETE/POSSIBLE. Earlier faults require actual ledger cleanup.

Every one of those 76 executions emits five ordered assertion projections. `A` means
the named projection must execute and pass; `N` means it must emit literal
`NOT_APPLICABLE` and may not silently disappear. Applicability is exact:

| Projection stable case | A rule | A count | N count | Expected outcome |
| --- | --- | ---: | ---: | --- |
| `OUTPUT_CREATE_RACE_FAIL` | before and after each of the 14 `CREATE_*` actions | 28 | 48 | attempted target substitution is rejected; ledger-only state retained |
| `OUTPUT_OPEN_RACE_FAIL` | before and after `VERIFY_PACKAGE` | 2 | 74 | substituted/opened identity is rejected with zero Verify writes |
| `OUTPUT_RENAME_RACE_FAIL` | before and after `RENAME_PACKAGE` | 2 | 74 | no foreign replacement and no path fallback |
| `OUTPUT_DISPOSITION_RACE_FAIL` | every subcase except before `CREATE_EVIDENCE_ROOT` | 75 | 1 | only still-matching ledger handles may receive disposition |
| `CHANNEL_POSTMUTATION_FAILURE_CONSERVATIVE` | all subcases | 76 | 0 | pre-first-create is NONE/NOT_REQUIRED; otherwise COMPLETE/NONE or INCOMPLETE/POSSIBLE |

The evidence row key is exact tuple `(faultOrdinal, BEFORE|AFTER, projectionOrdinal)`;
the wrapper requires 38*2*5=380 ordered rows, the exact A/N totals above, no duplicate
key and no missing row. This matrix is independent of the 64 top-level stable-case
count and prevents a projection from being omitted or relabelled.
Projection-mask framing is ASCII domain
`EAIRA_M5_SLICE5_FAULT_PROJECTION_MASK_V1`, byte 0x00, then each ordered row as one
UInt32LE-length UTF-8 field. Row text is exactly
`NN|FAULT_NAME|PHASE|P|PROJECTION_NAME|A_OR_N`: NN is zero-padded 01..38, PHASE is
`BEFORE` then `AFTER`, P is unpadded 1..5, and applicability is literal `A` or `N`.
The 380-row framed stream is 23,567 bytes with SHA-256
`3FF61A7E3CE9B4E81D0476769080F669D8EF61072AE95DA4874C5577DEE72996`.

## 10. Exact 36 compile-then-reject specimens

Ordered names are:

```text
FORBIDDEN_SYSTEM_NET|FORBIDDEN_HTTPCLIENT|FORBIDDEN_PROCESS|FORBIDDEN_REGISTRY|FORBIDDEN_SERVICE_CONTROLLER|FORBIDDEN_ACCESS_CONTROL|FORBIDDEN_X509_SIGNING|FORBIDDEN_ZIP_INSTALLER
NAMESPACE_UNC_LITERAL|NAMESPACE_DEVICE_LITERAL|NAMESPACE_VOLUME_GUID_LITERAL|NAMESPACE_ADS_LITERAL|NAMESPACE_DOT_SEGMENT_LITERAL|NAMESPACE_TRAILING_DOT_LITERAL|NAMESPACE_TRAILING_SPACE_LITERAL|NAMESPACE_SHORT_NAME_LITERAL
JSON_BOM_WRITER|JSON_NONCANONICAL_WHITESPACE|JSON_LOWERCASE_DIGEST|JSON_DUPLICATE_MEMBER|JSON_UNKNOWN_MEMBER|JSON_REORDERED_MEMBER
PATH_CREATE_CHECK_THEN_USE|PATH_OPEN_CHECK_THEN_USE|PATH_RENAME_CHECK_THEN_USE|PATH_DELETE_CHECK_THEN_USE|UNSAFE_FILE_CREATE|UNSAFE_FILE_MOVE|UNSAFE_FILE_DELETE|UNSAFE_DIRECTORY_DELETE_RECURSIVE
PAYLOAD_PROCESS_START|PAYLOAD_ASSEMBLY_LOAD|PAYLOAD_REFLECTION_INVOKE|PAYLOAD_NATIVE_LOADLIBRARY|PAYLOAD_SHELLEXECUTE|PAYLOAD_DELEGATE_FUNCTION_POINTER
```

Framing domain `EAIRA_M5_SLICE5_SPECIMEN_NAMES_V1`: count 36, bytes 1,022,
SHA-256 `B6559DB36F5CD9FABC6590AF0950E9B8E36251822F028B094800E98CA17A1988`.
Each isolated specimen compiles exit 0, is never executed/loaded, then PowerShell
rejects its exact named rule. The bounded verifier uses System.Reflection.Metadata to
enumerate AssemblyRef, TypeRef, TypeDef namespace/name, MemberRef, MethodDef call
operands, ModuleRef/PInvoke and user strings, plus exact ASCII/UTF-16 namespace tokens.
Malformed, unresolved or oversized metadata fails. Final mode requires all 36
ordered rows and name digest.

The wrapper may use System.Reflection.Metadata only when the current host is exact
`pwsh.exe`, 301,368 bytes, SHA-256
`362A356CE7F0940EC74F73A8FC2C990A2CC24A38A11C90BBD8ECA947110AD139`,
product version `7.6.5 SHA: ea554a8f9c6085f54fb2828f7ea286c65c35599f+ea554a8f9c6085f54fb2828f7ea286c65c35599f`,
valid signer thumbprint `AB172913A2960A224809EE8A0C371CD47A079B72`, and these complete permitted
non-framework metadata files from the same verified directory:
`System.Reflection.Metadata.dll` 1,156,904 bytes,
`97152D5C07E1E5D7F080F871EFF211CCDBECB2496E4EB1B086005CBD3656D431`;
`System.Collections.Immutable.dll` 976,680 bytes,
`623AD5FA5AC38C460DF0073F37FBB649E219AC486C926B822F77EBF02676D56C`;
`System.Memory.dll` 161,576 bytes,
`58A4DC8A9EFAC1FE0EE67138B0DDA35B2B812ADDC14C5D8251CC222B278A5C2D`;
`System.Buffers.dll` 15,144 bytes,
`7EFC8DFEF9548771EC328610DE7B8E5C4308A8EA6B1CA73021F336FC00653176`;
and `System.Runtime.CompilerServices.Unsafe.dll` 15,144 bytes,
`6F396205ABE594C9C72E618F4278657B4FF9DA9CD2BC17D8083481B287838ECC`.
All five report product version
`10.0.11+e2f47b0110ed922f21a1522da67279133ce28f32`; any other non-framework
dependency resolution or load fails before specimen inspection.
The verifier decodes every MethodDef body opcode, including call/callvirt/newobj/ldftn/
ldvirtftn/calli and MethodSpec resolution; unresolved tokens or calli in production
fail. It enumerates AssemblyRef/TypeRef/MemberRef/ModuleRef/PInvoke/user strings,
never loads a specimen assembly, and maps each specimen to exactly one rule ID.

The exact source inventory below is authoritative. Each row is
`NAME|BYTE_COUNT|SOURCE_SHA256|BASE64_OF_EXACT_UTF8_NO_BOM_LF_TERMINATED_BYTES`.
There are 36 rows and 5,596 source bytes. Framing domain
`EAIRA_M5_SLICE5_SPECIMEN_SOURCES_V1`, byte 0x00, then for each row
`UInt32LE(nameBytes)||nameBytes||UInt32LE(sourceBytes)||sourceBytes` is 6,764 bytes
with SHA-256 `99CB422F73D3A0F20CFAAB0C4123465DF8A3DDBABD422AED897150D2207AFFA1`.
The wrapper base64-decodes, checks count/hash/framing, writes only those bytes, and
requires compile exit 0 plus the sole rule identified by the row name.
Rule ownership is deterministic and applies only to specimen classification: exact
PInvoke/member rules (`PAYLOAD_*`) take precedence over unsafe filesystem members,
which take precedence over forbidden external TypeRef, then forbidden TypeDef, then
user-string rules. A lower-priority token that is structurally required by the
selected higher-priority member is supporting evidence for that same rule, not a
second rule ID. Thus `PAYLOAD_PROCESS_START` owns both its `Process.Start` MemberRef
and required `System.Diagnostics.Process` TypeRef; `FORBIDDEN_PROCESS` owns a Process
TypeRef only when no Process.Start MemberRef exists. The classifier must return the
one expected row name and its complete supporting-token set. Production inspection
does not suppress anything: any forbidden TypeRef, TypeDef, member, PInvoke or string
fails regardless of precedence.

```text
FORBIDDEN_SYSTEM_NET|170|CD01B2321CF638030EB611EAB99924C6571A072E69D9BDB80F21F9BAAA26DF5C|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAwO319fW5hbWVzcGFjZSBTeXN0ZW0uTmV0e2ludGVybmFsIHNlYWxlZCBjbGFzcyBFYWlyYUZvcmJpZGRlblN5c3RlbU5ldHt9fQo=
FORBIDDEN_HTTPCLIENT|146|51995CEDBF9ED0FBEFBC1135FDFB84BA1C4F0460164D5D0ADD7DA96587025304|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiB0eXBlb2YoU3lzdGVtLk5ldC5IdHRwLkh0dHBDbGllbnQpLk5hbWUuTGVuZ3RoO319fQo=
FORBIDDEN_PROCESS|146|62A6FE4475BCB2F4731AEF8A4B1301FD475347623A58D129F02ACFA93483E10E|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiB0eXBlb2YoU3lzdGVtLkRpYWdub3N0aWNzLlByb2Nlc3MpLk5hbWUuTGVuZ3RoO319fQo=
FORBIDDEN_REGISTRY|144|355410EBF65ABA1BF2A87FDD32A6060F048727DAE031CDE13F913369D15E9E8B|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiB0eXBlb2YoTWljcm9zb2Z0LldpbjMyLlJlZ2lzdHJ5KS5OYW1lLkxlbmd0aDt9fX0K
FORBIDDEN_SERVICE_CONTROLLER|159|E86214ADA5809CC89F187F68BBF0615E561ED624D6575B9D0E0DB0CF1951D4AB|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiB0eXBlb2YoU3lzdGVtLlNlcnZpY2VQcm9jZXNzLlNlcnZpY2VDb250cm9sbGVyKS5OYW1lLkxlbmd0aDt9fX0K
FORBIDDEN_ACCESS_CONTROL|193|2ED01689688C990361D3E84B3D0F82F4EBAD1173AD3B1FCC5A28DE70DF9BCF2D|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAwO319fW5hbWVzcGFjZSBTeXN0ZW0uU2VjdXJpdHkuQWNjZXNzQ29udHJvbHtpbnRlcm5hbCBzZWFsZWQgY2xhc3MgRWFpcmFGb3JiaWRkZW5BY2Nlc3NDb250cm9se319Cg==
FORBIDDEN_X509_SIGNING|182|7BD78E94AA5C1A2C200707388548429D130D59A769EA244B6AF86009142285A7|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiB0eXBlb2YoU3lzdGVtLlNlY3VyaXR5LkNyeXB0b2dyYXBoeS5YNTA5Q2VydGlmaWNhdGVzLlg1MDlDZXJ0aWZpY2F0ZTIpLk5hbWUuTGVuZ3RoO319fQo=
FORBIDDEN_ZIP_INSTALLER|182|D65D169D17E8F5D4838709F580FC9210327173862B39777852C774D9DE436888|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAwO319fW5hbWVzcGFjZSBTeXN0ZW0uSU8uQ29tcHJlc3Npb257aW50ZXJuYWwgc2VhbGVkIGNsYXNzIEVhaXJhRm9yYmlkZGVuWmlwQXJjaGl2ZXt9fQo=
NAMESPACE_UNC_LITERAL|124|E4F61AE78C815BC9D2E557E0A51643FCFAEAC20C546FC9C9DA790DBC503221F7|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiBAIlxcc2VydmVyXHNoYXJlIi5MZW5ndGg7fX19Cg==
NAMESPACE_DEVICE_LITERAL|123|2177C6533E7EB99ECF3775DF93BF53D7E200BB74D38DB5BAEB7D3239F6DB1660|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiBAIlxcP1xDOlxkZXZpY2UiLkxlbmd0aDt9fX0K
NAMESPACE_VOLUME_GUID_LITERAL|159|B7487C24DCF7CF61A9239A7FB5F71C79B53B421D75700A43F2FE36B79453A9A2|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiBAIlxcP1xWb2x1bWV7MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwfVwiLkxlbmd0aDt9fX0K
NAMESPACE_ADS_LITERAL|118|888585410600C205CD2D3E52345F74418F8D394C67153D150BF8AB42F0CF96B9|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiBAIkM6XHg6YWRzIi5MZW5ndGg7fX19Cg==
NAMESPACE_DOT_SEGMENT_LITERAL|118|F94543510F04851CB243F325A8F7C8BD9055686CAF686B95423CBBCD91280D7D|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiBAIkM6XGFcLlxiIi5MZW5ndGg7fX19Cg==
NAMESPACE_TRAILING_DOT_LITERAL|115|5330071A5D747BD23AD06137EDA4AB847FF95C54E4EE1E666609B4847B85E040|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiBAIkM6XGEuIi5MZW5ndGg7fX19Cg==
NAMESPACE_TRAILING_SPACE_LITERAL|115|20FC42E302C4D5EF8753FEBDB9DDF14D7D8AA3BC68065312B94904A3A89BF9BF|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiBAIkM6XGEgIi5MZW5ndGg7fX19Cg==
NAMESPACE_SHORT_NAME_LITERAL|121|699A1A715DCD4C6F2465E9188687A330C5EA1A670B77363F18AE09B04F684A20|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiBAIkM6XFBST0dSQX4xIi5MZW5ndGg7fX19Cg==
JSON_BOM_WRITER|117|BD1C941CFBAD0BC79412D277B5255F4BF3BD337CBA3CB4C685C41300BE43C8E5|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAiVVRGOF9CT00iLkxlbmd0aDt9fX0K
JSON_NONCANONICAL_WHITESPACE|119|CFE2545E5CBB1D638AC78D293202232E1A179D1865DABB73E9E56C89A86AF119|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAiSlNPTl9TUEFDRSIuTGVuZ3RoO319fQo=
JSON_LOWERCASE_DIGEST|125|5949AE8112A0C993F9A0DF16ACD52CE57C2CB5B6ADC1C4040E381998BF8A3E5A|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAibG93ZXJjYXNlX2RpZ2VzdCIuTGVuZ3RoO319fQo=
JSON_DUPLICATE_MEMBER|125|7BBEB336D0BA82BB0B1A71A8AE5722ECB67A020B097B683E71DC52D2B0730174|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAiZHVwbGljYXRlX21lbWJlciIuTGVuZ3RoO319fQo=
JSON_UNKNOWN_MEMBER|123|A1B787C6523450005CF889A2E13AAF8BE2F8B5BEB5EBE0C85139A7139803C02B|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAidW5rbm93bl9tZW1iZXIiLkxlbmd0aDt9fX0K
JSON_REORDERED_MEMBER|125|D00E340CEFB88756FF18E701BB99166E0C0F099A7DD729B32231B103974568DD|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAicmVvcmRlcmVkX21lbWJlciIuTGVuZ3RoO319fQo=
PATH_CREATE_CHECK_THEN_USE|183|AA26ECEF2AECE6125FCAF5D0913DAAF433FC1AD8A9C30163894C0DDCF3BE7B6A|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAwO319fW5hbWVzcGFjZSBFQUlSQS5Gb3JiaWRkZW4uUGF0aE11dGF0aW9ue2ludGVybmFsIHNlYWxlZCBjbGFzcyBDcmVhdGVDaGVja1RoZW5Vc2V7fX0K
PATH_OPEN_CHECK_THEN_USE|181|10528A7FE11B7BFB608C9136C505E954E9DAA7E1DAF2A6634A0BFA09DA5FA17B|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAwO319fW5hbWVzcGFjZSBFQUlSQS5Gb3JiaWRkZW4uUGF0aE11dGF0aW9ue2ludGVybmFsIHNlYWxlZCBjbGFzcyBPcGVuQ2hlY2tUaGVuVXNle319Cg==
PATH_RENAME_CHECK_THEN_USE|183|53317820CCCCAA1DB1AB11968CE9615E9C21CFB95908B584D2BCF414882D6C81|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAwO319fW5hbWVzcGFjZSBFQUlSQS5Gb3JiaWRkZW4uUGF0aE11dGF0aW9ue2ludGVybmFsIHNlYWxlZCBjbGFzcyBSZW5hbWVDaGVja1RoZW5Vc2V7fX0K
PATH_DELETE_CHECK_THEN_USE|183|F9AE35DA47BDBEAFA93B35438D842DC8DAA6F010A6E9C75EE74A2A076FE7621E|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3JldHVybiAwO319fW5hbWVzcGFjZSBFQUlSQS5Gb3JiaWRkZW4uUGF0aE11dGF0aW9ue2ludGVybmFsIHNlYWxlZCBjbGFzcyBEZWxldGVDaGVja1RoZW5Vc2V7fX0K
UNSAFE_FILE_CREATE|142|99DE997D71B7116E945F544564701EB41C83F3DEF2957ADB3350BC428DC77606|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3VzaW5nKHZhciBmPVN5c3RlbS5JTy5GaWxlLkNyZWF0ZSgieCIpKXt9cmV0dXJuIDA7fX19Cg==
UNSAFE_FILE_MOVE|130|69A5DF6122351CB8D458022EA70209602A3BB6FD11120FA6AC44DEB4DD3F3F8D|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe1N5c3RlbS5JTy5GaWxlLk1vdmUoImEiLCJiIik7cmV0dXJuIDA7fX19Cg==
UNSAFE_FILE_DELETE|128|F826D8736D5231AEFF53D52E2E07759924CE79CC9C44D91F7A92381C95383848|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe1N5c3RlbS5JTy5GaWxlLkRlbGV0ZSgieCIpO3JldHVybiAwO319fQo=
UNSAFE_DIRECTORY_DELETE_RECURSIVE|138|0AFED2FE65971E82AC8F200E53BC1C335F8EA60FA4EFB4FDB7FF710E67ED8CC5|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe1N5c3RlbS5JTy5EaXJlY3RvcnkuRGVsZXRlKCJ4Iix0cnVlKTtyZXR1cm4gMDt9fX0K
PAYLOAD_PROCESS_START|139|891D02656CB224127904E2DD6364A3B2B5CBE45FC594BF692191EA828F12CEB4|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe1N5c3RlbS5EaWFnbm9zdGljcy5Qcm9jZXNzLlN0YXJ0KCJ4Iik7cmV0dXJuIDA7fX19Cg==
PAYLOAD_ASSEMBLY_LOAD|146|15397FCD959B56EC72D031CA8CF65F912527094CAD5895CC731067743A4ED681|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe1N5c3RlbS5SZWZsZWN0aW9uLkFzc2VtYmx5LkxvYWQobmV3IGJ5dGVbMF0pO3JldHVybiAwO319fQo=
PAYLOAD_REFLECTION_INVOKE|164|027BD833CBB27C0286DCB9A4B31E69EFFA87CF0F0CFEC041D4448D1DBA6E52A3|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe3R5cGVvZihvYmplY3QpLkdldE1ldGhvZCgiVG9TdHJpbmciKS5JbnZva2UobmV3IG9iamVjdCgpLG51bGwpO3JldHVybiAwO319fQo=
PAYLOAD_NATIVE_LOADLIBRARY|272|643474B56F402E69798CEDB9E8DD983F0EC78D7975CA6D807279EE794B877D83|dXNpbmcgU3lzdGVtO3VzaW5nIFN5c3RlbS5SdW50aW1lLkludGVyb3BTZXJ2aWNlcztuYW1lc3BhY2UgRUFJUkEuUGFja2FnZVNwZWNpbWVue2ludGVybmFsIHN0YXRpYyBjbGFzcyBQcm9ncmFte1tEbGxJbXBvcnQoImtlcm5lbDMyLmRsbCIsQ2hhclNldD1DaGFyU2V0LlVuaWNvZGUpXXByaXZhdGUgc3RhdGljIGV4dGVybiBJbnRQdHIgTG9hZExpYnJhcnlXKHN0cmluZyB4KTtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe0xvYWRMaWJyYXJ5VygieCIpO3JldHVybiAwO319fQo=
PAYLOAD_SHELLEXECUTE|346|D46A9DA8FB947B3EF96ED696228164191443058A8F5439596A16010B0004C89B|dXNpbmcgU3lzdGVtO3VzaW5nIFN5c3RlbS5SdW50aW1lLkludGVyb3BTZXJ2aWNlcztuYW1lc3BhY2UgRUFJUkEuUGFja2FnZVNwZWNpbWVue2ludGVybmFsIHN0YXRpYyBjbGFzcyBQcm9ncmFte1tEbGxJbXBvcnQoInNoZWxsMzIuZGxsIixDaGFyU2V0PUNoYXJTZXQuVW5pY29kZSldcHJpdmF0ZSBzdGF0aWMgZXh0ZXJuIEludFB0ciBTaGVsbEV4ZWN1dGVXKEludFB0ciBoLHN0cmluZyBvLHN0cmluZyBmLHN0cmluZyBwLHN0cmluZyBkLGludCBzKTtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe1NoZWxsRXhlY3V0ZVcoSW50UHRyLlplcm8sIm9wZW4iLCJ4IixudWxsLG51bGwsMCk7cmV0dXJuIDA7fX19Cg==
PAYLOAD_DELEGATE_FUNCTION_POINTER|212|320528BFD6DA78193FD898F62EB83095C8FC256D935501CBF5CC6BF9E2422296|bmFtZXNwYWNlIEVBSVJBLlBhY2thZ2VTcGVjaW1lbntpbnRlcm5hbCBzdGF0aWMgY2xhc3MgUHJvZ3JhbXtwcml2YXRlIHN0YXRpYyBpbnQgTWFpbigpe1N5c3RlbS5SdW50aW1lLkludGVyb3BTZXJ2aWNlcy5NYXJzaGFsLkdldERlbGVnYXRlRm9yRnVuY3Rpb25Qb2ludGVyKFN5c3RlbS5JbnRQdHIuWmVybyx0eXBlb2YoU3lzdGVtLkFjdGlvbikpO3JldHVybiAwO319fQo=
```

## 11. Evidence gates

A non-final discovery run records exact-nine hashes, wrapper/profile/compiler/
reference/tool/harness hashes, A/B tool equality, both 64-case results, all 36
compile/reject rows, two package-tree digests, Verify results and zero-effect counters.
It grants no release authority. Independent review freezes profile, source, case,
specimen, golden-vector and exact-nine repository-input aggregate values. Sealed final
requires `EvidencePhase=SEALED_FINAL` and an externally supplied 64-hex
`ExpectedRepositoryInputsSha256` equal to the freshly recomputed exact-nine aggregate;
discovery requires `NONE`. There is no check bypass in either phase. Sealed final
repeats the complete Build+Verify cycle and only then permits exact-nine staging.
Wrapper self-hash is externally reviewed, never self-pinned.
The wrapper writes one canonical UTF-8/LF summary with ordered members: schema
`EAIRA_UNSIGNED_CUSTOMER_PACKAGE_WRAPPER_EVIDENCE_V1`, status, phase, finalEvidence,
profileSha256, sourceManifestSha256, repositoryInputCount, repositoryInputsSha256,
compilerSha256, mscorlibSha256, systemSha256, toolSha256, harnessSha256,
workRootIdentitySha256, wrapperWrites,
workPersistentOutput, toolWritesA, toolWritesB,
packageRootIdentitySha256A, packageRootIdentitySha256B, packageIdentitySha256A,
packageIdentitySha256B,
directChildCount, descendantCount, childEvidenceCount, childEvidenceSha256,
workTreeCheckCount, heldInputPostcheckCount, faultBackend, caseCount,
caseNamesSha256, specimenCount,
specimenNamesSha256, specimenSourcesSha256, faultSubcaseCount, faultProjectionCount,
argvGoldenCount, argvGoldenSha256, argvEchoPass,
faultProjectionMaskSha256, packageTreeSha256A, packageTreeSha256B, abEqual, network,
signing, installation and authority. Each invocation PASS requires children=45,
descendants=45, childEvidenceCount=45 with a canonical digest over every observed
executable hash, framed argv hash, exit, channel byte/hash and Job tuple, cases=64 per
suite harness, argvGoldenCount=5, argvGoldenSha256
`E75A281A92B34925C943CC3FF050C82422B3E3F3E9CD47126A2FF7D78B408DD1`,
argvEchoPass=true, specimens=36, specimen-source hash
`99CB422F73D3A0F20CFAAB0C4123465DF8A3DDBABD422AED897150D2207AFFA1`, subcases=76,
projections=380 and the fixed projection-mask hash. A complete cycle requires one
Build and one Verify summary with unequal workRootIdentitySha256 values, exact equality of all four
A/B identity digests, and summed direct children=90. No absolute path, time, user,
host, environment, raw stdout/stderr or exception is allowed. Failure uses the same
ordered schema with absent digests rendered as fixed `NONE`, never omitted.

## 12. Authority and determination

No installer, archive, signing, certificate, update, rollback executor, service,
ACL, provider, network, customer distribution or production activation is created.
The C# tool reads only fixed profile and nine source payloads; the wrapper additionally
reads only exact-nine repository inputs, compiler/references and its evidence tree.

Rename and disposition may retry at most 100 times with a fixed 50 ms interval only
for `STATUS_ACCESS_DENIED` or `STATUS_SHARING_VIOLATION`, retaining and revalidating
the same handle and FileId on every rename retry. No path re-resolution, new target,
share relaxation or retry for any other status is allowed.

`EAIRA_M5_SLICE5_A_EXACT_IMPLEMENTATION_DESIGN_V14` records the held-handle work
graph, production-flow fault/race testing, checked handles and conservative cleanup.
R4 is subject to a fresh independent Gate 8 review. R2 discovery summaries are
historical rejected evidence and cannot authorize sealed final for this revision.

## 13. Implementation discovery candidate

The V14 nine-path working-tree candidate is materialized under the consumed Project
Owner lifecycle authority. Discovery uses distinct persistent native-held work roots
and the same A/B package roots for Build then Verify. Acceptance requires each summary
to observe 45 direct children, 45 Job-contained descendants, 45 canonical child rows,
64 production-validator/test-seam cases, 76 injected fault subcases, 380 projections,
36 independently metadata-classified compile-then-reject specimens and identical A/B
package trees. Summary identities are kept as out-of-tree review evidence and are not
self-recorded in any exact-nine bound input, avoiding a circular hash update.

The older 1,809-byte Build summary `BD1FEA60567BE5D9E13C0DF7E892951853A154E397A877E7149B3D4B4FDE1FBE`
and 1,785-byte Verify summary `4939FB2F9C9FAF3BE52DAD023F93996A88E8B0038D75F162EC519B828FD0E87C`
are superseded rejected V8 diagnostics. They reported zero descendants and did not
exercise the held-handle graph or injected fake-native seam; they provide no acceptance
or staging evidence.


## 14. Gate 8 R4 remediation

R4 retains the nine-path ceiling and every existing acceptance check. It closes the
R3 writer-to-guard gap using overlapping handles and per-child original-guard
postchecks; enforces exact final-path equality and rejects Offline, RecallOnOpen and
RecallOnDataAccess; verifies the initial attribute query error 122 immediately; and
checks stdout/stderr remaining capacity before appending any bytes.

Metadata inspection now resolves bounded signatures and all referenced tokens,
MethodSpec generic targets/arity, every MethodDef opcode/operand, branch boundaries,
local signatures and exception regions. It enumerates AssemblyRefs and the user-string
heap and rejects production calli. Seven additional in-memory IL negative controls per
production A/B PE require the exact rejection for invalid opcode, truncated operand,
unresolved method token, calli, invalid branch, unresolved MethodSpec target and cyclic
TypeRef metadata. They
never create or execute a mutated assembly and do not replace the 36 compiled specimens.
R3 discovery evidence remains historical and cannot bind this changed R4 candidate.


R4 additionally pins all 15 PInvoke MethodDefs (13 distinct native library/entry
pairs) in metadata order: declaring type, managed/native names, library, import flags,
method/implementation flags, signature blob and every parameter's sequence/flags/
marshalling descriptor. Seven resolved type-token/name bindings fix the managed types
referenced by those native signature blobs. Flags require private static PInvoke,
PreserveSig, Winapi, ExactSpelling, Unicode for the two W-string calls, SetLastError
for Win32 but not NTSTATUS imports, BOOL returns and U1 native BOOLEAN parameters.
The explicit row inventory is in Assert-NativeInventory and is independently checked
against the C# declarations; it cannot be discovered or updated automatically.
Three additional in-memory native-ABI controls change an import flag, managed return
type and return MarshalAs descriptor; every mutation must fail NATIVE_METHOD_ROW.
Thus each A/B production PE executes 10 PE negative controls, plus 20 compressed-number
boundary goldens using the framework encoder and 4 overlong-number rejection controls.

The parser uses separate active/completed token sets, bounded type-name recursion,
canonical unsigned and signed compressed integers (including signed array lower
bounds), and a bounded user-string heap inventory without per-reference duplication.
The host check binds Environment.ProcessPath to the pinned pwsh path/hash/signer and
product version. Before metadata use, each of the five permitted assemblies is loaded
only from its held verified path if absent, then its loaded full name, unique instance,
location, FileId, hash and product version are checked. The same runtime identity check
runs again after all children. This verifies loaded-file provenance, not resistance to
malicious code or memory modification inside the trusted PowerShell process.
