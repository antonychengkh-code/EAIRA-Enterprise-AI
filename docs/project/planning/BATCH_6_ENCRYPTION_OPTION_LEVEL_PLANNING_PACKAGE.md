# Batch 6 Encryption Option-Level Planning Package

## 1. Document Control

| Field | Value |
| --- | --- |
| Document title | Batch 6 Encryption Option-Level Planning Package |
| Document type | Project Layer option-level planning package |
| Proposed path | `docs/project/planning/BATCH_6_ENCRYPTION_OPTION_LEVEL_PLANNING_PACKAGE.md` |
| Final status | `READY_FOR_PROJECT_OWNER_OPTION_REVIEW` |
| Planning qualifier | `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS` |
| Controlling encryption state | `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT` |
| Execution marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Related planning task | `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` |
| Related Annex field | Mandatory Field 8 — Evidence Handling and Integrity |
| Decision authority | Project Owner |
| Proposed version | `0.1.0` |
| Date | 2026-07-15 |
| Repository artifact state | Created through separate Project Owner-authorized repository mutation; committed and synchronized. This state does not constitute encryption-option approval or execution authority. |
| Inspection | Not authorized or performed |
| Configuration | Not authorized or performed |
| Implementation | Not authorized or performed |
| Repository-write history | Initial file creation was separately authorized by the Project Owner and completed. Any future modification still requires separate explicit Project Owner authorization. |

The initial repository creation of this planning package was separately authorized and completed. That repository action did not select an encryption option, approve an Annex alternative, resolve Field 8, or authorize implementation or execution. Any future modification requires a separate explicit Project Owner authorization identifying the exact path and permitted mutation.

### Status meaning

`READY_FOR_PROJECT_OWNER_OPTION_REVIEW` means ready only for review of:

- abstract architecture and custody categories;
- existing Annex alternatives and their boundaries;
- planning criteria;
- risks and trade-offs;
- evidence gaps;
- decisions required before selection.

It does not mean:

- ready for option or Annex-alternative selection;
- ready for product or vendor selection;
- ready for key-ownership approval;
- ready for architecture approval;
- ready for implementation planning;
- ready for inspection or configuration.

`OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS` is a planning qualifier and does not replace the final status.

## 2. Purpose

Prepare an abstract encryption option-level planning package for Project Owner consideration.

The package:

- documents Batch 6 Options A, B, C and D;
- records the existing Annex encryption alternatives without changing their states;
- identifies conceptual relationships without establishing equivalence;
- identifies evidence and decisions required before selection could be considered.

It does not select or prefer any Batch 6 category or Annex alternative. It does not establish that any encryption capability exists, is suitable, has been approved, or has been enabled.

## 3. Scope

This package covers abstract planning criteria for:

- encryption at rest;
- encryption in transit;
- application-level encryption;
- key ownership and custody;
- key lifecycle and rotation;
- backup and recovery;
- auditability;
- operational responsibility;
- governance implications;
- risks, limitations, trade-offs and failure modes.

The immediate documented concern is the unresolved encryption mechanism associated with Authorization Annex Mandatory Field 8.

The controlling state remains:

`ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT`

This package does not expand the Field 8 concern into an approved enterprise-wide encryption architecture.

## 4. Explicit Exclusions

This package excludes:

- repository mutation;
- repository working-tree inspection;
- runtime, host, container, service, database, cloud or deployment inspection;
- discovery or verification of platform capabilities;
- secret-store, certificate-store or key-store access;
- data classification activity;
- generation, storage, access, import, export, escrow, rotation or destruction of keys;
- selection of an algorithm, product, vendor, architecture, key owner or custodian;
- encryption configuration or enablement;
- deployable configuration values;
- production or assessment commands;
- data migration or re-encryption;
- backup or restore execution;
- assessment execution or evidence collection;
- evidence-directory or evidence-file creation;
- implementation planning;
- architecture approval;
- resolution of Field 8;
- modification of approved decisions;
- claims that encryption has been enabled, configured, validated, verified or selected.

