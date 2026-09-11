# EAIRA M4 Closeout Readiness and M5 Scope Decision Package

## 1. Document Control

| Field | Value |
| --- | --- |
| Package ID | `EAIRA_M4_CLOSEOUT_READINESS_AND_M5_SCOPE_DECISION_PACKAGE_V1` |
| Date | 2026-09-12 |
| Classification | `PROJECT_OWNER_AUTHORIZED_PLANNING_CANDIDATE_ONLY` |
| Package state | `CANDIDATE_READY_FOR_INDEPENDENT_REVIEW` |
| M4 closeout decision | `NO_SELECTION_RECORDED` |
| M5 scope decision | `NO_SELECTION_RECORDED` |
| Repository baseline | `023592cd62b1cd2f1efa94ab66f43817b43e07d3` |
| Cached remote baseline | `origin/master = 023592cd62b1cd2f1efa94ab66f43817b43e07d3` |
| Exact candidate path count | `1` |

This package was prepared under
`SEPARATE_PROJECT_OWNER_EAIRA_M4_CLOSEOUT_READINESS_AND_M5_SCOPE_DECISION_AUTHORIZATION`.
It records a read-only assessment and decision options. It does not close M4,
select M5, authorize implementation, or change any controlled project state.

## 2. Exact Candidate Manifest

The complete repository mutation candidate is this one new planning path:

1. `docs/project/planning/EAIRA_M4_CLOSEOUT_READINESS_AND_M5_SCOPE_DECISION_PACKAGE.md`

No existing product, strategy, status, context, memory, HANDOFF, release-profile,
build, test, `.obsidian`, integration, or repository-root test path is in this
candidate.

## 3. Authority and Evidence Boundary

The assessment may rely on repository content and Git metadata at the baseline,
but it does not infer authority from a memory note, generated evidence, working
tree content, or this package itself. `CURRENT_STATUS.md`, `TODAY_OBJECTIVE.md`,
`ACTIVE_TASK.yaml`, and `AGENT_CONTEXT_VERSION.yaml` remain authoritative for
current state. `CURRENT_CONTEXT.md` is context, and `HANDOFF.md` is provisional.

The following remain unauthorized:

- product implementation or behavior change;
- Windows, service, IPC, account, group, membership, ACL, encryption, certificate,
  signing, HSM, external-provider, credential, deployment, or production change;
- staging, commit, push, force push, tag, branch, or Git maintenance;
- changes to the M4 charter, Slice decisions, controlled status, CURRENT_CONTEXT,
  HANDOFF, project memory, or release profile; and
- repair of unrelated untracked paths or Codex checkpoint references.

## 4. Sources Reviewed

### 4.1 Controlling and current-state sources

- `AGENTS.md`;
- `docs/project/status/README.md`;
- `docs/project/status/CURRENT_STATUS.md`, Version `0.37.43`;
- `docs/project/status/TODAY_OBJECTIVE.md`, Version `0.36.44`;
- `docs/project/status/ACTIVE_TASK.yaml`;
- `docs/project/status/AGENT_CONTEXT_VERSION.yaml`, Context Version `0.28.44`;
- `docs/project/context/CURRENT_CONTEXT.md`;
- `docs/project/memory/README.md`; and
- `docs/project/memory/HANDOFF.md` as non-authoritative continuation context only.

### 4.2 M4 governance and product sources

- `docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_AUTHORIZATION_DECISION.md`;
- `docs/project/milestones/EAIRA_M4_FUNCTIONAL_AGENT_MVP_PROJECT_CHARTER.md`;
- the Slice 1 task and Slice 2 through Slice 5 scope decisions;
- the six published contracts under `apps/agent-services/contracts/`;
- `apps/agent-services/README.md`;
- `apps/agent-services/release/gate25-unsigned-release-profile.json`; and
- Git commit, parent, tree, subject, local `HEAD`, and cached `origin/master`
  metadata for the Slice publications and current endpoint.

No external source or provider result is used by this package.

## 5. M4 Charter Objective Assessment

The M4 charter objective is to move EAIRA from a verified offline five-Agent
contract to a locally invocable, provider-neutral, no-write functional MVP while
preserving fail-closed production and security boundaries.

