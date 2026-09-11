# EAIRA M4 Slice 5 Bounded Local Project QA Threat Model

## Package Identity

- Decision: `SLICE5_A_BOUNDED_LOCAL_PROJECT_QA`
- Revision: 5.2
- State: `SLICE5_A_R5R2_STRUCTURED_OUTPUT_REMEDIATION_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW`
- Baseline: `b4a871ffa9b18c86179a79d3b876fd314f853f7b`

## Security Objective

Provide useful local project Q&A from the published bounded context, knowledge and Ollama-loopback surfaces without turning repository text or model output into instructions, authority, arbitrary file access, external communication, persistence or an execution capability.

## Protected Assets

- confidentiality of every file and value outside the eleven-path source allowlist;
- authority and integrity of the four controlled status artifacts;
- integrity of the published Slice 2 provider and Slice 3/4 read-only platforms;
- absence of runtime writes, persistence, external network and credential access;
- separation of untrusted source text, model-generated text and Project Owner authority;
- bounded canonical output and sanitized failures; and
- reproducible evidence suitable for independent review.

## Trust Boundaries

[Clause S5-THREAT-BOUNDARIES]

- CLI arguments, repository root and question are untrusted.
- All bytes obtained from the eleven allowlisted files are untrusted data.
- Memory text is navigational and never authoritative.
- Controlled status remains authoritative only through the existing `AGENTS.md` precedence, not because it appears in a model prompt.
- The Ollama listener and returned content are untrusted even though transport is loopback.
- Exact model name/full-digest checks are trusted-local consistency checks, not cryptographic identity.
- The model prompt is not a policy boundary.
- Model-generated answers and citations are untrusted until deterministic parsing; after parsing they remain `MODEL_GENERATED_UNVERIFIED`.
- Only compiled source tables, deterministic validators and separately verified Git evidence may establish scope or lifecycle facts.

## Threats and Required Controls

| Threat | Required fail-closed control |
| --- | --- |
| Alternate root, traversal or name substitution | one canonical root/session; pinned ancestors; handle-derived exact full paths; exact eleven-path list |
| OneDrive hydration, recall or TOCTOU | published Slice 3/4 no-recall, attribute/tag, identity, stability, sharing and cleanup controls |
| Hidden file or candidate-memory access | no enumeration; `HANDOFF`, `MEMORY_INBOX`, `.obsidian` and all non-allowlisted paths statically excluded |
| Prompt injection in status or memory | length-framed data sections; instruction-shaped bytes inert; deterministic static Guard and output validator; fixed non-authority label |
| Prompt delimiter collision | exact byte framing and length prefixes; no delimiter-based parsing of untrusted payloads |
| Source text claims authority | host-fixed authority labels; model cannot emit a decision, approval or state transition |
| Citation hallucination or spoofing | model returns IDs only; unique subset check; host reconstructs every path/field/line/excerpt |
| Unsupported answer presented as fact | `MODEL_GENERATED_UNVERIFIED` and `ASSISTIVE_NOT_AUTHORITY` always emitted; citation presence is not entailment |
| Raw-file, context or prompt exfiltration | provider receives projection/matches only; answer/citation/output budgets; raw projection/prompt/provider body prohibited from output |
| Sensitive diagnostics | fixed sanitized errors; no exception, native error, endpoint, root, prompt or provider body |
| External provider or proxy escape | exact IPv4 loopback URI, model and digest; no redirect/proxy/credential/config fallback |
| Local listener impersonation | preflight/postflight exact name/full-digest check; disclose trusted-local limitation; fail closed on any mismatch |
| Retry amplification or multiple model calls | at most one QA chat; no retry, fallback or degraded mode |
| Source mutation between retrieval and prompt | one request-local pinned session; stable identities/metadata; prompt constructed only after both source phases validate |
| Cross-request data retention | request-scoped objects only; no persistence, telemetry, durable cache or raw-content logs |
| Output parser confusion | fixed closed request-side JSON Schema plus strict host UTF-8/JSON validation; exact members/order; no duplicates, extras, trailing document, comments, tool calls, thinking or images |
| Oversized input/output denial or leakage | all source, projection, prompt, provider, answer, citation and outer-output budgets checked without truncation |
| Guard bypass | static preauthorization before any file open, provider construction or network activity; deny path has exact zero-open/zero-call evidence |
| Capability creep | exact design, source/metadata inventories, changed-path manifest and compiled negative specimens |
| Stale or contradictory project state | preserve source identity and authority order; report uncertainty; never silently reconcile or choose a new decision |
| Ollama-side storage or network behavior | client claims limited to its own `LOOPBACK_ONLY`/`NONE` behavior; daemon behavior explicitly outside claim |

