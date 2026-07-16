# EAIRA Local Readiness Assessment Authorization Annex

## 1. Document Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Local Readiness Assessment Authorization Annex |
| Document Type | Strategy-owned Project Layer authorization planning annex |
| Layer | Project Layer |
| Status | `DRAFT_WITH_BLOCKERS_FOR_PROJECT_OWNER_INPUT` |
| Execution Marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Assessment Execution | `UNAUTHORIZED` |
| Assessment Evidence Collection | `UNAUTHORIZED` |
| Command Execution | `UNAUTHORIZED` |
| Connectivity Testing | `UNAUTHORIZED` |
| Port Probing | `UNAUTHORIZED` |
| Evidence Directory Creation | `UNAUTHORIZED` |
| Evidence File Creation | `UNAUTHORIZED` |
| Access-Control Configuration | `UNAUTHORIZED` |
| Encryption Configuration | `UNAUTHORIZED` |
| Hash Calculation | `UNAUTHORIZED` |
| Redaction Activity | `UNAUTHORIZED` |
| Evidence Retention Activity | `UNAUTHORIZED` |
| Evidence Disposal Activity | `UNAUTHORIZED` |
| Decision Authority | Project Owner |
| Planning Task | `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` |
| Date | 2026-07-16 |
| Version | 0.14.0 |

## 2. Purpose

Prepare the single Local Readiness Assessment Authorization Annex required by the Project Owner decision for future separate Project Owner review.

This Annex is a planning artifact only. It does not authorize, execute, simulate, or trial the Local Readiness Assessment. It does not authorize assessment-evidence collection, environment inspection, implementation, remediation, runtime activity, deployment, automation, database mutation, governance modification, production access, milestone establishment, M4, Platform Foundation, or a formal EAIRA Execution Layer.

## 3. Authorization and Traceability

This Annex derives its bounded planning authority from:

- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md`;
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_4_REVIEW_DECISION.md`;
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_5_REVIEW_DECISION.md`;
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_6_REVIEW_DECISION.md`;
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_7_REVIEW_DECISION.md`;
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_8_REVIEW_DECISION.md`;
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md`.

The underlying authorization-package decision remains `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`. The Batch 1 planning-input decision recorded below does not supersede that execution non-authorization. `AUTHORIZE_BOUNDED_ASSESSMENT` has not been granted. `AUTHORIZE_WITH_REQUIRED_REVISIONS` has not been granted as conditional execution authority.

The Annex addresses the twelve mandatory content areas in Section 6 of the decision record. Every unresolved execution-controlling input remains a blocker and is not converted into an approved fact.

## 4. Evidence Classification Rules

| Classification | Use in this Annex |
| --- | --- |
| `VERIFIED_REPOSITORY_FACT` | Directly supported by cited repository content. |
| `PROJECT_OWNER_DECISION` | Explicitly recorded Project Owner decision. |
| `PROPOSED_NOT_APPROVED` | Candidate input or control requiring separate Project Owner approval. |
| `PROJECT_OWNER_INPUT_OPTION_NOT_APPROVED` | Exact option prepared for Project Owner selection; it is not selected, approved, verified, or executable. |
| `RECOMMENDATION_NOT_PROJECT_OWNER_DECISION` | Planning recommendation for review that does not select an option or record Project Owner approval. |
| `APPROVED_AS_MANIFEST_PLANNING_INPUT` | Exact manifest content approved as a planning input only; not executable. |
| `APPROVED_WITH_REQUIRED_REVISION_AS_PLANNING_INPUT` | Manifest planning content approved subject to the recorded required control revision; not executable. |
| `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW` | Command is not approved because its client/service behavior remains unresolved. |
| `APPROVED_AS_PLANNING_INTERACTION_DEFINITION` | Interaction boundary approved as planning content only; interaction remains unauthorized. |
| `APPROVED_CONDITIONALLY_AS_PLANNING_INTERACTION` | Planning interaction definition approved only for the recorded future condition; no current interaction authority. |
| `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Required value or decision absent from current repository evidence. |
| `PARTIALLY_RESOLVED_WITH_BLOCKERS` | A control principle is supported, but one or more required inputs remain blocked. |
| `PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING` | Planning boundary and inventory inputs are approved, but exact command-level interactions and controls remain unapproved and blocking. |
| `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | Selected planning inputs are approved, but required revisions, deferrals, or blockers prevent field resolution. |
| `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS` | Evidence-control planning inputs are approved, but exact implementation details remain unapproved and blocking. |
| `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` | Evidence-control structure approved as planning content only; no evidence activity is authorized. |
| `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` | Identity, group, or access-control structure approved as planning content only; no identity, group, ACL, access, or verification activity is authorized. |
| `APPROVED_AS_INTEGRITY_PLANNING_INPUT_NOT_EXECUTABLE` | Integrity method approved as future planning content only; no hash calculation is authorized. |
| `APPROVED_AS_RETENTION_PLANNING_INPUT` | Retention policy approved as future planning content only; no evidence creation, retention, or disposal is authorized. |
| `APPROVED_AS_REDACTION_PLANNING_CONTROL` | Redaction control approved as planning content only; no capture or redaction activity is authorized. |
| `APPROVED_WITH_REQUIRED_REDACTION_REVISION` | Redaction planning control approved subject to its recorded revision; no capture or redaction activity is authorized. |
| `APPROVED_AS_INCIDENT_RESPONSE_PLANNING_CONTROL` | Incident-response sequence approved as planning content only; no incident record or response activity is authorized. |
| `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` | Reproduction record approved as planning content only; command execution and evidence capture remain unauthorized. |
| `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` | Criteria mapping approved as planning content only; no criterion is satisfied and no evidence exists. |
| `APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES` | Reproduction planning controls are approved but remain blocking and non-executable until Field 8 and Field 9 dependencies are resolved. |
| `APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES` | Criteria mappings are approved planning controls but remain blocking because approved evidence handling and actual assessment evidence do not exist. |
| `EVIDENCE_GAP` | Information not supported by current repository evidence. |
| `ASSUMPTION` | Planning premise that must not be treated as evidence. |
| `RISK` | Identified safety, evidence, scope, or authority risk. |
| `FUTURE_AUTHORIZATION_REQUIREMENT` | Input that must be explicitly approved before assessment activity. |
| `REJECTED_BY_PROJECT_OWNER` | Option explicitly rejected by the Project Owner and unavailable as an approved planning or execution input. |

### Batch 8 Documentary Status and Disposition Labels

The following are documentary status, model-disposition, record-disposition, and scope-completeness labels:

| Label | Meaning |
| --- | --- |
| `APPROVED_AS_PLANNING_EVIDENCE` | Project Owner-approved documentary planning evidence; no execution or evidence-collection authority. |
| `SELECTED_AS_INITIAL_DOCUMENTARY_SCOPE_MODEL` | Scope model selected for the initial documentary assessment inventory only. |
| `REVIEWED_NOT_SELECTED` | Model reviewed but not selected for the applicable documentary decision. |
| `RETAINED_AS_SUPPORTING_TRACEABILITY_RECORD_NOT_AS_EXECUTABLE_MANIFEST_ROW` | Supporting traceability retained without creating a command or interaction record. |
| `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE` | Historical record remains traceable but is excluded from the selected initial scope. |
| `DOCUMENTARY_INITIAL_SCOPE_COMPLETENESS_DETERMINATION_ONLY` | Determines documentary scope closure only; it does not establish existence, readiness, criterion satisfaction, Field resolution, gate satisfaction, or authority. |

These labels do not independently establish a `VERIFIED_REPOSITORY_FACT`, execution authority, evidence-collection authority, Field resolution, criterion satisfaction, or gate satisfaction.

Agent self-report, conversation memory, tool availability, and unstored local knowledge are not verified repository facts.

## Project Owner Input Resolution — Batch 1

| Decision field | Recorded value |
| --- | --- |
| Decision | `APPROVE_BATCH_1_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-14 |
| Classification | `PROJECT_OWNER_DECISION` |

This decision approves the Batch 1 planning inputs recorded below for Mandatory Fields 1, 5, 6, and 7 only. These values are recorded as explicit `PROJECT_OWNER_DECISION` inputs and are not necessarily `VERIFIED_REPOSITORY_FACT`.

This approval resolves planning inputs only. It does not authorize Local Readiness Assessment execution, simulation, trial activity, command execution, environment inspection, assessment-evidence collection, target interaction, implementation, remediation, runtime work or mutation, deployment, automation, CI/CD expansion, database or production mutation, external network activity, milestone establishment, M4, Platform Foundation, or a formal EAIRA Execution Layer.

## Batch 2 Proposed Command-Control Planning Inputs

Batch 2 introduced proposed manifest entries, command controls, and interaction entries for Project Owner review. The Batch 2 Review decision below now controls each recorded row state. Approval states are planning classifications only and do not authorize execution or evidence collection.

No proposed command is executable or approved for execution. Batch 2 does not authorize command execution, environment inspection, service or endpoint interaction, port probing, connectivity testing, process or container inspection, model or runtime interaction, database access, credential access, or assessment-evidence collection.

The proposed manifest is closed: only listed entries may be reviewed, and no omitted, wildcard, implied, or substituted command or target is permitted.

## Project Owner Input Resolution — Batch 2 Review

| Decision field | Recorded value |
| --- | --- |
| Decision | `APPROVE_BATCH_2_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-14 |
| Classification | `PROJECT_OWNER_DECISION` |

This decision approves selected Batch 2 command-manifest and interaction-control planning inputs only. Approved values are `PROJECT_OWNER_DECISION` inputs and are not automatically `VERIFIED_REPOSITORY_FACT`. No command semantics, executable presence, local service state, endpoint, port, or environment behavior was independently verified.

This decision does not authorize Local Readiness Assessment execution, command execution, assessment-evidence collection, environment or service inspection, endpoint interaction, port probing, connectivity testing, container, model, runtime, API, database, or credential interaction, implementation, remediation, deployment, automation, CI/CD expansion, milestone establishment, M4, Platform Foundation, or a formal EAIRA Execution Layer.

## Batch 3 Proposed Evidence-Control Planning Inputs

Batch 3 initially introduced evidence-handling, sensitive-data, reproduction, and criteria-mapping values as `PROPOSED_NOT_APPROVED`. The Batch 3 Review decision below now controls their recorded approval states. Approved planning controls are `PROJECT_OWNER_DECISION` values and are not `VERIFIED_REPOSITORY_FACT` values.

The placeholder paths and record structures below are text patterns only. No evidence directory, evidence file, incident record, reproduction artifact, mapping artifact, checksum, hash, integrity record, or assessment output is created by this planning work.

Batch 3 does not authorize assessment execution, command execution, environment or service inspection, endpoint interaction, connectivity testing, port probing, assessment-evidence collection, evidence-directory or evidence-file creation, credential or sensitive-value access, or any implementation or runtime activity.

## Project Owner Input Resolution — Batch 3 Review

| Decision field | Recorded value |
| --- | --- |
| Decision | `APPROVE_BATCH_3_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-14 |
| Classification | `PROJECT_OWNER_DECISION` |

This decision approves selected Batch 3 evidence-control, redaction, reproduction, and criteria-mapping planning inputs only. All approved Batch 3 inputs are `PROJECT_OWNER_DECISION` values, not `VERIFIED_REPOSITORY_FACT` values.

This decision does not authorize evidence-directory creation, evidence-file creation, command execution, assessment activity, assessment-evidence collection, hash calculation, redaction activity, evidence retention, evidence disposal, environment or service inspection, endpoint interaction, connectivity testing, port probing, or any implementation or runtime activity. It does not establish that any path exists, any access control is configured, any command was reproduced, any evidence was captured, any criterion was satisfied, or the environment is ready.

## Batch 4 Evidence Implementation-Detail Planning Inputs

The Batch 4 Review decision below controls the item-level states in this section. Approved values are non-executable planning inputs and `PROJECT_OWNER_DECISION` values; they are not `VERIFIED_REPOSITORY_FACT` values. No path was inspected or created; no user or group was enumerated; and no access, encryption, disposal, notification, quarantine, or redaction mechanism was configured or exercised.

## Project Owner Input Resolution — Batch 4 Review

| Decision field | Recorded value |
| --- | --- |
| Decision | `APPROVE_BATCH_4_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-15 |
| Classification | `PROJECT_OWNER_DECISION` |
| Authoritative Decision Record | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_4_REVIEW_DECISION.md` |

This decision approves only the item-level non-executable planning inputs identified below. It does not establish that a path exists or that any control is implemented, configured, tested, or operational. It does not authorize assessment execution, command execution, environment inspection, assessment-evidence collection, directory or file creation, ACL, identity, or group configuration, encryption, hashing, redaction, quarantine, notification, retention, disposal, implementation, remediation, runtime activity, deployment, database or production mutation, governance modification, milestone establishment, M4, Platform Foundation, or a formal EAIRA Execution Layer.

### Field 8 evidence-root decision options

