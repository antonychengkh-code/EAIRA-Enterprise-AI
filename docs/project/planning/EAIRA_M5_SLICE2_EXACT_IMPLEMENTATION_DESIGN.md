# EAIRA M5 Slice 2 Exact Implementation Design

## 1. Control

| Field | Value |
| --- | --- |
| Design ID | `EAIRA_M5_SLICE2_EXACT_IMPLEMENTATION_DESIGN_V1R3R3R2` |
| Date | `2026-09-12` |
| Baseline | `b32e947892b6b0ffd97411910f704394b6b805f2` |
| Scope | `M5S2_A_BOUNDED_OPERATOR_HEALTH_AND_CAPABILITY_STATUS` |
| Scope package | `EAIRA_M5_SLICE2_SCOPE_PACKAGE_V1R1` |
| State | `READY_FOR_INDEPENDENT_EXACT_DESIGN_R3R3R2_REVIEW` |
| Next Gate | `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE2_EXACT_IMPLEMENTATION_DESIGN_R3R3R2_REVIEW` |

This design is normative for Slice 2. Scope-package R1 canonical bytes and
digests are incorporated without change.

## 2. Exact changed-path manifest

The implementation and evidence candidate contains exactly these nine text
paths in ordinal repository-relative order:

1. `apps/agent-services/README.md`
2. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`
3. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
4. `apps/agent-services/release/gate25-unsigned-release-profile.json`
5. `apps/agent-services/src/LocalOperator.cs`
6. `apps/agent-services/tests/LocalOperatorHarness.cs`
7. `docs/project/planning/EAIRA_M5_SLICE2_BOUNDED_OPERATOR_HEALTH_AND_CAPABILITY_STATUS_SCOPE_PACKAGE.md`
8. `docs/project/planning/EAIRA_M5_SLICE2_EXACT_IMPLEMENTATION_DESIGN.md`
9. `docs/project/strategy/EAIRA_M5_SLICE2_SCOPE_DECISION.md`

`AgentCore.cs`, `LocalOperatorHost.cs`, all reader/provider sources, repository
root `tests/`, `docs/integrations/`, `scripts/claude_api.py` and `.obsidian/`
must remain byte-identical to baseline or untracked and unpublished as applicable.

## 3. Parser and request model

`LocalOperatorCapability` adds `Health = 4`. `CapabilityName` maps it only to
`HEALTH`; existing values and names are unchanged.

`LocalOperatorRequest.Parse` accepts exactly:

```text
health --trace <TRACE>
```

It requires exactly three argv entries and exact ordinal tokens. Trace uses the
existing `TaskEnvelope` validation: exactly 32 uppercase hexadecimal characters.
The request constructor receives provider `NONE`, model `NONE`, null root,
input kind `HEALTH`, and fixed internal input `COMPILED CONTRACT STATUS`.
No user value becomes the health payload.

The existing request digest algorithm and field order are unchanged. Input digest
domain is the constructor-derived `EAIRA_M5_SLICE1_HEALTH_V1`; request domain is
`EAIRA_M5_SLICE1_REQUEST_V1`. For trace
`0123456789ABCDEF0123456789ABCDEF`, request SHA-256 must be
`0E10A550738D8618EFB0C845E4E1C6357F11C64258BE78993E64791DC0456990`.

Missing, duplicate, reordered, additional, lowercase or alternate flags and any
root/provider/model/value/response-file/stdin/environment/config token fail as
the existing `INVALID_REQUEST`/64 wrapper before a factory or payload exists.

## 4. Route model

`LocalOperatorRoute.Create` handles `Health` before all existing branches with:

| Field | Exact value |
| --- | --- |
| capability | `HEALTH` |
| context policy | `NONE` |
| knowledge policy | `NONE` |
| execution policy | `EAIRA_STATIC_OPERATOR_HEALTH_V1` |
| network | `NONE` |
| authority | `OBSERVATIONAL_NOT_AUTHORITY` |
| payload contract | `EAIRA_OPERATOR_HEALTH_V1` |
| call budget | `MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0` |

The existing route digest domain and exact field order are unchanged. Fixed-trace
route SHA-256 is
`613DCE7408D3B68CD51A2E1C01A51A0BA20E20A84B2BE20438319D102446B429`.

## 5. Guard and execution branch

`LocalOperatorRunner.Execute` retains this ordering:

1. parse request;
2. create sealed route;
3. evaluate `GuardAgent.ExpectedDecision(request.Task)`;
4. emit the existing three-role denial on deny;
5. only after allow, branch on `Health`;
6. obtain the compile-time canonical health payload constant;
7. recompute its framed payload digest;
8. compare exact payload bytes/digest and route invariants;
9. build and revalidate the existing five-role success chain; and
10. build the existing outer wrapper in memory and write it once through the
    unchanged host.

The Health branch appears before `factory.CreateTask`, `CreateKnowledge` or
`CreateProjectQa`. It never calls `ILocalOperatorAdapterFactory` or creates an
adapter. The factory interface and native factory implementation do not change.
The allowed branch is isolated in the exact private instance method
`LocalOperatorRunner.ExecuteHealthAllowed(LocalOperatorRequest, LocalOperatorRoute)`;
this method cannot receive a factory, adapter, provider or runtime-observation
object. `Execute` invokes it only after Guard returns `Allow`.

The native runner stores no Guard delegate and `Execute` directly calls
`GuardAgent.ExpectedDecision(request.Task)`. Only under
`EAIRA_LOCAL_OPERATOR_TEST_SEAM`, conditional source adds a
`LocalOperatorGuardEvaluator testGuard` field plus an internal `CreateForTests`
factory. The harness build selects `testGuard(request.Task)` only when that field
is non-null; otherwise it calls `GuardAgent.ExpectedDecision` directly. The
delegate type, field, alternate construction path and callvirt are all absent
from the native CLI metadata and IL. The harness uses
an evaluator returning `Deny` to execute the public Health grammar through the
real parse, route and denial-wrapper path. It must observe exit 77, the exact
three-role denial chain, null payload and zero adapter-factory calls. The
process-scoped attempt delta described below must also remain zero. This is case
`HEALTH_DENY_THREE_ROLES_ZERO_FACTORIES`.

A new internal static `LocalOperatorHealth` in `LocalOperator.cs` owns one
`internal const string CanonicalPayload`. Its validation requires exact ordinal
equality with that constant, exact route values, payload byte count 366 and
payload SHA-256
`9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181`.
No property, collection, reflection, serialization library, runtime data or
dynamic construction is used to form the payload.

`LocalOperatorResponse.HasExpectedPayloadPrefix` adds one exact-equality Health
case. Existing three contract checks remain byte-for-byte unchanged.

## 6. Canonical payload and wrapper

The exact 366-byte payload is:

```json
{"schema":"EAIRA_OPERATOR_HEALTH_V1","status":"POLICY_READY","observationScope":"COMPILED_CONTRACT_ONLY","operatorSchema":"EAIRA_LOCAL_OPERATOR_V1","capabilities":["TASK","KNOWLEDGE","PROJECT_QA","HEALTH"],"guardPosture":"REQUIRED_BEFORE_EFFECT","network":"NONE","reads":"NONE","writes":"NONE","providerConstruction":"NONE","authority":"OBSERVATIONAL_NOT_AUTHORITY"}
```

For trace `0123456789ABCDEF0123456789ABCDEF`, exact values are:

- request SHA-256: `0E10A550738D8618EFB0C845E4E1C6357F11C64258BE78993E64791DC0456990`;
- route SHA-256: `613DCE7408D3B68CD51A2E1C01A51A0BA20E20A84B2BE20438319D102446B429`;
- payload SHA-256: `9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181`;
- Audit chain SHA-256: `228427F0DFB1B1592AC7912F68F94E183C741D2C62A58B7939FC02226534DE5F`;
- full line bytes including LF: `927`; and
- full line SHA-256: `8E7B9415938850843E23E933A82B6FCB07244AD8814706BB998C4C11D9D4D91A`.

The complete line is the exact scope-package R1 golden; no whitespace, CR,
stderr or second write is permitted. Existing global payload/wrapper/line maxima
remain `16383 / 587 / 16970`; the 927-byte Health line fits without widening.

## 7. Harness design

The first 96 case names, order and behavior remain unchanged. Append exactly:

1. `HEALTH_CANONICAL_REQUEST`
2. `HEALTH_ROUTE_EXACT`
3. `HEALTH_PAYLOAD_GOLDEN`
4. `HEALTH_WRAPPER_GOLDEN`
5. `HEALTH_ZERO_FACTORIES`
6. `HEALTH_DENY_THREE_ROLES_ZERO_FACTORIES`
7. `HEALTH_ALLOW_FIVE_ROLES`
8. `HEALTH_CROSS_TRACE_PAYLOAD_STABLE`
9. `HEALTH_CROSS_TRACE_WRAPPER_DISTINCT`
10. `HEALTH_INVALID_MISSING_TRACE`
11. `HEALTH_INVALID_TRACE_LOWER`
12. `HEALTH_INVALID_TRACE_SHORT`
13. `HEALTH_INVALID_TRACE_LONG`
14. `HEALTH_INVALID_TRACE_NONHEX`
15. `HEALTH_INVALID_EXTRA_ARG`
16. `HEALTH_INVALID_DUPLICATE_FLAG`
17. `HEALTH_INVALID_REORDERED_FLAG`
18. `HEALTH_INVALID_RESPONSE_FILE`
19. `HEALTH_INVALID_ROOT_FLAG`
20. `HEALTH_INVALID_PROVIDER_FLAG`
21. `HEALTH_OUTPUT_TAMPER_REJECT`
22. `HEALTH_ROUTE_TAMPER_REJECT`
23. `HEALTH_LEGACY_SEQUENCE_COMPATIBILITY`

Total tests are exactly 119. The full ordered list framed under
`EAIRA_M5_SLICE2_CASE_NAMES_V1`, using one actual U+0000 domain separator and
`ContractCodec.Field` for each name with no trailing byte, is 3,095 UTF-8 bytes
with SHA-256
`198B2B892C9E6516B50B2C2CAF86AABA058B4D8B0D335AD445DC8685230F8A86`.
The harness separately recomputes the first 96 names under the unchanged Slice 1
domain and requires 2,409 bytes and
`0AAF52EE6A087B487B6497676F48BA7AD0D36CB987C149CC1BADAD9CA5D2FE68`.

`HEALTH_ZERO_FACTORIES` uses a poison factory whose three methods each increment
a shared factory counter and then throw. Valid Health must succeed with that
counter at zero. The Guard-denial case uses the same poison factory and must also
leave it at zero. This harness counter is not presented as the native network
monitor.

`LocalOperator.cs` adds one process-static `LocalOperatorConnectAttemptMonitor`.
`Record(string channel)` uses `Interlocked.Increment`; `Snapshot()` uses
`Interlocked.CompareExchange(ref count,0,0)`. The two actual Local Operator
network entry points, `LocalOperatorCompatibleLoopbackTransport.GetTags` and
`SendChat`, call `Record("TAGS")` and `Record("CHAT")` respectively before calling
the inner transport. Exact IL checks require both calls and prohibit any other
network-capable Local Operator path. Direct uninstrumented socket/HTTP entry is
therefore rejected, not silently uncounted.

The exact ordered entrypoint list is:

1. `EAIRA.AgentServices.Functional.LocalOperatorCompatibleLoopbackTransport::GetTags(System.Threading.CancellationToken)`;
2. `EAIRA.AgentServices.Functional.LocalOperatorCompatibleLoopbackTransport::SendChat(System.Byte[],System.Threading.CancellationToken)`.

For each entrypoint, the verifier emits one row
`INSTRUMENT|<entrypoint>|<record-offset-8HEX>|<inner-offset-8HEX>|<record-target>|<inner-target>|DOMINATES`.
The exact record target is
`EAIRA.AgentServices.Functional.LocalOperatorConnectAttemptMonitor::Record(System.String)`.
The exact inner targets, in entrypoint order, are
`EAIRA.AgentServices.Functional.OllamaLoopbackTransport::GetTags(System.Threading.CancellationToken)`
and
`EAIRA.AgentServices.Functional.OllamaLoopbackTransport::SendChat(System.Byte[],System.Threading.CancellationToken)`.
Each entrypoint must contain exactly one call to its record target and exactly one
call to its inner target; record offset must be lower when they share a block,
otherwise the record block must dominate the inner block. The two rows remain in
the fixed entrypoint order, are UTF-8 LF-joined without terminal LF, and form
profile key `healthConnectAttemptMonitor.instrumentation: {count:2,sha256:<DISCOVERY_HASH>}`.
Discovery A/B rows and hash must be identical. Discovery exposes
`instrumentationIlProfileMatch=null`; final requires the rows to match that exact
profile baseline and exposes `true`. Any additional or missing entrypoint,
network-capable call, Record call or inner call fails closed.
Both entrypoint methods must have zero exception-handler clauses. This makes
normal CFG dominance complete for their instrumentation ordering; adding catch,
filter, fault or finally is a fail-closed profile mismatch.

At entry to `Execute`, immediately after request parsing, the runner captures
`attemptsBefore`. On both Health allow and Health deny completion, it captures
`attemptsAfter` and requires `attemptsAfter-attemptsBefore == 0`; overflow,
decrease or a nonzero delta fails closed. Under the test-seam symbol only,
`ResetForTests` uses `Interlocked.Exchange` and `RecordForTests` calls the same
production `Record` method. `HEALTH_ZERO_FACTORIES` first resets, records one
positive control and requires delta 1, then resets and runs Health, requiring
delta 0. The Guard-denial case repeats the zero-delta assertion. Thus the monitor
is live, process-scoped and records attempts at the actual sanctioned network
boundaries; it does not poll connection state and cannot miss a short attempt.
The native one-shot candidate can emit the canonical PASS line only after its
same-process zero-delta check passes. This runtime monitor remains supplemental
to the static Health-only closure and global metadata deny lists.

Health tamper cases call the sealed response boundary with an altered payload,
digest or route and require fail-closed rejection/no raw payload emission. Legacy
sequence compatibility executes task, knowledge, project-QA and health in both
orders and requires exactly one factory call per legacy route and zero for Health.

## 8. Build/verifier changes

`Invoke-Gate25UnsignedRelease.ps1` changes only its Local Operator section:

- expected harness count becomes 119;
- append the exact 23 names and use the Slice 2 full-list framing domain;
- independently retain the Slice 1 96-name prefix count/framing/hash assertion;
- manifest records both legacy-prefix and full-list evidence;
- run native `health --trace 0123456789ABCDEF0123456789ABCDEF`;
- require exit 0, stderr 0, stdout 927 bytes and stdout SHA-256
  `8E7B9415938850843E23E933A82B6FCB07244AD8814706BB998C4C11D9D4D91A`;
- require parsed capability `HEALTH`, network/writes `NONE`, observational
  authority, fixed payload schema/status/scope, four ordered capabilities,
  fixed payload/request/route/audit digests and no unexpected fields;
- record a `health` channel next to existing invalid/denied/mock channels;
- preserve every existing M4/Slice 1 test, specimen and policy;
- require no new P/Invoke, ModuleRef, System.Net/System.Net.Http member reference,
  dynamic-load, process, environment, registry, filesystem or IPC member beyond
  the exact independently calibrated pre-existing CLI inventory; and
- extract `LocalOperatorRunner.Execute` dispatch IL plus the complete transitive
  same-module closure rooted at `ExecuteHealthAllowed`; emit ordinally sorted,
  token-normalized method and call-edge rows; reject any factory, adapter,
  provider, transport, HTTP, socket, filesystem, environment, registry, process,
  service, IPC, clock or randomness match in the allowed closure; and
- final evidence remains unavailable until the profile is independently reviewed
  and supplied by exact SHA-256.

The targeted IL serializer consumes the decoded ECMA-335 instruction stream, not
raw method-body bytes. Names use
`<namespace>.<declaring-type>::<method>(<parameter-type>,...)` with nested types
joined by `+`, generic arity retained, return type omitted, no spaces and empty
parentheses for zero parameters. Type names use metadata full names; arrays append
`[]`, by-ref appends `&`, pointers append `*`, generic parameters are `!n`/`!!n`,
and constructed generics are `Type<arg,...>`.

Each decoded instruction becomes exactly one ASCII row:

`IL|<method>|<offset-8HEX>|<opcode-lowercase>|<operand-kind>|<operand-value>`

Operand kinds and values are exhaustive: `none|-`; `i1|<signed-decimal>`;
`i4|<signed-decimal>`; `i8|<signed-decimal>`; `r4|<8 uppercase IEEE754 hex>`;
`r8|<16 uppercase IEEE754 hex>`; `var|<unsigned-decimal>`;
`branch|<absolute-target-offset-8HEX>`;
`switch|<comma-separated absolute-target-offset-8HEX in encoded order>`;
`string|<UTF8-byte-count-decimal>:<SHA256-uppercase>`;
`method|<normalized-method-name>`; `field|<normalized-declaring-type>::<name>:<normalized-field-type>`;
`type|<normalized-type-name>`; `signature|<normalized-callsite>`; and
`token|<resolved method/field/type name using the preceding grammar>`. A
standalone-signature operand is decoded structurally as
`callsite|<calling-convention>|<generic-arity>|<return-type>|<parameter-types>`;
`calling-convention` is the base token `DEFAULT`, `VARARG`, `C`, `STDCALL`,
`THISCALL` or `FASTCALL`, followed when present by `+INSTANCE` and then
`+EXPLICITTHIS` in that fixed order. `generic-arity` is unsigned decimal and is 0
when absent. A pinned local is encoded `PINNED:<normalized-type>` and every other
local is `VALUE:<normalized-type>`; the locals list retains metadata order.
it never uses raw signature bytes or coded indices. `MethodSpec` resolves to the
generic method name followed by `<normalized-type-args>` in encoded argument
order. Any unresolved token or unsupported operand kind fails closed. Short and long branch
opcodes remain their decoded lowercase opcode names; prefixes are independent IL
rows. Metadata tokens, RVA, MVID, PE offsets and file paths never enter rows.

Every method begins with exactly these structural rows before IL rows:

- `BODY|<method>|<tiny-or-fat>|<maxstack-decimal>|<initlocals-TRUE-or-FALSE>`;
- `LOCALS|<method>|<count>|<comma-separated pinned-prefix-plus-normalized-types>`.

A method with no locals uses `LOCALS|<method>|0|-`. Exception clauses follow all
IL rows and are encoded as
`EH|<method>|<ordinal>|<catch-or-finally-or-fault-or-filter>|<try-start-8HEX>|<try-end-exclusive-8HEX>|<handler-start-8HEX>|<handler-end-exclusive-8HEX>|<catch-type-or-filter-start-8HEX-or->`.
Clauses are sorted by the complete tuple after method name and then assigned the
zero-based decimal ordinal. Catch types use normalized type names. Filter clauses
use the absolute filter start; other non-catch clauses use `-`.

For any method, its sole canonical `detailRows` stream is exactly: BODY row first,
LOCALS row second, IL rows in ascending numeric offset third, and EH rows in their
defined sorted order last. No other row participates. The method detail digest is
SHA-256 over this UTF-8 LF-joined stream without terminal LF.

`dispatchRows` are that complete `detailRows` stream for
`EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])`.
The dispatch summary `{count,sha256}` uses the complete stream's row count and
digest exactly as defined above.
For the allowed closure, start at
`EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteHealthAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)`;
decode every reachable same-module `call`, `callvirt`, `newobj`, `ldftn` and
`ldvirtftn` target exactly once, including the root. When any instruction references a same-module type through a method, constructor,
field, type operand, `newobj`, `call`, `callvirt`, `ldftn` or `ldvirtftn`, that
type's `.cctor` is added when present, regardless of static/instance use or the
`beforefieldinit` flag; all declaring/enclosing types are treated the same way.
The module `.cctor` is also added if present. Generic `MethodSpec` targets are traversed via
their resolved generic MethodDef while preserving type arguments in call rows.
`methodRows` are
`METHOD|<normalized-name>|<sha256-of-that-method's-complete-detailRows>` sorted by
normalized name. `callRows` are
`CALL|<caller>|<offset-8HEX>|<opcode-lowercase>|<normalized-callee>` for every
closure call instruction, sorted ordinally by the complete row. External targets
appear in call rows but are not traversed. Duplicate targets remain distinct by
caller/offset. Method and call summary hashes use UTF-8 LF-joined rows with no
terminal LF. Empty sets use count 0 and SHA-256 of zero bytes. Discovery A and B
must have byte-identical row arrays, counts and hashes.
The manifest additionally emits `methodDetails` as an array ordered by normalized
method name; each item is exactly `{method:string,detailRows:string[]}`. Its rows
must recompute the corresponding `methodRows` digest. Thus BODY, LOCALS, IL and
EH bytes are both visible and transitively bound by the closure summary.

