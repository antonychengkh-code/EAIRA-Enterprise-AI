# EAIRA Batch 8 Assessment Scope Minimization and Command Manifest Closure Planning Package

## 1. Document Control

| Field | Value |
| --- | --- |
| Title | EAIRA Batch 8 Assessment Scope Minimization and Command Manifest Closure Planning Package |
| Batch designation | `BATCH_8_ASSESSMENT_SCOPE_MINIMIZATION_AND_COMMAND_MANIFEST_CLOSURE_PLANNING` |
| Repository path | `docs/project/planning/BATCH_8_ASSESSMENT_SCOPE_MINIMIZATION_AND_COMMAND_MANIFEST_CLOSURE_PLANNING_PACKAGE.md` |
| Documentary review state | `PENDING_PROJECT_OWNER_BATCH_8_SCOPE_REVIEW` |
| Repository mutation authority | Creation and every future modification require separate explicit Project Owner authorization |
| Scope-model state | `SCOPE_MODEL_UNSELECTED` |
| Execution marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Decision authority | Project Owner |
| Preparation date | 2026-07-16 |
| Underlying package decision | `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE` |
| Assessment execution | `UNAUTHORIZED` |
| Assessment-evidence collection | `UNAUTHORIZED` |

`FAITHFUL SOURCE SUMMARY`: This package prepares documentary scope decisions only. It does not select a model, modify the Annex, close a Field, authorize a command, or establish that any target or capability exists.

Git lifecycle state is repository-history evidence. It is not the approval state of this package.

## 2. Purpose

Prepare bounded Project Owner decision inputs for minimizing the target and command scope of a possible future Local Readiness Assessment.

The decision question is whether unresolved targets, services, endpoints, ports, command semantics, and associated evidence-control dependencies should:

- remain inside the candidate selected assessment scope;
- be excluded from the candidate selected scope;
- remain deferred for a future separately authorized extension; or
- be rejected as unnecessary for the current Annex scope.

`BOUNDED INTERPRETATION`: Scope minimization may reduce documentary blockers only if the Project Owner explicitly approves the selected scope and separately determines that the retained target set, command rows, supporting records, and interaction definitions form the complete closed initial-assessment scope.

## 3. Scope

This package is limited to:

- comparing Models A, B, and C;
- classifying existing manifest, blocker, supporting, and interaction records under each model;
- analyzing `B2-MAN-011` and `B2-MAN-012`;
- defining exact model-specific Docker client-interaction boundaries;
- explaining target-inventory impact;
- evaluating potential documentary impact on Fields 1–4;
- preserving Fields 8–11 and the all-fields-resolved gate;
- identifying exact Project Owner decisions required.

All three models remain:

`SCOPE_MODEL_UNSELECTED`

No target or row is removed from historical planning evidence by this package.

## 4. Explicit Exclusions

This package does not:

- execute or approve a command;
- inspect the environment or repository working tree for assessment purposes;
- establish executable, service, process, endpoint, address, port, configuration, application, or capability existence;
- contact Docker Engine, Ollama, Hermes, OpenWebUI, or LM Studio;
- collect or create evidence;
- create evidence files or directories;
- configure access or encryption;
- classify actual data;
- select an encryption option or Annex alternative;
- perform implementation planning;
- modify the Annex or another repository artifact;
- establish a milestone, M4, Platform Foundation, formal EAIRA Execution Layer, or successor task.

## 5. Source Evidence

