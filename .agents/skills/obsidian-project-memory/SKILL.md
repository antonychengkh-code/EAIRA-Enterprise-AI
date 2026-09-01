---
name: obsidian-project-memory
description: Recall, search, stage, and hand off durable EAIRA project context stored in the local Obsidian-compatible Markdown vault. Use when a request asks to remember, recall, search, update project memory, prepare a handoff, or audit stale project notes; do not use for unrelated repository edits.
---

# Obsidian Project Memory

Use the repository's existing context architecture. Do not create a parallel source of truth.

## Start

1. Resolve the repository root containing `AGENTS.md` and `docs/project/status/`.
2. Read and follow the root `AGENTS.md`, including its required startup sequence.
3. Read `docs/project/memory/README.md` after the controlled status artifacts.
4. Preserve unrelated working-tree changes. Do not stage, commit, push, or synchronize unless explicitly requested.

## Choose the operation

### Recall or search

- Search the controlled status, context, strategy, notes, planning, and log paths with focused queries.
- Prefer current source-of-truth files over summaries and historical records.
- Return exact repository paths and distinguish verified facts, recorded decisions, proposals, and unknowns.
- Do not write files for a read-only recall request.

### Capture a candidate memory

- Add only evidence-backed information to `docs/project/memory/MEMORY_INBOX.md`.
- Include the capture date, source paths, confidence, proposed destination, and why the item may be durable.
- Keep unresolved or unapproved material explicitly marked `candidate`.
- Never treat conversation text alone as authorization to alter a controlled decision or status artifact unless the user explicitly requests that mutation.

### Promote durable memory

- Require explicit authorization before moving a candidate into a controlled decision, status, task, or governance artifact.
- Select the existing canonical destination rather than duplicating content in the memory folder.
- Preserve `docs/specifications/EAIRA_CONTEXT_CONTRACT_V1.md` for controlled status artifacts.
- Update indexes with links after the canonical artifact is successfully written and validated.

### Prepare a handoff

- Update `docs/project/memory/HANDOFF.md` after material repository work when the task authorizes repository documentation updates.
- Record completed work, validation evidence, remaining work, known risks, and exact paths.
- State clearly whether commit, push, external synchronization, API integration, and scheduling were performed.
- Do not let the handoff override a controlled source of truth.

### Audit staleness

- Compare `updated` dates, referenced paths, current status, active task, and Git-visible existence.
- Report stale, missing, duplicated, or contradictory notes before changing them.
- Do not rewrite controlled artifacts without explicit authorization.

## Safety invariants

- Do not modify `.obsidian/` or external application settings.
- Do not store secrets, credentials, tokens, personal data, or unredacted sensitive environment values.
- Do not infer approval, execution, synchronization, or verification from a note's existence.
- Keep the memory folder navigational or provisional; canonical project facts remain in their established project locations.
- Scheduling and API/MCP integration are separate phases and require separate user authorization.

## Validate

Run `python .agents/skills/obsidian-project-memory/scripts/validate_memory.py` from the repository root after changing the memory structure or its instructions. Fix structural failures before claiming the memory layer is ready.
