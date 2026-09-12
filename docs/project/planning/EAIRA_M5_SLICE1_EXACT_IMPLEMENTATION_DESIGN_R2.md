# EAIRA M5 Slice 1 Exact Implementation Design R2

## Control

- Design ID: `EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_V1R2`
- Date: `2026-09-12`
- Baseline: `c50ccb8d22926220ac8712aaaa9eaacff1e9de93`
- Selected scope: `M5S1_A_IN_PROCESS_THREE_ROUTE_ORCHESTRATOR`
- Base design: `EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_V1`
- Scope overlays: R2 status crosswalk and R3 exact wrapper bound
- Prior design verdict: `FAIL/CANNOT_CLOSE`; P0 `0`, P1 `7`, P2 `0`
- State: `R2_READY_FOR_INDEPENDENT_EXACT_DESIGN_REVIEW`
- Product implementation authority: `NOT_GRANTED_BY_THIS_DOCUMENT`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R2_REVIEW`

This R2 is the normative exact-design overlay. The V1 design remains applicable only where R2 does not replace it. R2 closes all seven P1 findings without widening the selected ten-path product manifest.

## 1. Complete orchestration state machine

### 1.1 Exact enums

`OrchestrationRole`: `Planning=1`, `Guard=2`, `Operations=3`, `Verification=4`, `Audit=5`.

`OrchestrationDecision`: `Candidate=1`, `Allow=2`, `Deny=3`, `Completed=4`, `Verified=5`, `Failed=6`, `Recorded=7`.

### 1.2 Exact terminal paths

| Terminal class | Exact role/decision sequence | Outer statuses |
|---|---|---|
| Invalid before sealed route | no role chain; audit null | `INVALID_REQUEST` |
| Static denial | `Planning/Candidate`, `Guard/Deny`, `Audit/Recorded` | `DENIED` |
| Allowed success | `Planning/Candidate`, `Guard/Allow`, `Operations/Completed`, `Verification/Verified`, `Audit/Recorded` | `PASS` |
| Operation failure | `Planning/Candidate`, `Guard/Allow`, `Operations/Failed`, `Audit/Recorded` | `PROVIDER_ERROR`, `CONTEXT_ERROR`, `KNOWLEDGE_ERROR`, `QA_VALIDATION_ERROR` when thrown during the adapter operation |
| Verification failure | `Planning/Candidate`, `Guard/Allow`, `Operations/Completed`, `Verification/Failed`, `Audit/Recorded` | `QA_VALIDATION_ERROR`, `OUTPUT_ERROR` |
| Orchestration failure | independently rebuilt `Planning/Candidate`, `Guard/Allow`, `Audit/Recorded` emergency chain | `ORCHESTRATION_ERROR` |

Operations and Verification never execute on denial. Verification never executes after an operation failure. Audit is mandatory after every sealed route, including every non-invalid error.

`BuildEmergencyAllowedAudit` accepts only a validated request digest, validated route digest and the already replayed static `Allow`. It constructs a new three-record chain using the same Planning and Guard evidence rules plus Audit status `ORCHESTRATION_ERROR`. It cannot accept adapter data or a prior corrupted result. Failure to build this fixed chain emits no output and exits 83; the implementation must prove this branch unreachable for validated 64-hex inputs.

## 2. Byte-exact digest framing

All framing is a .NET `String` encoded once with strict UTF-8 and hashed with SHA-256. `NUL` is the single U+0000 character. `Field(x)` is exactly `x.Length.ToString(InvariantCulture) + ":" + x`, where length is UTF-16 code units. Hashes are uppercase 64-hex.

### 2.1 Root and input

```text
ROOT = SHA256_UTF8("EAIRA_M5_SLICE1_ROOT_V1" + NUL + Field(root))
INPUT = SHA256_UTF8(domain + NUL + Field(input))
```

Input domain is exactly one of `EAIRA_M5_SLICE1_GOAL_V1`, `EAIRA_M5_SLICE1_QUERY_V1`, `EAIRA_M5_SLICE1_QUESTION_V1`.

### 2.2 Request

```text
SHA256_UTF8("EAIRA_M5_SLICE1_REQUEST_V1" + NUL +
 Field(capability) + Field(traceId) + Field(provider) + Field(model) +
 Field(rootPresent) + Field(rootSha256OrNONE) +
 Field(inputKind) + Field(inputSha256))
