# EAIRA Context Contract V1

## Purpose

The EAIRA Context Contract defines the minimum structure that EAIRA context artifacts must follow.

The contract exists so approved agents can read and validate context artifacts consistently. Context is central; agents are replaceable.

## Scope

This draft covers only required artifact fields, naming format, version format, and field-level validation rules for the context artifacts listed in this contract.

Context artifacts must be versioned and verifiable. This contract is separate from context management standards. Bootstrap behavior belongs to lifecycle definition and is not defined here. Unverified concepts must not be promoted to formal standards through this contract.

This contract does not define context lifecycle, context management standards, context events, event bus behavior, runtime synchronization, cross-document validation, or governance rules beyond the minimum contract rules.

## Context Artifacts

The context artifacts in scope are:

- `docs/project/status/CURRENT_STATUS.md`
- `docs/project/status/TODAY_OBJECTIVE.md`
- `docs/project/status/ACTIVE_TASK.yaml`
- `docs/project/status/AGENT_CONTEXT_VERSION.yaml`

## Required Fields

### `CURRENT_STATUS.md`

Minimum required fields:

- Context ID
- Version
- Updated At
- Current Milestone
- Active Phase
- Current Decision
- Blockers
- Next Action

### `TODAY_OBJECTIVE.md`

Minimum required fields:

- Date
- Milestone
- Current Scope
- Out of Scope
- Expected Deliverables
- Success Criteria

### `ACTIVE_TASK.yaml`

Minimum required fields:

- Task ID
- Owner
- Status
- Priority
- Dependencies
- Last Updated

### `AGENT_CONTEXT_VERSION.yaml`

Minimum required fields:

- Context Version
- Last Updated
- Current Status Version
- Today Objective Version
- Knowledge Index Version
- Verified Agents

## Naming Format

Context artifact filenames must match the names listed in the Context Artifacts section.

Markdown context artifacts must use the `.md` extension.

YAML context artifacts must use the `.yaml` extension.

Field names must remain stable within each artifact so approved agents can read them consistently.

## Version Format

Version fields must exist where required.

Version values must be non-empty strings.

The version format must be consistent within each artifact.

This contract does not define cross-artifact version comparison rules.

## Field Validation

Required fields must exist.

Required fields must not be empty.

Date and timestamp fields must exist where required.

Markdown artifacts must expose required fields as readable labeled fields or sections.

YAML artifacts must be valid YAML.

YAML scalar fields must contain valid YAML scalar values.

YAML list fields must contain valid YAML lists.

`Dependencies` may be an empty YAML list when there are no dependencies.

`Verified Agents` may be an empty YAML list when no agents are verified.

This contract does not define cross-document validation logic.

## Completion Checklist

- `CURRENT_STATUS.md` includes all minimum required fields.
- `TODAY_OBJECTIVE.md` includes all minimum required fields.
- `ACTIVE_TASK.yaml` includes all minimum required fields.
- `AGENT_CONTEXT_VERSION.yaml` includes all minimum required fields.
- Required fields are present and non-empty unless this contract explicitly allows an empty list.
- YAML artifacts are valid YAML.
- No context lifecycle behavior is defined.
- No context event behavior is defined.
- No runtime synchronization behavior is defined.
- No cross-document validation logic is defined.