## 5. Source Evidence and Claim Traceability

Only evidence already verified during the immediately preceding read-only documentary verification is used.

### 5.1 `VERIFIED SOURCE EVIDENCE`

| Claim ID | Repository file and exact location | Source wording or value | Constraint on Batch 6 |
| --- | --- | --- | --- |
| `VSE-01` | `docs/project/status/CURRENT_STATUS.md` — `Active Phase` | Complete verified value: “Bounded Project Layer planning under activated task `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` to resolve or explicitly retain the remaining mandatory Authorization Annex blockers.” | Batch 6 must remain bounded Project Layer planning and cannot become implementation or execution work. |
| `VSE-02` | Same — `Current Decision` | `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`; `AUTHORIZE_BOUNDED_ASSESSMENT` was not granted; `AUTHORIZE_WITH_REQUIRED_REVISIONS` was not granted as conditional execution authority. | Encryption planning cannot be treated as assessment or conditional execution authority. |
| `VSE-03` | Same — `Current Decision` | Field 8: `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`; Field 9: `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`; gate: `BLOCKED`. | This package cannot claim to resolve Field 8 or make the Annex execution-ready. |
| `VSE-04` | Same — `Blockers` | Blocking fields remain `1, 2, 3, 4, 8, 9, 10, and 11`; unresolved planning inputs include `encryption and disposal mechanisms`. | Encryption and disposal must remain unresolved. |
| `VSE-05` | Same — `Current Milestone` | `Current/New Milestone: None established.` | Batch 6 cannot imply milestone establishment. |
| `VSE-06` | `docs/project/status/TODAY_OBJECTIVE.md` — `Out of Scope` | `FAITHFUL SOURCE SUMMARY`: The `Out of Scope` section states that evidence-directory or evidence-file creation; ACL, identity, group, access, or encryption configuration; implementation; runtime execution; and deployment are not authorized. | No encryption configuration, implementation, deployment or runtime action may be included. These excerpts are not presented as the complete source sentence. |
| `VSE-07` | Same — `Success Criteria` | “does not invent identities, groups, users, ACL entries, permissions, commands, mechanisms, owners, priorities, or deadlines.” | Batch 6 must not invent key identities, mechanisms, owners or deadlines. Avoiding invented products and custodians is a bounded application of this constraint. |
| `VSE-08` | `docs/project/status/ACTIVE_TASK.yaml` — YAML key `Status` | `AUTHORIZED_FOR_AUTHORIZATION_PACKAGE_PREPARATION` | Active status supports planning preparation only. |
| `VSE-09` | Same — YAML key `Execution Marker` | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` | Every Batch 6 category and Annex alternative remains non-executable. |
| `VSE-10` | Same — YAML key `Assessment Evidence Collection` | `Unauthorized` | No newly collected assessment evidence may support option selection. |
| `VSE-11` | Same — YAML key `Overall Annex State` | `Not finalized; mandatory execution-controlling fields remain unresolved; all-fields-resolved gate is BLOCKED` | Abstract review remains separate from Annex finalization. |
| `VSE-12` | Same — YAML key `Field 8 State` | `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS` | Batch 6 does not resolve Field 8. |
| `VSE-13` | `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md` — `6. Explicit Out-of-Scope Boundaries` | `FAITHFUL SOURCE SUMMARY`: the section prohibits Local Readiness Assessment execution, command execution, assessment-evidence collection, evidence creation, inspection of listed local resources, encryption configuration, implementation, runtime mutation and deployment. | Batch 6 must remain documentary and non-executable. This is explicitly a summary of multiple source bullets, not a complete exact quotation. |
| `VSE-14` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` — `18. Current Annex Decision Readiness` | Gate: `No — BLOCKED`; Encryption configuration: `UNAUTHORIZED`; Implementation or runtime work authorized: `NO`. | Option review cannot be represented as configuration, implementation or execution readiness. |