| Option | Windows planning path | WSL/Linux planning path | Risks and required future decisions | State |
| --- | --- | --- | --- | --- |
| A — Windows-local evidence root | `C:\Users\User\OneDrive\文件\EAIRA-Enterprise-AI-Evidence` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI-Evidence` | OneDrive synchronization may export or replicate evidence; evidence may leave the strictly local boundary; accidental cloud synchronization is possible; repository/evidence separation is logical but not necessarily physical; unsuitable unless synchronization and export behavior are explicitly approved. | `PROJECT_OWNER_INPUT_OPTION_NOT_APPROVED` |
| B — Windows-local non-OneDrive evidence root | `C:\EAIRA\Evidence` | `/mnt/c/EAIRA/Evidence` | Approved as a planning input only; future directory creation and ACL configuration remain unauthorized, and exact user identity and permission behavior remain unresolved. | `PROJECT_OWNER_DECISION` |
| C — WSL-local evidence root | `NOT_APPLICABLE` | `~/eaira-evidence` | `~` is not exact enough for final authorization; a future exact absolute Linux path is required. WSL backup/recovery behavior, Windows-host accessibility, separation from Windows evidence-management controls, and exact user identity remain unresolved. | `PROJECT_OWNER_INPUT_OPTION_NOT_APPROVED` |

These strings are planning text only. Their existence, synchronization behavior, ownership, permissions, and suitability were not inspected.

#### Option disposition

The Project Owner selected Option B as a planning input. Options A and C remain `PROJECT_OWNER_INPUT_OPTION_NOT_APPROVED` and are not implicitly approved. The selection does not establish path existence or authorize directory creation, evidence storage, access configuration, or evidence collection.

### Field 8 approved closed role-to-permission matrix

The matrix is `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` and confers no current access. Operating-system identities, group mapping, exact ACL implementation, and all access configuration remain unresolved and unauthorized.

| Role | Approved planning permissions | Explicit separation / `NO_ACCESS` boundary |
| --- | --- | --- |
| `PROJECT_OWNER` | `READ_DIRECT_OUTPUT`, `READ_REDACTED_OUTPUT`, `READ_VERIFIER_DISPOSITION`, `APPROVE_RETENTION_EXCEPTION`, `APPROVE_DISPOSAL` | `NO_ACCESS` to routine operator or verifier writes unless separately authorized. |
| `ASSESSMENT_OPERATOR` | `CREATE_SESSION_STRUCTURE`, `WRITE_DIRECT_OUTPUT`, `READ_DIRECT_OUTPUT`, `WRITE_REDACTED_OUTPUT`, `READ_REDACTED_OUTPUT`, `WRITE_INCIDENT_METADATA` | `NO_ACCESS` to `WRITE_VERIFIER_DISPOSITION`, `APPROVE_RETENTION_EXCEPTION`, and `APPROVE_DISPOSAL`. |
| `INDEPENDENT_VERIFIER` | `READ_DIRECT_OUTPUT`, `READ_REDACTED_OUTPUT`, `WRITE_VERIFIER_DISPOSITION`, `READ_VERIFIER_DISPOSITION`, `WRITE_INCIDENT_METADATA` | `NO_ACCESS` to `WRITE_DIRECT_OUTPUT`, `WRITE_REDACTED_OUTPUT`, `CREATE_SESSION_STRUCTURE`, retention exceptions, and disposal approval. |
| `STOP_AUTHORITY` | `WRITE_INCIDENT_METADATA`, `APPROVE_RETENTION_EXCEPTION`, `APPROVE_DISPOSAL` within separately recorded authority | `NO_ACCESS` to direct/redacted evidence content or verifier disposition unless separately approved; receives only non-sensitive stop/incident metadata by default. |

### Field 8 unresolved operating-system identity mapping

No user or group name is inferred. Every value remains `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` and `BLOCKED_PENDING_PROJECT_OWNER_INPUT`.

| Required future decision field | Planning value |
| --- | --- |
| Windows user identity | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |
| WSL user identity | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |
| Windows local group for evidence readers | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |
| Windows local group for evidence writers | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |
| Verifier group | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |
| Owner/Stop-Authority group | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |
| Windows-to-WSL identity mapping | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |
| Whether one human may hold multiple role memberships | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |
| Separation controls when Antony Cheng is accountable for multiple roles | `OS_IDENTITY_PENDING_PROJECT_OWNER_INPUT` |

### Field 8 proposed access-mechanism alternatives

| Alternative | Benefits | Limitations | Privilege requirements | Cross-boundary risks | Future verification requirements | State |
| --- | --- | --- | --- | --- | --- | --- |
| Windows NTFS ACL | Mature Windows identity and granular access model; natural for Windows-local roots. | Does not by itself establish WSL access semantics or encryption. | ACL creation/change may require owner or administrative authority. | WSL access may not map exactly to intended Windows role separation. | Verify exact users/groups, inheritance, effective access, WSL behavior, and denial of unlisted identities. | `PROPOSED_NOT_APPROVED` |
| WSL/Linux ownership and mode bits | Native Linux ownership and compact least-privilege model for a WSL-local root. | Basic mode bits may not express every verifier/operator distinction; Windows-host access remains unresolved. | Ownership or group changes may require elevated privilege. | Windows access, backup, export, and host-side controls may bypass assumptions. | Verify exact UID/GID mapping, owner/group/mode, effective access, and Windows-host behavior. | `PROPOSED_NOT_APPROVED` |
| Combined Windows host control with WSL access | Supports practical Windows/WSL interoperability with host-controlled policy. | More complex identity and permission mapping; two boundary models must agree. | May require Windows ACL authority and WSL identity configuration. | Mismatched Windows/WSL enforcement could grant unintended access. | Verify both effective-access views, inheritance, identity mapping, and cross-boundary write/read separation. | `PROJECT_OWNER_DECISION` |
| Application-level access control | Can add record-level workflow separation and audit metadata. | Explicitly insufficient alone unless approved; cannot replace filesystem/host enforcement. | Depends on the future application and service identity. | Application bypass, direct filesystem access, or configuration error may defeat controls. | Verify host/filesystem controls plus application identities, authorization rules, and bypass resistance. | `PROPOSED_NOT_APPROVED` |

No `icacls`, `chmod`, `chown`, `getfacl`, `setfacl`, PowerShell ACL, or user/group command is authorized by these alternatives.

The Project Owner selected `Combined Windows host control with WSL access` as the access-control planning approach. The Windows NTFS ACL-only, WSL/Linux ownership-and-mode-bits-only, and application-level alternatives remain `PROPOSED_NOT_APPROVED`; no unselected alternative or exact ACL implementation is implicitly approved.

## Batch 5 OS Identity and ACL Planning Inputs

The Batch 5 Review decision below controls the item-level states in this section. Approved values are non-executable planning inputs and `PROJECT_OWNER_DECISION` values; they are not `VERIFIED_REPOSITORY_FACT` values. No identity, group, membership, UID, GID, ACL entry, right, inheritance behavior, privilege requirement, rollback mechanism, or effective-access result was inspected, configured, tested, or verified.

## Project Owner Input Resolution — Batch 5 Review

| Decision field | Recorded value |
| --- | --- |
| Decision | `APPROVE_BATCH_5_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-15 |
| Classification | `PROJECT_OWNER_DECISION` |
| Authoritative Decision Record | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_5_REVIEW_DECISION.md` |

This decision approves only the item-level non-executable planning inputs identified below. It does not establish that any identity, group, membership, mapping, ACL, right, inheritance behavior, deny rule, privilege requirement, rollback mechanism, or effective-access result exists or is implemented, configured, verified, tested, operational, executable, or sufficient for assessment authorization. It does not authorize assessment execution, command execution, environment inspection, identity or group enumeration, assessment-evidence collection, directory or file creation, access configuration or testing, implementation, runtime activity, deployment, database or production mutation, governance modification, milestone establishment, M4, Platform Foundation, or a formal EAIRA Execution Layer.

### Field 8 bounded OS identity and ACL decision inputs

This section prepares non-executable Project Owner decision inputs for the next unresolved Field 8 planning set. It does not identify or verify any host user, WSL user, group, membership, UID, GID, ACL entry, inherited permission, effective permission, or privilege. It does not authorize environment inspection, identity or group enumeration, directory creation, access configuration, command execution, or evidence collection.

The approved Option B planning paths remain `C:\EAIRA\Evidence` and `/mnt/c/EAIRA/Evidence`. The approved access-control planning approach remains `Combined Windows host control with WSL access`. Neither approval establishes that a path, identity, group, permission, or enforcement behavior exists.

#### A. OS identity mapping decision inputs

| Required Project Owner decision input | Exact value | Required decision boundary | Current state |
| --- | --- | --- | --- |
| Windows user identity | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Identify the exact future Windows principal only from separately authorized and verified evidence; do not infer an account from repository text or operator identity. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| WSL user identity | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Identify the exact future WSL principal and its verified relationship to Windows-host access only from separately authorized evidence. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| Windows local group for evidence readers | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Supply an exact group identity only after its intended membership, read boundary, and denial of write authority are approved. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| Windows local group for evidence writers | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Supply an exact group identity only after its intended membership and minimum write boundary are approved. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| Verifier group | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Supply an exact group identity only after direct-output read access, verifier-disposition write access, and primary-evidence non-write separation are approved. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| Owner / Stop-Authority group | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Decide whether owner and Stop Authority functions share or separate group enforcement while preserving metadata-only default Stop Authority access. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| Windows-to-WSL identity mapping | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Record the exact verified mapping and effective-access behavior across the Windows host and WSL `/mnt/c` boundary. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| Whether one human may hold multiple role memberships | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Select an explicit membership rule from the options below; silence or current accountability does not grant multiple memberships. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| Separation controls when one accountable human holds multiple roles | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | If multiple memberships are approved, define enforceable session, action, approval, and independent-verification separation before configuration authorization. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |

No table row supplies an actual identity or group name. All exact identity values remain blocked pending a Project Owner decision supported by future separately authorized verification.

#### B. Role-to-group function mapping planning

The approved role-to-permission matrix above remains controlling. The following table maps logical roles only to proposed operating-system enforcement functions; it does not create, name, select, or approve any group.

| Approved logical role | Proposed OS group function without a group name | Required separation preserved from approved matrix | Exact group identity | Planning state |
| --- | --- | --- | --- | --- |
| `PROJECT_OWNER` | Evidence read and separately recorded retention/disposal approval function. | No routine operator output, redaction, or verifier-disposition write authority unless separately approved. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| `ASSESSMENT_OPERATOR` | Session-structure and evidence-output writer function with permitted readback and incident-metadata write function. | No verifier-disposition write, retention-exception approval, or disposal approval. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| `INDEPENDENT_VERIFIER` | Direct/redacted evidence reader plus verifier-disposition writer and incident-metadata writer function. | No primary direct-output or redacted-output write and no session-structure creation. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| `STOP_AUTHORITY` | Non-sensitive incident-metadata and separately recorded retention/disposal decision function. | Metadata-only default; no direct/redacted evidence or verifier-disposition content access unless separately approved. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |

Separate local groups are the approved default enforcement model for these functions. A hybrid individual-user plus group-control model is retained only as an exception requiring separate explicit Project Owner approval before use. Exact group structure, names, memberships, and any individual-user exception remain blocked. Function descriptions do not override the approved role-to-permission matrix or grant current access.

#### C. Combined Windows/WSL ACL planning requirements

| Planning control | Non-executable requirement for future Project Owner decision | Unresolved input or evidence | Planning state |
| --- | --- | --- | --- |
| NTFS ACL inheritance boundary | Define the evidence-root inheritance boundary explicitly, including whether parent inheritance is retained, constrained, or removed and how unintended inherited access is prevented. | Exact inheritance and propagation behavior plus verified effective-access results remain `FUTURE_AUTHORIZATION_REQUIREMENT`. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Explicit allow permissions | Translate each approved logical permission into the minimum required filesystem rights at the correct root or subdirectory boundary; do not infer broad or administrative rights. | Exact principals, rights, scope, propagation, and subdirectory mapping remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT`. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Explicit deny or no-access boundary | Decide where absence of an allow entry is sufficient and where an explicit deny is required, accounting for group-membership interactions and deny precedence. | Exact memberships, conflict analysis, and deny policy remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT`. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Operator write / verifier non-write separation | Permit the operator function to write only approved operator-controlled locations while preventing verifier primary-evidence writes. | Exact writer and verifier principals, rights, and effective-access results remain blocked or future-authorized. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Verifier-disposition write separation | Permit verifier-disposition writes only in the approved verifier-review boundary and prevent operator writes there. | Exact verifier/operator principals, directory-specific rights, and effective-access results remain blocked or future-authorized. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Project Owner read access | Provide read access required by the approved matrix without routine operator or verifier write authority. | Exact Project Owner principal or group function, rights, and effective-access results remain blocked or future-authorized. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Stop Authority metadata-only default access | Limit default access to non-sensitive incident metadata and separately approved decision records; direct/redacted evidence content remains no-access by default. | Exact metadata boundary, principal or group function, exception process, and effective-access results remain blocked or future-authorized. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| WSL access through `/mnt/c` | Define how Windows-host controls govern access observed through WSL and prohibit assumptions that Linux ownership or mode presentation independently enforces the intended separation. | Exact Windows-to-WSL mapping and verified effective access remain blocked or future-authorized. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Effective-access verification | Require separately authorized verification for every approved role/principal against every relevant root and subdirectory, including allowed and prohibited actions. | Exact verification plan, expected results, evidence handling, and verified results remain `FUTURE_AUTHORIZATION_REQUIREMENT`. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Denial of unlisted identities | Require proof that identities outside the approved mapping receive no access, except separately documented mandatory system access approved by the Project Owner. | Exact identity inventory, system-access exceptions, and denial results remain `FUTURE_AUTHORIZATION_REQUIREMENT`. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Privilege/elevation requirements | Require least privilege and identify the minimum authority needed for future configuration and verification without assuming administrator, owner, or elevated access. | Exact configuration owner, privilege or elevation requirement, and authorization boundary remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT`. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Rollback planning | Define a reviewed pre-change record, restoration target, failure stop condition, and approval boundary for returning to the prior access state without deleting evidence. | Exact rollback mechanism and responsible principal remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT`; verification remains future-authorized. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |
| Access review and re-verification | Define review triggers for membership, inheritance, path, WSL mapping, exception, and policy changes; each trigger requires re-verification before continued authorized use. | Exact cadence, trigger owner, evidence requirements, and exception process remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT`; re-verification remains future-authorized. | `APPROVED_AS_ACCESS_CONTROL_PLANNING_INPUT_NOT_EXECUTABLE` |

No row is an ACL entry, configuration instruction, command, or implementation approval. Exact filesystem rights and enforcement mechanisms remain unresolved.

#### D. Project Owner decision options

##### Identity and group-control model options

| Option | Planning description | Risks and limitations | State |
| --- | --- | --- | --- |
| Single-user procedural separation | One verified OS principal performs separately recorded logical roles using procedural boundaries rather than OS-principal separation. | The filesystem cannot distinguish role changes performed by the same principal; self-approval, self-verification, accidental cross-role writes, and weak denial evidence make this insufficient for the approved separation model. | `REJECTED_BY_PROJECT_OWNER` |
| Separate local groups | Distinct verified local group functions enforce reader, writer, verifier, and owner/Stop-Authority boundaries, with exact membership separately approved. | Approved default planning model; exact group names, structure, memberships, inheritance, and cross-boundary behavior remain unresolved. | `PROJECT_OWNER_DECISION` |
| Hybrid individual-user plus group control | Group functions provide baseline access while narrowly scoped individual-user entries address separately approved exceptions. | Retained only as an exception model; each use requires separate explicit Project Owner approval and exact rights, scope, rationale, and rollback planning. | `FUTURE_AUTHORIZATION_REQUIREMENT` |

##### Multiple-role membership options

| Option | Planning description | Risks and limitations | State |
| --- | --- | --- | --- |
| Multiple role memberships prohibited | Each verified human principal receives only one operational role membership for the assessment boundary. | Preferred stronger technical-separation condition when staffing permits; not mandatory under this decision, and exact role coverage remains unresolved. | `PROJECT_OWNER_DECISION` |
| Multiple role memberships permitted only with approved separation controls | A verified human may hold more than one role only when session, action, approval, write-path, and independent-verification controls are explicitly approved and enforceable. | Approved controlling planning rule; exact memberships and separation-control implementations remain unresolved. | `PROJECT_OWNER_DECISION` |
| Multiple role memberships permitted without additional separation | A verified human may receive all otherwise approved memberships without added controls. | Highest risk of self-approval, self-verification, privilege accumulation, accidental overwrite, and inability to demonstrate independent denial; conflicts with the approved controlling rule. | `REJECTED_BY_PROJECT_OWNER` |

The Project Owner selected `Separate local groups` as the default model and retained `Hybrid individual-user plus group control` only as a separately approved exception model. `Single-user procedural separation` is rejected as the default and as a sufficient access-control model. Multiple role memberships are permitted only with approved separation controls; prohibition remains the preferred stronger technical condition when staffing permits but is not mandatory, and membership without additional separation is rejected. Exact identities, groups, memberships, and controls remain unresolved.

#### E. Required future verification before ACL configuration authorization

| Required future evidence | Minimum evidence content | Acceptance boundary | State |
| --- | --- | --- | --- |
| Verified Windows user and group identities | Exact approved principal identifiers, group identifiers, memberships, nested memberships, and role mapping from a separately authorized observation. | Every identity is attributable, current, within the approved mapping, and free of unreviewed membership paths. | `FUTURE_AUTHORIZATION_REQUIREMENT` |
| Verified WSL UID/GID and mapping | Exact approved WSL UID/GID identity and verified mapping to Windows-host access behavior for the Option B path. | The mapping explains which Windows principal and NTFS rights govern access through the approved WSL context. | `FUTURE_AUTHORIZATION_REQUIREMENT` |
| Verified NTFS inheritance behavior | Parent and evidence-root inheritance state, propagation scope, explicit entries, and resulting effective access from separately authorized verification. | No unintended inherited access exists, and every retained inherited entry is explicitly approved. | `FUTURE_AUTHORIZATION_REQUIREMENT` |
| Verified WSL `/mnt/c` effective access | Role-by-role allowed and prohibited access results observed through the approved WSL boundary without collecting unrelated environment information. | WSL-visible behavior matches the approved Windows-host control model for every relevant boundary. | `FUTURE_AUTHORIZATION_REQUIREMENT` |
| Verified least privilege and denial behavior | Positive results for each required role action and negative results for prohibited actions and unlisted identities. | Required access is no broader than the approved matrix, and prohibited/unlisted access is denied. | `FUTURE_AUTHORIZATION_REQUIREMENT` |
| Verified administrative privilege requirements | Exact authority required to apply, review, and reverse the future configuration, including whether elevation is necessary. | The minimum privilege boundary and authorized principal are explicitly approved before any configuration. | `FUTURE_AUTHORIZATION_REQUIREMENT` |
| Verified rollback method | Reviewed prior-state record, restoration procedure description, expected restoration result, failure stop condition, and responsible authority. | Rollback can restore the approved prior state without evidence loss, access expansion, or unapproved mutation. | `FUTURE_AUTHORIZATION_REQUIREMENT` |

All listed evidence remains future evidence only. Its collection requires separate authorization. This planning section does not authorize any verification action, host inspection, identity enumeration, access test, ACL configuration, rollback, or evidence artifact creation.

