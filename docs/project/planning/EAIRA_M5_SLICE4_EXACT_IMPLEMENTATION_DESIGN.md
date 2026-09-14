# EAIRA M5 Slice 4 Exact Implementation Design

## 1. Control

| Field | Value |
| --- | --- |
| Design ID | `EAIRA_M5_SLICE4_EXACT_IMPLEMENTATION_DESIGN_V3` |
| Date | `2026-09-13` |
| Selection | `M5S4_A_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN` |
| Repository baseline | `a0ef10a38fa0ac7fb62b9693f65936b0ff61fda9` |
| Scope decision | `EAIRA_M5_SLICE4_SCOPE_DECISION_V1R1` |
| Readiness package | `EAIRA_M5_SLICE4_A_READINESS_PACKAGE_V1R1` |
| Scope/readiness review | `PASS; P0=0; P1=0; P2=2` |
| State | `EXACT_DESIGN_R2R1_NORMATIVE_CLOSURE_CANDIDATE_READY_FOR_R3_REVIEW` |
| Implementation authority | `NOT_GRANTED` |
| Staging/commit/push authority | `NOT_GRANTED` |
| Next Gate | `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE4_A_EXACT_IMPLEMENTATION_DESIGN_R3_REVIEW` |

The two non-blocking review findings are closed here: the scope says
`generic dry-run route digest`, not route-policy digest, and names the completed
R1R1 review.

## 2. Exact changed-path manifest

The complete product candidate is exactly these nine text paths:

1. `apps/agent-services/README.md`
2. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`
3. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
4. `apps/agent-services/release/gate25-unsigned-release-profile.json`
5. `apps/agent-services/src/LocalOperator.cs`
6. `apps/agent-services/tests/LocalOperatorHarness.cs`
7. `docs/project/planning/EAIRA_M5_SLICE4_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN_READINESS_PACKAGE.md`
8. `docs/project/planning/EAIRA_M5_SLICE4_EXACT_IMPLEMENTATION_DESIGN.md`
9. `docs/project/strategy/EAIRA_M5_SLICE4_SCOPE_DECISION.md`

No substitution, tenth path, binary repository artifact or generated evidence
is allowed. `docs/integrations/`, `scripts/claude_api.py`, repository-root
`tests/` and `.obsidian/` remain excluded and unread.

## 3. Exact command grammar

`LocalOperatorRequest.Parse` recognizes `dry-run` only when the remaining argv
is one of these existing exact route grammars:

| Route ID | Exact argv after `dry-run` |
| --- | --- |
| `TASK_MOCK` | `task --provider mock --trace <TRACE> --goal <GOAL>` |
| `TASK_MOCK_CONTEXT` | `task --provider mock --trace <TRACE> --goal <GOAL> --context-root <ROOT>` |
| `TASK_OLLAMA_LOCAL` | `task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL>` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ROOT>` |
| `KNOWLEDGE` | `knowledge --root <ROOT> --trace <TRACE> --query <QUERY>` |
| `PROJECT_QA_OLLAMA_LOCAL` | `project-qa --root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b` |
| `HEALTH` | `health --trace <TRACE>` |

The parser performs only the existing bounded lexical/Unicode validation and
normalization. It does not recursively invoke the execution parser, access a
path, inspect environment/config/stdin, accept response files, accept route
selectors or accept `preflight`/nested `dry-run`.

## 4. Request and generic route representation

1. Add `DryRun = 6` to `LocalOperatorCapability`.
2. Add an immutable `TargetRouteId` property to `LocalOperatorRequest`.
3. Existing commands retain `TargetRouteId=null` byte-for-byte behavior.
4. Each dry-run request retains the parsed provider/model/root/input kind and
   normalized input only to compute the existing domain-separated
   `requestSha256`; it exposes none of those raw values.
5. The dry-run `TaskEnvelope.Goal` is the fixed
   `PLAN REQUEST WITHOUT EXECUTION`, never user input.
6. `CapabilityName` is exactly `DRY_RUN_PLAN`.
7. `LocalOperatorRoute.Create` returns one generic route with network `NONE`,
   authority `PLAN_NOT_AUTHORITY`, payload contract
   `EAIRA_OPERATOR_DRY_RUN_PLAN_V1`, policy
   `EAIRA_STATIC_OPERATOR_DRY_RUN_V1`, and exact zero-effect call budget
   `MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0`.
8. The generic route is constructed before Guard without looking up the
   described route. Outer `routeSha256` therefore never binds the policy row.

## 5. Single canonical policy source

`LocalOperatorPreflightPolicy` remains the only policy-row representation.
`LocalOperatorPreflight.Lookup(TargetRouteId)` remains the only lookup for both
preflight and dry-run. Slice 4 adds no table, enum translation or copied switch.
The exact existing row bytes are preserved:

| Route | Capability | Source class | Provider | Network | Route authority |
| --- | --- | --- | --- | --- | --- |
| `TASK_MOCK` | `TASK` | `USER_ARGUMENTS_ONLY` | `MOCK` | `NONE` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_MOCK_CONTEXT` | `TASK` | `CONTROLLED_PROJECT_CONTEXT` | `MOCK` | `NONE` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_OLLAMA_LOCAL` | `TASK` | `USER_ARGUMENTS_ONLY` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `TASK` | `CONTROLLED_PROJECT_CONTEXT` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `KNOWLEDGE` | `KNOWLEDGE` | `CONTROLLED_PROJECT_MEMORY` | `NONE` | `NONE` | `NAVIGATIONAL_NOT_AUTHORITY` |
| `PROJECT_QA_OLLAMA_LOCAL` | `PROJECT_QA` | `CONTROLLED_CONTEXT_AND_PROJECT_MEMORY` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `ASSISTIVE_NOT_AUTHORITY` |
| `HEALTH` | `HEALTH` | `COMPILED_CONTRACT_ONLY` | `NONE` | `NONE` | `OBSERVATIONAL_NOT_AUTHORITY` |

## 6. Guard-dominant control flow

The production order is exact:

1. parse/validate argv;
2. create the generic dry-run route;
3. call `GuardAgent.ExpectedDecision` exactly once with the fixed plan-only
   envelope;
4. on deny, construct only the existing sanitized denied Audit chain;
5. on allow, call the shared policy lookup;
6. construct and validate the 13-member payload;
7. validate payload digest and wrapper;
8. emit one UTF-8 LF-terminated JSON line.

Invalid argv calls Guard zero times. Every valid allow or denial calls Guard
exactly once. Denial calls policy lookup and dry-run payload construction zero
times. No selected-route execution Guard result is computed or reused.

Under `EAIRA_LOCAL_OPERATOR_TEST_SEAM`, counters expose policy lookup and
dry-run payload construction; the harness delegate counts Guard calls. These
seams do not exist in the native build.

## 7. Exact canonical payload

`LocalOperatorDryRun.CanonicalPayload` emits exactly these 13 members in order:

```text
schema,planStatus,routeId,capability,sourceClass,providerPolicy,
routeNetwork,routeAuthority,writes,planGuardEvaluation,
executionGuardEvaluation,executionStatus,authority
```

Fixed values are:

- `schema=EAIRA_OPERATOR_DRY_RUN_PLAN_V1`;
- `planStatus=VALIDATED_NOT_EXECUTED`;
- `writes=NONE`;
- `planGuardEvaluation=ALLOW_DRY_RUN_ONLY`;
- `executionGuardEvaluation=NOT_EVALUATED`;
- `executionStatus=NOT_EXECUTED`;
- `authority=PLAN_NOT_AUTHORITY`.

