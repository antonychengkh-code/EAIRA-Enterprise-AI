# EAIRA Governance

## Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Governance |
| Short Description | Entry point for EAIRA governance documents and reading order. |
| Version | 1.1.0 |
| Governance Status | Approved |
| Document Type | Governance Index |
| Author/Contributor | EAIRA Governance Contributors |
| Owner | EAIRA Governance Owner |
| Created Date | 2026-07-06 |
| Last Updated | 2026-07-06 |
| Tags / Capability Type | governance, index |
| Dependencies | None |
| Related Documents | [EAIRA Governance Principles](./EAIRA_GOVERNANCE_PRINCIPLES.md); [EAIRA Capability Governance Standard](./EAIRA_CAPABILITY_GOVERNANCE_STANDARD.md); [EAIRA Document Classification Standard](./EAIRA_DOCUMENT_CLASSIFICATION_STANDARD.md); [EAIRA Capability Lifecycle](./EAIRA_CAPABILITY_LIFECYCLE.md); [EAIRA Capability Assessment Standard](./EAIRA_CAPABILITY_ASSESSMENT_STANDARD.md); [EAIRA Capability Decision Checklist](./EAIRA_CAPABILITY_DECISION_CHECKLIST.md); [EAIRA Governance Audit Checklist](./EAIRA_GOVERNANCE_AUDIT_CHECKLIST.md); [EAIRA Governance Dry Run Report v1](./EAIRA_GOVERNANCE_DRY_RUN_REPORT_V1.md); [EAIRA Governance Improvement Backlog](./EAIRA_GOVERNANCE_IMPROVEMENT_BACKLOG.md); [EAIRA Governance Change Review v1](./EAIRA_GOVERNANCE_CHANGE_REVIEW_V1.md); [EAIRA Governance Framework v1.1 Revision Authorization Draft](./EAIRA_GOVERNANCE_FRAMEWORK_V1_1_REVISION_AUTHORIZATION_DRAFT.md) |
| Supersedes | Version 0.1.0 |
| Superseded By | None |
| Completion Criteria | Authorized v1.1 revision items GIB-001 through GIB-009 integrated and validated. |
| Review Cycle | Per governance milestone review. |
| Approval Record | Governance Board publication approval recorded on 2026-07-06; EAIRA Governance Framework v1.1 published as current baseline. |

## What Is Governance

Governance is the document-controlled process for deciding what EAIRA recognizes, assesses, approves, defers, rejects, or archives. It keeps decisions grounded in observed facts, evidence, reviewable criteria, and explicit approval records.

Governance does not by itself authorize technical design or delivery activity. It defines decision readiness and records why a decision can or cannot be made.

## How To Read

Read the framework in the order below. Earlier documents define principles and classification rules; later documents apply those rules to capability records, assessments, decisions, audits, and validation artifacts.

When a document has both metadata `Dependencies` and body-level `Dependencies`, metadata dependencies identify document relationships. Body-level dependencies identify the subject-specific dependencies of the record being assessed.

## Repository Structure

- `docs/governance/`: governance framework documents, validation records, change-management records, and authorization records.
- `docs/candidate/`: candidate capability records and candidate registries governed by the framework.

## Document Order

1. [EAIRA Governance](./README.md)
2. [EAIRA Governance Principles](./EAIRA_GOVERNANCE_PRINCIPLES.md)
3. [EAIRA Document Classification Standard](./EAIRA_DOCUMENT_CLASSIFICATION_STANDARD.md)
4. [EAIRA Capability Governance Standard](./EAIRA_CAPABILITY_GOVERNANCE_STANDARD.md)
5. [EAIRA Capability Lifecycle](./EAIRA_CAPABILITY_LIFECYCLE.md)
6. [EAIRA Capability Assessment Standard](./EAIRA_CAPABILITY_ASSESSMENT_STANDARD.md)
7. [EAIRA Capability Decision Checklist](./EAIRA_CAPABILITY_DECISION_CHECKLIST.md)
8. [EAIRA Governance Audit Checklist](./EAIRA_GOVERNANCE_AUDIT_CHECKLIST.md)
9. [Candidate Capability Registry](../candidate/CANDIDATE_CAPABILITY_REGISTRY.md)
10. [EAIRA Governance Dry Run Report v1](./EAIRA_GOVERNANCE_DRY_RUN_REPORT_V1.md)
11. [EAIRA Governance Improvement Backlog](./EAIRA_GOVERNANCE_IMPROVEMENT_BACKLOG.md)
12. [EAIRA Governance Change Review v1](./EAIRA_GOVERNANCE_CHANGE_REVIEW_V1.md)
13. [EAIRA Governance Framework v1.1 Revision Authorization Draft](./EAIRA_GOVERNANCE_FRAMEWORK_V1_1_REVISION_AUTHORIZATION_DRAFT.md)

## Relationship

Principles set expectations for evidence and approval. Classification defines document metadata and status usage. Capability governance defines what a candidate record must contain. Lifecycle defines status movement. Assessment and decision documents define review readiness. Audit and dry-run documents validate whether the process is usable and consistent.

## Lifecycle Overview

Allowed governance statuses:

| Status | Reviewable Meaning |
| --- | --- |
| Draft | Created for review and not yet accepted as a candidate, approved document, or completed record. |
| Candidate | Proposed for assessment with a named subject and minimum required sections. |
| In Review | Under active governance review with reviewer attention requested. |
| Assessment | Being evaluated against evidence, risks, activation criteria, and decision readiness. |
| Approved | Accepted by the authorized governance body for the stated scope. |
| Architecture | Reserved status for a later authorized phase; not used as a starting point. |
| Implementation | Reserved status for a later authorized phase; requires prior approval. |
| Operational | Reserved status for a later authorized phase after approval and completion criteria. |
| Deprecated | Retained for history but no longer preferred for current use. |
| Archived | Closed and retained for recordkeeping. |
| Rejected | Reviewed and not accepted for the stated scope. |
| Superseded | Replaced by a later document or decision. |

## Quick Start

1. Confirm the document type and `Governance Status`.
2. Confirm metadata dependencies and related documents.
3. Check whether required evidence exists.
4. Apply the capability lifecycle and assessment standard.
5. Use the decision checklist before recording any outcome.
6. Use governance review or dry-run validation according to the purpose of the review.

## Revision Traceability

| Backlog ID | v1.1 Integration |
| --- | --- |
| GIB-001 | Minimum evidence requirements referenced across governance, lifecycle, assessment, and decision documents. |
| GIB-002 | Status transition criteria added through lifecycle and status usage guidance. |
| GIB-003 | Metadata dependencies distinguished from body-level dependencies. |
| GIB-004 | README reading order updated to include Task B and validation documents. |
| GIB-005 | Governance review and dry-run validation separated in review guidance. |
| GIB-006 | Deferred decision criteria added to lifecycle, assessment, and decision guidance. |
| GIB-007 | Assessment template guidance added to assessment and checklist documents. |
| GIB-008 | Reviewable status definitions added to framework overview and classification guidance. |
| GIB-009 | Dry-run report structure standardized in audit guidance. |

## Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.1.0 | 2026-07-06 | Integrated authorized revision items GIB-001 through GIB-009. |
| 0.1.0 | 2026-07-06 | Initial governance index created. |