Forbidden matching is ordinal and runs against every normalized call target,
field target and type operand in the allowed closure. It rejects exact interface
names `EAIRA.AgentServices.Functional.ILocalOperatorAdapterFactory` and
`EAIRA.AgentServices.Functional.ILocalOperatorAdapter`; any EAIRA type containing
`Adapter`, `Factory`, `Provider`, `Transport` or `Ollama`; namespace prefixes
`System.Net`, `System.IO`, `System.Environment`, `System.Diagnostics`,
`Microsoft.Win32`, `System.ServiceProcess`, `System.IO.Pipes` and
`System.Reflection`; exact type names `System.DateTime`, `System.DateTimeOffset`,
`System.Random`, `System.Environment`, `System.Diagnostics.Process`,
`System.Diagnostics.ProcessStartInfo`, `Microsoft.Win32.Registry` and
`Microsoft.Win32.RegistryKey`; type-name prefixes
`System.Security.Cryptography.RandomNumberGenerator` and
`System.Security.Cryptography.RNGCryptoServiceProvider`; exact type names
`System.Guid`, `System.Threading.Timer`, `System.Timers.Timer` and
`System.Diagnostics.Stopwatch`; exact method pairs
`System.Threading.Thread::Sleep` and `System.Threading.Tasks.Task::Delay`; and
member names containing ordinal `Clock`, `Random`,
`Socket`, `Connect`, `Send`, `Receive`, `Open`, `Read`, `Write`, `Start` or
`CreateProcess`, or equal to `NewGuid`, `get_UtcNow`, `get_Now`, `get_TickCount`,
`GetTimestamp`, `Delay` or `Sleep`. Only the exact
`LocalOperatorConnectAttemptMonitor.Snapshot`
call is exempt from the `Connect` name match. The verifier separately requires
that no closure MethodDef has `PinvokeImpl`, no closure call resolves to a
ModuleRef, and no closure type/member row matches a P/Invoke implementation.

