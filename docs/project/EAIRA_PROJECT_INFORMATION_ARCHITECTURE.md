# EAIRA Project Information Architecture

## Objective

Define the Project Layer information hierarchy, ownership model, and traceability principles for EAIRA project artifacts.

## Scope

This document defines conceptual Project Layer information ownership. It is not a report, template, governance policy, or execution procedure.

## Information Hierarchy

EAIRA Project Layer artifacts are organized by information ownership:

1. Strategy.
2. Charter.
3. Status.
4. Progress.
5. Validation.
6. Closeout.
7. Navigation.
8. Specification.

Each artifact type owns a distinct kind of information. Documents should reference other artifacts when supporting information already has an owner.

## Ownership Model

Information ownership is assigned as follows:

- Project Status Report owns current state.
- Progress Report owns execution history.
- Phase Closeout owns phase completion records.
- Validation Summary owns validation evidence.
- Strategy owns planning rationale.
- Specification owns standards.
- README owns the navigation entry point.
- Information Architecture owns hierarchy, ownership, and traceability rules.

| Artifact Type | Owns | Does Not Own |
| --- | --- | --- |
| Project Status Report | Current state | Execution history or completion record |
| Progress Report | Execution history | Current-state baseline after the reporting period closes |
| Phase Closeout | Phase completion record | Current state or detailed validation evidence |
| Validation Summary | Validation evidence | Execution history or project strategy |
| Strategy | Planning rationale | Status, progress, validation evidence, or closeout |
| Specification | Standards | Project-specific execution history |
| README | Navigation entry point | Policy, standards, or detailed workflow logic |
| Information Architecture | Hierarchy, ownership, and traceability rules | Status, execution history, validation evidence, or closeout facts |

## Traceability Principles

- Reference information when possible.
- Do not duplicate information unless ownership requires it.
- Preserve the source artifact for each information type.
- Keep historical records stable after creation.
- Use validation artifacts as evidence sources.
- Use progress reports for execution history.
- Use status reports for current state when such reports are authorized.
- Use closeout records for phase or milestone completion.

## Relationship Model

Strategy explains why a direction exists.

Charter authorizes the scoped work.

Progress records what happened during execution.

Validation records whether outputs met stated checks.

Closeout records that a phase or milestone completed.

README helps readers find the relevant artifacts.

Specifications define reusable standards and structures.

Information Architecture explains how those artifact types relate without duplicating ownership.

## Non-Redundancy Rule

Prefer references over repetition.

Duplicate information only when the receiving artifact owns a distinct summary or decision. For example, a closeout may summarize evidence but should point to the validation summary for detailed validation results.

## Support for Future Artifacts

This information model supports future phase, milestone, status, progress, validation, closeout, navigation, and specification artifacts by assigning each artifact type a clear owner role.

Future artifacts should identify the information they own before repeating content from existing artifacts.

## Final Decision

Decision: DOCUMENTED

Summary:
EAIRA Project Layer information hierarchy is documented with distinct ownership for status, progress, validation, closeout, strategy, specifications, README navigation, and information architecture.