| Label | Repository source and exact location | Recorded value or constraint | Batch 8 effect |
| --- | --- | --- | --- |
| `VERIFIED SOURCE EVIDENCE` | `docs/project/status/CURRENT_STATUS.md` — `Active Phase`, `Blockers`, `Next Action` | Bounded Annex planning remains active; Fields 1–4 and 8–11 remain blocking; no later batch is automatic. | Batch 8 planning cannot change current Field states. |
| `VERIFIED SOURCE EVIDENCE` | `docs/project/status/ACTIVE_TASK.yaml` — `Task ID`, `Execution Marker`, `Overall Annex State` | The active task remains `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001`; execution is not authorized; gate is `BLOCKED`. | No assessment or successor task is authorized. |
| `VERIFIED SOURCE EVIDENCE` | `docs/project/status/AGENT_CONTEXT_VERSION.yaml` | Context metadata tracks Current Status `0.10.0` and Today Objective `0.9.0`. | Source versions were synchronized at the reviewed baseline. |
| `EXISTING APPROVED DECISION` | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md` — Sections 2, 4, 6, and 9 | `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`; every mandatory Annex field must resolve before execution review. | Scope planning cannot become execution authority. |
| `EXISTING APPROVED DECISION` | Main Annex — `Project Owner Input Resolution — Batch 1` | `APPROVE_BATCH_1_WITHOUT_EXECUTION_AUTHORITY`. | Approved target inventory and Fields 5–7 inputs remain unchanged. |
| `EXISTING APPROVED DECISION` | Main Annex — `Project Owner Input Resolution — Batch 2 Review` | `APPROVE_BATCH_2_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`. | Existing manifest and interaction classifications remain controlling until separately revised. |
| `EXISTING APPROVED DECISION` | Main Annex — `Project Owner Input Resolution — Batch 3 Review` | `APPROVE_BATCH_3_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`. | Evidence, reproduction, and mapping dependencies remain non-executable. |
| `EXISTING APPROVED DECISION` | Batch 4 decision — Sections 3.3–6 | Docker context equality-result handling is approved as planning input; exact expected value and evidence handling remain unresolved. | Model B or C may retain `B2-MAN-011` only with preserved conditions. |
| `EXISTING APPROVED DECISION` | Batch 5 decision — Sections 3–8 | Access-control planning decisions are non-executable; Field 8 remains partial. | Scope minimization cannot resolve access implementation. |
| `EXISTING APPROVED DECISION` | Batch 6 decision — Sections 5–9 | Options A–D are `REVIEWED_NOT_SELECTED`; Annex alternatives remain `PROPOSED_NOT_APPROVED`. | Batch 8 cannot select encryption. |
| `EXISTING APPROVED DECISION` | Batch 7 decision — Sections 3–11 | Model B is documentary only; Annex Field 9 controls; no actual classification or retention exception. | Classification and encryption dependencies remain unchanged. |
| `VERIFIED SOURCE EVIDENCE` | Main Annex — `Mandatory Field Resolution Matrix` | Fields 1–4 and 8–11 retain their recorded partial or dependency states; gate is `BLOCKED`. | No Field-state change is supported. |
| `VERIFIED SOURCE EVIDENCE` | Main Annex — command-manifest, blocker, and manifest-count sections | Thirteen `B2-MAN-*` command-manifest rows, one supporting resolution record, and five blocked no-command rows exist. | Supplies the manifest and supporting-record inventory. |
| `VERIFIED SOURCE EVIDENCE` | Main Annex — `Proposed closed interaction allowlist` | `B2-INT-001` through `B2-INT-011`; several interactions remain conditional or blocked. | Supplies the interaction inventory. |

## 6. Existing Approved Decisions

The following remain controlling and unmodified:

- `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`
- `APPROVE_BATCH_1_WITHOUT_EXECUTION_AUTHORITY`
- `APPROVE_BATCH_2_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`
- `APPROVE_BATCH_3_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`
- `APPROVE_BATCH_4_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`
- `APPROVE_BATCH_5_WITH_REQUIRED_REVISIONS_WITHOUT_EXECUTION_AUTHORITY`
- `APPROVE_BATCH_6_AS_PLANNING_EVIDENCE_WITHOUT_OPTION_SELECTION_OR_EXECUTION_AUTHORITY`
- `APPROVE_BATCH_7_AS_PLANNING_EVIDENCE_AND_SELECT_MODEL_B_WITHOUT_ACTUAL_CLASSIFICATION_OR_EXECUTION_AUTHORITY`
- Annex Field 9 taxonomy and disposition precedence
- `NON-SELECTIVE DOCUMENTARY CROSSWALK`
- `POTENTIAL_DECISION CONFLICT`
- no retention exception
- Batch 6 Options A–D: `REVIEWED_NOT_SELECTED`
- Annex encryption alternatives: `PROPOSED_NOT_APPROVED`
- `ENCRYPTION_MECHANISM_PENDING_PROJECT_OWNER_INPUT`
- `OPTION_SELECTION_REMAINS_BLOCKED_BY_EVIDENCE_GAPS`
- all prohibited target and interaction boundaries
- assessment execution and evidence collection: `UNAUTHORIZED`
- no current or new milestone

## 7. Current Fields 1–4 Blocker State

| Field | Current state | Current blocker basis |
| --- | --- | --- |
| Field 1 | `PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING` | The inventory is approved as planning input, but complete command-level controls for permitted targets remain unresolved. |
| Field 2 | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | `B2-MAN-011` requires revision, `B2-MAN-012` is deferred, and five target-specific no-command rows remain blocked. |
| Field 3 | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | Command semantics, evidence use, redaction, reproduction, and mapping dependencies remain unresolved. |
| Field 4 | `PARTIALLY_RESOLVED_WITH_BLOCKERS` | Docker Engine, Ollama, Hermes, OpenWebUI, and LM Studio interactions remain blocked; no service endpoint or port is approved. |

A Project Owner scope decision does not by itself close Fields 1–4. A separate determination is required that the retained target set, command rows, supporting records, and interaction definitions constitute the complete closed initial-assessment scope.

## 8. Current Manifest and Interaction Inventory

### Historical planning inventory

| Record category | Records | Count | Current role |
| --- | --- | ---: | --- |
| Command-manifest rows | `B2-MAN-001`–`B2-MAN-013` | 13 | Eleven approved planning rows, one approved with required revision, and one deferred by unresolved semantics. |
| Supporting resolution record | `B2-BLK-001` | 1 | Records resolved Windows Git executable identity supporting `B2-MAN-013`; not a command. |
| Blocked no-command rows | `B2-BLK-002`–`B2-BLK-006` | 5 | Record missing command, path, endpoint, port, process, or resource inputs. |
| Interaction records | `B2-INT-001`–`B2-INT-011` | 11 | Define approved, conditional, or blocked interaction boundaries. |

No supporting or blocked record is an executable command.

### `B2-BLK-001` qualifier

`B2-BLK-001` is:

`RETAINED_AS_SUPPORTING_TRACEABILITY_RECORD_NOT_AS_EXECUTABLE_MANIFEST_ROW`

It:

- records the resolved Windows Git executable identity planning input;
- supports `B2-MAN-013`;
- is not a command;
- is not an interaction;
- does not increase the executable command count;
- grants no Windows Git execution authority.

### Mandatory closure distinctions

For every model, keep separate:

1. historical planning inventory;
2. selected assessment-scope targets;
3. retained command-manifest rows;
4. supporting traceability records;
5. excluded, deferred, or blocked records;
6. interaction allowlist;
7. execution authority;
8. evidence-collection authority.

No model grants execution or evidence-collection authority.

## 9. Model A — Minimal Core Assessment Scope

Status:

`SCOPE_MODEL_UNSELECTED`

If selected, Model A would define a minimal selected documentary scope containing:

- `TGT-REPO-001`
- `TGT-WSL-001`
- `TGT-GIT-WIN-001`
- `TGT-GIT-WSL-001`
- `TGT-DOCKER-001`, limited to `B2-MAN-010`

Retained command-manifest rows:

- `B2-MAN-001`–`B2-MAN-010`
- `B2-MAN-013`

Supporting traceability:

- `B2-BLK-001`

Excluded from selected scope:

- `B2-MAN-011`
- `B2-MAN-012`
- `B2-BLK-002`–`B2-BLK-006`
- corresponding out-of-scope interactions

Every exclusion means only:

`NOT_INCLUDED_IN_SELECTED_ASSESSMENT_SCOPE`

## 10. Model B — Minimal Core Plus Docker Context Equality

Status:

`SCOPE_MODEL_UNSELECTED`

If selected, Model B would retain Model A and additionally retain `B2-MAN-011` only with:

- equality-result handling;
- no retained exact context name;
- a separately approved expected comparison value;
- no `docker context inspect`;
- no context-detail inspection;
- no Docker Engine contact;
- Fields 8 and 9 dependencies remaining blocking;
- no command execution or output collection.

`B2-MAN-012` and `B2-BLK-002`–`B2-BLK-006` remain outside the selected scope.

## 11. Model C — Extended Local AI Assessment Scope

Status:

`SCOPE_MODEL_UNSELECTED`

If selected, Model C would be an extended selected documentary scope. It is not merely a placeholder for an unspecified future extension.

The following remain inside Model C’s candidate selected scope:

- Docker Engine;
- Ollama;
- Hermes;
- OpenWebUI;
- LM Studio.

Inclusion means only documentary scope inclusion. It does not authorize interaction, execution, inspection, connectivity testing, or evidence collection.

Model C preserves:

- `B2-MAN-011` with required documentary revision;
- `B2-MAN-012` inside the documentary scope as `BLOCKED_BY_EVIDENCE_GAP`, while retaining its authoritative state `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW`;
- `B2-BLK-002`–`B2-BLK-006` as blockers inside the selected documentary scope;
- `B2-INT-005` as a conditional client-only planning interaction requiring documentary revision;
- `B2-INT-007`–`B2-INT-011` as separate blocked interaction records;
- no inferred executable, command, path, process identifier, endpoint, address, port, or configuration path;
- no service-contact authority.

`B2-MAN-012` cannot become part of a closed executable manifest unless its command semantics are separately resolved. Neither `ollama --version` nor a substitute command is approved.

`B2-INT-005` must not be conflated with `B2-INT-008`:

- `B2-INT-005` is a conditional client-only planning interaction and does not approve `B2-MAN-012`, service contact, endpoint access, port access, model interaction, or runtime interaction.
- `B2-INT-008` is the separate blocked Ollama service interaction.

`B2-BLK-003` retains its unresolved loopback address, port, endpoint, and non-mutating-command gaps.

## 12. Row-by-Row Disposition Matrix

### Command-manifest, supporting, and blocked records

| Record | Model A | Model B | Model C |
| --- | --- | --- | --- |
| `B2-MAN-001` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-002` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-003` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-004` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-005` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-006` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-007` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-008` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-009` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-010` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-MAN-011` | `EXCLUDE_FROM_SELECTED_SCOPE` | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` |
| `B2-MAN-012` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-MAN-013` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-BLK-001` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-BLK-002` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-BLK-003` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-BLK-004` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-BLK-005` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-BLK-006` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |

For every model, `B2-BLK-001` retains the qualifier:

`RETAINED_AS_SUPPORTING_TRACEABILITY_RECORD_NOT_AS_EXECUTABLE_MANIFEST_ROW`

### Interaction records

| Interaction | Model A | Model B | Model C |
| --- | --- | --- | --- |
| `B2-INT-001` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-INT-002` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-INT-003` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-INT-004` | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` |
| `B2-INT-005` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` |
| `B2-INT-006` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` | `RETAIN_IN_SELECTED_SCOPE` |
| `B2-INT-007` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-INT-008` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-INT-009` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-INT-010` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-INT-011` | `EXCLUDE_FROM_SELECTED_SCOPE` | `EXCLUDE_FROM_SELECTED_SCOPE` | `BLOCKED_BY_EVIDENCE_GAP` |

### Exact model-specific `B2-INT-004` boundaries

| Model | Disposition | Proposed documentary boundary |
| --- | --- | --- |
| Model A | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` | Retain only `B2-MAN-010`; remove `B2-MAN-011` from selected interaction scope; Docker Engine contact remains prohibited; `B2-INT-007` remains outside selected scope. |
| Model B | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` | Retain `B2-MAN-010`; retain `B2-MAN-011` only as equality-result planning; exact-name retention remains unapproved; expected comparison value remains separate Project Owner input; context inspection and Docker Engine contact remain prohibited; Fields 8 and 9 remain blocking. |
| Model C | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` | Retain the same Docker client boundary as Model B; represent Docker Engine separately through `B2-INT-007`; keep `B2-INT-007` as `BLOCKED_BY_EVIDENCE_GAP`; client-interaction planning must not imply Engine-interaction approval. |

