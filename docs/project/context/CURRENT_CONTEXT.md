# Current Context

## Purpose

Summarize the current EAIRA working context from repository evidence.

This file is a working-context summary only. It is not an authoritative project record. When conflicts exist, the referenced authoritative repository documents take precedence.

## Current State

Repository evidence supports the following current state:

- M3.2 Context Infrastructure MVP: completed.
- M3.3 Cold Start Validation: completed.
- M3.4 Evidence-Driven AI Organization Slice: completed.
- M3.4 Finance Revenue Input Task Record: `lifecycle_status = Executed`, `completion_decision = APPROVED WITH FINDINGS`.
- M4 Functional Agent MVP is active under the Project Owner decision `docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_AUTHORIZATION_DECISION.md` and charter `docs/project/milestones/EAIRA_M4_FUNCTIONAL_AGENT_MVP_PROJECT_CHARTER.md`.
- The controlling authorization-package decision remains `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`.
- The active product task is `M4-FUNCTIONAL-AGENT-MVP-SLICE-1`. The earlier `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` remains a separate blocked governance workstream.
- Functional-slice R3 is published and independently post-push verified at commit `a10c2ae098bb26455cd9004c0c5a503545a2ef7f`.
- M4 Slice 1 R3R3 is implemented only as an uncommitted local working-tree candidate: strict local CLI task intake, provider-neutral interface, deterministic mock enabled, real provider fail-closed disabled, malformed UTF-16 rejection, profile-derived manifest revision `5`, functional-source System.IO prohibition, an exact three-call service-host source allowlist, and a controlling structured PE metadata policy. Functional harnesses and intake executables permit zero compiled System.IO member references; each service host permits only `System.IO.File::Exists` and `System.IO.Path::IsPathRooted`. Two clean builds are byte-identical; functional tests are exactly `34` per build and intake tests exactly `14` per build. An isolated `File/*split*/.Delete` regression was rejected from compiled metadata. R3R3 manifest SHA-256 is `064698D865D2200A60976F419339FCFDFA18EE0537ABF3FC3A012841B1DFB0BD`; it records both I/O checks passed, external signing eligibility false and Gate 25 incomplete. Independent R3R3 review returned `PASS_WITH_NON_BLOCKING_FINDING`, `P0=0`, `P1=0`, `P2=1`, no blocker, and staging/repository-recording eligibility. The P2 notes that direct PE MemberReference auditing does not cover reflection; exact reviewed source contains no reflection, dynamic activation, or P/Invoke. Exact staging remains pending.
- Main Annex Version `0.33.0`, dated `2026-08-26`, is the current repository publication at commit `24b28a3d94edb79be36eb745b34372ec65af87b1`, parent `351fdeb6591ffe767f0fd8f7e982a7a6cf8bef3d`, blob `9090bedba5d0201ef77e1ab9246fb364631d9452`.
- Independent post-push publication verification on `2026-08-26` established `refs/heads/master` at `24b28a3d94edb79be36eb745b34372ec65af87b1` and determination `POST_PUSH_PUBLICATION_VERIFICATION_PASS`.
- Main Annex Version `0.32.0` and Versions `0.26.0` through `0.31.0` remain version-specific historical publication evidence and do not supersede the current Version `0.33.0` authority baseline.
- Main Annex Versions `0.26.0`, `0.27.0`, `0.28.0`, `0.29.0`, and `0.30.0` remain version-specific historical publication evidence.
- Commit `f317294515d1dc27a261035260e9fcc45e1545f6` is a completed six-file repository-recording fact. The authoritative Project Owner authorization-state decision is `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_F317294_AUTHORIZATION_STATE_DECISION.md`.
- The preserved historical finding is `REPOSITORY_RECORDED_AUTHORIZATION_EVIDENCE_NOT_FOUND`. This finding does not establish that prior authorization definitively never existed; it means only that qualifying repository-recorded evidence was not found within the documented search scope.
- The Project Owner selected `OPTION_B` and retrospectively accepted and retained `f317294515d1dc27a261035260e9fcc45e1545f6` as authorized EAIRA project evidence effective `2026-08-05`, without representing that prior authorization existed or preceded its mutation, commit, or push. No revert is required.
- The Version `0.30.0` six-file authorization was consumed by commit `2ecc2dd841a9581fa59c480bbb1149937b18db85` and does not authorize `f317294515d1dc27a261035260e9fcc45e1545f6`.
- Version `0.27.0`, commit `993a89871e1075f9655300b091c8bf0f9b535478`, blob `703351d3d5ff58c486225773dd30a184c1cc5bef`, remains historical B2-MAN-006 local-verification authorization-package adoption synchronization evidence.
- Main Annex Version `0.28.0`, dated `2026-07-22`, remains historical publication evidence at commit `6768d85c050d50aa52e8f25c7a46accc28977aba`, parent `92e6e1301fbbda4ece47b4ed9fa26970c1358d5b`, blob `7050272035646fd7c2870f77737a1b4a729694c2`. Its response-only independent verification established a clean working tree, the exact one-file Main Annex changed set, matching local and remote `master`, and successful repository-integrity verification through `git fsck --full --no-dangling`; GitHub connector readback remained unavailable with `404 Not Found`, and the verification response is not a repository artifact. That historical Version `0.28.0` connector gap does not apply to Version `0.29.0`, whose GitHub exact-ref readback succeeded.
- The B2-MAN-006 Field 8 / Field 9 documentary prerequisite-package adoption decision is recorded at `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_FIELD_8_FIELD_9_DOCUMENTARY_PREREQUISITE_PACKAGE_ADOPTION_DECISION.md`, initial publication commit `76a84c431f868ef5bfc485618a7f49bc7f7feaab`, bounded canonical-boundary correction commit `92e6e1301fbbda4ece47b4ed9fa26970c1358d5b`, final blob `b98df1da9abcdb99b50ce2f606c57a2f7dc9f2f7`.
- The adoption record classification is `PROJECT_OWNER_B2_MAN_006_FIELD_8_FIELD_9_DOCUMENTARY_PREREQUISITE_PACKAGE_PLANNING_EVIDENCE_ONLY_ADOPTION_DECISION_RECORD`; the standing decision is `APPROVE_B2_MAN_006_FIELD_8_FIELD_9_DOCUMENTARY_PREREQUISITE_PACKAGE_AS_BOUNDED_PLANNING_EVIDENCE_ONLY`; the source form is `RESPONSE_ONLY_PROJECT_OWNER_APPROVED_PACKAGE_TEXT_NOT_A_SEPARATE_REPOSITORY_ARTIFACT`; and the preservation mode is `INLINE_CANONICAL_TEXT_PRESERVATION`.
- The preserved canonical package identity is SHA-256 `9b18443a104895eccd16e33336399bd81deaeea7a3d38b401f695ae56d030071`, byte count `33425`, and line count `860`; the adoption state is `ADOPTED_AS_BOUNDED_PLANNING_EVIDENCE_ONLY_WITHOUT_EXECUTION_AUTHORITY`.
- Phase A is accepted only as the documentary Field 9 policy-closure framework, and Phase B is accepted only as the documentary Field 8 evidence-control specification framework. The earlier prerequisite package did not itself select its individual proposed matrix values or decision options.
- The later 2026-07-23 decisions are recorded at `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_PRE_EXECUTION_DOCUMENTARY_CLOSURE_DECISION.md`, `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_LOCAL_IDENTIFICATION_PACKAGE_ADOPTION_DECISION.md`, and `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_STAGE_2_LOCAL_IDENTIFICATION_PACKAGE_ADOPTION_DECISION.md`. They separately select named documentary directions and adopt the local-identification and Stage 2 packages only as bounded planning evidence.
- General Field 8 documentary selections are `ACL-A`, `ENC-A`, `INT-A`, `XFER-A`, and `SESSION_OPERATOR != INDEPENDENT_VERIFIER`. General Field 9 documentary direction comprises the item-level classification and handling matrix, exact redaction tokens `<ABSOLUTE_WINDOWS_PATH_REDACTED>`, `<ABSOLUTE_WSL_PATH_REDACTED>`, `<WINDOWS_USER_REDACTED>`, `<WSL_USER_REDACTED>`, `BRANCH-###`, `PATH-###`, `<REPOSITORY_URL_REDACTED>`, `<SECRET_REDACTED>`, `<PII_REDACTED>`, and `<ENVIRONMENT_VALUE_REDACTED>`, `DIAG-A`, `RET-A`, `NQ-A`, and no external automated notification or upload.
- The narrower Stage 2 package-local planning model is `CONSOLE_ONLY_LOCAL_REVIEW_WITHOUT_PERSISTED_EVIDENCE`. Its planning parameters are `EPS-1`, `LI-ALLOWLIST-1`, proposed WSL distribution `Ubuntu`, administrator elevation `NOT_AUTHORIZED`, network action `NONE`, retry authority `NONE`, timeout `30 seconds`, and `UNACTIVATED_PROPOSED_EXECUTION_WINDOW`.
- `LI-ALLOWLIST-1` authorizes no command and excludes every `git status` command, including the retained B2-MAN-006 logical command and future B2-MAN-006 status-command envelope, as well as `git fsmonitor--daemon status`.
- None of these directions is implemented, activated, executed, or evidence of a local fact. The general Field 8 and Field 9 framework and the narrower Stage 2 model neither repeal, implement, activate, nor execute one another.
- The B2-MAN-007 local-verification authorization-package adoption decision is recorded at `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_007_LOCAL_VERIFICATION_AUTHORIZATION_PACKAGE_ADOPTION_DECISION.md`, commit `9d16989125b147ea0ac749bfe8ecf5573be881f7`, blob `ba4aadff5b2226e68439dff313c6325dad91b2f7`, classification `PROJECT_OWNER_B2_MAN_007_LOCAL_VERIFICATION_AUTHORIZATION_PACKAGE_PLANNING_EVIDENCE_ONLY_ADOPTION_DECISION_RECORD`, standing decision `ADOPT_B2_MAN_007_COMPLETE_CORRECTED_REPLACEMENT_PACKAGE_AS_BOUNDED_PLANNING_EVIDENCE_ONLY_WITHOUT_EXECUTION_AUTHORITY`, and adoption state `ADOPTED_AS_BOUNDED_PLANNING_EVIDENCE_ONLY_WITHOUT_EXECUTION_AUTHORITY`.
- Its source SHA-256 is `c931389a5b46972030addf4f4b35b63f6a7d6a7e8fdce31fac47f4e4a4a7a5fe`; inline canonical SHA-256 is `6d9a3d407bf29a67e7ae27d3f8ec65e42f38566e50dc42fadd0d704a289a1ce5`; preservation mode is `INLINE_CANONICAL_TEXT_PRESERVATION`; and post-recording verification is `VERIFIED_REPOSITORY_RECORD_READY_FOR_SEPARATE_IMPACT_REVIEW`.
- The B2-MAN-007 category-disposition decision is `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_007_CATEGORY_BY_CATEGORY_DOCUMENTARY_DISPOSITION_DECISION.md`, recording commit `50f48cd4822aa92682ed213b7c7c0702e083413a`, blob `9457aad0e6509fde3f0581d44e4385bd8ac82c1e`, classification `PROJECT_OWNER_B2_MAN_007_CATEGORY_BY_CATEGORY_DOCUMENTARY_DISPOSITION_DECISION_RECORD`, and standing decision `APPROVE_B2_MAN_007_CATEGORY_BY_CATEGORY_DOCUMENTARY_DISPOSITIONS_WITH_ALL_CATEGORIES_REMAINING_UNSATISFIED_WITHOUT_EXECUTION_EVIDENCE_FIELD_GATE_OR_REPOSITORY_MUTATION_AUTHORITY`.
- All sixteen B2-MAN-007 categories remain unsatisfied; B2-MAN-007 remains an unresolved substantive blocker.
- The B2-MAN-007 Field 8 model-selection decision is recorded at commit `6fabe4a93110fc894f5588cc5502004ea48b45a6`, blob `0487e127912d27bffd3f5f1cc96c6bcd33796664`, selecting `B7-EPS-1` only as the documentary evidence-persistence model.
- The Revision 2 required-implementation-details candidate is recorded and remotely present at commit `351fdeb6591ffe767f0fd8f7e982a7a6cf8bef3d`, blob `49dd0e988a8201c977428d160c887fdda845242d`, SHA-256 `533ec64b919eff464b6f6516808d68311a31a79e4804dea50f100eef0a2b477c`. It records nineteen documentary binding targets under provisional overlay `B7-EPS-1-BINDING-1`.
- Independent review on `2026-08-26` found the repository facts suitable for evidence-only status synchronization but retained a blocking governance-closeout finding: the candidate's embedded Project Owner disposition and independent-review markers are not closed by tracked repository evidence.
- Field 8 remains `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`; Field 9 package preparation remains separately authorized but is not established as completed.
- Main Annex Version `0.30.0` downstream impact review determined that exactly six current-state and task artifacts required documentary synchronization. This synchronization changes no command, reproduction record, mapping, acceptance count, Field, blocker, gate, task, milestone, execution marker, or authority boundary.
- Version `0.29.0` historical downstream synchronization evidence is commit `93d5d9cbb3fcb9ab02f589bae2d2c1541a72f380`, parent `a2587cfbe59f6247be8b43941f6f8d3514c4b731`, with exactly six changed paths, `91` insertions, and `34` deletions.
- The Version `0.29.0` historical synchronization blobs are `CURRENT_CONTEXT.md` `b18135f4d2293f12d9640f5869ed97c210d16d76`; `CURRENT_STATUS.md` `c33afd513840624cd1e02869bb51d19672420dc2`; `TODAY_OBJECTIVE.md` `bd9cbb4295b735641533f40ace30db9045b182ab`; `ACTIVE_TASK.yaml` `b46ed89c9bba10d263630a8c739acc7f6cb4f7d8`; `AGENT_CONTEXT_VERSION.yaml` `cd07bcd0f07c0bdf7ec6e3546af84db5607de1dc`; and `LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md` `2806f4596b9c2c821b6a940b1087f7d0688e2653`. These are historical commit-scoped blobs, not Version `0.30.0` or current default-branch blobs.
- Response-only independent Version `0.29.0` post-publication verification established matching local `HEAD` and remote `master` at `93d5d9cbb3fcb9ab02f589bae2d2c1541a72f380`, a clean local working tree, the exact six-file changed set, all six remote blobs, and successful GitHub exact-ref readback. The verification response is not a repository artifact.