| Charter outcome | Repository evidence | Assessment |
| --- | --- | --- |
| Five-Agent functional flow | `EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1` defines Planning, Guard, Operations, Verification, and Audit allowed and denial flows with digest-linked handoffs. | `SATISFIED_FOR_M4` |
| Strict local task intake | Slice 1 publishes `EAIRA.AgentTask.Cli.exe` contract behavior, canonical output, bounded errors, mock enablement, and disabled real-provider fail-closed behavior. | `SATISFIED_FOR_M4` |
| Provider-neutral boundary | Mock and disabled-real boundaries remain; Slice 2 adds exact `ollama-local` / `qwen3:4b` loopback selection without external credentials. | `SATISFIED_FOR_M4` |
| No-write and fail-closed execution | Contracts and release profile retain `writes=NONE`, bounded exits, denial-before-read/provider behavior, no IPC, and no runtime child process. | `SATISFIED_FOR_M4` |
| Bounded current project context | Slice 3 publishes a request-local read-only snapshot of exactly four controlled status artifacts for Planning only. | `SATISFIED_ADDITIONAL_CAPABILITY` |
| Bounded project-memory lookup | Slice 4 publishes deterministic literal search over exactly seven navigation/schema files with `NAVIGATIONAL_NOT_AUTHORITY`. | `SATISFIED_ADDITIONAL_CAPABILITY` |
| Bounded local project QA | Slice 5 composes the published loopback provider, controlled context, and project knowledge into a no-write assistive QA surface with host-validated citations. | `SATISFIED_ADDITIONAL_CAPABILITY` |
| Deterministic technical evidence | Latest Slice 5 evidence binds two byte-identical builds, 484 stable-name tests, 36 abuse specimens, and a bounded successful live loopback validation. | `SATISFIED_FOR_M4` |
| Independently verified publication | Slice 1 through Slice 5 product commits and their subsequent state synchronization lifecycles are recorded as published and independently verified. | `SATISFIED_FOR_M4` |

## 6. Slice 1–5 Publication Ledger

| Slice | Capability | Product commit | Publication state |
| --- | --- | --- | --- |
| 1 | strict task intake and provider-neutral five-Agent mock MVP | `96573f8b570d39df1e7d7498f361a94783086cb0` | independently post-push verified |
| 2 | bounded Ollama loopback provider for exact `qwen3:4b` | `d43a4bc170df38e29f6115e927ad2c07190da821` | published and independently post-push verified |
| 3 | exact four-file read-only controlled project context | `a0e172f34ebc09f76e1bd894d680614ed901113d` | published and independently live-remote verified |
| 4 | exact seven-file bounded project-memory knowledge query | `8fefd6b7bb2369b80724270b64e74d33a7e1aa9f` | published and independently live-remote verified |
| 5 | bounded local project QA over the eleven allowed sources | `3945baaa3a63f8dba51a474ee36a6ad827d94817` | published and independently live-remote verified |

The current controlled-state endpoint is
`023592cd62b1cd2f1efa94ab66f43817b43e07d3`. At package preparation time,
local `HEAD` and cached `origin/master` both equal that endpoint.

## 7. Current Agent Capability Inventory

EAIRA currently provides these bounded local capabilities:

1. deterministic five-role Agent flow with fail-closed Guard denial and Audit
   participation;
2. strict command-line task intake with canonical JSON and sanitized error exits;
3. deterministic offline mock execution;
4. one exact local Ollama loopback provider selection for `qwen3:4b`;
5. request-local read-only extraction of the four controlled status artifacts;
6. literal, deterministic query of seven project-memory navigation/schema files;
7. one bounded local project-QA command with model-output validation,
   host-reconstructed citations, and explicit non-authority labels;
8. five separately built Agent service host scaffolds and offline self-tests; and
9. a hash-bound unsigned-release build and verification profile.

These are local engineering MVP surfaces. They are not yet one installed,
operational, customer-distributable EAIRA service product.

## 8. Product Gaps Preserved Beyond M4

### 8.1 Integration gaps

- The task-intake, project-context, project-knowledge, and project-QA CLIs are
  separate local surfaces rather than one unified operator workflow.
- The five Agent service hosts are not wired to the CLIs through an authorized
  transport or orchestrator.
- No authorized service IPC, authentication, lifecycle controller, health model,
  restart policy, or service-to-service authorization exists.

### 8.2 Customer and operational gaps

- No customer installer, upgrade, rollback, uninstall, configuration, support,
  telemetry, tenancy, or compatibility contract exists.
- The release binaries are unsigned; legal signing identity, provider,
  certificate, compliant non-exportable cloud-HSM key, and release signing are
  deferred.
- The five local groups are empty and do not establish service identities,
  memberships, directories, or ACL readiness.
- Production encryption, backup/recovery boundaries, Field 8 evidence, Field 9
  handling, and the separate Annex readiness gate remain unresolved.

