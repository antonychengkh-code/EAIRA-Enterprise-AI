# EAIRA M5 Slice 1 Exact Implementation Design

## Control

- Design ID: `EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_V1`
- Date: `2026-09-12`
- Baseline: `c50ccb8d22926220ac8712aaaa9eaacff1e9de93`
- Selected scope: `M5S1_A_IN_PROCESS_THREE_ROUTE_ORCHESTRATOR`
- Inputs: scope V1, R1, normative R2 overlay, and independent R2 `PASS`
- State: `CANDIDATE_READY_FOR_INDEPENDENT_EXACT_DESIGN_REVIEW`
- Product implementation authority: `NOT_YET_EXERCISED`
- Exact product manifest: ten paths
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_REVIEW`

## 1. Invariants

1. One new console entry point routes exactly task, knowledge and project QA in-process.
2. Invalid and denied requests construct no reader/provider factory.
3. Allowed execution records Planning, Guard, Operations, Verification and Audit; denial records exactly Planning, Guard and Audit.
4. Knowledge makes no provider call. QA preserves tags/chat/tags. Task preserves its selected M4 provider lifecycle.
5. Existing M4 CLIs, output bytes, exit codes and contracts remain unchanged.
6. No write, IPC, shell, child process, dynamic load, credential, listener or external-provider surface is added.
7. The complete operator line is at most 18,431 UTF-8 bytes including LF.
8. Output is assembled and validated in memory, then written once.

## 2. Exact source closure

### 2.1 New `LocalOperator.cs`

Namespace: `EAIRA.AgentServices.Functional`.

Types:

- `LocalOperatorCapability`: `Task=1`, `Knowledge=2`, `ProjectQa=3`.
- `LocalOperatorRequest`: immutable normalized request and exact parser.
- `LocalOperatorRoute`: immutable closed route policy and digest.
- `LocalOperatorAdapterResult`: immutable status/exit/network/payload tuple.
- `ILocalOperatorTaskAdapter`, `ILocalOperatorKnowledgeAdapter`, `ILocalOperatorQaAdapter`.
- `ILocalOperatorAdapterFactory`: creates only the adapter selected after allow.
- `LocalOperatorRunner`: parse, preauthorize, build ownership chain, invoke one adapter, validate, wrap.
- `LocalOperatorResponse`: exact outer serializer and byte-bound validator.
- Native adapters and factory under `EAIRA_LOCAL_OPERATOR_NATIVE`.

The task native adapter lives entirely in this file. It maps the new canonical task form to the already accepted legacy `LocalTaskIntake.Execute` argv order, calls `LocalTaskIntake.CreateNative(new LocalOperatorLocalModelProviderFactory())`, and converts its typed response. It catches only the published task exceptions and produces the R2 crosswalk. It does not call `AgentTaskIntakeHost` and does not copy task policy.

The knowledge native adapter calls `ProjectKnowledgeQuery.CreateNative().Execute(root, query)` and `CanonicalJsonOrThrow`. It does not call `ProjectKnowledgeHost`, enumerate directories or duplicate knowledge parsing.

The QA native adapter calls the reusable `ProjectQaRunner` defined below. It does not duplicate snapshot, prompt, answer or provider validation.

### 2.2 New `LocalOperatorHost.cs`

Namespace: `EAIRA.AgentServices.Functional`.

- Compiled only when `EAIRA_LOCAL_OPERATOR_NATIVE` is defined.
- `Main(string[] args)` constructs `LocalOperatorRunner` with the native adapter factory.
- It receives a complete byte array from the runner, opens stdout only after validation, writes the complete array once, flushes, and returns the response exit code.
- It never writes stderr and never formats exceptions.

### 2.3 `AgentCore.cs` modification

Add `OrchestrationRoleResult` and `OrchestrationChain` without modifying existing M4 classes.

`OrchestrationRoleResult` fields:

- role enum;
- decision enum;
- request digest;
- route digest;
- previous digest;
- depth;
- evidence digest;
- result digest.

Result digest bytes are:

```text
EAIRA_M5_SLICE1_ROLE_RESULT_V1 NUL
Field(role integer)
Field(decision integer)
Field(requestSha256)
Field(routeSha256)
Field(previousResultSha256)
Field(depth decimal)
Field(evidenceSha256)
```

`OrchestrationChain.StartAllowed` produces Planning then Guard(ALLOW). `CompleteAllowed` appends Operations, Verification and Audit. `CompleteDenied` produces Planning, Guard(DENY), Audit and refuses Operations/Verification. It validates role order, depths, previous hashes and evidence hashes on every construction and before serialization.

Role evidence domains:

- Planning: `EAIRA_M5_SLICE1_PLANNING_EVIDENCE_V1` + route digest.
- Guard: `EAIRA_M5_SLICE1_GUARD_EVIDENCE_V1` + request digest + static decision.
- Operations: `EAIRA_M5_SLICE1_OPERATIONS_EVIDENCE_V1` + payload digest + exit decimal + network.
- Verification: `EAIRA_M5_SLICE1_VERIFICATION_EVIDENCE_V1` + payload digest + expected contract.
- Audit: `EAIRA_M5_SLICE1_AUDIT_EVIDENCE_V1` + final status + prior result digest.

All concatenation uses `ContractCodec.Field` and ordinal ASCII constants. Outer `audit.chainSha256` is the Audit result digest.

### 2.4 `ProjectQa.cs` and `ProjectQaHost.cs` modification

Add `ProjectQaRunResult` and `ProjectQaRunner` to `ProjectQa.cs`.

`ProjectQaRunner.Execute` accepts exact argv plus injected snapshot-reader and provider factories. It contains the current `ProjectQaHost.Main` logic and returns:

- exact exit code;
- exact status;
- exact network;
- exact complete legacy line as bytes.

It never writes a channel. Error lines remain byte-for-byte identical to the published contract.

`ProjectQaHost.Main` becomes a compatibility adapter: create native factories, call `ProjectQaRunner.Execute`, write its already-complete line once and return its exit code. Existing Project QA harness golden bytes must remain unchanged.

### 2.5 No-change proof obligations

The compile/source closure must prove no change to:

- `LocalTaskIntake.cs` or `AgentTaskIntakeHost.cs`;
- `ProjectKnowledge.cs` or `ProjectKnowledgeHost.cs`;
- any M4 contract;
- context/native platform semantics;
- local provider/transport semantics.

If compilation proves a change is necessary, implementation stops for manifest-widening review.

## 3. Exact parser

The parser accepts only the six command forms in R1. It first compares `args.Length`, then every flag and fixed value by ordinal equality, then validates trace/input/root through existing primitives. It never normalizes capability or flag case.

Internal mapping:

| Form | Length | Capability | Provider | Root |
|---|---:|---|---|---|
| task mock | 7 | TASK | MOCK | absent |
| task mock context | 9 | TASK | MOCK | present |
| task Ollama | 9 | TASK | OLLAMA_LOOPBACK_V1 | absent |
| task Ollama context | 11 | TASK | OLLAMA_LOOPBACK_V1 | present |
| knowledge | 7 | KNOWLEDGE | NONE | present |
| project QA | 11 | PROJECT_QA | OLLAMA_LOOPBACK_V1 | present |

The length includes the leading capability. After removing the capability, adapters receive only exact legacy-compatible arrays constructed by code; user arrays are never forwarded.

Validation order:

1. null array and closed length/capability check;
2. exact flags/fixed provider/model values;
3. exact trace;
4. input validation through `TaskEnvelope.Create` or `ProjectKnowledgeQuery.NormalizeQueryOrThrowRequest`;
5. lexical root validation without content read;
6. request/root/input digests;
7. static Guard preauthorization;
8. route and adapter selection.

`real`, URI-like providers, alternate models and extra flags fail at step 2 with exit 64.

## 4. Exact request and route digests

Root digest:

```text
SHA256(UTF8("EAIRA_M5_SLICE1_ROOT_V1\0" + Field(root)))
```

Input digest substitutes domain `EAIRA_M5_SLICE1_GOAL_V1`, `EAIRA_M5_SLICE1_QUERY_V1` or `EAIRA_M5_SLICE1_QUESTION_V1`.

Request digest:

```text
SHA256(UTF8("EAIRA_M5_SLICE1_REQUEST_V1\0" +
  Field(capability) + Field(trace) + Field(provider) + Field(model) +
  Field(rootPresent) + Field(rootSha256-or-NONE) +
  Field(inputKind) + Field(inputSha256)))
