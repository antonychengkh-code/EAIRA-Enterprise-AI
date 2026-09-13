# EAIRA M5 Slice 3 Exact Implementation Design

## 1. Control

| Field | Value |
| --- | --- |
| Design ID | `EAIRA_M5_SLICE3_A_EXACT_IMPLEMENTATION_DESIGN_V4` |
| Date | `2026-09-13` |
| Baseline | `0be3bb95447a45c60ab4cc950a44950b784b086e` |
| Scope decision | `EAIRA_M5_SLICE3_SCOPE_DECISION_V1R4` |
| Readiness package | `EAIRA_M5_SLICE3_A_READINESS_PACKAGE_V1R4` |
| Scope review | `PASS; P0=0; P1=0; P2=3_RESOLVED` |
| V1 design review | `CANNOT_CLOSE; P0=0; P1=5; P2=1` |
| R2 design review | `CANNOT_CLOSE; P0=0; P1=3; P2=0` |
| R3 design review | `CANNOT_CLOSE; P0=0; P1=2; P2=1` |
| R4 remediation | `AUTHORIZED_BY_PROJECT_OWNER_ALL_GATES_AUTHORIZATION` |
| Exact-design authority | `GRANTED_BY_PROJECT_OWNER_ALL_GATES_AUTHORIZATION` |
| Implementation authority | `NOT_YET_EXERCISED_PENDING_INDEPENDENT_DESIGN_REVIEW` |
| Repository-recording authority | `NOT_YET_EXERCISED_PENDING_LATER_GATES` |
| Next Gate | `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE3_A_EXACT_IMPLEMENTATION_DESIGN_R4_REVIEW` |

This design adds one bounded, deterministic policy-explanation capability to
the existing Local Operator. It does not execute or authorize the described
route. All values below are normative; implementation may not add aliases,
fallbacks, defaults or dynamic sources.

## 2. Exact command and request construction

The only accepted form is exactly five argv items after the executable:

```text
preflight --trace <TRACE> --route <ROUTE_ID>
```

`TRACE` uses the existing exactly 32-character uppercase hexadecimal rule.
`ROUTE_ID` is ordinal-case-sensitive and is exactly one of:

```text
TASK_MOCK
TASK_MOCK_CONTEXT
TASK_OLLAMA_LOCAL
TASK_OLLAMA_LOCAL_CONTEXT
KNOWLEDGE
PROJECT_QA_OLLAMA_LOCAL
HEALTH
```

`LocalOperatorCapability` appends `Preflight = 5`; existing numeric values do
not change. The request properties are exact:

| Property | Value |
| --- | --- |
| `CapabilityName` | `PREFLIGHT` |
| `Provider` | `NONE` |
| `Model` | `NONE` |
| `Root` | `null` |
| `InputKind` | `PREFLIGHT_ROUTE` |
| `Input` | exact validated `ROUTE_ID` |
| `Task.Goal` | `EXPLAIN COMPILED ROUTE POLICY` |

The route ID is bound by the existing request-digest framing through
`InputDigest=DomainDigest("EAIRA_M5_SLICE1_PREFLIGHT_ROUTE_V1", ROUTE_ID)`.
The fixed Guard envelope deliberately contains no user-supplied goal, route ID,
query, question, path, provider or root; its only goal is the fixed internal
intent above. Other capabilities retain `Task.Goal=Input` and remain
byte-compatible.

## 3. Pre-Guard outer route versus post-Guard policy lookup

`LocalOperatorRoute.Create(request)` remains before Guard because denied output
requires a route digest. For Preflight it constructs only this generic outer
route:

| Route field | Exact value |
| --- | --- |
| Capability | `PREFLIGHT` |
| context policy | `NONE` |
| knowledge policy | `NONE` |
| provider/policy | `EAIRA_STATIC_OPERATOR_PREFLIGHT_V1` |
| Network | `NONE` |
| Authority | `EXPLANATORY_NOT_AUTHORITY` |
| PayloadContract | `EAIRA_OPERATOR_PREFLIGHT_V1` |
| CallBudget | `MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0` |

This object has no seven-row described-route tuple. After the generic route is
created, `LocalOperatorRunner.Execute` calls `GuardAgent.ExpectedDecision` (or
the test seam) exactly once. Deny returns the existing three-role sanitized
chain before `LocalOperatorPreflight.Lookup` or payload construction. Only an
allow result enters `ExecutePreflightAllowed` and the seven-row lookup.

The preflight Guard outcome means only that this explanation may be produced.
It is rendered as `ALLOW_PREFLIGHT_ONLY` and is never reusable as a Guard
decision or authorization for the described route.

## 4. Exact described-route policy table

