## Project Overview

EAIRA is an Enterprise AI repository that organizes project specifications and context artifacts.

## Before You Start

1. `docs/project/status/README.md`
2. `docs/project/status/CURRENT_STATUS.md`
3. `docs/project/status/TODAY_OBJECTIVE.md`
4. `docs/project/status/ACTIVE_TASK.yaml`
5. `docs/project/status/AGENT_CONTEXT_VERSION.yaml`
6. `docs/specifications/EAIRA_CONTEXT_CONTRACT_V1.md`
7. `docs/project/memory/README.md`

## Repository Layout

- `docs/specifications/`: Specification documents.
- `docs/project/status/`: Current context status artifacts.

## Current Sources of Truth

| Question | File |
|---|---|
| What is the current project state? | `docs/project/status/CURRENT_STATUS.md` |
| What is today's objective? | `docs/project/status/TODAY_OBJECTIVE.md` |
| What is the active task? | `docs/project/status/ACTIVE_TASK.yaml` |
| What format must context artifacts follow? | `docs/specifications/EAIRA_CONTEXT_CONTRACT_V1.md` |

## Boundaries

**This document does not define: AI Capabilities, Task Workflows, Lifecycle Management, Context Events, Runtime Synchronization, Repository Governance Rules, or Repository Architecture.**

## Obsidian Project Memory

- Treat `docs/project/memory/README.md` as a navigation layer, not as a source of project authority.
- The status artifacts and context contract listed above remain the sources of truth for current state, objective, active task, and context version.
- `docs/project/memory/MEMORY_INBOX.md` contains unapproved candidate memories. Never treat an inbox entry as a decision, authorization, verified fact, or current state.
- `docs/project/memory/HANDOFF.md` is a working handoff summary. When it conflicts with a source of truth, follow the source of truth and report the conflict.
- Put durable decisions in the appropriate controlled project artifact only with explicit Project Owner authorization. Do not promote candidate memory automatically.
- For a task that materially changes the repository, update the handoff with evidence-backed completed work, remaining work, and exact file links. Do not claim a commit, push, deployment, or synchronization that was not performed.
- Do not modify `.obsidian/`, create scheduled jobs, or enable external synchronization unless the user explicitly requests that separate action.
- Never store secrets, access tokens, credentials, personal data, or unredacted sensitive environment values in project memory.
