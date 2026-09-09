# EAIRA M4 Slice 3 Exact Implementation Design and Changed-Path Manifest

Design ID: `EAIRA_M4_SLICE3_S3_R08_EXACT_IMPLEMENTATION_DESIGN_V20_R10R6`

Date: 2026-09-07

Revision: 20

State: `S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_COMPLETE_READY_FOR_INDEPENDENT_REVIEW`

Baseline HEAD: `b3bd69683ae873be59bf5a78e5df4dd6a4e71eec`

## Authority and Evidence Basis

This design is based on the independently accepted R4R1 scope, allowlist and threat model plus the full S3-R07 read-only feasibility pass. S3-R07 established four hydrated files, aggregate size 100,887 bytes, exact directory/file tags `0x9000E01A`/`0x9000601A`, stable pinned handles, strict UTF-8 and schema validity, 27 projected fields, projection size 4,065 bytes, aggregate SHA-256 `5B10C493DF5D720209BBBD9287BB089BE2211C55F2D6A7AC23D41550EFF966A2`, and projection SHA-256 `25E9AF7AFB8CD01DFF135E8C6B814C6B2CF6D487509DB7542AC05F6FFE2A7D2B`.

This document records the separately authorized R10R6 documentary review-readiness state-identifier consistency remediation plus refreshed formal offline verification evidence. It authorizes no product or capability change, external provider invocation, Windows mutation, staging, commit or push.

The first independent S3-R08 review failed closed with `P0=0`, `P1=5`, and `P2=0`. Revision 2 closes the five documentary findings by defining the complete context semantic-seal call graph, an exact native wrapper and test seam, a complete 32-input release-profile binding, byte-exact preauthorization-deny and preflight-translation contracts, and the actual eight-path documentary candidate.

The independent R2 review failed closed with `P0=0`, `P1=2`, and `P2=1`. Revision 3 defines the native/no-native compilation topology for every existing harness, replaces the ambiguous managed handle-routing claim with three non-interchangeable opaque handle interfaces enforced by the C# type system, binds the relevant managed signatures, and corrects the 8/5 path explanation.

The independent R3 review failed closed with `P0=0`, `P1=2`, and `P2=1`. Revision 4 binds the full-assembly caller map for all six approved P/Invokes, separates production and test injection factories with an exact second compilation symbol, and binds exact marker/token `TypeDef`, base-type and `InterfaceImpl` rows.

The independent R4 review failed closed with `P0=0`, `P1=1`, and `P2=1`. Revision 5 makes CLI seam reachability mechanically testable through exact InterfaceImpl implementer sets, complete private-constructor caller multisets and reflection/dynamic-construction bans, and profile-binds the complete raw P/Invoke import, method and implementation attribute bitmasks.

The independent R5 review failed closed with `P0=0`, `P1=1`, and `P2=1`. Revision 6 closes the remaining general compile-time construction path by binding every platform/coordinator implementer constructor and every construction factory per output, adds entry-point reachability closure and direct/helper construction specimens, and corrects the service-output count wording.

The independent R6 review failed closed with `P0=0`, `P1=1`, and `P2=0`. Revision 7 binds the complete incoming caller multiset of both harness construction helpers and makes any extra direct caller or intermediate helper layer an exact-set failure.

The independent R7 review passed with `P0=0`, `P1=0`, and `P2=0`, after which the Human Project Owner separately authorized S3-R09 implementation. The first native compilation probe then failed closed with C# `CS0122`: an enclosing `ProjectContextWin32Platform` cannot directly call private members declared by its nested `ProjectContextNative` type. Revision 8 removes that impossible visibility/nesting combination without widening native capability: all six declarations become private static members of `ProjectContextWin32Platform` itself, while the full caller multiset, raw masks, entry points, constants, handle types and all other controls remain unchanged. S3-R09 remains paused pending a new independent R8 design review.

An isolated, non-executing in-memory C# feasibility specimen for the R8 topology compiled successfully on 2026-09-05. Reflection over its two representative imports confirmed `IsPrivate=true`, `IsStatic=true`, `PInvokeImpl=true` and `PreserveSig=true` for both the platform-called `CreateFileW` declaration and the nested-lease-called `CloseHandle` declaration. This proves only language-level feasibility; the pinned-compiler six-import masks, exact signatures, full caller graph and IL-body hashes remain mandatory S3-R09/S3-R10 evidence.

The independent R8 review passed with `P0=0`, `P1=0`, and `P2=0`, and the Human Project Owner separately authorized S3-R09 implementation resume. The first exact constructor-metadata probe then exposed a second C# accessibility constraint: an enclosing type cannot directly call a `private` constructor declared by its nested type. Revision 9 therefore gives only the three private nested implementers—`ProjectContextWin32Platform`, `ProjectContextHarness.FakePlatform`, and `LocalTaskIntakeHarness.FakeCoordinator`—an explicit `internal` parameterless constructor with exact `Assembly | HideBySig | SpecialName | RTSpecialName` flags (`0x1883`, 6275).
Each declaring TypeDef remains `NestedPrivate | Sealed | BeforeFieldInit`, so the type remains unnameable outside its enclosing type in ordinary C#; the complete constructor caller multisets, reflection/dynamic bans and factory topology remain unchanged. The top-level `ProjectContextRequestCoordinator`, loader injection constructor and intake context constructor remain private. S3-R09 is paused pending a new independent R9 design/remediation review.
The independent R9 review failed closed with `P0=0`, `P1=3`, and `P2=1`. Revision 10/R9R1 added MethodDef, MemberRef and MethodSpec operand resolution, signature-qualified caller identities, exact named-set checks and 18 isolated compile-and-reject specimens. Its development probe passed the ordinary offline suites, seam policy and cross-build controlled-method stability, but the separate independent R9R1 review still failed closed with `P0=0`, `P1=2`, and `P2=1`: the release profile did not bind the complete signature-level MethodDef inventory, `LocalTaskIntake` intentionally bypassed a single-name check without an equivalent full constructor-set binding, six mandatory specimen categories were absent or mislabeled, and the document carried a stale self-referential manifest hash.

Revision 11/R9R2 replaces that partial method check with a release-profile-bound canonical inventory for each of `Cli`, `ContextHarness`, `IntakeHarness`, `ProviderHarness` and `TransportHarness`. Each canonical row binds declaring type, managed name, complete signature blob, raw method and implementation flags, and generic-parameter count; the profile fixes both row count and SHA-256, including all permitted legacy `LocalTaskIntake` constructors, controlled token constructors, factories, helpers, relevant type initializers and entry points. Any added unused constructor, overload, changed parameter/return signature or extra factory-like MethodDef changes the inventory and fails closed. R9R2 expands the same-verifier specimen suite to 24 and distinguishes an extra call site in the same caller from a genuinely separate caller MethodDef. A final sanitized manifest hash is intentionally not embedded in this candidate document because this document is itself a manifest input; the immutable out-of-tree manifest and the separate review report carry its computed hash without circular self-reference. S3-R09 remains paused pending a separate independent R9R2 review.

The independent R9R2 review failed closed with `P0=0`, `P1=2`, and `P2=1`. It found that native signatures and approved-caller IL were observed but not bound to the release profile, `ProjectContextNativeLease` was absent from the controlled seam inventory and complete incoming-edge closure, and the authority paragraph still named R9R1. Revision 12/R9R3 profile-binds the exact six P/Invoke signatures separately for `Cli` and `ContextHarness`, binds a canonical eight-row caller identity/signature/IL inventory by exact count and SHA-256 for each native output, adds the nested lease TypeDef and all five lease MethodDefs to the closed inventory, and binds every constructor, factory, dispose, getter and setter incoming edge including opcode and MethodDef token kind. The isolated suites now contain 27 seam and 17 native specimens, all compiled and rejected by the production verifier. S3-R09 remains paused pending a separate independent R9R3 review.