#### Field 8 state preservation after this planning update

Batch 5 approves the default separate-local-groups model, the exception boundary, the controlling multiple-role membership rule, and the listed access-control requirements as non-executable planning inputs. Exact Windows and WSL identities, local group names, memberships, UID/GID mapping, ACL entries and rights, inheritance and propagation behavior, deny policy, privilege or elevation requirement, rollback mechanism, and verified effective-access results remain blocked or future authorization requirements. Field 8 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`. Field 9 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`. Field 10 retains Field 8 and Field 9 dependencies. Field 11 retains evidence dependencies. Blocking fields remain 1, 2, 3, 4, 8, 9, 10, and 11, and the all-fields-resolved gate remains `BLOCKED`.

## Batch 6 Encryption Option-Level Planning Evidence

The Batch 6 option-level planning package was created at commit `a4e6fc9c87bc66b59b172d08d81682b19030bf37` and received its authorized documentary correction at commit `9e765281c6f39f844bf87fcf348c29e7dcf8161e`. The corrected package documents abstract encryption architecture and custody categories, planning criteria, risks, trade-offs, evidence gaps, decision criteria, and a non-selective conceptual crosswalk. It does not establish that any capability exists, is enabled, verified, validated, suitable, available, or implementable in the EAIRA environment.

## Project Owner Input Resolution — Batch 6 Review

| Decision field | Recorded value |
| --- | --- |
| Decision | `APPROVE_BATCH_6_AS_PLANNING_EVIDENCE_WITHOUT_OPTION_SELECTION_OR_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-15 |
| Classification | `PROJECT_OWNER_DECISION` |
| Execution Marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Decision Commit | `385c66c314af7582320356e0258ebe985fa4b6f8` |
| Authoritative Decision Record | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_6_REVIEW_DECISION.md` |

This decision accepts Batch 6 only as bounded, non-executable planning evidence. It does not approve or select an encryption mechanism, product, vendor, algorithm, service, architecture, key owner, custodian, implementation, configuration, inspection, or execution activity. It does not resolve an evidence gap or expand the authority established by prior decisions.

| Batch 6 option | Disposition |
| --- | --- |
| Option A — Platform-managed Encryption | `REVIEWED_NOT_SELECTED` |
| Option B — Customer-managed Keys | `REVIEWED_NOT_SELECTED` |
| Option C — Application-level Encryption | `REVIEWED_NOT_SELECTED` |
| Option D — Hybrid Encryption Model | `REVIEWED_NOT_SELECTED` |

The four existing Annex alternatives below remain `PROPOSED_NOT_APPROVED`. The controlling state remains `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT`, and the planning qualifier remains `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS`. No encryption mechanism is assumed enabled.

### Field 8 proposed encryption alternatives

`ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT` remains the controlling blocker.

| Alternative | Planning boundary | State |
| --- | --- | --- |
| BitLocker-backed host-volume protection | Future decision must verify volume scope, recovery governance, WSL interaction, and whether host-volume protection meets the evidence risk model. | `PROPOSED_NOT_APPROVED` |
| Encrypted evidence archive | Future decision must define archive format, creation timing, access workflow, key custody, verifier access, and disposal behavior. | `PROPOSED_NOT_APPROVED` |
| Application-level encryption | Future decision must define algorithm, implementation, key custody, access recovery, verifier workflow, and filesystem exposure. | `PROPOSED_NOT_APPROVED` |
| No separate encryption beyond approved host-volume control | Accept only if the Project Owner explicitly determines verified host-volume control is sufficient for the approved evidence classes. | `PROPOSED_NOT_APPROVED` |

No encryption mechanism is assumed enabled. Encryption keys must not be stored in the evidence root, Git repository, Annex files, or environment variables captured as evidence.

Batch 6 review does not select or approve any alternative in this table. Options A–D remain `REVIEWED_NOT_SELECTED`; option and Annex-alternative selection remain blocked by the preserved Batch 6 evidence gaps.

### Field 8 proposed disposal control and mechanisms

A future disposal event would require expiration under `FIXED_30_DAY_RETENTION_AFTER_FINAL_VERIFIER_DISPOSITION`, Project Owner or delegated Stop Authority approval, an exact artifact list, verifier confirmation that retention is no longer required, and a disposal log containing only non-sensitive metadata. Silent deletion is prohibited, and disposal must not occur while an incident or discrepancy remains open. These are `PROPOSED_NOT_APPROVED` implementation details and do not authorize disposal.

| Mechanism option | Planning limitation | State |
| --- | --- | --- |
| Filesystem deletion | Ordinary deletion may not remove replicas, snapshots, backups, synchronized copies, or recoverable storage blocks. | `PROPOSED_NOT_APPROVED` |
| Secure-delete tooling | Effectiveness depends on storage media, filesystem, snapshots, synchronization, backups, privileges, and tool semantics. | `PROPOSED_NOT_APPROVED` |
| Encrypted-container key destruction | Requires an approved encrypted-container design and verified key custody; copies and backups remain in scope. | `PROPOSED_NOT_APPROVED` |

Secure-deletion characteristics remain unverified because they depend on storage media, filesystem, synchronization, snapshots, backups, and encryption. No mechanism is selected or executed.

### Field 8 proposed incident-notification options

No notification may contain a sensitive value.

| Option | Planning limitation | State |
| --- | --- | --- |
| Direct ChatGPT/Codex session notification | Requires confirmation that the session is an approved non-sensitive notification channel and that only minimum metadata is sent. | `PROPOSED_NOT_APPROVED` |
| Local non-sensitive incident file outside the evidence content area | Requires an exact approved path, access rule, lifecycle, and assurance that no sensitive content is recorded. | `PROPOSED_NOT_APPROVED` |
| Email notification | Requires an approved recipient, account, transport, subject/body template, and prohibition on sensitive content. | `PROPOSED_NOT_APPROVED` |
| Another exact approved channel | Project Owner must name the exact channel, recipients, minimum metadata, access, and retention rules. | `PROPOSED_NOT_APPROVED` |

### Field 8 approved minimum stopped-assessment record

| Field | Proposed content boundary |
| --- | --- |
| Incident or stop ID | Non-sensitive stable identifier only. |
| Timestamp | Exact timestamp with UTC offset. |
| Session ID | Approved session identifier only. |
| Manifest ID | Approved manifest identifier only. |
| Target ID | Approved target identifier only. |
| Stop category | Approved non-sensitive category only. |
| Operator identity | Approved identity reference only. |
| Stop Authority notification state | Non-sensitive delivery state only. |
| Disposition state | Non-sensitive Project Owner/Stop Authority disposition only. |
| Restart-authorization reference | Reference only; absence means restart remains unauthorized. |

The schema is `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT`. It explicitly prohibits command output, exposed secret values, credential fragments, copied sensitive content, and unnecessary absolute paths. No stopped-assessment record is created.

### Field 9 approved deterministic path-alias rules

| Alias | Planning meaning | Classification / state |
| --- | --- | --- |
| `EAIRA_REPOSITORY_ROOT` | Existing approved alias for the exact approved repository root. | Existing `PROJECT_OWNER_DECISION` planning input. |
| `EAIRA_EVIDENCE_ROOT` | Alias for the approved Option B planning evidence root without retaining its absolute representation. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |
| `WINDOWS_USER_HOME` | Alias for a future approved Windows user-home prefix without retaining a user name. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |
| `WSL_USER_HOME` | Alias for a future approved WSL user-home prefix without retaining a user name. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |

Deterministic rules:

1. Replace the exact approved repository root with `EAIRA_REPOSITORY_ROOT`.
2. Replace either approved Option B planning-root representation with `EAIRA_EVIDENCE_ROOT`.
3. Replace approved user-home prefixes with `WINDOWS_USER_HOME` or `WSL_USER_HOME`.
4. An unknown absolute path triggers immediate stop and `UNUSABLE_PENDING_PROJECT_OWNER_DECISION`.
5. Partial path substitution that leaks a user name is prohibited.

Rules 1–5 are `APPROVED_AS_REDACTION_PLANNING_CONTROL`. User-home prefixes remain unresolved inputs, so those aliases cannot be operationalized. No redaction is performed.

### Field 9 approved sensitive repository-relative path review

The following review-pattern categories are `APPROVED_AS_REDACTION_PLANNING_CONTROL`, not repository evidence: credentials; secrets; tokens; keys; certificates; `.env`; production configuration; customer or employee personal information; finance or payroll source data; private backups; and credential stores.

Any match would require stop, sensitive-content review, and a future Project Owner disposition before retention. The repository is not scanned under Batch 4.

### Field 9 proposed commit-metadata implementation rules

| `B2-MAN-007` field | Proposed disposition | State |
| --- | --- | --- |
| Commit SHA | Retain exact value only if evidence collection is later authorized. | `PROPOSED_NOT_APPROVED` |
| Timestamp | Retain exact value under a future evidence authorization. | `PROPOSED_NOT_APPROVED` |
| Author name | Replace with `COMMIT_AUTHOR_REDACTED` unless explicitly required. | `PROPOSED_NOT_APPROVED` |
| Commit subject | Retain only after sensitive-content review. | `PROPOSED_NOT_APPROVED` |
| Email, body, signature | Prohibited from capture or retention. | Existing `PROJECT_OWNER_DECISION` prohibition. |

### Field 9 reviewed Docker context-name options

| Option | Proposed disposition | State |
| --- | --- | --- |
| Exact-name retention | Retain the exact name only after an explicit Project Owner decision. | `PROPOSED_NOT_APPROVED` |
| Redacted name | Replace with `DOCKER_CONTEXT_REDACTED`. | `PROPOSED_NOT_APPROVED` |
| Equality result | Retain only whether the observed name equals a separately approved expected name. | `PROJECT_OWNER_DECISION` |
| Sensitive name | Mark evidence unusable if the context name itself is sensitive. | `PROPOSED_NOT_APPROVED` |

The Project Owner selected the `Equality result` planning disposition. Exact-name retention, redacted-name retention, and sensitive-name handling alternatives remain `PROPOSED_NOT_APPROVED` and are not implicitly approved. The expected comparison value remains separately approval-dependent. No Docker command is executed.

### Field 9 proposed business-sensitive-information rule

The planning categories are financial, payroll, employee, customer, supplier, contractual, production, security, internal architecture, and unreleased product or strategy information. Planning disposition: `REDACT_BEFORE_RETENTION_OR_MARK_UNUSABLE`. Exact permitted categories remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT`.

### Field 9 approved accidental-exposure stop principle and blocked quarantine planning

On suspected exposure, stop immediately, perform no further capture or copying, and mark affected evidence `UNUSABLE_PENDING_PROJECT_OWNER_DECISION`. This accidental-exposure stop principle is `APPROVED_AS_INCIDENT_RESPONSE_PLANNING_CONTROL`. Quarantine may be used only after the Project Owner approves an exact location or mechanism, access boundary, notification channel, retention decision, and disposal method. Those implementation details remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT`; quarantine must not expand exposure or create an additional sensitive copy. No quarantine or notification occurs.

### Field 9 approved non-sensitive redaction-record schema

| Field | Proposed content boundary |
| --- | --- |
| Redaction record ID | Non-sensitive stable identifier. |
| Source artifact ID | Identifier only. |
| Derivative artifact ID | Identifier only. |
| Timestamp | Exact timestamp with UTC offset. |
| Redaction rule ID | Approved rule identifier only. |
| Category | Approved non-sensitive category only. |
| Operator identity | Approved identity reference only. |
| Verifier disposition | Separate verifier decision reference. |
| Source hash reference | Reference only; not the source content. |
| Derivative hash reference | Reference only; not the derivative content. |

The schema is `APPROVED_AS_REDACTION_PLANNING_CONTROL` and explicitly prohibits recording the removed sensitive value. No redaction record is created under Batch 4.

### Batch 4 resolution boundary

Batch 4 approves the listed planning inputs but does not fully resolve Field 8 or Field 9. Operating-system identities and group mapping, exact ACL implementation, encryption mechanism, disposal mechanism, final incident-notification channel and configuration, exact permitted business-sensitive-information categories, and other recorded implementation dependencies remain blocked or deferred. Fields 8–11 retain their Resolution Matrix states, blocking fields remain 1, 2, 3, 4, 8, 9, 10, and 11, and the all-fields-resolved gate remains `BLOCKED`.

## Batch 7 Data/Evidence Classification and Encryption-Scope Planning Evidence

The Batch 7 data/evidence classification and encryption-scope planning package was created at commit `c18cc3ee85262ec1b8a95964694c679455bc6b8e`. It documents abstract artifact classes, classification models, classification criteria, Annex Field 9 precedence, plaintext-exposure questions, encryption-scope questions, backup, recovery, replica and export questions, and unresolved evidence requirements. It does not classify actual data or evidence, establish that an artifact exists, approve an encryption scope, or grant implementation or execution authority.

## Project Owner Input Resolution — Batch 7 Review

| Decision field | Recorded value |
| --- | --- |
| Decision | `APPROVE_BATCH_7_AS_PLANNING_EVIDENCE_AND_SELECT_MODEL_B_WITHOUT_ACTUAL_CLASSIFICATION_OR_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-15 |
| Classification | `PROJECT_OWNER_DECISION` |
| Execution Marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Package Commit | `c18cc3ee85262ec1b8a95964694c679455bc6b8e` |
| Decision Record Commit | `396f302130276ac28da9818889677949072a6a9d` |
| Authoritative Decision Record | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_7_REVIEW_DECISION.md` |

This decision accepts Batch 7 only as bounded, non-executable planning evidence and selects Model B solely as the documentary classification model. It does not classify actual data or evidence, approve an actual category assignment, assign a classification execution owner, approve an encryption scope, or grant assessment, implementation, runtime, deployment or milestone authority.

| Batch 7 model | Disposition |
| --- | --- |
| Model A | `REVIEWED_NOT_SELECTED` |
| Model B | `SELECTED_AS_DOCUMENTARY_CLASSIFICATION_MODEL_ONLY` |

Model B records five documentary categories:

1. `Public`
2. `Internal non-sensitive`
3. `Confidential`
4. `Restricted-retainable`
5. `Prohibited from retention`

The approved Annex Field 9 taxonomy and dispositions remain controlling. Model B does not replace, narrow, supersede or reinterpret the Annex taxonomy. Every mapping remains a `NON-SELECTIVE DOCUMENTARY CROSSWALK`. Any apparent inconsistency remains a `POTENTIAL_DECISION CONFLICT` and must return to the Project Owner.

Existing Annex `PROHIBITED_FROM_CAPTURE` dispositions remain stricter and controlling. `Prohibited from retention` does not authorize temporary capture or retention. Encryption, hashing, redaction, transformation, aliasing, restricted access or any other technical treatment cannot authorize retention of prohibited content. No retention exception is granted.

Batch 7 does not change the Batch 6 decision. Options A–D remain `REVIEWED_NOT_SELECTED`; all Annex encryption alternatives remain `PROPOSED_NOT_APPROVED`; `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT` and `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS` remain controlling.

Actual classification assignments, classification inheritance, exact encryption scope, plaintext locations and readers, administrator plaintext access, verifier decryption authority, backup, recovery, replica and export treatment, platform and application capabilities, key governance, compliance and cryptographic requirements, technical and data-flow evidence, and acceptance and verification criteria remain unresolved.

## Batch 8 Assessment Scope Minimization and Command Manifest Closure Planning Evidence

The Project Owner accepts the Batch 8 assessment-scope minimization and command-manifest closure package as bounded documentary planning evidence. The package's original lifecycle states remain historical pre-decision source evidence, while the Batch 8 decision record controls the adopted disposition.

## Project Owner Input Resolution — Batch 8 Review

