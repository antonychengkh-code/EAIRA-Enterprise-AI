# EAIRA M4 Functional Agent MVP Slice 5 Scope Decision

## Document Metadata

| Field | Value |
| --- | --- |
| Decision ID | `SLICE5_A_BOUNDED_LOCAL_PROJECT_QA` |
| Decision date | 2026-09-10 |
| Decision authority | Human Project Owner |
| Decision state | `SLICE5_A_R3_SCOPE_PACKAGE_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW` |
| Product baseline | `b4a871ffa9b18c86179a79d3b876fd314f853f7b` |

## Decision

The Human Project Owner selects `SLICE5_A_BOUNDED_LOCAL_PROJECT_QA` as the next bounded M4 product slice.

Slice 5 will plan one local, no-write project-question-answering surface that composes only the already published Slice 2 Ollama loopback provider, Slice 3 controlled project-context projection and Slice 4 bounded project-knowledge query. This decision authorizes planning documents only. It does not authorize implementation or repository recording.

## Intended User Value

A local user can ask one bounded project question and receive:

- one short model-generated answer;
- an explicit `MODEL_GENERATED_UNVERIFIED` classification;
- validated citations limited to source-qualified Slice 3 context fields and emitted Slice 4 knowledge matches;
- deterministic source, prompt-input and answer evidence digests;
- explicit `LOOPBACK_ONLY` network and `NONE` write classifications; and
- sanitized failure results that expose no root, raw file, prompt, provider body or native diagnostic.

The answer is assistive navigation. It is not project authority, approval, a decision, a Gate result, a Field transition, an instruction to execute, or evidence that a cited source supports every generated claim.

## Exact Composition Boundary

[Clause S5-SCOPE-COMPOSITION]

The future exact design must compose, without widening them:

1. `ollama-loopback-v1` with exact model `qwen3:4b` and the full digest already fixed by `EAIRA_LOCAL_MODEL_PROVIDER_V1`;
2. the exact four controlled files and 27-field bounded projection fixed by `EAIRA_READ_ONLY_PROJECT_CONTEXT_V1`; and
3. the exact seven memory-navigation files, literal matching rules and at-most-eight emitted matches fixed by `EAIRA_PROJECT_KNOWLEDGE_QUERY_V1`.

The future product must use one canonical root identity across all eleven source files. It may not enumerate, discover, accept or infer another path. `HANDOFF.md`, `MEMORY_INBOX.md`, `.obsidian`, attachments, evidence, source code, Git metadata, secrets and all other files remain excluded.

## Proposed Product Surface

The proposed separate local executable is:

```text
EAIRA.ProjectQa.Cli.exe --root <absolute-EAIRA-root> --trace <32-uppercase-hex> --question <literal-question> --provider ollama-local --model qwen3:4b
```

An offline deterministic mock surface may exist only for tests. Any non-mock functional runtime of this Slice is fixed to the existing loopback provider identity. This wording grants no production-activation authority. No endpoint, hostname, port, URL, model, digest, proxy, credential, environment-variable configuration, response file or implicit default is caller-selectable.

The question is also the Slice 4 literal retrieval query. It must therefore use the stricter shared grammar: Unicode Form KC, 1 through 64 Unicode scalar values, no malformed UTF-16 and no C0/C1 control. Regex, glob, wildcard, path, URL, command and prompt-template syntax have no special meaning.

## Required Processing Order

[Clause S5-SCOPE-ORDER]

A future implementation may proceed only in this order:

1. validate the exact CLI shape and perform pure lexical checks of trace, provider, model, question and root without opening a file, constructing a provider or performing network activity; any failure is `INVALID_REQUEST/64`;
2. run deterministic static Guard preauthorization; a denial is `DENIED/77` with zero file opens and zero provider activity;
3. establish and semantically validate one pinned read-only root/session identity; failure is `CONTEXT_ERROR/80`;
4. load the exact Slice 3 controlled projection; failure is `CONTEXT_ERROR/80`;
5. execute the exact Slice 4 literal knowledge query against the seven compiled-in files under the same pinned root/session; acquisition, query or cross-phase session-invariant failure is `KNOWLEDGE_ERROR/81`;
6. construct one domain-separated, length-framed prompt within a fixed byte preflight; failure is `PROJECT_QA_ERROR/82`;
7. perform the existing preflight model-name/full-digest check; failure is `LOCAL_PROVIDER_ERROR/79`;
8. make at most one project-QA chat request; failure is `LOCAL_PROVIDER_ERROR/79`;
9. perform the existing postflight model-name/full-digest check; failure is `LOCAL_PROVIDER_ERROR/79`;
10. strictly parse and validate one bounded answer object; failure is `PROJECT_QA_ERROR/82`;
11. accept citations only when they reference an exact context-field ID or emitted knowledge-match ID from this request; failure is `PROJECT_QA_ERROR/82`; and
12. emit one canonical outer result or one sanitized error; output-schema or output-budget failure is `PROJECT_QA_ERROR/82`.

