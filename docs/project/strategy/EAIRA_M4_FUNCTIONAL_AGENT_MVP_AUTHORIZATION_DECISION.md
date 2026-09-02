# EAIRA M4 Functional Agent MVP Authorization Decision

## 1. Document Metadata

| Field | Value |
| --- | --- |
| Document Type | Strategy-owned Project Owner decision record |
| Layer | Project Layer |
| Status | Approved and Active |
| Version | 1.0.0 |
| Date | 2026-09-02 |
| Decision Authority | Human Project Owner |

## 2. Decision

The Project Owner establishes `M4 Functional Agent MVP` as the current EAIRA milestone and authorizes its first bounded implementation slice.

This decision supersedes only the prior statement that no current/new milestone was established. It does not close or erase the historical Local Readiness Authorization Annex task, its Fields, acceptance categories or substantive blockers.

## 3. Authorized Slice

The first M4 slice is limited to:

- a local command-line task-intake contract;
- a provider-neutral model interface;
- an enabled deterministic mock provider;
- a selectable but fail-closed disabled real-provider adapter;
- execution of the existing deterministic five-Agent no-write pipeline;
- offline tests and deterministic unsigned builds; and
- evidence-backed synchronization of controlled Project Layer status artifacts.

## 4. Explicit Boundaries

This decision does not authorize:

- network access or an external AI API;
- credentials, secrets, provider enrollment or billing;
- runtime file, registry, database or evidence writes;
- an IPC listener, message broker or cross-service transport;
- Windows service installation or activation;
- service accounts, group membership, directories or ACL changes;
- encryption, backup, HSM, certificate acquisition or signing;
- customer deployment, production readiness, commit or push.

The `real` provider selection must remain disabled and return a bounded fail-closed result until a later Project Owner decision authorizes an exact provider, credential boundary, network policy and verification package.

## 5. Relationship to Existing Readiness Work

M4 is a product-development milestone. It does not satisfy the Local Readiness Authorization Annex all-fields gate. `B2-MAN-006`, `B2-MAN-007`, `B2-MAN-010` and `B2-MAN-013` remain open, and the existing production/readiness gate remains blocked.

## 6. Acceptance

The first slice is accepted as implemented only when:

- mock task intake passes allowed and Guard-denied paths;
- real-provider selection fails closed without external activity;
- invalid requests fail closed;
- all existing functional-slice tests remain passing;
- clean-build outputs are byte-for-byte reproducible; and
- controlled status distinguishes M4 development progress from production eligibility.

## 7. Final Decision

Decision: `ESTABLISH_M4_FUNCTIONAL_AGENT_MVP_AND_AUTHORIZE_BOUNDED_SLICE_1`.

Repository recording, commit, push, external-model activation and production deployment require separate authority.