## Current Milestone

The latest completed milestone evidence remains M3, including the completed M3.4 Evidence-Driven AI Organization Slice.

M4 Functional Agent MVP is established, but only its first bounded offline slice is locally implemented. Platform Foundation, a formal EAIRA Execution Layer, Windows-service task routing, real-model integration, persistence, deployment capability, and production multi-agent runtime are not established.

## Current Planning Models

- Batch 7 Model B remains `SELECTED_AS_DOCUMENTARY_CLASSIFICATION_MODEL_ONLY`; no actual data or evidence classification occurred.
- Batch 8 Model A remains `SELECTED_AS_INITIAL_DOCUMENTARY_SCOPE_MODEL`.
- Batch 7 Model B and Batch 8 Model A are separate documentary model namespaces and do not modify, replace, or reopen one another.
- The selected initial scope remains Repository, WSL, Windows Git, WSL Git, and Docker limited strictly to `B2-MAN-010`.
- Docker Engine beyond `B2-MAN-010`, Ollama, Hermes, OpenWebUI, and LM Studio require a mandatory separate Project Owner-authorized extension.
- The only permitted future readiness claim remains `INITIAL_MINIMAL_CORE_SCOPE_READINESS`.
- Initial-scope completeness remains `DOCUMENTARY_INITIAL_SCOPE_COMPLETENESS_DETERMINATION_ONLY`.