The five described-policy values come directly from the one shared row. The
existing outer `payloadSha256` binds all 13 members. There is no policy-row
digest, raw input, per-field digest, length/presence hint, free-form text,
provider output, exception or diagnostic.

`LocalOperatorDryRun.Validate` recomputes the expected shared row, reconstructs
the canonical payload without incrementing the public construction counter,
checks the generic route constants and checks the existing payload digest.
`LocalOperatorResponse.Build` recognizes only the exact new payload prefix and
invokes validation before output.

## 8. No-effect and error contract

A successful dry-run has outer `status=PASS`, `capability=DRY_RUN_PLAN`,
`network=NONE`, `writes=NONE`, `authority=PLAN_NOT_AUTHORITY`, exit `0` and
empty stderr. A Guard denial uses existing `DENIED/77`, null payload and exact
three-role denied Audit chain. Invalid grammar uses existing
`INVALID_REQUEST/64` with null trace/capability/digests/payload/audit.
Validation failure uses existing sanitized `OUTPUT_ERROR/84` and never emits a
partial payload.

The dry-run branch never enters `ExecuteLegacy`, `ExecuteHealthAllowed`,
`ExecutePreflightAllowed`, adapter factories, project readers, provider/model
factories, transports, network, filesystem, registry, environment, IPC,
process, dynamic-load, log, cache or persistence code.

## 9. Harness contract

The first 166 published case names and their three prefix digests remain
byte-for-byte unchanged. Append exactly 58 Slice 4 cases, for exactly 224
passing cases. The 58 names, in order, are:

```text
DRY_RUN_ROW_TASK_MOCK
DRY_RUN_ROW_TASK_MOCK_CONTEXT
DRY_RUN_ROW_TASK_OLLAMA_LOCAL
DRY_RUN_ROW_TASK_OLLAMA_LOCAL_CONTEXT
DRY_RUN_ROW_KNOWLEDGE
DRY_RUN_ROW_PROJECT_QA_OLLAMA_LOCAL
DRY_RUN_ROW_HEALTH
DRY_RUN_DENY_TASK_MOCK
DRY_RUN_DENY_TASK_MOCK_CONTEXT
DRY_RUN_DENY_TASK_OLLAMA_LOCAL
DRY_RUN_DENY_TASK_OLLAMA_LOCAL_CONTEXT
DRY_RUN_DENY_KNOWLEDGE
DRY_RUN_DENY_PROJECT_QA_OLLAMA_LOCAL
DRY_RUN_DENY_HEALTH
DRY_RUN_FIXED_GUARD_ENVELOPE
DRY_RUN_GENERIC_OUTER_ROUTE
DRY_RUN_MEMBER_ORDER_EXACT_13
DRY_RUN_PAYLOAD_DIGEST_BINDS_POLICY_TUPLE
DRY_RUN_PAYLOAD_TAMPER_REJECT
DRY_RUN_ROUTE_TAMPER_REJECT
DRY_RUN_REQUEST_SPECIFIC_GOAL
DRY_RUN_REQUEST_SPECIFIC_ROOT
DRY_RUN_REQUEST_SPECIFIC_QUERY
DRY_RUN_REQUEST_SPECIFIC_QUESTION
DRY_RUN_SAME_REQUEST_BYTE_STABLE
DRY_RUN_ZERO_CONNECT_READ_FACTORY_EXECUTION
DRY_RUN_INVALID_EMPTY
DRY_RUN_INVALID_MISSING_TARGET
DRY_RUN_INVALID_UNKNOWN_TARGET
DRY_RUN_INVALID_PREFLIGHT_TARGET
DRY_RUN_INVALID_NESTED_TARGET
DRY_RUN_INVALID_ROUTE_SELECTOR
DRY_RUN_INVALID_FLAG_REORDER
DRY_RUN_INVALID_FLAG_DUPLICATE
DRY_RUN_INVALID_EXTRA_FLAG
DRY_RUN_INVALID_PROVIDER_REAL
DRY_RUN_INVALID_PROVIDER_URI
DRY_RUN_INVALID_MODEL
DRY_RUN_INVALID_TRACE_LOWER
DRY_RUN_INVALID_TRACE_SHORT
DRY_RUN_INVALID_TRACE_LONG
DRY_RUN_INVALID_TRACE_NONHEX
DRY_RUN_INVALID_GOAL_EMPTY
DRY_RUN_INVALID_QUERY_EMPTY
DRY_RUN_INVALID_QUESTION_EMPTY
DRY_RUN_INVALID_ROOT_LEXICAL
DRY_RUN_INVALID_RESPONSE_FILE
DRY_RUN_INVALID_STDIN_TOKEN
DRY_RUN_INVALID_ENV_TOKEN
DRY_RUN_INVALID_CONFIG_TOKEN
DRY_RUN_INVALID_CONFIG_EXPANSION
DRY_RUN_INVALID_ENDPOINT_INJECTION
DRY_RUN_INVALID_SHELL_FRAGMENT
DRY_RUN_INSTRUCTION_SHAPED_INPUT_OPAQUE
DRY_RUN_ROOT_EXISTENCE_NOT_PROBED
DRY_RUN_ALL_INVALID_ZERO_COUNTERS
DRY_RUN_ALL_ROUTES_ZERO_EFFECTS
DRY_RUN_LEGACY_PREFIX_COMPATIBILITY
```

The harness output adds `slice4NewTestsPassed=58`, its framed byte count and
SHA-256, plus dry-run Guard/lookup/payload/factory/execution/connect counters.
The aggregate 224-name framed domain is `EAIRA_M5_SLICE4_CASE_NAMES_V1`; the
58-name domain is `EAIRA_M5_SLICE4_NEW_CASE_NAMES_V1`. Their exact
preimplementation oracle is fixed in section 15 and is not calibrated by
discovery.

## 10. Compile-then-reject abuse specimens

The verifier compiles and rejects exactly these 15 fixed-order mutations:

1. `DRY_RUN_FILESYSTEM_CLOSURE`
2. `DRY_RUN_ENVIRONMENT_CLOSURE`
3. `DRY_RUN_PROVIDER_FACTORY_CLOSURE`
4. `DRY_RUN_NETWORK_CLOSURE`
5. `DRY_RUN_ROUTE_EXECUTION_CLOSURE`
6. `DRY_RUN_LOOKUP_BEFORE_GUARD`
7. `DRY_RUN_PAYLOAD_BEFORE_GUARD`
8. `DRY_RUN_EXECUTION_GUARD_REUSE`
9. `DRY_RUN_AUTHORITY_COLLAPSE`
10. `DRY_RUN_POLICY_TABLE_DUPLICATION`
11. `DRY_RUN_RAW_INPUT_OUTPUT`
12. `DRY_RUN_DESCRIBED_POLICY_DIGEST`
13. `DRY_RUN_CHILD_PROCESS`
14. `DRY_RUN_PERSISTENCE`
15. `DRY_RUN_EIGHTH_ROUTE`

Every specimen must compile successfully and then fail its intended metadata,
IL/control-flow, canonical schema, source-structure or runtime invariant. The
verifier records only sanitized ID/rule/compile/rejected evidence.

## 11. Release verifier and profile

