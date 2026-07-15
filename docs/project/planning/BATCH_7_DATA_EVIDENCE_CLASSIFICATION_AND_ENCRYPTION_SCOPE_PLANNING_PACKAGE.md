# Batch 7 Data/Evidence Classification and Encryption Scope Planning Package

## 1. Document Control

| Field | Value |
| --- | --- |
| Document title | Batch 7 Data/Evidence Classification and Encryption Scope Planning Package |
| Document type | Project Layer documentary planning package |
| Proposed path | `docs/project/planning/BATCH_7_DATA_EVIDENCE_CLASSIFICATION_AND_ENCRYPTION_SCOPE_PLANNING_PACKAGE.md` |
| Batch designation | `BATCH_7_DATA_EVIDENCE_CLASSIFICATION_AND_ENCRYPTION_SCOPE_PLANNING` |
| Final status | `READY_FOR_PROJECT_OWNER_CLASSIFICATION_SCOPE_REVIEW` |
| Review-readiness meaning | Ready only for review of abstract classification models, artifact classes, scope boundaries and decision criteria |
| Execution marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Related planning task | `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` |
| Related Annex fields | Mandatory Field 8 and Mandatory Field 9 |
| Decision authority | Project Owner |
| Proposed version | `0.2.0` |
| Date | 2026-07-15 |
| Repository artifact state | Created as a Project Layer documentary planning artifact; pending separate Project Owner review and approval as planning evidence |
| Actual data classification | Not authorized or performed |
| Environment inspection | Not authorized or performed |
| Evidence collection | Not authorized or performed |
| Classification-model selection | Not authorized or performed |
| Encryption-option selection | Not authorized or performed |
| Implementation planning | Not authorized or performed |

`READY_FOR_PROJECT_OWNER_CLASSIFICATION_SCOPE_REVIEW` means ready only to review abstract classification models, scope boundaries and planning criteria.

It does not mean ready to:

- select a classification model;
- approve a classification category;
- classify actual data or evidence;
- inspect an environment or data path;
- select a Batch 6 option;
- approve an Annex alternative;
- approve a product, vendor, algorithm or architecture;
- approve a key owner or custodian;
- configure encryption;
- begin implementation planning;
- execute an assessment;
- collect evidence;
- perform runtime or deployment activity.

Initial repository creation of this package was separately authorized and completed. That creation does not approve a classification model, classify actual data, approve Batch 7 as planning evidence, select an encryption option, or grant implementation or execution authority. Any future modification requires separate explicit Project Owner authorization identifying the exact path and permitted mutation.

## 2. Purpose

Prepare bounded, non-executable decision inputs for:

1. identifying abstract artifact classes that might arise only in a future separately authorized Local Readiness Assessment;
2. comparing two unselected classification-category models;
3. defining documentary criteria for future classification decisions;
4. defining plaintext-exposure questions;
5. defining storage, transfer, processing, backup, recovery and export boundaries that require future decisions; and
6. identifying evidence required before any Batch 6 option or Annex alternative can be selected.

This package does not classify actual data, select a classification model, establish that an artifact exists, or determine that encryption is required for an actual system or data path.

## 3. Scope

This package covers abstract planning for:

- future evidence-artifact classes;
- alternative sensitivity and confidentiality models;
- normalized planning classes used only for comparison;
- classification criteria;
- prohibited-content boundaries;
- relationship to the existing Annex Field 9 taxonomy;
- plaintext-exposure boundaries;
- encryption-scope boundaries;
- conditional classification-to-control relationships;
- backup, recovery, replica and export treatment;
- evidence required before encryption-option consideration;
- Project Owner decisions needed for future documentary progression.

All models, classes and matrices are unselected planning constructs.

## 4. Explicit Exclusions

This package excludes:

- repository mutation;
- environment, host, runtime, service, container, database or network inspection;
- secret-store, certificate-store or key-store inspection;
- assessment or command execution;
- evidence collection;
- evidence-directory or evidence-file creation;
- classification of actual data or evidence;
- access to actual sensitive information;
- creation of sample credentials, secrets, tokens or keys;
- executable inspection, redaction, quarantine, retention, deletion or disposal procedures;
- identity, group, ACL, access or encryption configuration;
- classification-model selection;
- classification-category approval;
- modification of the Annex Field 9 taxonomy;
- encryption-option or Annex-alternative selection;
- selection of products, vendors, algorithms, architectures, key owners or custodians;
- implementation planning;
- runtime activity;
- deployment;
- governance modification;
- milestone establishment;
- M4;
- Platform Foundation;
- a formal EAIRA Execution Layer.

## 5. Source Evidence

### `VERIFIED SOURCE EVIDENCE`