The dispatch control-flow graph splits basic blocks at method entry, every branch
target, the instruction after every conditional/unconditional branch, switch,
return or throw, and every EH try/handler/filter boundary. Normal successors are
fall-through, branch and switch targets; leave targets are ordinary successors;
return/throw have none. The ordinary analysis root is method entry; each catch,
filter, fault or finally handler entry is a separate analysis root, and a filter
start is also a separate root. A block is classified as an EH block when its start
offset lies in that handler's `[handlerStart,handlerEnd)` or filter's
`[filterStart,handlerStart)` interval; all other blocks are ordinary. Every
ordinary block must be reachable from method entry by normal successors. Every EH
block must be reachable from its own handler/filter root by normal successors.
A block in neither reachable set, or an EH block reachable only from the wrong EH
root, fails closed. A `leave` from an EH block may target an ordinary block but is
not used to make an otherwise unreachable ordinary block acceptable.

Dominators for a selected root are initialized with root={root}, every other block
in that root's reachable set=the complete reachable set, then intersect
predecessor sets within that set to a fixed point. The Guard block is the unique block calling
`GuardAgent.ExpectedDecision`; it must dominate the unique block that calls
`ExecuteHealthAllowed`. The Health selector is the unique block loading
`LocalOperatorRequest.Capability`, comparing with integer enum value 4, and
branching to the Health successor. That selector must be dominated by the Guard
block. From the Health successor, graph reachability must include exactly one
`ExecuteHealthAllowed` call followed by return and must include none of
`CreateTask`, `CreateKnowledge` or `CreateProjectQa`. The non-Health successor
must not reach `ExecuteHealthAllowed`. For the monitor entrypoints, the same CFG
construction/dominator fixed point proves the `INSTRUMENT` rows above.