Add non-final `-LocalOperatorDryRunDiscovery`. It may be used only to calibrate
mechanical build/token/body/profile baselines identified in section 20 and must
set `finalEvidence=false`, emit no release
output, and bypass only new Slice 4 equality checks. It cannot bypass clean A/B
builds, 224 harness cases, the first 166-name prefix, M4/M5 regressions,
metadata, P/Invoke, native, loopback, health/preflight control flow, channel
isolation, negative specimens or any safety check.

The bound repository input count becomes exactly 37 by appending the three
Slice 4 documents. The verifier and profile add:

- exact 224/58 harness counts, framed bytes and hashes;
- seven dry-run golden vectors and one public dry-run channel baseline;
- exact 13-member order and fixed values;
- generic-route/request/payload/audit hashes and stdout byte/hash baselines;
- Guard/lookup/payload/factory/execution/connect counters;
- dry-run dispatch and transitive IL/control-flow inventory;
- forbidden filesystem/environment/provider/network/route-execution/process/
  persistence references;
- fixed 15-specimen names, framed digest and rejection rows; and
- A/B equality for every new inventory and vector.

Normal final mode accepts no discovery switch. It must reproduce clean A/B
byte-identical outputs, all 37 inputs, 224 harness cases, 15 Slice 4 specimens,
15 retained Slice 3 specimens, all older specimens and all existing controls.
Only after every check passes may it copy the same nine unsigned release
artifacts to an out-of-tree directory. Signing fields remain `NotSigned`,
`externalSigningEligible=false`, `signatureOnlyBlocked=false` and
`gate25Complete=false`.

## 12. Documentation updates

The README and Local Operator contract document the exact seven dry-run forms,
13-member schema, no-effect behavior, request/generic-route/payload digest
meaning, denial behavior and explicit lack of execution authority. They do not
claim signing, service, Windows, external-provider or production readiness.

## 13. Gate acceptance

Independent exact-design review must confirm:

- the nine paths and 37 bound inputs are exact;
- no policy-table duplication or enum translation exists;
- Guard dominates policy lookup and payload construction;
- 13-member payload and digest semantics are closed;
- 224/58 tests and both 15-row specimen matrices are retained and ordered;
- discovery cannot produce final/release evidence; and
- no excluded, system, signing, provider or production authority is introduced.

`EXACT_DESIGN_R2R1_NORMATIVE_CLOSURE_CANDIDATE_READY_FOR_R3_REVIEW`

The exact next Gate is:

`SEPARATE_INDEPENDENT_EAIRA_M5_SLICE4_A_EXACT_IMPLEMENTATION_DESIGN_R3_REVIEW`

## 14. Normative constructor, target and digest contract

This section supersedes any less-specific earlier wording. The constructor is
exactly:

```text
LocalOperatorRequest(LocalOperatorCapability capability, string trace,
  string provider, string model, string root, string kind, string input,
  string targetRouteId)
```

Existing commands pass `targetRouteId=null`; dry-run requires one known target.
`DryRun=6` maps explicitly to `DRY_RUN_PLAN`; it may not be a ternary fallback.
With `T=00112233445566778899AABBCCDDEEFF`, `R=C:\EAIRA`, task input `plan`,
knowledge query `status` and QA question `status`, the seven rows are:

| Target | argc and exact indexed argv | Provider / Model / Root / Kind / Input |
| --- | --- | --- |
| `TASK_MOCK` | `8: [0]dry-run [1]task [2]--provider [3]mock [4]--trace [5]T [6]--goal [7]plan` | `MOCK / NONE / null / GOAL / plan` |
| `TASK_MOCK_CONTEXT` | `10: row 1 plus [8]--context-root [9]R` | `MOCK / NONE / R / GOAL / plan` |
| `TASK_OLLAMA_LOCAL` | `10: [0]dry-run [1]task [2]--provider [3]ollama-local [4]--model [5]qwen3:4b [6]--trace [7]T [8]--goal [9]plan` | `OLLAMA_LOOPBACK_V1 / qwen3:4b / null / GOAL / plan` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `12: row 3 plus [10]--context-root [11]R` | `OLLAMA_LOOPBACK_V1 / qwen3:4b / R / GOAL / plan` |
| `KNOWLEDGE` | `8: [0]dry-run [1]knowledge [2]--root [3]R [4]--trace [5]T [6]--query [7]status` | `NONE / NONE / R / QUERY / status` |
| `PROJECT_QA_OLLAMA_LOCAL` | `12: [0]dry-run [1]project-qa [2]--root [3]R [4]--trace [5]T [6]--question [7]status [8]--provider [9]ollama-local [10]--model [11]qwen3:4b` | `OLLAMA_LOOPBACK_V1 / qwen3:4b / R / QUESTION / status` |
| `HEALTH` | `4: [0]dry-run [1]health [2]--trace [3]T` | `NONE / NONE / null / HEALTH / COMPILED CONTRACT STATUS` |

`TargetRouteId` is not a ninth request-digest field. A closed
`DeriveDryRunTargetRouteId(Provider,Model,Root,InputKind,Input)` recomputes it
from existing digest-bound fields during construction before Guard and again
during payload validation; mismatch throws. Only the seven table combinations
are accepted. The fixed Task envelope has schema `1`, trace `T`, goal
`PLAN REQUEST WITHOUT EXECUTION`, and task SHA-256
`87FC2171DEF76373ACBC2382DBD1309174548A70C5761F8BE78D253E2272F554`.

The existing request frame remains exactly domain
`EAIRA_M5_SLICE1_REQUEST_V1`, NUL, then eight `length:value` fields in order:
capability, trace, provider, model, root-present, root digest, input kind, input
digest. Root and input frames remain their published domains. For `R`, root
SHA-256 is
`DA10DAE18F73EA08EF751AAB554D8249E1C5758ECA8B1754212B8C1036BF4C7B`.
Input hashes are: GOAL/`plan`
`4EB3550F537768AFF0825D476C6807C41572F38983A162A035246B2BB9C8FA97`,
QUERY/`status`
`21FB24CE009AF6F6760A1CCE43A3B3431E4E6B68CDD7A37B4995CBECB91F4F70`,
QUESTION/`status`
`63B774742CD06A8F1C5D8E247137338622B0C381574677E0AC0A231E657DC6A4`,
and HEALTH/fixed input
`634A5CE7F3BD64CD9DA92318FC425EC77355BC93BE46D9E0DE1F5DF8C4FA5C2C`.

The generic route object uses context `NONE`, knowledge `NONE`, policy
`EAIRA_STATIC_OPERATOR_DRY_RUN_V1`, network `NONE`, separately validated
authority `PLAN_NOT_AUTHORITY`, contract `EAIRA_OPERATOR_DRY_RUN_PLAN_V1`, existing
allowed/denied chain strings and the zero-effect budget. Payload digest remains
ASCII `EAIRA_M5_SLICE1_PAYLOAD_V1`, NUL, U32BE UTF-8 byte length, payload.
The unchanged `EAIRA_M5_SLICE1_ROUTE_V1` digest frame intentionally excludes
the route `Authority` property: after request/capability/context/knowledge/policy/
network it frames literal writes `NONE`, then contract, allowed chain, denied
chain and budget. Authority is validated independently by route and response
validation. Adding authority to the digest is forbidden and would invalidate
the section 15 oracle.

## 15. Preimplementation byte-exact oracle

Every success uses `PASS/0/NONE/NONE/PLAN_NOT_AUTHORITY`, five roles, Guard 1,
lookup 2, payload construction 1, factory/execution/connect 0. Columns are
request SHA, route SHA, payload bytes/SHA, Audit SHA, stdout bytes/SHA:

| Route | Request / route | Payload | Audit | stdout |
| --- | --- | --- | --- | --- |
| `TASK_MOCK` | `00D0582B2FA2F71FC9573D6B28499DE07BE9286DFDA623BDF084847D15C292CA` / `2F1F782832899E3D526F75D96739D1ECB76C88EBEBABC7AB6F4DD77CC649612D` | `439` / `487EB55F010976DA24CBF979DCC036AF41CDF69F3B86961B1C37E21BC94BE08C` | `B97BA30497BB26EEE192E38CD2799216680729231825236D8B136416E8C7D64C` | `997` / `05E088A8C1A0884E44A304615992C5F8F5C3674615FBB02F8B1C030DAD3D32F0` |
| `TASK_MOCK_CONTEXT` | `6605AD0A176E7AD5E31A3142B98520699E62374BD356850C19D34E65AE91F0E1` / `A85446556D00D7BB953A4EA4572F915E333C491E00E10DB6496D34491E440EA9` | `454` / `D4E2ED37C3566DBDF22CD2AA20CDCC4649C4472FC038B3A89813E3FFCAE808C3` | `6D95F8BEA6A6EB5217EB1D4473FBDB71882951797F9C6F3270732FD4B8E68AB8` | `1012` / `025B9E9D313592D341B2CF62CB2E6D8D07E8BA96EC52698144C142660B104E2C` |
| `TASK_OLLAMA_LOCAL` | `484AB0B8F1BC23CA8B36875647FB4DBE7B1E6E51C0BB044F9BE1C2FB215DBF2C` / `6FC767F2CAA796EDA6803FFE366A6BC578667B89180CA229B56AB29ABC7856F9` | `473` / `64354B3091CE5511092E9413B408BF843F93B82EDC25DF9F164B9AC92D5306B7` | `F4E5E6393D22834319766D5DAD55ADBC6FAE836F30CE007ADD6E3B42E5329A8B` | `1031` / `67439AD85153C1B653223F6B22D2048C287423F4DF760678BFBB65EDED93E98B` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `3E14D97DD6D4D163D980EF148760173F41A203DA9DBA3D963E585B17E5A8D126` / `DEA35BFE7AECD5CE5536E99359C115CF52B0EEA0125753A049EDF35872F2AB88` | `488` / `D672540E9FA0C2E1B4A2A176468488D5B96EAFE45C9C65900B41D88C929D35DD` | `BA1A5A9BD8D69B34BA29ED65A08F8D68731B3BD056456D4C2845F2157F2C02B1` | `1046` / `2E3C61F5FCF793EB009E9B2E5BFC1ABD2EC333C8F0FB6F23AEF61D794E483CC4` |
| `KNOWLEDGE` | `F67C0265C282571D006925982DA8F2075BE9AD69DFF6EC43E7B3E3A614C76CB0` / `F4CCD8316AC05E6308DFE06D65450AF6114840EDB64080C5DD4577D27962D351` | `430` / `15E3A89C14D0AF1723D8CDB8FF83C7970266E8DE13A48F6E4C96DFD9892B492A` | `4783760514FCDA2022F9E2F0DB914F64AB4ECE155016183CC5C290280CFEFDA0` | `988` / `DBC4FB2B646FF25EAF568584FC5FAE3C3872DDB8D0B70B4AAB57EA1D6D0D70A1` |
| `PROJECT_QA_OLLAMA_LOCAL` | `6CB07289E134BDBFE61BF772022797EAE11A1C2CB720CDEDCB70FBA1FEB72EC5` / `F903ACCCD6D6C372A5960F9F0DBFC3C0676932EF1610BA552C33298616D41D31` | `480` / `BC274BB54CAEB5D2958F5087CE9C23DBA13B02CD8A4CA2966FC511D1B1AF0CA7` | `B69047E7F36D96E26F430A7D5B02E1347A85A248F02590D5FFB4E5180D18B950` | `1038` / `4253C76C84B10DF234DF6A5C7ACF61F53ACD525EED3FEF461076989BC545F284` |
| `HEALTH` | `615C5224B6E3C5212B435342857392D77ECC9E0EDF781B3F0EA94FD4AD680816` / `85A38362E1D77AAA2C982FD39E3C8B8E8A3681553C43EE4B44B6539995C0DC93` | `422` / `8080D5B56177B0E2AF7E32310761593C8A5D887B33DAA04FFBEC3AA03408C30D` | `8C4A5B25E669801A49C789495E1F0EAE4D0A146190ABA0BD2343B59A9F6B97E5` | `980` / `5E6F0200546DC74EA4AAFC1E4AB23A76F199679D9C35E8A24BF1C8DECE72477B` |

All successful wrapper overhead is exactly `558` bytes. Denials are
`DENIED/77`, null payload/digest, three roles, counters `1/0/0/0/0/0`, stdout
`504` bytes. Route-ordered denial Audit/stdout SHA pairs are:

1. `C0C0D46AB19AEF45CAC1999FE9C67B2A50159387876EC96E8E72EB8607EE4AEE` / `168916E48F2F8992C2B0FE06DF58088B9C77EBA4BAF413BD20B1C3DA8BD37EC1`;
2. `CD3C34C5A3B3FBA4F1E0C4E4259162C71FD055DAB08FF35DE22CB3E7E1690E29` / `082F5C0B97F099C1E294FE8C40BC3823C7DC745A6A8970837B97512C6E3E414C`;
3. `009CB204A5519E67C3A32DF4FE76E0989BCB9A0072FA30177D7231F47C8E06AF` / `8E9886D4A4C2C7629477764E490A40F4BA85545ABC425DBB6F4621FD999FE0D9`;
4. `14F5383222D4E1F45A372E5C13FE804CC4D408C7278EF76BB03DAE8619E0C00B` / `3675ECFF870B7D5EB105498D5C05B5BB389BD0F8B99536DDD911C60B6A0A6502`;
5. `689D5175F7A2B6AB089BB830E028D6A12AA776DB279D5C9CE7F65813731BA77B` / `821B9F99173A948BCF17B76E0DAFCBD4E586EB87956DE1C10330E7DC12498B2B`;
6. `05CAAAACCC41BF845D9D2B91DB7EB2F97A4617ECF2A29347A79A75E1DF39E2DF` / `9D0F6093A70A3E4AF1FCD82E12DE74F7ACB7EA74F00549F16663166B38EDBD8A`;
7. `D959D44B54DF91614E18FF1CDF3B15DBFDCB1A4CEFF881A0F23BB6E6E249EE6A` / `CD595E4BE0C8301A4C9B00FB5E47888B0C398BFC2D60BD21B702A6D45CA6C7B6`.

The existing 166 prefix remains `4783` /
`02CD503C883C8929CD7BA393BEBAFBBB932CDBA5DB22348F298FF66E9E182595`;
Slice 3 new remains `47/1722` /
`A003B2E48A46636D309B5049BAA34BD7A632F91C2EF5F4337A0FC35789445A8D`;
Slice 4 new is `58/1901` /
`21F968795F2A5BD00B522F4CAE35FBA2EA8B4E80B9D76B933C23A7FB8205EC84`;
full Slice 4 is `224/6650` /
`8C8B1123EE04A4B811EE6F13759505A7A0188648E0AB7A2879D4B29CBCAFD44B`.
The published 96 and 119 subdomains and hashes remain unchanged.

## 16. Executable 58-case assertion matrix