| Route ID | Capability | Source class | Provider policy | Route network | Route authority |
| --- | --- | --- | --- | --- | --- |
| `TASK_MOCK` | `TASK` | `USER_ARGUMENTS_ONLY` | `MOCK` | `NONE` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_MOCK_CONTEXT` | `TASK` | `CONTROLLED_PROJECT_CONTEXT` | `MOCK` | `NONE` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_OLLAMA_LOCAL` | `TASK` | `USER_ARGUMENTS_ONLY` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `TASK` | `CONTROLLED_PROJECT_CONTEXT` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `KNOWLEDGE` | `KNOWLEDGE` | `CONTROLLED_PROJECT_MEMORY` | `NONE` | `NONE` | `NAVIGATIONAL_NOT_AUTHORITY` |
| `PROJECT_QA_OLLAMA_LOCAL` | `PROJECT_QA` | `CONTROLLED_CONTEXT_AND_PROJECT_MEMORY` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `ASSISTIVE_NOT_AUTHORITY` |
| `HEALTH` | `HEALTH` | `COMPILED_CONTRACT_ONLY` | `NONE` | `NONE` | `OBSERVATIONAL_NOT_AUTHORITY` |

The table is implemented by exact ordinal branches in
`LocalOperatorPreflight.Lookup(string routeId)`. There is no dictionary,
reflection, configuration, environment input, filesystem input or default row.
Unknown input throws before success output.

## 5. Exact payload contract

`LocalOperatorPreflight.CanonicalPayload(policy)` constructs one minified JSON
object in exactly this member order, with all values JSON strings:

```json
{"schema":"EAIRA_OPERATOR_PREFLIGHT_V1","status":"POLICY_EXPLAINED","observationScope":"COMPILED_CONTRACT_ONLY","routeId":"<ROW>","capability":"<ROW>","guardRequirement":"REQUIRED_BEFORE_EFFECT","guardEvaluation":"ALLOW_PREFLIGHT_ONLY","sourceClass":"<ROW>","providerPolicy":"<ROW>","routeNetwork":"<ROW>","preflightNetwork":"NONE","writes":"NONE","routeAuthority":"<ROW>","authority":"EXPLANATORY_NOT_AUTHORITY"}
```

`LocalOperatorPreflight.Validate` requires the exact request properties, generic
outer route, selected row, canonical payload equality, payload digest equality,
14-member order and enumerated values. `LocalOperatorResponse` accepts the
payload only when `PayloadContract=EAIRA_OPERATOR_PREFLIGHT_V1` and this exact
validator-produced prefix is present. Payload SHA-256 uses the existing
`EAIRA_M5_SLICE1_PAYLOAD_V1` length-framed domain. Golden byte counts and hashes
are defined only by the pre-implementation oracle and vectors in section 5.1.
Clean discovery builds merely observe candidate values and must equal that prior
oracle across A/B before profile calibration; source/build observations never
define or replace the oracle.

The existing wrapper remains `EAIRA_LOCAL_OPERATOR_V1`; successful outer fields
are `capability=PREFLIGHT`, `network=NONE`, `writes=NONE`, and
`authority=EXPLANATORY_NOT_AUTHORITY`. Stderr is empty and stdout is written
once only after full in-memory validation.

### 5.1 Pre-implementation canonical oracle and vectors

The normative oracle is a direct UTF-8 implementation of existing
`ContractCodec.Field`, SHA-256, U32BE payload framing and
`OrchestrationChain.Success`; it does not compile or execute candidate product
source. Canonical trace for every row is
`00112233445566778899AABBCCDDEEFF`; the fixed Task digest is
`F881CE67DC74CC8EC4180BDC2F506B4EDA1369226EF9D102A790A4C495998076`.