No model authorizes Docker interaction or execution.

### `B2-MAN-011` unselected disposition analysis

| Unselected disposition | Classification | Effect |
| --- | --- | --- |
| Remove from selected initial scope | `EXCLUDE_FROM_SELECTED_SCOPE` | Removes the row from Models A’s selected scope without deleting historical evidence. |
| Retain only with equality-result handling | `RETAIN_WITH_REQUIRED_DOCUMENTARY_REVISION` | Preserves the Batch 4 equality approach but requires a separately approved expected value and resolved evidence dependencies. |
| Retain as blocked inside scope | `BLOCKED_BY_EVIDENCE_GAP` | Preserves the blocker and prevents closure until the expected value and Fields 8–9 dependencies resolve. |

Exact-name retention, context inspection, context details, Docker Engine contact, execution, and output collection remain prohibited.

### `B2-MAN-012` unselected disposition analysis

| Unselected disposition | Classification | Effect |
| --- | --- | --- |
| Reject from current Annex scope | `REJECT_FROM_CURRENT_ANNEX_SCOPE` | Requires explicit Project Owner approval; does not establish nonexistence or permanent rejection. |
| Retain inside Model C under the authoritative deferred state | `BLOCKED_BY_EVIDENCE_GAP` | Keeps `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW`; the row remains a blocker and cannot join a closed executable manifest. |
| Reserve outside the initial scope for a later extension | `RETAIN_DEFERRED_FOR_FUTURE_EXTENSION` | Requires a model or extension decision distinct from Model C’s corrected selected-scope semantics. |

