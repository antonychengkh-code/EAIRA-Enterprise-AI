# EAIRA Local Readiness Assessment Authorization Annex — Batch 4 Review Decision

## 1. Document Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Local Readiness Assessment Authorization Annex — Batch 4 Review Decision |
| Document Type | Strategy-owned Project Layer Project Owner decision record |
| Layer | Project Layer |
| Status | `APPROVED_WITH_REQUIRED_REVISIONS` |
| Decision | `APPROVE_BATCH_4_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-15 |
| Classification | `PROJECT_OWNER_DECISION` |
| Execution Marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Related Annex | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` |
| Planning Task | `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` |

## 2. Decision

The EAIRA Project Owner approves the Batch 4 item-level dispositions and the overall decision:

`APPROVE_BATCH_4_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`

This approval applies only to non-executable planning inputs in the Local Readiness Assessment Authorization Annex.

## 3. Approved Item-Level Dispositions

### 3.1 Evidence root planning input

The approved planning evidence root is Option B:

- Windows planning path: `C:\EAIRA\Evidence`
- WSL planning path: `/mnt/c/EAIRA/Evidence`

This decision approves the paths as planning inputs only. It does not establish that either path exists and does not authorize directory creation, access configuration, evidence storage, or evidence collection.

### 3.2 Access-control planning approach

The approved planning approach is:

`Combined Windows host control with WSL access`

This is a non-executable planning selection only. Exact identities, groups, ACL entries, inheritance behavior, effective access, privilege requirements, Windows-to-WSL mapping, and cross-boundary enforcement remain unresolved and unauthorized.

### 3.3 Docker context-name disposition

The approved planning disposition is:

`Equality-result approach`

Under a future separate evidence authorization, only whether the observed Docker context name equals a separately approved expected value may be retained. This decision does not authorize execution of Docker commands, context inspection, evidence collection, or retention.

### 3.4 Approved non-executable planning controls

The following Batch 4 controls are approved as non-executable planning inputs:

- role-to-permission matrix;
- minimum stopped-assessment record schema;
- deterministic path-alias controls;
- sensitive repository-relative path review controls;
- accidental-exposure stop principle;
- non-sensitive redaction-record schema.

These approvals do not establish that any control is implemented, configured, tested, or operational.

## 4. Blocked or Deferred Inputs

The following inputs remain blocked or deferred and require separate Project Owner decisions:

- operating-system identities and group mapping;
- exact ACL implementation;
- encryption mechanism;
- disposal mechanism;
- final incident-notification channel and configuration;
- exact permitted business-sensitive-information categories.

No unselected alternative is implicitly approved.

## 5. Mandatory Field and Gate State

- Field 8 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`.
- Field 9 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`.
- Field 10 retains its Field 8 and Field 9 dependencies.
- Field 11 retains its evidence dependencies.
- The all-fields-resolved gate remains `BLOCKED`.

This decision does not satisfy the all-fields-resolved gate and does not authorize submission for assessment execution authorization as though all mandatory inputs were resolved.

## 6. Explicit Non-Authorization Boundary

This decision grants no authority for:

- Local Readiness Assessment execution, simulation, or trial activity;
- command execution;
- environment, service, endpoint, port, process, container, model, runtime, API, database, credential, or production inspection;
- assessment-evidence collection;
- evidence-directory or evidence-file creation;
- ACL, identity, group, or access-control configuration;
- encryption configuration;
- hash calculation;
- redaction execution;
- quarantine or notification execution;
- evidence retention or disposal;
- implementation, remediation, runtime activity, deployment, automation, or CI/CD expansion;
- database or production mutation;
- milestone establishment;
- M4;
- Platform Foundation;
- a formal EAIRA Execution Layer;
- governance modification.

The underlying authorization-package decision remains `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`. `AUTHORIZE_BOUNDED_ASSESSMENT` has not been granted, and `AUTHORIZE_WITH_REQUIRED_REVISIONS` has not been granted as conditional execution authority.

## 7. Traceability and Synchronization Requirement

This decision record is the authoritative repository evidence for the Project Owner's Batch 4 Review decision as of 2026-07-15.

The related Annex must be synchronized in a subsequent controlled Project Layer documentation update so that its Batch 4 decision section, row-level classifications, resolution descriptions, Project Owner input queue, and document metadata accurately reference this decision without changing the execution boundary or the `BLOCKED` gate state.

Until that synchronization is directly verified, the Annex text may contain stale `PROPOSED_NOT_APPROVED` states for Batch 4 rows. Such stale text must not be interpreted as overriding this decision record, and this decision record must not be interpreted as approving any item not explicitly listed above.