### 5.2 `EXISTING APPROVED DECISION`

| Claim ID | Repository file and exact location | Exact recorded decision or value | Constraint on Batch 6 |
| --- | --- | --- | --- |
| `EAD-01` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md` — `1. Decision Identification`; `2. Decision` | `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`; `AUTHORIZE_BOUNDED_ASSESSMENT` not granted. | No encryption option may be selected or treated as executable. |
| `EAD-02` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_4_REVIEW_DECISION.md` — `1. Document Metadata`; `2. Decision`; `4. Blocked or Deferred Inputs` | `APPROVE_BATCH_4_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`; `encryption mechanism` remains blocked. | Batch 6 may prepare options but cannot record a selected or approved mechanism. |
| `EAD-03` | Same — `3.1 Evidence root planning input` | Windows: `C:\EAIRA\Evidence`; WSL: `/mnt/c/EAIRA/Evidence`; planning inputs only. | Any evidence-root discussion must not assert path existence, usability, creation authority or encryption coverage. |
| `EAD-04` | Same — `3.2 Access-control planning approach` | `Combined Windows host control with WSL access`; exact identities, ACLs, mappings and enforcement remain unresolved. | Any future encryption design would need to preserve or separately resolve this boundary. This is a bounded interpretation, not a new decision. |
| `EAD-05` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_5_REVIEW_DECISION.md` — `3.1 Default model`; `3.2 Exception model`; `3.3 Rejected model` | `Separate local groups` is the default; hybrid individual-user plus group control requires separate approval; single-user procedural separation is rejected. | Any OS-enforced future key-custody model must preserve these boundaries or obtain a separate decision. |
| `EAD-06` | Same — `4. Multiple-Role Membership Dispositions` | `Multiple role memberships permitted only with approved separation controls`; membership without additional separation is rejected. | Proposed key roles cannot be combined without approved separation controls. |
| `EAD-07` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` — parent heading `Batch 4 Evidence Implementation-Detail Planning Inputs`; subheading `Field 8 approved closed role-to-permission matrix` | The matrix separates operator evidence writes, verifier disposition writes, Project Owner reading and Stop Authority default metadata access. | Future key-use permissions must not silently expand approved evidence access or write authority. Section 11 separately cross-references the approved matrix in its evidence-control register. |
| `EAD-08` | Same — `11. Mandatory Field 8 — Evidence Handling and Integrity`; `Approved integrity planning input` | `SHA-256`; `APPROVED_AS_INTEGRITY_PLANNING_INPUT_NOT_EXECUTABLE`; no hash calculation authorized. | SHA-256 is not an approved encryption mechanism. |
| `EAD-09` | Same — Section 11; `Approved retention planning input` | `FIXED_30_DAY_RETENTION_AFTER_FINAL_VERIFIER_DISPOSITION`; disposal after 30 calendar days requires Project Owner or delegated Stop Authority approval; extension requires a new decision. | Future key-version retention and destruction cannot make authorized retained evidence unrecoverable before applicable retention and disposal decisions. |
| `EAD-10` | Same — Section 11; `Retained Field 8 blockers` | `Encryption mechanism`; `Exact disposal command or physical deletion method`; `Final incident-notification channel and configuration`. | Batch 6 cannot claim that encryption, disposal or notification has been resolved. |

### 5.3 Existing Annex encryption alternatives and key-storage constraint

`EAD-11 — VERIFIED SOURCE EVIDENCE / EXACT ANNEX CONSTRAINT`

