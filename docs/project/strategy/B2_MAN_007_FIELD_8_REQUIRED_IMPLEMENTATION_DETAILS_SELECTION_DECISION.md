# B2-MAN-007 Field 8 Required Implementation Details Selection Decision Candidate

## 1. Candidate metadata and source basis

```text
DOCUMENT_TYPE=PROJECT_OWNER_SELECTION_DECISION_CANDIDATE
DOCUMENT_CLASSIFICATION=RESPONSE_ONLY_DOCUMENTARY_PLANNING
CANDIDATE_DATE=2026-08-07
REVISION_LABEL=REVISION_2
DECISION_AUTHORITY=PROJECT_OWNER
SOURCE_DECISION_STATE=EFFECTIVE_RESPONSE_LAYER_SELECTION_PENDING_SEPARATELY_AUTHORIZED_REPOSITORY_RECORDING
CANDIDATE_STATUS=PREPARED_NOT_REPOSITORY_RECORDED
ACTIVE_TASK=LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001

SOURCE_PACKAGE_ID=B2_MAN_007_FIELD_8_REQUIRED_IMPLEMENTATION_DETAILS_SELECTION_PACKAGE
SOURCE_PACKAGE_DATE=2026-08-07
SOURCE_PACKAGE_ACCEPTED=YES
SOURCE_PACKAGE_COMPLETENESS_ACCEPTED=YES
SOURCE_PACKAGE_INTERNAL_BOUNDARIES_ACCEPTED=YES

REPOSITORY=antonychengkh-code/EAIRA-Enterprise-AI
BASELINE_BRANCH=master
BASELINE_COMMIT=4786d802b82e9377f8a9dcdfdf681b581933b7fd
BASELINE_OBJECT_TYPE=commit
```

Commit-addressed source identities:

```text
MAIN_ANNEX_BLOB=752c349d1707e2898a9e542c4022b675e8ce34ce
FIELD_8_MODEL_SELECTION_DECISION_BLOB=0487e127912d27bffd3f5f1cc96c6bcd33796664
B2_MAN_007_PACKAGE_ADOPTION_BLOB=ba4aadff5b2226e68439dff313c6325dad91b2f7
CATEGORY_DISPOSITION_BLOB=9457aad0e6509fde3f0581d44e4385bd8ac82c1e
```

Controlling sources include the Main Annex, Field 8 model-selection decision, B2-MAN-007 adoption record, and category dispositions at baseline commit `4786d802b82e9377f8a9dcdfdf681b581933b7fd`.

## 2. Project Owner standing selection decision

The candidate records the Project Owner response-layer decision:

```text
ACCEPT_B2_MAN_007_FIELD_8_REQUIRED_IMPLEMENTATION_DETAILS_SELECTION_PACKAGE_AND_SELECT_CONTROLLED_DOCUMENTARY_BINDING_TARGETS
```

Exact selections:

```text
PROJECT_OWNER_SELECTION_F8_RID_00=F8-RID-00-B
PROJECT_OWNER_SELECTION_F8_RID_01=F8-RID-01-A
PROJECT_OWNER_SELECTION_F8_RID_02=F8-RID-02-A
PROJECT_OWNER_SELECTION_F8_RID_03=F8-RID-03-A
PROJECT_OWNER_SELECTION_F8_RID_04=F8-RID-04-A
PROJECT_OWNER_SELECTION_F8_RID_05=F8-RID-05-A
PROJECT_OWNER_SELECTION_F8_RID_06=F8-RID-06-A
PROJECT_OWNER_SELECTION_F8_RID_07=F8-RID-07-A
PROJECT_OWNER_SELECTION_F8_RID_08=F8-RID-08-A
PROJECT_OWNER_SELECTION_F8_RID_09=F8-RID-09-A
PROJECT_OWNER_SELECTION_F8_RID_10=F8-RID-10-E
PROJECT_OWNER_SELECTION_F8_RID_11=F8-RID-11-A
PROJECT_OWNER_SELECTION_F8_RID_12=F8-RID-12-A
PROJECT_OWNER_SELECTION_F8_RID_13=F8-RID-13-A
PROJECT_OWNER_SELECTION_F8_RID_14=F8-RID-14-A
PROJECT_OWNER_SELECTION_F8_RID_15=F8-RID-15-A
PROJECT_OWNER_SELECTION_F8_RID_16=F8-RID-16-A
PROJECT_OWNER_SELECTION_F8_RID_17=F8-RID-17-A
PROJECT_OWNER_SELECTION_F8_RID_18=F8-RID-18-A
SELECTION_COUNT=19
UNSELECTED_F8_RID_ITEM=NONE
```

