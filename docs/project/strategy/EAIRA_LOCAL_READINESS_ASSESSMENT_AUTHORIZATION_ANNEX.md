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
| Decision Authority | Project Owner |
| Planning Task | `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` |
| Date | 2026-07-14 |
| Version | 0.5.0 |

## 2. Purpose

Prepare the single Local Readiness Assessment Authorization Annex required by the Project Owner decision for future separate Project Owner review.

This Annex is a planning artifact only. It does not authorize, execute, simulate, or trial the Local Readiness Assessment. It does not authorize assessment-evidence collection, environment inspection, implementation, remediation, runtime activity, deployment, automation, database mutation, governance modification, production access, milestone establishment, M4, Platform Foundation, or a formal EAIRA Execution Layer.

## 3. Authorization and Traceability

This Annex derives its bounded planning authority from:

- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md`;
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md`.

The underlying authorization-package decision remains `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`. The Batch 1 planning-input decision recorded below does not supersede that execution non-authorization. `AUTHORIZE_BOUNDED_ASSESSMENT` has not been granted. `AUTHORIZE_WITH_REQUIRED_REVISIONS` has not been granted as conditional execution authority.

The Annex addresses the twelve mandatory content areas in Section 6 of the decision record. Every unresolved execution-controlling input remains a blocker and is not converted into an approved fact.

## 4. Evidence Classification Rules

| Classification | Use in this Annex |
| --- | --- |
| `VERIFIED_REPOSITORY_FACT` | Directly supported by cited repository content. |
| `PROJECT_OWNER_DECISION` | Explicitly recorded Project Owner decision. |
| `PROPOSED_NOT_APPROVED` | Candidate input or control requiring separate Project Owner approval. |
| `APPROVED_AS_MANIFEST_PLANNING_INPUT` | Exact manifest content approved as a planning input only; not executable. |
| `APPROVED_WITH_REQUIRED_REVISION_AS_PLANNING_INPUT` | Manifest planning content approved subject to the recorded required control revision; not executable. |
| `DEFER_PENDING_COMMAND_SEMANTICS_REVIEW` | Command is not approved because its client/service behavior remains unresolved. |
| `APPROVED_AS_PLANNING_INTERACTION_DEFINITION` | Interaction boundary approved as planning content only; interaction remains unauthorized. |
| `APPROVED_CONDITIONALLY_AS_PLANNING_INTERACTION` | Planning interaction definition approved only for the recorded future condition; no current interaction authority. |
| `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Required value or decision absent from current repository evidence. |
| `PARTIALLY_RESOLVED_WITH_BLOCKERS` | A control principle is supported, but one or more required inputs remain blocked. |
| `PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING` | Planning boundary and inventory inputs are approved, but exact command-level interactions and controls remain unapproved and blocking. |
| `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | Selected planning inputs are approved, but required revisions, deferrals, or blockers prevent field resolution. |
| `EVIDENCE_GAP` | Information not supported by current repository evidence. |
| `ASSUMPTION` | Planning premise that must not be treated as evidence. |
| `RISK` | Identified safety, evidence, scope, or authority risk. |
| `FUTURE_AUTHORIZATION_REQUIREMENT` | Input that must be explicitly approved before assessment activity. |

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

## 5. Mandatory Field Resolution Matrix

| # | Mandatory field | Resolution state | Current disposition |
| ---: | --- | --- | --- |
| 1 | Exact local environment boundary and complete target inventory | `PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING` | The environment boundary and initial inventory are approved as planning inputs; selected command-level definitions are approved as planning content, but complete command-level controls remain unresolved. |
| 2 | Exact approved tool and command manifest | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | Selected Batch 2 manifest planning inputs are approved, one requires revision, one is deferred, and five target-specific rows remain blocked; no command is executable. |
| 3 | Command-specific arguments, working directory, privilege, target, purpose, expected output, timeout, and mutation-risk determination | `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS` | Selected command-specific planning controls are approved, but required revisions, unresolved semantics, and evidence/redaction dependencies remain blocking. |
| 4 | Approved and prohibited services, endpoints, ports, network actions, and resources | `PARTIALLY_RESOLVED_WITH_BLOCKERS` | Selected no-network interaction definitions are approved as planning inputs; service endpoints, ports, and several resource interactions remain blocked. |
| 5 | Named operator and named independent verifier | `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER` | Batch 1 names the operator, verifier, accountable human owner, and stop authority. |
| 6 | Verifier independence, role separation, and named stop authority | `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER` | Batch 1 approves procedural independence, separation, stop conditions, and restart control. |
| 7 | Observation window, timezone, clock source, freshness, staleness, and rerun rules | `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER` | Batch 1 approves the observation and freshness control framework; an exact future start timestamp still belongs in a separate execution authorization. |
| 8 | Evidence paths, readers, access, integrity, retention, disposal, and stopped-assessment handling | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | No approved evidence location or lifecycle controls exist. |
| 9 | Redaction, sensitive-data taxonomy, secret prohibition, and accidental-exposure procedure | `PARTIALLY_RESOLVED_WITH_BLOCKERS` | Secret capture is prohibited; detailed taxonomy and incident procedure remain unresolved. |
| 10 | Reproduction procedure for every material observation | `PROPOSED_NOT_APPROVED` | A reusable procedure format is proposed below; command-specific procedures remain blocked. |
| 11 | Criteria-to-evidence mapping | `PROPOSED_NOT_APPROVED` | A decision-use mapping framework is proposed below; exact criteria depend on approved targets and commands. |
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