The native `Execute` method may retain the existing parse try/catch, but the Guard
call block, Health selector block, Health-successor blocks, the
`ExecuteHealthAllowed` call and its following return must lie outside every try,
handler, filter, fault and finally interval. No EH clause may have an applicable
protected or handler range intersecting that region. `Execute` may contain no
finally or fault clause. These facts are derived from the exact EH rows before
normal-edge reachability is accepted. Consequently no exceptional/finally edge
can execute a factory or network action from the Health path; any future wrapping
of the Health region in EH fails closed rather than being ignored.
Before final mode, the independently reviewed values are copied to the exact
profile keys `healthControlFlow.dispatchIl`,
`healthControlFlow.allowedClosureMethods`, and
`healthControlFlow.allowedClosureCalls`, each `{count,sha256}`, plus
`healthConnectAttemptMonitor.instrumentation` as defined above. The manifest also
carries the full `dispatchRows`, `methodRows` and `callRows`, plus
`forbiddenMatchCount`, `factoryReferenceCount`, `providerReferenceCount`,
`networkReferenceCount` and `connectAttemptDelta`; every count
must be 0.
Discovery is the only mode in which profile comparison may be null. Final mode
requires exact A/B equality and exact profile equality.

The verifier never queries Ollama, its endpoint, status or logs. The Health
runtime proof is the combination of native golden output, zero poison-factory
calls, positive-controlled process monitor with zero Health delta, exact
dispatch/allowed-closure evidence, and unchanged strict
metadata/PInvoke/native policies.