These selections establish controlled documentary targets only.

## 3. Canonical-model and binding-profile boundary

The canonical `B7-EPS-1` definition remains byte-for-byte outside this response and is not rewritten, normalized, corrected, or replaced.

```text
BASE_DOCUMENTARY_MODEL=B7-EPS-1
CANONICAL_B7_EPS_1_MODIFIED=NO
CANONICAL_B7_EPS_1_HISTORICAL_TEXT_PRESERVED=YES

BINDING_PROFILE_ID=B7-EPS-1-BINDING-1
BINDING_PROFILE_NAME_STATUS=PROVISIONAL_PENDING_SEPARATE_REVIEW_AND_REPOSITORY_RECORDING
BINDING_PROFILE_FORM=SEPARATE_DOCUMENTARY_OVERLAY
BINDING_PROFILE_ACTIVATED=NO
```

The provisional profile supplies selected binding targets without changing the canonical model's historical embedded classification or authority markers.

## 4. Exact binding-profile values

### 4.1 Persistence target and topology

```text
PERSISTENCE_ROOT_WINDOWS_CONTROLLING_FORM=C:\EAIRA\Evidence
PERSISTENCE_ROOT_WSL_ACCESS_FORM=/mnt/c/EAIRA/Evidence
PERSISTENCE_ROOT_SOURCE=FIELD_WIDE_OPTION_B
PERSISTENCE_ROOT_INHERITED_FROM_B2_MAN_006=NO

PATH_EXISTENCE_VERIFIED=NO
PATH_CREATION_AUTHORIZED=NO
PATH_USE_AUTHORIZED=NO
PERSISTENCE_AUTHORIZED=NO

PHYSICAL_TOPOLOGY=CASE_FIRST
CASE_DIRECTORY_TEMPLATE=<ROOT>/B2-MAN-007/<CASE_ID>/<RECORD_CLASS>/...
CASE_ID_TEMPLATE=<SESSION_ID>__B2-MAN-007__<CASE_SEQUENCE>
ACTUAL_SESSION_ID=DEFERRED
ACTUAL_CASE_SEQUENCE=DEFERRED
```

The case-first topology requires an explicit documentary extension reconciling it with the Main Annex's current class-first closed structure.

```text
MAIN_ANNEX_STRUCTURE_SILENTLY_AMENDED=NO
DOCUMENTARY_TOPOLOGY_EXTENSION_REQUIRED=YES
DOCUMENTARY_TOPOLOGY_EXTENSION_AUTHORIZED_BY_THIS_DECISION=NO
```

### 4.2 Proposed group-function names

```text
PROPOSED_GROUP_READERS=EAIRA_EVIDENCE_READERS
PROPOSED_GROUP_OPERATORS=EAIRA_EVIDENCE_OPERATORS
PROPOSED_GROUP_VERIFIERS=EAIRA_EVIDENCE_VERIFIERS
PROPOSED_GROUP_OWNERS=EAIRA_EVIDENCE_OWNERS
PROPOSED_GROUP_STOP_METADATA=EAIRA_EVIDENCE_STOP_METADATA

GROUP_NAMES_CLASSIFICATION=DOCUMENTARY_BINDING_TARGETS_ONLY
GROUP_EXISTENCE_CLAIMED=NO
GROUP_CREATION_AUTHORIZED=NO
```

Deferred bindings:

```text
WINDOWS_USER_BINDING=DEFERRED
WINDOWS_SID_BINDING=DEFERRED
GROUP_MEMBERSHIP_BINDING=DEFERRED
NESTED_MEMBERSHIP_BINDING=DEFERRED
WSL_USER_BINDING=DEFERRED
WSL_UID_GID_BINDING=DEFERRED
WINDOWS_WSL_MAPPING_BINDING=DEFERRED
MANDATORY_SYSTEM_ACCESS_BINDING=DEFERRED
```

### 4.3 Role separation