| Field | Verified value |
| --- | --- |
| Source | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` |
| Heading | `Field 8 proposed encryption alternatives` |
| Controlling state | `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT` |
| Alternative | `BitLocker-backed host-volume protection` — `PROPOSED_NOT_APPROVED` |
| Alternative | `Encrypted evidence archive` — `PROPOSED_NOT_APPROVED` |
| Alternative | `Application-level encryption` — `PROPOSED_NOT_APPROVED` |
| Alternative | `No separate encryption beyond approved host-volume control` — `PROPOSED_NOT_APPROVED` |
| Exact controlling constraint | `No encryption mechanism is assumed enabled.` |

The Annex also records the following exact restriction:

> Encryption keys must not be stored in the evidence root, Git repository, Annex files, or environment variables captured as evidence.

This package preserves that restriction without expanding it. It proposes no alternative key-storage location.

Although the identifier is `EAD-11`, the four alternatives remain proposed and unapproved. The mapping does not reclassify them as approved decisions.

## 6. Existing Decision Boundary

The controlling constraints are mapped in `EAD-01` through `EAD-11`.

The authoritative decisions remain in:

- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_4_REVIEW_DECISION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_5_REVIEW_DECISION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md`

This package does not reinterpret or modify them.

If an option would require changing an existing decision, the issue must be classified as `POTENTIAL_DECISION_CONFLICT` and returned to the Project Owner.

## 7. Evidence Gaps

### 7.1 Data and scope

`EVIDENCE GAP`

- Exact artifact classes requiring encryption.
- Approved data classification.
- Whether different evidence artifact classes require different confidentiality controls.
- Whether encryption would apply to temporary locations, backups, exports or replicas.
- Acceptable plaintext exposure boundaries.
- Whether encryption in transit applies to any approved data path.

### 7.2 Architecture and platform

`EVIDENCE GAP`

- Actual storage and filesystem technology.
- Actual Windows-to-WSL data path and enforcement behavior.
- Hosting, database, object-storage or managed-platform capabilities.
- Supported platform encryption boundary.
- Supported customer-managed-key integration.
- Application or service boundary capable of encryption.
- Backup and restore architecture.
- Approved endpoints and network boundaries.
- Vendor, licensing, regional and portability constraints.

### 7.3 Key governance

`EVIDENCE GAP`

- Accountable key owner.
- Key custodian.
- Key administrator.
- Service identities permitted to use a key.
- Recovery and emergency authorities.
- Separation between key administration and protected-data access.
- Key backup or escrow policy.
- Rotation interval and triggers.
- Revocation, compromise and destruction procedures.

### 7.4 Assurance

`EVIDENCE GAP`

- Applicable compliance or regulatory requirements.
- Approved cryptographic standards.
- Required algorithm, mode, key size or cryptographic module.
- Audit-log capability and authoritative log source.
- Availability and recovery requirements.
- Future acceptance and verification criteria.
- Acceptable vendor dependency and exit conditions.

Option selection remains blocked because these gaps affect scope, capability, custody, recovery and assurance.

## 8. Encryption Planning Principles

`RECOMMENDATION — conditional and for Project Owner consideration only`

Subject to approved data classification, verified platform capability, and approved key ownership and recovery authority, future option assessment could consider:

1. Encryption as a supplement to—not an implicit replacement for—the boundaries mapped in `EAD-04` through `EAD-07`.
2. Separation of key administration, protected-data access, recovery approval and audit review.
3. Explicit boundaries for stored data, transmitted data, application plaintext, backups, exports and replicas.
4. Minimization of plaintext persistence, subject to verified workflow requirements.
5. Recovery feasibility before activation or destruction.
6. Auditability without logging key material or protected plaintext.
7. Coordination of rotation, retention and disposal subject to `EAD-09`.
8. Portability and vendor-exit criteria.
9. Separate treatment of integrity and confidentiality.
10. Preservation of the key-storage restriction in `EAD-11`.
11. No architecture preference until material evidence gaps are resolved.

## 9. Data and System Boundary Assumptions

`ASSUMPTION`

- A future separately authorized process may require confidentiality protection for some safely retainable evidence.
- More than one technical layer may be available for encryption.
- Encryption and access control may require coordinated planning.

The following remain `EVIDENCE GAP`:

- whether evidence passes between Windows and WSL;
- whether backups or recovery copies exist;
- whether multiple data sensitivity levels will be approved;
- whether any platform offers suitable encryption;
- whether an application can safely perform encryption;
- whether key-administration roles can be separated;
- whether an approved key-management service exists.