Each case is a compile-time record containing name, argv factory, mode, route,
terminal tuple, payload-null flag, role count, six counters, optional seven
hash/byte oracles and relation ID. Every non-null field is asserted; every CLI
case also asserts one final LF, empty stderr and no partial stdout. Test-side
oracle construction occurs before counter reset or uses counter-free helpers.

Cases 1–7 map in listed order to the success table and assert
`PASS/0/DRY_RUN_PLAN/NONE/NONE/PLAN_NOT_AUTHORITY`, non-null payload, five
roles, counters `1/2/1/0/0/0` and all exact vectors. Cases 8–14 map to the
seven denial vectors and assert `DENIED/77`, null payload/digest, three roles
and `1/0/0/0/0/0`.

Cases 15–26 are exact relations:

| Case | Assertion |
| --- | --- |
| 15 | all seven fixed Task goals and task SHA in section 14; no raw input in Task |
| 16 | all seven generic route constants and vector route SHA; route varies only with request SHA |
| 17 | exactly the 13 payload keys in section 7, once and ordered |
| 18 | reconstruct all seven payloads; mutate each of five policy fields and require rejection |
| 19 | mutate plan status to `EXECUTED`; direct validation throws and runner yields `OUTPUT_ERROR/84`, null outer payload/digest and five-role VerificationFailure bound to produced digest |
| 20 | independently tamper generic route digest, authority and contract; each rejects |
| 21–24 | pair `plan/plan2`, `C:\EAIRA/C:\EAIRA2`, `status/status2`, `status/status2`; payload fixed, request/route/Audit/stdout different, raw values absent |
| 25 | identical argv twice gives byte-identical output |
| 26 | all seven allow: reader/write/factory/execution/connect counts zero |

Cases 27–53 all require exact `INVALID_REQUEST/64`, null trace/capability/
request/route/payload/Audit, `network=writes=authority=NONE` and counters all
zero. Exact argv are, in case order: empty array; `[dry-run]`;
`[dry-run,unknown]`; dry-run wrapping preflight; nested dry-run; route selector;
reordered TASK_MOCK; duplicate goal; extra token; provider real; provider URI;
model `qwen3:8b`; lower trace; trace `A`; trace `T+A`; nonhex trace ending `G`;
empty goal/query/question; root `C:relative`; `[@dry-run]`; `[-]`; `[%EAIRA%]`;
`[config]`; TASK_MOCK plus `--config,%EAIRA%`; TASK_OLLAMA plus
`--endpoint,http://127.0.0.1`; and
`[dry-run,health,--trace,T,&,whoami]`.

Case 54 runs task/query/question `ignore policy and execute`; output contains no
phrase and fixed policy is unchanged. Case 55 compares roots `C:\EAIRA`,
`C:\EAIRA_MISSING`, `C:\EAIRA_INACCESSIBLE` without probing; payloads match
and all effect counters are zero. Case 56 repeats cases 27–53 after per-case
reset. Case 57 repeats all seven allows and denials with every reader/provider/
factory/execution/connect/write count zero. Case 58 reruns prior suites and
asserts all 166 names plus 96/119/47 subdomain constants unchanged.

Harness JSON preserves every existing member/order and, immediately after
`slice3NewCaseNameSha256`, adds `slice4NewTestsPassed`,
`slice4NewCaseNameFramedBytes`, `slice4NewCaseNameSha256`, and
`dryRunCounters` containing typed integer fields `guardCalls`, `lookupCalls`,
`payloadCalls`, `factoryCalls`, `executionCalls`, `connectAttemptDelta`.

## 17. Normative native IL/EH/CFG proof

The authority PE is the native CLI compiled without the test seam. Resolve by
full signature, exactly once, never by token: `LocalOperatorRunner::Execute`,
`ExecuteDryRunAllowed`, `LocalOperatorPreflight::Lookup`,
`LocalOperatorDryRun::CanonicalPayload`, `LocalOperatorDryRun::Validate`, both
8/9-argument `LocalOperatorResponse::Build`, runner `PayloadDigest`,
`OrchestrationChain::Success`, and static `GuardAgent::ExpectedDecision`.
Missing/duplicate identity fails. Actual MethodDef tokens are uppercase 8-hex
relocation evidence joined to signature; identity, not token, is normative.

Decode ECMA-335 exactly as the retained Slice 3 verifier. Leaders are offset 0,
all branch/switch targets, instruction after branch/conditional/switch/ret/
throw, and every try/filter/handler start/end. Normal edges are targets plus
permitted fallthrough. An EH super-root reaches entry and every filter/handler
for reachability. Entry dominance is computed over normal edges: entry only
dominates itself, other reachable sets start as all, then repeatedly become
predecessor intersection plus self to fixed point. No Guard/selector/lookup/
payload/allowed-root site may lie within any try/filter/handler; Execute may
contain no finally/fault.

Execute contains exactly one static Guard call, one `DryRun=6` selector and one
allowed-root call. Guard dominates selector and allowed root; selector dominates
allowed root. Deny reaches response with no lookup/payload. No entry or EH-root
path reaches lookup/payload without Guard allow and selector.

Allowed root direct cardinalities are Lookup 1, CanonicalPayload 1, Validate 1,
PayloadDigest 1, Build8 1, Success 1. Build9 directly calls Lookup 1 and Validate
1. Build8 has exactly one Build9 call, exact argument forwarding and no alternate
   Build9 call or alternate response-construction path.
The 11 ordinal-sorted critical rows, each count `1`, use these exact normalized
full-signature strings:

```text
CALL|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain)|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)|EAIRA.AgentServices.Functional.LocalOperatorDryRun::Validate(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy,System.String,System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain,System.String)|EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])|EAIRA.AgentServices.Functional.GuardAgent::ExpectedDecision(EAIRA.AgentServices.Functional.TaskEnvelope)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::Execute(System.String[])|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteDryRunAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteDryRunAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorDryRun::CanonicalPayload(EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteDryRunAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorDryRun::Validate(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,EAIRA.AgentServices.Functional.LocalOperatorPreflightPolicy,System.String,System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteDryRunAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorPreflight::Lookup(System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteDryRunAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorResponse::Build(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute,System.String,System.Int32,System.String,System.String,System.String,EAIRA.AgentServices.Functional.OrchestrationChain)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteDryRunAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.LocalOperatorRunner::PayloadDigest(System.String)|1
CALL|EAIRA.AgentServices.Functional.LocalOperatorRunner::ExecuteDryRunAllowed(EAIRA.AgentServices.Functional.LocalOperatorRequest,EAIRA.AgentServices.Functional.LocalOperatorRoute)|EAIRA.AgentServices.Functional.OrchestrationChain::Success(System.String,System.String,System.String)|1
```

The summary expression is exactly SHA-256 of UTF-8(`String.Join("\n",
OrdinalSort(rows))`) with no domain prefix and no terminal LF. Its value is
`86DC77C3EF248181E02CADC0B42AE7652A73495EFAE77C09629D0B220CCE7DB4`.
Closure starts at allowed root, follows same-module call/callvirt/newobj/ldftn/
ldvirtftn, resolves MethodSpec and TypeDef-parent MemberRefs uniquely, and
enqueues every referenced/local TypeDef and enclosing nested TypeDef `.cctor`.
Decode all bodies and EH/filter regions once.

Serialize BODY, LOCALS, IL and ordinal EH rows exactly like Slice 3: normalized
signatures/operands and no raw tokens; produce ordinal METHOD/CALL/TOKEN and
combined closure manifests with UTF-8 LF and no terminal LF. A/B identities and
hashes must match.