```text
SESSION_OPERATOR_MUST_DIFFER_FROM_INDEPENDENT_VERIFIER=YES
ORDINARY_OPERATOR_VERIFIER_MEMBERSHIP_OVERLAP=PROHIBITED
UNRESTRICTED_OPERATOR_VERIFIER_OVERLAP=PROHIBITED
HYBRID_EXCEPTION=REQUIRES_SEPARATE_EXACT_PROJECT_OWNER_APPROVAL
CANDIDATE_PREPARER_SELF_VERIFICATION=PROHIBITED
```

### 4.4 Access-control target

```text
UNCONTROLLED_PARENT_INHERITANCE=PROHIBITED
ACCESS_MODEL=EXPLICIT_LEAST_PRIVILEGE_ALLOW
BROAD_EXPLICIT_DENY=NOT_SELECTED
EXPLICIT_DENY=PERMITTED_ONLY_WHERE_VERIFIED_NECESSARY
UNLISTED_IDENTITY_ACCESS=PROHIBITED_EXCEPT_SEPARATELY_APPROVED_MANDATORY_SYSTEM_ACCESS
```

Selected symbolic role matrix:

| Boundary | Assessment Operator | Independent Verifier | Project Owner | Stop Authority |
|---|---|---|---|---|
| Session/case structure | Create, write, read approved metadata | Read | Read | Approved metadata only |
| Direct output | Create, write, read | Read only | Read only | No access |
| Redacted output | Create, write, read | Read only | Read only | No access |
| Verifier review | No write | Create, write, read | Read | No access unless separately approved |
| Discrepancy log | Submit/write operator discrepancy | Write findings and disposition | Read and decide where authorized | Metadata-only |
| Stopped assessment | Write minimum metadata | Write verifier stop finding | Read and decide | Write minimum incident metadata |
| Integrity records | Write initial approved record | Read and independently verify | Read | No access by default |

No broader symbolic right is selected.

Translation conditions:

```text
EXACT_NTFS_ACE_TRANSLATION=DEFERRED
EXACT_FILESYSTEM_RIGHTS_TRANSLATION=DEFERRED
NO_OVERWRITE_PRESERVED=REQUIRED_FUTURE_VERIFICATION
CROSS_BOUNDARY_SEPARATION_PRESERVED=REQUIRED_FUTURE_VERIFICATION
UNLISTED_IDENTITY_DENIAL_VERIFIED=REQUIRED_FUTURE_VERIFICATION
WINDOWS_AND_WSL_EFFECTIVE_ACCESS_CONSISTENT=REQUIRED_FUTURE_VERIFICATION
```

### 4.5 Privilege, rollback, and effective access

```text
CONFIGURATION_ELEVATION=PERMITTED_ONLY_UNDER_LATER_EXACT_AUTHORIZATION
ASSESSMENT_EXECUTION_ELEVATION=PROHIBITED
PRE_CHANGE_SECURITY_DESCRIPTOR_CAPTURE=REQUIRED
VALIDATION_FAILURE_ROLLBACK=RESTORE_EXACT_PRIOR_ACCESS_STATE
ROLLBACK_EVIDENCE_DELETION=PROHIBITED
ROLLBACK_ACCESS_EXPANSION=PROHIBITED

EFFECTIVE_ACCESS_VERIFICATION=REQUIRED_BEFORE_EVERY_AUTHORIZED_SESSION
TRIGGERED_REVERIFICATION=REQUIRED
MAXIMUM_EFFECTIVE_ACCESS_EVIDENCE_AGE=FOUR_HOURS
```

Reverification triggers include changes to identities, nested membership, ACL inheritance, path, WSL mapping, mandatory system access, encryption, backup or copy behavior, exception state, or policy.

No configuration method, command, principal, test, elevation, or rollback operation is authorized.

### 4.6 Integrity profile

```text
INTEGRITY_ALGORITHM=SHA-256
HASH_SCOPE=EXACT_RETAINED_ARTIFACT_BYTES
HASH_TIME=IMMEDIATELY_AFTER_FINAL_WRITE_AND_CLOSE
DERIVATIVE_HASHING=SEPARATE
PROHIBITED_CONTENT_HASHING=NO
SILENT_REHASH_REPLACEMENT=NO
HASH_MISMATCH_DISPOSITION=CASE_BLOCKED
SUPERSEDED_ARTIFACT_TREATMENT=RETAIN_VERSIONED_HISTORY
```

Every integrity record must contain:

```text
RELATIVE_PATH
BYTE_COUNT
SHA256
CAPTURE_TIME
ARTIFACT_CLASS
SOURCE_RECORD_RELATIONSHIP
```