| Route ID | Input SHA-256 | Request SHA-256 | Outer route SHA-256 | Payload bytes | Payload SHA-256 | Audit SHA-256 | Wrapper bytes | Wrapper SHA-256 |
| --- | --- | --- | --- | ---: | --- | --- | ---: | --- |
| `TASK_MOCK` | `6E02888095CC5D5D9C440BF26DE342848855A56D9C04282A398B8B59C812B185` | `0BBACB758B1EA183338134C3D5CAAEDABA56793026E506214651BD0EA5FF1CC8` | `1261E4E6931D12FD0C7AD5451003D1ED9C099D47549C474451D7FED5C858A5BC` | 469 | `8D7997CAE44F3D9AC2B244DD8B24B36A9BF2862E53A940B2F407178A24700123` | `612EEE7C3DBC3C74D9756FF3F864904B1F0096056514228A73575CBE8234D979` | 1031 | `F6A302DFD0B183F774EB284646E6A349684D7A04069BB48993752A55FDDBF363` |
| `TASK_MOCK_CONTEXT` | `8EAF2E7E352ED6708B4E27C1DEB3C43750E06002E561217F42631D328D662EB6` | `49A90C39F8B8E078F16E911E779D7E5B680CF110B361EB1BE2EA61C0FFA89606` | `2BD5CAB32D3A6D92EBCFF7DBE908C8697040D5C5F0680F7BB5F94437CE9556A6` | 484 | `4A8FA23201A8D66973B7ED2B12175550CE8420B7AB4A2E3B1719F95C1E900AAE` | `29AB65CD7FA72CDAC05D745522378BEF3B9CBDC791F7262FAF8F1FD33CADD9A7` | 1046 | `44CE99EB60F7060B8F929BEDB43ABC1E4BC1AE30FB357F3306F487DB81DF490D` |
| `TASK_OLLAMA_LOCAL` | `02EC0071865D2E0F8180E4EBB2F26018E6D4311F17F42F19EB8636CA7378471F` | `8C370BC4AAD608DB64D4153FFF5041B33E851E104FCD340AE7C86B359FACC67C` | `CAD4B1919CCC21DE78491E7354BC7CCDD18B06F825391382374504FB42B5FFD9` | 503 | `BC12483396D81F0FD34694785ABD48D246B682A9307CF7C67EF59A90C06F7235` | `9E9227C0CD8D8535E55BCD67B827E8AB98F8E5825BEE24094E238E154851491B` | 1065 | `7EF3DB6697E0C22668562ACEE901C3DB7F89AF7CEC7E06BAB2DE46EC8A52AF4E` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `73A30D6DFF83BD0F29587F9A96BB9068CD4457B3B7CCBF431CCDE3E90684B14D` | `8934570547EB83CFD702A33915E23DEC3C9D6932832050718241E452FF01E246` | `95852EB55B3CB5423ACDA23B15EB345A4A71427089E1FC6F691AB488C39CAABF` | 518 | `B9942954B900123FFBD4F81E36CD26DDC588B29E1CF223EEFBC73C0B3B0C9FDD` | `0CF369D262B8508D10D02D92B8DD662E4BF27C43E8B152CEF934FCD05C293BFE` | 1080 | `15EDE12F1DEAC0BAEDC5BB59179D37F8CB5B9A121308CFE293BA3037CB74FAB9` |
| `KNOWLEDGE` | `9D8343AD14123606AB0123B44B1F6E33A9FDD08BA85E2F59919173A72AE40E29` | `6E9B253090E1E9F48DB5EB40DB2C6B2FA638AB94422C761A5171D2BFFFBA9273` | `41CC3A936B9E48034A9CFA2E0B330135D7B0DC005B50151FF0AF9E6B3C8C223A` | 460 | `8C6AC210A698083658282360A080E406CBD123D4DF612B75D92F4D2B69ADE024` | `4FCACC78AAE677180A3F72A8390D3E3BA06BDF49199BA8FF18BE7147B29F1D4A` | 1022 | `1253EC133D4C292E202D093C9D300F1789156EE17C11D773E73F3486F135EC78` |
| `PROJECT_QA_OLLAMA_LOCAL` | `A8A0D2FF6C74A7A7FEE5F253DD84EFF6BF0A03EE176E8A3B2AFF6D7C3E3625FE` | `3BA821B17CD1C6AEDC39941E24D437616773544E1D10A9FF3BA8CCB888878DB3` | `B2B97AB2C724BD85E80AD82D678E748EE0FDEEF550381F52FADF97DB3F66AEE9` | 510 | `8B23F674B8E485B171DA882D2FB99C46132BDACB795A5C55E4DD3BB6B2EDBA3A` | `DB6A5A47D1F213F1FE47AC404ECA7D94AA4896E1A2FB3277569E8A313571A7D3` | 1072 | `A12A101605F2972915528EAB7D9354969835FE4128985034EB99EA0EF1C3298E` |
| `HEALTH` | `C88E47E2668A7754785362F580C3F5B2E25AC7CBEE9F58A5C32056BC82FC9993` | `6CDAB3F8DA1151DDFABD36D7082AFD2AC9BB96DE0D474403C7696B7A207128ED` | `13BC3DBF53415D5EDDE75C4E07B71E95B357175204BD03711E1177E0457FBC03` | 452 | `8FC6CF6017AA3DC770D6D2E3934C5B01E7506F834DB4670BCF18C0545CCEB927` | `B70027C347516E0EF87793C724E71F3FEAEBD8CCAC16E1706CC195861653963C` | 1014 | `81E9E488E0FC8F74E73397FCEA5DF1F127EE787E622072E3C3199C3DBF6C5912` |

Harness framing is fixed before implementation:

| Segment | Domain | Count | Bytes | SHA-256 |
| --- | --- | ---: | ---: | --- |
| Slice 1 prefix | `EAIRA_M5_SLICE1_CASE_NAMES_V1` | 96 | 2409 | `0AAF52EE6A087B487B6497676F48BA7AD0D36CB987C149CC1BADAD9CA5D2FE68` |
| Slice 2 prefix | `EAIRA_M5_SLICE2_CASE_NAMES_V1` | 119 | 3095 | `198B2B892C9E6516B50B2C2CAF86AABA058B4D8B0D335AD445DC8685230F8A86` |
| Slice 3 new only | `EAIRA_M5_SLICE3_NEW_CASE_NAMES_V1` | 47 | 1722 | `A003B2E48A46636D309B5049BAA34BD7A632F91C2EF5F4337A0FC35789445A8D` |
| Slice 3 full | `EAIRA_M5_SLICE3_CASE_NAMES_V1` | 166 | 4783 | `02CD503C883C8929CD7BA393BEBAFBBB932CDBA5DB22348F298FF66E9E182595` |