```

Exact values:

- capability: `TASK`, `KNOWLEDGE`, `PROJECT_QA`;
- provider: `MOCK`, `OLLAMA_LOOPBACK_V1`, `NONE`;
- model: `qwen3:4b`, `NONE`;
- rootPresent: `TRUE`, `FALSE`;
- inputKind: `GOAL`, `QUERY`, `QUESTION`.

### 2.3 Route policy values

| Route | Context allowlist | Knowledge allowlist | Provider policy | Expected payload contract | Call budget |
|---|---|---|---|---|---|
| task mock no context | `NONE` | `NONE` | `EAIRA_DETERMINISTIC_MOCK_V1` | `EAIRA_LOCAL_TASK_INTAKE_V1` | `MODEL_COMPLETE=2;TAGS=0;CHAT=0` |
| task mock context | `EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1` | `NONE` | `EAIRA_DETERMINISTIC_MOCK_V1` | `EAIRA_LOCAL_TASK_INTAKE_V1` | `MODEL_COMPLETE=2;TAGS=0;CHAT=0` |
| task Ollama no context | `NONE` | `NONE` | `EAIRA_LOCAL_MODEL_PROVIDER_V1` | `EAIRA_LOCAL_TASK_INTAKE_V1` | `MODEL_COMPLETE=2;TAGS=2;CHAT=2` |
| task Ollama context | `EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1` | `NONE` | `EAIRA_LOCAL_MODEL_PROVIDER_V1` | `EAIRA_LOCAL_TASK_INTAKE_V1` | `MODEL_COMPLETE=2;TAGS=2;CHAT=2` |
| knowledge | `NONE` | `EAIRA_M4_SLICE4_KNOWLEDGE_SEVEN_FILE_ALLOWLIST_V1` | `NONE` | `EAIRA_PROJECT_KNOWLEDGE_QUERY_V1` | `MODEL_COMPLETE=0;TAGS=0;CHAT=0` |
| project QA | `EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1` | `EAIRA_M4_SLICE4_KNOWLEDGE_SEVEN_FILE_ALLOWLIST_V1` | `EAIRA_BOUNDED_LOCAL_PROJECT_QA_V1` | `EAIRA_PROJECT_QA_V1` | `MODEL_COMPLETE=0;TAGS=2;CHAT=1` |

Allowed sequence string: `PLANNING_CANDIDATE>GUARD_ALLOW>OPERATIONS_COMPLETED>VERIFICATION_VERIFIED>AUDIT_RECORDED`.

Denied sequence string: `PLANNING_CANDIDATE>GUARD_DENY>AUDIT_RECORDED`.

Network is exact `NONE` or `LOOPBACK_ONLY`; writes is exact `NONE`.

Route digest:

```text
SHA256_UTF8("EAIRA_M5_SLICE1_ROUTE_V1" + NUL +
 Field(requestSha256) + Field(capability) + Field(contextAllowlist) +
 Field(knowledgeAllowlist) + Field(providerPolicy) + Field(network) +
 Field("NONE") + Field(expectedPayloadContract) +
 Field(allowedSequence) + Field(deniedSequence) + Field(callBudget))
```

### 2.4 Role evidence and result

Evidence digest is:

```text
SHA256_UTF8(domain + NUL + Field(requestSha256) + Field(routeSha256) +
 Field(previousResultSha256) + Field(statusOrDecision) + Field(subjectSha256OrNONE))
