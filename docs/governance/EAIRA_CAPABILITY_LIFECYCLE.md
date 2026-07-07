# EAIRA Capability Lifecycle

## Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Capability Lifecycle |
| Short Description | Lifecycle guidance for EAIRA capability governance. |
| Version | 1.1.0 |
| Governance Status | Approved |
| Document Type | Governance Lifecycle |
| Author/Contributor | EAIRA Governance Contributors |
| Owner | EAIRA Governance Owner |
| Created Date | 2026-07-06 |
| Last Updated | 2026-07-06 |
| Tags / Capability Type | governance, capability, lifecycle |
| Dependencies | [EAIRA Governance](./README.md); [EAIRA Governance Principles](./EAIRA_GOVERNANCE_PRINCIPLES.md); [EAIRA Capability Governance Standard](./EAIRA_CAPABILITY_GOVERNANCE_STANDARD.md); [EAIRA Document Classification Standard](./EAIRA_DOCUMENT_CLASSIFICATION_STANDARD.md) |
| Related Documents | [EAIRA Capability Assessment Standard](./EAIRA_CAPABILITY_ASSESSMENT_STANDARD.md); [EAIRA Capability Decision Checklist](./EAIRA_CAPABILITY_DECISION_CHECKLIST.md); [EAIRA Governance Audit Checklist](./EAIRA_GOVERNANCE_AUDIT_CHECKLIST.md); [Candidate Capability Registry](../candidate/CANDIDATE_CAPABILITY_REGISTRY.md) |
| Supersedes | Version 0.1.0 |
| Superseded By | None |
| Completion Criteria | Authorized v1.1 revision items GIB-001 through GIB-009 integrated and validated. |
| Review Cycle | Per governance milestone review. |
| Approval Record | Governance Board publication approval recorded on 2026-07-06; EAIRA Governance Framework v1.1 published as current baseline. |

## Purpose

Define how capability governance records move through reviewable statuses and decision outcomes.

Traceability: GIB-002, GIB-006, GIB-008.

## Scope

This lifecycle applies to candidate capability records and related governance decisions. It does not convert a candidate into an approved outcome without a decision record.

## Lifecycle Statuses

| Status | Entry Criteria | Exit Criteria |
| --- | --- | --- |
| Draft | Record exists with required metadata. | Ready to become Candidate, enter review, be archived, or be superseded. |
| Candidate | Subject is named and candidate sections exist. | Minimum evidence is ready for assessment, or gaps require deferral. |
| In Review | Review has been requested or started. | Review conclusion is recorded. |
| Assessment | Evidence, risks, activation criteria, and decision readiness are being evaluated. | Decision outcome is recorded. |
| Approved | Authorized decision exists for the stated scope. | Superseded, archived, or moved only by later approved decision. |
| Architecture | Reserved for later authorized phase after approved capability decision. | Governed by a later approved phase. |
| Implementation | Reserved for later authorized phase after approval. | Governed by a later approved phase. |
| Operational | Reserved for later authorized phase after approved completion criteria. | Governed by a later approved phase. |
| Deprecated | Record is retained but no longer preferred. | Archived or superseded. |
| Archived | Record is closed and retained. | Reopened only by governance decision. |
| Rejected | Record was reviewed and not accepted. | Superseded or reopened only by governance decision. |
| Superseded | Record was replaced by a later record. | No further movement unless reopened by governance decision. |

Traceability: GIB-002, GIB-008.

## Candidate Management

Candidate status requires a named subject and the required candidate sections. Candidate status does not mean the candidate is approved or scheduled for later phases.

Candidate records with placeholder evidence may remain `Candidate`, return to `Draft`, or receive a deferred decision depending on review context.

Traceability: GIB-002, GIB-006.

## Assessment Entry Criteria

Assessment should begin only when the candidate record includes minimum evidence or explicitly records missing evidence. Minimum evidence follows [EAIRA Capability Governance Standard](./EAIRA_CAPABILITY_GOVERNANCE_STANDARD.md).

If evidence is absent or placeholder-only, assessment may record that the candidate is not ready for decision.

Traceability: GIB-001, GIB-007.

## Decision Points

Decision outcomes are `Approved`, `Deferred`, `Rejected`, or `Superseded`.

Use `Deferred` when:

- Required evidence is missing.
- Activation criteria are absent or not reviewable.
- Metadata dependencies and body-level dependencies are unclear.
- Decision readiness cannot be established.
- The review is a dry run rather than a candidate decision review.

Traceability: GIB-006.

## Review Requirements

Lifecycle review verifies status entry criteria, status exit criteria, decision outcome, and whether the record has sufficient evidence for its requested movement.

Governance review determines decision readiness. Dry-run validation tests whether the process is usable and must not be treated as candidate approval.

Traceability: GIB-005, GIB-009.

## Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.1.0 | 2026-07-06 | Added status transition criteria, assessment entry criteria, deferred decision criteria, and review separation for GIB-001, GIB-002, GIB-005, GIB-006, GIB-007, GIB-008, and GIB-009. |
| 0.1.0 | 2026-07-06 | Initial capability lifecycle created. |