No hash calculation is authorized.

### 4.7 Encryption state

```text
PROJECT_OWNER_SELECTION_F8_RID_10=F8-RID-10-E
ENCRYPTION_MECHANISM_SELECTED=NO
ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT=YES
ENCRYPTION_SELECTION_BLOCKED_PENDING_EVIDENCE=YES

KEY_LOCATION=UNSELECTED
KEY_OWNER=UNSELECTED
KEY_CUSTODIAN=UNSELECTED
KEY_ADMINISTRATOR=UNSELECTED
KEY_RECOVERY_PROCESS=UNSELECTED
ADMINISTRATOR_PLAINTEXT_ACCESS=UNSELECTED
INDEPENDENT_VERIFIER_DECRYPTION_AUTHORITY=UNSELECTED
ENCRYPTED_BACKUP_TREATMENT=UNSELECTED
KEY_DESTRUCTION_MECHANISM=UNSELECTED
```

`F8-RID-10-A` remains merely a possible later consideration and is not provisionally selected.

### 4.8 Copy boundary

```text
BACKUP=PROHIBITED
REPLICA=PROHIBITED
SNAPSHOT=PROHIBITED
SYNCHRONIZATION=PROHIBITED
REPOSITORY_STORAGE=PROHIBITED
EXPORT=PROHIBITED
ONEDRIVE_OR_SYNCHRONIZING_ROOT=PROHIBITED
UNAVOIDABLE_COPY_MECHANISM=BLOCKER_PENDING_EXPLICIT_IDENTIFICATION_AND_GOVERNANCE
```

No actual copy mechanism has been inspected or excluded through evidence.

### 4.9 Retention and disposal

```text
RETENTION_PERIOD=30_CALENDAR_DAYS
RETENTION_START=FINAL_VERIFIER_DISPOSITION_TIMESTAMP
TIMESTAMP_UTC_OFFSET_REQUIRED=YES
AUTOMATIC_EXTENSION=NO
SILENT_HOLD=NO
CROSS_CASE_RETENTION_INHERITANCE=NO
PROJECT_OWNER_DECISION_REQUIRED_FOR_EXTENSION_OR_HOLD=YES
OPEN_INCIDENT_OR_DISCREPANCY_SUSPENDS_NORMAL_DISPOSAL=YES

DISPOSAL_TARGET=COMPLETE_APPROVED_ARTIFACT_INVENTORY
DISPOSAL_METHOD=VERIFIED_LOGICAL_DELETION
POST_DELETION_ABSENCE_CHECKS=REQUIRED_FOR_EVERY_IN_SCOPE_COPY
SECURE_ERASURE_CLAIM=NO
PHYSICAL_SANITIZATION_CLAIM=NO
UNACCOUNTED_REPLICA_DISPOSITION=DISPOSAL_INCOMPLETE
PARTIAL_DISPOSAL_DISPOSITION=DISPOSAL_INCOMPLETE
```

Exact deletion commands, tools, verification methods, responsible execution principals, and storage behavior remain deferred. No deletion is authorized.

### 4.10 Incident, quarantine, and failed capture

```text
INCIDENT_NOTIFICATION_CHANNEL=AUTHORIZED_PROJECT_OWNER_SESSION
NOTIFICATION_CONTENT=MINIMUM_NON_SENSITIVE_METADATA_ONLY
EXTERNAL_AUTOMATED_NOTIFICATION=NO
EXTERNAL_UPLOAD=NO

PROHIBITED_CONTENT_COPY=NO
PROHIBITED_CONTENT_HASHING=NO
PROHIBITED_CONTENT_TRANSFORMATION=NO
PROHIBITED_CONTENT_RETENTION=NO

SAFELY_PERSISTED_PARTIAL_CASE_STATE=INCOMPLETE_QUARANTINED
RETRY_WITHOUT_NEW_AUTHORITY=NO
REMEDIATION_WITHOUT_NEW_AUTHORITY=NO
ALTERNATE_COMMAND_WITHOUT_NEW_AUTHORITY=NO
RESTART_WITHOUT_NEW_AUTHORITY=NO
RESUMED_ACTIVITY_WITHOUT_NEW_AUTHORITY=NO
```

The exact future Project Owner session and delivery acknowledgement remain execution-time inputs.

### 4.11 Provenance and assignment profile