| Decision field | Recorded value |
| --- | --- |
| Decision | `APPROVE_BATCH_8_AND_SELECT_MODEL_A_WITH_MANDATORY_SEPARATE_EXTENSION_AND_LIMITED_READINESS_CLAIM_WITHOUT_EXECUTION_AUTHORITY` |
| Decision Authority | Project Owner |
| Decision Date | 2026-07-16 |
| Status | `APPROVED_AS_PLANNING_EVIDENCE` |
| Classification | `PROJECT_OWNER_DECISION` |
| Execution Marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Package | `docs/project/planning/BATCH_8_ASSESSMENT_SCOPE_MINIMIZATION_AND_COMMAND_MANIFEST_CLOSURE_PLANNING_PACKAGE.md` |
| Package Commit | `17d03c080e22b3dab9df13043358418a25a3b55a`; stabilized at `fec0436da1941576c3a322291ec9dca2b03ba6b0` |
| Authoritative Decision Record | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_8_REVIEW_DECISION.md` |

This decision accepts Batch 8 only as bounded documentary planning evidence and selects Model A only as the initial documentary assessment-scope model.

| Batch 8 scope model | Disposition |
| --- | --- |
| Model A — Minimal Core Assessment Scope | `SELECTED_AS_INITIAL_DOCUMENTARY_SCOPE_MODEL` |
| Model B — Minimal Core Plus Docker Context Equality | `REVIEWED_NOT_SELECTED` |
| Model C — Extended Local AI Assessment Scope | `REVIEWED_NOT_SELECTED` |

Batch 7 Model B and Batch 8 Model A belong to different documentary model namespaces. Batch 7 Model B remains `SELECTED_AS_DOCUMENTARY_CLASSIFICATION_MODEL_ONLY`; Batch 8 Model A is `SELECTED_AS_INITIAL_DOCUMENTARY_SCOPE_MODEL`. Neither decision modifies or reopens the other.

### Batch 8 selected targets

The selected initial Model A documentary target set contains only:

- `TGT-REPO-001`
- `TGT-WSL-001`
- `TGT-GIT-WIN-001`
- `TGT-GIT-WSL-001`
- `TGT-DOCKER-001`, limited strictly to the Docker client-version planning row `B2-MAN-010`

Target selection does not establish existence or authorize interaction, inspection, command execution, or evidence collection.

### Batch 8 retained command and supporting records

Retained command-manifest rows:

- `B2-MAN-001` through `B2-MAN-010`
- `B2-MAN-013`

`B2-BLK-001` is retained only as:

`RETAINED_AS_SUPPORTING_TRACEABILITY_RECORD_NOT_AS_EXECUTABLE_MANIFEST_ROW`

It is not a command, is not an interaction, does not increase either count, and grants no execution authority.

### Batch 8 selected interaction allowlist

Exactly five documentary interaction records are retained:

- `B2-INT-001`
- `B2-INT-002`
- `B2-INT-003`
- `B2-INT-004`, narrowed strictly to `B2-MAN-010`
- `B2-INT-006`

For the selected initial Model A scope, retained `B2-INT-004` includes only the Docker client-version planning interaction associated with `B2-MAN-010`. It excludes `B2-MAN-011`, Docker context equality handling, context-name retention, context inspection, Docker Engine contact, interaction authority, and execution authority.

### Batch 8 excluded initial-scope records

The following are classified only as `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`:

- `B2-MAN-011`
- `B2-MAN-012`
- `B2-BLK-002` through `B2-BLK-006`
- `B2-INT-005`
- `B2-INT-007` through `B2-INT-011`

Exclusion does not delete historical planning evidence, prove nonexistence or unsafety, permanently reject a target, authorize a substitute command or later interaction, or automatically approve a future extension.

### Mandatory separate-extension rule

Docker Engine, Ollama, Hermes, OpenWebUI, and LM Studio may return to assessment scope only through a separately proposed and separately Project Owner-authorized Annex extension defining exact targets, commands, executables, working directories, endpoints, ports, service-contact boundaries, output restrictions, mutation-risk determinations, evidence classifications, Fields 8 and 9 controls, reproduction procedures, criteria mappings, stop conditions, review authority, and synchronization authority.

No excluded target, interaction, command, endpoint, or port is implicitly reserved, pre-approved, or fast-tracked.

### Limited readiness-claim boundary

Any future readiness conclusion derived only from the selected Model A scope must be described as:

`INITIAL_MINIMAL_CORE_SCOPE_READINESS`

It must not be represented as complete EAIRA local-AI-platform readiness, Docker Engine readiness, Ollama readiness, Hermes readiness, OpenWebUI readiness, LM Studio readiness, complete runtime readiness, implementation readiness, milestone readiness, or Platform Foundation readiness.

### Documentary initial-scope completeness determination

The retained Model A target set, retained command-manifest rows, `B2-BLK-001` supporting traceability record, and retained interaction allowlist constitute the complete closed documentary inventory for the initial Model A assessment scope.

That inventory includes selected targets, retained command-manifest rows, `B2-BLK-001` as supporting traceability only, five retained documentary interaction records, excluded and deferred records, and execution and evidence-collection boundaries.

Every record explicitly listed in Batch 8 decision §7 remains `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`.

The phrase “excluded and deferred records” does not create a new row-specific deferred disposition.

Future extension eligibility remains governed only by the mandatory separate-extension rule.

This determination is classified only as:

`DOCUMENTARY_INITIAL_SCOPE_COMPLETENESS_DETERMINATION_ONLY`

It does not establish executable or command existence, executable availability, independently verified semantics, operational evidence controls, target-environment readiness, criterion satisfaction, Field 1–4 resolution, gate satisfaction, execution authority, or evidence-collection authority.

This Version 0.14.0 synchronization records the adopted complete closed documentary inventory but does not modify any Field state. Before any future Field-state modification, direct review of the synchronized Annex, objective verification that every retained requirement is addressed and satisfied, and separate Project Owner approval remain required. That later review must not reopen or unselect the initial documentary scope.

## 5. Mandatory Field Resolution Matrix

| # | Mandatory field | Resolution state | Current disposition |
| ---: | --- | --- | --- |
| 1 | Exact local environment boundary and complete target inventory | `PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING` | Batch 8 selects the complete initial Model A documentary target set. Field 1 remains unchanged because retained command-level controls have not been objectively verified as addressed and satisfied. |
| 2 | Exact approved tool and command manifest | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | Batch 8 retains eleven command-manifest rows and excludes the remaining rows from the selected initial scope while preserving historical traceability. No command is executable, and no Field-state change is approved. |
| 3 | Command-specific arguments, working directory, privilege, target, purpose, expected output, timeout, and mutation-risk determination | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | Retained command-specific planning controls remain subject to evidence, redaction, semantic-verification, and satisfaction dependencies. Batch 8 does not resolve Field 3. |
| 4 | Approved and prohibited services, endpoints, ports, network actions, and resources | `PARTIALLY_RESOLVED_WITH_BLOCKERS` | Batch 8 retains exactly five documentary interactions for selected Model A and excludes extended interactions from the initial scope. No interaction, endpoint, port, or execution authority is approved, and Field 4 remains unchanged. |
| 5 | Named operator and named independent verifier | `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER` | Batch 1 names the operator, verifier, accountable human owner, and stop authority. |
| 6 | Verifier independence, role separation, and named stop authority | `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER` | Batch 1 approves procedural independence, separation, stop conditions, and restart control. |
| 7 | Observation window, timezone, clock source, freshness, staleness, and rerun rules | `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER` | Batch 1 approves the observation and freshness control framework; an exact future start timestamp still belongs in a separate execution authorization. |
| 8 | Evidence paths, readers, access, integrity, retention, disposal, and stopped-assessment handling | `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS` | Batch 4 approvals remain controlling; Batch 5 approves separate local groups as the default planning model, controlled multiple-role membership, role-to-group functions, and access-control requirements as non-executable planning inputs. Batch 6 is accepted as planning evidence only; Options A–D remain `REVIEWED_NOT_SELECTED`, all Annex encryption alternatives remain `PROPOSED_NOT_APPROVED`, and option selection remains blocked by evidence gaps. Batch 7 selects Model B only as the documentary classification model and does not approve actual classification, encryption scope, plaintext access, backup, recovery, replica, export or key governance. Exact identities, groups, memberships, UID/GID mapping, ACL rights and behavior, privilege, rollback, effective-access results, encryption, disposal, and final notification details remain blocked or future-authorized. |
| 9 | Redaction, sensitive-data taxonomy, secret prohibition, and accidental-exposure procedure | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | Batch 4 approvals remain controlling. Batch 7 selects Model B only as a subordinate documentary model; the approved Annex Field 9 taxonomy and stricter prohibitions remain controlling, every mapping remains a `NON-SELECTIVE DOCUMENTARY CROSSWALK`, and apparent conflicts remain `POTENTIAL_DECISION CONFLICT`. No actual assignment or retention exception is approved. Exact business-sensitive categories, classification inheritance, actual assignments and implementation mechanisms remain blocked. |
| 10 | Reproduction procedure for every material observation | `APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES` | Twelve non-executable reproduction records are approved as planning controls; unresolved Field 8 and Field 9 dependencies remain blocking. |
| 11 | Criteria-to-evidence mapping | `APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES` | Twelve criteria mappings are approved as planning controls; the approved planning root is not created or usable, and no assessment evidence exists. |
| 12 | All-fields-resolved gate | `RESOLVED_AS_CONTROL` | Gate logic is defined below; the gate currently evaluates to `BLOCKED`. |

## 6. Mandatory Field 1 — Local Environment Boundary and Target Inventory

### Approved environment boundary

The following values are `PROJECT_OWNER_DECISION` inputs approved by `APPROVE_BATCH_1_WITHOUT_EXECUTION_AUTHORITY`. They were not independently inspected or verified under this task.

| Decision input | Approved value |
| --- | --- |
| Environment ID | `EAIRA-LOCAL-PRIMARY-001` |
| Physical host | Project Owner-controlled primary Windows workstation |
| Host identifier | `WIN-3IDR7MV7G7C` |
| Operating-system boundary | Windows host operating system plus explicitly approved WSL2 environment |
| WSL2 | `INCLUDED` |
| Approved WSL distribution | Ubuntu under WSL2 |
| Docker Desktop | `INCLUDED_AS_TARGET_PENDING_COMMAND_APPROVAL` |
| Local containers | `INCLUDED_ONLY_IF_INDIVIDUALLY_LISTED` |
| Repository working tree | `C:\Users\User\OneDrive\文件\EAIRA-Enterprise-AI` |
| WSL repository path | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` |
| External environments | `EXCLUDED` |
| Production resources | `PROHIBITED` |
| Credential and secret inspection | `PROHIBITED` |
| Network policy | Local-only by default; only explicitly listed loopback or local endpoints may later be proposed |
| Unlisted targets | `PROHIBITED` |

### Approved initial target inventory

Each row is an approved planning target classified as `PROJECT_OWNER_DECISION`. Inclusion does not authorize interaction.

| Target ID | Category | Exact target | Approved planning disposition | Current permitted interaction |
| --- | --- | --- | --- | --- |
| `TGT-REPO-001` | Repository | `C:\Users\User\OneDrive\文件\EAIRA-Enterprise-AI` | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None until command approval |
| `TGT-WSL-001` | Virtual environment | Ubuntu under WSL2 | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None until command approval |
| `TGT-GIT-WIN-001` | Tool | Windows Git at `C:\Program Files\Git\cmd\git.exe` (`/mnt/c/Program Files/Git/cmd/git.exe` from WSL) | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None; version-only planning interaction recorded below remains non-executable |
| `TGT-GIT-WSL-001` | Tool | Git inside WSL2 | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None until command approval |
| `TGT-DOCKER-001` | Runtime | Docker Desktop | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None until command approval |
| `TGT-OLLAMA-001` | Local service | Ollama local service | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None until command approval |
| `TGT-HERMES-001` | Agent runtime | Hermes local runtime | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None until command approval |
| `TGT-OPENWEBUI-001` | Local service | OpenWebUI | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None until command approval |
| `TGT-LMSTUDIO-001` | Local application | LM Studio | `PERMIT_FOR_FUTURE_READ_ONLY_MANIFEST` | None until command approval |
| `TGT-SUPABASE-001` | Local platform | Local Supabase environment | `BLOCKED_PENDING_SEPARATE_APPROVAL` | None |
| `TGT-DATABASE-001` | Database | Any local or remote database | `PROHIBITED_PENDING_SEPARATE_AUTHORIZATION` | None |
| `TGT-PRODUCTION-001` | Production | All production resources | `PROHIBITED` | None |
| `TGT-CREDENTIAL-001` | Sensitive resource | Credentials, tokens, keys, and secrets | `PROHIBITED` | None |
| `TGT-EXTERNAL-001` | Network resource | External endpoints and internet services | `PROHIBITED_UNLESS_EXPLICITLY_APPROVED` | None |

### Batch 2 approved Windows Git executable identity

The following values are `PROJECT_OWNER_DECISION` inputs approved by `APPROVE_BATCH_2_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`. They identify a planning target only and do not establish executable presence or authorize general Windows Git usage.

| Decision input | Approved planning value |
| --- | --- |
| Windows-native executable path | `C:\Program Files\Git\cmd\git.exe` |
| WSL-visible executable path | `/mnt/c/Program Files/Git/cmd/git.exe` |
| Permitted planning scope | Future version-only manifest definition `B2-MAN-013` |
| General Windows Git usage | `NOT_APPROVED` |
| Execution | `UNAUTHORIZED` |

### Command-level control boundary

- Inclusion in this inventory does not authorize interaction.
- Every future interaction requires an exact approved command manifest.
- No wildcard, implied, or unlisted target is permitted.
- Database, credential, production, and external-network boundaries remain prohibited as stated above.
- No target may be contacted, queried, executed, or inspected under this planning decision.

### Batch 8 selected initial Model A target overlay

The approved initial target inventory above remains historical planning evidence. For the selected initial Model A documentary scope, the effective target overlay is:

| Target or boundary | Selected Model A disposition |
| --- | --- |
| `TGT-REPO-001` | Retained in selected initial Model A documentary scope |
| `TGT-WSL-001` | Retained in selected initial Model A documentary scope |
| `TGT-GIT-WIN-001` | Retained in selected initial Model A documentary scope |
| `TGT-GIT-WSL-001` | Retained in selected initial Model A documentary scope |
| `TGT-DOCKER-001` | Retained in selected initial Model A documentary scope; limited strictly to `B2-MAN-010` |
| Docker Engine, `TGT-OLLAMA-001`, `TGT-HERMES-001`, `TGT-OPENWEBUI-001`, `TGT-LMSTUDIO-001` | `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`; historical planning evidence retained; separate extension required |
| Existing prohibited targets | Existing prohibitions remain unchanged |

The selected target overlay does not establish target existence, availability, readiness, or authority.

### Current status

`PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING`

The historical environment boundary and target inventory remain approved planning inputs. Batch 8 selects and closes the initial Model A documentary target set. This synchronization does not modify Field 1. Field 1 remains unchanged until the synchronized Annex is directly reviewed, every retained requirement is objectively verified as addressed and satisfied, and the Project Owner separately approves a Field-state modification.

## 7. Mandatory Fields 2 and 3 — Tool and Command Manifest

### Proposed command-selection controls

- Every command below is planning text classified by the Batch 2 Review decision; no row is executable.
- No command installs, updates, starts, stops, restarts, creates, removes, fetches, pulls, pushes, commits, merges, rebases, checks out, cleans, resets, loads, runs a workload, performs inference, queries a database, writes through an API, or mutates configuration.
- Every command proposes `NO_ELEVATION`, an explicit timeout, and `NONE` for network action.
- No command reads environment-variable values, credentials, tokens, secrets, private configuration values, or unrelated host inventory.
- Executable paths, endpoint details, ports, or safe semantics not supported by current planning evidence remain blockers below.
- No command is classified as confirmed read-only because planning approval does not establish independently verified semantics or execution authority.

### Proposed closed manifest — command definitions

The three tables keyed by Manifest ID jointly form each complete proposed command row.

