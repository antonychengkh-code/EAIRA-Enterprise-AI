# EAIRA Documentation Index Tracking System

The EAIRA Documentation Index Tracking System keeps Project Layer documentation discoverable, current, and verifiable by deriving index artifacts from the repository filesystem.

## Objective

Define the purpose, source of truth, index structure, workflow, validation, and acceptance criteria for the EAIRA Project Layer documentation index system.

This specification records the documentation-index tracking standard only. It does not create index outputs or define automation details.

## Inputs

- Existing Project Layer documentation.
- Existing EAIRA project task documents.
- Existing milestone documentation, if any.
- Validated project experience.

## Specification Scope

This specification applies to documentation indexing within the Project Layer only.

It defines the documentation index model, lifecycle behavior, and validation principles. It does not define governance policy or implementation details.

## Scope

Create and maintain a Project Layer master specification for documentation index tracking.

This specification may later support derived artifacts such as:

- `docs/project/index/README.md`
- `docs/project/index/documentation-index.yaml`

Those artifacts are not created by this specification.

## Rules

- Markdown only.
- Project Layer only.
- Do not modify `docs/governance/`.
- Do not implement a scanner or automation script.
- Define the specification only.
- Keep the specification implementation-agnostic.
- Describe workflow behavior without programming language, library, pattern-matching, or tool-specific details.
- Preserve the four-layer model: Purpose, Structure, Workflow, Validation.
- Do not create a separate Automated Test Workflow layer.

## Writing Principles

- Keep the language concise, explicit, and stable.
- Prefer system behavior over implementation detail.
- Keep the specification reusable for future Project Layer document types.
- Preserve separation between Project Layer and Governance Layer.
- Make the specification suitable for future automation without binding it to a specific tool.
- Keep Workflow and Validation distinct: Workflow describes how information moves; Validation describes how correctness is proven.

## Non-Goals

- Do not create or modify automation code.
- Do not create README or index outputs.
- Do not modify governance documents.
- Do not create project artifacts outside this specification file.
- Do not introduce an additional layer beyond Purpose, Structure, Workflow, and Validation.
- Do not expand scope with new functional requirements.

## Index Purpose

The Documentation Index Tracking System exists to keep Project Layer documentation discoverable, current, and verifiable.

The system supports documentation lifecycle management by showing which documents exist, where they live, what role they serve, who owns them, and when they were last verified.

The system supports traceability by connecting generated index outputs back to the authoritative files under `docs/`.

## Source of Truth

The filesystem under `docs/` is the authoritative source of truth for EAIRA documentation.

Generated indexes are derived artifacts only. They summarize, organize, or expose information that already exists in source documents.

Generated indexes must never become the source of truth. If a generated index conflicts with the filesystem under `docs/`, the filesystem under `docs/` wins.

## Index Structure

The minimum schema for `documentation-index.yaml` is:

| Field | Purpose |
| --- | --- |
| `path` | Repository-relative path to the indexed document. |
| `title` | Human-readable title of the document. |
| `layer` | Documentation layer that owns the document. |
| `type` | Document type or category. |
| `status` | Current index status for the document. |
| `owner` | Person, group, or role responsible for the document. |
| `last_verified` | Date when the index entry was last verified. |
| `generated_from` | Source used to generate or verify the index entry. |

Allowed `status` values:

| Status | Meaning |
| --- | --- |
| `active` | The document exists and is current in the index. |
| `new` | The document exists in the filesystem but has not yet been fully incorporated into the index. |
| `changed` | The document exists and has changed since the last verified index state. |
| `stale` | The index entry exists but no longer reflects the current filesystem or document metadata. |
| `archived` | The document is retained for history and should not be treated as current active documentation. |

## Workflow

The workflow is sequential:

1. scan
2. validate
3. publish

Each stage depends on the successful completion of the previous stage.

### scan

The scan stage discovers Project Layer documentation from the filesystem under `docs/` and identifies the documents that should be represented in the index.

### validate

The validate stage checks that discovered documents and index entries are complete, consistent, and traceable to the filesystem source of truth.

### publish

The publish stage makes the verified index information available as derived documentation artifacts.

## Validation

Validation is where correctness is established.

Validation establishes confidence in generated artifacts without changing the source of truth.

### Validation Objectives

Validation is intended to prove that:

- The filesystem under `docs/` remains the source of truth.
- The index represents current Project Layer documentation.
- Required index fields are present.
- Status values are valid.
- Generated outputs are derived from verified source documents.

### Manual Validation

A human reviewer can verify the index by comparing indexed entries against the files under `docs/`, checking that required fields are present, confirming document titles and types, and confirming that generated outputs reflect the current index state.

### Automated Validation

Automated validation is a method within Validation, not a separate layer.

Automated validation may compare the filesystem against the index, verify schema completeness, confirm metadata correctness, identify new or changed documents, and detect stale or missing entries.

Automated validation must remain subordinate to the source-of-truth rule: the filesystem under `docs/` remains authoritative.

### Acceptance Criteria

The specification is satisfied when:

- No validation errors are present.
- The index is synchronized with Project Layer files under `docs/`.
- Generated outputs, when present, are current derived artifacts.
- Required index fields are complete.
- Status values use the allowed status model.
- The source of truth remains the filesystem under `docs/`.

## Acceptance

- Specification document created.
- Project Layer only.
- Governance documents unchanged.
- Standard documentation index structure documented.
- Workflow behavior documented at specification level.
- Validation expectations documented without implementation detail.

## Final Decision

Decision: DOCUMENTED

Summary:
EAIRA Documentation Index Tracking System is documented as a Project Layer master specification.
