# EAIRA M5 Slice 1 Scope Decision

## Decision control

- Decision ID: `EAIRA_M5_SLICE1_SCOPE_DECISION_V1`
- Date: `2026-09-12`
- Project Owner authority: authorization to complete the listed M5 Slice 1 Gate lifecycle
- Baseline: `c50ccb8d22926220ac8712aaaa9eaacff1e9de93`
- Selected scope: `M5S1_A_IN_PROCESS_THREE_ROUTE_ORCHESTRATOR`
- Decision state: `SELECTED_FOR_EXACT_DESIGN_ONLY`
- Implementation authority: `NOT_YET_EXERCISED`
- Next Gate: `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_AUTHORIZATION`

## Evidence considered

- V1 scope package: `EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_V1`
- V1 independent review: `PASS_WITH_REMEDIATION`, P0 `0`, P1 `0`, P2 `5`
- R1 package SHA-256: `C63C82AC4FCC50D40DB4CB496AA41F9946F81D2C71AE72C9C56BF915FCA91AA4`
- R1 independent review: `PASS_WITH_REMEDIATION`, P0 `0`, P1 `0`, P2 `2`
- R2 overlay SHA-256: `5C136CB6FB1E502C748FFD8F6FBF3AF3F35D0BD040F0FBCAA49CAB5F565E65A5`
- R2 independent review: `PASS`, P0 `0`, P1 `0`, P2 `0`

## Selected boundary

The selected Slice 1 scope is one unprivileged, unsigned, console-only, in-process operator executable with the exact `task`, `knowledge` and `project-qa` routes. It preserves legacy M4 CLIs and contracts, applies static Guard before every reader/provider factory, uses all five roles on allow and exactly Planning → Guard(DENY) → Audit on denial, and keeps the exact published M4 allowlists/provider restrictions.

The selected byte model is:

- embedded payload: at most `16,383` UTF-8 bytes excluding LF;
- wrapper: at most `2,048` UTF-8 bytes including LF;
- complete outer line: at most `18,431` UTF-8 bytes including LF.

`PROVIDER_BLOCKED`/exit `78` is not part of the Slice 1 outer contract. Legacy task behavior remains unchanged.

## Non-authority boundary

This decision authorizes exact design preparation only. It does not itself authorize product mutation, live provider calls, Windows or external-system changes, staging, commit or push. Any manifest widening beyond the conditionally approved ten product paths requires a separate decision and independent review.