The independent R9R3 review failed closed with `P0=0`, `P1=1`, and `P2=1`. Revision 13/R9R4 eliminates the `IDisposable.Dispose` interface-dispatch surface rather than permitting an alternate close path: `ProjectContextNativeLease` implements no interface, exposes only the controlled non-public `Close()` wrapper, and has an exact profile-bound zero InterfaceImpl count plus exact TypeDef and `Close` MethodDef flags. The production verifier now rejects an isolated `NATIVE_LEASE_IDISPOSABLE_INTERFACE_DISPATCH` specimen, increasing the seam suite to exactly 28 while retaining 17 native specimens. The formal non-development run used the release-profile-pinned Microsoft Roslyn compiler SHA-256 `2DC1461B1A6E95BE9C1BECEB4B263141B7BB90E704029344A0C2D1A5693D9007`, product version `4.14.0-3.25262.10+8edf7bcd4f1594c3d68a6a567469f41dbd33dd1b`, with valid Microsoft Authenticode, and refreshed only compiler-derived profile metadata measured from that exact compiler. Two builds were byte-for-byte reproducible; all 44 project-context harness tests, 28 seam specimens and 17 native specimens passed; the out-of-tree sanitized manifest reports `M4_SLICE_3_UNSIGNED_TECHNICAL_CHECKS_PASS`. Its computed SHA-256 remains only in out-of-tree evidence and the separate review record so no manifest input embeds a circular self-hash. S3-R09 remains paused pending a separate independent R9R4 review.

The separate independent R9R4 review returned `PASS`, `P0=0`, `P1=0`, and `P2=0`, with no actionable finding. It independently confirmed zero lease interfaces, exact lease TypeDef and `Close()` flags, complete close/native caller closure, exact six-import metadata, pinned compiler identity, 32/32 input hashes, byte-identical A/B outputs, 44 project-context tests, 28 seam specimens and 17 native specimens. Revision 14 records completion of the existing bounded S3-R09 implementation lifecycle without adding capability or changing product code after the reviewed R9R4 candidate. The candidate is ready for S3-R10 independent implementation and abuse-case review; staging, commit, push, signing and activation remain separate later gates.

The independent S3-R10 implementation and abuse-case review then failed closed with `P0=0`, `P1=3`, and `P2=1`. Revision 15/R10R1 remediates those findings without widening the four-path read capability: required YAML keys may use the repository's canonical quoted form, additional top-level status fields remain unprojected, and each required key must still occur exactly once; multi-entry Markdown milestone sections are canonically joined from their non-empty controlled lines. Context-mode Planning provider text is replaced in the result chain by a domain-separated SHA-256 summary, so provider echoes cannot enter downstream AgentResult or CLI JSON. The harness now uses canonical quoted YAML with extra fields, rejects duplicate quoted required keys, covers every pinned ancestor plus relative/separator/case/ADS/UNC/device root variants, proves per-file digests are absent from result metadata, and proves injected instruction/Markdown-reference/provider-echo sentinels are absent from both pipeline and intake serialization. The existing native specimens separately bind exact read-only sharing and `FILE_FLAG_OPEN_NO_RECALL` values. The next gate is a new independent R10R1 remediation review; staging, commit, push, signing and activation remain separate later gates.

Revision 16/R10R2 completes the mandatory abuse matrix and verifier evidence requested after R10R1. It exercises every retained root/ancestor and final-file Cloud Files state, every final-file identity substitution, no-recall content-open failure, exact per-file/aggregate/projection boundaries, missing and extra files, required-schema failures, lower-precedence override attempts, fixed aggregate digest vectors, and raw-content non-emission. The production verifier binds exact output-field inventories and critical serializer, planning, seal, pipeline and intake MethodDef/IL inventories for every governed output. Three additional compiled specimens—`DIRECTORY_ENUMERATION_OUTPUT`, `RAW_CONTENT_OUTPUT`, and `PER_FILE_DIGEST_OUTPUT`—must compile and then be rejected. A formal pinned-toolchain run passed two byte-identical builds, 52 project-context tests, exactly 31 seam specimens and exactly 17 native specimens with status `M4_SLICE_3_UNSIGNED_TECHNICAL_CHECKS_PASS`. The next gate is a new independent R10R2 remediation review.

The independent R10R2 review returned `CANNOT_CLOSE`, `P0=0`, `P1=2`, and `P2=1`. Revision 17/R10R3 adds the omitted non-directory ancestor and directory-final cases; splits final-file validation into path-specific probe, content-before and content-after states and substitutions; repeats probe/content identity and content-open failures for all four files; and adds fixed reversed-path-order, 262,143/262,144-byte and same-length content-change aggregate vectors. It selects the strict ownership rule: exact keys reserved to another controlled source fail closed, while non-reserved additional fields remain opaque and unprojected. It also synchronizes the stale deep `ACTIVE_TASK.yaml` Slice 3 fields. The unchanged output-isolation verifier retains 31 seam and 17 native specimens. A formal pinned-toolchain run passed two byte-identical builds and all 52 project-context assertions. The next gate is a new independent R10R3 remediation review.

The independent R10R3 review returned `CANNOT_CLOSE`, `P0=0`, `P1=1`, and `P2=1`. It confirmed all R10R3 technical controls but found three non-historical `ACTIVE_TASK.yaml` fields still describing R10R1, including the required `Priority` projected to Planning; it also found stale Revision 15/R10R1 wording in `CURRENT_CONTEXT.md` and an overbroad synchronization claim in `HANDOFF.md`. Revision 18/R10R4 changes only the controlled-state and summary documents needed to remove those contradictions, records the R10R3 determination, and refreshes the hash-bound evidence without changing product code, the allowlist, parser, verifier or capability. The refreshed pinned run retains two byte-identical builds, 52 context tests, 31 seam specimens, 17 native specimens and all three output-isolation specimens; the computed final manifest hash remains only in out-of-tree evidence to avoid circular self-reference.

The independent R10R4 review returned `CANNOT_CLOSE`, `P0=0`, `P1=1`, and `P2=1`. It confirmed the original R10R3 controlled-state findings were corrected and the technical evidence remained valid, but found this artifact's `Design ID` still declared V17 while its Revision was 18 and `ACTIVE_TASK.yaml` identified V18/R10R4; it also found the readiness S3-R10 table still named the R10R3 review as next. Revision 19/R10R5 makes the exact design identifier `EAIRA_M4_SLICE3_S3_R08_EXACT_IMPLEMENTATION_DESIGN_V19_R10R5` consistently match this Revision and the active-task identity, corrects the readiness row, records the R10R4 determination, and changes no product code, allowlist, parser, verifier or capability.

The independent R10R5 review returned `CANNOT_CLOSE`, `P0=0`, `P1=1`, and `P2=0`. It confirmed the exact V19/R10R5 design identity, Revision 19, readiness row, lifecycle summaries, 32 bound inputs and technical evidence, but found machine-like readiness identifiers split between `READY_FOR_INDEPENDENT_REVIEW` and `READY_FOR_NEW_INDEPENDENT_REVIEW`. Revision 20/R10R6 defines one canonical identifier—`S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_COMPLETE_READY_FOR_INDEPENDENT_REVIEW`—and uses it unchanged for every current design, readiness and active-task state field. It changes no product code, allowlist, parser, verifier or capability.

## Compatibility Decision