### Current status

`PARTIALLY_RESOLVED_WITH_COMMAND_LEVEL_CONTROLS_PENDING`

The environment boundary and initial target inventory are approved as planning inputs. Field 1 remains blocking because complete exact command-level interactions and controls are not resolved.

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

### Current status

- Field 2: `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`
- Field 3: `PARTIALLY_RESOLVED_WITH_REQUIRED_REVISIONS`

Selected manifest content is approved as planning input only. No manifest row is executable. `B2-MAN-011` retains mandatory Field 9 and evidence-collection dependencies, `B2-MAN-012` is deferred, and Field 8 evidence destinations, Field 9 controls, Field 10 reproduction procedures, and Field 11 mappings remain required.

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

Selected interaction definitions are approved as planning inputs only. Docker engine, Ollama service, Hermes, OpenWebUI, and LM Studio interactions remain blocked. `B2-INT-005` is conditional and does not approve `B2-MAN-012`; no service endpoint or port is approved.

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

### Required Project Owner inputs

The future authorization must define:

- exact evidence root path;
- approved readers and writers;
- access-control method;
- naming and indexing rules;
- file-integrity mechanism;
- provenance requirements;
- retention duration;
- disposal procedure;
- handling of partial, failed, or stopped assessments;
- whether repository storage is prohibited or separately approved;
- whether evidence may leave the named local environment.

### Minimum integrity controls proposed for review

- preserve exact command text and ordered arguments;
- record start and end timestamps and exit status;
- identify operator, verifier, host, target, and manifest ID;
- preserve original direct output before any approved redacted derivative;
- record every redaction without retaining prohibited secret values;
- make missing, partial, conflicting, and unexpected output explicit;
- prevent evidence overwrite or silent replacement;
- record verifier disposition separately from operator notes.

### Current status

`BLOCKED_PENDING_PROJECT_OWNER_INPUT`

## 12. Mandatory Field 9 — Sensitive Data, Redaction, and Accidental Exposure

### Verified repository facts

- Secret-value capture or disclosure is prohibited.
- Assessment activity must stop if credentials or sensitive values are requested or exposed.
- Evidence must not infer or disclose sensitive information outside approved scope.

### Required Project Owner inputs

The future authorization must define:

- sensitive-data taxonomy;
- secret, credential, token, key, personal-data, business-data, and configuration-value categories;
- fields that may be retained as names or presence indicators;
- mandatory redaction method;
- prohibited capture patterns;
- accidental-exposure reporting path;
- quarantine, access restriction, retention, and disposal rules for accidentally exposed material;
- who determines whether safe evidence may be retained.

### Current status

`PARTIALLY_RESOLVED_WITH_BLOCKERS`

Secret capture prohibition is resolved. Detailed taxonomy and accidental-exposure controls remain blocked.

## 13. Mandatory Field 10 — Reproduction Procedure

### Proposed standard procedure format

Every material observation must have a separately approved reproduction record containing:

1. reproduction ID;
2. linked manifest ID;
3. exact environment and target identifiers;
4. exact tool and version;
5. exact command and ordered arguments;
6. exact working directory and privilege level;
7. expected safe output;
8. approved timeout;
9. operator action sequence;
10. timestamp and clock source;
11. exit status and direct-output location;
12. redaction steps;
13. verifier repetition or direct-output inspection steps;
14. discrepancy handling;
15. stop conditions;
16. linked criteria-to-evidence mapping.

