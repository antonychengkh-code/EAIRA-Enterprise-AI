# EAIRA M5 Slice 1 Exact Implementation Design R3R2

## Control

- Design ID: `EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_V1R3R2`
- Date: `2026-09-12`
- Base: V1 + R2 + R3 + R3R1, except as replaced here
- Prior verdict: `FAIL/CANNOT_CLOSE`; P0 `0`, P1 `2`, P2 `3`
- State: `R3R2_READY_FOR_INDEPENDENT_EXACT_DESIGN_REVIEW`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R2_REVIEW`

## 1. Exact Project QA provider-factory compatibility

R3 section 2 is corrected to match the current `ProjectQaHost` inner catch boundary.

Provider factory creation is inside the provider-active inner try. Therefore:

- `ProjectQaException` thrown by provider factory maps to legacy `PROJECT_QA_ERROR`/82/`LOOPBACK_ONLY`, and operator `QA_VALIDATION_ERROR`/82/`LOOPBACK_ONLY`;
- any other provider-factory exception maps to legacy `LOCAL_PROVIDER_ERROR`/79/`LOOPBACK_ONLY`, and operator `PROVIDER_ERROR`/79/`LOOPBACK_ONLY`;
- neither provider-factory exception propagates from the shared runner;
- the provider object may be null and all tags/chat/digest flags remain zero/false;
- the network class is still `LOOPBACK_ONLY` because the published current inner catch assigns that class once provider construction is attempted.

Unexpected exceptions before provider-factory invocation continue to propagate from the shared runner exactly as current outer behavior does. The operator catches them and emits `ORCHESTRATION_ERROR`/83/`NONE`; the legacy host leaves them unhandled as today.

Corrected exact tuples:

| Cut-point | Tuple `snapshotFactory,read,providerFactory,tags,chat,pre,post` | Operator result |
|---|---|---|
| snapshot factory unexpected | `1,0,0,0,0,false,false` | ORCHESTRATION_ERROR / 83 / NONE |
| snapshot read caught context | `1,1,0,0,0,false,false` | CONTEXT_ERROR / 80 / NONE |
| snapshot read caught knowledge | `1,1,0,0,0,false,false` | KNOWLEDGE_ERROR / 81 / NONE |
| prompt/body caught QA error | `1,1,0,0,0,false,false` | QA_VALIDATION_ERROR / 82 / NONE |
| provider factory `ProjectQaException` | `1,1,1,0,0,false,false` | QA_VALIDATION_ERROR / 82 / LOOPBACK_ONLY |
| provider factory other exception | `1,1,1,0,0,false,false` | PROVIDER_ERROR / 79 / LOOPBACK_ONLY |
| preflight tags failure | `1,1,1,1,0,false,false` | PROVIDER_ERROR / 79 / LOOPBACK_ONLY |
| chat failure | `1,1,1,1,1,true,false` | PROVIDER_ERROR / 79 / LOOPBACK_ONLY |
| postflight tags failure | `1,1,1,2,1,true,false` | PROVIDER_ERROR / 79 / LOOPBACK_ONLY |
| decode failure | `1,1,1,2,1,true,true` | QA_VALIDATION_ERROR / 82 / LOOPBACK_ONLY |
| success | `1,1,1,2,1,true,true` | PASS / 0 / LOOPBACK_ONLY |

The observer stage boundary is corrected:

- stages through `BodyReady` (1–7), if not one of the existing caught exception types, use operator emergency orchestration error;
- `ProviderFactoryCalled` and later are handled by the runner's existing inner catch mapping above;
- no stage number or exception data is emitted.

## 2. Corrected orchestration chain mapping

`ORCHESTRATION_ERROR` always uses the R2 emergency chain:

`Planning/Candidate → Guard/Allow → Audit/Recorded`.

It never creates `Operations/Failed` and never creates Verification.

Operation-failure chains remain limited to caught route-operation outcomes:

- `CONTEXT_ERROR`;
- `KNOWLEDGE_ERROR`;
- `QA_VALIDATION_ERROR` when the failure occurred during snapshot/prompt/body/provider/decode work;
- `PROVIDER_ERROR`.

The exact operation-failure chain is:

`Planning/Candidate → Guard/Allow → Operations/Failed → Audit/Recorded`.

`OUTPUT_ERROR` after a produced operation payload uses:

`Planning/Candidate → Guard/Allow → Operations/Completed → Verification/Failed → Audit/Recorded`.

## 3. Harness mapping corrections

R3 cases 73–86 cover the crosswalk error rows not already exercised by earlier denial cases. The complete non-PASS mapping is:

- Task/Knowledge/QA denial: cases 26–28;
- Task invalid/provider/context: 73–75;
- Knowledge outer denial is additionally crosswalk-asserted by 76, with zero-factory behavior in 27;
- Knowledge invalid/error: 77–78;
- QA denial is additionally crosswalk-asserted by 79, with zero-factory behavior in 28;
- QA invalid/provider/context/knowledge/validation: 80–84;
- orchestration/output errors: 85–86.

No claim remains that cases 73–86 alone contain Task denial.

The `caseNames` schema, count 96, framed bytes 2409 and digest `0AAF52EE6A087B487B6497676F48BA7AD0D36CB987C149CC1BADAD9CA5D2FE68` remain unchanged.

## 4. Task counting-provider terminology correction

The exact numeric budgets in R3 remain unchanged. Their interpretation is:

- deterministic mock has no transport cache; its `Complete` method is invoked 10 or 6 times and produces two unique semantic values because replayed inputs are deterministic;
- Ollama local provider has two cache misses/unique semantic completions, so 10 or 6 method invocations produce exactly two chat calls;
- `UNIQUE_COMPLETIONS=2` means distinct Planning and Operations semantic results, not mock cache misses;
- tags/chat counters do not apply to mock and remain zero.

Harness providers expose separate `CompleteInvocations`, `UniqueSemanticValues`, `TagsCalls` and `ChatCalls`; no single ambiguous cache counter is used.

## 5. Normative Gate and bound-input correction

This R3R2 supersedes the live next-Gate identifiers in R3 and R3R1. The only next Gate is:

`SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R2_REVIEW`

The exact bound-input list is R3R1's ordered 27 paths with this file inserted immediately after `EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R1.md`. Final count is therefore `28`; all later paths retain relative order. Discovery requires exact count/order 28 and may bypass only hashes. Final mode binds all 28 hashes.

## 6. Live Ollama response compatibility remediation

The Slice 5 Local Operator compatibility adapter accepts the optional top-level `prompt_eval_cached_count` telemetry member only after the existing strict parser proves that the response is valid JSON, the member is unique and its value is numeric. The adapter then removes only that telemetry member before the unchanged fail-closed chat allowlist runs. Both Local Operator task and embedded project-QA routes use the adapter. Shared transport, parser and earlier ProjectContext outputs remain unchanged. Wrong types, escaped or ambiguous member encodings, duplicate raw markers and all other unknown members remain rejected; model content is neither exposed nor retained by the remediation evidence.

## 7. Authorization state

`SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3R2_REMEDIATION_AUTHORIZATION` is applied only to the two P1 and three P2 findings above.

No product implementation, live provider call, staging, commit or push is authorized by this document.