No substitute command, client-only behavior, endpoint, port, or Ollama contact is approved or inferred.

### Blocked no-command rows

| Record | Missing input | Models A/B | Model C |
| --- | --- | --- | --- |
| `B2-BLK-002` | Docker Engine resource/context and safe server-version command | Excluded from selected scope | Retained as `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-BLK-003` | Ollama loopback address, port, endpoint, and non-mutating command | Excluded from selected scope | Retained as `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-BLK-004` | Hermes executable/package/configuration-presence path and syntax | Excluded from selected scope | Retained as `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-BLK-005` | OpenWebUI executable/process or loopback endpoint and command | Excluded from selected scope | Retained as `BLOCKED_BY_EVIDENCE_GAP` |
| `B2-BLK-006` | LM Studio executable/process or loopback endpoint and command | Excluded from selected scope | Retained as `BLOCKED_BY_EVIDENCE_GAP` |

No missing input is supplied.

### Model-specific inventory counts

| Category | Model A | Model B | Model C |
| --- | ---: | ---: | ---: |
| Retained command-manifest rows | 11 | 12 | 13, including one deferred blocker |
| Supporting traceability records | 1 | 1 | 1 |
| Blocked no-command rows inside selected scope | 0 | 0 | 5 |
| Retained interaction records inside documentary scope | 5 | 5 | 11 |
| Execution-authorized command rows | 0 | 0 | 0 |
| Evidence-collection-authorized rows | 0 | 0 | 0 |