| Manifest ID | Target ID | Executor and path style | Exact tool or executable | Exact command | Exact ordered arguments | Exact working directory | Named user context | Privilege | Purpose |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `B2-MAN-001` | `TGT-GIT-WSL-001` | WSL Git; WSL path | `git` | `git --version` | `--version` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe the WSL Git version string only. |
| `B2-MAN-002` | `TGT-REPO-001` | WSL Git; WSL path | `git` | `git rev-parse --show-toplevel` | `rev-parse`, `--show-toplevel` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe the repository top-level path identity only. |
| `B2-MAN-003` | `TGT-REPO-001` | WSL Git; WSL path | `git` | `git branch --show-current` | `branch`, `--show-current` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe the current branch name only. |
| `B2-MAN-004` | `TGT-REPO-001` | WSL Git; WSL path | `git` | `git rev-parse HEAD` | `rev-parse`, `HEAD` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe the current repository `HEAD` SHA only. |
| `B2-MAN-005` | `TGT-REPO-001` | WSL Git; WSL path | `git` | `git rev-parse origin/master` | `rev-parse`, `origin/master` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe the local remote-tracking SHA for `origin/master` only; no fetch. |
| `B2-MAN-006` | `TGT-REPO-001` | WSL Git; WSL path | `git` | `git status --short --branch --untracked-files=no` | `status`, `--short`, `--branch`, `--untracked-files=no` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe branch and tracked working-tree status without enumerating untracked files. |
| `B2-MAN-007` | `TGT-REPO-001` | WSL Git; WSL path | `git` | `git log -1 --format=%H%x09%an%x09%aI%x09%s` | `log`, `-1`, `--format=%H%x09%an%x09%aI%x09%s` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe one commit SHA, author name, author timestamp, and subject; no email or body. |
| `B2-MAN-008` | `TGT-WSL-001` | WSL shell; WSL path | `uname` | `uname -srm` | `-srm` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe bounded WSL kernel name, release, and machine metadata. |
| `B2-MAN-009` | `TGT-WSL-001` | WSL shell; WSL path | `pwd` | `pwd -P` | `-P` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe the physical current working-directory identity only. |
| `B2-MAN-010` | `TGT-DOCKER-001` | WSL CLI; WSL path | `docker` | `docker --version` | `--version` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe Docker client version text without engine interaction. |
| `B2-MAN-011` | `TGT-DOCKER-001` | WSL CLI; WSL path | `docker` | `docker context show` | `context`, `show` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe only the selected Docker context name; do not inspect the context. |
| `B2-MAN-012` | `TGT-OLLAMA-001` | WSL CLI; WSL path | `ollama` | `ollama --version` | `--version` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Deferred: proposed Ollama version observation pending independent command-semantics review; no substitute may be inferred. |
| `B2-MAN-013` | `TGT-GIT-WIN-001` | Windows Git invoked from WSL; WSL path | `/mnt/c/Program Files/Git/cmd/git.exe` | `"/mnt/c/Program Files/Git/cmd/git.exe" --version` | `--version` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Codex under Antony Cheng's explicit task-level authorization | `NO_ELEVATION` | Observe the Windows Git version string only; no repository, configuration, or credential interaction. |

### Proposed closed manifest — output, risk, and traceability

| Manifest ID | Expected safe output fields | Proposed maximum timeout | Network action | Mutation-risk determination and rationale | Evidence-output classification | Reproduction ID | Criteria-mapping ID | Approval state |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `B2-MAN-001` | One Git version string: product name and version only. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — version-only planning content approved; semantics are not independently verified. | `PROPOSED_DIRECT_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-001` | `MAP-B2-001` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-002` | One absolute WSL repository path matching the approved working tree. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — repository-path planning content approved; not executable. | `PROPOSED_DIRECT_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-002` | `MAP-B2-002` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-003` | One branch name, or empty output if detached. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — branch-name planning content approved; not executable. | `PROPOSED_DIRECT_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-003` | `MAP-B2-003` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-004` | One 40-hexadecimal `HEAD` commit SHA. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — ref-resolution planning content approved; not executable. | `PROPOSED_DIRECT_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-004` | `MAP-B2-004` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-005` | One 40-hexadecimal `origin/master` remote-tracking SHA. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — local ref-resolution planning content approved; no network action or execution authorized. | `PROPOSED_DIRECT_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-005` | `MAP-B2-005` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-006` | Branch header and zero or more tracked repository-relative status entries. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — bounded status planning content approved; not executable. | `PROPOSED_PATH_BEARING_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-006` | `MAP-B2-006` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-007` | Four tab-separated fields: commit SHA, author name, ISO-8601 author timestamp, subject. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — bounded commit-record planning content approved; not executable. | `PROPOSED_PERSON_NAME_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-007` | `MAP-B2-007` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-008` | Kernel name, kernel release, and machine architecture only. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — bounded OS-identity planning content approved; not executable. | `PROPOSED_HOST_METADATA_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-008` | `MAP-B2-008` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-009` | One absolute WSL working-directory path matching the approved path. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — working-directory planning content approved; not executable. | `PROPOSED_DIRECT_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-009` | `MAP-B2-009` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-010` | One Docker client version string and build identifier if emitted. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — client-version planning content approved; Docker engine contact remains prohibited. | `PROPOSED_DIRECT_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-010` | `MAP-B2-010` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-011` | Exactly one Docker context name only. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — approved with required controls; context inspection, details, and Docker engine contact remain prohibited. | `PROPOSED_CONFIGURATION_NAME_OUTPUT_PENDING_FIELDS_8_AND_9`; no collection until Fields 8 and 9 are resolved | `REP-B2-011` | `MAP-B2-011` | `APPROVED_WITH_REQUIRED_REVISION_AS_PLANNING_INPUT` |
| `B2-MAN-012` | Unresolved; client-only output behavior is not independently established. | 30 seconds | `NONE` | `MUTATION_RISK_UNRESOLVED` — `ollama --version` is not approved; service-contact semantics require separate review. | `NO_OUTPUT_COLLECTION_AUTHORIZED` | `REP-B2-012` | `MAP-B2-012` | `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW` |
| `B2-MAN-013` | One Windows Git version string: product name and version only. | 30 seconds | `NONE` | `READ_ONLY_APPROVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` — version-only planning content approved; executable presence and semantics are not independently verified. | `PROPOSED_DIRECT_OUTPUT_PENDING_FIELDS_8_AND_9` | `REP-B2-013` | `MAP-B2-013` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |

### Proposed command-specific stop, redaction, and evidence controls

`STOP-B2-COMMON` requires immediate stop before or during any future separately authorized command if authorization is absent or conflicting; executable resolution differs from the approved manifest; elevation, mutation, network access, credential access, or an unlisted target is requested; output exceeds the expected fields; provenance cannot be recorded; or the repository/environment changes unexpectedly. No remediation or alternate command is permitted.

| Manifest ID | Command-specific stop condition | Proposed redaction need | Evidence destination placeholder | Approval state |
| --- | --- | --- | --- | --- |
| `B2-MAN-001` | Stop if output contains fields beyond product/version text. | None expected; reject unexpected fields. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-001.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-002` | Stop if output is not the exact approved WSL repository path. | Retain only the approved path; reject any other path. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-002.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-003` | Stop if output contains more than one branch-name line. | None expected; reject unexpected fields. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-003.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-004` | Stop if output is not one 40-hexadecimal SHA. | None expected; reject unexpected fields. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-004.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-005` | Stop if output is not one 40-hexadecimal SHA or if network access is attempted. | None expected; reject unexpected fields. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-005.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-006` | Stop if untracked entries, absolute paths, or data outside tracked status fields appear. | Repository-relative paths require Field 9 review; reject sensitive or absolute paths. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-006.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-007` | Stop if email, commit body, signature material, or more than four fields appears. | Author name and subject require Field 9 review; email/body are prohibited. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-007.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-008` | Stop if host name, user name, environment data, or additional inventory appears. | Retain only kernel name, release, and architecture. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-008.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-009` | Stop if output is not the exact approved WSL working-directory path. | Retain only the approved path; reject any other path. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-009.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-010` | Stop if the command attempts engine contact or output exceeds client version/build text. | None expected; reject unexpected fields. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-010.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |
| `B2-MAN-011` | Stop if output is not exactly one context name, if `docker context inspect` or any context-detail read is attempted, or if Docker engine contact occurs. | Context name remains subject to Field 9 approval; no context details may be retained and no output may be collected until Fields 8 and 9 are resolved. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-011.txt` | `APPROVED_WITH_REQUIRED_REVISION_AS_PLANNING_INPUT` |
| `B2-MAN-012` | Do not execute. Stop because client-only behavior is not independently established; any future command requires an approved client-only method or explicit Field 4 loopback service-contact approval. No substitute command may be inferred. | No output collection authorized. | `NO_EVIDENCE_PATH_AUTHORIZED` | `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW` |
| `B2-MAN-013` | Stop if output contains fields beyond Windows Git product/version text or if repository, configuration, credential, or network interaction occurs. | None expected; reject unexpected fields. | `EVIDENCE_PATH_PENDING_FIELD_8_APPROVAL/B2-MAN-013.txt` | `APPROVED_AS_MANIFEST_PLANNING_INPUT` |

### Resolved manifest blocker identity

`B2-BLK-001` is resolved only for executable identity by the Project Owner decision. It does not approve general Windows Git usage or execution.

| Manifest ID | Target ID | Resolved input | Linked planning command | Classification | Resolution state |
| --- | --- | --- | --- | --- | --- |
| `B2-BLK-001` | `TGT-GIT-WIN-001` | Windows path `C:\Program Files\Git\cmd\git.exe`; WSL-visible path `/mnt/c/Program Files/Git/cmd/git.exe` | `B2-MAN-013` version-only definition | `PROJECT_OWNER_DECISION` | `RESOLVED_AS_PLANNING_INPUT_NOT_EXECUTABLE` |

### Explicit manifest blockers retained

These rows remain part of the closed manifest but contain no command. No substitute, inferred path, endpoint, port, process name, or argument is permitted.

| Manifest ID | Target ID | Missing exact input | Exact command | Working directory | Privilege | Proposed timeout if resolved | Network action | Mutation-risk determination | Evidence / reproduction / criteria | Approval state |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `B2-BLK-002` | `TGT-DOCKER-001` | Exact approved Docker engine resource/context and safe server-version command. | `NO_COMMAND` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | `NO_ELEVATION` | 60 seconds | Local IPC or loopback only, exact value blocked | `MUTATION_RISK_UNRESOLVED` | Evidence path, `REP-B2-BLK-002`, and `MAP-B2-BLK-002` remain blocked. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| `B2-BLK-003` | `TGT-OLLAMA-001` | Exact Project Owner-approved loopback address, port, endpoint path, and non-mutating status command. | `NO_COMMAND` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | `NO_ELEVATION` | 60 seconds | Loopback only, exact value blocked | `MUTATION_RISK_UNRESOLVED` | Evidence path, `REP-B2-BLK-003`, and `MAP-B2-BLK-003` remain blocked. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| `B2-BLK-004` | `TGT-HERMES-001` | Exact executable/package path, supported version syntax, or exact configuration-presence path. | `NO_COMMAND` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | `NO_ELEVATION` | 300 seconds only if later proposed | `NONE` | `MUTATION_RISK_UNRESOLVED` | Evidence path, `REP-B2-BLK-004`, and `MAP-B2-BLK-004` remain blocked. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| `B2-BLK-005` | `TGT-OPENWEBUI-001` | Exact executable/process identifier or approved loopback address, port, endpoint, and safe status command. | `NO_COMMAND` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | `NO_ELEVATION` | 60 seconds | Loopback only, exact value blocked | `MUTATION_RISK_UNRESOLVED` | Evidence path, `REP-B2-BLK-005`, and `MAP-B2-BLK-005` remain blocked. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| `B2-BLK-006` | `TGT-LMSTUDIO-001` | Exact executable/process identifier or approved loopback address, port, endpoint, and safe status command. | `NO_COMMAND` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | `NO_ELEVATION` | 60 seconds | Loopback only, exact value blocked | `MUTATION_RISK_UNRESOLVED` | Evidence path, `REP-B2-BLK-006`, and `MAP-B2-BLK-006` remain blocked. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |

### Manifest counts

- Approved manifest planning-input rows: 11 (`B2-MAN-001` through `B2-MAN-010`, plus `B2-MAN-013`).
- Approved-with-required-revision planning row: 1 (`B2-MAN-011`).
- Deferred command-semantics row: 1 (`B2-MAN-012`).
- Resolved blocker-identity record: 1 (`B2-BLK-001`).
- Explicit blocked rows with no command: 5 (`B2-BLK-002` through `B2-BLK-006`).
- Total closed manifest and blocker records: 19.

### Batch 8 selected initial Model A manifest overlay

The historical command, supporting, and blocker records above remain intact. The selected initial Model A documentary disposition is:

| Historical records | Selected Model A disposition |
| --- | --- |
| `B2-MAN-001` through `B2-MAN-010` | Retained in selected initial Model A documentary scope |
| `B2-MAN-011` | `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE` |
| `B2-MAN-012` | `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`; historical deferred semantics retained |
| `B2-MAN-013` | Retained in selected initial Model A documentary scope |
| `B2-BLK-001` | `RETAINED_AS_SUPPORTING_TRACEABILITY_RECORD_NOT_AS_EXECUTABLE_MANIFEST_ROW` |
| `B2-BLK-002` through `B2-BLK-006` | `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE` |

Selected initial Model A counts:

- Retained command-manifest rows: 11.
- Supporting traceability records: 1.
- Supporting records counted as commands: 0.
- Supporting records counted as interactions: 0.
- Excluded command and blocked records retained in historical traceability: 7.
- Execution-authorized rows: 0.
- Evidence-collection-authorized rows: 0.

### Current status

- Field 2: `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`
- Field 3: `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`

Historical manifest content remains approved planning evidence only. For selected Model A, `B2-MAN-011`, `B2-MAN-012`, and `B2-BLK-002` through `B2-BLK-006` are outside the selected initial scope and are not prerequisites for its documentary completeness. Retained rows remain non-executable and subject to Field 8, Field 9, Field 10, Field 11, semantic-verification, and satisfaction dependencies. Field 2 and Field 3 states remain unchanged.

## 8. Mandatory Field 4 — Services, Endpoints, Ports, Network Actions, and Resources

### Proposed closed interaction allowlist

Default network rule: `ALL_UNLISTED_NETWORK_ACTIONS_PROHIBITED`.

`NONE` means the proposed interaction must not initiate any network or service connection. `LOOPBACK_ONLY` is a scope ceiling, not an approved endpoint; where the address, port, or endpoint is blocked, no connection may be attempted.