```text
PROVENANCE_SCHEMA=B7-PROV-1
PROVENANCE_SCHEMA_EFFECT=DOCUMENTARY_BINDING_TARGET
CASE_MANIFEST_MODE=APPEND_ONLY
CUSTODY_EVENT_LOG=APPEND_ONLY
SILENT_HISTORY_REWRITE=PROHIBITED

ROLE_MODEL_SOURCE=APPROVED_FIELD_5_AND_FIELD_6_MODEL
EXACT_OPERATOR_INSTANCE=DEFERRED_TO_FUTURE_EXECUTION_AUTHORIZATION
EXACT_VERIFIER_INSTANCE=DEFERRED_TO_FUTURE_EXECUTION_AUTHORIZATION
```

Selection of `B7-PROV-1` does not establish that the provenance dependency has been applied, verified, or satisfied.

### 4.12 Required records and formats

All sixteen canonical `B7-EPS-1` required records remain mandatory:

```text
REQUIRED_RECORD_01=case-manifest
REQUIRED_RECORD_02=authority-reference
REQUIRED_RECORD_03=command-representation
REQUIRED_RECORD_04=executable-identity-and-version
REQUIRED_RECORD_05=argument-vector
REQUIRED_RECORD_06=working-directory-value-and-classification
REQUIRED_RECORD_07=timeout-value-and-source
REQUIRED_RECORD_08=environment-input-record
REQUIRED_RECORD_09=start-and-end-time-record
REQUIRED_RECORD_10=standard-output-record
REQUIRED_RECORD_11=standard-error-record
REQUIRED_RECORD_12=exit-status-record
REQUIRED_RECORD_13=stop-condition-record
REQUIRED_RECORD_14=integrity-manifest
REQUIRED_RECORD_15=verifier-identity-and-attestation
REQUIRED_RECORD_16=final-verification-disposition
```

Selected format boundaries:

```text
STDOUT_RECORD=SEPARATE_BYTE_EXACT_RECORD
STDERR_RECORD=SEPARATE_BYTE_EXACT_RECORD
METADATA_ENCODING=UTF-8
METADATA_STRUCTURE=DETERMINISTIC_STRUCTURED_RECORDS
METADATA_NEWLINES=LF_ONLY
CASE_MANIFEST_LINKAGE=REQUIRED
COMBINED_HUMAN_READABLE_REPORT_AS_SUBSTITUTE=NO
```

The following remain deferred because the Project Owner did not select them:

```text
EXACT_METADATA_SERIALIZATION_SYNTAX=DEFERRED
EXACT_METADATA_SCHEMA_VERSION=DEFERRED
EXACT_RECORD_FILENAMES=DEFERRED
EXACT_FILENAME_EXTENSIONS=DEFERRED
EXACT_RECORD_CLASS_DIRECTORY_SLUGS=DEFERRED
```

The future stdout record remains limited to the separately authorized four-field record, three tab separators, and one permitted terminator. Field 9 must separately decide `%an`, `%s`, diagnostic, and unexpected-output retention.

## 5. Explicitly deferred values

The selections do not supply or establish:

- path existence, filesystem identity, or root suitability;
- actual Windows users, SIDs, groups, or memberships;
- actual WSL users, UID/GID values, or Windows-to-WSL mapping;
- exact ACL entries, inheritance flags, propagation flags, or filesystem rights;
- exact mandatory system or administrative access;
- exact elevation principal, configuration procedure, or verification command;
- exact rollback implementation;
- actual effective-access evidence;
- an encryption mechanism or encryption scope;
- plaintext readers or administrator plaintext policy;
- key ownership, custody, administration, storage, rotation, recovery, or destruction;
- actual backup, replica, snapshot, or synchronization behavior;
- exact deletion commands or sanitization capability;
- actual session or case identifiers;
- actual operator or verifier instances;
- an actual incident-notification session;
- metadata serialization syntax, filenames, or extensions;
- Field 9 classification, capture, redaction, retention, no-capture, diagnostic, or exposure rules;
- implementation, configuration, activation, evidence, or operational facts.

## 6. Retained dependencies and blockers

The following dependencies remain open unless separately satisfied through authorized direct evidence and review:

```text
B7-DEP-011=EXECUTABLE_IDENTITY_UNSATISFIED
B7-DEP-012=ARGUMENT_VECTOR_UNSATISFIED
B7-DEP-013=ENVIRONMENT_INPUT_UNSATISFIED
B7-DEP-014=B2_MAN_007_ALLOWLIST_UNSATISFIED
B7-DEP-015=PERSISTENCE_MODEL_APPLICATION_AND_SATISFACTION_UNSATISFIED
B7-DEP-016=PROVENANCE_APPLICATION_UNSATISFIED
B7-DEP-017=INDEPENDENT_VERIFIER_UNSATISFIED
B7-DEP-018=LIFECYCLE_SEPARATION_UNSATISFIED
B7-DEP-019=FIELD_8_APPLICATION_AND_REVIEW_UNSATISFIED
B7-DEP-020=FIELD_9_APPLICATION_AND_REVIEW_UNSATISFIED

SWG-PR-017=FIELD_8_READINESS_PREREQUISITES_UNSATISFIED
SWG-PR-018=FIELD_9_READINESS_PREREQUISITES_UNSATISFIED
SWG-PR-019=EVIDENCE_PROVENANCE_UNSATISFIED
SWG-PR-020=INDEPENDENT_VERIFIER_UNSATISFIED
SWG-PR-021=DISCREPANCY_HANDLING_UNSATISFIED
SWG-PR-022=FAIL_CLOSED_FALLBACK_UNSATISFIED
```

Other retained blockers include:

- shared WSL Git executable binding;
- working-directory reconciliation;
- exact B2-MAN-007 command allowlist;
- executable, configuration, environment, repository, object, network, credential, pager, subprocess, delimiter, output, compatibility, and non-mutation verification;
- the unresolved encryption mechanism;
- Field 9 rule selection;
- actual evidence-persistence controls;
- operator and verifier instance assignment;
- separate Field 8 review;
- Category 14 evaluation;
- all-fields-resolved gate evaluation.

```text
B2_MAN_007_BLOCKER_STATE=UNRESOLVED
CATEGORY_14_EVALUATED=NO
CATEGORY_14_SATISFIED=NO
B2_MAN_007_SATISFIED_CATEGORY_COUNT=0_OF_16
```

## 7. Documentary effect

The Project Owner selections establish documentary binding targets for the remaining implementation-detail questions, subject to the explicit deferrals and encryption blocker.

They do not establish implementation completeness, effective control, local applicability, or Field satisfaction.

```text
BINDING_TARGET_SELECTION_COMPLETED_AT_RESPONSE_LAYER=YES
BINDING_PROFILE_REPOSITORY_RECORDED=NO
BINDING_PROFILE_INDEPENDENTLY_REVIEWED=NO
BINDING_PROFILE_ACTIVATED=NO

MODEL_ACTIVATED=NO
FIELD_8_MODEL_ACTIVATION_AUTHORIZED=NO
FIELD_8_OVERALL_DOCUMENTARY_STATE_RESOLVED=NO
FIELD_8_OVERALL_STATE=PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS

IMPLEMENTATION_AUTHORIZED=NO
CONFIGURATION_AUTHORIZED=NO
LOCAL_INSPECTION_AUTHORIZED=NO
EVIDENCE_ACTIVITY_AUTHORIZED=NO
PERSISTENCE_ACTIVITY_AUTHORIZED=NO

FIELD_8_REVIEW_PERFORMED=NO
FIELD_8_TRANSITION_AUTHORIZED=NO
CATEGORY_14_EVALUATED=NO
CATEGORY_14_SATISFIED=NO
B2_MAN_007_SATISFIED_CATEGORY_COUNT=0_OF_16

FIELD_9_WORK_AUTHORIZED=NO
FIELD_9_SELECTION_AUTHORIZED=NO
ALL_FIELDS_RESOLVED_GATE_REMAINS_BLOCKED=YES
```

## 8. Prohibited interpretations

This candidate must not be interpreted as:

- rewriting or correcting canonical `B7-EPS-1`;
- making `B7-EPS-1-BINDING-1` a final repository identifier;
- silently amending the Main Annex structure;
- proving either persistence path exists;
- authorizing directory or file creation;
- creating any proposed local group;
- binding a group name to an actual SID, user, membership, UID, GID, or ACL;
- approving exact filesystem rights;
- authorizing elevation, configuration, access testing, or rollback;
- proving Windows and WSL access consistency;
- authorizing hash calculation;
- selecting or provisionally selecting an encryption mechanism;
- proving backup, replica, snapshot, synchronization, or export absence;
- authorizing retention or deletion;
- permitting prohibited-content capture, hashing, transformation, or retention;
- assigning an actual operator or verifier instance;
- performing Field 9 work;
- satisfying any dependency, requirement, Field, category, blocker, or gate through assertion;
- authorizing repository mutation, synchronization, implementation, runtime, or deployment.