## Acceptance and Field States

- Shared WSL Git requirements: `0` satisfied of `22`.
- Shared WSL Git acceptance categories: `0` of `20`.
- B2-MAN-006 acceptance categories: `0` of `6`.
- B2-MAN-007 acceptance categories: `0` of `16`.
- B2-MAN-013 row criteria: `0` satisfied.
- B2-MAN-013 Route C acceptance categories: `0` of `20`.

Field states remain exactly:

- Field 1: `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER`, limited to mandatory Annex pre-execution documentary planning completeness.
- Field 2: `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`.
- Field 3: `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`.
- Field 4: `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER`, limited to mandatory Annex pre-execution documentary planning completeness.
- Fields 5, 6, and 7: `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER` as preservation-only states.
- Field 8: `PARTIALLY_RESOLVED_WITH_REQUIRED_IMPLEMENTATION_DETAILS`.
- Field 9: `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`.
- Field 10: `APPROVED_AS_PLANNING_CONTROL_WITH_FIELD_8_AND_9_DEPENDENCIES`.
- Field 11: `APPROVED_AS_PLANNING_CONTROL_WITH_EVIDENCE_DEPENDENCIES`.
- Field 12: `RESOLVED_AS_CONTROL`.

The all-fields-resolved gate remains `BLOCKED`.