Discovery is acceptable only when every observed value equals this table.
Profile calibration copies equal observations; it never defines the oracle.

### 5.2 Mandatory Build-time full validation

The exact eight-argument overload is:

```text
EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain)
```

Its release body is one basic block: load its eight arguments, load
`payloadDigest` again as `chainPayloadDigest`, call the exact nine-argument
overload once, and immediately return that result. It has no alternate call,
branch, EH region, output construction or return. The verifier enforces this
shape and the direct `Build8 -> Build9` edge.

The nine-argument `LocalOperatorResponse.Build` must branch on
`route.PayloadContract == "EAIRA_OPERATOR_PREFLIGHT_V1"` before its generic
prefix acceptance. It performs a second post-allow
`LocalOperatorPreflight.Lookup(r.Input)` and calls
`LocalOperatorPreflight.Validate(r, route, policy, payload, payloadDigest)`.
Therefore a successful request has exactly two described-policy resolutions and
one payload construction; a denied request has zero of each. Only after full
validation may `Build` test the schema prefix and construct the wrapper.

Full validation requires exact canonical equality for all 14 members, row tuple,
route/response authority separation, request properties, generic outer route,
payload digest and current row. A forged payload with the same
`EAIRA_OPERATOR_PREFLIGHT_V1` prefix but any changed/extra/reordered member must
be rejected. `PREFLIGHT_PAYLOAD_TAMPER_REJECT` directly calls the exact
eight-argument runtime `Build` with a same-prefix forged payload and valid
recomputed digest to prove this
boundary cannot be bypassed.

## 6. Exact source changes

Only `apps/agent-services/src/LocalOperator.cs` changes production code:

1. append `Preflight=5` and add the exact parser branch;
2. select the fixed Guard task goal only for Preflight;
3. add the generic outer route branch before existing route branches;
4. add immutable `LocalOperatorPreflightPolicy` and static
   `LocalOperatorPreflight` lookup/payload/validation methods;
5. extend `HasExpectedPayloadPrefix` for the exact preflight schema;
6. after Guard allow and before Health/legacy dispatch, call
   `ExecutePreflightAllowed` for Preflight;
7. snapshot connect-attempt count around the allowed branch and convert any
   nonzero delta to existing sanitized `OUTPUT_ERROR`;
8. keep every legacy and Health branch and method signature unchanged.

Under `EAIRA_LOCAL_OPERATOR_TEST_SEAM` only, lookup and payload-construction
counters expose reset/snapshot methods. They prove deny occurs before described
lookup/payload. They do not exist in the release assembly.

No Task capability adapter/intake, context reader, knowledge reader, QA object,
Health method, provider factory, model, network transport, native method,
filesystem API, environment API, clock, randomness, reflection, dynamic load,
IPC, process or persistence call is reachable from the allowed preflight root.

## 7. Harness contract

The current 119 case names and first-96 Slice 1 prefix remain unchanged. Append
exactly 47 Slice 3 cases (166 total), in this order:

```text
PREFLIGHT_ROW_TASK_MOCK
PREFLIGHT_ROW_TASK_MOCK_CONTEXT
PREFLIGHT_ROW_TASK_OLLAMA_LOCAL
PREFLIGHT_ROW_TASK_OLLAMA_LOCAL_CONTEXT
PREFLIGHT_ROW_KNOWLEDGE
PREFLIGHT_ROW_PROJECT_QA_OLLAMA_LOCAL
PREFLIGHT_ROW_HEALTH
PREFLIGHT_FIXED_GUARD_ENVELOPE
PREFLIGHT_OUTER_ROUTE_EXACT
PREFLIGHT_GUARD_ALLOW_ONCE
PREFLIGHT_GUARD_DENY_ONCE_NO_LOOKUP_PAYLOAD_FACTORY
PREFLIGHT_CROSS_TRACE_PAYLOAD_STABLE_WRAPPER_DISTINCT
PREFLIGHT_SAME_INPUT_BYTE_STABLE
PREFLIGHT_ZERO_CONNECT_AND_FACTORIES
PREFLIGHT_AUTHORITY_SEPARATION
PREFLIGHT_MEMBER_ORDER_EXACT
PREFLIGHT_PAYLOAD_TAMPER_REJECT
PREFLIGHT_ROUTE_TAMPER_REJECT
PREFLIGHT_INVALID_UNKNOWN_ROUTE
PREFLIGHT_INVALID_ROUTE_LOWER
PREFLIGHT_INVALID_ROUTE_PREFIX
PREFLIGHT_INVALID_ROUTE_SUFFIX
PREFLIGHT_INVALID_ROUTE_UNICODE_CONFUSABLE
PREFLIGHT_INVALID_MISSING_TRACE
PREFLIGHT_INVALID_TRACE_LOWER
PREFLIGHT_INVALID_TRACE_SHORT
PREFLIGHT_INVALID_TRACE_LONG
PREFLIGHT_INVALID_TRACE_NONHEX
PREFLIGHT_INVALID_MISSING_ROUTE
PREFLIGHT_INVALID_DUPLICATE_ROUTE
PREFLIGHT_INVALID_REORDERED_FLAGS
PREFLIGHT_INVALID_EXTRA_FLAG
PREFLIGHT_INVALID_GOAL_INJECTION
PREFLIGHT_INVALID_QUERY_INJECTION
PREFLIGHT_INVALID_QUESTION_INJECTION
PREFLIGHT_INVALID_ROOT_INJECTION
PREFLIGHT_INVALID_PROVIDER_INJECTION
PREFLIGHT_INVALID_MODEL_INJECTION
PREFLIGHT_INVALID_ENDPOINT_INJECTION
PREFLIGHT_INVALID_RESPONSE_FILE
PREFLIGHT_INVALID_STDIN_TOKEN
PREFLIGHT_INVALID_ENV_TOKEN
PREFLIGHT_INVALID_CONFIG_TOKEN
PREFLIGHT_INVALID_CONFIG_EXPANSION
PREFLIGHT_ZERO_SELECTED_ROUTE_EXECUTION_AND_READS_SUCCESS
PREFLIGHT_ZERO_COUNTERS_ALL_INVALID
PREFLIGHT_LEGACY_GUARD_AND_ROUTE_SEQUENCE_COMPATIBILITY
```

