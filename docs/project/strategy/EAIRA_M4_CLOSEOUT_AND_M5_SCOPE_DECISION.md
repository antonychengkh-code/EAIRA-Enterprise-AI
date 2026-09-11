# EAIRA M4 Closeout and M5 Scope Decision

## 1. Decision Control

| Field | Value |
| --- | --- |
| Decision ID | `EAIRA_M4_CLOSEOUT_AND_M5_SCOPE_DECISION_V1` |
| Decision date | 2026-09-12 |
| Decision authority | EAIRA Human Project Owner |
| Decision source gate | `SEPARATE_PROJECT_OWNER_EAIRA_M4_CLOSEOUT_AND_M5_SCOPE_DECISION` |
| Subsequent lifecycle authority | Project Owner directive to complete the thirteen-gate sequence |
| Package review gate | `SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_READINESS_AND_M5_SCOPE_DECISION_PACKAGE_REVIEW` |
| Package review verdict | `CLOSEABLE; P0=0; P1=0; P2=0` |
| Reviewed package SHA-256 | `705472B7CAF69DBB36E7136DC84422DBC5866FDF650502C27078D1D3D8677121` |
| Repository baseline | `023592cd62b1cd2f1efa94ab66f43817b43e07d3` |

## 2. Project Owner Selections

The Human Project Owner explicitly selected:

```text
M4_CLOSEOUT_SELECTION=M4_CLOSEOUT_A_APPROVE_WITH_NON_BLOCKING_CARRY_FORWARD
M5_SCOPE_SELECTION=M5_A_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW
```

No selection is inferred from a recommendation. These exact values are the
Project Owner decision supplied in the separate Gate 2 response after the
independent package review passed. The earlier read-only inventory authorization
did not select either value.

## 3. M4 Closeout Decision

M4 Functional Agent MVP is approved for closeout as a completed bounded
functional MVP. The closeout establishes only that the chartered locally
invocable, provider-neutral, no-write, fail-closed functional objective is met
and that Slice 1 through Slice 5 were published with the recorded independent
verification evidence.

The following are carried forward as non-blocking M5 or production gaps:

- separate local CLI surfaces are not yet one unified operator workflow;
- the five Agent service hosts are not connected through authorized IPC or an
  operational orchestrator;
- customer installer, upgrade, rollback, configuration and support contracts do
  not exist;
- release signing, certificate/HSM, legal-publisher completion and customer
  distribution remain deferred;
- service identities, memberships, directories, ACLs, encryption, backup,
  recovery, Field 8, Field 9 and Annex production-readiness gates remain open;
- external providers, credentials, tenancy, egress and retention controls remain
  unauthorized; and
- release-version documentary hygiene and the overlong Codex checkpoint refs
  remain non-blocking maintenance items.

M4 closeout is not evidence of production readiness, signing eligibility,
Windows-service activation, customer deployment, or Annex blocker closure.

## 4. M5 Scope Decision

M5 is established as `M5_A_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW`.

Its product objective is to turn the published M4 capabilities into one bounded,
user-mode local operator workflow while preserving the existing least-authority,
no-write, Guard, provenance, provider and data-isolation controls. The first M5
slice will define one canonical local entry point and explicit capability routing
across task intake, controlled context, project knowledge, bounded project QA,
and the five-Agent functional flow.

M5 begins with planning and design. This decision does not authorize product
implementation, runtime activation, persistence, IPC, Windows services,
privileged identity changes, external providers, credentials, signing or
customer deployment.

## 5. M5 Ordered Product Sequence

1. `M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR`
2. `M5_SLICE2_SECURE_LOCAL_TRANSPORT_CONTRACT`
3. `M5_SLICE3_BOUNDED_ENCRYPTED_LOCAL_STATE`, only if persistence is approved
4. `M5_SLICE4_WINDOWS_SERVICE_AND_ACL_ACTIVATION`
5. `M5_SLICE5_CUSTOMER_PACKAGE_AND_SIGNED_PILOT`

Every slice requires its own scope decision, exact implementation design,
independent review, implementation authority, sealed evidence, staging, commit,
push and publication verification gates. The order grants no later-slice
authority in advance.

## 6. Preserved Boundaries

- The separate Local Readiness Assessment Annex remains blocked and unchanged.
- Gate 24 signing and its unresolved legal, provider, certificate and HSM inputs
  remain deferred.
- The five local groups and empty memberships establish no runtime identity or
  service readiness.
- The M4 provider remains loopback-only exact `qwen3:4b`; its digest check is a
  trusted-local consistency control, not cryptographic attestation.
- M4 source allowlists, no-write outcomes, non-authority labels and Guard
  separation remain controlling until a later exact change is authorized.
- No API, MCP, external synchronization, arbitrary vault read or automated write
  is enabled.

## 7. Repository Lifecycle Boundary

This decision record and the M5 charter may be prepared and independently
reviewed under the authorized Gate sequence. Controlled-state synchronization,
staging, commit and normal push require the later gates in that sequence and
must stop on any P0 or P1 finding. Force push is not authorized.

## 8. Decision State

`M4_CLOSEOUT_APPROVED_M5_A_SCOPE_SELECTED_PENDING_CONTROLLED_STATE_SYNCHRONIZATION`

The next gate after this decision and charter candidate are prepared is:

`SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_AND_M5_CHARTER_PACKAGE_REVIEW`
