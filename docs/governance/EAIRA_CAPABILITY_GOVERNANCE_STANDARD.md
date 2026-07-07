# EAIRA Capability Governance Standard

## Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Capability Governance Standard |
| Short Description | Standard for governing EAIRA capability records and decisions. |
| Version | 1.1.0 |
| Governance Status | Approved |
| Document Type | Governance Standard |
| Author/Contributor | EAIRA Governance Contributors |
| Owner | EAIRA Governance Owner |
| Created Date | 2026-07-06 |
| Last Updated | 2026-07-06 |
| Tags / Capability Type | governance, capability |
| Dependencies | [EAIRA Governance](./README.md); [EAIRA Governance Principles](./EAIRA_GOVERNANCE_PRINCIPLES.md); [EAIRA Document Classification Standard](./EAIRA_DOCUMENT_CLASSIFICATION_STANDARD.md) |
| Related Documents | [EAIRA Capability Lifecycle](./EAIRA_CAPABILITY_LIFECYCLE.md); [EAIRA Capability Assessment Standard](./EAIRA_CAPABILITY_ASSESSMENT_STANDARD.md); [EAIRA Capability Decision Checklist](./EAIRA_CAPABILITY_DECISION_CHECKLIST.md); [Candidate Capability Registry](../candidate/CANDIDATE_CAPABILITY_REGISTRY.md) |
| Supersedes | Version 0.1.0 |
| Superseded By | None |
| Completion Criteria | Authorized v1.1 revision items GIB-001 through GIB-009 integrated and validated. |
| Review Cycle | Per governance milestone review. |
| Approval Record | Governance Board publication approval recorded on 2026-07-06; EAIRA Governance Framework v1.1 published as current baseline. |

## Purpose

Define minimum governance expectations for candidate capability records, evidence, activation criteria, assessment readiness, decision outcomes, and deferred decisions.

Traceability: GIB-001, GIB-006, GIB-007.

## Scope

This standard governs capability records and capability decisions. It does not approve the subject of a candidate record by itself.

## Capability Record Requirements

A capability record must include the sections required by the applicable candidate template or standard. At minimum, a reviewable candidate record identifies:

- Purpose
- Observed Issue
- Evidence
- Current Workaround
- Potential Benefits
- Risks
- Activation Criteria
- Body-level Dependencies
- Decision
- Next Steps
- Owners & Contacts

Metadata dependencies must remain separate from body-level dependencies.

Traceability: GIB-001, GIB-003, GIB-007.

## Capability Decision Requirements

A capability decision must record one of these outcomes:

- `Approved`: evidence and criteria support the stated scope.
- `Deferred`: evidence, criteria, ownership, or review readiness is insufficient.
- `Rejected`: evidence or review findings do not support the stated scope.
- `Superseded`: the decision is replaced by a later record.

A candidate decision cannot be inferred from candidate status. It must be explicitly recorded.

Traceability: GIB-002, GIB-006.

## Activation Criteria

Activation criteria are the conditions that must be met before a capability can advance. Criteria must be observable, reviewable, and tied to evidence.

If activation criteria are absent, ambiguous, or unsupported, the decision outcome should be `Deferred`.

Traceability: GIB-001, GIB-006, GIB-007.

## Evidence Requirements

Minimum evidence for assessment includes:

- The observed issue and where it was observed.
- The evidence source or explicit statement that evidence is missing.
- Current workaround, if one exists.
- Potential benefit connected to the observed issue.
- Risk statement.
- Activation criteria.
- Body-level dependencies.
- Decision readiness statement.

Placeholder text is not sufficient evidence for approval.

Traceability: GIB-001, GIB-007.

## Status Usage

Governance status describes document state. Decision outcome describes the result of a capability decision. These are related but not interchangeable.

Use [EAIRA Capability Lifecycle](./EAIRA_CAPABILITY_LIFECYCLE.md) for status transitions and [EAIRA Document Classification Standard](./EAIRA_DOCUMENT_CLASSIFICATION_STANDARD.md) for status meanings.

Traceability: GIB-002, GIB-008.

## Review Requirements

Capability review verifies evidence sufficiency, activation criteria, dependency classification, decision readiness, and whether any decision should be deferred.

Governance review validates the decision record. A dry run validates whether the governance process is usable; it does not approve the candidate.

Traceability: GIB-005, GIB-006, GIB-009.

## Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.1.0 | 2026-07-06 | Added evidence requirements, dependency distinction, decision outcomes, deferred criteria, and review separation for GIB-001 through GIB-009. |
| 0.1.0 | 2026-07-06 | Initial capability governance standard created. |