```

Domains and last two fields:

- Planning: domain `EAIRA_M5_SLICE1_PLANNING_EVIDENCE_V1`; status `CANDIDATE`; subject route digest.
- Guard: `EAIRA_M5_SLICE1_GUARD_EVIDENCE_V1`; `ALLOW` or `DENY`; subject request digest.
- Operations success: `EAIRA_M5_SLICE1_OPERATIONS_EVIDENCE_V1`; `COMPLETED`; subject payload digest.
- Operations failure: same domain; exact outer error status; subject `NONE`.
- Verification success: `EAIRA_M5_SLICE1_VERIFICATION_EVIDENCE_V1`; `VERIFIED`; subject payload digest.
- Verification failure: same domain; exact outer error status; subject payload digest or `NONE` when no valid payload digest exists.
- Audit: `EAIRA_M5_SLICE1_AUDIT_EVIDENCE_V1`; exact outer terminal status; subject prior result digest.

Role result digest:

```text
SHA256_UTF8("EAIRA_M5_SLICE1_ROLE_RESULT_V1" + NUL +
 Field(roleInteger) + Field(decisionInteger) + Field(requestSha256) +
 Field(routeSha256) + Field(previousResultSha256) +
 Field(depthDecimal) + Field(evidenceSha256))
```

Planning previous digest is `ContractCodec.ZeroHash`; every later record uses the immediately prior result digest. Depth starts at `0` and increments by one. Audit `chainSha256` is the final Audit result digest.

Payload digest is byte-framed, not String-framed:

```text
SHA256(UTF8("EAIRA_M5_SLICE1_PAYLOAD_V1") || 0x00 || U32BE(payloadByteLength) || payloadBytes)
```

## 3. Exact QA runner compatibility closure

### 3.1 Types

Add to `ProjectQa.cs`:

```text
IProjectQaSnapshotReaderFactory.Create() -> ProjectQaSnapshotReader
ProjectQaRunResult(
  int ExitCode,
  string Status,
  string Network,
  byte[] CompleteLegacyLine,
  string CanonicalSuccessObjectOrNull,
  int TagsCalls,
  int ChatCalls,
  bool PreflightDigestValidated,
  bool PostflightDigestValidated,
  string ContextAggregateSha256OrNull,
  string ContextProjectionSha256OrNull,
  string KnowledgeResultSetSha256OrNull,
  string PromptSha256OrNull,
  string AnswerSha256OrNull,
  int CitationCount)