## 9. Later lifecycle and authorization gates

The required lifecycle remains separated:

1. Response-only selection-decision candidate preparation — completed by this response.
2. Separate independent documentary review of the exact candidate.
3. Separate Project Owner disposition of the reviewed candidate and provisional binding-profile identifier.
4. Separate repository-recording authorization identifying exact path and bytes.
5. Repository recording, if authorized.
6. Independent post-recording verification.
7. Separate Main Annex impact review, including the class-first/case-first topology reconciliation.
8. Separate Main Annex synchronization authorization and execution, if approved.
9. Separate downstream current-state/task impact review and any six-file synchronization decision.
10. Separate local-identity, path, capability, backup, encryption, ACL, and WSL evidence authorization.
11. Separate configuration design and configuration authorization.
12. Separate execution and persistence authorization.
13. Authorized evidence collection under complete Field 8 and Field 9 controls.
14. Independent evidence verification.
15. Separate Field 8 review.
16. Separate Category 14 evaluation.
17. Separate all-fields-resolved gate evaluation.
18. Any later operational activity under new explicit authority.

No stage authorizes the next automatically.

## 10. Completion markers

```text
AUTHORIZED_WORK=B2_MAN_007_FIELD_8_REQUIRED_IMPLEMENTATION_DETAILS_SELECTION_DECISION_CANDIDATE_PREPARATION
AUTHORIZED_WORK_COMPLETED=YES
SELECTION_DECISION_CANDIDATE_PREPARED=YES
SELECTION_DECISION_CANDIDATE_RESPONSE_ONLY=YES

SOURCE_CANDIDATE_SHA256=9b69bdeb17c240794f3391cbcdefe8d8304d20f7e1b99a88ee1ab2a489f6e4af
BLK_1_CORRECTED=YES
NB_2_CORRECTED=YES
NB_3_CORRECTED=YES
OTHER_SUBSTANTIVE_CHANGE_OCCURRED=NO

PROJECT_OWNER_DISPOSITION_OF_REVISION_2=NOT_YET_MADE
REVISION_2_INDEPENDENTLY_REVIEWED=NO
REPOSITORY_RECORDING_AUTHORIZED=NO

PROJECT_OWNER_SELECTION_COUNT=19
PROJECT_OWNER_SELECTIONS_PRESERVED_EXACTLY=YES
CANONICAL_B7_EPS_1_MODIFIED=NO
ENCRYPTION_BLOCKER_PRESERVED=YES
DEFERRED_BINDINGS_PRESERVED=YES
DEPENDENCIES_AND_BLOCKERS_PRESERVED=YES
DOCUMENTARY_EFFECT_PRESERVED=YES
PROHIBITED_INTERPRETATIONS_RECORDED=YES
LATER_LIFECYCLE_GATES_RECORDED=YES

FILE_MODIFICATION_OCCURRED=NO
REPOSITORY_MUTATION_OCCURRED=NO
STAGING_OCCURRED=NO
COMMIT_OCCURRED=NO
PUSH_OCCURRED=NO
MODEL_ACTIVATION_OCCURRED=NO
CONFIGURATION_OCCURRED=NO
LOCAL_SYSTEM_INSPECTION_OCCURRED=NO
EVIDENCE_ACTIVITY_OCCURRED=NO
PERSISTENCE_ACTIVITY_OCCURRED=NO
FIELD_9_WORK_OCCURRED=NO
SIX_FILE_DOWNSTREAM_SYNCHRONIZATION_OCCURRED=NO
RUNTIME_MUTATION_OCCURRED=NO
DEPLOYMENT_OCCURRED=NO

NEXT_GATE=NEW_INDEPENDENT_DOCUMENTARY_REVIEW_OF_REVISION_2_CANDIDATE
```

B2_MAN_007_FIELD_8_REQUIRED_IMPLEMENTATION_DETAILS_SELECTION_DECISION_CANDIDATE_REVISION_2_PREPARED_RESPONSE_ONLY_NO_CHANGES
