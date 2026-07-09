# EAIRA AI Bootstrap Access Observation - 2026-07-09

## Metadata

| Field | Value |
| --- | --- |
| Document Type | Project Observation Note |
| Status | Observation Recorded Only |
| Scope | Cross-model Bootstrap access behavior, single uncontrolled trial |
| Layer | Project Layer |
| Date | 2026-07-09 |

## Purpose

Record observations from an informal, single-trial test in which the same EAIRA Project Bootstrap task was given to multiple AI assistants (Claude, ChatGPT, Grok, Gemini, Perplexity, Copilot, Copilot M365) against the public GitHub repository.

This note records what was observed. It does not establish a validation suite, a model comparison standard, or a governance rule.

## Scope Boundary

This document records observations from one uncontrolled trial as of 2026-07-09. It does not establish a Bootstrap validation methodology, a model scoring system, a governance policy, or a repeatable benchmark. All observations are limited to what was directly reported or directly verified during this trial.

Out of scope:

- Ranking AI models by capability.
- Declaring any model's Bootstrap behavior superior to another's.
- Approving a validation suite or comparison report.
- Modifying governance or project status.

## Observation 1: Reported Results Varied Across AI Assistants

As reported in this trial, different AI assistants returned different results for the same Bootstrap task:

- Claude and ChatGPT reported PASS WITH DRIFT, citing specific repository file paths and content as evidence.
- Other assistants (Gemini, Perplexity, Copilot, Copilot M365) reported BLOCKED, stating they could not access repository content.

These are self-reported results from each assistant's own session. Only the Claude-session portion of this trial was independently re-verified by directly re-pulling repository content (see Observation 4); the other assistants' reported results are recorded here as reported, not independently confirmed.

This document does not treat the PASS WITH DRIFT results as more "correct" than the BLOCKED results. Both are evaluated separately in Observation 2.

## Observation 2: BLOCKED Is A Valid Outcome, Not A Failure

An assistant reporting BLOCKED when it cannot access repository evidence is consistent with an evidence-first approach: it did not guess repository state or fabricate a Bootstrap result in the absence of evidence. A model that answered PASS without verified repository access would be the more concerning outcome, not the reverse.

## Observation 3: This Trial Did Not Isolate Repository Access Capability From Bootstrap Reasoning

The trial did not separately test whether an assistant (a) could technically reach repository content, versus (b) could correctly perform Bootstrap reasoning once given that content. These are two different capabilities and this trial conflated them:

- An assistant that returned BLOCKED may have failed only at (a) - it may never have gotten repository content to reason over at all.
- An assistant that returned PASS WITH DRIFT succeeded at both (a) and (b), but this trial cannot show whether it would also have succeeded at (b) had it been given the same access-blocked condition as another assistant.

Because access and reasoning were not tested independently, results across assistants are not directly comparable on either dimension alone.

## Observation 4: Access Outcome Was Affected By Tool And Session Conditions, Not Only By The Assistant Itself

### Initial Access Failure

During this trial, in the Claude session specifically, an initial attempt using raw.githubusercontent.com, as instructed by the task, returned a 404 error - the same class of failure other assistants reported.

### Subsequent Access Success Under Different Session/Tool Conditions

A later attempt succeeded only after switching to a different, undirected method (codeload.github.com tarball download), which depended on that specific network domain being allowlisted in that session's tool configuration. Once initial repository content had been fetched and appeared in the conversation, subsequent fetches of related files were further constrained by a same-session tool rule permitting only URLs that had already appeared in prior search or fetch results in that conversation.

This indicates that, at least for the Claude session, successful repository access depended on: which tool method was attempted, which network domains were allowlisted for that tool in that session, and accumulated conversation history providing already-seen URLs. These are properties of the product/session configuration, not demonstrated properties of the underlying model's Bootstrap reasoning ability.

Repository evidence on the equivalent tool/network configuration for the other tested assistants (Gemini, Perplexity, Copilot, Copilot M365, Grok, ChatGPT) was not available to this note's author, so no comparison of underlying access conditions across assistants can be made.

## Observation 5: "M3 Completed" Is An Inference, Not A Single-Document Declaration

Repository evidence includes closeout records for M3 Phase 1 (`docs/project/phases/EAIRA_M3_PHASE1_CLOSEOUT.md`), M3.2, M3.3, and M3.4 individually. No repository file titled or functioning as an M3 Closeout covering the milestone as a whole was found. A statement that "M3 is completed" would combine these separate records into a conclusion that no single authoritative document states directly.

## Observation 6: This Trial Is Not Repeatable As Currently Run

The following were not held constant or recorded across assistants during this trial:

- Exact prompt delivery method and timing per assistant.
- Whether each assistant's product interface had network/tool access enabled at all, and to which domains.
- Whether each assistant session carried any prior conversation context.

Without these being controlled and recorded, a second run of this same trial could plausibly produce different PASS / BLOCKED outcomes for the same assistants without any change in underlying model capability.

## Observation 7: A Self-Reported Commit Could Not Be Independently Confirmed

During follow-up discussion of this note, one assistant (Grok) reported having created and pushed this file to `docs/project/notes/` with a specific commit hash, and described the local repository status as clean. A direct re-pull of the public repository's master branch, performed independently after that report, did not show this file present in `docs/project/notes/`.

This does not establish what happened on Grok's side (whether the commit was local-only and not pushed, pushed to a different branch, or not actually made despite being reported as made). It is recorded here only as an observed discrepancy between a self-reported execution result and independently re-verified repository state, consistent with the independent-verification requirement already recorded in `docs/tasks/M3_4_FINANCE_REVENUE_INPUT_TASK_RECORD.md` (Validated Constraint VC-M3.4-002: agent self-reporting must never be treated as sufficient evidence alone).

## Evidence Boundary

This note summarizes what was observed and reported during a single, informal cross-model trial on 2026-07-09. It does not reinterpret, supersede, or replace authoritative project records. It does not establish a Bootstrap validation suite, a model comparison methodology, a scoring system, or a governance rule.

## No Action Taken

No validation suite is created by this note.

No model comparison report is created by this note.

No governance decisions are recorded.

No repository modifications beyond this note are performed.

## Status

Observation Recorded Only

These observations are insufficient to justify a Validation Spec, a model comparison standard, or a governance artifact. Further evaluation, including a controlled re-run with access conditions held constant and independently re-verified rather than self-reported, would be required before any of these observations could support one.