## 10. Option A — Platform-managed Encryption

`OPTION — unselected and unapproved`

| Planning dimension | Abstract definition |
| --- | --- |
| Intended use | Baseline encryption supplied by a hosting, storage, database or managed platform, subject to verified capability. |
| Scope boundary | Only data and paths within the verified platform boundary. |
| Prerequisites | Approved classification, verified capability, approved service boundary, backup coverage and assurance evidence. |
| Key ownership | Provider-owned or provider-controlled only if documented and accepted. |
| Custody responsibility | Provider custody with separately defined EAIRA governance responsibilities. |
| Operational complexity | Potentially lower, but not verified. |
| Auditability | Dependent on verified provider logs and tenant-visible events. |
| Recovery considerations | Dependent on provider recovery, account access and backup coverage. |
| Rotation considerations | Provider-controlled or configurable only if supported and approved. |
| Vendor dependency | Potentially high. |
| Governance impact | Requires acceptance of provider custody and shared responsibility. |
| Security benefits | May provide broad baseline storage protection. |
| Limitations | May limit direct control over custody, rotation, algorithms or privileged access. |
| Failure modes | Account loss, provider outage, incomplete coverage, unsupported export or inaccessible logs. |
| Evidence gaps | Platform, scope, custody, backup, audit, recovery, portability and cost. |
| Decisions required | Whether provider custody is acceptable and what assurance is required. |

No preference for Option A is expressed.

## 11. Option B — Customer-managed Keys

`OPTION — unselected and unapproved`

| Planning dimension | Abstract definition |
| --- | --- |
| Intended use | Platform-integrated encryption where EAIRA or a designated authority controls key policy. |
| Scope boundary | Only resources verifiably bound to the customer-managed key. |
| Prerequisites | Approved classification, verified integration, approved key-management capability, custody and recovery decisions. |
| Key ownership | EAIRA or an explicitly designated accountable authority, subject to approval. |
| Custody responsibility | Approved custodians or managed service under approved policy. |
| Operational complexity | Potentially medium to high. |
| Auditability | Potentially strong if key-use and administrative events are attributable. |
| Recovery considerations | Key loss or policy lockout may make data unavailable. |
| Rotation considerations | Requires verified versioning, re-encryption and historical-key behavior. |
| Vendor dependency | Depends on platform and key-management integration. |
| Governance impact | Requires ownership, custody, privileged-access separation and recovery authority. |
| Security benefits | May provide stronger lifecycle and revocation control. |
| Limitations | Increased operational burden and customer-caused data-loss risk. |
| Failure modes | Key deletion, lockout, region loss, failed rotation or incomplete binding. |
| Evidence gaps | Key service, administrators, recovery, integration, cost and staffing. |
| Decisions required | Owner, custodian, recovery authority and separation controls. |

No preference for Option B is expressed.

## 12. Option C — Application-level Encryption

`OPTION — unselected and unapproved`

| Planning dimension | Abstract definition |
| --- | --- |
| Intended use | Encryption of selected fields, payloads or artifacts inside an approved application boundary. |
| Scope boundary | Only explicitly selected data and application paths. |
| Prerequisites | Approved classification, verified application boundary, approved key access, design review and recovery design. |
| Key ownership | EAIRA or an approved application-security authority. |
| Custody responsibility | Approved key-management component and service identities. |
| Operational complexity | Potentially high. |
| Auditability | Potentially granular if decrypt and key-use events are safely recorded. |
| Recovery considerations | Requires compatible application behavior, key versions and metadata. |
| Rotation considerations | Requires an approved versioning and possible re-encryption strategy. |
| Vendor dependency | May reduce storage dependency while increasing application dependency. |
| Governance impact | Requires field-level classification and change governance. |
| Security benefits | May protect selected data beyond the storage layer. |
| Limitations | Does not automatically protect metadata, memory, logs or derivatives. |
| Failure modes | Key loss, metadata loss, plaintext logging, incompatible versions or partial migration. |
| Evidence gaps | Fields, architecture, query requirements, identities and migration constraints. |
| Decisions required | Protected fields, application boundary, custody, recovery and audit requirements. |

