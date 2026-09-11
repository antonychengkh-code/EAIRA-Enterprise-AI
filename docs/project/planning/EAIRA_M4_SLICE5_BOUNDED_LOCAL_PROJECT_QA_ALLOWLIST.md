# EAIRA M4 Slice 5 Bounded Local Project QA Allowlist

## Package Identity

- Decision: `SLICE5_A_BOUNDED_LOCAL_PROJECT_QA`
- Revision: 5.2
- State: `SLICE5_A_R5R2_STRUCTURED_OUTPUT_REMEDIATION_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW`
- Baseline: `b4a871ffa9b18c86179a79d3b876fd314f853f7b`

## Exact Source Allowlist

[Clause S5-ALLOW-SOURCES]

The current implementation candidate may open exactly these eleven repository-relative paths, in this order:

1. `docs/project/status/CURRENT_STATUS.md`
2. `docs/project/status/TODAY_OBJECTIVE.md`
3. `docs/project/status/ACTIVE_TASK.yaml`
4. `docs/project/status/AGENT_CONTEXT_VERSION.yaml`
5. `docs/project/memory/README.md`
6. `docs/project/memory/DECISION_INDEX.md`
7. `docs/project/memory/DISCOVERY_INDEX.md`
8. `docs/project/memory/PROCEDURE_INDEX.md`
9. `docs/project/memory/OPEN_QUESTIONS.md`
10. `docs/project/memory/STABILITY_CHECKLIST.md`
11. `docs/project/memory/MEMORY_SCHEMA.md`

Paths 1-4 are consumed only through the published Slice 3 loader and canonical projection. Paths 5-11 are consumed only through the published Slice 4 literal query and match projection. No caller value may alter the list or order.

Every listed file is mandatory. The implementation must not enumerate to locate it or observe any extra physical file. A twelfth compiled-in path, fallback path, link target, glob, caller path or dynamically discovered path is a static policy violation.

## Explicit Source Exclusions

[Clause S5-ALLOW-EXCLUSIONS]

The closed list excludes:

- `docs/project/memory/HANDOFF.md`;
- `docs/project/memory/MEMORY_INBOX.md`;
- `.obsidian/` and all hidden or conflict files;
- attachments, source code, tests, evidence and generated artifacts;
- Git objects, refs, config, worktrees and remote metadata;
- environment files, credentials, secrets and provider configuration; and
- every path not named in `S5-ALLOW-SOURCES`.

Wikilinks, Markdown links, transclusions, paths and instruction-shaped text are inert bytes. They are never followed, opened or executed.

## Root and Snapshot Controls

[Clause S5-ALLOW-ROOT]

The exact design must reuse the published Slice 3/4 platform controls and define one shared request-local root/session:

- absolute canonical EAIRA root;
- exact handle-derived full-path equality;
- pinned root and ancestor identity across all eleven reads;
- the exact accepted local/hydrated-directory/hydrated-file attribute/tag truth table;
- no Offline, RecallOnOpen or RecallOnDataAccess state;
- no directory enumeration;
- regular-file leaf identity;
- probe/content identity equality;
- stable volume/file identity, byte count and last-write time;
- read sharing only, with write/delete sharing denied;
- `FILE_OPEN_REPARSE_POINT` probe and `FILE_OPEN_NO_RECALL` content semantics;
- exactly one bounded content read per leaf; and
- fail-closed cleanup with all handles attempted in reverse ownership order.

The exact design must either keep the shared root/ancestor handles pinned across both the context and knowledge phases or independently prove one immutable root identity and non-overlapping leaf snapshots without a substitution window. A second root parse or path authority is prohibited.

## Exact Context Citation IDs

[Clause S5-ALLOW-CONTEXT-IDS]

The Slice 3 projection order is fixed to these 27 request-local IDs:

| ID | Source-qualified field |
| --- | --- |
| `C01` | `Current Status.Context ID` |
| `C02` | `Current Status.Version` |
| `C03` | `Current Status.Updated At` |
| `C04` | `Current Status.Current Milestone` |
| `C05` | `Current Status.Active Phase` |
| `C06` | `Current Status.Current Decision` |
| `C07` | `Current Status.Blockers` |
| `C08` | `Current Status.Next Action` |
| `C09` | `Today Objective.Date` |
| `C10` | `Today Objective.Milestone` |
| `C11` | `Today Objective.Current Scope` |
| `C12` | `Today Objective.Expected Deliverables` |
| `C13` | `Today Objective.Success Criteria` |
| `C14` | `Active Task.Task ID` |
| `C15` | `Active Task.Owner` |
| `C16` | `Active Task.Status` |
| `C17` | `Active Task.Priority` |
| `C18` | `Active Task.Last Updated` |
| `C19` | `Active Task.Dependency Count` |
| `C20` | `Active Task.Dependency SHA-256` |
| `C21` | `Agent Context Version.Context Version` |
| `C22` | `Agent Context Version.Last Updated` |
| `C23` | `Agent Context Version.Current Status Version` |
| `C24` | `Agent Context Version.Today Objective Version` |
| `C25` | `Agent Context Version.Knowledge Index Version` |
| `C26` | `Agent Context Version.Verified Agent Count` |
| `C27` | `Agent Context Version.Verified Agent SHA-256` |

The model may return only these IDs. The host reconstructs each accepted context citation as an ID, the exact owning repository-relative path, the exact field label and `CONTROLLED_SOURCE_REFERENCE_NOT_MODEL_AUTHORITY`. Raw context values are not repeated in the citation object.

## Exact Knowledge Citation IDs

[Clause S5-ALLOW-KNOWLEDGE-IDS]

The at-most-eight Slice 4 emitted matches receive request-local IDs `K01` through `K08` in their canonical emitted order. An ID exists only when the corresponding match exists.

The model may return only an existing `Knn` ID. The host reconstructs path, one-based line, heading, excerpt and `NAVIGATIONAL_NOT_AUTHORITY` from the request-local validated match table. The model cannot supply or override any citation metadata.

## Question Grammar

[Clause S5-ALLOW-QUESTION]

- The question is required and is also the Slice 4 literal retrieval query.
- Reject malformed UTF-16, normalize to Unicode Form KC, count Unicode scalar values, then reject controls.
- Normalized length is 1 through 64 Unicode scalar values.
- NUL, CR, LF, tab and every C0/C1 control are prohibited.
- Paths, commands, URLs, regular expressions, globs, wildcards, Markdown and prompt delimiters have no special meaning.
- The exact trace remains 32 uppercase hexadecimal characters.

Zero, 65 scalars, malformed surrogates or prohibited controls return `INVALID_REQUEST/64` before any file open or provider construction.

## Provider Allowlist

[Clause S5-ALLOW-PROVIDER]

The only functional provider selection is:

- selection: `ollama-local`;
- provider ID: `ollama-loopback-v1`;
- URI: `http://127.0.0.1:11434/`;
- model: `qwen3:4b`;
- full digest: `359d7dd4bcdab3d86b87d73ac27966f4dbb9f5efdfcc75d34a8764a09474fae7`; and
- at most one successful QA chat request, bounded by the existing preflight/postflight tags checks.

The existing no-redirect, no-proxy, no-credential, exact content-type, response-size, timeout, JSON-schema, model, digest and sanitized-diagnostic controls remain mandatory. A deterministic in-memory mock may be compiled into test outputs only and must have zero network metadata.

The canonical `api/chat` request retains `stream=false` and `think=false`, and its `format` is one fixed closed JSON Schema object rather than the legacy `"json"` shorthand. The schema requires only ordered properties `answer` and `citationIds`, requires both members, rejects additional properties, constrains `answer` to 1–512 characters, and constrains `citationIds` to at most eight unique strings. It guides generation only. The host-side strict decoder remains controlling for lexical member order, UTF-8, Unicode scalar and byte budgets, request-local citation membership/order, insufficient-evidence coupling and every fail-closed rule.

## Prompt Input Allowlist and Budgets

[Clause S5-ALLOW-PROMPT]

The model prompt may contain only:

1. a fixed versioned instruction and schema contract;
2. the normalized question;
3. the 27-field Slice 3 canonical projection, retaining source-qualified field names;
4. zero through eight emitted Slice 4 matches with their host-assigned `Knn` IDs; and
5. the exact set of valid `Cnn` and existing `Knn` citation IDs.

The absolute root, raw file bytes, frontmatter, per-file digests, handles, native results, environment values, credentials, non-emitted matches and error details are prohibited.

