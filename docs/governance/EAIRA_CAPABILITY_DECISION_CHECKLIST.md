# EAIRA Capability Decision Checklist

## Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Capability Decision Checklist |
| Short Description | Checklist for EAIRA capability governance decisions. |
| Version | 1.1.0 |
| Governance Status | Approved |
| Document Type | Governance Checklist |
| Author/Contributor | EAIRA Governance Contributors |
| Owner | EAIRA Governance Owner |
| Created Date | 2026-07-06 |
| Last Updated | 2026-07-06 |
| Tags / Capability Type | governance, capability, decision |
| Dependencies | [EAIRA Governance](./README.md); [EAIRA Governance Principles](./EAIRA_GOVERNANCE_PRINCIPLES.md); [EAIRA Capability Governance Standard](./EAIRA_CAPABILITY_GOVERNANCE_STANDARD.md); [EAIRA Capability Assessment Standard](./EAIRA_CAPABILITY_ASSESSMENT_STANDARD.md) |
| Related Documents | [EAIRA Capability Lifecycle](./EAIRA_CAPABILITY_LIFECYCLE.md); [EAIRA Governance Audit Checklist](./EAIRA_GOVERNANCE_AUDIT_CHECKLIST.md); [Candidate Capability Registry](../candidate/CANDIDATE_CAPABILITY_REGISTRY.md) |
| Supersedes | Version 0.1.0 |
| Superseded By | None |
| Completion Criteria | Authorized v1.1 revision items GIB-001 through GIB-009 integrated and validated. |
| Review Cycle | Per governance milestone review. |
| Approval Record | Governance Board publication approval recorded on 2026-07-06; EAIRA Governance Framework v1.1 published as current baseline. |

## Purpose

Provide a checklist for determining whether a candidate capability decision is ready, deferred, rejected, superseded, or approved for the stated scope.

Traceability: GIB-001, GIB-006, GIB-007.

## Scope

This checklist applies to capability decision readiness. It does not authorize any later phase unless a decision record explicitly says so.

## Reality First

- Are all observed facts sourced from existing records?
- Are missing facts recorded as missing?
- Are assumptions excluded from the decision basis?

Traceability: GIB-001.

## Evidence Before Design

- Is the observed issue supported by evidence?
- Is the current workaround present or explicitly absent?
- Are potential benefits tied to the observed issue?
- Are risks recorded?
- Are activation criteria reviewable?

Traceability: GIB-001, GIB-007.

## Capability Before Architecture

- Is the requested decision a capability decision?
- Is the candidate record distinct from later reserved phases?
- Is decision scope limited to the evidence in the record?

Traceability: GIB-002, GIB-008.

## Architecture Is Never A Starting Point

- Is the reserved `Architecture` status avoided unless a prior approved capability decision exists?
- Is any later-phase language excluded from the candidate decision basis?

Traceability: GIB-002, GIB-008.

## Implementation Requires Approval

- Is the reserved `Implementation` status avoided unless prior approval exists?
- Does the decision record avoid implying approval beyond the stated scope?

Traceability: GIB-005, GIB-008.

## Candidate Does Not Equal Milestone

- Does the record avoid treating `Candidate` as approval?
- Does the decision identify whether the outcome is approved, deferred, rejected, or superseded?

Traceability: GIB-002, GIB-006.

## Every Capability Needs Activation Criteria

- Are activation criteria present?
- Are activation criteria observable through governance evidence?
- If criteria are missing or placeholder-only, is the decision deferred?

Traceability: GIB-001, GIB-006, GIB-007.

## Every Architecture Must Trace Back To A Capability Decision

- If a later reserved status is referenced, does it trace to an approved capability decision?
- Is that trace recorded in the decision record?

Traceability: GIB-002, GIB-008.

## Decision Record

A decision record must include:

- Decision outcome.
- Evidence summary.
- Activation criteria result.
- Dependency review result.
- Rationale.
- Approval record or deferred reason.
- Backlog or review trace when the decision is based on governance improvement evidence.

Use `Deferred` when evidence is missing, placeholder-only, unclear, or when the review is a dry run rather than a candidate decision review.

Traceability: GIB-003, GIB-005, GIB-006, GIB-009.

## Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.1.0 | 2026-07-06 | Added decision-readiness checklist details, evidence checks, deferred criteria, dependency review, and dry-run distinction for GIB-001 through GIB-009. |
| 0.1.0 | 2026-07-06 | Initial capability decision checklist created. |