### Current status

`PROPOSED_NOT_APPROVED`

The format is available for Project Owner review. No material observation or executable reproduction procedure exists until Fields 1–9 are approved.

## 14. Mandatory Field 11 — Criteria-to-Evidence Mapping

### Decision-use rules

- Tool presence may support only a tool-presence observation.
- Version output may support only the observed version at the recorded time.
- Service status may support only observed service availability, not workload or functional readiness.
- File presence may support only existence at the approved path, not correctness or operational validity.
- Local connectivity may support only the approved connection observation, not end-to-end readiness.
- No single observation may establish Local Readiness, a milestone, implementation authority, Platform Foundation, or an Execution Layer.

### Required mapping schema

| Mapping field | Requirement |
| --- | --- |
| Criterion ID | Stable criterion identifier. |
| Decision question | Exact future decision question informed. |
| Required observation | Exact bounded observation. |
| Manifest ID | Approved command or method. |
| Evidence artifact | Exact approved evidence path and type. |
| Verifier action | Exact independent-verification step. |
| Sufficient result | Exact result that supports the criterion only. |
| Insufficient result | Missing, stale, conflicting, partial, or unexpected result. |
| Non-inference boundary | Conclusions explicitly prohibited from this evidence. |
| Decision use | How the evidence may inform, but not determine, a later decision. |

### Current status

`PROPOSED_NOT_APPROVED`

Exact criterion mappings remain blocked by unresolved target and command inputs.

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
- `PROPOSED_NOT_APPROVED`;
- `EVIDENCE_GAP`;
- `ASSUMPTION`;
- unresolved conflict, exception, ambiguity, or unlisted target.

### Current gate evaluation

`BLOCKED`

Blocking fields: 1, 2, 3, 4, 8, 9, 10, and 11.

Field 12 is resolved only as gate logic; it does not satisfy the gate.

## 16. Consolidated Project Owner Input Queue

The following decisions are required before this Annex can be finalized for an assessment-authorization decision:

1. Resolve complete command-level interactions and controls for every permitted Field 1 target.
2. Complete the required revision for `B2-MAN-011`, resolve or reject deferred `B2-MAN-012`, and resolve the remaining blocked manifest rows.
3. Resolve outstanding command-specific semantics, evidence locations, redaction dependencies, reproduction procedures, and criteria mappings.
4. Resolve the blocked service, endpoint, port, network, and resource interactions while retaining all recorded prohibitions.
5. Approve evidence paths, access roles, integrity controls, retention, disposal, and stopped-assessment handling.
6. Approve sensitive-data taxonomy, redaction method, secret-handling prohibition, and accidental-exposure procedure.
7. Approve the reproduction procedure format and every command-specific procedure.
8. Approve the criteria-to-evidence mappings and non-inference boundaries.
9. Confirm that all mandatory fields, exceptions, conflicts, and ambiguities satisfy the all-fields-resolved gate.

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
| Assessment execution | `UNAUTHORIZED` |
| Assessment-evidence collection | `UNAUTHORIZED` |
| Command execution | `UNAUTHORIZED` |
| Connectivity testing | `UNAUTHORIZED` |
| Port probing | `UNAUTHORIZED` |
| New milestone established | `NO` |
| Implementation or runtime work authorized | `NO` |
| Is this Annex ready for an execution-authorization decision? | No; Project Owner inputs are required. |

## 19. Future Review Requirement

After the mandatory inputs are supplied and every field is explicitly resolved, this Annex must undergo direct file review and independent repository verification, including exact Git status, exact Git diff, and direct reading of the finalized Annex.

The Project Owner must then conduct a separate review and record an unconditional decision. Annex completion, acceptance, silence, conditional language, or approval with unresolved revisions is insufficient to authorize any assessment command, observation, interaction, or evidence collection.

## 20. Source Paths

- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md`
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_001.md`
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md`
- `docs/project/status/CURRENT_STATUS.md`
- `docs/project/status/TODAY_OBJECTIVE.md`
- `docs/project/status/ACTIVE_TASK.yaml`
- `docs/project/context/CURRENT_CONTEXT.md`

## 21. Boundary

This Annex records bounded Project Layer planning only. It does not authorize or perform the Local Readiness Assessment, collect assessment evidence, establish a milestone, establish M4, approve implementation, authorize runtime work, establish Platform Foundation, establish a formal EAIRA Execution Layer, modify governance, authorize deployment, or permit production change.
