# M3.4 Evidence-Driven AI Organization Slice Candidate

## Metadata

| Field | Value |
| --- | --- |
| Title | M3.4 Evidence-Driven AI Organization Slice Candidate |
| Short Description | Candidate validation slice for testing whether AI organization assignment can produce repository evidence through Hermes execution. |
| Version | 0.1.0 |
| Governance Status | Candidate |
| Document Type | Candidate Capability |
| Author/Contributor | EAIRA Project Contributors |
| Owner | EAIRA Project Owner |
| Created Date | 2026-07-08 |
| Last Updated | 2026-07-08 |
| Tags / Capability Type | candidate, execution-slice, ai-organization, hermes, evidence-review |
| Dependencies | [EAIRA Governance Principles](../governance/EAIRA_GOVERNANCE_PRINCIPLES.md); [EAIRA Context Contract V1](../specifications/EAIRA_CONTEXT_CONTRACT_V1.md); [Candidate Capability Registry](./CANDIDATE_CAPABILITY_REGISTRY.md) |
| Related Documents | [EAIRA Capability Architecture Observation Note](../project/notes/EAIRA_CAPABILITY_ARCHITECTURE_OBSERVATION_NOTE.md); [EAIRA M3.2 Context Infrastructure MVP Closeout](../project/milestones/EAIRA_M3_2_CONTEXT_INFRASTRUCTURE_MVP_CLOSEOUT.md); [EAIRA M3.3 Cold Start Validation Closeout](../project/milestones/EAIRA_M3_3_COLD_START_VALIDATION_CLOSEOUT.md) |
| Supersedes | None |
| Superseded By | None |
| Completion Criteria | One controlled Finance Revenue Input Task completes an evidence-reviewed lifecycle without promoting the full five-layer architecture to M4. |
| Review Cycle | Before any M4 roadmap or execution-layer formalization decision. |
| Approval Record | Candidate direction recorded by project owner on 2026-07-08; Project Owner retains final completion authority. Repo Auditor may produce an Evidence Summary only and has no completion authority or governance authority. Task Record schema use is authorized for this validation slice only; successful completion does not make the schema reusable or approved as a standard. Future adoption requires separate evaluation and approval. |

## Purpose

Record a candidate validation slice for the proposed EAIRA AI Organization concept.

This candidate does not formalize the full five-layer architecture as M4. It preserves the architecture as a North Star Reference / Design Only Hypothesis until repository evidence verifies a controlled execution slice.

## Observed Issue

The proposed five-layer architecture describes:

Entry -> Control -> AI Organization -> Hermes -> Product Platform

The model is coherent, but most of it is not yet supported by repository evidence. Current repository status records M3.2 and M3.3 as completed, while the next milestone remains pending project owner decision.

The EAIRA Context Contract V1 also does not define lifecycle behavior, runtime synchronization, cross-document validation, or governance rules. Therefore, the proposed EAIRA Execution Layer cannot be declared formally established from current evidence.

## Evidence

Current evidence supports only a candidate validation step:

- M3.2 Context Infrastructure MVP is completed.
- M3.3 Cold Start Validation is completed.
- Context artifacts exist and are governed by EAIRA Context Contract V1.
- The Context Contract V1 explicitly does not define lifecycle behavior, runtime synchronization, cross-document validation, or governance rules.
- Existing governance principles state that candidate status does not equal milestone approval and implementation requires approval.
- The AI organization architecture remains Design Only until verified by repository evidence.

## Current Workaround

Treat the five-layer architecture as a North Star Reference only.

Do not place the full architecture into formal status infrastructure, governance standards, or roadmap commitments until a small execution slice has been verified.

## Proposed Validation Slice

The candidate validation slice is:

Client / Project / Module / Task

Finance Module

Revenue Input Task

PM + Database + Backend Agents

Hermes Execution

Evidence Review

## Candidate Task Record Format

A minimal task record for the slice should include:

| Field | Purpose |
| --- | --- |
| client_id | Identifies the client context for the task. |
| project_id | Identifies the project context for the task. |
| module_type | Identifies the product or business module. |
| task_id | Identifies the controlled task instance. |
| task_title | Human-readable task title. |
| agent_assignments | Lists assigned agent roles and responsibilities. |
| execution_runtime | Identifies Hermes or another approved runtime. |
| expected_repository_changes | Defines the files or artifact classes expected to change. |
| evidence_required | Defines evidence needed before completion can be claimed. |
| review_agent | Identifies the agent responsible for evidence review. |
| lifecycle_status | Tracks candidate lifecycle state for this task. |
| completion_decision | Records whether the task is complete, deferred, or rejected. |