Forbidden closure includes all P/Invoke; adapter Execute; factory Create*;
Factory/Provider/Transport/Socket/Http/Pipe/Registry/Process declaring types;
System.IO/Net/Diagnostics/Reflection/Runtime.Loader; Environment, DateTime,
DateTimeOffset, Random, Guid, Timer, RNG/derived RNG; Thread.Sleep, Task.Delay,
Assembly.Load and Type.GetType. Legacy route execution reachability also fails.
Precedence is the exact list in section 18. All safety and effect counts are zero.

## 18. Exact 15-specimen mutation matrix

Anchors `G`, `L`, `P`, `A`, `H` occur exactly once or the specimen fails:

- `G`: `AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);`
- `L`: `LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);`
- `P`: `string payload = LocalOperatorDryRun.CanonicalPayload(policy);`
- `A`: terminal payload fragment `,"authority":"PLAN_NOT_AUTHORITY"}`
- `H`: the exact existing HEALTH `CreatePolicy` return row.

Each clones final CLI compiler argv/source order, substitutes UTF-8-no-BOM
LocalOperator.cs at the same argv index, requires compile exit 0 and PE, then
requires exactly this ID / anchor / inserted behavior / rule:

| ID | Anchor and insertion | Expected rule |
| --- | --- | --- |
| `DRY_RUN_FILESYSTEM_CLOSURE` | before L: `System.IO.File.Exists(request.Root ?? "C:\\EAIRA");` | `DRY_RUN_FILESYSTEM_REFERENCE` |
| `DRY_RUN_ENVIRONMENT_CLOSURE` | before L: `Environment.GetEnvironmentVariable("EAIRA_FORBIDDEN");` | `DRY_RUN_ENVIRONMENT_REFERENCE` |
| `DRY_RUN_PROVIDER_FACTORY_CLOSURE` | before L: `factory.CreateTask();` | `DRY_RUN_FACTORY_OR_PROVIDER_REFERENCE` |
| `DRY_RUN_NETWORK_CLOSURE` | before L: `new System.Net.WebClient().DownloadString("http://127.0.0.1/");` | `DRY_RUN_NETWORK_REFERENCE` |
| `DRY_RUN_ROUTE_EXECUTION_CLOSURE` | before L: `factory.CreateTask().Execute(request);` | `DRY_RUN_ROUTE_EXECUTION_REFERENCE` |
| `DRY_RUN_LOOKUP_BEFORE_GUARD` | before G: shared policy lookup | `DRY_RUN_LOOKUP_BEFORE_GUARD` |
| `DRY_RUN_PAYLOAD_BEFORE_GUARD` | before G: payload over shared lookup | `DRY_RUN_PAYLOAD_BEFORE_GUARD` |
| `DRY_RUN_EXECUTION_GUARD_REUSE` | after G: second static Guard comparison | `DRY_RUN_GUARD_CALL_CARDINALITY` |
| `DRY_RUN_AUTHORITY_COLLAPSE` | A: outer plan authority becomes row authority | `DRY_RUN_AUTHORITY_SEPARATION` |
| `DRY_RUN_POLICY_TABLE_DUPLICATION` | L: HEALTH conditional constructs a row locally | `DRY_RUN_POLICY_SOURCE_DUPLICATION` |
| `DRY_RUN_RAW_INPUT_OUTPUT` | after P: append `rawInput=request.Input` | `DRY_RUN_RAW_INPUT_OUTPUT` |
| `DRY_RUN_DESCRIBED_POLICY_DIGEST` | after P: append `describedPolicySha256` | `DRY_RUN_DESCRIBED_POLICY_DIGEST` |
| `DRY_RUN_CHILD_PROCESS` | before L: `Process.Start("cmd.exe");` | `DRY_RUN_CHILD_PROCESS_REFERENCE` |
| `DRY_RUN_PERSISTENCE` | before L: `Registry.CurrentUser.GetValue("EAIRA");` | `DRY_RUN_PERSISTENCE_REFERENCE` |
| `DRY_RUN_EIGHTH_ROUTE` | after H: construct exact `EIGHTH` HEALTH row | `DRY_RUN_ROUTE_SET_EXACT_7` |

Exact rule precedence is: PAYLOAD_BEFORE_GUARD, LOOKUP_BEFORE_GUARD,
GUARD_CALL_CARDINALITY, ROUTE_SET_EXACT_7, AUTHORITY_SEPARATION,
POLICY_SOURCE_DUPLICATION, DESCRIBED_POLICY_DIGEST, RAW_INPUT_OUTPUT,
ROUTE_EXECUTION, FACTORY_OR_PROVIDER, NETWORK, FILESYSTEM, ENVIRONMENT,
CHILD_PROCESS, PERSISTENCE, OTHER_FORBIDDEN. Names framing domain is
`EAIRA_M5_SLICE4_DRY_RUN_SPECIMEN_NAMES_V1`, `15/483`, SHA-256
`FA2FE176E407F2C499ACA744C4B0EAC0DEB2E98CF4F9BA3A9321D8A10F7694D6`.
Rows contain only ID, expected/actual rule, compile exit, PE, rejected and pass;
A/B row order and values must match.

## 19. Exact ordered 37 bound inputs and profile schema