| Interaction ID | Target ID | Service or resource | Exact endpoint or resource identifier | Port | Network scope | Permitted interaction | Explicitly prohibited interactions | Mutation prohibition | Approval state |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `B2-INT-001` | `TGT-REPO-001` | Approved EAIRA working tree | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | `NOT_APPLICABLE` | `NONE` | Only `B2-MAN-002` through `B2-MAN-007` under a future separate execution authorization. | Fetch, pull, push, commit, checkout, reset, clean, merge, rebase, configuration change, or file mutation. | Repository content, refs, index, worktree, and configuration must not change. | `APPROVED_AS_PLANNING_INTERACTION_DEFINITION` |
| `B2-INT-002` | `TGT-WSL-001` | Ubuntu under WSL2 | Approved WSL2 environment boundary; exact commands `B2-MAN-001`, `B2-MAN-008`, and `B2-MAN-009` only | `NOT_APPLICABLE` | `NONE` | Bounded version, kernel identity, and working-directory observations under a future separate execution authorization. | Environment dumps, user/host inventory beyond expected fields, package actions, process enumeration, privilege elevation, or configuration reads. | WSL, host, package, process, and configuration state must not change. | `APPROVED_AS_PLANNING_INTERACTION_DEFINITION` |
| `B2-INT-003` | `TGT-GIT-WSL-001` | WSL Git executable | `git` resolved only in a future separately authorized WSL execution context | `NOT_APPLICABLE` | `NONE` | Only `B2-MAN-001` through `B2-MAN-007` under a future separate execution authorization. | Any Git command not listed in the closed manifest. | Repository and Git configuration state must not change. | `APPROVED_AS_PLANNING_INTERACTION_DEFINITION` |
| `B2-INT-004` | `TGT-DOCKER-001` | Docker client executable | `docker` client-only commands `B2-MAN-010` and `B2-MAN-011` | `NOT_APPLICABLE` | `NONE` | Client version and selected context-name planning interactions under a future separate execution authorization; `B2-MAN-011` also requires Fields 8 and 9 resolution. | `docker context inspect`; context details; Docker engine inspection or contact; container/image/network/volume listing; run, exec, start, stop, restart, create, remove, pull, load, build, prune; configuration or environment dumps. | Docker client, context, engine, container, image, network, volume, and configuration state must not change. | `APPROVED_AS_PLANNING_INTERACTION_DEFINITION` |
| `B2-INT-005` | `TGT-OLLAMA-001` | Future client-only Ollama interaction | No command currently approved; applies only to a future explicitly approved client-only command | `NOT_APPLICABLE`; no port approved | `NONE`; no service contact approved | Only a future command whose client-only behavior is independently established and separately approved. This conditional definition does not approve `B2-MAN-012`. | `B2-MAN-012`; Ollama service contact; endpoint or port interaction; model or runtime interaction; model listing, pull, run, load, inference, show, deletion, or metadata export. | Ollama service, model, runtime, client, and configuration state must not change. | `APPROVED_CONDITIONALLY_AS_PLANNING_INTERACTION` |
| `B2-INT-006` | `TGT-GIT-WIN-001` | Windows Git executable | Windows path `C:\Program Files\Git\cmd\git.exe`; WSL-visible path `/mnt/c/Program Files/Git/cmd/git.exe`; `B2-MAN-013` only | `NOT_APPLICABLE` | `NONE` | Future version-only planning interaction under a separate execution authorization; no repository interaction. | General Windows Git usage; repository interaction; configuration read; credential interaction; network action; any inferred executable path or command. | Repository, Git configuration, credentials, and environment state must not change. | `APPROVED_AS_PLANNING_INTERACTION_DEFINITION` |
| `B2-INT-007` | `TGT-DOCKER-001` | Docker engine | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Local IPC or `LOOPBACK_ONLY` | None. | Engine contact, lifecycle actions, unrestricted inspection, sensitive configuration, or non-loopback access. | All Docker engine and managed-resource state must remain unchanged. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| `B2-INT-008` | `TGT-OLLAMA-001` | Ollama local service | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `LOOPBACK_ONLY` | None. | Connectivity tests, status/version calls, model actions, inference, writes, or non-loopback access. | Service, model, runtime, and configuration state must remain unchanged. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| `B2-INT-009` | `TGT-HERMES-001` | Hermes local runtime | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `NOT_APPLICABLE` | `NONE` | None. | Agent/task execution, browser access, shell actions, model inference, process interaction, or configuration-value disclosure. | Runtime, task, browser, shell, model, and configuration state must remain unchanged. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| `B2-INT-010` | `TGT-OPENWEBUI-001` | OpenWebUI local service | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `LOOPBACK_ONLY` | None. | Login, endpoint calls, API writes, model loading, inference, plugin execution, configuration export, credentials, or non-loopback access. | Application, service, model, plugin, and configuration state must remain unchanged. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| `B2-INT-011` | `TGT-LMSTUDIO-001` | LM Studio local application or service | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | `LOOPBACK_ONLY` | None. | Application/service calls, model loading, inference, configuration export, credentials, or non-loopback access. | Application, service, model, runtime, and configuration state must remain unchanged. | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |

### Batch 8 selected initial Model A interaction overlay

The historical Batch 2 interaction table above remains intact as pre-Batch 8 historical planning evidence. The selected initial Model A overlay below records the adopted effective initial-scope boundary and does not rewrite the historical interaction record.

The selected initial Model A interaction allowlist retains exactly:

| Interaction | Selected Model A disposition |
| --- | --- |
| `B2-INT-001` | Retained in selected initial Model A documentary scope |
| `B2-INT-002` | Retained in selected initial Model A documentary scope |
| `B2-INT-003` | Retained in selected initial Model A documentary scope |
| `B2-INT-004` | Retained in selected initial Model A documentary scope; narrowed strictly to `B2-MAN-010` |
| `B2-INT-006` | Retained in selected initial Model A documentary scope |

Within this selected-scope overlay, `B2-INT-004` includes only the Docker client-version planning interaction associated with `B2-MAN-010`. It excludes `B2-MAN-011`, Docker context equality handling, context-name retention, context inspection, Docker Engine contact, interaction authority, and execution authority.

`B2-INT-005` and `B2-INT-007` through `B2-INT-011` are `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`. Their historical records remain traceable, and any later inclusion requires a separately authorized extension.

### Explicitly prohibited targets and interactions

| Target ID | Prohibited boundary | Command | Approval state |
| --- | --- | --- | --- |
| `TGT-SUPABASE-001` | Any local Supabase environment or interaction pending separate approval. | `NO_COMMAND` | `PROHIBITED` |
| `TGT-DATABASE-001` | Any local or remote database query, connection, migration, or mutation. | `NO_COMMAND` | `PROHIBITED` |
| `TGT-PRODUCTION-001` | All production resources and interactions. | `NO_COMMAND` | `PROHIBITED` |
| `TGT-CREDENTIAL-001` | Credentials, tokens, keys, secrets, and credential-bearing configuration. | `NO_COMMAND` | `PROHIBITED` |
| `TGT-EXTERNAL-001` | External endpoints, internet services, and non-loopback network actions. | `NO_COMMAND` | `PROHIBITED` |

API writes, service lifecycle actions, container lifecycle actions, model execution or inference, implementation, remediation, deployment, automation, and any interaction not explicitly listed remain prohibited.

### Current status

`PARTIALLY_RESOLVED_WITH_BLOCKERS`

Historical interaction definitions remain approved planning inputs only. The selected initial Model A overlay retains exactly five documentary interactions and excludes Docker Engine, Ollama service, Hermes, OpenWebUI, and LM Studio interactions from the initial scope. Those historical or future-extension matters remain non-executable. No service endpoint or port is approved, and Field 4 remains unchanged.

## 9. Mandatory Fields 5 and 6 — Operator, Independent Verifier, Separation, and Stop Authority

### Approved named roles

The following assignments are `PROJECT_OWNER_DECISION` inputs approved by `APPROVE_BATCH_1_WITHOUT_EXECUTION_AUTHORITY`.

| Role | Approved assignment |
| --- | --- |
| Project Owner | Antony Cheng |
| Assessment Operator | Codex operating under Antony Cheng's explicit task-level authorization |
| Operator accountable human owner | Antony Cheng |
| Independent Verifier | ChatGPT performing direct repository and approved evidence review |
| Verifier accountable human owner | Antony Cheng |
| Stop Authority | Antony Cheng |

### Approved role limitations

- Codex may perform only future actions listed in an explicitly approved command manifest.
- ChatGPT may verify only approved direct evidence and may not generate the primary evidence it verifies.
- Antony Cheng retains all final authorization and stop authority.
- Neither Codex nor ChatGPT may establish readiness, approve a milestone, authorize implementation, or expand scope.
- These role assignments do not authorize assessment execution, evidence collection, command execution, or target interaction.

### Approved independence and stop controls

1. Codex is the primary Assessment Operator.
2. ChatGPT is the Independent Verifier.
3. Operator and Verifier must not be the same execution instance for a material observation.
4. The Verifier must review direct outputs and may not rely on Operator summaries alone.
5. Agent self-report alone is insufficient evidence.
6. Antony Cheng is the Stop Authority.
7. Operator and Verifier must stop immediately when:
   - authorization is absent, unclear, or conflicting;
   - a target or command is unlisted;
   - mutation risk is unresolved;
   - credentials or sensitive data may be exposed;
   - unexpected elevated privilege is required;
   - evidence provenance is missing;
   - repository or environment state changes unexpectedly;
   - scope, authority, or verifier independence becomes unclear.
8. No remediation or corrective action is permitted after a stop condition.
9. Restart after a stop requires a new explicit Project Owner decision.

### Independence limitation

`RISK_ACCEPTED_FOR_BOUNDED_LOCAL_ASSESSMENT_PLANNING`

The Project Owner accepts that independence is procedural rather than organizational because both Agent roles operate under the same Project Owner. This accepted planning risk does not reduce direct-evidence, role-separation, stop, or future-authorization requirements.

### Current status

- Field 5: `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER`
- Field 6: `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER`

The named roles, procedural independence requirements, stop authority, stop conditions, and restart control are approved as planning inputs only.

## 10. Mandatory Field 7 — Observation Window and Evidence Freshness

### Approved observation and freshness controls

The following controls are `PROJECT_OWNER_DECISION` inputs approved by `APPROVE_BATCH_1_WITHOUT_EXECUTION_AUTHORITY`.

| Decision input | Approved value |
| --- | --- |
| Timezone | `Asia/Ho_Chi_Minh` |
| UTC offset treatment | Record the actual UTC offset in every timestamp |
| Authoritative clock source | Windows host operating-system clock |
| Secondary clock reference | WSL2 clock; discrepancies must be recorded |
| Maximum session duration | Four hours per separately authorized assessment session |
| Observation start | Must be explicitly recorded in the future execution authorization |
| Observation end | Start time plus no more than four hours |
| Evidence validity | Valid only for the approved session and current repository `HEAD` |
| Maximum evidence age | Four hours from capture unless a shorter criterion-specific limit applies |
| Repository HEAD change | Repository-dependent evidence becomes `RERUN_REQUIRED` |
| Tool version change | Affected evidence becomes `RERUN_REQUIRED` |
| Service or configuration change | Affected evidence becomes `RERUN_REQUIRED` |
| Target change | Affected evidence becomes `RERUN_REQUIRED` |
| Interrupted assessment | Partial evidence is `UNUSABLE` unless separately retained under approved stopped-assessment handling |
| Outside-window evidence | `UNUSABLE` |
| Missing timestamp or provenance | `UNUSABLE` |
| Rerun authorization | Any rerun after the approved session requires renewed Project Owner authorization |
| Cross-session evidence reuse | Prohibited unless explicitly approved |

### Approved control-state definitions

| State | Approved definition |
| --- | --- |
| `FRESH` | Captured within the approved session, using the approved clock controls, within the applicable maximum evidence age, for the current repository `HEAD`, and not affected by a rerun trigger. |
| `STALE` | Older than the applicable maximum evidence age or a shorter criterion-specific limit; stale evidence is not valid for decision use. |
| `OUTSIDE_WINDOW` | Captured before the explicitly authorized observation start or after the authorized observation end; outside-window evidence is `UNUSABLE`. |
| `RERUN_REQUIRED` | A repository `HEAD`, tool version, service, configuration, target, or other approved trigger changed such that affected evidence must be collected again under valid authorization. |
| `UNUSABLE` | Evidence that is partial after interruption, outside the approved window, missing a timestamp or provenance, or otherwise invalid under an approved control. |

These definitions govern only a future separately authorized assessment session. They do not authorize a session, set an observation start timestamp, authorize a rerun, or permit evidence collection.

### Current status

`RESOLVED_AND_APPROVED_BY_PROJECT_OWNER`

## 11. Mandatory Field 8 — Evidence Handling and Integrity

### Approved closed evidence-root planning structure

The Project Owner selected Option B as `PROJECT_OWNER_DECISION` planning input:

- Windows planning root: `C:\EAIRA\Evidence`
- WSL planning root: `/mnt/c/EAIRA/Evidence`

The following closed structural pattern is approved as `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT`. `EAIRA_EVIDENCE_ROOT` deterministically represents either approved Option B path form. The pattern is planning text only and must not be created:

```text
EAIRA_EVIDENCE_ROOT/
  session-manifest/
  direct-output/
  redacted-output/
  verifier-review/
  discrepancy-log/
  stopped-assessment/
  integrity-records/
```

Neither path is verified to exist or usable. Directory or file creation, access configuration, evidence storage, and evidence collection require future separate authorization.

### Approved evidence-control planning register

| Control | Approved planning value or retained blocker | Approval state |
| --- | --- | --- |
| Exact evidence root path | Option B planning forms: Windows `C:\EAIRA\Evidence`; WSL `/mnt/c/EAIRA/Evidence`. Existence and use are not authorized or verified. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Writers | Role category `ASSESSMENT_OPERATOR` for future separately authorized direct capture and `INDEPENDENT_VERIFIER` for separate verifier disposition. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Readers | Role categories `PROJECT_OWNER`, `ASSESSMENT_OPERATOR`, `INDEPENDENT_VERIFIER`, and `STOP_AUTHORITY`. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Reader/writer separation | Operator records, direct output, and verifier disposition remain separated; the verifier does not generate the primary evidence reviewed. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Access-control planning approach | `Combined Windows host control with WSL access`; exact operating-system identities, group mapping, ACL entries, inheritance, effective access, privilege requirements, Windows-to-WSL mapping, and cross-boundary enforcement remain blocked. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Role-to-permission matrix | The closed Batch 4 role matrix is approved as planning content; it grants no current access. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Naming convention | `<session-id>__<manifest-id>__<target-id>__<reproduction-id>__<mapping-id>__<timestamp>__<artifact-class>.<approved-extension>`. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Required identifiers | Use exact manifest, target, reproduction, mapping, session, timestamp, operator, and verifier identifiers; aliases and substitutions are prohibited. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Direct-output separation | Safely retained direct output remains separate from redacted derivatives; unsafe output is not copied merely to preserve it. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Verifier disposition | Store separately from operator records and direct output, linked by the approved identifiers. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Overwrite prohibition | Silent replacement is prohibited. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Corrections | Append-only or versioned correction records identify the superseded artifact, reason, author, and time without deleting history. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Output-state classification | Explicitly classify `MISSING`, `PARTIAL`, `CONFLICTING`, `STALE`, `UNEXPECTED`, `UNSAFE`, or `USABLE_PENDING_VERIFICATION`. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Evidence export | Prohibited unless an exact destination, transfer method, reader list, redaction state, and disposal rule are separately approved. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Repository storage | Prohibited unless an exact repository location, content class, access rule, retention rule, and separate Project Owner approval exist. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |
| Prohibited or unsafe content | Prohibited secrets and unsafe values are excluded from retention. | `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT` |

No operating-system user, group, ACL, filesystem permission, encryption mechanism, or actual reader/writer access is inferred or configured.

### Approved integrity planning input

Proposed future integrity algorithm: `SHA-256`.

Classification: `APPROVED_AS_INTEGRITY_PLANNING_INPUT_NOT_EXECUTABLE` and `PROJECT_OWNER_DECISION`.

- Hash each safely retained direct artifact after capture.
- Store its hash in a separate integrity record.
- Hash redacted derivatives separately.
- Never retain or hash prohibited sensitive content merely to preserve evidence.
- The Independent Verifier compares the recorded value.
- No hash calculation is authorized by this decision.

### Approved retention planning input

Retention policy: `FIXED_30_DAY_RETENTION_AFTER_FINAL_VERIFIER_DISPOSITION`.

Classification: `APPROVED_AS_RETENTION_PLANNING_INPUT` and `PROJECT_OWNER_DECISION`.

- The policy applies only to safely retained and usable evidence.
- Retention begins when final verifier disposition is recorded.
- Disposal after 30 calendar days requires approval by the Project Owner or delegated Stop Authority.
- Retention beyond 30 days requires a new Project Owner decision.
- Unusable, unsafe, or accidentally exposed material follows the incident decision instead of the normal retention period.
- This decision does not authorize creation or retention of any actual evidence.

### Approved stopped-assessment planning controls

- Partial evidence is `UNUSABLE`.
- Retain only a non-sensitive minimum stop record.
- Safely captured material may be retained only by explicit Project Owner decision.
- No further capture, copying, remediation, or alternate command is permitted.
- Restart requires a new explicit Project Owner decision.

The controls and the Batch 4 minimum stopped-assessment record schema are `APPROVED_AS_EVIDENCE_CONTROL_PLANNING_INPUT`. No stop record or evidence is created or retained by this decision.

### Retained Field 8 blockers

- Actual operating-system user and group identities.
- Exact ACL implementation, permission behavior, and cross-boundary identity/group mapping.
- Encryption mechanism.
- Exact disposal command or physical deletion method.
- Final incident-notification channel and configuration.

### Current status

`PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`

Field 8 remains blocking. The approved planning root and access approach do not authorize creation or configuration. No evidence root may be created, and no evidence creation, hashing, retention, or disposal activity is authorized.