The last case runs Task mock, Task local, Knowledge, Project QA, Health and
Preflight through counting Guard/factory seams and proves one Guard evaluation
per valid request, unchanged expected factory counts, and zero preflight
factories. The harness emits separate 96-case Slice 1, 119-case Slice 2 and
166-case Slice 3 framed-name evidence. Every success row asserts two post-allow
policy resolutions (construction plus Build-boundary validation), one payload
construction, zero adapter executions, zero reads, zero provider factories and
zero connect attempts. Every invalid row asserts zero Guard, lookup, payload,
adapter, read, provider-factory and connect counters; deny asserts one Guard and
all remaining counters zero. Discovery pins the Slice 3 framed bytes,
digest, payload/wrapper golden values and denial counters before final mode.

## 8. Verifier and abuse matrix

`Invoke-Gate25UnsignedRelease.ps1` adds
`-LocalOperatorPreflightDiscovery`. It is non-final, never creates release
output, bypasses only the new Local Operator profile equality, and cannot be
combined with any other discovery/probe switch. Normal final mode bypasses
nothing.

The verifier retains all existing clean A/B builds, 119-case prefix, M4/M5
regressions, metadata, P/Invoke, native, loopback, channel, output-isolation and
13 Local Operator/Health negative specimens. It additionally verifies:

- exact 166-case list and unchanged 119-case Slice 2 prefix digest;
- all seven golden payload tuples and canonical wrapper channels;
- one Guard call on valid allow/deny and zero lookup/payload/factory/connect on
  deny;
- parser accepted-route set equals the seven-row table exactly;
- decoded IL/CFG dominance: Guard call dominates Preflight selector, described
  lookup, payload construction and allowed root;
- allowed-root transitive same-module closure has no factory/provider/network,
  `System.IO`, environment, process, IPC, reflection, dynamic-load, clock,
  randomness or P/Invoke reference;
- generic outer route construction may precede Guard, but the described lookup
  and payload methods may not;
- connect-attempt monitor covers both sanctioned loopback entrypoints and has
  zero delta on preflight allow and deny.

Append exactly these 15 targeted compile-then-reject specimens in this order:

```text
PREFLIGHT_FILESYSTEM_CLOSURE
PREFLIGHT_ENVIRONMENT_CLOSURE
PREFLIGHT_PROVIDER_FACTORY_CLOSURE
PREFLIGHT_NETWORK_CLOSURE
PREFLIGHT_ROUTE_EXECUTION_CLOSURE
PREFLIGHT_LOOKUP_BEFORE_GUARD
PREFLIGHT_PAYLOAD_BEFORE_GUARD
PREFLIGHT_AUTHORITY_COLLAPSE
PREFLIGHT_EIGHTH_ROUTE
PREFLIGHT_DYNAMIC_LOAD_CLOSURE
PREFLIGHT_THREAD_SLEEP_CLOSURE
PREFLIGHT_TASK_DELAY_CLOSURE
PREFLIGHT_THREADING_TIMER_CLOSURE
PREFLIGHT_TIMERS_TIMER_CLOSURE
PREFLIGHT_CRYPTO_RNG_CLOSURE
```

The ordered-name oracle is domain
`EAIRA_M5_SLICE3_PREFLIGHT_SPECIMEN_NAMES_V1`, count 15, 526 framed UTF-8
bytes and SHA-256
`47B0424EF00EDE857C4C6EFA0A4428737A6F7A188FB23D4E816A5AB995B3D7D3`.
Discovery output, normal final output and profile revision 3 must each contain
this exact ordered list, count, byte length and digest; set equality or sorting
at comparison time is forbidden.