Slice 3 is opt-in. The existing six-argument mock/real form and eight-argument ollama-local form remain byte-for-byte behavior compatible and perform no project-context read.

The only new accepted forms append the repository root last:

```text
EAIRA.AgentTask.Cli.exe --provider mock --trace <TRACE> --goal <GOAL> --context-root <ABSOLUTE_ROOT>
EAIRA.AgentTask.Cli.exe --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ABSOLUTE_ROOT>
```

`real` with `--context-root`, alternate ordering, repeated flags, relative/UNC/device/ADS/short-name roots, trailing-dot/space components, environment expansion and every other form fail as `INVALID_REQUEST/64`. The root is never emitted, logged, hashed into an ordinary result, or sent to a provider.

## Exact Execution Sequence

For a context-enabled request:

1. parse the exact CLI form and create/validate the existing `TaskEnvelope`;
2. compute and seal `GuardAgent.ExpectedDecision(task)` before provider construction or any context handle is opened;
3. on deny, return `DENIED/77` with context state `NOT_READ_GUARD_DENY`, no context read, no provider construction/call and no network;
4. select only enabled mock or exact ollama-local; no external provider is enabled;
5. load the R4R1 four-file bundle through `ProjectContextLoader`;
6. validate all handles, raw bytes, schemas, versions, digests and the complete 27-field projection before any provider lifecycle begins;
7. construct the exact Planning prompt and pass it to `ProjectContextRequestPreflight.Validate`; this calls the existing deterministic canonical-request builder and translates only its pre-lifecycle `LocalProviderException` to `ProjectContextException`; reject more than 16,384 UTF-8 bytes before `BeginRequest` or any tags/chat call;
8. begin the existing request-scoped provider lifecycle;
9. execute the new pipeline overload with the exact Planning prompt and sealed preauthorization; immediately after Planning semantic verification, replace the prompt-bearing validation path with a content-free `ContextPlanningSeal`;
10. replay `GuardAgent.ExpectedDecision(task)` inside the context-specific Guard overload and require exact equality with the sealed decision before Operations; Guard and every later Agent receive the seal, never the Planning prompt or project context;
11. give Operations only the existing Guard-result digest; raw/projected context must not enter Operations, Verification, Audit or either Guard input;
12. end/dispose the provider lifecycle and dispose all context state on every success/failure path; and
13. emit only the versioned sanitized context metadata defined below.

Legacy requests call the existing pipeline overload and retain existing output. A context-enabled deny does not create a partial Agent chain.

## Exact Product Types and Responsibilities

One new source file, `apps/agent-services/src/ProjectContext.cs`, contains only:

- `ProjectContextException`: one sanitized failure type with no path/content-bearing message;
- `IPinnedAncestorHandle`, `ILeafProbeHandle` and `IApprovedContentHandle`: three empty, unrelated internal marker interfaces with no conversion operators or shared project-context handle base;
- `IProjectContextReadOnlyPlatform`: an internal high-level test seam exposing only `OpenPinnedAncestor` returning `IPinnedAncestorHandle`, `OpenLeafProbe` returning `ILeafProbeHandle`, `OpenApprovedContent` returning `IApprovedContentHandle`, queries accepting only their exact handle type, one bounded `ReadApprovedContent(IApprovedContentHandle, int)` operation and close/dispose; it exposes no desired-access, sharing, creation-disposition, raw flag or arbitrary native-call parameter;
- `EAIRA.AgentServices.Functional.ProjectContextLoader+ProjectContextWin32Platform`: the private sealed nested production implementation of that seam;
- six private static Win32 declarations and their private structures, declared directly by `EAIRA.AgentServices.Functional.ProjectContextLoader+ProjectContextWin32Platform` and callable only by that sealed platform or its private nested lease;
- `ProjectContextNativeLease`: a private nested native-region-only `IntPtr` owner used only by the sealed Win32 platform and closed fail-safe through the sole approved `CloseHandle` caller;
- `ProjectContextFileSnapshot`: internal relative path ID, raw byte count, identity and digest;
- `ProjectContextBundle`: immutable allowlist ID, aggregate digest, projection byte count/digest, projection string and fixed provenance/classification;
- `ProjectContextLoader.Load(string absoluteRoot)`: the instance state-machine entry point, which uses only its constructor-bound platform and never constructs an implementer;
- a private platform-accepting `ProjectContextLoader` constructor plus `CreateForTests(IProjectContextReadOnlyPlatform)` compiled only under `EAIRA_PROJECT_CONTEXT_TEST_SEAM`, enabling deterministic call-ledger, substitution and Cloud Files state tests without exposing the factory in the CLI;
- `ProjectContextPrompt.Build(string goal, ProjectContextBundle bundle)`: exact Planning prompt construction; and
- `ProjectContextRequestPreflight.Validate(string exactPlanningPrompt)`: the single pre-lifecycle exception-translation boundary; and
- `IProjectContextRequestCoordinator` plus internal sealed `EAIRA.AgentServices.Functional.ProjectContextRequestCoordinator` and its always-compiled sanitized input/result contract, used by `LocalTaskIntake`; its sole private constructor accepts one `ProjectContextLoader`, while the native and test construction factories are separately symbol-gated; and
- `ProjectContextResultMetadata.ToCanonicalJson()`: sanitized result fragment.

Raw byte arrays and decoded full-file strings remain local to `Load`, are not properties of the returned bundle, and become unreachable after projection construction. Per-file byte counts, identities and digests are internal validation state and never enter ordinary output.

## Native Read-Only Capability Allowlist

The implementation must not reference `System.IO`, `Microsoft.Win32`, `FileStream`, shell, Git, child-process, renderer, write, delete, move, directory-enumeration or network APIs.

`EAIRA.AgentServices.Functional.ProjectContextLoader+ProjectContextWin32Platform` may P/Invoke only `kernel32.dll` and exactly these six entry points:

1. `CreateFileW`;
2. `GetFileInformationByHandle`;
3. `GetFileInformationByHandleEx`;
4. `GetFinalPathNameByHandleW`;
5. `ReadFile`; and
6. `CloseHandle`.

No other ModuleRef, P/InvokeImpl MethodDef or native entry point is permitted. All six declarations are private static members declared directly by `ProjectContextWin32Platform`; they may not be moved into a nested helper, sibling, base type or other declaring type. No delegate, function pointer or raw native handle escapes the sealed platform. This direct declaration is the controlling R8 feasibility repair: it preserves `0x2091` private visibility while allowing the named platform methods and its private nested lease to be the exact direct callers.

`ProjectContextWin32Platform` has exactly three non-overridable open wrappers and one read wrapper. `OpenPinnedAncestor` has one `CreateFileW` call site fixed to `GENERIC_READ`, `FILE_SHARE_READ`, `OPEN_EXISTING`, `FILE_FLAG_OPEN_REPARSE_POINT | FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_NO_RECALL`. `OpenLeafProbe` has one call site fixed to `GENERIC_READ`, `FILE_SHARE_READ`, `OPEN_EXISTING`, `FILE_FLAG_OPEN_REPARSE_POINT | FILE_FLAG_OPEN_NO_RECALL`. `OpenApprovedContent` has one call site fixed to `GENERIC_READ`, `FILE_SHARE_READ`, `OPEN_EXISTING`, `FILE_FLAG_SEQUENTIAL_SCAN | FILE_FLAG_OPEN_NO_RECALL`. Security attributes are null and the template handle is zero at all three sites. Each returns a different private sealed Win32 token implementing only its corresponding marker interface; tokens expose no `IntPtr`. The sole `ReadFile` call site is private `ReadApprovedContent`, accepts only `IApprovedContentHandle`, requires the exact private Win32 approved-content token at runtime, enforces the per-file bound, performs the one sequential read and cannot accept ancestor/probe handles. All handles close in `finally`.

