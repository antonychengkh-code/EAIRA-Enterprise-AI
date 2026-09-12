# EAIRA M5 Slice 1 Unified User-Mode Orchestrator Scope Package R2

## Document control

- Package ID: `EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_V1R2`
- Prepared: `2026-09-12`
- Baseline: `c50ccb8d22926220ac8712aaaa9eaacff1e9de93`
- State: `R2_CANDIDATE_READY_FOR_INDEPENDENT_SCOPE_REVIEW`
- Base package: `EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_V1R1`
- R1 independent verdict: `PASS_WITH_REMEDIATION`; P0 `0`, P1 `0`, P2 `2`
- Candidate: `M5S1_A_IN_PROCESS_THREE_ROUTE_ORCHESTRATOR` remains recommended and unselected
- Implementation authority: `NOT_GRANTED`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R2_REVIEW`

This R2 is a normative remediation overlay on R1. R1 remains applicable except where the two closed sections below replace it. The original V1 and R1 remain immutable review evidence.

## 1. Complete M4-to-outer status crosswalk

This table replaces R1 section 9.5 in full.

| M4 or outer condition | Outer status | Exit | Payload | Reachability in Slice 1 |
|---|---|---:|---|---|
| Task `PASS` | `PASS` | 0 | validated task object | reachable |
| Task `DENIED` | `DENIED` | 77 | null | reachable |
| Task `INVALID_REQUEST` | `INVALID_REQUEST` | 64 | null | reachable |
| Task `LOCAL_PROVIDER_ERROR` | `PROVIDER_ERROR` | 79 | null | reachable on Ollama route |
| Task `CONTEXT_ERROR` | `CONTEXT_ERROR` | 80 | null | reachable on context route |
| Knowledge `KNOWLEDGE_QUERY_OK` | `PASS` | 0 | validated knowledge object | reachable |
| Knowledge outer static Guard denial | `DENIED` | 77 | null | reachable; existing knowledge reader is not constructed |
| Knowledge `INVALID_REQUEST` | `INVALID_REQUEST` | 64 | null | reachable |
| Knowledge `KNOWLEDGE_ERROR` | `KNOWLEDGE_ERROR` | 81 | null | reachable |
| QA `PROJECT_QA_OK` | `PASS` | 0 | validated QA object | reachable |
| QA `DENIED` | `DENIED` | 77 | null | reachable |
| QA `INVALID_REQUEST` | `INVALID_REQUEST` | 64 | null | reachable |
| QA `LOCAL_PROVIDER_ERROR` | `PROVIDER_ERROR` | 79 | null | reachable |
| QA `CONTEXT_ERROR` | `CONTEXT_ERROR` | 80 | null | reachable |
| QA `KNOWLEDGE_ERROR` | `KNOWLEDGE_ERROR` | 81 | null | reachable |
| QA `PROJECT_QA_ERROR` | `QA_VALIDATION_ERROR` | 82 | null | reachable |
| Outer validation/chain failure | `ORCHESTRATION_ERROR` | 83 | null | reachable only through fail-closed internal validation |
| Outer byte/serialization failure | `OUTPUT_ERROR` | 84 | null | reachable only through fail-closed output validation |

The valid outer status enum is exactly:

`PASS`, `DENIED`, `INVALID_REQUEST`, `PROVIDER_ERROR`, `CONTEXT_ERROR`, `KNOWLEDGE_ERROR`, `QA_VALIDATION_ERROR`, `ORCHESTRATION_ERROR`, `OUTPUT_ERROR`.

`PROVIDER_BLOCKED` and exit `78` are not part of the Slice 1 outer contract. The closed Slice 1 commands expose only the enabled deterministic mock and exact pinned Ollama provider; the legacy task `real` provider form is not accepted. A request containing `real` or any other provider value returns `INVALID_REQUEST`/`64` before provider construction. The legacy task CLI and its existing `PROVIDER_BLOCKED` behavior remain unchanged.

All R1 presence/null rules continue to apply. In particular, no error or denial emits a payload or payload digest, and no invalid request emits a partially validated value.

## 2. Corrected least-authority byte model

This section replaces every R1 reference to the `18,432` complete-line limit and its boundary vectors.

- Embedded validated M4 JSON object: maximum `16,383` UTF-8 bytes, excluding LF.
- Complete wrapper overhead: maximum `2,048` UTF-8 bytes, including every outer field name/value, punctuation and the final LF.
- Complete outer line: maximum `18,431` UTF-8 bytes, including LF.
- Arithmetic invariant: `16,383 + 2,048 = 18,431`.
- Exact implementation design must enumerate the maximum wrapper bytes and prove `wrapperBytes <= 2,048`.
- The writer must byte-count the complete line before its sole stdout write.
- Boundary acceptance vectors are exactly `18,430` accepted, `18,431` accepted and `18,432` rejected with `OUTPUT_ERROR`/`84` and no partial output.
- Task payload is subject to the new operator-only `16,383`-byte embedded-object cap; the legacy task CLI remains unchanged.
- Knowledge and QA already cap their complete legacy line at `16,384` including LF, so their JSON object is at most `16,383` bytes.
- No later design may widen any of these values without a separate scope remediation and independent review.

## 3. Gate insertion and completion condition

The following remediation Gates are inserted after R1 review:

1. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R2_REMEDIATION_AUTHORIZATION` — applied to the two bounded P2 findings.
2. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R2_REVIEW` — next.

If R2 review passes with no unresolved P1/P2 blocker, the next Gate is:

`SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_SCOPE_SELECTION`

No implementation, controlled-state mutation, staging, commit or push is authorized by this R2 overlay.
