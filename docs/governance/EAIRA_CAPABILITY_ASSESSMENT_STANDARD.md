# EAIRA Capability Assessment Standard

## Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Capability Assessment Standard |
| Short Description | Standard for assessing EAIRA candidate capabilities. |
| Version | 1.1.0 |
| Governance Status | Approved |
| Document Type | Governance Standard |
| Author/Contributor | EAIRA Governance Contributors |
| Owner | EAIRA Governance Owner |
| Created Date | 2026-07-06 |
| Last Updated | 2026-07-06 |
| Tags / Capability Type | governance, capability, assessment |
| Dependencies | [EAIRA Governance](./README.md); [EAIRA Governance Principles](./EAIRA_GOVERNANCE_PRINCIPLES.md); [EAIRA Capability Governance Standard](./EAIRA_CAPABILITY_GOVERNANCE_STANDARD.md); [EAIRA Capability Lifecycle](./EAIRA_CAPABILITY_LIFECYCLE.md) |
| Related Documents | [EAIRA Capability Decision Checklist](./EAIRA_CAPABILITY_DECISION_CHECKLIST.md); [EAIRA Governance Audit Checklist](./EAIRA_GOVERNANCE_AUDIT_CHECKLIST.md); [Candidate Capability Registry](../candidate/CANDIDATE_CAPABILITY_REGISTRY.md) |
| Supersedes | Version 0.1.0 |
| Superseded By | None |
| Completion Criteria | Authorized v1.1 revision items GIB-001 through GIB-009 integrated and validated. |
| Review Cycle | Per governance milestone review. |
| Approval Record | Governance Board publication approval recorded on 2026-07-06; EAIRA Governance Framework v1.1 published as current baseline. |

## Purpose

Define assessment inputs, minimum evidence, risk review, activation criteria review, and decision outcomes for candidate capability assessment.

Traceability: GIB-001, GIB-006, GIB-007.

## Scope

Assessment determines decision readiness. It does not approve the candidate unless an explicit decision record says so.

## Assessment Inputs

Assessment inputs are:

- Candidate record metadata.
- Candidate body sections.
- Evidence cited in the candidate record.
- Current workaround statement.
- Risk statement.
- Activation criteria.
- Metadata dependencies and body-level dependencies.
- Prior governance review or dry-run findings, if relevant.

Traceability: GIB-001, GIB-003, GIB-007.

## Evidence Requirements

Assessment must classify evidence as:

- `Present`: reviewable evidence is available.
- `Missing`: required evidence is absent.
- `Placeholder`: text exists but is not substantive evidence.
- `Unclear`: evidence exists but cannot be interpreted consistently.

Approval cannot be recommended from `Missing`, `Placeholder`, or `Unclear` evidence unless the decision is explicitly limited to a non-approval outcome.

Traceability: GIB-001.

## Risk Review

Risk review records whether risks are present, missing, placeholder-only, or unclear. Missing risk evidence should result in a deferred decision unless the review scope allows only validation of the process.

Traceability: GIB-006, GIB-007.

## Activation Criteria Review

Activation criteria must be observable and testable through governance evidence. Criteria that are missing, placeholder-only, or unrelated to the observed issue should produce a deferred decision.

Traceability: GIB-001, GIB-006.

## Decision Outcomes

Assessment may recommend:

- `Approved`: evidence and criteria are sufficient for the stated scope.
- `Deferred`: required evidence or criteria are missing, placeholder-only, unclear, or outside the review purpose.
- `Rejected`: evidence does not support the stated scope.
- `Superseded`: a later record replaces the assessment target.

Traceability: GIB-002, GIB-006.

## Review Requirements

Assessment must record observed facts separately from interpretation and recommendations when used for dry-run validation or governance improvement evidence.

Traceability: GIB-005, GIB-009.

## Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.1.0 | 2026-07-06 | Added assessment input guidance, evidence classification, deferred decision criteria, and dry-run separation for GIB-001, GIB-003, GIB-005, GIB-006, GIB-007, and GIB-009. |
| 0.1.0 | 2026-07-06 | Initial capability assessment standard created. |