| Claim ID | Source path and location | Source-expression type | Source wording or summary | Batch 7 constraint |
| --- | --- | --- | --- | --- |
| `B7-VSE-01` | `docs/project/status/CURRENT_STATUS.md` — `Active Phase` | `FAITHFUL SOURCE SUMMARY` | Work remains bounded Project Layer planning; the Annex is not finalized; assessment execution and evidence collection remain unauthorized. | Batch 7 must remain documentary and non-executable. |
| `B7-VSE-02` | Same — `Current Decision` | `FAITHFUL SOURCE SUMMARY` | The package decision remains `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`; Batch 6 was accepted without option selection or execution authority. | Classification planning cannot become assessment or encryption authority. |
| `B7-VSE-03` | Same — `Current Decision` | `FAITHFUL SOURCE SUMMARY` | Field 8 is `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`; Field 9 is `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`; Fields 10 and 11 retain dependencies; the gate is `BLOCKED`. | Batch 7 cannot claim to resolve a Field or satisfy the gate. |
| `B7-VSE-04` | Same — `Current Milestone` | `EXACT VALUE` | `Current/New Milestone: None established.` | Batch 7 cannot establish or imply a milestone. |
| `B7-VSE-05` | `docs/project/status/TODAY_OBJECTIVE.md` — `Out of Scope` | `FAITHFUL SOURCE SUMMARY` | The section excludes environment inspection, evidence creation, access or encryption configuration, implementation, runtime execution and deployment. | Batch 7 must not include executable procedures or implementation work. |
| `B7-VSE-06` | `docs/project/status/ACTIVE_TASK.yaml` — keys `Status`, `Execution Marker`, `Assessment Evidence Collection` | `FAITHFUL SOURCE SUMMARY` | The task is `AUTHORIZED_FOR_AUTHORIZATION_PACKAGE_PREPARATION`, is `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION`, and assessment evidence collection is `Unauthorized`. | The package is planning-only and may not collect supporting assessment evidence. |
| `B7-VSE-07` | Same — keys `Batch 6 Option Disposition`, `Encryption Mechanism State` | `EXACT VALUE` | Options A–D are `REVIEWED_NOT_SELECTED`; all four Annex alternatives remain `PROPOSED_NOT_APPROVED`; `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS`; `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT`; no mechanism is assumed enabled. | Batch 7 cannot select or prefer an option or mechanism. |
| `B7-VSE-08` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` — Section 11, `Approved evidence-control planning register` | `BOUNDED INTERPRETATION` | The source distinguishes direct output, redacted output, verifier disposition, integrity records, stopped-assessment material and related evidence-control structures. Batch 7 extends those documented structures only into abstract artifact-class questions. | Artifact classes remain planning categories; their existence must not be inferred. |
| `B7-VSE-09` | Same — Section 12, `Existing prohibition boundary` and `Approved sensitive-data taxonomy and general dispositions` | `FAITHFUL SOURCE SUMMARY` | Secret capture is prohibited. Credentials, passwords, API keys, tokens, private keys, private certificate material, connection strings, database credentials and environment-variable values are prohibited from capture. | Batch 7 cannot weaken the prohibited-content boundary or use encryption to justify retention. |
| `B7-VSE-10` | Same — Section 12, `Approved accidental-exposure planning procedure` | `FAITHFUL SOURCE SUMMARY` | Suspected exposure requires stop; affected evidence is unusable pending Project Owner decision; exact notification, quarantine and disposal mechanisms remain blocked. | Batch 7 may identify decision categories but cannot define executable quarantine or disposal procedures. |
| `B7-VSE-11` | Same — Section 16, `Consolidated Project Owner Input Queue`, item 6 | `EXACT EXCERPT` | “Before any encryption option or Annex-alternative selection, resolve the Batch 6 evidence gaps for approved data and evidence classification; exact encryption scope; verified platform and application capabilities; key ownership, custody, administration, permitted service identities and separation; backup, recovery, rotation, revocation and compromise response; auditability and cryptographic standards; vendor, regional, licensing, portability and recovery constraints; and future acceptance and verification criteria.” | Batch 7 supplies classification and scope planning evidence, not option selection. |
| `B7-VSE-12` | Same — Section 15, `Mandatory Field 12 — All-Fields-Resolved Gate` | `FAITHFUL SOURCE SUMMARY` | `EVIDENCE_GAP`, `ASSUMPTION`, partial states and unresolved ambiguity fail the gate; the current evaluation is `BLOCKED`. | Batch 7 gaps, unselected models and assumptions remain blockers. |
| `B7-VSE-13` | `docs/project/planning/BATCH_6_ENCRYPTION_OPTION_LEVEL_PLANNING_PACKAGE.md` — Section 7, `Evidence Gaps` | `FAITHFUL SOURCE SUMMARY` | Approved data classification, artifact classes, encryption scope, plaintext boundaries, backups, exports and replicas remain evidence gaps. | Batch 7 addresses these only as abstract planning questions. |
| `B7-VSE-14` | Same — Sections 14 and 24 | `FAITHFUL SOURCE SUMMARY` | The Batch 6 crosswalk is non-selective; no option or Annex alternative is approved; option selection remains blocked. | Batch 7 must not reinterpret the crosswalk as a selection. |
| `B7-VSE-15` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_6_REVIEW_DECISION.md` — Sections 5–8 | `FAITHFUL SOURCE SUMMARY` | Options remain unselected, alternatives remain unapproved, evidence gaps remain unresolved, Fields and gate remain blocked, and data-classification execution is unauthorized. | Batch 7 must preserve every Batch 6 disposition and non-authorization boundary. |
| `B7-VSE-16` | `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md` — Sections 5, 6, 10 and 11 | `FAITHFUL SOURCE SUMMARY` | The task is limited to bounded Annex planning and prohibits assessment, inspection, evidence collection, configuration, implementation, runtime and deployment activity. | Batch 7 remains a documentary planning sub-scope only. |