The build script adds `Get-ProjectContextPInvokeMetadata` and `Assert-ProjectContextPInvokePolicy` using `System.Reflection.PortableExecutable.PEReader` and `System.Reflection.Metadata.MetadataReader`. It decodes every MethodDef body in each output, resolves every `call`, `callvirt`, `ldftn`, `ldvirtftn`, `ldtoken` and MethodSpec target, rejects every `calli` and every non-call token load targeting a P/Invoke MethodDef, and constructs a complete callee-to-caller multiset for all six P/Invoke MethodDefs. The verifier must prove, rather than token-scan:

1. the CLI and context harness each contain exactly one ModuleRef named `kernel32.dll`;
2. exactly six private-static P/InvokeImpl MethodDefs exist, each declared directly by `EAIRA.AgentServices.Functional.ProjectContextLoader+ProjectContextWin32Platform`, with exact managed name, import name and signature blob plus the complete raw `MethodImportAttributes`, `MethodAttributes` and `MethodImplAttributes` integer bitmasks bound independently for every method in the release profile;
3. no other ModuleRef, P/InvokeImpl, unmanaged-callers-only method, delegate/function-pointer call or indirect native call exists;
4. the full-assembly caller map, with every caller identified by declaring TypeDef, managed name and exact signature blob rather than name alone, equals exactly:
   - `CreateFileW`: `ProjectContextWin32Platform.OpenPinnedAncestor` once, `OpenLeafProbe` once and `OpenApprovedContent` once; aggregate call-site count 3;
   - `GetFileInformationByHandle`: `ProjectContextWin32Platform.QueryIdentityAndMetadata` once; aggregate count 1;
   - `GetFileInformationByHandleEx`: `ProjectContextWin32Platform.QueryAttributeTag` once; aggregate count 1;
   - `GetFinalPathNameByHandleW`: `ProjectContextWin32Platform.QueryCanonicalFinalPath` once; aggregate count 1;
   - `ReadFile`: `ProjectContextWin32Platform.ReadApprovedContent` once; aggregate count 1; and
   - `CloseHandle`: `ProjectContextNativeLease.Close` once; aggregate count 1;
5. no MethodDef other than the eight named callers contains an IL operand that resolves directly to an approved P/Invoke MethodDef; no `ldftn`, `ldvirtftn` or `ldtoken` targets one of those methods, and no `calli` exists;
6. the canonical eight-row set of approved native callers—each row containing declaring type, managed name, exact signature blob and compiled IL SHA-256—matches the release-profile-bound exact count and aggregate SHA-256 for the output kind;
7. each marker interface TypeDef has exact profile-bound `NotPublic | Interface | Abstract` flags, nil base type and zero InterfaceImpl rows;
8. each of the three private nested Win32 token TypeDefs has exact profile-bound `NestedPrivate | Sealed | BeforeFieldInit` flags, direct base `System.Object`, exactly one InterfaceImpl row naming only its corresponding marker interface, and no additional interface, generic parameter, conversion operator or inheritance edge;
9. the exact metadata signatures of the high-level seam, three token constructors, all query/close methods and `ReadApprovedContent(IApprovedContentHandle, int)` match profile-bound blobs, with no generic/object/`IntPtr` overload, conversion operator or common project-context handle base; and
10. every other runtime/service/harness binary retains zero ModuleRef and P/InvokeImpl rows.

The following raw values are normative before compilation and identical in both native outputs; they are not values learned from, or refreshable during, a release run:

| Declaring type | Managed MethodDef / import name | `MethodImportAttributes` | `MethodAttributes` | `MethodImplAttributes` |
| --- | --- | --- | --- | --- |
| `ProjectContextLoader+ProjectContextWin32Platform` | `CreateFileW` / `CreateFileW` | `0x1165` (4453) | `0x2091` (8337) | `0x0080` (128) |
| `ProjectContextLoader+ProjectContextWin32Platform` | `GetFileInformationByHandle` / `GetFileInformationByHandle` | `0x1165` (4453) | `0x2091` (8337) | `0x0080` (128) |
| `ProjectContextLoader+ProjectContextWin32Platform` | `GetFileInformationByHandleEx` / `GetFileInformationByHandleEx` | `0x1165` (4453) | `0x2091` (8337) | `0x0080` (128) |
| `ProjectContextLoader+ProjectContextWin32Platform` | `GetFinalPathNameByHandleW` / `GetFinalPathNameByHandleW` | `0x1165` (4453) | `0x2091` (8337) | `0x0080` (128) |
| `ProjectContextLoader+ProjectContextWin32Platform` | `ReadFile` / `ReadFile` | `0x1165` (4453) | `0x2091` (8337) | `0x0080` (128) |
| `ProjectContextLoader+ProjectContextWin32Platform` | `CloseHandle` / `CloseHandle` | `0x1165` (4453) | `0x2091` (8337) | `0x0080` (128) |

`0x1165` is exactly `ExactSpelling | CharSetUnicode | BestFitMappingDisable | SetLastError | CallingConventionWinApi | ThrowOnUnmappableCharEnable`. `0x2091` is exactly `Private | Static | HideBySig | PinvokeImpl`. `0x0080` is exactly `PreserveSig`. Equality is over the complete raw integer, so both omitted expected bits and any additional or reserved bit fail closed.

Each source declaration explicitly sets `EntryPoint`, `ExactSpelling=true`, `CallingConvention=CallingConvention.Winapi`, `CharSet=CharSet.Unicode`, `SetLastError=true`, `BestFitMapping=false` and `ThrowOnUnmappableChar=true`, and retains `PreserveSig=true`. The verifier compares the full raw masks, not a selected flag list, so `NoMangle`/exact spelling, character-set mask, calling-convention mask, `SupportsLastError`, best-fit mapping, unmappable-character behavior, `PinvokeImpl`, visibility, static/hide-by-signature and `PreserveSig` cannot change unnoticed. Reserved or unexpected bits fail closed.

The full caller multiset and eight IL-body bindings make any extra native caller, second native call, desired-access, share, disposition, flag, null-security/template or close/read routing change a profile mismatch. The scan covers every MethodDef, so adding a `CreateFileW` or `ReadFile` call to a query, close, coordinator or unrelated method fails even when all eight approved bodies remain unchanged. TypeDef, InterfaceImpl and signature binding makes a changed visibility/base, added marker interface, generic/object/raw-handle overload or conversion a profile mismatch. The profile cannot be refreshed during a release run. Independent implementation review must compare the wrapper source constants, complete decoded caller map, IL bodies and proposed profile values before accepting them.

Isolated native-verifier specimens change each of the seven access/share/disposition/flag constants one at a time, toggle each C#-constructible raw DllImport mask dimension (`ExactSpelling`, `CharSet`, `CallingConvention`, `SetLastError`, `BestFitMapping`, `ThrowOnUnmappableChar`, `PreserveSig`) one at a time, change visibility, add an import, and add an unapproved native caller. Every specimen must compile and then be rejected by the same P/Invoke/caller/seam verifier chain. Static, hide-by-signature and reserved-bit drift remain covered by complete raw integer equality; they are not misrepresented as independently source-constructible C# specimens.

