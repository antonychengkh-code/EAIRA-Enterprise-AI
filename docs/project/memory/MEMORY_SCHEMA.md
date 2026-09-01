---
type: project-memory-schema
status: active
created: 2026-08-26
updated: 2026-08-26
source: codex
project: EAIRA
authority: operational-guidance
---

# Project Memory Schema

## Required Frontmatter

Every file in this folder uses:

```yaml
---
type: <memory-document-type>
status: <active|candidate|deferred|superseded>
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: <origin>
project: EAIRA
authority: <navigational|provisional|operational-guidance>
---
```

## Candidate Entry

Each candidate in `MEMORY_INBOX.md` must include:

- Capture date
- Summary
- Evidence or source paths
- Confidence
- Proposed canonical destination
- Reason it may be durable
- Approval state

Candidates are not decisions, authorizations, verified current state, or evidence of execution.

## Promotion Rule

A candidate may be promoted only after explicit Project Owner authorization. Promotion means updating the existing canonical project artifact and then replacing the candidate with a link to that artifact. The memory folder must not become a parallel source of truth.