## 6. Existing Approved Decisions

### `EXISTING APPROVED DECISION`

| Claim ID | Source path and location | Source-expression type | Source wording or summary | Batch 7 constraint |
| --- | --- | --- | --- | --- |
| `B7-EAD-01` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md` — Sections 1 and 2 | `EXACT EXCERPT` | “The Project Owner records `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`”; “`AUTHORIZE_BOUNDED_ASSESSMENT` is not granted.” | Batch 7 may prepare planning evidence only. |
| `B7-EAD-02` | Same — Sections 4 and 9 | `FAITHFUL SOURCE SUMMARY` | Assessment, evidence collection, implementation and milestone establishment remain unauthorized; a future unconditional decision is required before assessment activity. | Batch 7 cannot create conditional execution authority. |
| `B7-EAD-03` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` — Section 11, `Approved integrity planning input` | `EXACT EXCERPT` | “Proposed future integrity algorithm: `SHA-256`”; “No hash calculation is authorized by this decision.” | Integrity remains distinct from confidentiality and encryption. Prohibited content must not be hashed merely to preserve it. |
| `B7-EAD-04` | Same — Section 11, `Approved retention planning input` | `EXACT EXCERPT` | “Retention policy: `FIXED_30_DAY_RETENTION_AFTER_FINAL_VERIFIER_DISPOSITION`”; “The policy applies only to safely retained and usable evidence.” | Classification planning must distinguish safely retainable material from prohibited or unusable material. |
| `B7-EAD-05` | Same — Section 11, `Approved evidence-control planning register` | `FAITHFUL SOURCE SUMMARY` | Direct output and redacted derivatives remain separate; unsafe content is not copied merely to preserve it; export requires separate approval. | Artifact classes, derivatives and export treatment must preserve these boundaries. |
| `B7-EAD-06` | Same — Section 12, `Approved sensitive-data taxonomy and general dispositions` | `FAITHFUL SOURCE SUMMARY` | Secret-bearing categories are prohibited from capture; other categories have exact conditional, blocked, redaction or retention dispositions. | Candidate Batch 7 models cannot replace or weaken existing Annex dispositions. |
| `B7-EAD-07` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_BATCH_6_REVIEW_DECISION.md` — Section 2 | `EXACT VALUE` | `APPROVE_BATCH_6_AS_PLANNING_EVIDENCE_WITHOUT_OPTION_SELECTION_OR_EXECUTION_AUTHORITY` | Batch 7 supplements Batch 6 evidence; it does not replace or expand Batch 6. |
| `B7-EAD-08` | Same — Section 5 | `EXACT VALUE` | Options A–D: `REVIEWED_NOT_SELECTED`; all four Annex alternatives: `PROPOSED_NOT_APPROVED`. | No Batch 7 model or matrix may imply encryption preference or selection. |
| `B7-EAD-09` | Same — Section 5 | `EXACT VALUE` | `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT`; `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS`; `No encryption mechanism is assumed enabled.` | Encryption scope remains undecided and conditional. |
| `B7-EAD-10` | Same — Section 7 | `FAITHFUL SOURCE SUMMARY` | Field 8 remains partial; Field 9 remains partial; Fields 10 and 11 retain dependencies; the gate remains `BLOCKED`; assessment and evidence collection remain unauthorized. | Batch 7 does not change mandatory states or grant execution authority. |

No approved decision is reinterpreted or modified.

If a proposed model, category, boundary or control appears inconsistent with an approved decision, classify it:

`POTENTIAL_DECISION CONFLICT`

and return it to the Project Owner without resolving it.

## 7. Evidence Gaps

### `EVIDENCE GAP`

The following remain unresolved:

- actual data inventory;
- actual assessment outputs;
- actual artifact population or volume;
- actual platform or application capabilities;
- actual Windows or WSL data paths;
- actual temporary-processing locations;
- actual backup, snapshot, replica and recovery architecture;
- actual export or transfer paths;
- actual identities, groups, permissions and effective access;
- actual compliance, contractual or regulatory obligations;
- actual cryptographic requirements;
- actual product, vendor, licensing, regional or portability constraints;
- actual log contents and logging behavior;
- actual plaintext locations;
- actual recovery and emergency-access needs;
- actual retention exceptions;
- actual acceptance and verification criteria.

No evidence gap is closed by this package.

## 8. Artifact-Class Planning

All entries are:

`PLANNING CATEGORY`

They describe possible future documentary classes only. No artifact is claimed to exist.

| Candidate artifact class | Abstract planning boundary | Classification questions |
| --- | --- | --- |
| Direct command output | Unmodified bounded output from a future separately authorized command | Could it contain secrets, identifiers, paths, infrastructure details or business-sensitive data? Is retention permissible? |
| Redacted command output | A derivative created only under a future approved redaction process | Is redaction sufficiently irreversible? Does context permit re-identification? Is the source retainable? |
| Verifier disposition | Independent review result separate from primary evidence | Does it contain protected excerpts or only bounded conclusions and references? |
| Integrity record | Hash and provenance metadata for safely retained evidence | Does metadata expose sensitive names, paths, timestamps or relationships? |
| Assessment metadata | Session, manifest, target, timing, operator and provenance references | Which identifiers are necessary, and which must be aliased or omitted? |
| Reproduction record | Documentary provenance for a future material observation | Could command text, path data or expected values expose protected information? |
| Criteria-to-evidence mapping | Link between a criterion, evidence reference and verifier action | Does the mapping disclose protected system, business or identity information? |
| Stopped-assessment record | Minimum non-sensitive record of a stopped activity | Which fields remain safe when underlying output is unusable or prohibited? |
| Incident or accidental-exposure record | Minimum metadata concerning suspected exposure | Which metadata can be retained without repeating or expanding exposure? |
| Temporary processing artifact | Possible transient copy, cache, working file or intermediate representation | Is creation permitted? Where could plaintext exist? When must persistence be prohibited? |
| Backup or recovery copy | Possible copy retained for restoration or continuity | Does classification propagate? Are required keys and metadata recoverable? |
| Replica or synchronized copy | Possible duplicate created by platform or synchronization behavior | Is replication authorized, mapped and subject to equivalent controls? |
| Export package | Possible bounded transfer package prepared under separate approval | What destination, reader, transfer, redaction, retention and disposal rules apply? |
| Audit or activity record | Possible metadata about access, policy, recovery or future key use | Could the log itself disclose protected content or sensitive relationships? |

The artifact-class structure requires a Project Owner decision before it can govern future classification.

## 9. Proposed Classification-Category Models

Neither model is selected, preferred or recommended.

### Model A — Four-level simplified structure

`PLANNING CATEGORY MODEL — UNSELECTED`

| Candidate class | Abstract planning meaning |
| --- | --- |
| Public / approved non-sensitive disclosure | Information considered for public disclosure or otherwise approved as non-sensitive under an exact future decision |
| Internal | Non-public information intended for bounded internal use |
| Confidential | Information whose unauthorized disclosure could cause material personal, business, operational or security harm |
| Restricted or prohibited | Information requiring the strongest documentary restrictions or prohibited from retention |

Model A is simpler, but it retains ambiguity between:

- public information and non-sensitive internal information; and
- restricted-retainable content and prohibited-from-retention content.

“Approved non-sensitive” does not itself establish that public disclosure is approved.

### Model B — Five-level separated structure

`PLANNING CATEGORY MODEL — UNSELECTED`

| Candidate class | Abstract planning meaning |
| --- | --- |
| Public | Information whose public disclosure is separately approved |
| Internal non-sensitive | Non-public information considered non-sensitive for an approved internal purpose |
| Confidential | Information whose unauthorized disclosure could cause material harm |
| Restricted-retainable | Information whose retention could be considered only under future explicit approval and strict controls |
| Prohibited from retention | Content that must not be retained; encryption, redaction, hashing or restricted access cannot be used as justification for retention |

Model B separates:

- public disclosure from internal non-sensitive handling; and
- restricted-retainable content from prohibited content.

It remains unselected and does not approve any category or actual assignment.

### Decision boundary

`PROJECT OWNER DECISION REQUIRED`

The Project Owner must select, revise or reject Model A, Model B or another explicitly defined model.

No model preference is recorded.

## 10. Classification Criteria

To avoid assuming either model, this section uses normalized planning classes:

- Public
- Internal non-sensitive
- Confidential
- Restricted-retainable
- Prohibited

These normalized classes are analytical constructs only.

Model A would merge or leave ambiguity between certain normalized classes only if explicitly approved by the Project Owner. Model B corresponds more directly to the normalized classes, but that relationship is not a recommendation or selection.

| Criterion | Public | Internal non-sensitive | Confidential | Restricted-retainable | Prohibited |
| --- | --- | --- | --- | --- | --- |
| Business sensitivity | Public disclosure separately approved | Non-public but no material sensitivity established for approved internal use | Material business or operational harm possible | Severe harm possible; retention requires explicit exception and strict controls | Retention prohibited by controlling disposition |
| Personal or identifying information | Only explicitly approved public identity information | Minimal bounded identifiers only if approved | Identifying or personal information requiring narrow handling | Highly sensitive identifying information under explicit future approval | Prohibited identity, secret or credential-bearing content |
| Credentials, secrets or tokens | Not permitted | Not permitted | Not permitted | Not permitted unless an approved Annex disposition expressly states otherwise | Prohibited from retention |
| System or repository paths | Publicly releasable path only after approval | Approved bounded internal reference | Sensitive topology or identity-bearing path | High-risk path information under exact approval | Secret-store, credential-store, production or otherwise prohibited path information |
| Infrastructure details | Approved public facts | Bounded internal detail | Detail that could aid unauthorized access or disruption | Critical detail subject to strict approval | Secret-bearing or prohibited operational detail |
| Financial or operational information | Approved public information only | Low-impact internal information | Material financial, contractual, payroll, customer or operational information | Exceptionally sensitive information under exact approval | Information whose retention is prohibited |
| Redaction reversibility | No protected source content | Low re-identification risk | Material re-identification risk requires review | Strong controls and explicit approval required | Redaction cannot justify retention |
| Harm from disclosure | Public disclosure approved | Limited internal impact | Material harm | Severe or potentially irreversible harm | Prohibited regardless of access restriction |
| Retention permissibility | Approved purpose and duration still required | Bounded retention may be considered | Explicit justification and narrow retention may be required | Retention only under future explicit approval and strict controls | Retention prohibited |
| Minimum reader boundary | Approved public boundary | Approved internal readers | Approved need-to-know readers | Exact narrowly approved readers | No readers because retention is prohibited |
| Confidentiality protection | Not presumed unnecessary | May be considered | Requires Project Owner consideration | Strict protection may be considered after retention approval | Cannot substitute for prohibition |

No actual data is assigned to a normalized class.

## 11. Prohibited-Content Boundary

### Existing controlling boundary

`EXISTING APPROVED DECISION`

Secret-value capture or disclosure is prohibited. Existing Annex prohibitions for credentials, passwords, API keys, OAuth tokens, personal access tokens, private keys, private certificate material, connection strings, database credentials and environment-variable values remain unchanged.

### Documentary disposition categories

| Disposition | Planning meaning |
| --- | --- |
| Safely retainable | Content could be retained only after future authorization, approved classification, purpose, readers, integrity, retention and path controls |
| Redaction required before retention | Source content may require an approved derivative process; the source is not automatically retainable |
| Immediate stop and future incident decision | Suspected exposure requires stop; future quarantine, notification, redaction, retention or disposal requires separate authorization |
| Restricted-retainable | Retention could be considered only under future explicit approval and strict controls |
| Prohibited from retention | Content must not be copied, transformed, hashed, encrypted or access-restricted merely to preserve it |

### `POTENTIAL_DECISION CONFLICT`

Any proposal that treats encryption, redaction, hashing or restricted access as permission to retain an existing prohibited category conflicts with the Annex’s controlling prohibition.

No executable redaction, quarantine, notification or disposal process is defined.

## 12. Encryption-Scope Boundaries

Every row is conditional and requires future Project Owner review.

| Potential scope boundary | Documentary questions | Required future evidence |
| --- | --- | --- |
| Evidence at rest | Which approved artifact classes and locations are in scope? Does classification propagate to derivatives? | Approved artifact inventory, classification and verified storage boundaries |
| Evidence in transit | Does an approved transfer occur, between which bounded endpoints, and what plaintext exposure exists? | Approved data flow, endpoints, transport capability and authentication boundary |
| Temporary processing locations | Could plaintext exist in working files, caches, memory-backed locations or intermediates? | Verified processing design and persistence behavior |
| Windows-host storage | Which approved storage boundary exists and what host-level coverage applies? | Verified Windows path, volume and control evidence |
| WSL-visible storage | How do Windows-host controls and WSL-visible access interact? | Verified mapping and effective-access evidence |
| Backups | Does classification propagate, and are copies protected, recoverable and retained consistently? | Verified backup architecture and recovery requirements |
| Recovery copies | Which historical versions and metadata are required for restoration? | Approved recovery model and verified capability |
| Exports | Which destination, reader, transfer, redaction, retention and disposal rules apply? | Exact approved export boundary |
| Replicas and synchronized copies | Are copies created, where, and under whose authority? | Verified replication and synchronization behavior |
| Application-level fields or payloads | Which fields require distinct treatment, and where does plaintext occur? | Approved field classification and verified application boundary |
| Metadata | Can names, paths, identifiers, timestamps or relationships disclose protected information? | Approved metadata taxonomy and log/content evidence |
| Logs and audit records | Can logs expose protected plaintext or sensitive relationships? | Verified logging behavior, schema and access boundary |

No listed path, copy, platform or capability is asserted to exist.

## 13. Plaintext Exposure Boundaries

### `PROJECT OWNER DECISION REQUIRED`

| Decision area | Decision required |
| --- | --- |
| Temporary plaintext locations | Decide whether plaintext may exist and within which approved processing boundary |
| Plaintext readers | Decide the minimum approved role categories without assigning actual identities or permissions |
| Administrator access | Decide whether administrative capability may expose plaintext and what separation or approval boundary applies |
| Verification access | Decide whether decryption for independent verification is allowed, by whom, for what purpose and under what evidence controls |
| Logs | Decide whether protected data may appear in logs; no default may be inferred |
| Backups | Decide whether plaintext backups are prohibited or whether an exact exception can exist |
| Recovery | Decide when recovery may produce plaintext and who approves it |
| Emergency access | Decide trigger, approver, duration, audit and post-event review requirements |
| Temporary derivatives | Decide whether intermediate plaintext artifacts may be created or persisted |
| Failure and crash material | Decide how dumps, temporary files or partial outputs are treated without presuming they exist |
| Export preparation | Decide whether plaintext may exist during packaging or transfer preparation |
| Key-administration separation | Decide how key administration remains separated from protected-data access |

No identity, account, group, permission or technical mechanism is selected.

## 14. Classification-to-Control Decision Matrix

This matrix uses normalized planning classes and does not select Model A or Model B.

Model A would merge or leave ambiguity between normalized classes only if explicitly approved. Model B would keep the five normalized classes separate only if explicitly approved.

Every entry remains conditional on future model approval, actual classification, verified capability and separate authorization.

| Control consideration | Public | Internal non-sensitive | Confidential | Restricted-retainable | Prohibited |
| --- | --- | --- | --- | --- | --- |
| Access-control strength | Public access only if separately approved | Approved internal boundary may be required | Narrow need-to-know access may be required | Exact narrowly approved access required before retention consideration | Retention and access prohibited |
| Retention | Approved purpose and duration still required | Bounded retention may be considered | Explicit justification and narrow retention may be required | Not automatically approved; requires future explicit approval and strict controls | Prohibited |
| Redaction | May be unnecessary only after public status is approved | Could be required for identifiers or paths | Likely requires review and possibly an approved derivative | Strong review required; source retention remains separately controlled | Cannot justify retention |
| Integrity | Approved integrity controls may apply | Approved integrity controls may apply | Approved integrity controls may apply | Approved integrity controls may apply only after retention approval | Must not be hashed merely to preserve it |
| Encryption at rest | Not presumed unnecessary | May be considered | Requires Project Owner consideration | May be considered only after retention is explicitly approved | Cannot authorize retention |
| Encryption in transit | Depends on an approved transfer | May be considered | Requires Project Owner consideration | Requires exact approval if transfer is permitted | Transfer normally prohibited |
| Application-level encryption | Not presumed | Could be considered if field scope is approved | Could be considered subject to verified capability | Could be considered only after explicit retention approval | Cannot substitute for prohibition |
| Backup treatment | Inclusion requires an approved backup boundary | Classification may need to propagate | Equivalent or stronger protection may be considered | Backup requires explicit approval and strict controls | Backup prohibited |
| Export restrictions | Export still requires separate approval | Bounded destination and readers required | Narrow destination and transfer controls required | Exact exceptional approval required | Export prohibited |
| Audit requirements | Basic provenance may be considered | Bounded access/activity records may be required | Attributable access and recovery records may be required | Strict attributable records may be required after retention approval | Record only safe minimum metadata; do not preserve prohibited content |
| Plaintext exposure | Public status does not itself authorize processing | Minimize within an approved boundary | Strictly bounded and separately approved | Exceptional and strictly bounded | Prohibited |
| Recovery | Approved recoverability criteria still required | Controlled recovery may be required | Narrow recovery authority may be required | Exact recovery and emergency authority required | Recovery must not recreate prohibited retained content |

Public and internal non-sensitive information are not automatically equivalent.

Restricted-retainable content is not automatically approved for retention.

Encryption cannot authorize retention of prohibited content.

## 15. Relationship to Existing Annex Field 9 Sensitive-Data Taxonomy

Batch 7 candidate classification models do not replace, rename, supersede, weaken or reinterpret the existing approved Annex Field 9 taxonomy or dispositions.

The following boundaries control:

1. Existing prohibited secret-bearing categories remain controlling.
2. Existing Annex dispositions remain authoritative unless separately modified by a Project Owner decision.
3. Batch 7 categories are broader documentary planning models intended only to organize future decision inputs.
4. No actual Annex taxonomy row is reassigned by Batch 7.
5. Any future mapping between the Annex taxonomy and Batch 7 categories must be a:
   `NON-SELECTIVE DOCUMENTARY CROSSWALK`
6. Any conflict must be classified:
   `POTENTIAL_DECISION CONFLICT`
   and returned to the Project Owner.
7. Where Batch 7 wording and an approved Annex disposition differ, the approved Annex disposition controls.
8. Public disclosure must not be inferred from an Annex disposition that merely identifies content as non-sensitive.
9. Restricted retention must not be inferred for content already prohibited from capture or retention.

### Non-selective example crosswalk

`NON-SELECTIVE DOCUMENTARY CROSSWALK`

| Existing Annex disposition type | Potential Batch 7 planning class | Boundary |
| --- | --- | --- |
| Prohibited secret-bearing content | Prohibited from retention | Existing Annex prohibition remains controlling; no reassignment occurs |
| Conditionally retainable sensitive content | Confidential or Restricted-retainable | Exact classification requires future Project Owner approval |
| Approved non-sensitive metadata | Public or Internal non-sensitive | Public disclosure must not be inferred from non-sensitive status |
| Unresolved business-sensitive category | Unassigned | Remains unresolved and cannot be classified by assumption |

This example does not approve a classification, crosswalk mapping or Annex change.

## 16. Relationship to Batch 6

Batch 7 does not replace, supersede, reinterpret or modify Batch 6.

Batch 7 supplies abstract classification and encryption-scope planning evidence required before Batch 6 option selection can be considered.

The following states remain unchanged:

- Option A — Platform-managed Encryption: `REVIEWED_NOT_SELECTED`
- Option B — Customer-managed Keys: `REVIEWED_NOT_SELECTED`
- Option C — Application-level Encryption: `REVIEWED_NOT_SELECTED`
- Option D — Hybrid Encryption Model: `REVIEWED_NOT_SELECTED`
- BitLocker-backed host-volume protection: `PROPOSED_NOT_APPROVED`
- Encrypted evidence archive: `PROPOSED_NOT_APPROVED`
- Application-level encryption: `PROPOSED_NOT_APPROVED`
- No separate encryption beyond approved host-volume control: `PROPOSED_NOT_APPROVED`
- Controlling encryption state: `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT`
- Planning qualifier: `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS`

The underlying decision remains:

`DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`

The Batch 6 decision remains:

`APPROVE_BATCH_6_AS_PLANNING_EVIDENCE_WITHOUT_OPTION_SELECTION_OR_EXECUTION_AUTHORITY`

No encryption mechanism is assumed enabled.

The existing key-storage prohibition remains unchanged:

`Encryption keys must not be stored in the evidence root, Git repository, Annex files, or environment variables captured as evidence.`

Batch 7 proposes no key-storage location.

### 16.1 Risks and Trade-offs

| Risk | Planning treatment |
| --- | --- |
| A category model is treated as selected | Preserve both models as `PLANNING CATEGORY MODEL — UNSELECTED` |
| Public and internal non-sensitive are conflated | Require an explicit Project Owner decision |
| Restricted-retainable and prohibited are conflated | Require an explicit Project Owner decision and preserve Annex prohibitions |
| Actual data is classified without evidence | Prohibit actual assignment under this package |
| Encryption is treated as permission to retain secrets | Preserve existing capture and retention prohibitions |
| Metadata is under-classified | Require separate metadata and relationship review |
| Derivatives are assumed less sensitive | Require approved inheritance and redaction-reversibility rules |
| Backups or replicas escape scope | Require verified architecture before selection |
| Plaintext persists in temporary processing | Require an explicit plaintext boundary |
| Administrator access defeats confidentiality | Require a Project Owner decision on privileged plaintext access |
| Recovery is impossible after key loss | Require approved recovery evidence before option selection |
| Logs expose protected data | Require verified logging behavior and classification |
| Crosswalk is treated as authoritative | Label it non-selective and return conflicts to the Project Owner |
| Batch 7 is treated as option selection | Preserve all Batch 6 dispositions and blockers |

## 17. Project Owner Decisions Required

### `PROJECT OWNER DECISION REQUIRED`

Before Batch 7 could be approved as planning evidence, the Project Owner must decide:

1. Model A versus Model B, a revised model, or rejection of both.
2. Whether public and internal non-sensitive information remain separate.
3. Whether restricted-retainable and prohibited-from-retention content remain separate.
4. Final category names, definitions and criteria.
5. Taxonomy precedence between approved Annex dispositions and any later Batch 7 model.
6. Confirmation that approved Annex dispositions control whenever wording differs.
7. Crosswalk authority and whether any future crosswalk may be recorded.
8. Classification inheritance for metadata, derivatives, backups, replicas, recovery copies and exports.
9. Ambiguity handling when an Annex disposition and Batch 7 category appear inconsistent.
10. Whether the highest applicable category controls when multiple criteria apply.
11. Whether to approve the proposed artifact-class structure.
12. The prohibited-content categories and any exact exceptions.
13. Documentary encryption-scope boundaries for at-rest, in-transit, temporary-processing, Windows, WSL, backup, recovery, export, replica, application and metadata contexts.
14. The acceptable plaintext-exposure boundary.
15. Whether administrators may access plaintext.
16. Whether decryption for independent verification may be permitted.
17. Backup, recovery and export treatment.
18. Classification-owner role and classification-approval authority.
19. Dispute, uncertainty and escalation handling.
20. Required future platform, application, backup, recovery, logging and data-flow evidence.
21. Required future compliance and cryptographic-requirement evidence.
22. Whether Batch 7 may later be recorded as approved planning evidence.
23. Whether any future modification of this package or creation of a subsequent documentary package should be authorized, including the exact path and permitted mutation.

The repository records the Project Owner as decision authority. It does not assign a separate classification execution owner. No such owner is inferred.

## 18. Recommended Next Documentary Action

### `RECOMMENDATION`

For Project Owner consideration only:

1. Review both classification models without selecting by implication.
2. Decide whether the two ambiguity boundaries must remain separated.
3. Review the normalized conditional matrix.
4. Review the Field 9 taxonomy precedence and non-selective crosswalk boundary.
5. Review artifact classes, encryption-scope questions and plaintext-exposure decisions.
6. Approve, revise or reject the documentary structure without assigning actual data.
7. Treat the completed repository creation of this package as documentary recording only; it does not constitute approval of Batch 7 planning evidence. Any future modification requires separate explicit Project Owner authorization.
8. Conduct a separate Project Owner review before treating Batch 7 as approved planning evidence.
9. Keep Batch 6 option selection blocked until required classification, scope and capability evidence is separately approved.

No classification model or encryption option is recommended.

## 19. Authorization Boundary

This package:

- was prepared as a response-only proposal and subsequently created through separate explicit Project Owner repository-write authorization;
- compares two unselected classification models;
- identifies normalized analytical classes without selecting them;
- identifies abstract artifact categories;
- does not claim any artifact exists;
- does not classify actual data or evidence;
- does not modify or reinterpret the Annex Field 9 taxonomy;
- does not inspect an environment or data path;
- does not collect evidence;
- does not define executable commands;
- does not approve redaction, quarantine or disposal execution;
- does not select encryption scope;
- does not select a Batch 6 option;
- does not approve an Annex alternative;
- does not select a product, vendor, algorithm, architecture, key owner or custodian;
- does not configure access or encryption;
- does not perform implementation planning;
- preserves Field 8 as `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`;
- preserves Field 9 as `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`;
- preserves Field 10 and Field 11 dependencies;
- preserves the all-fields-resolved gate as `BLOCKED`;
- does not establish a milestone, M4, Platform Foundation or formal EAIRA Execution Layer;
- does not modify an approved decision;
- records no authority for any future repository mutation; future modifications require separate explicit Project Owner authorization.

Final status:

`READY_FOR_PROJECT_OWNER_CLASSIFICATION_SCOPE_REVIEW`

This status means ready only for review of abstract classification and scope planning. It does not mean ready to select a classification model, classify actual data, select encryption, configure controls or begin implementation planning.

Repository artifact state:

`CREATED_PENDING_PROJECT_OWNER_DOCUMENT_REVIEW`

This state means the package exists as a repository artifact but has not been approved as planning evidence. Git staging, commit and push status are repository-history facts and are not used as this document’s enduring approval state.