## Prompt-Injection Controls

[Clause S5-THREAT-INJECTION]

The later exact design must ensure:

1. fixed instructions are generated by code and are not read from the repository;
2. every question, context field and knowledge match is length-framed and carries a fixed untrusted-data classification;
3. source text cannot introduce a new role, message, tool, path, citation or output schema;
4. the provider receives no capability token, credential, writable destination or callable tool;
5. the model's only accepted control output is a strict answer string plus citation-ID array;
6. deterministic code rejects any unknown or non-existing citation ID and reconstructs citations itself;
7. answer validation occurs before canonical output; and
8. even a fully injected answer has no write, execution, authority or external-network effect.

No prompt instruction can replace these controls. Tests that merely ask the model to ignore malicious instructions are insufficient.

## Data-Leakage Controls

[Clause S5-THREAT-LEAKAGE]

- Only the canonical 27-field projection and zero-to-eight bounded knowledge matches may enter the provider prompt.
- No raw source document, frontmatter, non-emitted match, absolute root, handle, SID, environment value, credential or per-file digest may enter.
- The outer result may emit the answer, evidence digests and host-reconstructed selected citations only.
- Context citations expose field identity but do not repeat the field value.
- Knowledge citations expose only the already bounded path, line, heading and excerpt from the emitted match.
- No raw prompt, raw provider response, provider request/response body, exception or diagnostic is emitted or logged.
- Output limits reduce exposure but do not prove source text is non-sensitive. The scope package makes no such claim.
- The local Ollama daemon may independently store model files, caches or logs; this package neither verifies nor controls those behaviors.

## Mandatory Abuse Matrix

[Clause S5-THREAT-MATRIX]

The implementation evidence must include stable-name cases for all of the following.

### CLI and preauthorization

- missing, duplicate, reordered, alternate and extra arguments;
- invalid trace, provider, model, question and every rejected lexical-root form, all producing `INVALID_REQUEST/64` with zero opens and zero provider activity;
- question scalar boundaries 0/1/64/65, malformed surrogate and every prohibited control class;
- combined-precedence cases proving lexical invalidity returns `64` before Guard, while a lexically valid root plus unsafe question is denied before semantic root validation, file open, provider construction, tags or chat;
- deny-path counters proving zero source and provider activity; and
- inaccessible, missing, substituted and state-invalid roots proving post-Guard semantic-root failures return only `CONTEXT_ERROR/80`.

### Root, source and snapshot

- every Slice 3 and Slice 4 root/path/state/identity/stability/native-failure case remains passing;
- exact eleven source paths and order;
- compiled twelfth path rejected;
- direct/indirect open and enumeration attempts rejected;
- unrelated physical files ignored without enumeration;
- replacement before probe, between probe/content, after content and between context/knowledge phases;
- context succeeds then knowledge fails, knowledge succeeds then prompt preflight fails, and cleanup precedence in every phase;
- root/session identity mismatch between the Slice 3 and Slice 4 components rejected.

### Prompt injection