Each specimen has one exact mutation anchor, must compile where applicable, and
must fail one named targeted rule. Unexpected compile failure is not a pass.
The final evidence classification becomes
`M5_SLICE3_OPERATOR_PREFLIGHT_UNSIGNED_CANDIDATE`; discovery is
`M5_SLICE3_OPERATOR_PREFLIGHT_DISCOVERY`. Final evidence remains false in
discovery and true only with the exact reviewed profile SHA-256.

### 8.1 Exact IL/CFG evidence algorithm

The authoritative release assembly is the CLI compiled without
`EAIRA_LOCAL_OPERATOR_TEST_SEAM`. The seam harness is separately executed to
prove injected-Guard counters; seam delegate calls are excluded from release
callsite cardinality and may not appear in CLI metadata.

Exact release identities are resolved from MethodDef/MemberRef signatures, not
assumed token positions:

```text
EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])
EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)
EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)
EAIRA.AgentServices.Functional.LocalOperatorPreflight::CanonicalPayload(EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy)
EAIRA.AgentServices.Functional.LocalOperatorPreflight::Validate(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy,System.String,System.String)
EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain)
EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)
EAIRA.AgentServices.Functional.GuardAgent::ExpectedDecision(EAIRA.AgentServices.Functional.TaskEnvelope)
```

Every identity must resolve exactly once. Its actual MethodDef token is emitted
as eight-digit uppercase hex and must be identical across clean A/B builds.
Token numeric values are relocation evidence, not the identity key: profile
binding joins by the full signature so a reviewed metadata relocation cannot be
misread as a different method. Duplicate or missing identities fail closed.

IL decoding uses ECMA-335 instruction boundaries. Basic-block leaders are
offset zero, every branch/switch target, instruction after branch,
conditional-branch, switch, return or throw, and every try/filter/handler start
and end. Edges are all branch/switch targets plus fall-through except after
unconditional branch, return or throw. A synthetic EH super-root connects entry,
every filter start and every handler start for reachability accounting; dominance
of the protected normal path is computed from entry over normal edges, while any
Guard/selector/lookup/payload/allowed-root callsite inside try, filter or handler
range is independently rejected. `finally` or `fault` in `Execute` is rejected.
The standard iterative dominator sets initialize entry to itself and all other
reachable blocks to all reachable blocks, then intersect predecessor sets to a
fixed point.

Release `Execute` must contain exactly one callsite to
`GuardAgent.ExpectedDecision` and exactly one to `ExecutePreflightAllowed`.
The Guard block must dominate the `Preflight=5` selector block and allowed-root
call block; the selector must dominate the allowed-root call. The allowed root
must contain one direct call each to `Lookup`, `CanonicalPayload`, `Validate`,
`PayloadDigest`, the eight-argument `LocalOperatorResponse.Build` and
`OrchestrationChain.Success`. The nine-argument Build boundary must contain one
direct call each to `Lookup` and `Validate`. The eight-argument Build must call
the nine-argument Build exactly once and have no alternate output/return path.
The critical call-row manifest is ordinal-sorted UTF-8 lines
`CALL|<caller-full-signature>|<callee-full-signature>|<count>`; its 11-row
SHA-256 is
`54FE70CC5D09904BF093D0551E0EDDB33A312345D61295415C5398A1A335B4F4`.
Any additional/missing critical row or count fails closed.
The exact 11 pre-sort rows are:

```text
CALL|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain)|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)|EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)|EAIRA.AgentServices.Functional.LocalOperatorPreflight::Validate(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy,System.String,System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])|EAIRA.AgentServices.Functional.GuardAgent::ExpectedDecision(EAIRA.AgentServices.Functional.TaskEnvelope)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorPreflight::CanonicalPayload(EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorPreflight::Validate(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy,System.String,System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorRunner::PayloadDigest(System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecutePreflightAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.OrchestrationChain::Success(System.String,System.String,System.String)|1
```

Transitive closure begins at `ExecutePreflightAllowed` and follows same-module
`call`, `callvirt`, `newobj`, `ldftn` and `ldvirtftn` operands. MemberRefs whose
parent is a TypeDef are resolved by full signature; ambiguity fails. Every
referenced TypeDef and each enclosing nested TypeDef contributes its single
`.cctor` when present. MethodSpec is normalized to its generic base identity
plus ordinal generic arguments. The queue is identity-keyed and each method is
visited once. EH handlers and filters are decoded as part of their containing
method regardless of normal reachability.

Closure rows are ordinal-sorted UTF-8 without a terminal LF. Each normalized
method hash covers all BODY, LOCALS, IL and EH rows:

```text
BODY|<full-signature>|<tiny-or-fat>|<code-size>|<maxstack>|<initlocals-TRUE-or-FALSE>
LOCALS|<full-signature>|<count>|<ordinal structural local identities or ->
METHOD|<full-signature>|<methoddef-token-hex>|<BODY-LOCALS-IL-EH-sha256>
CALL|<caller-full-signature>|<opcode>|<callee-full-signature>
TOKEN|<caller-full-signature>|<opcode>|<normalized-entity-identity>
EH|<caller-full-signature>|<kind>|<try-start>|<try-end>|<handler-start>|<handler-end>|<catch-or-filter>
```

