# EAIRA Project Status

## Purpose

This directory contains the current static context status artifacts for EAIRA.

These files provide the current working state needed by approved agents to identify the current milestone, active phase, current objective, active task, and context version status.

All status artifacts in this directory must conform to `docs/specifications/EAIRA_CONTEXT_CONTRACT_V1.md`.

## Files

| File | Status Information Owned |
| --- | --- |
| `CURRENT_STATUS.md` | Current project state |
| `TODAY_OBJECTIVE.md` | Current day's objective |
| `ACTIVE_TASK.yaml` | Current active task |
| `AGENT_CONTEXT_VERSION.yaml` | Context version tracking state |

## Suggested Reading Sequence

1. `CURRENT_STATUS.md`
2. `TODAY_OBJECTIVE.md`
3. `ACTIVE_TASK.yaml`
4. `AGENT_CONTEXT_VERSION.yaml`

## Current Sources Of Truth

| Status Need | Source Of Truth |
| --- | --- |
| Current milestone and active phase | `CURRENT_STATUS.md` |
| Current decision, blockers, and next action | `CURRENT_STATUS.md` |
| Current day's scope and expected deliverables | `TODAY_OBJECTIVE.md` |
| Current active task | `ACTIVE_TASK.yaml` |
| Context version status | `AGENT_CONTEXT_VERSION.yaml` |

## Boundaries

This directory does not define context lifecycle behavior, context management standards, context events, event bus behavior, runtime synchronization, or governance rules.