```

Route digest:

```text
SHA256(UTF8("EAIRA_M5_SLICE1_ROUTE_V1\0" +
  Field(requestSha256) + Field(capability) + Field(contextAllowlist-or-NONE) +
  Field(knowledgeAllowlist-or-NONE) + Field(providerPolicy-or-NONE) +
  Field(network) + Field("NONE") + Field(expectedPayloadContract) +
  Field(allowedRoleSequence) + Field(deniedRoleSequence) + Field(callBudget)))
```

Booleans are uppercase `TRUE`/`FALSE`; enum strings are the exact uppercase contract strings; hashes are uppercase hex. Every digest is recomputed before adapter use and output.

## 5. Guard and adapter factory order

`LocalOperatorRunner` receives an `ILocalOperatorAdapterFactory`, not preconstructed adapters. It performs parse, `TaskEnvelope.Create`, `GuardAgent.ExpectedDecision`, Planning/Guard ownership records and route sealing before calling the selected factory.

On deny:

- no factory method is called;
- Planning/Guard/Audit records are constructed from request/route digests only;
- output is `DENIED`, network `NONE`, null payload and exit 77.

On allow:

- exactly one route-specific factory method is called;
- exactly one adapter is executed;
- adapter output is validated against route policy before Operations/Verification/Audit completion.

The harness uses factory, read, tags and chat counters at every cut-point.

## 6. Adapter result validation

Before a payload may be embedded:

- exit must be 0 and mapped status must be `PASS`;
- network must equal the sealed route's observed class;
- writes is fixed `NONE` by adapter type;
- payload is one JSON object without BOM, CR, LF or trailing bytes;
- UTF-8 is strict and payload byte length is 1 through 16,383;
- first schema/status members match the exact expected M4 contract;
- payload digest is `SHA256(UTF8("EAIRA_M5_SLICE1_PAYLOAD_V1\0") || U32BE(length) || payloadBytes)`;
- route-specific typed invariants and call counters pass.

Failure before a validated success produces a null payload. No M4 error object is embedded.

## 7. Exact outer serializer

The member order and presence/null rules are those in R1 plus normative R2. JSON encoding uses `ContractCodec.Json`; hashes and enums are ASCII. `payload` is inserted only from a strict validated canonical byte array and is not reparsed or reserialized.

The serializer performs:

1. field invariant validation;
2. payload bound and digest validation;
3. ownership chain validation;
4. complete byte-array construction with one LF;
5. strict UTF-8 length check `<= 18431`;
6. return of immutable bytes to host.

Maximum wrapper proof target:

- fixed keys/punctuation/schema/nulls: at most 420 bytes;
- longest status/capability/network/authority/audit outcome: at most 180 bytes;
- trace: at most 34 encoded bytes;
- three quoted hashes: at most 198 bytes;
- audit object and chain hash: at most 132 bytes;
- conservative remaining fixed headroom: 1,084 bytes;
- total wrapper including LF: at most 2,048 bytes.

Implementation harness must calculate the actual maximum from constructed valid field maxima and assert it is `<= 2048`; this design does not rely only on the category estimate.

## 8. Crosswalk and network state

The exact status/exit/payload table is normative R2 section 1.

Network rules:

- invalid/deny: `NONE`;
- knowledge: always `NONE`;
- task mock: always `NONE`;
- task/QA before provider construction: `NONE`;
- task/QA after loopback provider construction where a request may occur: `LOOPBACK_ONLY`;
- provider failure never emits raw endpoint or exception.

`PROVIDER_BLOCKED`/78 is unavailable from the operator contract.

## 9. Harness case families

`LocalOperatorHarness` has one `--self-test` mode and emits only:

```json
{"schema":"EAIRA_LOCAL_OPERATOR_HARNESS_V1","status":"PASS","testsPassed":N,"caseNameSha256":"<HASH>","wrapperMaximumBytes":N,"network":"NONE","writes":"NONE"}
```

Required named case families:

- six canonical forms;
- null/empty/unknown/case-variant capability;
- every missing/extra/duplicate/reordered/cross-route flag;
- invalid trace, input, root, provider and model boundaries;
- static deny for every route with all factory counters zero;
- allowed factory selection exactly once;
- all R2 crosswalk rows;
- allowed five-role and denied three-role golden chains;
- tampered request, route, previous, evidence, payload and audit digests;
- knowledge zero-provider invariant;
- QA exact tags/chat/tags and every failure cut-point;
- task mock/local call-budget preservation;
- prompt/tool/image/thinking/extra-member sentinel isolation;
- sequential TASK→KNOWLEDGE→QA and reverse-order leakage tests;
- zero/16,382/16,383/16,384 payload bytes;
- 18,430/18,431/18,432 complete-line specimens;
- single write, one LF, empty stderr and no partial failure output;
- response file/stdin/env/config strings rejected as literal argv;
- repeated trace proves correlation-only semantics;
- legacy QA runner byte-for-byte golden compatibility.

The case list is ordinal-sorted only for digest construction; execution order is fixed in source and separately recorded. Digest domain is `EAIRA_M5_SLICE1_CASE_NAMES_V1` plus NUL and `ContractCodec.Field` for each name in execution order.

## 10. Build/release changes

The build script adds:

- compilation of `EAIRA.LocalOperator.Harness.exe` with test-seam symbols;
- compilation of `EAIRA.LocalOperator.Cli.exe` with `EAIRA_LOCAL_OPERATOR_NATIVE`, all required read-only native symbols, `System.Net.Http`, and exact `/main:EAIRA.AgentServices.Functional.LocalOperatorHost`;
- both artifacts to clean A/B reproducibility checks;
- harness execution and exact JSON validation;
- static forbidden-token, System.IO member-ref, native caller, seam, loopback and output-isolation checks for the new outputs;
- negative specimens for child process, write, IPC, dynamic load, raw output and unapproved provider metadata;
- release copy of the unsigned operator CLI only, not the harness.

The release profile adds `localOperator` with contract, output names, symbols, limits, route/call policies, source hashes, harness golden values, compiled metadata inventories and release hash. Discovery mode may establish new exact IL/token baselines only from clean A/B byte-identical builds; final mode has no discovery bypass.

Existing profile sections and checks remain mandatory.

## 11. Exact product manifest

1. New `apps/agent-services/src/LocalOperator.cs`
2. New `apps/agent-services/src/LocalOperatorHost.cs`
3. New `apps/agent-services/tests/LocalOperatorHarness.cs`
4. New `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
5. Modify `apps/agent-services/src/AgentCore.cs`
6. Modify `apps/agent-services/src/ProjectQa.cs`
7. Modify `apps/agent-services/src/ProjectQaHost.cs`
8. Modify `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`
9. Modify `apps/agent-services/release/gate25-unsigned-release-profile.json`
10. Modify `apps/agent-services/README.md`