`LOCALS` structurally decodes the StandaloneSig and preserves exact `PINNED:`,
`BYREF:`, `PTR:`, `SZARRAY:`, multidimensional-array rank, generic-type and
generic-argument identities in ordinal slot order. Every local type identity is
fed to forbidden matching and enqueues its TypeDef and enclosing-type `.cctor`
exactly like an IL token operand. The method hash input is BODY first, LOCALS
second, IL rows in offset order, then normalized EH rows in ordinal order, joined
by LF without a terminal LF. Each IL row is
`<offset-hex>|<opcode-lower>|<operand-kind>|<normalized-operand>`. Raw metadata
tokens never appear as operands. A/B must have identical
identity row sets, body hashes, closure hash and tokens; the independently
reviewed discovery set is then pinned by identity in profile revision 3.

Forbidden matching applies in this exact precedence order so each specimen has
one result: `PREFLIGHT_PAYLOAD_BEFORE_GUARD`,
`PREFLIGHT_LOOKUP_BEFORE_GUARD`, `PREFLIGHT_ROUTE_SET_MISMATCH`,
`PREFLIGHT_GOLDEN_VECTOR_MISMATCH`, `PREFLIGHT_ROUTE_EXECUTION_REFERENCE`,
`PREFLIGHT_FACTORY_OR_PROVIDER_REFERENCE`, `PREFLIGHT_NETWORK_REFERENCE`,
`PREFLIGHT_FILESYSTEM_REFERENCE`, `PREFLIGHT_ENVIRONMENT_REFERENCE`,
`PREFLIGHT_DYNAMIC_LOAD_REFERENCE`, `PREFLIGHT_THREAD_SLEEP_REFERENCE`,
`PREFLIGHT_TASK_DELAY_REFERENCE`, `PREFLIGHT_TIMER_REFERENCE`,
`PREFLIGHT_CRYPTO_RNG_REFERENCE`, then `PREFLIGHT_OTHER_FORBIDDEN_REFERENCE`.
Exact forbidden identities are any P/Invoke method; adapter `::Execute`; factory
`::CreateTask`, `::CreateKnowledge`, `::CreateProjectQa`; a declaring type
containing `Factory`, `Provider`, `Transport`, `Socket`, `Http`, `Pipe`,
`Registry` or `Process`; type prefixes `System.IO.`, `System.Net.`,
`System.Diagnostics.`, `System.Reflection.`; exact types `System.Environment`,
`System.DateTime`, `System.DateTimeOffset`, `System.Random`, `System.Guid`,
`System.Threading.Timer`, `System.Timers.Timer`,
`System.Security.Cryptography.RandomNumberGenerator` and every derived RNG type;
methods `System.Threading.Thread::Sleep*`,
`System.Threading.Tasks.Task::Delay*`, `System.Reflection.Assembly::Load*`,
`System.Type::GetType*` or any
`System.Runtime.Loader.*` identity.

### 8.2 Exact compile-then-reject mutations

Every specimen clones the final release CLI compiler argv `$localOperatorArguments`
after deterministic/pathmap flags are present, verifies the original
`LocalOperator.cs` source argument occurs exactly once, substitutes exactly one
UTF-8-without-BOM specimen path at that same argv index, substitutes exactly one
`/out:` value, and changes no other argument or source order. All rows require
`compileRequired=true`, compiler exit 0 and output PE present; compilation failure
or a rejection rule other than the exact expected rule is a specimen failure.
Every literal anchor must occur exactly once before ordinal replacement.