## 13. Target-Inventory Impact

| Target | Model A | Model B | Model C |
| --- | --- | --- | --- |
| `TGT-REPO-001` | Inside selected documentary scope | Inside selected documentary scope | Inside selected documentary scope |
| `TGT-WSL-001` | Inside selected documentary scope | Inside selected documentary scope | Inside selected documentary scope |
| `TGT-GIT-WIN-001` | Inside selected documentary scope | Inside selected documentary scope | Inside selected documentary scope |
| `TGT-GIT-WSL-001` | Inside selected documentary scope | Inside selected documentary scope | Inside selected documentary scope |
| `TGT-DOCKER-001` | Client version only; Engine excluded | Client version and conditional context equality; Engine excluded | Client boundary retained; Engine remains inside scope as blocked |
| `TGT-OLLAMA-001` | Excluded from selected scope | Excluded from selected scope | Inside selected scope; client semantics and service interaction remain separate blockers |
| `TGT-HERMES-001` | Excluded from selected scope | Excluded from selected scope | Inside selected scope as blocked |
| `TGT-OPENWEBUI-001` | Excluded from selected scope | Excluded from selected scope | Inside selected scope as blocked |
| `TGT-LMSTUDIO-001` | Excluded from selected scope | Excluded from selected scope | Inside selected scope as blocked |
| `TGT-SUPABASE-001` | Existing prohibition unchanged | Existing prohibition unchanged | Existing prohibition unchanged |
| `TGT-DATABASE-001` | Existing prohibition unchanged | Existing prohibition unchanged | Existing prohibition unchanged |
| `TGT-PRODUCTION-001` | Existing prohibition unchanged | Existing prohibition unchanged | Existing prohibition unchanged |
| `TGT-CREDENTIAL-001` | Existing prohibition unchanged | Existing prohibition unchanged | Existing prohibition unchanged |
| `TGT-EXTERNAL-001` | Existing prohibition unchanged | Existing prohibition unchanged | Existing prohibition unchanged |