No other product path is permitted. Planning/review/evidence/status documents are separately tracked lifecycle paths. Excluded untracked areas and `.obsidian` remain untouched.

## 12. Implementation and verification order

1. Add pure ownership/request/response primitives and offline harness seams.
2. Extract QA runner and prove legacy QA golden compatibility.
3. Add in-process adapters and host.
4. Add complete abuse harness.
5. Add contract and README.
6. Extend build/profile in discovery mode.
7. Produce clean out-of-tree A/B artifacts and derive exact metadata baselines.
8. Pin baselines; rerun final mode without discovery bypass.
9. Obtain independent implementation/abuse review.
10. Run separately authorized live loopback validation.

Any failed invariant stops without staging. Any required eleventh product path stops for explicit manifest widening.

## 13. Exact design review questions

The independent reviewer must verify:

- source closure and ten-path feasibility;
- parser length/order correctness;
- Guard/factory order;
- role chain domains/order and denial behavior;
- typed adapter reuse without policy copying;
- QA refactor compatibility;
- crosswalk/network/error atomicity;
- payload and wrapper arithmetic;
- harness coverage/count/digest integrity;
- build/profile discovery cannot bypass final verification;
- no excluded path or system surface is introduced.

## 14. Completion state

This exact design is ready for independent review only. It does not grant implementation, staging, commit or push authority.