`POTENTIAL_DECISION_CONFLICT`

Using application-level encryption or access control to replace rather than supplement `EAD-04` through `EAD-07` could conflict with existing access-control planning boundaries.

No preference for Option C is expressed.

## 13. Option D — Hybrid Encryption Model

`OPTION — unselected and unapproved`

| Planning dimension | Abstract definition |
| --- | --- |
| Intended use | Combination of platform-managed, customer-managed and application-level protection. |
| Scope boundary | Multiple explicitly mapped layers. |
| Prerequisites | Approved classification, verified capabilities, ownership matrix and coordinated recovery design. |
| Key ownership | May differ by layer but must be explicit and approved. |
| Custody responsibility | Potentially divided among provider, EAIRA custodians and application identities. |
| Operational complexity | Potentially highest. |
| Auditability | May be broad if events can be correlated. |
| Recovery considerations | Each required layer and key version must be recoverable in the correct order. |
| Rotation considerations | Independent rotations may create compatibility or outage risk. |
| Vendor dependency | Mixed and architecture-dependent. |
| Governance impact | Requires explicit responsibility at every layer. |
| Security benefits | May provide differentiated layered protection. |
| Limitations | Complexity, cost, overhead and recovery difficulty. |
| Failure modes | Layer mismatch, incomplete coverage, incompatible rotation, orphaned keys or unclear ownership. |
| Evidence gaps | Classification, architecture, overlap, performance, logging and staffing. |
| Decisions required | Whether layered protection is justified and who owns each layer. |

`POTENTIAL_DECISION_CONFLICT`

A hybrid model that expands evidence access beyond `EAD-06` or `EAD-07` could conflict with existing separation controls.

No preference for Option D is expressed.

## 14. Relationship to Existing Annex Encryption Alternatives

`NON-SELECTIVE CONCEPTUAL CROSSWALK`

The Batch 6 A–D categories are abstract architecture and custody planning categories.

The Annex alternatives are existing concrete planning alternatives for Field 8.

Batch 6 does not replace, rename, supersede, approve or reject any Annex alternative. No one-to-one equivalence is assumed.

All Annex alternatives remain:

`PROPOSED_NOT_APPROVED`

The controlling state remains:

`ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT`

| Existing Annex alternative | Potentially related Batch 6 category | Boundary |
| --- | --- | --- |
| BitLocker-backed host-volume protection | Option A and possibly Option B | Classification depends on actual key ownership and platform control; neither is verified. |
| Encrypted evidence archive | Option A, B, C or D | Classification depends on where encryption occurs and who controls the keys. |
| Application-level encryption | Option C and possibly Option D | Direct conceptual overlap exists, but no approval, equivalence or implementation inference is allowed. |
| No separate encryption beyond approved host-volume control | Potentially Option A or a separately retained minimal-control alternative | Must not be treated as equivalent to Option A without Project Owner interpretation and verified host-volume control. |

The crosswalk does not rank, prefer, consolidate or eliminate any category or alternative.

## 15. Comparative Evaluation Matrix

These are qualitative planning comparisons, not verified facts or selection scores.

| Criterion | A: Platform-managed | B: Customer-managed keys | C: Application-level | D: Hybrid |
| --- | --- | --- | --- | --- |
| Relative operational complexity | Potentially lower | Potentially medium–high | Potentially high | Potentially highest |
| Direct EAIRA key control | Potentially low | Potentially high | Potentially high | Varies |
| Provider dependency | Potentially high | Medium–high | Potentially lower for storage | Mixed |
| Field-level protection | Usually limited | Usually limited | Potentially strong | Potentially strong |
| Custom implementation risk | Potentially lower | Medium | Potentially high | Potentially high |
| Recovery complexity | Provider-dependent | High customer responsibility | Application-dependent | Cross-layer |
| Audit potential | Provider-dependent | Potentially strong | Potentially granular | Potentially broad but fragmented |
| Portability | Potentially limited | Integration-dependent | Application-dependent | Mixed |
| Current evidence sufficiency | Insufficient | Insufficient | Insufficient | Insufficient |