Any failure rejects the complete request. There is no partial answer, fallback provider, second model attempt, automatic retry or degraded ungrounded mode.

The lexical root check is grammar-only. It cannot establish existence, identity, state, authorization or accessibility. When more than one input is invalid, step order controls the single result: lexical invalidity returns `64` before Guard; with all lexical inputs valid, Guard denial returns `77` before any semantic root operation.

## Prompt and Output Authority

[Clause S5-SCOPE-AUTHORITY]

- Controlled context values and knowledge excerpts are delimited untrusted data, never instructions.
- Prompt text is not a security boundary; deterministic code must enforce every capability and output restriction.
- The model may select only citation identifiers supplied in the prompt. It cannot create a new path, field, line number or authority label.
- The host reconstructs citation details from its validated request-local source table; model-supplied citation metadata is prohibited.
- The outer answer classification is always `MODEL_GENERATED_UNVERIFIED` and `ASSISTIVE_NOT_AUTHORITY`.
- No generated text changes a controlled status, decision, task, blocker, Field, Gate, file or system.
- Conflicting or stale sources are surfaced as an uncertainty; the model cannot choose a new authority order.
- The authoritative sources and conflict rules in `AGENTS.md` remain controlling.

## Privacy and Data-Minimization Boundary

[Clause S5-SCOPE-DATA]

- The provider receives only the bounded Slice 3 canonical projection, the at-most-eight Slice 4 emitted matches, the normalized question and fixed framing/instructions.
- Raw files, frontmatter, absolute root, per-file digest, handles, SIDs, environment values, credentials, secrets, Git metadata and non-emitted matches must not enter the prompt or output.
- The client performs no persistence, telemetry, cache beyond the request, raw-content logging or diagnostic body logging.
- The answer and citations use independent byte/count budgets fixed by the allowlist.
- EAIRA may assert only `network=LOOPBACK_ONLY` and `writes=NONE` for its own process. Ollama daemon model storage, cache, logs and provider-side behavior remain outside this claim and must be disclosed.

## Explicit Exclusions

This decision does not authorize:

- implementation, source-code or contract changes;
- arbitrary vault search, directory enumeration, caller-selected paths or link following;
- external providers, internet endpoints, credentials, secrets, enrollment or billing;
- runtime repository, file, registry, database, evidence, memory or audit writes;
- persistent history, cross-request cache, telemetry or automatic memory promotion;
- Windows services, IPC, listeners, service routing or multi-process orchestration;
- accounts, groups, memberships, directories, ACLs, encryption or backup changes;
- certificate acquisition, HSM, signing, packaging, customer deployment or production activation;
- staging, commit, push, force push or checkpoint-ref repair; or
- closure of production-signing Gate 24, Gate 25, Field 8, Field 9 or any Annex blocker.

## Acceptance Boundary

Eligibility is phase-specific and strictly forward-only:

- Exact-design work becomes eligible only after the scope-package review closes with no P0 or P1.
- Bounded implementation and offline evidence become eligible only after the exact-design review closes with no P0 or P1.
- Live-loopback validation becomes eligible only after the implementation-and-abuse review closes with no P0 or P1.
- Exact staging becomes eligible only after both the implementation-and-abuse review and live-loopback review close with no P0 or P1.
- Exact commit becomes eligible only after the staged-snapshot review closes with no P0 or P1.
- Normal push becomes eligible only after the post-commit verification closes with no P0 or P1.
- Post-publication controlled-state and HANDOFF synchronization becomes eligible only after post-push publication verification closes with no P0 or P1.
- Synchronization staging, commit and normal push each become eligible only after their immediately preceding review or verification Gate closes with no P0 or P1.

No downstream review, evidence, staging, commit or push is a prerequisite for beginning an earlier phase. It is instead the result of that earlier phase and its own separately identified Gate.

## Current Determination

`SLICE5_A_R3_SCOPE_PACKAGE_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW`

Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_R3_SCOPE_PACKAGE_REVIEW`.

No implementation, staging, commit or push is authorized by this decision package.