| Specimen | Exact anchor | Exact replacement | Expected rule |
| --- | --- | --- | --- |
| `PREFLIGHT_FILESYSTEM_CLOSURE` | `LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `System.IO.File.Exists("C:\\EAIRA_FORBIDDEN"); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_FILESYSTEM_REFERENCE` |
| `PREFLIGHT_ENVIRONMENT_CLOSURE` | same policy anchor | `System.Environment.GetEnvironmentVariable("EAIRA_FORBIDDEN"); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_ENVIRONMENT_REFERENCE` |
| `PREFLIGHT_PROVIDER_FACTORY_CLOSURE` | same policy anchor | `factory.CreateTask(); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_FACTORY_OR_PROVIDER_REFERENCE` |
| `PREFLIGHT_NETWORK_CLOSURE` | same policy anchor | `new System.Net.WebClient().DownloadString("http://127.0.0.1/"); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_NETWORK_REFERENCE` |
| `PREFLIGHT_ROUTE_EXECUTION_CLOSURE` | same policy anchor | `factory.CreateTask().Execute(request); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_ROUTE_EXECUTION_REFERENCE` |
| `PREFLIGHT_LOOKUP_BEFORE_GUARD` | `AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);` | `LocalOperatorPreflight.Lookup(request.Input); AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);` | `PREFLIGHT_LOOKUP_BEFORE_GUARD` |
| `PREFLIGHT_PAYLOAD_BEFORE_GUARD` | same Guard anchor | `LocalOperatorPreflight.CanonicalPayload(LocalOperatorPreflight.Lookup(request.Input)); AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);` | `PREFLIGHT_PAYLOAD_BEFORE_GUARD` |
| `PREFLIGHT_AUTHORITY_COLLAPSE` | `+ ",\"authority\":\"EXPLANATORY_NOT_AUTHORITY\"}";` | `+ ",\"authority\":" + ContractCodec.Json(policy.RouteAuthority) + "}";` | `PREFLIGHT_GOLDEN_VECTOR_MISMATCH` |
| `PREFLIGHT_EIGHTH_ROUTE` | `value == "HEALTH";` | `value == "HEALTH" || value == "FORBIDDEN_ROUTE";` | `PREFLIGHT_ROUTE_SET_MISMATCH` |
| `PREFLIGHT_DYNAMIC_LOAD_CLOSURE` | same policy anchor | `System.Reflection.Assembly.Load(new byte[] { 0 }); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_DYNAMIC_LOAD_REFERENCE` |
| `PREFLIGHT_THREAD_SLEEP_CLOSURE` | same policy anchor | `System.Threading.Thread.Sleep(1); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_THREAD_SLEEP_REFERENCE` |
| `PREFLIGHT_TASK_DELAY_CLOSURE` | same policy anchor | `System.Threading.Tasks.Task.Delay(1); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_TASK_DELAY_REFERENCE` |
| `PREFLIGHT_THREADING_TIMER_CLOSURE` | same policy anchor | `new System.Threading.Timer(delegate(object state) { }, null, 1, 1); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_TIMER_REFERENCE` |
| `PREFLIGHT_TIMERS_TIMER_CLOSURE` | same policy anchor | `new System.Timers.Timer(1.0); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_TIMER_REFERENCE` |
| `PREFLIGHT_CRYPTO_RNG_CLOSURE` | same policy anchor | `System.Security.Cryptography.RandomNumberGenerator.Create(); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.Input);` | `PREFLIGHT_CRYPTO_RNG_REFERENCE` |

`PREFLIGHT_PAYLOAD_BEFORE_GUARD` has precedence over its nested lookup;
`PREFLIGHT_ROUTE_EXECUTION_CLOSURE` has precedence over its factory reference.
Authority collapse is compared to all seven pre-implementation vectors, and the
eighth-route rule compares parser acceptance to exactly the seven IDs in section
2 before running golden checks.

## 9. Release profile calibration

`gate25-unsigned-release-profile.json` increments only the Local Operator
profile revision from 2 to 3 and updates fields mechanically produced by the
reviewed verifier: ordered repository inputs, CLI/harness image and metadata
inventories, native inventory, exact 166-case values, seven golden payload and
wrapper records, denial/Guard/lookup counters, CFG/closure evidence, negative
specimen manifest and classification. Historical Slice 1 and Slice 2 prefix
records remain present and equal.

Calibration order is mandatory:

1. run discovery from the reviewed candidate into a sanitized out-of-tree root;
2. require clean A/B byte equality and every non-profile test;
3. independently review discovery JSON and source diff;
4. copy only observed deterministic fields into the profile;
5. rerun normal final mode with exact profile SHA-256;
6. require clean A/B equality again and zero bypass flags.

## 10. Exact changed-path manifest

The complete product candidate is exactly these nine paths:

```text
apps/agent-services/README.md
apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1
apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md
apps/agent-services/release/gate25-unsigned-release-profile.json
apps/agent-services/src/LocalOperator.cs
apps/agent-services/tests/LocalOperatorHarness.cs
docs/project/planning/EAIRA_M5_SLICE3_BOUNDED_OPERATOR_PREFLIGHT_AND_ROUTE_EXPLANATION_READINESS_PACKAGE.md
docs/project/planning/EAIRA_M5_SLICE3_EXACT_IMPLEMENTATION_DESIGN.md
docs/project/strategy/EAIRA_M5_SLICE3_SCOPE_DECISION.md
```

No other path may be modified in the product lifecycle. In particular,
`AgentCore.cs`, `LocalOperatorHost.cs`, repository-root `tests/`,
`docs/integrations/`, `scripts/claude_api.py` and `.obsidian/` remain excluded
and unread. Later post-publication controlled-state synchronization uses a new
separately reviewed manifest and may not be mixed into the product commit.

## 11. Fail-closed stop conditions

Stop and require a new remediation review if implementation needs a tenth path,
changes an existing command's bytes or Guard count, permits an eighth route,
puts described-route data in the Guard envelope, performs the described lookup
before Guard allow, reports the result as authorization for the described route,
constructs a provider/adapter, reads data, touches network or persistent state,
weakens any regression/negative specimen, creates release output in discovery,
updates a profile without clean A/B evidence, or touches an excluded path.

No stage, commit, normal push or controlled-state mutation occurs until its
separate core Gate and independent predecessor review are satisfied. Force push
is never authorized.