```

Arrays are cloned on construction/access. Success requires non-null object, exact complete line `UTF8(object + LF)`, exit 0, status `PROJECT_QA_OK`, network `LOOPBACK_ONLY`, tags 2, chat 1, both digest flags true, five valid hashes and citation count 0..8. Error requires null success object and hashes, citation count 0, exact published error line, and counters matching the reached cut-point.

`ProjectQaRunner.Execute(args, snapshotFactory, providerFactory)` owns all current host logic. Exact order:

1. parse request;
2. create `TaskEnvelope` and static Guard decision;
3. on deny return fixed DENIED line without calling either factory;
4. call snapshot factory once, reader once;
5. build prompt/body;
6. call provider factory once;
7. execute once; the provider performs tags/chat/tags;
8. decode/validate answer and build success;
9. capture sanitized typed observations;
10. dispose provider, swallowing disposal failure exactly as the legacy host does.

Exception mapping is unchanged:

- parse/task construction/knowledge request exception: `INVALID_REQUEST`/64/NONE;
- static deny: `DENIED`/77/NONE;
- `ProjectQaContextException`: `CONTEXT_ERROR`/80/NONE;
- `ProjectQaKnowledgeException`: `KNOWLEDGE_ERROR`/81/NONE;
- `ProjectQaException` before provider create: `PROJECT_QA_ERROR`/82/NONE;
- `ProjectQaException` after provider create: `PROJECT_QA_ERROR`/82/LOOPBACK_ONLY;
- any other exception after provider create: `LOCAL_PROVIDER_ERROR`/79/LOOPBACK_ONLY;
- any other exception before provider create: current outer handler classification, fixed by golden legacy tests.

`ProjectQaHost.Main` only calls the runner with native factories, writes `CompleteLegacyLine` once and returns `ExitCode`. Golden tests assert every existing invalid, deny and success line byte-for-byte, exit code, stderr emptiness, and provider counter. No payload JSON is reparsed: the operator receives `CanonicalSuccessObjectOrNull` plus independently captured typed invariants and validates both against the runner's construction invariants.

## 4. Exact wrapper enumeration and runtime bound

Normative scope R3 is adopted:

| Valid shape | Wrapper bytes including LF |
|---|---:|
| Task PASS, LOOPBACK_ONLY, task authority | `587` |
| Project-QA PASS, LOOPBACK_ONLY, QA authority | `570` |
| Knowledge PASS, NONE, knowledge authority | `563` |
| Maximum error shape | `559` |

The implementation stores these four constants and constructs valid maximum-field specimens. For each, it calculates `UTF8(completeLine).Length - UTF8(payload).Length` and requires exact equality. No unexplained headroom participates in runtime authority.

- Payload max: `16,383` bytes.
- Canonical wrapper max: `587` bytes.
- Complete line max: `16,970` bytes.
- `16,969` and `16,970` are accepted; `16,971` is rejected atomically as `OUTPUT_ERROR`/84.
- A separate design assertion rejects any wrapper over `2,048`, but 2,048 is not a runtime allowance.

## 5. Canonical 72-case harness manifest

Execution order and digest order are identical: the following listed order. No sorting occurs.

1. `CANON_TASK_MOCK`
2. `CANON_TASK_MOCK_CONTEXT`
3. `CANON_TASK_OLLAMA`
4. `CANON_TASK_OLLAMA_CONTEXT`
5. `CANON_KNOWLEDGE`
6. `CANON_PROJECT_QA`
7. `INVALID_NULL_ARGV`
8. `INVALID_EMPTY_ARGV`
9. `INVALID_UNKNOWN_CAPABILITY`
10. `INVALID_CAPABILITY_CASE`
11. `INVALID_MISSING_FLAG`
12. `INVALID_EXTRA_FLAG`
13. `INVALID_DUPLICATE_FLAG`
14. `INVALID_REORDERED_FLAG`
15. `INVALID_CROSS_ROUTE_FLAG`
16. `INVALID_RESPONSE_FILE`
17. `INVALID_PROVIDER_REAL`
18. `INVALID_PROVIDER_URI`
19. `INVALID_MODEL_CASE`
20. `INVALID_TRACE_LENGTH`
21. `INVALID_TRACE_LOWER`
22. `INVALID_GOAL_EMPTY`
23. `INVALID_QUERY_EMPTY`
24. `INVALID_QUESTION_EMPTY`
25. `INVALID_ROOT_LEXICAL`
26. `DENY_TASK_ZERO_FACTORIES`
27. `DENY_KNOWLEDGE_ZERO_FACTORIES`
28. `DENY_PROJECT_QA_ZERO_FACTORIES`
29. `ALLOW_TASK_FACTORY_ONCE`
30. `ALLOW_KNOWLEDGE_FACTORY_ONCE`
31. `ALLOW_PROJECT_QA_FACTORY_ONCE`
32. `CHAIN_ALLOW_FIVE_ROLES`
33. `CHAIN_DENY_THREE_ROLES`
34. `CHAIN_DENY_NO_OPERATIONS`
35. `CHAIN_DENY_NO_VERIFICATION`
36. `TAMPER_REQUEST_DIGEST`
37. `TAMPER_ROUTE_DIGEST`
38. `TAMPER_PREVIOUS_DIGEST`
39. `TAMPER_EVIDENCE_DIGEST`
40. `TAMPER_PAYLOAD_DIGEST`
41. `TAMPER_AUDIT_DIGEST`
42. `KNOWLEDGE_ZERO_PROVIDER`
43. `QA_TAGS_CHAT_TAGS_EXACT`
44. `QA_FAILURE_PRE_TAGS`
45. `QA_FAILURE_CHAT`
46. `QA_FAILURE_POST_TAGS`
47. `TASK_MOCK_CALL_BUDGET`
48. `TASK_OLLAMA_CALL_BUDGET`
49. `SENTINEL_RAW_ROOT`
50. `SENTINEL_RAW_INPUT`
51. `SENTINEL_RAW_CONTENT`
52. `SENTINEL_RAW_PROMPT`
53. `SENTINEL_REQUEST_BODY`
54. `SENTINEL_PROVIDER_RESPONSE`
55. `SENTINEL_PER_FILE_DIGEST`
56. `PROVIDER_TOOL_CALL`
57. `PROVIDER_IMAGE`
58. `PROVIDER_THINKING`
59. `PROVIDER_UNKNOWN_MEMBER`
60. `SEQUENCE_TASK_KNOWLEDGE_QA`
61. `SEQUENCE_QA_KNOWLEDGE_TASK`
62. `PAYLOAD_16382`
63. `PAYLOAD_16383`
64. `PAYLOAD_16384_REJECT`
65. `LINE_16969`
66. `LINE_16970`
67. `LINE_16971_REJECT`
68. `CHANNEL_SINGLE_WRITE_LF`
69. `CHANNEL_EMPTY_STDERR`
70. `CHANNEL_NO_PARTIAL_FAILURE`
71. `REPLAY_TRACE_CORRELATION_ONLY`
72. `LEGACY_QA_COMPATIBILITY`

Digest construction is exact:

```text
SHA256_UTF8("EAIRA_M5_SLICE1_CASE_NAMES_V1" + NUL + Field(case1) + ... + Field(case72))
```

- Expected count: `72`.
- Canonical framed bytes: `1,743`.
- Expected SHA-256: `3D87F0232652339F8F776BBD6BBF153B954D559932A1F4E0943536E6256B8D34`.

Abuse mapping:

- routing/parameter smuggling: 7–19;
- input/path boundaries: 20–25;
- authorization/read-before-allow: 26–31;
- role/confused-deputy/tamper: 32–41;
- provider budget/failure: 42–48;
- data exposure/prompt injection/provider output: 49–59;
- cross-route isolation: 60–61;
- payload/output atomicity: 62–70;
- replay claim: 71;
- legacy regression: 72 plus the complete unchanged M4 harness suite.

The build verifier has the same exact ordered names and independently recomputes count, framed-byte length and digest from harness-emitted case names; a count-only pass is prohibited.

## 6. Exact compiler argv and source order

Both outputs use this fixed common prefix, in order:

```text
/nologo /noconfig /target:exe /platform:x64 /optimize+ /debug- /checked+
/highentropyva+ /warn:4 /warnaserror+ /nostdlib+
```

Outside `DevelopmentProbe`, append `/deterministic+` then `/pathmap:<componentRoot>=/_/EAIRA/apps/agent-services` immediately after `/out` and before source paths, matching the current script convention.

### 6.1 Harness

OutputKind: `LocalOperatorHarness`.

```text
/define:EAIRA_PROJECT_CONTEXT_TEST_SEAM,EAIRA_PROJECT_KNOWLEDGE_TEST_SEAM,EAIRA_PROJECT_QA_TEST_SEAM,EAIRA_LOCAL_OPERATOR_TEST_SEAM
/reference:<refs>\mscorlib.dll
/reference:<refs>\System.dll
/main:EAIRA.AgentServices.Functional.LocalOperatorHarness
/out:<buildRoot>\EAIRA.LocalOperator.Harness.exe
```

Then exact source order:

1. `src/ContractCodec.cs`
2. `src/AgentCore.cs`
3. `src/ModelProviders.cs`
4. `src/LocalTaskIntake.cs`
5. `src/LocalModelProvider.cs`
6. `src/ProjectReadOnlyPlatform.cs`
7. `src/ProjectContext.cs`
8. `src/ProjectKnowledge.cs`
9. `src/ProjectQa.cs`
10. `src/LocalOperator.cs`
11. `tests/LocalOperatorHarness.cs`

### 6.2 CLI

OutputKind: `LocalOperatorCli`.

```text
/define:EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_CONTEXT_NATIVE,EAIRA_PROJECT_KNOWLEDGE_NATIVE,EAIRA_PROJECT_QA_NATIVE,EAIRA_LOCAL_OPERATOR_NATIVE
/reference:<refs>\mscorlib.dll
/reference:<refs>\System.dll
/reference:<refs>\System.Net.Http.dll
/main:EAIRA.AgentServices.Functional.LocalOperatorHost
/out:<buildRoot>\EAIRA.LocalOperator.Cli.exe
```

Then exact source order:

1. `src/ContractCodec.cs`
2. `src/AgentCore.cs`
3. `src/ModelProviders.cs`
4. `src/LocalTaskIntake.cs`
5. `src/LocalModelProvider.cs`
6. `src/OllamaLoopbackTransport.cs`
7. `src/ProjectReadOnlyPlatform.cs`
8. `src/ProjectContext.cs`
9. `src/ProjectKnowledge.cs`
10. `src/ProjectQa.cs`
11. `src/LocalOperator.cs`
12. `src/LocalOperatorHost.cs`

The legacy QA CLI compile continues to include `ProjectQaHost.cs`, proving the refactor there independently.

### 6.3 Exact stdout-only System.IO allowance

Only `LocalOperatorHost.cs` may import `System.IO`. Static verification requires exactly one `using System.IO;`, one `Console.OpenStandardOutput()` call and one `Stream.Write(byte[],0,length)` call. No `Flush`, `Dispose`, file/path/directory API or other `System.IO` member is permitted in the two operator outputs.

Compiled `LocalOperatorCli` member-reference allowance is exactly:

- `System.Console::OpenStandardOutput()`;
- `System.IO.Stream::Write(System.Byte[],System.Int32,System.Int32)`.

`LocalOperatorHarness` has no System.IO allowance. Existing native P/Invoke and loopback metadata must match the union of the already pinned Task/QA read-only and loopback allowlists under distinct OutputKinds; no new module, endpoint or native entry point is allowed.

## 7. Exact release-profile subtree and bound inputs

Add top-level `localOperator` with these members in exact order:

```text
contract, revision, output, outputHarness, nativeSymbols, testSeamSymbols,
maximumPayloadBytes, maximumWrapperBytes, maximumStdoutBytes,
capabilities, statusExitMap, frameworkReferences, sourceOrderCli,
sourceOrderHarness, expectedHarnessTests, expectedHarnessCanonicalNameBytes,
expectedHarnessCaseNameSha256, boundRepositoryInputs,
cliMetadataInventory, harnessMetadataInventory, nativeCallerInventory,
loopbackMetadataAllowlist, channelMatrix
```

Fixed scalar values:

- contract `EAIRA_LOCAL_OPERATOR_V1`, revision `1`;
- output `EAIRA.LocalOperator.Cli.exe`;
- harness `EAIRA.LocalOperator.Harness.exe`;
- native symbols and test symbols exactly as section 6;
- limits `16383`, `587`, `16970`;
- capabilities exactly `[TASK, KNOWLEDGE, PROJECT_QA]`;
- status/exit pairs exactly R2 crosswalk outer statuses;
- framework references exactly mscorlib, System, System.Net.Http for CLI and mscorlib/System for harness;
- harness `72`, `1743`, and the fixed digest above.

Exact ordered `boundRepositoryInputs` excludes the profile itself and contains 24 entries:

1. `docs/project/milestones/EAIRA_M5_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW_PROJECT_CHARTER.md`
2. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE.md`
3. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R1.md`
4. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R2.md`
5. `docs/project/planning/EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_R3.md`
6. `docs/project/strategy/EAIRA_M5_SLICE1_SCOPE_DECISION.md`
7. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R2.md`
8. `apps/agent-services/README.md`
9. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
10. `apps/agent-services/src/ContractCodec.cs`
11. `apps/agent-services/src/AgentCore.cs`
12. `apps/agent-services/src/ModelProviders.cs`
13. `apps/agent-services/src/LocalTaskIntake.cs`
14. `apps/agent-services/src/LocalModelProvider.cs`
15. `apps/agent-services/src/OllamaLoopbackTransport.cs`
16. `apps/agent-services/src/ProjectReadOnlyPlatform.cs`
17. `apps/agent-services/src/ProjectContext.cs`
18. `apps/agent-services/src/ProjectKnowledge.cs`
19. `apps/agent-services/src/ProjectQa.cs`
20. `apps/agent-services/src/ProjectQaHost.cs`
21. `apps/agent-services/src/LocalOperator.cs`
22. `apps/agent-services/src/LocalOperatorHost.cs`
23. `apps/agent-services/tests/LocalOperatorHarness.cs`
24. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`