Mandatory distinctions:

1. A historical inventory entry is not proof of existence.
2. Inventory presence does not itself establish selected scope.
3. Selected-scope inclusion does not permit interaction.
4. Interaction planning does not authorize command execution.
5. Command planning does not authorize evidence collection.
6. Supporting traceability does not create an executable row.
7. Exclusion does not delete historical evidence.
8. Exclusion does not establish nonexistence.
9. Exclusion does not permanently reject a target.
10. Exclusion does not authorize later interaction.
11. Exclusion affects Fields 1–4 only after an explicit Project Owner readiness-evaluation decision.

## 14. Fields 1–4 Impact Analysis

| Model | Field 1 | Field 2 | Field 3 | Field 4 |
| --- | --- | --- | --- | --- |
| Model A | `POTENTIAL_TO_REDUCE_BLOCKERS` | `POTENTIAL_TO_REDUCE_BLOCKERS` | `POTENTIAL_TO_REDUCE_BLOCKERS` | `POTENTIAL_TO_REDUCE_BLOCKERS` |
| Model B | `POTENTIAL_TO_REDUCE_BLOCKERS` | `BLOCKERS_RETAINED` | `BLOCKERS_RETAINED` | `POTENTIAL_TO_REDUCE_BLOCKERS` |
| Model C | `BLOCKERS_RETAINED` | `BLOCKERS_RETAINED` | `BLOCKED_BY_EVIDENCE_GAP` | `BLOCKED_BY_EVIDENCE_GAP` |

Model A has the greatest potential to narrow Fields 1–4 because it excludes unresolved context, service, endpoint, port, and blocked no-command records from the selected initial scope.

Model B retains the `B2-MAN-011` required revision and expected-value dependency.

Model C is an extended selected documentary scope. Its unresolved Docker Engine, Ollama, Hermes, OpenWebUI, and LM Studio records remain blockers inside that scope. Model C therefore does not represent later consideration outside the selected scope and does not support initial manifest closure without resolving or separately disposing of those blockers.

For this unselected planning package:

`NO_FIELD_STATE_CHANGE_SUPPORTED`

A Project Owner model selection alone does not close Fields 1–4. A separate determination must confirm that the retained target set, command-manifest rows, supporting records, and interaction definitions constitute the complete closed initial-assessment scope.

## 15. Fields 8–11 Preservation

Scope minimization does not resolve:

- evidence paths or access implementation;
- operating-system identities, groups, memberships, ACLs, or effective access;
- classification inheritance;
- actual evidence assignments;
- encryption scope;
- plaintext locations or readers;
- administrator plaintext access;
- verifier decryption authority;
- backup, recovery, replica, or export handling;
- key governance;
- redaction implementation;
- reproduction dependencies;
- criteria-to-evidence dependencies.