The high-level fake seam is implemented only in `ProjectContextHarness.cs`. It uses its own three private sealed fake tokens, records every method and typed token in order, and rejects tokens not created by that fake instance. Mandatory tests provide exact expected ledgers for success, Guard deny, every ancestor/final substitution, both approved Cloud Files tags, every rejected tag/attribute state, partial read, mutation and exception cleanup. The CLI contains the always-compiled internal contracts and exact construction controls but contains no fake implementation, no test factory and no test symbol; its only reachable context construction path is the native factory bound below. The task CLI and context harness must still have zero `System.IO` member references.

## Exact Native/No-Native Compilation Topology

`ProjectContext.cs` has an always-compiled section containing the three marker interfaces, high-level seam, a platform-parameterized loader state machine with a private constructor, coordinator interface, sanitized contracts and parser/projection/prompt logic, with no dependency on `LocalModelProvider` and no P/Invoke declarations. One `#if EAIRA_PROJECT_CONTEXT_NATIVE` region contains only `ProjectContextRequestPreflight`, private nested `ProjectContextLoader.ProjectContextWin32Platform`, its six direct private static P/Invoke declarations and private native structures, its private tokens, `ProjectContextNativeLease`, `ProjectContextLoader.CreateNative` and `ProjectContextRequestCoordinator.CreateNative`. No separate `ProjectContextNative` declaring type exists. One separate `#if EAIRA_PROJECT_CONTEXT_TEST_SEAM` region contains only `ProjectContextLoader.CreateForTests(IProjectContextReadOnlyPlatform)`. Fake platform/token implementations remain solely in `ProjectContextHarness.cs`.

`LocalTaskIntake.cs` retains its legacy constructors and a private context-coordinator constructor in the always-compiled section. One `EAIRA_PROJECT_CONTEXT_NATIVE` region exposes only internal `LocalTaskIntake.CreateNative(ILocalModelProviderFactory)`, which calls the native coordinator factory. One `EAIRA_PROJECT_CONTEXT_TEST_SEAM` region exposes only internal `LocalTaskIntake.CreateForTests(ILocalModelProviderFactory, IProjectContextRequestCoordinator)`. The private constructor is not directly callable outside `LocalTaskIntake`.

The exact compiler-symbol matrix is:

| Output | ProjectContext.cs | LocalTaskIntake.cs | NATIVE | TEST_SEAM | Native rows |
| --- | --- | --- | --- | --- | --- |
| `EAIRA.AgentTask.Cli.exe` | included | included | yes | no | exactly 1 ModuleRef / 6 P/Invokes |
| `EAIRA.ProjectContext.Harness.exe` | included | not included | yes | yes | exactly 1 ModuleRef / 6 P/Invokes |
| `EAIRA.LocalTaskIntake.Harness.exe` | included | included | no | yes | zero |
| `EAIRA.LocalModelProvider.Harness.exe` | included | included | no | no | zero |
| `EAIRA.LoopbackTransport.PolicyHarness.exe` | included | included | no | no | zero |
| `EAIRA.AgentCore.Harness.exe` | not included | not included | no | no | zero |
| each of five service executables | not included | not included | no | no | zero |

The CLI compiles `AgentCore.cs`, provider/intake/local-provider/transport sources, `ProjectContext.cs` and `AgentTaskIntakeHost.cs` with only the native symbol. `AgentTaskIntakeHost.Main` calls `LocalTaskIntake.CreateNative` exactly once; that factory calls `ProjectContextRequestCoordinator.CreateNative` exactly once. The complete CLI MethodDef graph contains no reference to `CreateForTests` and no fake implementation. The context harness compiles `AgentCore.cs`, `ModelProviders.cs`, `LocalModelProvider.cs`, `ProjectContext.cs` and `ProjectContextHarness.cs` with both symbols; its entry point reaches only `ProjectContextLoader.CreateForTests` through the single bound harness helper and never reaches either native factory, either production implementer constructor or a live path. The intake harness compiles the no-native context contract and its own fake coordinator with only the test-seam symbol. The other two intake-dependent harnesses resolve the always-compiled contract but expose neither context factory.

The build script records an exact per-output source/symbol invocation manifest and fails on an extra, missing or differently ordered source or symbol. It binds the CLI production factory caller graph stated above and rejects `CreateForTests` or any fake type in the CLI metadata. It also rejects a native factory reference from a harness test entry point. Existing bans on reflection, dynamic invocation, assembly loading, delegates to construction factories and external plugin activation remain in force.

The existing aggregate functional-source prohibition remains unchanged for every existing source. New `Assert-ProjectContextSourcePolicy` and `Assert-LocalTaskIntakeConditionalPolicy` require exactly one native region and one test-seam region in each applicable file, verify the exact permitted declarations in each region, and reject fake classes in product sources. `DllImport` is permitted only on the six declarations in the native region. Existing shell, Git, process, registry, `System.IO`, network and write-token prohibitions apply to the complete project-context source. `Assert-NoForbiddenBinaryMetadata` gains a `DllImportAttribute` exception only for the two named native outputs and continues checking every other forbidden token; those two outputs then pass `Assert-ProjectContextPInvokePolicy`. Every other output must have zero ModuleRef/P/InvokeImpl rows. No stub/generated source, second context implementation or extra changed path is permitted.

## Exact CLI Seam Reachability Policy

`Assert-ProjectContextSeamPolicy` enumerates every TypeDef, InterfaceImpl, MethodDef, MemberRef and MethodSpec row plus every MethodDef body in each context-bearing output. Type and method identity always includes enclosing type chain, namespace, name, exact signature blob, generic-parameter count and raw flags; simple-name matching is insufficient. It compares the complete named MethodDef set for every controlled constructor, factory and harness helper, so an overload or same-name generic method is an exact-set failure even when the approved row remains present.

The complete production implementer set is:

- `EAIRA.AgentServices.Functional.ProjectContextLoader+ProjectContextWin32Platform` has exact TypeDef flags `NestedPrivate | Sealed | BeforeFieldInit`, direct base `System.Object`, exactly one InterfaceImpl naming only `IProjectContextReadOnlyPlatform`, exactly one instance constructor `.ctor()` with `Assembly | HideBySig | SpecialName | RTSpecialName` (`0x1883`, 6275), zero type initializers and no other constructor;
- `EAIRA.AgentServices.Functional.ProjectContextRequestCoordinator` has exact TypeDef flags `NotPublic | Sealed | BeforeFieldInit`, direct base `System.Object`, exactly one InterfaceImpl naming only `IProjectContextRequestCoordinator`, exactly one instance constructor `.ctor(EAIRA.AgentServices.Functional.ProjectContextLoader)` with `Private | HideBySig | SpecialName | RTSpecialName`, zero type initializers and no other constructor.

The complete test implementer set is:

- `EAIRA.AgentServices.Tests.ProjectContextHarness+FakePlatform`, present only in `EAIRA.ProjectContext.Harness.exe`, has exact `NestedPrivate | Sealed | BeforeFieldInit` flags, direct base `System.Object`, one InterfaceImpl naming only `IProjectContextReadOnlyPlatform`, exactly one parameterless instance constructor with `Assembly | HideBySig | SpecialName | RTSpecialName` (`0x1883`, 6275), and zero type initializers; and
- `EAIRA.AgentServices.Tests.LocalTaskIntakeHarness+FakeCoordinator`, present only in `EAIRA.LocalTaskIntake.Harness.exe`, has the same exact TypeDef flags, base, `Assembly` constructor flags and zero-type-initializer constraints, and one InterfaceImpl naming only `IProjectContextRequestCoordinator`.

All four implementer constructor MethodDefs have exact profile-bound signature blobs and `IL | Managed` implementation flags. The three private nested implementer constructors have exact `Assembly` visibility; only the non-nested production coordinator constructor retains exact `Private` visibility. No implementer may have an overload, additional `.ctor`, `.cctor`, generic parameter, conversion operator, factory-like method or additional interface.