Order and hashes are mandatory in final mode. Existing `candidateRepositoryPaths` remains the exact current 32-path list; M5 inputs are bound separately, as Slice 4/5 inputs already are.

## 8. Discovery/final verifier state machine

Add switch `-LocalOperatorDiscovery`. It may be used only when `DevelopmentProbe`, `ProjectKnowledgeDiscovery` and `ProjectQaDiscovery` are false. Simultaneous discovery flags fail before output directory creation.

Pre-parse profile SHA rule:

- final mode is none of the four probe/discovery flags;
- final mode requires `ExpectedReleaseProfileSha256` and exact ordinal match before `ConvertFrom-Json`;
- LocalOperatorDiscovery alone bypasses only the external profile hash and the fields explicitly listed below;
- DevelopmentProbe never produces acceptance evidence.

LocalOperatorDiscovery may bypass comparison, but not collection, for exactly:

- 24 bound-input hashes, while path count/order remains mandatory;
- CLI/harness metadata inventories;
- native caller IL inventory for the two new OutputKinds;
- operator loopback member-reference inventory;
- CLI/harness artifact hashes;
- channel-matrix byte hashes.

It may not bypass:

- contract/revision/names/symbols/references/source order;
- capability/status/exit/limit policy;
- 72-case count, 1,743 framed bytes or case digest;
- A/B byte identity;
- tests and abuse mapping;
- Guard/factory counters;
- forbidden metadata/source checks;
- legacy M4 suites;
- path count/order or excluded-path intersection.

