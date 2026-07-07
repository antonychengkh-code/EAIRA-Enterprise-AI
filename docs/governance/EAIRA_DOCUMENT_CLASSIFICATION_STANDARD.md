# EAIRA Document Classification Standard

## Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Document Classification Standard |
| Short Description | Standard for classifying EAIRA governance documents. |
| Version | 1.1.0 |
| Governance Status | Approved |
| Document Type | Governance Standard |
| Author/Contributor | EAIRA Governance Contributors |
| Owner | EAIRA Governance Owner |
| Created Date | 2026-07-06 |
| Last Updated | 2026-07-06 |
| Tags / Capability Type | governance, classification |
| Dependencies | [EAIRA Governance](./README.md); [EAIRA Governance Principles](./EAIRA_GOVERNANCE_PRINCIPLES.md); [EAIRA Capability Governance Standard](./EAIRA_CAPABILITY_GOVERNANCE_STANDARD.md) |
| Related Documents | [EAIRA Capability Lifecycle](./EAIRA_CAPABILITY_LIFECYCLE.md); [EAIRA Capability Assessment Standard](./EAIRA_CAPABILITY_ASSESSMENT_STANDARD.md); [EAIRA Capability Decision Checklist](./EAIRA_CAPABILITY_DECISION_CHECKLIST.md); [EAIRA Governance Audit Checklist](./EAIRA_GOVERNANCE_AUDIT_CHECKLIST.md) |
| Supersedes | Version 0.1.0 |
| Superseded By | None |
| Completion Criteria | Authorized v1.1 revision items GIB-001 through GIB-009 integrated and validated. |
| Review Cycle | Per governance milestone review. |
| Approval Record | Governance Board publication approval recorded on 2026-07-06; EAIRA Governance Framework v1.1 published as current baseline. |

## Purpose

Define consistent classification metadata, document types, status usage, and dependency meanings for EAIRA governance documents.

Traceability: GIB-003, GIB-008.

## Scope

This standard applies to governance documents, candidate governance records, validation reports, change-management records, and authorization records in the EAIRA repository.

## Classification Fields

Required metadata fields are Title, Short Description, Version, Governance Status, Document Type, Author/Contributor, Owner, Created Date, Last Updated, Tags / Capability Type, Dependencies, Related Documents, Supersedes, Superseded By, Completion Criteria when applicable, Review Cycle, and Approval Record.

Metadata `Dependencies` identify documents that this document relies on for interpretation or governance authority. `Related Documents` identify documents that are useful context but not required for interpretation.

If a document body includes a `Dependencies` section, that section describes the subject of the record, not metadata relationships.

Traceability: GIB-003.

## Document Types

Allowed document types include Governance Index, Governance Principles, Governance Standard, Governance Lifecycle, Governance Checklist, Governance Validation Report, Governance Change Backlog, Governance Change Review, Authorization Draft, Candidate Registry, and Candidate Capability.

New document types require governance review before use.

## Status Usage

Allowed governance statuses:

| Status | Reviewable Meaning | Entry Evidence |
| --- | --- | --- |
| Draft | Created for review and not yet accepted as a later status. | Document exists with required metadata. |
| Candidate | Proposed for capability assessment. | Candidate sections exist and identify a subject. |
| In Review | Under active governance review. | Review request or review record exists. |
| Assessment | Being evaluated against evidence and criteria. | Minimum evidence is present or missing evidence is explicitly recorded. |
| Approved | Accepted for the stated scope. | Approval record identifies authority, scope, and date. |
| Architecture | Reserved for a later authorized phase. | Prior approved capability decision required. |
| Implementation | Reserved for a later authorized phase. | Prior approved decision for that phase required. |
| Operational | Reserved for a later authorized phase. | Prior approved completion criteria required. |
| Deprecated | Retained but no longer preferred for use. | Replacement or deprecation reason recorded. |
| Archived | Closed and retained for recordkeeping. | Closure reason recorded. |
| Rejected | Reviewed and not accepted for the stated scope. | Rejection rationale recorded. |
| Superseded | Replaced by a later document or decision. | Superseding document recorded. |

Traceability: GIB-002, GIB-008.

## Review Requirements

Classification review verifies that metadata is complete, status is valid, dependencies are correctly classified, and approval records do not overstate authority.

## Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.1.0 | 2026-07-06 | Added dependency distinction and reviewable status definitions for GIB-003 and GIB-008. |
| 0.1.0 | 2026-07-06 | Initial document classification standard created. |