## 9. Release profile changes

`localOperator.revision` becomes `2`; ordered capabilities append `HEALTH`.
The following exact keys are added:

- `healthContract: EAIRA_OPERATOR_HEALTH_V1`
- `healthObservationScope: COMPILED_CONTRACT_ONLY`
- `healthAuthority: OBSERVATIONAL_NOT_AUTHORITY`
- `healthPayloadBytes: 366`
- `healthPayloadSha256: 9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181`
- `healthGoldenStdoutBytes: 927`
- `healthGoldenStdoutSha256: 8E7B9415938850843E23E933A82B6FCB07244AD8814706BB998C4C11D9D4D91A`
- `legacyHarnessTests: 96`
- `legacyHarnessCanonicalNameBytes: 2409`
- `legacyHarnessCaseNameSha256: 0AAF52EE6A087B487B6497676F48BA7AD0D36CB987C149CC1BADAD9CA5D2FE68`

Existing `expectedHarness*` fields become `119`, `3095`, and
`198B2B892C9E6516B50B2C2CAF86AABA058B4D8B0D335AD445DC8685230F8A86`.
`channelMatrix` appends exact `health` evidence. `boundRepositoryInputs` appends
the three Slice 2 decision/scope/design paths after all Slice 1 design paths and
before product paths, and binds all 31 inputs. The exact ordered list is:

1. `docs/project/milestones/EAIRA_M5_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW_PROJECT_CHARTER.md`
2. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE.md`
3. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R1.md`
4. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R2.md`
5. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R3.md`
6. `docs/project/strategy/EAIRA_M5_SLICE1_SCOPE_DECISION.md`
7. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN.md`
8. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R2.md`
9. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3.md`
10. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R1.md`
11. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R2.md`
12. `docs/project/strategy/EAIRA_M5_SLICE2_SCOPE_DECISION.md`
13. `docs/project/planning/EAIRA_M5_SLICE2_BOUNDED_OPERATOR_HEALTH_AND_CAPABILITY_STATUS_SCOPE_PACKAGE.md`
14. `docs/project/planning/EAIRA_M5_SLICE2_EXACT_IMPLEMENTATION_DESIGN.md`
15. `apps/agent-services/README.md`
16. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
17. `apps/agent-services/src/ContractCodec.cs`
18. `apps/agent-services/src/AgentCore.cs`
19. `apps/agent-services/src/ModelProviders.cs`
20. `apps/agent-services/src/LocalTaskIntake.cs`
21. `apps/agent-services/src/LocalModelProvider.cs`
22. `apps/agent-services/src/OllamaLoopbackTransport.cs`
23. `apps/agent-services/src/ProjectReadOnlyPlatform.cs`
24. `apps/agent-services/src/ProjectContext.cs`
25. `apps/agent-services/src/ProjectKnowledge.cs`
26. `apps/agent-services/src/ProjectQa.cs`
27. `apps/agent-services/src/ProjectQaHost.cs`
28. `apps/agent-services/src/LocalOperator.cs`
29. `apps/agent-services/src/LocalOperatorHost.cs`
30. `apps/agent-services/tests/LocalOperatorHarness.cs`
31. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`

Discovery may bypass only new expected
hash/inventory/channel comparisons; it cannot produce final or release output.

CLI and harness metadata inventories are calibrated only from two clean discovery
builds. Both builds must be byte-identical before those exact inventories may be
adopted. A separate independent profile review must verify the source diff,
discovery manifest, binary hashes, 119 cases, legacy prefix, channel golden,
metadata/call graph and all retained controls before final mode.

## 10. Negative specimens and non-regression

All six existing Local Operator negative specimens remain in their exact order.
Append these seven stable IDs in this exact order:

1. `HEALTH_FILESYSTEM_ENVIRONMENT_PROBE`;
2. `HEALTH_DIRECT_SOCKET_CONSTRUCTION`;
3. `HEALTH_ADAPTER_FACTORY_INVOCATION`;
4. `HEALTH_RUNTIME_OBSERVATION`;
5. `HEALTH_ADDITIONAL_PAYLOAD_MEMBER`;
6. `HEALTH_OBSERVATION_AUTHORITY_MUTATION`; and
7. `HEALTH_PROVIDER_MODEL_ROOT_ACCEPTANCE`.

Each specimen is produced from the candidate `LocalOperator.cs` by an exact
ordered replacement plan. The verifier requires every old anchor to occur exactly
once and applies each plan step exactly once in listed order, writes
the replacement to an out-of-tree specimen source, removes only the original
`LocalOperator.cs` argument, compiles with the otherwise identical CLI arguments,
and applies the same metadata, native and targeted Health control-flow checks.
For specimens 1–4 the old anchor is the exact source line
`string payload = LocalOperatorHealth.CanonicalPayload;`. The replacement is the
following injected statement followed by LF and the unchanged old anchor:

1. `if (Environment.GetEnvironmentVariable("EAIRA_HEALTH_PROBE") != null || System.IO.File.Exists("EAIRA_HEALTH_PROBE")) throw new LocalOperatorException();`
2. `using (System.Net.Sockets.TcpClient forbidden = new System.Net.Sockets.TcpClient()) { if (forbidden.Connected) throw new LocalOperatorException(); }`
3. `if (factory.CreateTask() != null) throw new LocalOperatorException();`
4. `long forbiddenTicks = DateTime.UtcNow.Ticks; int forbiddenRandom = new Random(1).Next(); object forbiddenProcess = new System.Diagnostics.ProcessStartInfo("cmd.exe"); object forbiddenRegistry = Microsoft.Win32.Registry.CurrentUser; if (forbiddenTicks == forbiddenRandom && forbiddenProcess == forbiddenRegistry) throw new LocalOperatorException();`

Their rejection rule must be `FORBIDDEN_HEALTH_CLOSURE_MEMBER`.

The fifth old anchor is the exact C# constant-source substring
`\"providerConstruction\":\"NONE\",\"authority\":\"OBSERVATIONAL_NOT_AUTHORITY\"}`
and its replacement is
`\"providerConstruction\":\"NONE\",\"extra\":\"FORBIDDEN\",\"authority\":\"OBSERVATIONAL_NOT_AUTHORITY\"}`;
native Health execution must differ from the golden
payload/wrapper and be rejected as `HEALTH_GOLDEN_MISMATCH`. The sixth performs
an ordered two-step plan. Step 1 replaces exact substring
`\"observationScope\":\"COMPILED_CONTRACT_ONLY\",\"operatorSchema\"` with
`\"observationScope\":\"RUNTIME_OBSERVED\",\"operatorSchema\"`. Step 2 replaces
exact substring
`\"writes\":\"NONE\",\"providerConstruction\":\"NONE\",\"authority\":\"OBSERVATIONAL_NOT_AUTHORITY\"}`
with
`\"writes\":\"NONE\",\"providerConstruction\":\"NONE\",\"authority\":\"AUTHORITATIVE\"}`.
It must be rejected by both
payload golden and route/authority policy.
The seventh inserts one exact parser
branch before the unique exact source anchor:

```csharp
if (args[0] == "knowledge" && args.Length == 7 && args[1] == "--root" && args[3] == "--trace" && args[5] == "--query")
```

Its literal replacement bytes, encoded as UTF-8 without BOM and using the
candidate file's LF line ending, are:

```csharp
if (args[0] == "health" && args.Length == 9 && args[1] == "--trace" && args[3] == "--provider" && args[4] == "ollama-local" && args[5] == "--model" && args[6] == "qwen3:4b" && args[7] == "--root")
    return new LocalOperatorRequest(LocalOperatorCapability.Health, args[2], "OLLAMA_LOOPBACK_V1", "qwen3:4b", args[8], "HEALTH", "COMPILED CONTRACT STATUS");
if (args[0] == "knowledge" && args.Length == 7 && args[1] == "--root" && args[3] == "--trace" && args[5] == "--query")
```

The inserted branch accepts only nine argv tokens in this order:
`health --trace <TRACE> --provider ollama-local --model qwen3:4b --root C:\\EAIRA`;
the specimen verifier invokes that exact argv and rejects unless it remains exit
64 with null capability/payload and zero factories. A replacement count other
than the stated count is itself fail-closed.

Manifest specimen rows are exactly
`{id,mutationKind,compileExitCode,rejected,rejectionRule}` in this deterministic
mapping and order:

| ID | mutationKind | rejectionRule |
| --- | --- | --- |
| `CHILD_PROCESS` | `LEGACY_ADDITIONAL_SOURCE` | `LEGACY_POLICY_REJECTION` |
| `WRITE_REFERENCE` | `LEGACY_ADDITIONAL_SOURCE` | `LEGACY_POLICY_REJECTION` |
| `IPC_REFERENCE` | `LEGACY_ADDITIONAL_SOURCE` | `LEGACY_POLICY_REJECTION` |
| `DYNAMIC_LOAD` | `LEGACY_ADDITIONAL_SOURCE` | `LEGACY_POLICY_REJECTION` |
| `RAW_OUTPUT` | `LEGACY_ADDITIONAL_SOURCE` | `LEGACY_POLICY_REJECTION` |
| `UNAPPROVED_PROVIDER_METADATA` | `LEGACY_ADDITIONAL_SOURCE` | `LEGACY_POLICY_REJECTION` |
| `HEALTH_FILESYSTEM_ENVIRONMENT_PROBE` | `HEALTH_SOURCE_REPLACEMENT_1` | `FORBIDDEN_HEALTH_CLOSURE_MEMBER` |
| `HEALTH_DIRECT_SOCKET_CONSTRUCTION` | `HEALTH_SOURCE_REPLACEMENT_1` | `FORBIDDEN_HEALTH_CLOSURE_MEMBER` |
| `HEALTH_ADAPTER_FACTORY_INVOCATION` | `HEALTH_SOURCE_REPLACEMENT_1` | `FORBIDDEN_HEALTH_CLOSURE_MEMBER` |
| `HEALTH_RUNTIME_OBSERVATION` | `HEALTH_SOURCE_REPLACEMENT_1` | `FORBIDDEN_HEALTH_CLOSURE_MEMBER` |
| `HEALTH_ADDITIONAL_PAYLOAD_MEMBER` | `HEALTH_SOURCE_REPLACEMENT_1` | `HEALTH_GOLDEN_MISMATCH` |
| `HEALTH_OBSERVATION_AUTHORITY_MUTATION` | `HEALTH_SOURCE_REPLACEMENT_2_ORDERED` | `HEALTH_GOLDEN_MISMATCH` |
| `HEALTH_PROVIDER_MODEL_ROOT_ACCEPTANCE` | `HEALTH_SOURCE_REPLACEMENT_1` | `HEALTH_ALTERNATE_GRAMMAR_ACCEPTED` |