Hard limits:

| Item | Limit |
| --- | --- |
| normalized question | 1-64 Unicode scalar values |
| Slice 3 projection | existing maximum 10,000 UTF-8 bytes |
| knowledge matches | existing maximum 8 |
| logical QA prompt | maximum 12,000 strict UTF-8 bytes |
| complete canonical Ollama request body | existing maximum 16,384 bytes |
| provider response body | existing maximum 65,536 bytes |
| accepted answer | 1-512 Unicode scalar values and at most 2,048 strict UTF-8 bytes |
| accepted citation IDs | 0-8 unique IDs |
| complete successful outer stdout including LF | maximum 16,384 strict UTF-8 bytes |

No input or output is truncated to satisfy these limits. Exceeding any post-read prompt or QA-output limit rejects the complete request. Exact framing bytes and below/at/above golden vectors are mandatory outputs of the later exact-design Gate.

## Model Answer Schema

[Clause S5-ALLOW-MODEL-OUTPUT]

The assistant content must be one strict JSON object with exactly these members in this order:

1. `answer`: one well-formed string;
2. `citationIds`: one array of zero through eight unique strings.

The answer must contain 1-512 Unicode scalar values, encode to at most 2,048 strict UTF-8 bytes and contain no C0/C1 control. Duplicate members, unknown members, duplicate citations, nonexistent IDs, model-supplied paths/lines/fields, Markdown code fences, trailing documents, comments, tool calls, images or thinking output fail closed.

Zero citations are permitted only for the fixed insufficient-evidence answer selected by the later exact design. Every other accepted answer requires at least one citation. Citation validity establishes only that the cited item was in the prompt; it does not establish semantic entailment.

## Canonical Outer Result

[Clause S5-ALLOW-RESULT]

The later exact design must freeze one canonical JSON result with at least:

- schema and status;
- question, context-projection, knowledge-result-set, prompt and answer SHA-256 evidence;
- the bounded answer;
- fixed `MODEL_GENERATED_UNVERIFIED` and `ASSISTIVE_NOT_AUTHORITY` classifications;
- `network=LOOPBACK_ONLY` and `writes=NONE`;
- host-reconstructed context citations; and
- host-reconstructed knowledge citations.

It must never emit the absolute root, complete projection, raw prompt, raw provider response, raw file, frontmatter, per-file digest, handle, SID, credential, environment value, exception message or native diagnostic.

The output schema, field order, digest domains/framing, insufficient-evidence answer, exact success/error stdout and golden vectors are intentionally deferred to the separately authorized exact-design Gate. They may not be inferred by implementation.

## Error Boundary

[Clause S5-ALLOW-ERRORS]

The later exact design must preserve the established category separation and this exact precedence:

- `INVALID_REQUEST/64` for malformed CLI, trace, provider, model, question or lexically invalid root, determined by pure checks before Guard with zero file opens and zero provider activity;
- `DENIED/77` for static Guard denial, with zero file opens and zero provider activity;
- `LOCAL_PROVIDER_ERROR/79` for loopback provider lifecycle failure;
- `CONTEXT_ERROR/80` for semantic root/session establishment or controlled-context acquisition/schema/projection failure after Guard allows the request;
- `KNOWLEDGE_ERROR/81` for bounded knowledge acquisition/query failure or a cross-phase pinned-root/session invariant failure after context succeeds; and
- `PROJECT_QA_ERROR/82` for prompt-budget, model-answer-schema, citation or outer-output validation failure.

Every error is canonical and sanitized. There is no exception text, partial answer, partial citation set, raw content, absolute path or provider body.

The lexical root check validates only the closed DOS-path grammar selected by the exact design. It makes no filesystem call and establishes no semantic root fact. If any lexical input is invalid, `64` takes precedence. Otherwise Guard runs before semantic root validation; a denial returns `77`. Only an allowed request may enter the `80`, `81`, `79` and `82` stages in the processing order fixed by the scope decision.

## Current Determination

`SLICE5_A_R5R2_STRUCTURED_OUTPUT_REMEDIATION_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW`

This revision records the bounded structured-output remediation after two independently reviewed `PROJECT_QA_ERROR/82` live results. It does not weaken the answer validator or expand the source, provider, network, write or authority boundary.
