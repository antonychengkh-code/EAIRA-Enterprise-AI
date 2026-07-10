# Project Bootstrap

## Purpose

Define a Project Layer context reconstruction protocol for AI assistants before beginning EAIRA work.

This document helps an AI assistant reconstruct sufficient working context from repository evidence. It is documentation only. It does not define project governance, project status, project authority, automation, linting, SYSTEM behavior, Platform Foundation, or an execution layer.

## Startup Reading Sequence

Read the following in order:

1. Project README: `docs/project/README.md`
2. Project Bootstrap: `docs/project/bootstrap/PROJECT_BOOTSTRAP.md`
3. Current Context: `docs/project/context/CURRENT_CONTEXT.md`
4. Current Status, if present: `docs/project/status/CURRENT_STATUS.md`
5. Today Objective, if present: `docs/project/status/TODAY_OBJECTIVE.md`
6. Daily Index: `docs/project/daily/INDEX.md`
7. Latest Daily Report
8. Active Task Record, if present
9. Relevant authoritative project records, if required, such as milestone records, closeouts, validation summaries, task records, or task evidence summaries

## Reconstruction Rules

- Do not rely on conversation memory.
- Do not guess context.
- Do not read the entire repository by default.
- Read summaries first, authoritative sources second.
- Use daily reports as history or audit only.
- Use `CURRENT_CONTEXT.md` as working context.
- If a listed or referenced file is missing or inaccessible, report it as missing evidence and do not reconstruct it from memory or prior conversation.
- If context conflicts, stop bootstrap, report the detected conflict, and request Project Owner clarification before continuing.

## Expected Bootstrap Output

Report the reconstructed Project Layer context from repository evidence, including:

- current project context;
- current milestone, phase, objective, active task, and context version status;
- current decision;
- active work and next action;
- blockers;
- pending Project Owner decisions, if any;
- applicable boundaries;
- missing or inaccessible evidence;
- source paths used for reconstruction.

## Boundary

Bootstrap defines how AI reconstructs context.

It does not define project governance, project status, project authority, automation, linting, SYSTEM behavior, M4, Platform Foundation, or any runtime architecture.