The complete per-output constructor caller multisets are:

| Output | Platform implementer constructor callers | Coordinator implementer constructor callers | Loader injection-ctor callers | Intake context-ctor callers |
| --- | --- | --- | --- | --- |
| `EAIRA.AgentTask.Cli.exe` | `ProjectContextLoader.CreateNative` x1 | `ProjectContextRequestCoordinator.CreateNative` x1 | `ProjectContextLoader.CreateNative` x1 | `LocalTaskIntake.CreateNative` x1 |
| `EAIRA.ProjectContext.Harness.exe` | production: `ProjectContextLoader.CreateNative` x1; fake: `ProjectContextHarness.CreateLoaderForTests` x1 | `ProjectContextRequestCoordinator.CreateNative` x1 | `ProjectContextLoader.CreateNative` x1; `ProjectContextLoader.CreateForTests` x1 | type absent |
| `EAIRA.LocalTaskIntake.Harness.exe` | no implementer | fake: `LocalTaskIntakeHarness.CreateIntakeForTests` x1 | `ProjectContextLoader.CreateForTests` x1 | `LocalTaskIntake.CreateForTests` x1 |
| `EAIRA.LocalModelProvider.Harness.exe` | no implementer | no implementer | no callers | no callers |
| `EAIRA.LoopbackTransport.PolicyHarness.exe` | no implementer | no implementer | no callers | no callers |

`Loader injection-ctor` means exactly `EAIRA.AgentServices.Functional.ProjectContextLoader::.ctor(IProjectContextReadOnlyPlatform)`. `Intake context-ctor` means exactly `EAIRA.AgentServices.Functional.LocalTaskIntake::.ctor(ILocalModelProviderFactory,IProjectContextRequestCoordinator)`. Both are private, have their exact profile-bound signature/flag blobs, and have no other `newobj` caller.

The only possible construction-factory MethodDefs, each non-generic with exact `Assembly` visibility, `Static | HideBySig` flags, return type and parameter sequence, are:

- `ProjectContextLoader CreateNative()` and `ProjectContextLoader CreateForTests(IProjectContextReadOnlyPlatform)` on `EAIRA.AgentServices.Functional.ProjectContextLoader`;
- `IProjectContextRequestCoordinator CreateNative()` on `EAIRA.AgentServices.Functional.ProjectContextRequestCoordinator`; and
- `LocalTaskIntake CreateNative(ILocalModelProviderFactory)` and `LocalTaskIntake CreateForTests(ILocalModelProviderFactory,IProjectContextRequestCoordinator)` on `EAIRA.AgentServices.Functional.LocalTaskIntake`.

Their presence is controlled solely by the exact symbol matrix; each permitted factory has one exact profile-bound signature blob and no overload, generic form, alternate return type or optional/parameter-array form.

The complete per-output construction-factory caller multisets are:

| Output | `ProjectContextLoader.CreateNative` | `ProjectContextLoader.CreateForTests` | `ProjectContextRequestCoordinator.CreateNative` | `LocalTaskIntake.CreateNative` | `LocalTaskIntake.CreateForTests` |
| --- | --- | --- | --- | --- | --- |
| `EAIRA.AgentTask.Cli.exe` | `ProjectContextRequestCoordinator.CreateNative` x1 | absent | `LocalTaskIntake.CreateNative` x1 | `AgentTaskIntakeHost.Main(string[])` x1 | absent |
| `EAIRA.ProjectContext.Harness.exe` | `ProjectContextRequestCoordinator.CreateNative` x1 | `ProjectContextHarness.CreateLoaderForTests` x1 | no callers | type absent | type absent |
| `EAIRA.LocalTaskIntake.Harness.exe` | absent | no callers | absent | absent | `LocalTaskIntakeHarness.CreateIntakeForTests` x1 |
| `EAIRA.LocalModelProvider.Harness.exe` | absent | absent | absent | absent | absent |
| `EAIRA.LoopbackTransport.PolicyHarness.exe` | absent | absent | absent | absent | absent |

The two harness helper identities are exactly `EAIRA.AgentServices.Functional.ProjectContextLoader EAIRA.AgentServices.Tests.ProjectContextHarness::CreateLoaderForTests()` and `EAIRA.AgentServices.Functional.LocalTaskIntake EAIRA.AgentServices.Tests.LocalTaskIntakeHarness::CreateIntakeForTests()`; each is private static, contains exactly one implementer-construction site and one injection-factory call site as listed, has an exact profile-bound signature/flag blob, and has no overload.

Their complete incoming caller multisets are normative:

| Output | Helper | Complete incoming caller multiset |
| --- | --- | --- |
| `EAIRA.ProjectContext.Harness.exe` | `ProjectContextHarness.CreateLoaderForTests()` | `ProjectContextHarness.Main(string[])` x1 |
| `EAIRA.LocalTaskIntake.Harness.exe` | `LocalTaskIntakeHarness.CreateIntakeForTests()` | `LocalTaskIntakeHarness.Main(string[])` x1 |
| every other output | both helpers | both absent |

`Assert-ProjectContextSeamPolicy` compares each helper's complete incoming caller multiset for exact equality, including caller identity, signature and call-site count. Each harness `Main(string[])` invokes its one helper directly once and retains the returned instance for all context cases in that process. No test method, wrapper, dispatcher, lambda-generated method, compiler-generated state machine or other MethodDef may call either helper. The context-harness entry point's transitive call graph may reach `CreateLoaderForTests` directly but must not reach `ProjectContextLoader.CreateNative`, `ProjectContextRequestCoordinator.CreateNative` or either production implementer constructor. The intake-harness entry point may reach `CreateIntakeForTests` directly and then `LocalTaskIntake.CreateForTests`; it cannot reach a native factory because those MethodDefs are absent.

The verifier scans every MethodDef for `newobj`, `call`, `callvirt`, `ldftn`, `ldvirtftn` and `ldtoken` operands targeting any implementer constructor, injection constructor, construction factory or named harness helper. It resolves MethodDef, MemberRef and MethodSpec operands, preserves each caller's full signature and any MethodSpec instantiation signature, and builds every complete signature-qualified callee-to-caller multiset above, including the two helper incoming sets and the transitive entry-point call graph. Controlled targets must resolve to the exact approved MethodDef; a controlled-target MemberRef/MethodSpec, unresolved construction-relevant dispatch, generic controlled method, `calli`, function-pointer/delegate load, non-call token load, extra overload, extra wrapper/helper layer or any extra/missing edge fails closed.

For the CLI and the two context-test harnesses, exactly `EAIRA.ProjectContext.Harness.exe` and `EAIRA.LocalTaskIntake.Harness.exe`, structured TypeRef/MemberRef/MethodDef inspection rejects:

- every namespace equal to or beneath `System.Reflection`, `System.Reflection.Emit`, `System.Linq.Expressions` or `Microsoft.CSharp.RuntimeBinder`;
- `System.Activator` and all of its members;
- `System.Object::GetType`; `System.Type::GetType`, `GetMethod`, `GetMethods`, `GetConstructor`, `GetConstructors`, `GetInterface`, `GetInterfaces` and `InvokeMember`;
- `System.Delegate::CreateDelegate` and `System.Delegate::DynamicInvoke`;
- `System.Runtime.CompilerServices.CallSite` and `CallSiteBinder`;
- `System.Runtime.Serialization.FormatterServices::GetUninitializedObject`; and
- any `Assembly.Load*`, `MethodBase.Invoke`, `ConstructorInfo.Invoke`, dynamic binder, emitted-method, expression-compile or uninitialized-object construction path.