## Current Blockers

The substantive blockers remain exactly:

- `B2-MAN-006`;
- `B2-MAN-007`;
- `B2-MAN-010`; and
- `B2-MAN-013`.

B2-MAN-006 remains unresolved and non-executable. Its historical/current logical command remains separate from the selected future non-executable documentary envelope. Package adoption does not establish an executable path, configuration state, non-mutation result, output compatibility, Field 8 compliance, or Field 9 compliance.

B2-MAN-007 remains unresolved and non-executable. Its executable, repository, object, network, credential, configuration, output, delimiter, non-mutation, Field 8, and Field 9 dependencies remain open.

B2-MAN-010 remains blocked under its version-scoped documentary boundary; no local Docker executable, version, configuration, endpoint, telemetry, Engine, or network fact is established.

B2-MAN-013 remains `UNRESOLVED_SUBSTANTIVE_BLOCKER`; Route C targets and operations remain future and unauthorized, Route B remains conditional and unauthorized, and all local applicability dependencies remain unresolved.

## Current Decisions and Lifecycle

The durable Annex lifecycle remains controlling:

1. Preserve completed Annex versions as version-specific historical evidence.
2. Resolve current publication from Section 1 metadata in the publication commit under independent verification.
3. Treat package preparation, Project Owner disposition, canonical freeze, repository recording, publication, verification, impact review, and synchronization as separate documentary stages.
4. Require separate Project Owner authority for local executable discovery, local inspection, actual verification, option testing, command execution, evidence collection, criterion evaluation, blocker disposition, Field review, gate evaluation, and any later execution stage.