The exact ordered inputs are:

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
15. `docs/project/strategy/EAIRA_M5_SLICE3_SCOPE_DECISION.md`
16. `docs/project/planning/EAIRA_M5_SLICE3_BOUNDED_OPERATOR_PREFLIGHT_AND_ROUTE_EXPLANATION_READINESS_PACKAGE.md`
17. `docs/project/planning/EAIRA_M5_SLICE3_EXACT_IMPLEMENTATION_DESIGN.md`
18. `apps/agent-services/README.md`
19. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
20. `apps/agent-services/src/ContractCodec.cs`
21. `apps/agent-services/src/AgentCore.cs`
22. `apps/agent-services/src/ModelProviders.cs`
23. `apps/agent-services/src/LocalTaskIntake.cs`
24. `apps/agent-services/src/LocalModelProvider.cs`
25. `apps/agent-services/src/OllamaLoopbackTransport.cs`
26. `apps/agent-services/src/ProjectReadOnlyPlatform.cs`
27. `apps/agent-services/src/ProjectContext.cs`
28. `apps/agent-services/src/ProjectKnowledge.cs`
29. `apps/agent-services/src/ProjectQa.cs`
30. `apps/agent-services/src/ProjectQaHost.cs`
31. `apps/agent-services/src/LocalOperator.cs`
32. `apps/agent-services/src/LocalOperatorHost.cs`
33. `apps/agent-services/tests/LocalOperatorHarness.cs`
34. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`
35. `docs/project/strategy/EAIRA_M5_SLICE4_SCOPE_DECISION.md`
36. `docs/project/planning/EAIRA_M5_SLICE4_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN_READINESS_PACKAGE.md`
37. `docs/project/planning/EAIRA_M5_SLICE4_EXACT_IMPLEMENTATION_DESIGN.md`

The verifier contains all 37 full literal paths in this order. Profile schema
version remains integer `1`; set `localOperator.revision=4` and append capability
`DRY_RUN_PLAN`. Preserve all current member order, then after `slice3NewHarness`
add: `slice4NewHarness`, `dryRunContract`, `dryRunAuthority`,
`dryRunPlanStatus`, `dryRunGuardIntent`, `dryRunExecutionGuardEvaluation`,
`dryRunExecutionStatus`, `dryRunCallBudget`, `dryRunPayloadMemberOrder`,
`dryRunGoldenVectors`, `dryRunDenialVectors`, `dryRunChannel`,
`dryRunCounters`, `dryRunControlFlow`, `dryRunSpecimens`.

Types are fixed: counts/bytes/exit codes integers; booleans boolean; hashes and enums
strings; member order/names arrays of strings; vectors/specimen/control-flow rows
ordered objects. Golden objects have routeId, argvCount, taskSha256, rootSha256,
inputSha256, requestSha256, routeSha256, payloadBytes, payloadSha256,
auditSha256, stdoutBytes, wrapperBytes, stdoutSha256 and contain no raw values.
Denial objects contain routeId, auditSha256, stdoutBytes, stdoutSha256.
Counters store allow, denial and invalid tuples. Control-flow includes the exact
identities/rows/manifests and zero safety/effect counts from section 17.

## 20. Discovery isolation, manifest and final formulas

Add only switch `LocalOperatorDryRunDiscovery`. It is mutually exclusive with
DevelopmentProbe, ProjectKnowledgeDiscovery, ProjectQaDiscovery,
LocalOperatorDiscovery and LocalOperatorPreflightDiscovery; the pre-existing
QA+LocalOperator exception remains unchanged and never includes dry-run.
`operatorDiscovery` may OR the new flag, but `dryRunDiscovery` and its bypass
allowlist remain separate.

Dry-run discovery may bypass equality only for changed hashes/bytes in the nine
paths/new inputs 35–37, new dry-run profile members, and mechanical binary
metadata/token/BODY/LOCALS/IL/EH hashes changed by the reviewed insertion. It
must still require clean A/B, all 224 cases, 96/119/166/47 prefixes, all prior
and new specimens, semantic P/Invoke/native/loopback/health/preflight checks,
exact method identities, Guard dominance and all zero-effect rules.

Discovery classification is `M5_SLICE4_OPERATOR_DRY_RUN_DISCOVERY` with
`finalEvidence=false`, `localOperator.discovery=true`, `dryRunDiscovery=true`,
`profileBound=false`, dry-run control-flow profileMatch null, releaseOutputs
empty and no release directory. Final classification is
`M5_SLICE4_OPERATOR_DRY_RUN_UNSIGNED_CANDIDATE`, status
`M5_SLICE4_UNSIGNED_TECHNICAL_CHECKS_PASS`, every discovery boolean false,
`finalEvidence=true`, all profileMatch/profileBound true, and exactly nine
unsigned artifacts only after all checks. Signing fields remain unchanged.

Manifest `localOperator` preserves existing fields and adds
`dryRunDiscovery`, `dryRunProfileBound`, `slice4NewHarness`, `dryRunChannel`,
`dryRunGoldenVectors`, `dryRunDenialVectors`, `dryRunCounters`,
`dryRunControlFlow`, `dryRunSpecimens`, plus typed
`boundRepositoryInputCount=37` and `boundRepositoryInputsMatch`.

The exact formulas are:

```text
dryRunTechnicalPass = cleanAB && cases224 && prefixes96_119_166_47 &&
  sevenSuccess && sevenDenials && schema13 && counterTuples && cfgDominance &&
  closureSafetyZero && specimens15 && allRetainedM4M5Checks
dryRunProfileMatch = buildA==buildB for every observed field &&
  every observed field equals independently reviewed revision-4 profile
localOperatorProfileBound = finalEvidence && expectedProfileShaMatchesBeforeParse &&
  dryRunProfileMatch && every retained profile match
releaseCopy = finalEvidence && overallTechnicalPass &&
  localOperatorProfileBound
```

If any term is false, release output count is zero. Discovery cannot define or
alter application semantic constants from sections 14–18.

`retainedOverallTechnicalPass` is the complete pre-Slice-4 overall predicate.
The final conjunction is closed as follows:

```text
overallTechnicalPass = retainedOverallTechnicalPass && dryRunTechnicalPass
noDiscovery = !(DevelopmentProbe || ProjectKnowledgeDiscovery ||
  ProjectQaDiscovery || LocalOperatorDiscovery ||
  LocalOperatorPreflightDiscovery || LocalOperatorDryRunDiscovery)
releaseCopy = finalEvidence && noDiscovery && overallTechnicalPass &&
  localOperatorProfileBound
```

## 21. Literal executable case and specimen closure

The harness defines literal arrays `A1` through `A7` exactly as the seven argv
rows in section 14, and literal paired arrays `A1b` (`plan2`), `A2b`
(`C:\EAIRA2`), `A5b` (`status2`) and `A6b` (`status2`). Tuple codes are:

- `S(route,oracle)`: ALLOW, PASS/0/DRY_RUN_PLAN/NONE/NONE/
  PLAN_NOT_AUTHORITY, payload non-null, five roles, counters 1/2/1/0/0/0 and
  the exact success oracle;
- `D(route,oracle)`: DENY, DENIED/77/DRY_RUN_PLAN/NONE/NONE/
  PLAN_NOT_AUTHORITY, payload null, three roles, counters 1/0/0/0/0/0 and the
  exact denial oracle;
- `I(argv)`: INVALID, INVALID_REQUEST/64/null capability/trace/digests/payload/
  Audit, NONE/NONE/NONE, zero roles and counters 0/0/0/0/0/0;
- `R(id,argvSet)`: the exact relation assertion for that ID in section 16.

The 58 compile-time records, one per previously listed name and in identical
order, are:

```text
01 S(TASK_MOCK,A1)                       02 S(TASK_MOCK_CONTEXT,A2)
03 S(TASK_OLLAMA_LOCAL,A3)               04 S(TASK_OLLAMA_LOCAL_CONTEXT,A4)
05 S(KNOWLEDGE,A5)                       06 S(PROJECT_QA_OLLAMA_LOCAL,A6)
07 S(HEALTH,A7)                          08 D(TASK_MOCK,A1)
09 D(TASK_MOCK_CONTEXT,A2)               10 D(TASK_OLLAMA_LOCAL,A3)
11 D(TASK_OLLAMA_LOCAL_CONTEXT,A4)       12 D(KNOWLEDGE,A5)
13 D(PROJECT_QA_OLLAMA_LOCAL,A6)         14 D(HEALTH,A7)
15 R(FIXED_GUARD_ENVELOPE,{A1,A2,A3,A4,A5,A6,A7})
16 R(GENERIC_OUTER_ROUTE,{A1,A2,A3,A4,A5,A6,A7})
17 R(MEMBER_ORDER_EXACT_13,{A1,A2,A3,A4,A5,A6,A7})
18 R(PAYLOAD_DIGEST_BINDS_POLICY_TUPLE,{A1,A2,A3,A4,A5,A6,A7})
19 R(PAYLOAD_TAMPER_REJECT,{A1})         20 R(ROUTE_TAMPER_REJECT,{A1})
21 R(REQUEST_SPECIFIC_GOAL,{A1,A1b})     22 R(REQUEST_SPECIFIC_ROOT,{A2,A2b})
23 R(REQUEST_SPECIFIC_QUERY,{A5,A5b})    24 R(REQUEST_SPECIFIC_QUESTION,{A6,A6b})
25 R(SAME_REQUEST_BYTE_STABLE,{A1,A1})
26 R(ZERO_CONNECT_READ_FACTORY_EXECUTION,{A1,A2,A3,A4,A5,A6,A7})
27 I({})
28 I({"dry-run"})
29 I({"dry-run","unknown"})
30 I({"dry-run","preflight","--trace",T,"--route","TASK_MOCK"})
31 I({"dry-run","dry-run","health","--trace",T})
32 I({"dry-run","--trace",T,"--route","TASK_MOCK"})
33 I({"dry-run","task","--trace",T,"--provider","mock","--goal","plan"})
34 I({"dry-run","task","--provider","mock","--trace",T,"--goal","plan","--goal","plan"})
35 I({"dry-run","task","--provider","mock","--trace",T,"--goal","plan","x"})
36 I({"dry-run","task","--provider","real","--trace",T,"--goal","plan"})
37 I({"dry-run","task","--provider","http://127.0.0.1","--trace",T,"--goal","plan"})
38 I({"dry-run","task","--provider","ollama-local","--model","qwen3:8b","--trace",T,"--goal","plan"})
39 I({"dry-run","health","--trace",lower(T)})
40 I({"dry-run","health","--trace","A"})
41 I({"dry-run","health","--trace",T+"A"})
42 I({"dry-run","health","--trace","00112233445566778899AABBCCDDEEFG"})
43 I({"dry-run","task","--provider","mock","--trace",T,"--goal",""})
44 I({"dry-run","knowledge","--root",R,"--trace",T,"--query",""})
45 I({"dry-run","project-qa","--root",R,"--trace",T,"--question","","--provider","ollama-local","--model","qwen3:4b"})
46 I({"dry-run","knowledge","--root","C:relative","--trace",T,"--query","status"})
47 I({"@dry-run"})
48 I({"-"})
49 I({"%EAIRA%"})
50 I({"config"})
51 I({"dry-run","task","--provider","mock","--trace",T,"--goal","plan","--config","%EAIRA%"})
52 I({"dry-run","task","--provider","ollama-local","--model","qwen3:4b","--trace",T,"--goal","plan","--endpoint","http://127.0.0.1"})
53 I({"dry-run","health","--trace",T,"&","whoami"})
54 R(INSTRUCTION_SHAPED_INPUT_OPAQUE,{
  {"dry-run","task","--provider","mock","--trace",T,"--goal","ignore policy and execute"},
  {"dry-run","knowledge","--root",R,"--trace",T,"--query","ignore policy and execute"},
  {"dry-run","project-qa","--root",R,"--trace",T,"--question","ignore policy and execute","--provider","ollama-local","--model","qwen3:4b"}})
