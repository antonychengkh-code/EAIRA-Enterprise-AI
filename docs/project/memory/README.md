---
type: project-memory-home
status: active
created: 2026-08-26
updated: 2026-08-26
source: codex
project: EAIRA
authority: navigational
---

# EAIRA Project Memory Home

This folder is the Obsidian-compatible navigation and staging layer for EAIRA project memory. It does not replace the repository's controlled context artifacts.

## Authority Map

| Need | Canonical source | Memory role |
| --- | --- | --- |
| Current project state | [[docs/project/status/CURRENT_STATUS]] | Link only |
| Current objective | [[docs/project/status/TODAY_OBJECTIVE]] | Link only |
| Active task and authorization | [[docs/project/status/ACTIVE_TASK.yaml]] | Link only |
| Context version | [[docs/project/status/AGENT_CONTEXT_VERSION.yaml]] | Link only |
| Detailed current context | [[docs/project/context/CURRENT_CONTEXT]] | Link only |
| Context format contract | [[docs/specifications/EAIRA_CONTEXT_CONTRACT_V1]] | Link only |
| Durable decisions | [[docs/project/memory/DECISION_INDEX]] | Navigational index |
| Discoveries and observations | [[docs/project/memory/DISCOVERY_INDEX]] | Navigational index |
| Procedures and templates | [[docs/project/memory/PROCEDURE_INDEX]] | Navigational index |
| Candidate knowledge | [[docs/project/memory/MEMORY_INBOX]] | Provisional only |
| Working handoff | [[docs/project/memory/HANDOFF]] | Non-authoritative summary |
| Open memory questions | [[docs/project/memory/OPEN_QUESTIONS]] | Provisional only |
| Stability gate | [[docs/project/memory/STABILITY_CHECKLIST]] | Operational validation |

## Startup Sequence

1. Read `AGENTS.md`.
2. Read the six controlled startup artifacts listed there.
3. Read this page.
4. Read [[docs/project/memory/HANDOFF]] only when continuing prior work.
5. Consult [[docs/project/memory/MEMORY_INBOX]] only when reviewing or promoting candidate knowledge.

## Write Policy

- Write verified current state only to its established controlled artifact and only when the task authorizes that mutation.
- Stage useful but unapproved knowledge in [[docs/project/memory/MEMORY_INBOX]].
- Record a working continuation summary in [[docs/project/memory/HANDOFF]] after material repository work.
- Never use a memory note to infer execution, approval, validation, commit, push, deployment, or synchronization.
- Do not store secrets, credentials, tokens, personal data, or unredacted sensitive environment values.
- Do not modify `.obsidian/` as part of memory maintenance.
- Keep scheduling, API, MCP, and external synchronization disabled until separately authorized.

## Schema

Use [[docs/project/memory/MEMORY_SCHEMA]] for frontmatter and candidate-entry requirements.