Assessment execution, command execution, local inspection, connectivity testing, port probing, evidence-directory or evidence-file creation, ACL and identity configuration, encryption configuration, hashing, redaction, retention, disposal, implementation, runtime, deployment, database, production, and governance activity remain `UNAUTHORIZED`.

## Current Planning Direction

Version `0.30.0` downstream synchronization completed at commit `0d0185738309f58d64f143f93cf9e7917d12aa1e`, parent `f7408802a0fba79bdaf81684683d213df217075b`, with exactly six modified paths, `59` additions, and `47` deletions. It updates only current-state and task artifacts to the independently verified Main Annex Version `0.30.0` publication and the independently verified B2-MAN-007 planning-evidence adoption record.

Formatting correction completed at commit `cd512bd4eb4c8ab2b7897192baf453ef20c7be56`, parent `0d0185738309f58d64f143f93cf9e7917d12aa1e`. Only `CURRENT_CONTEXT.md` and `ACTIVE_TASK.yaml` changed; the correction was formatting-only and made no semantic project-state change.

The final verified remote ref is `cd512bd4eb4c8ab2b7897192baf453ef20c7be56`. Its six final blobs are `CURRENT_CONTEXT.md` `4938e06929810a93ba198f74efec1772132397d1`; `CURRENT_STATUS.md` `da8b056fa08a0343bdaad86607139041b08d01de`; `TODAY_OBJECTIVE.md` `3049f901d300c45748c3a95c020412a6493da9fb`; `ACTIVE_TASK.yaml` `612aab2742a429d8de7945172f8b2cd29fdec012`; `AGENT_CONTEXT_VERSION.yaml` `a355164baac10e2127e3b9a158342b528bcd0e13`; and `LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md` `6c59a6f5399eda80f8c3f25772715593a9a873cd`.

The remote-chain verification outcome is `VERSION_0_30_0_DOWNSTREAM_CHAIN_VERIFIED_WITH_RECORDED_LOCAL_STATE_LIMITATIONS`. Live GitHub `master`, remote ancestry, changed-file sets, final endpoint, and blobs were verified. Codex reported a stale local `HEAD`, stale cached `origin/master`, and unrelated untracked `.claude/settings.local.json`; those local-state facts were not independently verified. No claim is made that local and remote were equal or that the local working tree was clean.

The Version `0.30.0` downstream chain remains historical evidence. Its six-file authorization was consumed by commit `2ecc2dd841a9581fa59c480bbb1149937b18db85` and does not authorize `f317294515d1dc27a261035260e9fcc45e1545f6`. The historical predecessor identity does not supersede the current Version `0.33.0` authority baseline.

The evidence-only six-file current-state synchronization for Version `0.32.0` was authorized and materialized on `2026-08-26` and remains precursor working-tree evidence.