The source policy rejects the corresponding fully qualified and alias/import forms; the metadata policy is controlling and rejects encoded or aliased source forms that still compile to a forbidden reference. Existing code may use ordinary compile-time delegates for provider fakes, but none of those three governed outputs may contain `CreateDelegate`, `DynamicInvoke`, reflection-based construction or a delegate/function-pointer reference to either seam constructor/factory. S3-R09 must replace the existing `exception.GetType().Name` in `AgentTaskIntakeHost.cs` with the fixed `ContractException` literal and replace the test-only occurrence in `LocalTaskIntakeHarness.cs` with a fixed non-reflective sanitized failure literal; the CLI's canonical legacy error JSON and all success output remain byte-exact. This reflection/dynamic ban does not broaden to `EAIRA.AgentCore.Harness.exe`, `EAIRA.LocalModelProvider.Harness.exe`, `EAIRA.LoopbackTransport.PolicyHarness.exe` or any of the five service executables: none exposes a context-construction factory, and their existing independently bound policies remain controlling.

Mandatory negative specimens add, one at a time: a second platform or coordinator implementer; an extra/overloaded constructor or type initializer on either production or fake implementer; direct `newobj` of either production implementer from an unapproved MethodDef; an extra `newobj` caller for either injection constructor; an extra factory overload; a direct factory call from an unapproved caller; a second direct caller of either named harness helper; a wrapper inserted between `Main` and either named helper; a second helper layer that hides direct construction; a helper that indirectly makes the context-harness entry point reach a native factory; a token/fn-pointer load of a constructor/factory/helper; `Activator.CreateInstance`; `Object.GetType` followed by constructor lookup; `ConstructorInfo.Invoke`; Reflection.Emit construction; expression compilation; `Delegate.DynamicInvoke`; a dynamic call site; and `FormatterServices.GetUninitializedObject`.
Each specimen must compile when its referenced framework API is available and then be rejected by `Assert-ProjectContextSeamPolicy`; a specimen compilation failure fails the suite and does not count as a verifier pass.
The R9R3 seam-verifier suite contains exactly 27 isolated, source-substituted specimens: the 24 R9R2 cases plus `EXTRA_NATIVE_LEASE_CONSTRUCTOR`, `EXTRA_NATIVE_LEASE_FACTORY_OVERLOAD`, and `EXTRA_NATIVE_LEASE_CALLER`. A separate native-verifier suite contains exactly 17 cases: seven one-variable constant changes; seven one-variable DllImport attribute changes; `NATIVE_IMPORT_VISIBILITY_INTERNAL`; `EXTRA_NATIVE_IMPORT`; and `EXTRA_NATIVE_CALLER`. Each suite passes only at its exact count when every specimen compiled with exit code 0 and the production verifier rejected it. The manifest records only sanitized `name`, `compileExitCode`, `verifierRejected`, and `outputKind`; specimen binaries remain outside the repository and are never publication inputs.

R9R4 adds exactly one twenty-eighth seam specimen, `NATIVE_LEASE_IDISPOSABLE_INTERFACE_DISPATCH`, which reintroduces `IDisposable` plus an explicit interface implementation forwarding to `Close()`. The specimen must compile and the unchanged production verifier must reject it. The release profile also binds the native lease to zero InterfaceImpl rows and binds its exact TypeDef and `Close()` MethodDef flags; the ordinary CLI and ContextHarness each retain exactly eight approved native caller rows.

R10R2 adds exactly three output-isolation specimens to the same production seam-verifier path, increasing the seam suite from 28 to 31 while retaining 17 native specimens. `DIRECTORY_ENUMERATION_OUTPUT` introduces a compiled `System.IO.Directory.GetFiles` reference; `RAW_CONTENT_OUTPUT` adds raw projection content to `ProjectContextResultMetadata`; and `PER_FILE_DIGEST_OUTPUT` adds a per-file-digest-shaped result field. Every specimen must compile successfully and the production verifier must reject it; a compile failure or accepted specimen fails the suite. The release profile also binds the exact public-output field sets and the canonical MethodDef/IL inventory of every critical serialization and result-propagation path.

## Exact Bundle and Projection Contract

The path IDs, order, byte limits, tags, attribute rejection, ancestor pinning, full-path equality, file identity, same-handle pre/post comparison, one sequential read, strict UTF-8, authority precedence, version checks, list canonicalization, field order, source-qualified labels and digest framing remain fixed. Revision 15 aligns the parser with the controlled artifacts: quoted repository YAML keys are decoded, additional top-level keys remain opaque and unprojected, required-key duplication or absence fails closed, and multi-entry Markdown milestone sections are joined in source order from their non-empty controlled lines. Revision 16 changes no parser or allowlist rule; it adds exact boundary/golden-vector tests and closed output-surface verification. There is no second parser or fallback.

The returned bundle exposes only:

- allowlist ID `EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1`;
- aggregate SHA-256;
- projection byte count and SHA-256;
- in-memory projection string;
- provenance `WORKING_TREE_SNAPSHOT_NO_GIT_PROVENANCE_CLAIM`; and
- classification `UNTRUSTED_DATA_NOT_INSTRUCTIONS`.

## Exact Planning Prompt and Request Preflight

The Planning prompt is UTF-8 without BOM and exactly:

```text
EAIRA_M4_SLICE3_PLANNING_CONTEXT_V1
GOAL=<goal-byte-count>:<exact goal>
PROJECTION=<projection-byte-count>:<exact projection>
```

There is one LF after the domain line and one LF between the goal field and projection label. No byte is appended after the exact projection; the canonical projection itself currently ends in LF. Counts are shortest ASCII decimal UTF-8 byte counts with no leading zero.

Before provider lifecycle start, `LocalModelProvider.BuildCanonicalRequest(AgentRole.Planning, exactPlanningPrompt)` is called for both mock and ollama-local context requests solely as the common 16,384-byte preflight. Its returned bytes are discarded. Ollama-local later rebuilds the same bytes in `Complete`; tests must prove byte equality. Mock performs no transport.

`ProjectContextRequestPreflight.Validate` is the only translation boundary. It calls that static builder with the fixed Planning role inside a `try`; it catches only `LocalProviderException` raised by that call and throws a fresh message-free, inner-exception-free `ProjectContextException`. The context branch invokes it before provider construction and `BeginRequest`. The host catches `ProjectContextException` before `LocalProviderException` and returns `CONTEXT_ERROR/80`. Any `LocalProviderException` after provider construction or lifecycle start retains the existing `LOCAL_PROVIDER_ERROR/79` contract. No change to `LocalModelProvider.cs` is permitted.

## Pipeline Changes

`AgentCore.cs` adds context-specific overloads without changing legacy overload semantics:

- `PlanningAgent.Execute(TaskEnvelope, string exactPlanningPrompt)`;
- `PlanningAgent.ExpectedPayload(TaskEnvelope, IModelProvider, string exactPlanningPrompt)`;
- `ContextPlanningSeal.Create(TaskEnvelope, AgentResult planning, IModelProvider, string exactPlanningPrompt)`;
- `GuardAgent.Execute(TaskEnvelope, AgentResult planning, ContextPlanningSeal, AgentDecision sealedPreauthorization)`;
- `OperationsAgent.Execute(TaskEnvelope, AgentResult planning, AgentResult guard, ContextPlanningSeal)`;
- `VerificationAgent.Execute(TaskEnvelope, AgentResult planning, AgentResult guard, AgentResult operations, ContextPlanningSeal)`;
- `AuditAgent.Execute(TaskEnvelope, IList<AgentResult>, string outcome, ContextPlanningSeal)`;
- `MinimumFunctionalPipeline.Execute(TaskEnvelope, string exactPlanningPrompt, AgentDecision sealedPreauthorization)`;
- `MinimumFunctionalPipeline.ValidateContextSemanticPrefix(TaskEnvelope, IList<AgentResult>, IModelProvider, ContextPlanningSeal)`; and
- `MinimumFunctionalPipeline.ValidateContextChain(TaskEnvelope, IList<AgentResult>, IModelProvider, ContextPlanningSeal)`.

