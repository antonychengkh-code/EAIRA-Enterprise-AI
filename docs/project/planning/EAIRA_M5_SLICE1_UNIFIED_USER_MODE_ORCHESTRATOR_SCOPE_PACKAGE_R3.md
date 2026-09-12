# EAIRA M5 Slice 1 Scope Package R3 — Exact Wrapper Bound

## Control

- Package ID: `EAIRA_M5_SLICE1_SCOPE_PACKAGE_V1R3`
- Date: `2026-09-12`
- Base: R1 plus normative R2 overlay
- Reason: exact-design review P1 wrapper-proof remediation exposed an unreachable R2 acceptance boundary
- State: `R3_READY_FOR_INDEPENDENT_SCOPE_REVIEW`
- Authority effect: narrows output authority; grants no implementation authority
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R3_EXACT_WRAPPER_BOUND_REVIEW`

## 1. Finding

R2 reserved 2,048 bytes for the wrapper and therefore set a complete-line safety ceiling of 18,431 bytes. Exact enumeration of the closed schema proves the largest valid wrapper is only 587 bytes. Consequently, R2's requirement that 18,430 and 18,431 be accepted as valid canonical lines is unreachable while the 16,383-byte payload limit and closed enum/field lengths remain intact.

## 2. Exact enumeration

The wrapper is the complete canonical line minus the raw embedded payload object bytes. All wrapper characters are ASCII. Hashes are exactly 64 ASCII hex characters and trace is exactly 32 ASCII hex characters.

| Valid shape | Capability/network/authority | Exact wrapper bytes including LF |
|---|---|---:|
| PASS maximum | TASK / LOOPBACK_ONLY / BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY | 587 |
| PASS | PROJECT_QA / LOOPBACK_ONLY / ASSISTIVE_NOT_AUTHORITY | 570 |
| PASS | KNOWLEDGE / NONE / NAVIGATIONAL_NOT_AUTHORITY | 563 |
| Error maximum | TASK / LOOPBACK_ONLY / longest reachable outer error/audit enum | 559 |
| Denial maximum | TASK / NONE / BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY | less than 559 |
| Fully unclassified invalid request | null capability/digests/audit and NONE authority | less than 300 |

The exact maximum is the TASK PASS shape because it contains the longest authority and all three non-null hashes plus audit. Its canonical skeleton is fixed by R1 section 9.3. Subtracting the embedded JSON object's bytes from the complete line yields exactly 587.

## 3. Normative replacement

This R3 replaces every R1/R2 reference to an 18,431-byte complete-line cap, 2,048-byte runtime wrapper cap, and 18,430/18,431/18,432 acceptance vectors.

- Embedded validated M4 JSON object: maximum `16,383` UTF-8 bytes excluding LF.
- Maximum valid canonical wrapper: exactly `587` UTF-8 bytes including LF.
- Maximum complete canonical output line: exactly `16,970` UTF-8 bytes including LF.
- Arithmetic invariant: `16,383 + 587 = 16,970`.
- Boundary vectors: `16,969` accepted, `16,970` accepted, `16,971` rejected with `OUTPUT_ERROR`/84 and no partial stdout.
- Per-shape serializer tests must also assert exact wrapper sizes 587, 570 and 563 above.
- The former 2,048 bytes may remain only as a design-time assertion ceiling proving the wrapper cannot widen silently; it is not a runtime output allowance.
- Any schema/enum/field change that makes a valid wrapper exceed 587 blocks the build and requires separate scope review.
- Legacy M4 CLI limits and behavior remain unchanged.

## 4. Gate insertion

1. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R3_EXACT_WRAPPER_BOUND_REMEDIATION_AUTHORIZATION` — applied as a least-authority correction under the owner's lifecycle authorization.
2. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R3_EXACT_WRAPPER_BOUND_REVIEW` — next.

After PASS, exact implementation design R2 must use this bound and close the seven P1 findings. No product mutation, staging, commit or push is authorized by this overlay.