| Item | Preserved state |
| --- | --- |
| Field 8 | `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS` |
| Field 9 | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` |
| Field 10 | `APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES` |
| Field 11 | `APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES` |
| Gate | `BLOCKED` |

## 16. Risks and Trade-offs

| Model or risk | Trade-off |
| --- | --- |
| Model A | Minimizes unresolved service dependencies and configuration exposure but may omit local AI platform observations later considered relevant. |
| Model B | Adds bounded Docker context equality planning but retains expected-value and Fields 8–9 dependencies. |
| Model C | Keeps extended local AI targets inside the selected documentary scope, preserving coverage but also preserving unresolved command, client/service, endpoint, port, process, and interaction blockers inside the model. |
| Ollama client/service conflation | `B2-INT-005`, `B2-INT-008`, `B2-MAN-012`, and `B2-BLK-003` must remain separate records with separate gaps. |
| Docker client/Engine conflation | `B2-INT-004` must not imply approval of `B2-INT-007`. |
| Supporting record miscount | `B2-BLK-001` must not be counted as an executable command or interaction. |
| Scope exclusion misread as nonexistence | Historical inventory and exclusion semantics must remain explicit. |
| Scope exclusion misread as permanent rejection | Later consideration still requires separate authorization. |
| Premature manifest closure | A separate completeness determination is required after any scope-model decision. |
| Planning mistaken for execution | Every model remains non-executable and evidence collection remains unauthorized. |

## 17. Project Owner Decisions Required

`PROJECT OWNER DECISION REQUIRED`:

1. Select Model A, Model B, Model C, or a revised model.
2. Decide whether `B2-MAN-010` remains in the selected initial scope.
3. Decide whether `B2-MAN-011` is excluded or retained under the equality-result boundary.
4. Decide whether a Docker context expected comparison value should ever be separately approved.
5. Decide whether `B2-MAN-012` is rejected, excluded for a later extension, or retained inside Model C as a deferred blocker.
6. Decide whether Docker Engine, Ollama, Hermes, OpenWebUI, and LM Studio are excluded under Models A/B or retained as blockers inside Model C’s selected documentary scope.
7. Decide whether excluded targets may return only through a separate Annex extension.
8. Decide whether scope exclusions remove affected rows from the Fields 1–4 initial-readiness evaluation; under Model C, retained unresolved rows remain blockers.
9. Separately determine whether the retained target set, command rows, supporting records, and interaction definitions form the complete closed initial-assessment scope.
10. Decide whether a future Batch 8 decision may be synchronized into the Annex.

## 18. Recommended Next Documentary Action

`RECOMMENDATION_NOT_PROJECT_OWNER_DECISION`

Evaluate:

`MODEL_A_MINIMAL_CORE_SCOPE_IS_PREFERRED_FOR_CURRENT_ANNEX_REVIEW`

This recommendation is not adopted and does not select Model A.

Model A may be preferable for Project Owner consideration because it:

- relies on existing approved manifest planning rows;
- avoids unresolved service-contact, endpoint, and port dependencies;
- reduces configuration-name and sensitive-output exposure;
- does not make local AI platform inventory mandatory for the initial assessment;
- preserves later consideration through a separately authorized extension;
- may narrow Fields 1–4 without claiming that Fields 8–11 are resolved.

Any future decision should separately record:

- selected scope model;
- retained and excluded targets;
- retained command-manifest rows;
- supporting traceability records;
- blocked or deferred records;
- interaction allowlist;
- Fields 1–4 readiness-evaluation effect;
- manifest-completeness determination;
- extension rule;
- synchronization authority.

## 19. Authorization Boundary

This repository artifact remains a non-executable documentary planning package pending Project Owner Batch 8 scope review.

- Documentary review state remains `PENDING_PROJECT_OWNER_BATCH_8_SCOPE_REVIEW`.
- The act of repository creation, staging, commit, or push does not select a scope model.
- Git lifecycle state is repository-history evidence, not package approval state.
- No command or interaction becomes authorized.
- No Field or gate state changes.
- No execution or evidence-collection authority follows.
- Every future modification requires separate explicit Project Owner authorization identifying the exact path and permitted mutation.

Any later decision record, Annex synchronization, status synchronization, staging, commit, or push requires separate authorization.
