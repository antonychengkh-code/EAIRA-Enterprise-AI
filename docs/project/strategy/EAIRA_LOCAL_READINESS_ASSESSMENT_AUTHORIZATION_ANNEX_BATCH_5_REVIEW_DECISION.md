# EAIRA Local Readiness Assessment Authorization Annex — Batch 5 Review Decision

## 1. Document Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Local Readiness Assessment Authorization Annex — Batch 5 Review Decision |
| Document Type | Strategy-owned Project Layer Project Owner decision record |
| Layer | Project Layer |
| Status | `APPROVED_WITH_REQUIRED_REVISIONS` |
| Decision | `APPROVE_BATCH_5_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-15 |
| Classification | `PROJECT_OWNER_DECISION` |
| Execution Marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Related Annex | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` |
| Underlying Package Decision | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md` |
| Planning Task | `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` |

## 2. Decision

The EAIRA Project Owner approves the Batch 5 item-level dispositions and the overall decision:

`APPROVE_BATCH_5_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`

This approval applies only to non-executable planning inputs for operating-system identity, group-control, role-membership, and access-control planning in the Local Readiness Assessment Authorization Annex.

## 3. Identity and Group-Control Model Dispositions

### 3.1 Default model

`Separate local groups` is approved as the default operating-system identity and group-control planning model.

This is a planning-model decision only. It does not name, create, configure, populate, inspect, or verify any group, user, membership, identity mapping, or access right.

### 3.2 Exception model

`Hybrid individual-user plus group control` is retained only as an exception model. Its use requires a separate explicit Project Owner approval before any exception may be included in an implementation or configuration authorization.

No individual-user exception, principal, right, scope, or rationale is approved by this decision.

### 3.3 Rejected model

`Single-user procedural separation` is rejected as the default model and rejected as a sufficient access-control model.

## 4. Multiple-Role Membership Dispositions

`Multiple role memberships permitted only with approved separation controls` is approved as the controlling planning rule.

`Multiple role memberships prohibited` is recorded as the preferred stronger technical-separation condition when staffing permits. It is not mandatory under this decision.

`Multiple role memberships permitted without additional separation` is rejected.

This decision does not approve any exact membership, shared principal, staffing arrangement, session control, action control, approval control, write-path control, or verification implementation.

## 5. Approved Non-Executable Planning Controls

The following are approved as planning inputs only:

- role-to-group function mapping;
- NTFS ACL inheritance-boundary planning;
- explicit allow and deny-or-no-access planning;
- operator-write and verifier-non-write separation;
- verifier-disposition write separation;
- Project Owner read-access planning;
- Stop Authority metadata-only default-access planning;
- WSL `/mnt/c` cross-boundary access planning;
- effective-access verification requirements;
- denial of unlisted identities;
- least-privilege requirements;
- rollback planning; and
- access review and re-verification requirements.

These approvals do not establish that any control is implemented, configured, verified, tested, operational, executable, or sufficient for assessment authorization.

## 6. Required Revisions and Unresolved Implementation Details

The Annex must synchronize the approved default model, exception boundary, rejected models, controlling multiple-role membership rule, preferred stronger separation condition, and approved non-executable planning controls.

The following exact implementation values remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT` or `FUTURE_AUTHORIZATION_REQUIREMENT`, according to the Annex classification applicable to each item:

- exact Windows user identity;
- exact WSL user identity;
- exact Windows local group names;
- exact group memberships;
- exact UID/GID mapping;
- exact ACL entries and filesystem rights;
- exact inheritance and propagation behavior;
- exact deny policy;
- exact privilege or elevation requirement;
- exact rollback mechanism; and
- verified effective-access results.

No implementation value may be inferred from the approved planning model or controls. Separate Project Owner input and, where required, separately authorized verification remain necessary.

## 7. Mandatory Field and Gate State

- Field 8 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`.
- Field 9 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`.
- Field 10 retains its Field 8 and Field 9 dependencies.
- Field 11 retains its evidence dependencies.
- The all-fields-resolved gate remains `BLOCKED`.

This decision does not finalize the Authorization Annex, make it execution-ready, approve it for assessment execution, or fully resolve its mandatory execution-controlling fields.

## 8. Explicit Non-Authorization Boundary

This decision grants no authority for:

- Local Readiness Assessment execution, simulation, or trial activity;
- command execution or environment inspection;
- identity or group enumeration;
- assessment-evidence collection;
- evidence-directory or evidence-file creation;
- ACL, identity, group, membership, access-control, permission, or encryption configuration;
- access or effective-access testing;
- hashing, redaction, quarantine, notification, retention, or disposal activity;
- implementation, remediation, runtime activity, deployment, automation, or CI/CD expansion;
- database or production mutation;
- governance modification;
- milestone establishment;
- M4;
- Platform Foundation; or
- a formal EAIRA Execution Layer.

No Local Readiness Assessment execution or assessment-evidence collection authority is granted.

## 9. Relationship to the Underlying Package Decision

This Batch 5 decision is subordinate to and does not supersede the underlying authorization-package decision recorded in `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md`.

That decision remains `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`. `AUTHORIZE_BOUNDED_ASSESSMENT` has not been granted, and `AUTHORIZE_WITH_REQUIRED_REVISIONS` has not been granted as conditional execution authority.

## 10. Traceability and Synchronization Requirement

This decision record is the authoritative repository evidence for the Project Owner's Batch 5 Review decision as of 2026-07-15.

The related Annex must record this decision, preserve unresolved implementation details and the `BLOCKED` gate, and retain all execution non-authorization wording. Synchronization is documentation evidence only and cannot be interpreted as assessment, implementation, configuration, verification, or evidence-collection authority.