The Project Owner accepted Revision 2 Option A, authorized the exact Main Annex mutation and commit, and separately authorized a normal non-force push. Claude independently reviewed the candidate, verified the post-mutation object, and verified the GitHub publication. Version `0.33.0` now records the case-first documentary extension without activating or implementing it.

The Project Owner subsequently authorized sequential execution of the ten remaining lifecycle gates with fail-closed preconditions. This authorization does not itself establish local evidence or satisfy a Field, category, blocker, or gate. The immediate next gate is local identity, path, capability, backup, encryption, ACL, and WSL evidence collection. Field 8 remains partial, Category 14 remains unsatisfied, B2-MAN-007 remains `0` of `16`, and the gate remains `BLOCKED`.

That local evidence gate completed read-only on `2026-08-26` with `FAIL_CLOSED_BLOCKED`. At that historical point, `C:\EAIRA\Evidence`, its WSL access form, and the five proposed groups did not exist. Later authorized group creation and administrator reconciliation established that the five approved groups now exist and are empty. Exact service identities and role assignments, ACL translation, effective-access proof, encryption implementation, backup-copy absence, and Field 9 implementation rules remain incomplete.

The 2026-09-01 controlled-state reconciliation confirms that Gate 19 through Gate 23 bounded preparation and independent review are complete. Gate 24 is partial: the official .NET Framework 4.8 Developer Pack and Windows SDK SignTool are available, but the legal signing identity, provider, certificate acquisition, compliant non-exportable cloud-HSM key, and release signing remain deferred. That evidence did not itself establish a milestone; M4 was established separately on 2026-09-02. Neither the reconciliation nor M4 Slice 1 establishes service readiness, production readiness, Field transition, category satisfaction, blocker closure, or all-fields gate passage.

## Authoritative Sources

| Question | Source |
| --- | --- |
| Current publication | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX.md` |
| B2-MAN-007 Field 8 model selection | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_007_FIELD_8_DOCUMENTARY_MODEL_SELECTION_DECISION.md` |
| B2-MAN-007 Field 8 Revision 2 candidate | `docs/project/strategy/B2_MAN_007_FIELD_8_REQUIRED_IMPLEMENTATION_DETAILS_SELECTION_DECISION.md` |
| F317294 authorization-state decision | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_F317294_AUTHORIZATION_STATE_DECISION.md` |
| B2-MAN-007 category dispositions | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_007_CATEGORY_BY_CATEGORY_DOCUMENTARY_DISPOSITION_DECISION.md` |
| B2-MAN-006 package adoption | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_LOCAL_VERIFICATION_AUTHORIZATION_PACKAGE_ADOPTION_DECISION.md` |
| B2-MAN-006 Field 8 / Field 9 prerequisite adoption | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_FIELD_8_FIELD_9_DOCUMENTARY_PREREQUISITE_PACKAGE_ADOPTION_DECISION.md` |
| B2-MAN-006 pre-execution documentary closure | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_PRE_EXECUTION_DOCUMENTARY_CLOSURE_DECISION.md` |
| B2-MAN-006 local-identification package adoption | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_LOCAL_IDENTIFICATION_PACKAGE_ADOPTION_DECISION.md` |
| B2-MAN-006 Stage 2 package adoption | `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_B2_MAN_006_STAGE_2_LOCAL_IDENTIFICATION_PACKAGE_ADOPTION_DECISION.md` |
| Current status | `docs/project/status/CURRENT_STATUS.md` |
| M4 decision and charter | `docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_AUTHORIZATION_DECISION.md` and `docs/project/milestones/EAIRA_M4_FUNCTIONAL_AGENT_MVP_PROJECT_CHARTER.md` |
| Active task | `docs/project/status/ACTIVE_TASK.yaml` and `docs/project/planning/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_1_TASK.md` |
| Retained blocked Annex task | `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md` |
| Historical validation constraints | `docs/tasks/M3_4_FINANCE_REVENUE_INPUT_TASK_RECORD.md` |

## Boundary

`CURRENT_CONTEXT.md` is a Project Layer working-context summary only. It does not itself define governance, modify the context contract, approve a milestone, authorize implementation or execution, establish automation, create a SYSTEM layer, establish Platform Foundation, or establish a formal EAIRA Execution Layer. M4 authority comes only from its separately recorded Project Owner decision.