This format is a candidate validation aid only. It does not modify ACTIVE_TASK.yaml or EAIRA Context Contract V1.

This candidate authorizes use of the Task Record schema for this validation slice only. Successful completion of the slice does not make the schema reusable, approved, or standardized. Any future adoption requires a separate evaluation and approval decision.

## Minimal Task Definition

| Field | Value |
| --- | --- |
| module_type | Finance |
| task_title | Revenue Input Task |
| task_goal | Validate whether AI organization assignment can complete one controlled task lifecycle through Hermes and repository evidence. |
| candidate_status | Proposed |
| expected_lifecycle | Assigned -> Executed -> Reviewed |
| completion_basis | Project Owner completion decision informed by Repo Auditor Evidence Summary. |

## Minimal Agent Assignments

| Agent Role | Candidate Responsibility |
| --- | --- |
| PM Agent | Implementation Scope: define task objective, scope, acceptance criteria, and coordination boundaries. |
| Database Agent | Implementation Scope: identify or implement required persistence changes for revenue input. |
| Backend Agent | Implementation Scope: identify or implement required service/API changes for revenue input. |
| Repo Auditor Agent | Evidence Review Scope only: produce an Evidence Summary covering changed files, task fit, evidence sufficiency, and unresolved gaps. |

Repo Auditor has no completion authority and no governance authority. The Project Owner is the final completion decision maker for this candidate slice.

## Hermes Boundary

Hermes is treated as execution runtime only for this candidate.

Hermes does not own governance approval, task completion declaration, evidence review, milestone promotion, or architecture formalization.

## Evidence Review Rule Candidate

The Repo Auditor Agent produces an Evidence Summary only. The Evidence Summary should address whether all of the following are true:

- Repository changes are traceable to the Revenue Input Task.
- Modified files match the expected task scope.
- Each assigned implementation agent has produced reviewable evidence or an explicit no-change rationale.
- The task can be verified from repository evidence without relying on oral status.
- Any unresolved missing evidence is recorded before completion is deferred or rejected.

The Repo Auditor Agent does not declare completion, approve governance changes, or authorize reuse of the Task Record schema. This is a candidate evidence review aid for one slice only. It does not define a general multi-agent evidence review standard.

## Potential Benefits

- Tests whether AI organization assignment can produce traceable repository evidence.
- Keeps architecture pressure below the evidence threshold.
- Creates a concrete basis for deciding whether a future EAIRA Execution Layer is warranted.
- Identifies gaps in multi-agent task completion review before broader formalization.

## Risks

- The slice could be mistaken for M4 approval.
- The task record format could be treated as a new context contract without approval.
- Agent responsibilities may overlap unless evidence ownership is explicit.
- Hermes execution may be confused with governance authority.

## Activation Criteria

Before execution, the project owner should explicitly approve:

- The candidate slice as M3.4 Candidate work.
- The Revenue Input Task as the single validation task.
- The minimum agent roles.
- The expected repository evidence.
- The rule that completion is declared only by the Project Owner after reviewing the Repo Auditor Evidence Summary.
- The rule that the Task Record schema is authorized for this validation slice only and is not a reusable or approved standard.

## Dependencies

- Completed M3.2 and M3.3 evidence.
- Project owner approval to begin M3.4 Candidate execution.
- A repository area suitable for a Finance Revenue Input Task.
- A non-governance task record location or task artifact approved for the validation slice.

## Decision

Do not formalize the full five-layer AI organization architecture as M4.

Create M3.4 Candidate as a controlled validation slice focused on one Finance Revenue Input Task.

The EAIRA Execution Layer concept is proposed, but not yet verified by repository evidence.

## Next Steps

1. Confirm project owner approval to execute the M3.4 Candidate slice.
2. Create the concrete Revenue Input Task record using the candidate task record format.
3. Run the task through Assigned -> Executed -> Reviewed.
4. Record repository evidence and Repo Auditor findings.
5. Project Owner decides whether the AI Organization -> Hermes -> Repository Evidence flow has enough evidence to advance, defer, or reject broader formalization.

## Owners & Contacts

Project owner decision required before execution begins.