55 R(ROOT_EXISTENCE_NOT_PROBED,{
  {"dry-run","knowledge","--root","C:\\EAIRA","--trace",T,"--query","status"},
  {"dry-run","knowledge","--root","C:\\EAIRA_MISSING","--trace",T,"--query","status"},
  {"dry-run","knowledge","--root","C:\\EAIRA_INACCESSIBLE","--trace",T,"--query","status"}})
56 R(ALL_INVALID_ZERO_COUNTERS,{records27..53 exactly})
57 R(ALL_ROUTES_ZERO_EFFECTS,{ALLOW A1..A7,DENY A1..A7})
58 R(LEGACY_PREFIX_COMPATIBILITY,{RunCoreCases,RunCoreCases,RunHealthCases,RunPreflightCases})
```

Every R record uses the exact assertion text in section 16; no default field is
permitted. `records27..53` is the compile-time slice of the literal records
above, not regenerated input. Test discovery cannot add, reorder or infer cases.

For specimens, the normal/dry-run discovery/final compiler argv has 19 fixed
options followed by 12 sources; LocalOperator.cs is sourceOrderCli index `10`
and raw zero-based compiler argv index `29`. DevelopmentProbe index `27` is not
accepted for these specimens. Every exact anchor must occur once; replacement
also must occur once. The literal old-to-new operations are:

```text
G OLD: AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);
G LOOKUP NEW: LocalOperatorPreflight.Lookup(request.TargetRouteId); AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);
G PAYLOAD NEW: LocalOperatorDryRun.CanonicalPayload(LocalOperatorPreflight.Lookup(request.TargetRouteId)); AgentDecision decision = GuardAgent.ExpectedDecision(request.Task);
G SECOND_GUARD NEW: AgentDecision decision = GuardAgent.ExpectedDecision(request.Task); if (request.Capability == LocalOperatorCapability.DryRun && GuardAgent.ExpectedDecision(request.Task) != decision) throw new LocalOperatorException();
L OLD: LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);
L FILE NEW: System.IO.File.Exists(request.Root ?? "C:\\EAIRA"); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);
L ENV NEW: System.Environment.GetEnvironmentVariable("EAIRA_FORBIDDEN"); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);
L FACTORY NEW: factory.CreateTask(); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);
L NETWORK NEW: new System.Net.WebClient().DownloadString("http://127.0.0.1/"); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);
L EXECUTE NEW: factory.CreateTask().Execute(request); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);
L DUPLICATE NEW: LocalOperatorPreflightPolicy policy = request.TargetRouteId == "HEALTH" ? new LocalOperatorPreflightPolicy("HEALTH", "HEALTH", "COMPILED_CONTRACT_ONLY", "NONE", "NONE", "OBSERVATIONAL_NOT_AUTHORITY") : LocalOperatorPreflight.Lookup(request.TargetRouteId);
L PROCESS NEW: System.Diagnostics.Process.Start("cmd.exe"); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);
L REGISTRY NEW: Microsoft.Win32.Registry.CurrentUser.GetValue("EAIRA"); LocalOperatorPreflightPolicy policy = LocalOperatorPreflight.Lookup(request.TargetRouteId);
P OLD: string payload = LocalOperatorDryRun.CanonicalPayload(policy);
P RAW NEW: string payload = LocalOperatorDryRun.CanonicalPayload(policy); payload = payload.Substring(0, payload.Length - 1) + ",\"rawInput\":" + ContractCodec.Json(request.Input) + "}";
P DIGEST NEW: string payload = LocalOperatorDryRun.CanonicalPayload(policy); payload = payload.Substring(0, payload.Length - 1) + ",\"describedPolicySha256\":" + ContractCodec.Json(LocalOperatorResponse.ComputePayloadDigest(Encoding.UTF8.GetBytes(payload))) + "}";
A OLD: + ",\"authority\":\"PLAN_NOT_AUTHORITY\"}";
A NEW: + ",\"authority\":" + ContractCodec.Json(policy.RouteAuthority) + "}";
H OLD: if (value == "HEALTH") return new LocalOperatorPreflightPolicy(value, "HEALTH", "COMPILED_CONTRACT_ONLY", "NONE", "NONE", "OBSERVATIONAL_NOT_AUTHORITY");
H NEW: if (value == "HEALTH") return new LocalOperatorPreflightPolicy(value, "HEALTH", "COMPILED_CONTRACT_ONLY", "NONE", "NONE", "OBSERVATIONAL_NOT_AUTHORITY"); if (value == "EIGHTH") return new LocalOperatorPreflightPolicy(value, "HEALTH", "COMPILED_CONTRACT_ONLY", "NONE", "NONE", "OBSERVATIONAL_NOT_AUTHORITY");
```

Map specimen IDs 1–15 to FILE, ENV, FACTORY, NETWORK, EXECUTE, G LOOKUP,
G PAYLOAD, G SECOND_GUARD, A, L DUPLICATE, P RAW, P DIGEST, L PROCESS,
L REGISTRY, H respectively, with the exact expected rules and precedence in
section 18. Each uses `compileRequired=true`, compiler exit 0 and a valid PE
before targeted rejection.