No preferred category is identified.

## 16. Key Ownership and Custody Models

All models remain abstract and unapproved.

- Provider ownership and custody.
- EAIRA ownership with managed custody.
- EAIRA ownership and direct custody.
- Split or dual-control custody.

`RECOMMENDATION — conditional and for Project Owner consideration only`

Subject to approved key ownership and recovery authority, future planning could distinguish:

- accountable key owner;
- key custodian;
- key administrator;
- service identity permitted to use a key;
- protected-data reader;
- recovery authority;
- audit reviewer;
- destruction approver.

No person, account, group, service, product or key-storage location is proposed.

## 17. Key Lifecycle and Rotation Planning

`RECOMMENDATION — conditional and for Project Owner consideration only`

Subject to an approved option, ownership model, recovery authority and verified capability, a future lifecycle package could address:

1. Generation.
2. Registration and purpose.
3. Distribution or service binding.
4. Activation.
5. Permitted use.
6. Rotation.
7. Historical-key retention.
8. Suspension or revocation.
9. Recovery.
10. Destruction.
11. Post-destruction evidence requirements.

`PROJECT OWNER DECISION REQUIRED`

- Rotation policy model.
- Versioning or re-encryption behavior.
- Historical-version retention.
- Emergency rotation triggers.
- Request, approval and verification authority.
- Partial-rotation handling.
- Backup handling.
- Acceptable recovery and outage conditions.

`EVIDENCE GAP`

No rotation interval, cryptoperiod, re-encryption method or emergency rotation authority is approved.

## 18. Backup, Recovery, and Loss Scenarios

| Scenario | Conditional planning consideration |
| --- | --- |
| Primary key unavailable | Define recovery only under an approved recovery model. |
| Key permanently lost | Determine whether permanent data loss is acceptable. |
| Key compromised | Decide revocation and replacement only under approved incident authority. |
| Backup restored | Confirm required key versions and metadata remain available. |
| Ciphertext restored without metadata | Treat recoverability as unresolved. |
| Provider account lost | Determine an approved account-recovery boundary. |
| Partial rotation | Preserve prior keys until authorized retained data remains recoverable. |
| Application rollback | Determine compatibility with protected data and key versions. |
| Retention expiry | Coordinate disposal and key dependencies with `EAD-09`. |
| Stopped assessment | Preserve existing Annex controls; no evidence activity is authorized here. |

No key operation is proposed or authorized.

## 19. Auditability and Evidence Requirements

`RECOMMENDATION — conditional and for Project Owner consideration only`

Subject to verified capability and an approved option, future audit requirements could consider:

- key creation or registration;
- policy changes;
- administrator or custodian changes;
- enable, disable, revoke and destroy actions;
- rotation and version changes;
- service binding;
- permitted and denied key use;
- recovery or escrow access;
- backup or restore dependencies;
- incident and exception approvals.

`EVIDENCE GAP`

No encryption audit capability, log source, event schema or encryption-specific log-retention policy has been verified or approved.

## 20. Governance and Responsibility Boundaries

| Responsibility | Current state |
| --- | --- |
| Abstract option review | Supported by this response-only package |
| Option selection | Blocked |
| Annex-alternative selection | Blocked |
| Data classification approval | Project Owner decision required |
| Key ownership | Project Owner decision required |
| Custody model | Project Owner decision required |
| Architecture approval | Not ready or authorized |
| Product or vendor selection | Not ready or authorized |
| Key administration | Unassigned |
| Recovery authority | Unassigned |
| Emergency rotation authority | Unassigned |
| Implementation planning | Not ready or authorized |
| Repository write | Requires separate explicit Project Owner authorization |