- instruction-shaped text in the question and in every context and knowledge source position;
- fake system/developer/user roles;
- attempts to close framing, inject length fields or create an additional message;
- Markdown links, wikilinks, transclusions, code fences, XML/JSON/YAML fragments and shell/PowerShell text;
- requests to reveal prompt, raw context, hidden files, credentials, handles or absolute root;
- requests to ignore authority labels, approve a Gate, modify a Field, write a file or call a tool;
- Unicode confusables, NFKC changes, bidi controls and non-ASCII whitespace;
- injected valid-looking citation IDs, nonexistent IDs and another request's IDs.

### Provider and transport

- listener unavailable, timeout at each stage, non-200 status and redirect;
- proxy/environment configuration ignored or rejected;
- wrong model name, duplicate model, missing model and pre/post digest mismatch;
- content-type and encoding variants, length boundaries, short/partial stream and trailing bytes;
- response JSON duplicate/extra/missing members, comments, trailing documents and malformed Unicode;
- tool calls, images, thinking output, streaming response and multiple assistant messages;
- exact structured-output schema, retained `think=false`, rejection of legacy `format:"json"`, reordered properties, removed required members, widened limits and `additionalProperties=true`;
- proof of at most one QA chat and no retry/fallback.

### Model-answer schema and citations

- exact valid answer with context-only, knowledge-only and mixed citations;
- zero citations only with the fixed insufficient-evidence answer;
- empty/oversized/control-containing/malformed answer;
- answer scalar and UTF-8 byte below/at/above limits;
- duplicate, more-than-eight, unknown, malformed, reordered and cross-request citation IDs;
- model-supplied path, field, line, heading, excerpt or authority member rejected;
- model response that echoes the complete projection, prompt or provider body rejected by structural/output isolation controls;
- host reconstruction proves emitted citation metadata equals the request-local validated source table.

### Output and lifecycle

- exact canonical success and every error channel;
- output below/at/above 16,384 bytes with no truncation fallback;
- no raw projection, prompt, provider body, absolute root, per-file digest, handle, SID, environment or credential fields;
- fixed classifications `MODEL_GENERATED_UNVERIFIED` and `ASSISTIVE_NOT_AUTHORITY` cannot be changed by model output;
- deterministic mock A/B outputs and case-name inventory are byte-identical;
- live-loopback evidence records nondeterminism without claiming byte equality of model text;
- zero file, registry, database, evidence, telemetry and audit writes by EAIRA;
- no external socket destination and no Windows service/IPC/process/shell activity.

### Verifier resistance

- extra source path, provider, endpoint, model, message, chat call, retry or fallback;
- widened answer/citation/prompt/output budgets;
- raw projection, prompt or provider response added to result/diagnostic objects;
- model-provided citation metadata accepted directly;
- removal or mutation of authority classifications;
- reordered validation that opens files or constructs provider before Guard denial;
- alternate parser, unbounded read/helper, logging sink, persistence API, process/shell API or dynamic code;
- every negative specimen must compile successfully and then be rejected by the production verifier.

## Residual Risks and Non-Claims

[Clause S5-THREAT-NONCLAIMS]

This Slice cannot prove:

- that model text is true, complete, unbiased or semantically entailed by citations;
- that repository text is current, non-malicious, non-sensitive or conflict-free;
- that the local Ollama process is authentic, isolated, non-persistent or offline;
- that loopback traffic is confidential from administrators or local privileged software;
- that citation presence makes an answer authoritative;
- that M4 is production-ready, signed, packaged or safe for customer deployment; or
- that any Annex Field, category, blocker or Gate is resolved.

The safe failure is no answer plus one sanitized status. Human verification against authoritative repository sources remains mandatory before acting on generated content.

## Current Determination

`SLICE5_A_R5R2_STRUCTURED_OUTPUT_REMEDIATION_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW`

The R5 remediation changes request-side generation constraints only. All host-side validation, safe failure, no-retry, loopback-only and no-write controls remain mandatory.