### 8.3 Provider and trust gaps

- The only enabled model path is a trusted-local-host, unauthenticated loopback
  Ollama endpoint. Name and digest checks are consistency controls, not
  cryptographic endpoint or model attestation.
- No external provider, credential broker, tenant isolation, secret lifecycle,
  egress policy, or provider-side retention control is authorized.

### 8.4 Evidence and maintenance gaps

- The authoritative `ACTIVE_TASK.yaml` still names the phase-stable Slice 5
  synchronization repository-recording lifecycle and its prior verification
  gate, while Git and the later independent evidence place the endpoint at
  `023592cd62b1cd2f1efa94ab66f43817b43e07d3`. This is a required closeout
  controlled-state reconciliation item; this planning package does not overwrite
  it or infer a milestone transition.
- The release profile still carries the label `0.3.0-m4.3-r3` while containing
  later Slice 4 and Slice 5 controls. This is non-blocking for M4 functional
  closeout but must be resolved before relying on the label for customer
  packaging or release-version semantics.
- Some durable Slice scope documents preserve candidate-stage “Current
  Determination” wording. Controlled status is authoritative and records the
  later publication, but a later documentary hygiene gate should decide whether
  to freeze those passages as historical or append explicit completion notes.
- Eighteen overlong Codex checkpoint references may trigger Windows legacy
  `MAX_PATH` or repack warnings. Existing publication verification records them
  as non-blocking; repair is outside this package.

None of these gaps invalidates the bounded M4 functional-MVP evidence. They do
prevent interpreting M4 closeout as production, signing, deployment, or customer
distribution readiness.

## 9. M4 Closeout Readiness Determination

Package determination:

`READY_FOR_INDEPENDENT_M4_CLOSEOUT_REVIEW_WITH_NON_BLOCKING_M5_AND_PRODUCTION_GAPS`

The evidence supports an M4 closeout decision because the chartered functional
MVP objective and safety boundary are met and all five product slices are
published. M4 remains formally `Active` until both of the following occur:

1. a separate independent review confirms this package, the current endpoint,
   and the M4 criterion mapping with no P0 or P1 finding; and
2. the Human Project Owner separately selects an M4 closeout disposition and an
   M5 scope option.

This determination does not itself update the milestone or active task.

## 10. M4 Closeout Decision Options

### `M4_CLOSEOUT_A_APPROVE_WITH_NON_BLOCKING_CARRY_FORWARD` — recommended

Close M4 as a completed bounded functional MVP. Carry Section 8 into M5 and the
separate production-readiness workstream without treating any item as completed.

### `M4_CLOSEOUT_B_APPROVE_AFTER_BOUNDED_DOCUMENTARY_REMEDIATION`

First correct release-version and durable-document lifecycle wording, independently
review the exact documentary candidate, and then close M4. No product behavior
changes are implied.

### `M4_CLOSEOUT_C_DEFER`

Keep M4 active and require the Project Owner to state additional M4 acceptance
criteria. Existing Slice publications remain valid and unchanged.

No option is selected by this package.

## 11. M5 Scope Options

### `M5_A_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW` — recommended

Build a user-mode, least-authority integrated local product around the existing
published capabilities before activating Windows services or customer signing.
The first M5 slice would define one canonical local entry point and explicit
capability routing across task intake, controlled context, knowledge query, QA,
and the five-Agent flow. It would retain no-write behavior, the existing Guard,
local loopback only, no credentials, no service mutation, and no production
claim. Later separately authorized slices could add secure IPC/service hosting,
bounded encrypted persistence, and customer packaging.

Benefits: closes the largest present product gap, produces demonstrable user
value, and postpones certificate cost and privileged Windows changes until the
runtime boundary is stable.

Primary risks: integration can accidentally widen data flow or bypass role and
Guard separation; exact routing, output, abuse, and provenance policies must be
designed before implementation.

### `M5_B_CUSTOMER_PACKAGING_AND_SIGNING_FIRST`

Prioritize installer, signed binaries, upgrade/uninstall, and customer release
mechanics before runtime integration.

This is not presently recommended because legal signing details, certificate/HSM,
service identity/ACL, and customer support boundaries remain unresolved. It may
create packaging around interfaces that still change during integration.

### `M5_C_EXTERNAL_PROVIDER_AND_CREDENTIAL_BOUNDARY_FIRST`

Prioritize a cloud/external model provider, credential brokerage, egress control,
and provider data-governance policy.