Discovery output has `classification=M5_SLICE1_LOCAL_OPERATOR_DISCOVERY`, `finalEvidence=false`, `externalSigningEligible=false`, and no release directory copy.

Final acceptance formula is exactly:

```text
finalEvidence =
  !DevelopmentProbe && !ProjectKnowledgeDiscovery && !ProjectQaDiscovery &&
  !LocalOperatorDiscovery && externalProfileShaMatch &&
  allLegacyM4ChecksPass && localOperatorPolicyPass &&
  localOperatorBoundInputsPass && localOperatorHarnessPass &&
  localOperatorCliChannelsPass && localOperatorMetadataPass &&
  localOperatorNegativeSpecimensPass && reproducibleByteForByte
```

Only when this Boolean is true may the unsigned operator CLI be copied to release. The build manifest records every conjunct separately and records all discovery flags as false.

## 9. Ten-path closure and next Gate

The exact product manifest remains the ten paths in V1 design section 11. Sections 3, 6 and 7 prove no change is required to `LocalTaskIntake`, task host, ProjectKnowledge, knowledge host or an M4 contract. If compilation disproves this, implementation stops for manifest widening.

R2 remedies only design documents. It does not authorize product mutation, live provider use, staging, commit or push.

Next Gate:

`SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R2_REVIEW`