`ContextPlanningSeal` is internal sealed, has a private constructor, and retains only task digest, Planning result digest and provider ID; it has no prompt, projection, content, path or metadata property. Its only factory first performs structural validation, recomputes the exact context Planning payload through the prompt-bearing Planning overload, requires byte equality, and then returns the content-free seal. In context mode that Planning payload contains only the fixed marker `PLAN_CANDIDATE_CONTEXT_REDACTED`, a domain-separated SHA-256 of the provider output, and `STEPS=3`; provider output text is not retained in the result chain. After that factory returns, no downstream method receives `exactPlanningPrompt`.

Each new downstream Agent overload calls `ValidateContextSemanticPrefix`, not the legacy `ValidateSemanticPrefix`. Context validation uses the seal to bind the already-verified Planning result, replays Guard only from `task`, replays Operations only from `guard.ResultDigest`, and replays Verification/Audit only from their existing prior-result/outcome inputs. It never regenerates Planning and never accepts a prompt. The Guard overload also requires both its replayed decision and `sealedPreauthorization` to be identical. The context pipeline is entered only after an Allow preauthorization; any mismatch throws before Operations. `ValidateContextChain` uses the same seal path. Operations continues to call the provider with only `guard.ResultDigest`.

Tests must prove all five legacy methods still route exclusively through legacy validation; all five context methods route exclusively through seal validation; prompt-bearing overloads are referenced only by the context pipeline and seal factory; and raw context/projection/prompt cannot be observed by Guard, Operations, Verification or Audit. An altered seal, Planning result, task, provider ID or preauthorization fails before the next Agent.

## Canonical Result and Failure Contract

Legacy response JSON remains unchanged. A successful context-enabled result appends one `context` object before any existing provider-observations object, in this exact order:

`allowlistId`, `aggregateSha256`, `projectionBytes`, `projectionSha256`, `provenance`, `classification`.

It contains no root, absolute path, raw content, excerpt, per-file count/identity/digest or Planning prompt.

All context acquisition, validation, projection and request-preflight failures return exit code `80` and exactly:

```json
{"schemaVersion":1,"status":"CONTEXT_ERROR","errorType":"ProjectContextException","network":"NONE","writes":"NONE","context":null}
```

A context-enabled preauthorization deny performs a static requested-provider-ID mapping without provider construction: `mock` maps to `mock-v1`, and `ollama-local` maps to `ollama-loopback-v1`. It returns exit code `77` and exactly this field order and JSON shape, with the validated request trace substituted as the JSON-escaped string value and the mapped literal provider ID:

```json
{"schemaVersion":1,"status":"DENIED","provider":"<mock-v1|ollama-loopback-v1>","traceId":"<validated-trace>","outcome":"DENIED","network":"NONE","writes":"NONE","result":null,"context":{"state":"NOT_READ_GUARD_DENY"}}
```

There is no Agent result chain because Planning was not run. No provider observation object is present. Tests require byte equality for both provider selections and prove zero platform-seam calls, provider-factory calls, lifecycle calls, tags calls, chat calls and network calls.

No exception message, Win32 error, root, path, source field, content fragment or per-file evidence may cross the CLI boundary.

## Exact S3-R09 Product Changed-Path Manifest

A future S3-R09 implementation authorization may modify or add exactly these 13 product paths:

1. `apps/agent-services/README.md`;
2. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`;
3. `apps/agent-services/contracts/EAIRA_LOCAL_TASK_INTAKE_V1.md`;
4. `apps/agent-services/contracts/EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1.md`;
5. new `apps/agent-services/contracts/EAIRA_READ_ONLY_PROJECT_CONTEXT_V1.md`;
6. `apps/agent-services/release/gate25-unsigned-release-profile.json`;
7. `apps/agent-services/src/AgentCore.cs`;
8. `apps/agent-services/src/AgentTaskIntakeHost.cs`;
9. `apps/agent-services/src/LocalTaskIntake.cs`;
10. new `apps/agent-services/src/ProjectContext.cs`;
11. `apps/agent-services/tests/AgentCoreHarness.cs`;
12. `apps/agent-services/tests/LocalTaskIntakeHarness.cs`; and
13. new `apps/agent-services/tests/ProjectContextHarness.cs`.

`LocalModelProvider.cs`, `ModelProviders.cs`, `OllamaLoopbackTransport.cs`, all service-host sources, Windows state and every other path are immutable under that future implementation gate.

The release profile and build script retain their current ordered 22 candidate repository inputs and append exactly these ten inputs in this order, producing 32:

1. `apps/agent-services/src/AgentCore.cs`;
2. `apps/agent-services/contracts/EAIRA_READ_ONLY_PROJECT_CONTEXT_V1.md`;
3. `apps/agent-services/src/ProjectContext.cs`;
4. `apps/agent-services/tests/AgentCoreHarness.cs`;
5. `apps/agent-services/tests/ProjectContextHarness.cs`;
6. `docs/project/planning/EAIRA_M4_SLICE3_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md`;
7. `docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_ALLOWLIST.md`;
8. `docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_READINESS_PACKAGE.md`;
9. `docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_THREAT_MODEL.md`; and
10. `docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_3_SCOPE_DECISION.md`.

This exact ordered 32-path set contains all thirteen future product mutation paths: eight were already present in the ordered 22 and the five missing product paths—`AgentCore.cs`, the new context contract, `ProjectContext.cs`, `AgentCoreHarness.cs` and the new context harness—are bound by the appended list. The other five appended entries are the documentary evidence bindings. Candidate-input membership is evidence binding, not permission to mutate an unchanged input.

## Mandatory Tests and Build Evidence

Implementation acceptance requires:

- all existing Slice 1/Slice 2 harness results unchanged for legacy invocation;
- positive mock and fake-ollama context requests with independently recomputed aggregate/projection metadata;
- preauthorization deny proving zero `CreateFileW`, tags and chat calls;
- exact 16,384/16,385 canonical-request boundaries before provider lifecycle;
- all negative and abuse cases in the R4R1 threat model, including every ancestor/final substitution and Cloud Files state;
- proof that context text cannot enter either Guard input, Operations, Verification or Audit;
- exact native ModuleRef/PInvokeImpl and zero-System.IO metadata checks;
- isolated regression specimens for an extra native import, write-capable desired access/share/creation disposition, directory enumeration, raw-content output and per-file digest output;
- two clean byte-identical builds and sanitized manifests/reports; and
- an independent S3-R10 implementation review with P0/P1/P2 counts.

Tests must use fakes or explicitly authorized local fixtures. They may not mutate the EAIRA vault, hydrate OneDrive content, contact an external provider, install a service or alter Windows configuration.

## Stop Conditions

Stop before implementation if independent review finds any ambiguity, if exact PE metadata enforcement cannot distinguish the six approved imports, if the 16,384-byte preflight is not byte-identical to the eventual local chat request, if legacy output changes, if a denied request reads context or calls a provider, or if any additional path/capability is required.

## Current Determination

`S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_COMPLETE_READY_FOR_INDEPENDENT_REVIEW`

Next gate: `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE3_S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_REVIEW`.