## 21. Risks and Trade-offs

| Risk | Relevant categories | Conditional planning treatment |
| --- | --- | --- |
| False assurance from broad encryption claims | All | Require verified boundaries. |
| Key loss causes permanent data loss | B, C, D | Require an approved recovery model. |
| Provider lock-in | A, B, D | Define portability and exit criteria. |
| Custom cryptographic defect | C, D | Require separately authorized expert review. |
| Privileged plaintext access | A, B | Reconsider only after classification. |
| Metadata exposure | C, D | Classify metadata separately. |
| Rotation outage | B, C, D | Define versioning and partial-failure handling. |
| Backup not covered | All | Map backup paths before selection. |
| Audit fragmentation | D | Define authoritative log sources. |
| Access-control bypass | All | Preserve `EAD-04` through `EAD-07`. |
| Premature key destruction | B, C, D | Preserve `EAD-09`. |
| Parallel taxonomies misunderstood | All | Preserve Section 14’s non-selective crosswalk. |
| Planning treated as authority | All | Preserve all non-execution boundaries. |

## 22. Project Owner Decisions Required

Before selection can be considered, the Project Owner would need to decide or authorize resolution of:

1. Exact encryption planning scope.
2. Whether scope is limited to future assessment evidence.
3. Data-classification planning authority.
4. Required platform or application documentary evidence.
5. Acceptable key-ownership models.
6. Acceptable custody and recovery models.
7. Required separation controls.
8. Backup, recovery and escrow requirements.
9. Auditability and assurance requirements.
10. Portability and vendor-exit requirements.
11. Interpretation of relationships between Batch 6 categories and existing Annex alternatives.
12. Disposition of the `POTENTIAL_DECISION_CONFLICT` records.
13. Whether a narrower documentary evidence package may be prepared.
14. Whether a future documentary evidence package or further modification of this planning package should be separately authorized, including the exact permitted path and mutation scope.

This section does not request selection under the current evidence state.

## 23. Recommended Next Planning Action

`RECOMMENDATION — conditional and for Project Owner consideration only`

Subject to Project Owner approval, a future bounded documentary evidence request could address:

- encryption scope;
- data classifications;
- platform capability documentation;
- application-boundary documentation;
- key ownership and custody alternatives;
- backup and recovery requirements;
- audit and assurance requirements;
- portability and operational constraints.

It should not include inspection, commands, configuration, validation, evidence collection or key operations unless separately authorized.

No category or Annex alternative is preferred.

## 24. Authorization and Review-Readiness Boundary

This package:

- documents Batch 6 Options A, B, C and D;
- documents all four existing Annex encryption alternatives;
- leaves every Batch 6 category unapproved;
- leaves every Annex alternative `PROPOSED_NOT_APPROVED`;
- preserves `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT`;
- preserves `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS`;
- preserves the verified key-storage prohibition;
- does not select a mechanism;
- does not assume a mechanism is enabled;
- does not approve a product, vendor, algorithm, architecture, owner or custodian;
- does not resolve Field 8;
- does not satisfy the all-fields-resolved gate;
- does not authorize implementation planning;
- does not authorize inspection, configuration, deployment or runtime mutation;
- does not establish a milestone;
- does not modify an approved decision.

Creation of this file was completed through a separate explicit Project Owner repository-write authorization.

That completed repository mutation does not constitute option selection, Annex-alternative approval, Field 8 resolution, architecture approval, implementation authority, or execution authority.

Any future modification of this file requires a separate explicit Project Owner authorization identifying the exact path and permitted mutation.

Final status:

`READY_FOR_PROJECT_OWNER_OPTION_REVIEW`

Planning qualifier:

`OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS`

Repository-write readiness recommendation:

`READY_FOR_PROJECT_OWNER_REPOSITORY_WRITE_DECISION`

This recommendation means the corrected response-only document may be presented for a future Project Owner repository-write decision. It is not repository-write authorization.