Batch 6 acceptance as planning evidence does not change this state. Options A–D remain `REVIEWED_NOT_SELECTED`; all four Annex alternatives remain `PROPOSED_NOT_APPROVED`; `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT` and `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS` remain controlling.

Batch 7 acceptance as planning evidence and documentary selection of Model B do not change this state. No actual artifact is classified; no encryption scope, plaintext reader, administrator access, verifier decryption authority, backup, recovery, replica, export, product, vendor, algorithm, architecture or key-governance model is approved.

## 12. Mandatory Field 9 — Sensitive Data, Redaction, and Accidental Exposure

### Existing prohibition boundary

- Secret-value capture or disclosure is prohibited.
- Assessment activity must stop if credentials or sensitive values are requested or exposed.
- Evidence must not infer or disclose sensitive information outside approved scope.

### Approved sensitive-data taxonomy and general dispositions

The following are `PROJECT_OWNER_DECISION` planning controls. They do not authorize capture, retention, or redaction activity.

| Category | Approved planning disposition |
| --- | --- |
| Credentials | `PROHIBITED_FROM_CAPTURE` |
| Passwords | `PROHIBITED_FROM_CAPTURE` |
| API keys | `PROHIBITED_FROM_CAPTURE` |
| OAuth tokens | `PROHIBITED_FROM_CAPTURE` |
| Personal access tokens (PATs) | `PROHIBITED_FROM_CAPTURE` |
| Private keys | `PROHIBITED_FROM_CAPTURE` |
| Certificates containing private material | `PROHIBITED_FROM_CAPTURE` |
| Connection strings | `PROHIBITED_FROM_CAPTURE` |
| Database credentials | `PROHIBITED_FROM_CAPTURE` |
| Environment-variable values | `PROHIBITED_FROM_CAPTURE` |
| Personally identifiable information not otherwise classified | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| User names where not required | `REDACT_BEFORE_RETENTION` |
| Email addresses | `PROHIBITED_FROM_CAPTURE` unless explicitly required by a separately approved criterion |
| Host names | Retain only if required by an approved criterion |
| Local absolute paths | `REDACT_TO_APPROVED_PATH_ALIAS` |
| Repository-relative paths | Retain only when required by an approved criterion and after sensitive-path review |
| Commit author names | `RETAIN_NAME_ONLY_IF_REQUIRED_AND_APPROVED` |
| Commit subjects | Review for secrets and business-sensitive information before retention |
| Configuration names | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` |
| Docker context names | Retain only an equality result against a separately approved expected value |
| Model names | Retain only if required by an approved criterion |
| Service names | Retain only if required by an approved criterion |
| Process names | Retain only if required by an approved criterion |
| Ports and endpoints | Retain only after exact Field 4 approval |
| Business-sensitive information | `REDACT_BEFORE_RETENTION_OR_MARK_UNUSABLE` |
| Production identifiers | `PROHIBITED_FROM_CAPTURE` |

No secret value is approved for capture.

### Batch 7 documentary classification boundary

Model A is `REVIEWED_NOT_SELECTED`. Model B is `SELECTED_AS_DOCUMENTARY_CLASSIFICATION_MODEL_ONLY` with documentary categories `Public`, `Internal non-sensitive`, `Confidential`, `Restricted-retainable` and `Prohibited from retention`.

The approved Annex Field 9 taxonomy and dispositions remain controlling. Model B supplies no actual classification or category assignment and does not replace, narrow or reinterpret any Annex disposition. Every mapping remains a `NON-SELECTIVE DOCUMENTARY CROSSWALK`; any apparent inconsistency remains a `POTENTIAL_DECISION CONFLICT` for Project Owner resolution.

Existing `PROHIBITED_FROM_CAPTURE` dispositions remain stricter than the Model B `Prohibited from retention` category. The latter does not grant temporary capture, retention, transformation or a retention exception. Encryption, hashing, redaction, transformation, aliasing or restricted access cannot authorize retention of prohibited content.

### Approved manifest-specific Field 9 planning mappings

`B2-MAN-012` is excluded because it remains `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW` and is neither executable nor collectible.

| Manifest ID | Output category | Approved planning disposition and stop boundary | Approval state |
| --- | --- | --- | --- |
| `B2-MAN-001` | WSL Git product/version | Retain only product/version if separately authorized for evidence collection; stop on any additional field. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |
| `B2-MAN-002` | Local absolute repository path | Full absolute path must not be retained in redacted evidence; use approved alias `EAIRA_REPOSITORY_ROOT`. | `APPROVED_WITH_REQUIRED_REDACTION_REVISION` |
| `B2-MAN-003` | Branch name | `RETAIN_NAME_ONLY_IF_APPROVED`; stop if more than one line or unrelated ref data appears. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |
| `B2-MAN-004` | Commit SHA | Exact retention permitted only if separately authorized for evidence collection; stop on additional metadata. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |
| `B2-MAN-005` | Remote-tracking SHA | Exact retention permitted only if separately authorized; stop on network action or additional metadata. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |
| `B2-MAN-006` | Branch header and tracked repository-relative paths | Require sensitive-path review before retention; stop and mark evidence unusable for credentials, tokens, secret-related filenames, production identifiers, or business-sensitive paths outside the approved criterion. | `APPROVED_WITH_REQUIRED_REDACTION_REVISION` |
| `B2-MAN-007` | SHA, author name, timestamp, commit subject | SHA may be retained exactly only if separately authorized; timestamp may be retained exactly; author name only if required and approved; subject only after sensitive-content review; email, body, and signature material prohibited. | `APPROVED_WITH_REQUIRED_REDACTION_REVISION` |
| `B2-MAN-008` | Kernel name, release, architecture | Retain only these three fields if separately authorized; host/user names or other inventory trigger stop. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |
| `B2-MAN-009` | Local absolute working-directory path | Full absolute path must not be retained in redacted evidence; use approved alias `EAIRA_REPOSITORY_ROOT`. | `APPROVED_WITH_REQUIRED_REDACTION_REVISION` |
| `B2-MAN-010` | Docker client product/version/build | Retain bounded client fields only if separately authorized; engine or configuration data trigger stop. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |
| `B2-MAN-011` | Docker context name | Retain only whether the observed name equals a separately approved expected value, and only when Field 8 is sufficiently resolved, output is exactly one context name, and no context detail or Docker engine contact occurs. Exact-name retention is not approved. | `APPROVED_WITH_REQUIRED_REDACTION_REVISION` |
| `B2-MAN-013` | Windows Git product/version | Retain only product/version if separately authorized; repository, configuration, credential, or additional fields trigger stop. | `APPROVED_AS_REDACTION_PLANNING_CONTROL` |

### Batch 8 selected-scope Field 9 boundary

All historical Field 9 records remain intact. For the selected initial Model A scope, `B2-MAN-011` and its context-name or equality-result handling are `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`. No context-name retention, context equality handling, context inspection, Docker Engine contact, or related evidence collection is retained.

This selected-scope exclusion does not resolve or rewrite historical `B2-MAN-011`, `REP-B2-011`, or `MAP-B2-011` semantics. The approved Field 9 taxonomy, Batch 7 Model B documentary classification decision, stricter prohibitions, and current Field 9 state remain unchanged.

### Approved accidental-exposure planning procedure

State: `APPROVED_AS_INCIDENT_RESPONSE_PLANNING_CONTROL`.

1. Stop immediately.
2. Execute no further command and perform no remediation.
3. Do not copy, repeat, quote, transform, or further expose the sensitive value.
4. Restrict access only through an approved mechanism.
5. Mark affected evidence `UNUSABLE_PENDING_PROJECT_OWNER_DECISION`.
6. Notify the Stop Authority through an approved non-sensitive channel.
7. Record only a non-sensitive incident ID, timestamp, manifest ID, target ID, and exposure category.
8. The Project Owner determines quarantine, redaction, retention, or disposal.
9. Restart requires a new explicit Project Owner decision.

No incident record is created under Batch 3. The exact notification channel, quarantine mechanism, filesystem access restriction, and disposal mechanism remain blocked.

### Batch 4 approved redaction implementation planning controls

The deterministic path-alias rules, sensitive repository-relative path review controls, accidental-exposure stop principle, and non-sensitive redaction-record schema are approved as planning controls. Their applicable classifications are `APPROVED_AS_REDACTION_PLANNING_CONTROL` and `APPROVED_AS_INCIDENT_RESPONSE_PLANNING_CONTROL`. Exact permitted business-sensitive-information categories, user-home prefix inputs, quarantine mechanism, filesystem restriction implementation, final notification channel and configuration, and disposal mechanism remain `BLOCKED_PENDING_PROJECT_OWNER_INPUT`.

### Current status

`PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`

The prohibitions, general dispositions, manifest-specific planning controls, Batch 4 redaction controls, and incident procedure are approved as `PROJECT_OWNER_DECISION` planning inputs. Required redaction revisions, exact permitted business-sensitive-information categories, and exact implementation mechanisms remain blocking; no capture or redaction activity is authorized.

## 13. Mandatory Field 10 — Reproduction Procedures

### Approved reproduction-record planning controls

Each reproduction record consists of `B3-REP-COMMON` plus both table rows carrying the same Reproduction ID. This incorporation is part of each record and supplies every required field. All 12 records are `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` and `PROJECT_OWNER_DECISION` planning inputs. `B2-MAN-012` is excluded and remains `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW`.

`B3-REP-COMMON` proposes these controls for every record:

- Preconditions: a future explicit execution authorization; approved Fields 1–9; approved session ID, evidence root, roles, redaction rules, and exact executable resolution; clean authorization and scope checks.
- Operator procedure: confirm exact manifest text without aliases, wrappers, substitutions, or copy/paste changes; record start time; run the exact command once only if separately authorized; record end time and exit status; stop before copying unsafe output; preserve only safely capturable output under approved Field 8 controls.
- Verifier procedure: independently inspect direct output and provenance, exact command/arguments, IDs, timestamps, exit status, redaction log, integrity record, and stop disposition; verifier output remains separate.
- Discrepancy handling: classify missing, partial, conflicting, stale, unexpected, or unsafe output; stop without remediation or alternate command; refer to Stop Authority.
- Rerun triggers: Field 7 rules, repository `HEAD`, tool version, target, service/configuration state, authorization, or evidence-integrity change; every rerun requires future execution authorization.
- Quality controls: alternate commands, shell aliases, and wrappers are prohibited unless explicitly approved. Output outside expected fields triggers stop. Failure, timeout, or nonzero exit status is an observation outcome only and never remediation authority.

### Proposed reproduction identity and execution fields

| Reproduction ID | Manifest / target | Exact command and ordered arguments | Exact working directory | Executor / privilege | Timeout / network |
| --- | --- | --- | --- | --- | --- |
| `REP-B2-001` | `B2-MAN-001` / `TGT-GIT-WSL-001` | `git --version`; `--version` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Git in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-002` | `B2-MAN-002` / `TGT-REPO-001` | `git rev-parse --show-toplevel`; `rev-parse`, `--show-toplevel` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Git in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-003` | `B2-MAN-003` / `TGT-REPO-001` | `git branch --show-current`; `branch`, `--show-current` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Git in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-004` | `B2-MAN-004` / `TGT-REPO-001` | `git rev-parse HEAD`; `rev-parse`, `HEAD` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Git in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-005` | `B2-MAN-005` / `TGT-REPO-001` | `git rev-parse origin/master`; `rev-parse`, `origin/master` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Git in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-006` | `B2-MAN-006` / `TGT-REPO-001` | `git status --short --branch --untracked-files=no`; `status`, `--short`, `--branch`, `--untracked-files=no` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Git in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-007` | `B2-MAN-007` / `TGT-REPO-001` | `git log -1 --format=%H%x09%an%x09%aI%x09%s`; `log`, `-1`, `--format=%H%x09%an%x09%aI%x09%s` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Git in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-008` | `B2-MAN-008` / `TGT-WSL-001` | `uname -srm`; `-srm` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL shell in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-009` | `B2-MAN-009` / `TGT-WSL-001` | `pwd -P`; `-P` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL shell in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-010` | `B2-MAN-010` / `TGT-DOCKER-001` | `docker --version`; `--version` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Docker client in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-011` | `B2-MAN-011` / `TGT-DOCKER-001` | `docker context show`; `context`, `show` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | WSL Docker client in approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |
| `REP-B2-013` | `B2-MAN-013` / `TGT-GIT-WIN-001` | `"/mnt/c/Program Files/Git/cmd/git.exe" --version`; `--version` | `/mnt/c/Users/User/OneDrive/文件/EAIRA-Enterprise-AI` | Windows Git invoked from approved WSL context / `NO_ELEVATION` | 30 seconds / `NONE` |

### Proposed reproduction output, evidence, and traceability fields

| Reproduction ID | Expected bounded output | Field 9 dependency | Field 8 destination placeholder | Record-specific precondition / stop | Mapping | Approval state |
| --- | --- | --- | --- | --- | --- | --- |
| `REP-B2-001` | One WSL Git product/version string. | Product/version retention approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-001__REP-B2-001.pending` | Exact WSL Git resolution; stop on additional fields. | `MAP-B2-001` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-002` | One approved absolute repository path. | Absolute-path redaction approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-002__REP-B2-002.pending` | Exact approved path; stop on any other path. | `MAP-B2-002` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-003` | One branch name or empty detached-state output. | Branch-name retention approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-003__REP-B2-003.pending` | Stop on more than one branch-name line. | `MAP-B2-003` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-004` | One 40-hexadecimal `HEAD` SHA. | Exact-SHA retention approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-004__REP-B2-004.pending` | Stop on malformed SHA or additional metadata. | `MAP-B2-004` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-005` | One 40-hexadecimal local `origin/master` SHA. | Exact-SHA retention approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-005__REP-B2-005.pending` | No fetch/network; stop on malformed SHA or additional metadata. | `MAP-B2-005` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-006` | Branch header and tracked relative status entries only. | Repository-relative-path decisions. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-006__REP-B2-006.pending` | Stop on untracked, absolute, sensitive, or unrelated fields. | `MAP-B2-006` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-007` | SHA, author name, ISO-8601 author time, subject. | Author-name and subject decisions. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-007__REP-B2-007.pending` | Stop on email, body, signature, or extra fields. | `MAP-B2-007` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-008` | Kernel name, release, architecture only. | Host-metadata retention approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-008__REP-B2-008.pending` | Stop on host/user names or other inventory. | `MAP-B2-008` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-009` | One approved absolute working-directory path. | Absolute-path redaction approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-009__REP-B2-009.pending` | Stop on any other path. | `MAP-B2-009` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-010` | Docker client product/version/build only. | Client-metadata retention approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-010__REP-B2-010.pending` | Stop on engine contact or extra data. | `MAP-B2-010` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-011` | One Boolean or bounded equality-result value indicating whether the observed Docker context name equals the separately approved expected value; the exact context name must not be retained. | Field 9 equality-result approval and separately approved expected comparison value; no collection until Fields 8 and 9 resolve. | `EAIRA_EVIDENCE_ROOT/redacted-output/<session>__B2-MAN-011__REP-B2-011.pending` | Stop if the exact context name would be retained, if the expected comparison value is not separately approved, or on `docker context inspect`, context details, or engine contact. | `MAP-B2-011` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |
| `REP-B2-013` | One Windows Git product/version string. | Product/version retention approval. | `EAIRA_EVIDENCE_ROOT/direct-output/<session>__B2-MAN-013__REP-B2-013.pending` | Exact approved executable; stop on repository, configuration, credential, network, or extra data. | `MAP-B2-013` | `APPROVED_AS_REPRODUCTION_PLANNING_CONTROL_NOT_EXECUTABLE` |

### Reproduction count and status

- Approved reproduction planning-control records: 12.
- Excluded deferred row: `B2-MAN-012` / `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW`.
- Commands executed to test reproduction records: 0.

### Batch 8 selected initial Model A reproduction overlay

All twelve historical reproduction records remain intact. The selected initial Model A scope retains eleven reproduction records:

- `REP-B2-001` through `REP-B2-010`
- `REP-B2-013`

`REP-B2-011` is `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`. Its historical record and its semantic relationship to `MAP-B2-011` remain unresolved and are preserved only for historical traceability or a future separately authorized extension review.

Selected initial-scope reproduction-record count: 11. Field 10 remains `APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES`.

### Current status

`APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES`

Field 10 remains blocking because Field 8 and Field 9 dependencies are unresolved and execution is unauthorized. No command change, alias, wrapper, substitution, alternate command, evidence destination use, remediation, or reproduction execution is authorized.

## 14. Mandatory Field 11 — Criteria-to-Evidence Mapping

### Approved criteria-mapping planning controls

Each mapping consists of both table rows carrying the same Mapping ID. All 12 mappings are `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` and `PROJECT_OWNER_DECISION` planning inputs. Evidence artifact placeholders are Field 8 patterns only and are not usable. `B2-MAN-012` has no mapping because it remains deferred.

### Proposed bounded criteria, observations, and verifier actions

| Mapping ID | Manifest ID | Criterion and exact bounded observation | Expected evidence artifact | Verifier action | Sufficient result |
| --- | --- | --- | --- | --- | --- |
| `MAP-B2-001` | `B2-MAN-001` | Observe the WSL Git product/version string only. | Field 8 direct output for `REP-B2-001`. | Verify provenance and one bounded product/version field. | Expected bounded version text captured safely under valid authorization. |
| `MAP-B2-002` | `B2-MAN-002` | Observe whether the command returns the exact approved repository top-level path. | Field 8 direct/redacted output for `REP-B2-002`. | Compare safely against the approved path and review redaction. | Exact approved path observed without extra output. |
| `MAP-B2-003` | `B2-MAN-003` | Observe the current symbolic branch name or detached-state empty output. | Field 8 direct output for `REP-B2-003`. | Verify one bounded branch-name line or expected empty result. | One permitted branch observation with complete provenance. |
| `MAP-B2-004` | `B2-MAN-004` | Observe the current `HEAD` SHA only. | Field 8 direct output for `REP-B2-004`. | Verify one 40-hexadecimal SHA and provenance. | One well-formed SHA captured under valid authorization. |
| `MAP-B2-005` | `B2-MAN-005` | Observe the existing local `origin/master` remote-tracking SHA without network access. | Field 8 direct output for `REP-B2-005`. | Verify one SHA, no fetch/network action, and provenance. | One well-formed local remote-tracking SHA. |
| `MAP-B2-006` | `B2-MAN-006` | Observe branch header and tracked working-tree status with untracked enumeration disabled. | Field 8 direct/redacted output for `REP-B2-006`. | Verify options, tracked-only scope, path handling, and provenance. | Bounded status output containing only permitted fields. |
| `MAP-B2-007` | `B2-MAN-007` | Observe one commit SHA, author name, author timestamp, and subject. | Field 8 direct/redacted output for `REP-B2-007`. | Verify four fields, redaction decisions, and absence of email/body. | Exactly four expected fields safely captured. |
| `MAP-B2-008` | `B2-MAN-008` | Observe kernel name, release, and architecture only. | Field 8 direct/redacted output for `REP-B2-008`. | Verify exactly three bounded metadata fields and provenance. | Expected three fields without host/user inventory. |
| `MAP-B2-009` | `B2-MAN-009` | Observe the exact physical working-directory identity. | Field 8 direct/redacted output for `REP-B2-009`. | Compare safely to approved path and review redaction. | Exact approved path observed without extra output. |
| `MAP-B2-010` | `B2-MAN-010` | Observe Docker client product/version/build text only. | Field 8 direct output for `REP-B2-010`. | Verify client-only output and absence of engine contact. | Bounded client version/build text only. |
| `MAP-B2-011` | `B2-MAN-011` | Observe exactly one Docker context name without inspection or engine contact. | Field 8 direct/redacted output for `REP-B2-011`. | Verify one name, Field 9 handling, no context detail, and no engine contact. | Exactly one approved-to-retain context name under resolved Fields 8 and 9. |
| `MAP-B2-013` | `B2-MAN-013` | Observe Windows Git product/version text only. | Field 8 direct output for `REP-B2-013`. | Verify exact executable provenance and absence of repository/configuration/credential interaction. | Bounded Windows Git version text only. |

### Proposed insufficiency, non-inference, and decision-use boundaries

For every mapping, missing, partial, conflicting, stale, outside-window, unverified, malformed, unexpected, or unsafe evidence is insufficient and `UNUSABLE` or `RERUN_REQUIRED` under Field 7 and proposed Field 8 controls.

| Mapping ID | Non-inference boundary | Allowed decision use | Prohibited decision use | Approval state |
| --- | --- | --- | --- | --- |
| `MAP-B2-001` | Git version does not establish repository readiness. | Inform a future bounded WSL Git version observation only. | Readiness, correctness, synchronization, or implementation authority. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-002` | Repository path identity does not establish correctness or validity. | Inform whether a future observation resolved to the approved path. | Repository correctness, cleanliness, permissions, or readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-003` | Branch name does not establish synchronization. | Inform a future branch-identity observation only. | Remote freshness, clean state, or code quality. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-004` | `HEAD` SHA does not establish clean state. | Inform a future commit-identity observation only. | Worktree cleanliness, correctness, quality, or readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-005` | Local `origin/master` does not establish remote freshness without separately authorized fetch. | Inform a future local remote-tracking identity observation only. | Remote synchronization, network reachability, or deployment readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-006` | Git status does not establish application readiness. | Inform a future bounded tracked-status observation only. | Functional, runtime, deployment, or production readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-007` | Commit metadata does not establish code quality. | Inform a future bounded commit-metadata observation only. | Authorship assurance, correctness, review quality, or readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-008` | Kernel metadata does not establish WSL functional readiness. | Inform a future bounded OS-identity observation only. | Compatibility, performance, service health, or runtime readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-009` | Working-directory identity does not establish permissions or validity. | Inform whether a future shell resolved to the approved path. | Access sufficiency, repository correctness, or readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-010` | Docker client version does not establish Docker engine readiness. | Inform a future Docker client-version observation only. | Engine availability, container capability, workload, or runtime readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-011` | Docker context name does not establish engine connectivity or correctness. | Inform a future selected-context-name observation only. | Engine reachability, context correctness, container state, or runtime readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |
| `MAP-B2-013` | Windows Git version does not establish credential or repository-operation readiness. | Inform a future Windows Git version observation only. | Credential availability, repository operations, synchronization, or readiness. | `APPROVED_AS_CRITERIA_MAPPING_PLANNING_CONTROL` |

No mapping, alone or combined, may establish overall Local Readiness, milestone establishment, M4, Platform Foundation, a formal EAIRA Execution Layer, implementation authority, runtime authority, deployment readiness, or production readiness.

### Mapping count and status

- Approved criteria-to-evidence planning mappings: 12.
- Mapping for deferred `B2-MAN-012`: none.

### Batch 8 selected initial Model A criteria-mapping overlay

All twelve historical criteria mappings remain intact. The selected initial Model A scope retains eleven mappings:

- `MAP-B2-001` through `MAP-B2-010`
- `MAP-B2-013`

`MAP-B2-011` is `NOT_INCLUDED_IN_SELECTED_INITIAL_ASSESSMENT_SCOPE`. Its historical inconsistency with `REP-B2-011` is not resolved by this synchronization and remains an unresolved historical or future-extension review matter.

Selected initial-scope criteria-mapping count: 11. Field 11 remains `APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES`.

### Current status

`APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES`

Field 11 remains blocking because the approved planning root is not created or usable and no assessment evidence exists. Approval of the mapping controls does not satisfy any criterion.

## 15. Mandatory Field 12 — All-Fields-Resolved Gate

### Gate rule

No future assessment-execution authorization decision may be made unless every mandatory field is explicitly classified as one of:

- `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER`;
- `NOT_APPLICABLE_APPROVED_BY_PROJECT_OWNER`.

The following states fail the gate:

- `BLOCKED_PENDING_PROJECT_OWNER_INPUT`;
- `BLOCKED_BY_FIELD_n`;
- `PARTIALLY_RESOLVED_WITH_BLOCKERS`;
- `PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING`;
- `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`;
- `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`;
- `APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES`;
- `APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES`;
- `PROPOSED_NOT_APPROVED`;
- `EVIDENCE_GAP`;
- `ASSUMPTION`;
- unresolved conflict, exception, ambiguity, or unlisted target.

### Current gate evaluation

`BLOCKED`

Blocking fields: 1, 2, 3, 4, 8, 9, 10, and 11.

Field 12 is resolved only as gate logic; it does not satisfy the gate.

## 16. Consolidated Project Owner Input Queue

The following requirements remain before any Field-state modification or assessment-authorization decision.

### Retained Model A requirements

1. Directly review this synchronized Annex and verify that the retained target, manifest, supporting-record, interaction, reproduction, and mapping overlays faithfully implement the adopted Batch 8 decision.
2. Objectively verify that every retained command-manifest and interaction requirement is addressed and satisfied without inferring executable availability, command semantics, environment readiness, or criterion satisfaction.
3. Resolve retained-scope evidence-use, redaction, reproduction, criteria-mapping, and Field 8 and Field 9 dependencies.
4. Obtain separate Project Owner approval before modifying any Field state.

### Excluded historical and future-extension matters

The following remain historical planning records but are not prerequisites for initial Model A documentary-scope completeness:

- `B2-MAN-011`
- `B2-MAN-012`
- `B2-BLK-002` through `B2-BLK-006`
- `B2-INT-005`
- `B2-INT-007` through `B2-INT-011`
- `REP-B2-011`
- `MAP-B2-011`

Their historical dispositions, gaps, and internal inconsistencies remain traceable and unresolved. They must not be silently deleted, rewritten, or treated as selected initial-scope requirements.

### Separate-extension requirements

Any future extension covering Docker Engine, Ollama, Hermes, OpenWebUI, or LM Studio must independently define and receive Project Owner approval for exact targets, commands and arguments, executables or process identities, working directories, endpoints, addresses, ports, service-contact and network boundaries, output restrictions, mutation-risk determinations, evidence classifications, Fields 8 and 9 controls, reproduction procedures, criteria mappings, stop conditions, review authority, and synchronization authority.

### Fields 8–11 dependencies

1. Resolve exact operating-system identities, local group names and memberships, UID/GID mapping, ACL entries and rights, inheritance and propagation behavior, deny policy, privilege or elevation requirements, rollback, and verified effective-access results while preserving the Batch 5 planning model and non-execution boundary.
2. Resolve encryption, disposal, final incident-notification, actual classification assignments, classification inheritance, exact encryption scope, plaintext locations and readers, administrator access, verifier decryption, backup, recovery, replica and export treatment, key governance, platform and application capabilities, technical and data-flow evidence, compliance and cryptographic requirements, and acceptance and verification criteria.
3. Preserve Batch 6 Options A–D as `REVIEWED_NOT_SELECTED`, all Annex encryption alternatives as `PROPOSED_NOT_APPROVED`, and Batch 7 Model B only as the documentary classification model.
4. Resolve Field 8 and Field 9 dependencies for the eleven selected-scope reproduction controls.
5. Resolve evidence dependencies for the eleven selected-scope criteria mappings.
6. Confirm through a later direct review and separate Project Owner decision that every mandatory Field classification, exception, conflict, and ambiguity satisfies the all-fields-resolved gate.

## 17. Stop Conditions

Annex planning must stop and return to the Project Owner if work would:

- execute, simulate, or trial any assessment activity;
- collect local-readiness evidence;
- inspect or exercise a local service, process, container, endpoint, runtime, model, API, database, credential, deployment, production resource, or unapproved environment;
- modify repository files outside this single Annex deliverable without separate authorization;
- modify runtime, configuration, service, database, deployment, production, governance, decision, Bootstrap, validation, or status state;
- expose or infer sensitive information;
- leave a mandatory field ambiguously classified;
- imply milestone, implementation, conditional execution, or assessment authority.

No remediation or corrective action is authorized after a stop condition is reached.

## 18. Current Annex Decision Readiness

| Question | Current answer |
| --- | --- |
| Are all twelve mandatory fields addressed? | Yes, as planning fields. |
| Are all execution-controlling fields resolved and approved? | No. |
| Is the all-fields-resolved gate satisfied? | No — `BLOCKED`. |
| Is Batch 7 accepted as planning evidence? | Yes, as bounded non-executable planning evidence only. |
| Is the Batch 7 documentary classification model selected? | Yes — Batch 7 Model B is `SELECTED_AS_DOCUMENTARY_CLASSIFICATION_MODEL_ONLY`; Batch 7 Model A is `REVIEWED_NOT_SELECTED`. |
| Is Batch 8 accepted as planning evidence? | Yes — `APPROVED_AS_PLANNING_EVIDENCE` without execution authority. |
| Is an initial documentary assessment-scope model selected? | Yes — Batch 8 Model A is `SELECTED_AS_INITIAL_DOCUMENTARY_SCOPE_MODEL`; Batch 8 Models B and C are `REVIEWED_NOT_SELECTED`. |
| Is the initial Model A documentary inventory complete and closed? | Yes, only as `DOCUMENTARY_INITIAL_SCOPE_COMPLETENESS_DETERMINATION_ONLY`; no Field, criterion, gate, execution, or evidence authority follows. |
| Is any actual data or evidence classified? | No. |
| Is any encryption scope, option, or Annex alternative selected? | No. |
| Assessment execution | `UNAUTHORIZED` |
| Assessment-evidence collection | `UNAUTHORIZED` |
| Command execution | `UNAUTHORIZED` |
| Connectivity testing | `UNAUTHORIZED` |
| Port probing | `UNAUTHORIZED` |
| Evidence-directory creation | `UNAUTHORIZED` |
| Evidence-file creation | `UNAUTHORIZED` |
| Access-control configuration | `UNAUTHORIZED` |
| Encryption configuration | `UNAUTHORIZED` |
| Hash calculation | `UNAUTHORIZED` |
| Redaction activity | `UNAUTHORIZED` |
| Evidence retention activity | `UNAUTHORIZED` |
| Evidence disposal activity | `UNAUTHORIZED` |
| New milestone established | `NO` |
| Implementation or runtime work authorized | `NO` |
| Is this Annex ready for an execution-authorization decision? | No; Project Owner inputs are required. |

## 19. Future Review Requirement

After the mandatory inputs are supplied and every field is explicitly resolved, this Annex must undergo direct file review and independent repository verification, including exact Git status, exact Git diff, and direct reading of the finalized Annex. For any future Field-state modification, direct review of this synchronized Annex, objective verification that every retained requirement is addressed and satisfied, and separate Project Owner approval are required. That review must not reopen or unselect the initial Model A documentary scope.

The Project Owner must then conduct a separate review and record an unconditional decision. Annex completion, acceptance, silence, conditional language, or approval with unresolved revisions is insufficient to authorize any assessment command, observation, interaction, or evidence collection.

## 20. Source Paths

- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_4_REVIEW_DECISION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_5_REVIEW_DECISION.md`
- `docs/project/planning/BATCH_6_ENCRYPTION_OPTION_LEVEL_PLANNING_PACKAGE.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_6_REVIEW_DECISION.md`
- `docs/project/planning/BATCH_7_DATA_EVIDENCE_CLASSIFICATION_AND_ENCRYPTION_SCOPE_PLANNING_PACKAGE.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_7_REVIEW_DECISION.md`
- `docs/project/planning/BATCH_8_ASSESSMENT_SCOPE_MINIMIZATION_AND_COMMAND_MANIFEST_CLOSURE_PLANNING_PACKAGE.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_8_REVIEW_DECISION.md`
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_001.md`
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md`
- `docs/project/status/CURRENT_STATUS.md`
- `docs/project/status/TODAY_OBJECTIVE.md`
- `docs/project/status/ACTIVE_TASK.yaml`
- `docs/project/context/CURRENT_CONTEXT.md`

## 21. Boundary

This Annex records bounded Project Layer planning only. It does not authorize or perform the Local Readiness Assessment, collect assessment evidence, establish a milestone, establish M4, approve implementation, authorize runtime work, establish Platform Foundation, establish a formal EAIRA Execution Layer, modify governance, authorize deployment, or permit production change.