For legacy specimens, any existing underlying rejection is normalized to the
stated legacy rule only after the verifier confirms rejection. For new specimens,
the stated rule is the first and only accepted outcome; a different rejection
reason fails the specimen. In all rows,
all compile exits are 0 and all `rejected` values are true. No existing specimen
is removed or weakened.

## 11. Exact Slice 2 evidence identity and schema

Top-level manifest identity is normative:

- discovery classification: `M5_SLICE2_OPERATOR_HEALTH_DISCOVERY`;
- final classification: `M5_SLICE2_OPERATOR_HEALTH_UNSIGNED_CANDIDATE`;
- passing status in either mode: `M5_SLICE2_UNSIGNED_TECHNICAL_CHECKS_PASS`;
- any failed control: `FAIL_CLOSED`;
- discovery requires `finalEvidence=false`, no `unsigned-release` directory and
  an empty `releaseOutputs` array;
- final requires every discovery switch false, exact non-null profile SHA-256,
  `finalEvidence=true`, and normal unsigned release outputs.

`manifest.localOperator` adds these exact objects and types:

- `revision` integer `2`;
- `legacyHarness` object `{testsPassed:int,caseNameFramedBytes:int,caseNameSha256:string}`;
- `fullHarness` object with the same three fields;
- `healthChannel` object `{exitCode:int,stderrBytes:int,stdoutBytes:int,stdoutSha256:string,payloadBytes:int,payloadSha256:string,requestSha256:string,routeSha256:string,auditSha256:string,capability:string,network:string,writes:string,authority:string}`;
- `healthGuardDenial` object `{exitCode:int,roles:int,payloadNull:bool,factoryCalls:int,connectAttemptDelta:int}`;
- `healthConnectAttemptMonitor` object `{positiveControlBefore:int,positiveControlAfter:int,positiveControlDelta:int,healthBefore:int,healthAfter:int,healthDelta:int,denialBefore:int,denialAfter:int,denialDelta:int,instrumentedEntryPoints:string[],instrumentationRows:string[],instrumentation:{count:int,sha256:string},instrumentationIlProfileMatch:bool|null}`; its entrypoint array is the exact two-string ordered list above;
- `healthControlFlow` object `{dispatchMethod:string,allowedRoot:string,dispatchRows:string[],methodDetails:object[],methodRows:string[],callRows:string[],dispatchIl:{count:int,sha256:string},allowedClosureMethods:{count:int,sha256:string},allowedClosureCalls:{count:int,sha256:string},forbiddenMatchCount:int,factoryReferenceCount:int,providerReferenceCount:int,networkReferenceCount:int,connectAttemptDelta:int,stableAcrossBuilds:bool,profileMatch:bool|null,discoveryBypass:bool}`;
- `negativeSpecimens` array of the exact row schema above and
  `negativeSpecimensPass` boolean.

The profile stores the three `{count,sha256}` control-flow baselines plus the one
monitor instrumentation `{count,sha256}` baseline; the
manifest stores both rows and summaries. In discovery,
`profileMatch=null`/`discoveryBypass=true`. In final,
`profileMatch=true`/`discoveryBypass=false`. Missing, additional, reordered or
wrongly typed properties fail closed.

## 12. Evidence sequence

1. Implement only the nine paths.
2. Run `-LocalOperatorDiscovery` to a new out-of-tree directory; no final output.
3. Require two clean byte-identical discovery builds and all 119 plus retained
   suites/specimens.
4. Update only the exact profile baselines produced by discovery.
5. Independently review design conformance and profile calibration.
6. Compute the release-profile SHA-256 externally.
7. Run normal final mode with that exact SHA to a fresh out-of-tree directory.
8. Require `finalEvidence=true`, every discovery flag false, two byte-identical
   builds, profile-bound true, all retained controls true and no signed output.
9. Independently review implementation and sealed evidence.
10. Native validation runs only Health; it performs no provider observation.
11. Continue exact staging, staged review, commit, post-commit, normal push,
    post-push, controlled-state synchronization and final verification Gates.

## 13. Stop conditions

R3R3R2 resolves independent Gate 6/R1/R2/R3R1/R3R2/R3R3R1 findings without widening the nine-path manifest,
runtime authority, provider boundary or release lifecycle. Control-flow counts and
digests are deliberately produced only by two clean post-implementation discovery
builds because they bind compiler-emitted IL. They are not guessed pre-build;
their exact adoption into the profile is a separate independently reviewed
calibration Gate before any final evidence can exist.

Stop on any extra changed path, P0/P1, altered legacy case, profile bypass,
non-identical build, unexpected member/PInvoke/native edge, factory/connect
attempt delta, output mismatch, provider observation, repository output, signed
binary, credential, Windows mutation, or force-push requirement. P2 findings may
proceed only when independently shown not to weaken evidence or safety.