This is not presently recommended because it adds secret, network, tenant,
retention, and vendor-risk surfaces before the local integrated workflow is
established.

### `M5_D_PAUSE_AFTER_M4`

Close M4 and start no M5 product work. Preserve all current boundaries while the
separate Annex, signing identity, or business decisions are resolved.

No M5 option is selected by this package.

## 12. Recommended M5-A Slice Sequence

This is a planning outline only; each slice requires a later scope decision,
exact design, independent review, implementation authorization, sealed evidence,
and repository lifecycle authorization.

1. `M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR` — one canonical entry point,
   capability routing, and end-to-end five-Agent ownership without services.
2. `M5_SLICE2_SECURE_LOCAL_TRANSPORT_CONTRACT` — specify and verify identity,
   message, replay, timeout, and fail-closed IPC controls before activation.
3. `M5_SLICE3_BOUNDED_ENCRYPTED_LOCAL_STATE` — only if product requirements need
   persistence; decide data classes, retention, backup, recovery, and key custody.
4. `M5_SLICE4_WINDOWS_SERVICE_AND_ACL_ACTIVATION` — consume separately verified
   service identities, group memberships, directories, ACLs, and operational
   runbooks.
5. `M5_SLICE5_CUSTOMER_PACKAGE_AND_SIGNED_PILOT` — only after Gate 24 signing,
   versioning, installer, rollback, and support prerequisites pass.

M5 Slice 1 can be planned without authorizing any privileged Windows or external
provider change. Slices 2 through 5 are dependencies, not pre-authorizations.

## 13. Proposed Immediate Gate Sequence

Only Gate 1 is eligible after this candidate is prepared:

1. `SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_READINESS_AND_M5_SCOPE_DECISION_PACKAGE_REVIEW`
2. `SEPARATE_PROJECT_OWNER_EAIRA_M4_CLOSEOUT_AND_M5_SCOPE_DECISION`
3. `SEPARATE_PROJECT_OWNER_EAIRA_M4_CLOSEOUT_AND_M5_CHARTER_PACKAGE_PREPARATION_AUTHORIZATION`
4. `SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_AND_M5_CHARTER_PACKAGE_REVIEW`
5. `SEPARATE_PROJECT_OWNER_EAIRA_M4_CLOSEOUT_CONTROLLED_STATE_SYNCHRONIZATION_AUTHORIZATION`
6. `SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_CONTROLLED_STATE_SYNCHRONIZATION_REVIEW`
7. `SEPARATE_PROJECT_OWNER_EAIRA_M4_CLOSEOUT_EXACT_STAGING_AUTHORIZATION`
8. `SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_STAGED_REVIEW`
9. `SEPARATE_PROJECT_OWNER_EAIRA_M4_CLOSEOUT_EXACT_COMMIT_AUTHORIZATION`
10. `SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_POST_COMMIT_VERIFICATION`
11. `SEPARATE_PROJECT_OWNER_EAIRA_M4_CLOSEOUT_NORMAL_PUSH_AUTHORIZATION`
12. `SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_POST_PUSH_PUBLICATION_VERIFICATION`
13. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_SCOPE_PACKAGE_AUTHORIZATION`

The sequence must stop fail-closed on any P0 or P1 finding. Remediation gates may
be inserted when independently required; their existence does not grant their
authority in advance.

## 14. Exact Project Owner Decision Fields Required Later

A future decision must state both values explicitly:

```text
M4_CLOSEOUT_SELECTION=<M4_CLOSEOUT_A_APPROVE_WITH_NON_BLOCKING_CARRY_FORWARD |
M4_CLOSEOUT_B_APPROVE_AFTER_BOUNDED_DOCUMENTARY_REMEDIATION |
M4_CLOSEOUT_C_DEFER>

M5_SCOPE_SELECTION=<M5_A_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW |
M5_B_CUSTOMER_PACKAGING_AND_SIGNING_FIRST |
M5_C_EXTERNAL_PROVIDER_AND_CREDENTIAL_BOUNDARY_FIRST |
M5_D_PAUSE_AFTER_M4>
```

Selecting an option authorizes only the stated decision and the next separately
named planning gate. It does not authorize implementation, mutation, staging,
commit, push, Windows changes, credentials, signing, or production activation.

## 15. Final Package State

`M4_CLOSEOUT_READINESS_ASSESSED_M5_SCOPE_OPTIONS_PREPARED_NO_SELECTION_RECORDED`

The next eligible gate is:

`SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_READINESS_AND_M5_SCOPE_DECISION_PACKAGE_REVIEW`
