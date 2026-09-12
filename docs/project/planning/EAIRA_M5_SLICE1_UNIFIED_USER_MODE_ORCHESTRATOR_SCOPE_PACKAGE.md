# EAIRA M5 Slice 1 Unified User-Mode Orchestrator Scope Package

## Document control

- Package ID: `EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_V1`
- Prepared on: `2026-09-12`
- Preparation Gate: `SEPARATE_EVIDENCE_DRIVEN_EAIRA_M5_SLICE1_SCOPE_PACKAGE_PREPARATION`
- Baseline commit: `c50ccb8d22926220ac8712aaaa9eaacff1e9de93`
- Baseline remote: `origin/master` at the same commit when this package was prepared
- Milestone: `M5_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW`
- Slice: `M5 Slice 1 — Unified User-Mode Orchestrator`
- State: `CANDIDATE_READY_FOR_INDEPENDENT_SCOPE_REVIEW`
- Implementation authority: `NOT_GRANTED`
- Scope selection: `NOT_YET_RECORDED`
- Classification: planning candidate; not runtime authority, not an implementation design, and not a release artifact
- Exact current working-tree change manifest: this file only
- Required next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_REVIEW`

## 1. Authority and non-authority boundary

This package is prepared under the exact authority named above. It may define and compare bounded Slice 1 scope candidates and may identify evidence-backed requirements for later design. It does not select a candidate and does not authorize implementation.

This Gate does not authorize:

- modification of any product source, contract, test, harness, build script or release profile;
- arbitrary vault reads or any widening of the M4 source allowlists;
- a live model call, provider discovery, provider fallback or external provider use;
- Windows, service, IPC, account, group, membership, directory, ACL, BitLocker, TPM, certificate or signing changes;
- runtime persistence, shell execution, child-process launch, dynamic code load or repository writes;
- controlled-status, `CURRENT_CONTEXT` or `HANDOFF` synchronization;
- staging, commit, push or force push.

The M5 charter contains candidate-stage wording in its own document-control block. That wording is historical evidence of the charter's preparation state. The published controlled status at baseline `c50ccb8...` is the current authority: M4 is closed, M5 is active, `M5_A_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW` is selected, and this Slice 1 scope-package Gate is authorized. This package does not rewrite the published charter.

## 2. Evidence basis

### 2.1 Published M4 capability surfaces

| Capability | Published entry point | Execution shape | Read boundary | Provider boundary | Five-Agent state |
|---|---|---|---|---|---|
| Task intake | `EAIRA.AgentTask.Cli.exe` | Parses one bounded task and executes the minimum functional pipeline | Optional four-file project context | deterministic mock or exact Ollama loopback `qwen3:4b` | Full Planning → Guard → Operations → Verification → Audit pipeline |
| Project knowledge | `EAIRA.ProjectKnowledge.Cli.exe` | Deterministic bounded search over the published knowledge set | Exact seven-file knowledge allowlist | None | Standalone query path; no enclosing five-Agent lifecycle |
| Project QA | `EAIRA.ProjectQa.Cli.exe` | Static Guard preauthorization, context/knowledge snapshot, one bounded prompt and one provider chat | Exact four context files plus seven knowledge files | Exact Ollama loopback `qwen3:4b`; tags/chat/tags | Guard is explicit; remaining five-Agent ownership is not expressed as one lifecycle |

### 2.2 Source and contract observations

The baseline supports the following facts:

1. `AgentTaskIntakeHost` delegates to `LocalTaskIntake`, which creates a `TaskEnvelope`, obtains `GuardAgent.ExpectedDecision`, and constructs or uses a provider only after an allow decision.
2. `MinimumFunctionalPipeline` implements the full five-role chain. Its denial path contains Planning, Guard and Audit; its allow path contains all five roles.
3. `ProjectKnowledgeHost` accepts exactly `--root <ROOT> --query <QUERY>`, performs deterministic read-only work and emits `EAIRA_PROJECT_KNOWLEDGE_QUERY_V1` or its fixed error schema.
4. `ProjectQaHost` accepts the exact published seven-argument-value form, obtains static Guard authorization before reading, then builds one bounded prompt and invokes the exact local provider lifecycle.
5. Project QA output is capped at 16,384 bytes and does not emit the root, raw projection, raw prompt, request body, raw provider response or per-file digest.
6. The release profile binds the published M4 contracts, exact provider/model/digest, output limits, harnesses, source list and unsigned artifacts.
7. No published single entry point currently routes among task intake, project knowledge and project QA.

### 2.3 Problem statement

M5 Slice 1 must produce one coherent local operator entry point without turning the program into a launcher, a shell, a privileged host or an authority source. The central difficulty is not command selection. It is preserving the existing Guard-before-read/provider boundary, route-specific call counts, exact allowlists, output isolation and five-Agent responsibility while three independently published M4 surfaces become one workflow.

## 3. Scope candidates

### 3.1 Candidate A — `M5S1_A_IN_PROCESS_THREE_ROUTE_ORCHESTRATOR` (recommended)

Create one user-mode executable, provisionally named `EAIRA.LocalOperator.Cli.exe`, with three explicit routes: `task`, `knowledge` and `project-qa`. Compile and call reviewed components in-process. Do not spawn the three legacy executables. Preserve the legacy executables and their public contracts unchanged during Slice 1.

For `knowledge` and `project-qa`, add an outer deterministic five-Agent orchestration record while retaining their published M4 data readers, provider call counts and canonical payload serializers. The outer record must not create extra model calls.

Why recommended:

- It satisfies the M5 charter's single-entry and five-Agent ownership goals.
- It preserves route-local security controls rather than duplicating their implementations in a launcher.
- It supports deterministic offline verification and one later bounded loopback validation.
- It provides a migration path while keeping M4 CLIs available as compatibility surfaces.

### 3.2 Candidate B — `M5S1_B_IN_PROCESS_ROUTE_ADAPTER_WITHOUT_FULL_ROLE_UNIFICATION`

Create the same three-route executable and call existing components in-process, but expose no new five-Agent lifecycle around knowledge or project QA.

Trade-off: this is smaller, but it does not fully meet the charter requirement that the five-Agent roles remain explicit across the integrated workflow. It should be accepted only if the independent review demonstrates that explicit five-role ownership is deferred by a separately approved charter interpretation.

### 3.3 Candidate C — `M5S1_C_PROJECT_QA_ONLY_OPERATOR_ENTRY`

Expose only bounded project QA through a new operator CLI and defer task and knowledge routing.

Trade-off: this is the smallest runtime change, but it does not establish the charter's canonical multi-capability entry point. It is a fallback slice, not the recommended Slice 1 scope.

### 3.4 Decision state

No candidate is selected by this preparation Gate. Candidate A is the package recommendation. Selection requires a separate Human Project Owner decision after independent review.

## 4. Proposed exact boundary for Candidate A

### 4.1 Included

- One unsigned, unprivileged, console-mode Windows executable.
- Three and only three explicit capabilities: task, knowledge and project QA.
- In-process invocation of reviewed M4 components; no child process.
- A closed, versioned request, routing, result/error and provenance contract.
- A static Guard preauthorization before any project-file read or provider construction.
- Explicit five-Agent ownership for every accepted or denied request.
- Exact preservation of published context and knowledge allowlists.
- Exact preservation of the approved loopback address, model name, model digest and call counts.
- Deterministic offline harnesses, abuse cases, metadata verification and reproducible A/B build evidence.
- One separately authorized live loopback validation after offline review passes.
- Compatibility verification for every existing M4 CLI and contract.

### 4.2 Excluded

- Interactive REPL, graphical UI, web UI, tray application or background resident process.
- Service installation, scheduled execution, startup registration, IPC listener or remote endpoint.
- Arbitrary file browsing, directory enumeration, globbing, symlink traversal or user-defined allowlists.
- Repository mutation, note editing, decision writing, source refresh or automatic memory update.
- External provider, provider selection by URI, model selection outside the exact pinned model, retry or fallback.
- Retrieval from the Internet, plugin/MCP invocation, tool calls, shell commands or child processes.
- Authentication, authorization persistence, multi-user concurrency or cross-process replay storage.
- Credentials, secrets, certificates, signing, installer, auto-update or customer distribution.
- Removal or behavioral change of an existing M4 CLI.

## 5. User stories and operator outcomes

1. A local operator can submit a bounded task through one canonical executable and receive the existing five-Agent task result inside a versioned operator result.
2. A local operator can query the exact seven-file project knowledge set through the same executable without invoking a model.
3. A local operator can ask a bounded project question through the same executable and receive an assistive, citation-bearing, locally generated answer.
4. A request that Guard denies produces a deterministic denial with zero file reads, zero provider construction and zero provider calls.
5. A malformed or ambiguous command fails before route selection, read or provider activity.
6. A route cannot borrow flags, readers, provider privileges or output fields from another route.
7. The operator can identify the selected capability, trace ID, authority class, network class, write class and cryptographic provenance without seeing raw roots, prompts, source content, provider bodies or credentials.
8. Existing M4 callers continue to receive the exact published behavior from the legacy CLIs.

## 6. Proposed closed command surface

The exact executable name remains provisional until the scope decision. Candidate A proposes these and only these forms:

```text
EAIRA.LocalOperator.Cli.exe task --provider mock --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe task --provider mock --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe knowledge --root <ROOT> --trace <TRACE> --query <QUERY>
EAIRA.LocalOperator.Cli.exe project-qa --root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b
```

Closed parsing requirements:

- `<TRACE>` is exactly 32 uppercase hexadecimal characters.
- Every flag appears exactly once, in the exact order shown.
- `task` inherits the published goal length and static Guard rules.
- `knowledge` inherits the published query length and normalization rules.
- `project-qa` inherits the published question length and normalization rules.
- `<ROOT>` must pass the applicable published native-path and Cloud Files checks before any content read.
- No aliases, abbreviations, combined flags, response files, stdin input, environment substitution or configuration file are accepted.
- Extra, missing, duplicate, case-variant or cross-route flags return invalid request.
- No implicit default capability, provider, model or root exists.
- `--help`, `--version` and diagnostic modes are outside Slice 1 unless a later exact design adds fixed, data-free forms.

## 7. Capability routing and preserved budgets

| Route | Data reads after allow | Provider | Network | Writes | Required call-count rule |
|---|---|---|---|---|---|
| `task` / mock / no context | None | Published deterministic mock | `NONE` | `NONE` | Exact M4 task lifecycle |
| `task` / mock / context | Exact four-file context allowlist | Published deterministic mock | `NONE` | `NONE` | Exact M4 context task lifecycle |
| `task` / Ollama / no context | None | Exact pinned loopback provider | `LOOPBACK_ONLY` | `NONE` | Exact M4 local-provider lifecycle |
| `task` / Ollama / context | Exact four-file context allowlist | Exact pinned loopback provider | `LOOPBACK_ONLY` | `NONE` | Exact M4 context/provider lifecycle |
| `knowledge` | Exact seven-file knowledge allowlist | None | `NONE` | `NONE` | Zero provider construction and zero provider calls |
| `project-qa` | Exact four context plus seven knowledge files | Exact pinned loopback provider | `LOOPBACK_ONLY` | `NONE` | Exactly tags/chat/tags; no retry or fallback |
| Any Guard denial | None | None | `NONE` | `NONE` | Zero readers, provider construction, tags and chat calls |

Routing must be a closed enum dispatch. It must not use reflection, dynamic loading, executable lookup, shell association, file extension dispatch, URI activation or child-process execution.

## 8. Five-Agent ownership and call graph

### 8.1 Common preauthorization boundary

All routes must use the same published `TaskEnvelope` identity rules and `GuardAgent.ExpectedDecision`. Static Guard preauthorization occurs immediately after lexical/semantic request validation and before project-path resolution that could read content, Cloud Files hydration checks that could trigger I/O, provider construction or provider calls.

```text
argv bytes
  -> closed lexical parser
  -> normalized LocalOperatorRequest
  -> TaskEnvelope + request digest
  -> static Guard preauthorization
       DENY -> sanitized Audit denial -> canonical output
       ALLOW -> closed route dispatch
                  -> Planning ownership
                  -> Guard decision replay/seal
                  -> Operations adapter
                  -> Verification seal
                  -> Audit seal
                  -> canonical output
```

### 8.2 Route-specific ownership

| Role | Task route | Knowledge route | Project-QA route |
|---|---|---|---|
| Planning | Existing M4 provider-backed or context-backed planning behavior | Deterministic route plan containing only capability, request digest and allowlist ID | Deterministic route plan containing only capability, request digest, allowlist IDs and provider policy ID |
| Guard | Existing M4 semantic Guard plus common static preauthorization | Common static preauthorization and sealed replay; no model | Common static preauthorization and sealed replay; no model |
| Operations | Existing M4 operations behavior | Existing deterministic knowledge query | Existing bounded context/knowledge snapshot plus one QA provider chat |
| Verification | Existing M4 result-chain validation | Validate query/result/allowlist digests, result bounds and no provider activity | Validate citation IDs, provider observations, digests, schema and output isolation |
| Audit | Existing M4 audit plus outer route provenance | Emit route outcome and chain digest without source data | Emit route outcome and chain digest without prompt, provider body or source data |

The deterministic Planning records on knowledge and project QA are ownership metadata, not model requests. They must not add provider calls or read project data. The exact domain-separated seal formats remain a design-Gate deliverable.

## 9. Proposed request, routing, result and error schemas

### 9.1 Internal normalized request

The exact design must define `EAIRA_LOCAL_OPERATOR_REQUEST_V1` with these ordered logical fields:

1. `schema`: fixed `EAIRA_LOCAL_OPERATOR_REQUEST_V1`
2. `capability`: one of `TASK`, `KNOWLEDGE`, `PROJECT_QA`
3. `traceId`: exact normalized trace
4. `provider`: `MOCK`, `OLLAMA_LOOPBACK_V1` or `NONE`, fixed by route form
5. `model`: exact pinned name or `NONE`
6. `rootPresent`: Boolean
7. `rootSha256`: digest or `NONE`; raw root never enters output
8. `inputKind`: `GOAL`, `QUERY` or `QUESTION`
9. `inputSha256`: domain-separated digest; raw user input never enters outer provenance

The request digest must cover the canonical schema bytes and every field, including explicit `NONE` values. CLI argument order is already closed; no semantically equivalent alternate encoding is accepted.

### 9.2 Routing record

`EAIRA_LOCAL_OPERATOR_ROUTE_V1` must bind:

- normalized request digest;
- exact capability enum;
- exact reader allowlist IDs;
- exact provider policy ID or `NONE`;
- exact expected network and write classifications;
- exact expected M4 payload contract;
- exact role sequence;
- exact expected provider call budget.

The route record contains no raw root, goal, query, question, content, prompt or response.

### 9.3 Canonical outer result

Candidate A proposes one UTF-8 JSON line with these members in exact order:

1. `schema`: `EAIRA_LOCAL_OPERATOR_V1`
2. `status`: closed route outcome enum
3. `traceId`: exact trace or `null` when lexical validation failed before a valid trace existed
4. `capability`: `TASK`, `KNOWLEDGE`, `PROJECT_QA` or `null`
5. `network`: `NONE` or `LOOPBACK_ONLY`
6. `writes`: always `NONE`
7. `authority`: route-specific fixed classification
8. `requestSha256`: digest or `null`
9. `routeSha256`: digest or `null`
10. `payloadSha256`: digest of the exact embedded canonical M4 payload, or `null`
11. `payload`: the validated M4 canonical JSON object, or `null`
12. `audit`: either `null` or an exact object with `outcome` then `chainSha256`

Route-specific authority is fixed as follows:

- Task: `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY`
- Knowledge: `NAVIGATIONAL_NOT_AUTHORITY`
- Project QA: `ASSISTIVE_NOT_AUTHORITY`

The embedded payload must be produced by the published M4 serializer and validated before embedding. It must not be reinterpreted, merged with another route or emitted after a later failure. The proposed outer line limit is 20,480 bytes including LF. Independent review must verify that this limit accommodates every published 16,384-byte inner boundary plus worst-case fixed wrapper overhead without creating an unbounded output channel.

### 9.4 Closed status and exit-code mapping

| Status | Exit | Read/provider effect |
|---|---:|---|
| route-specific success | `0` | Only the sealed route budget |
| `INVALID_REQUEST` | `64` | zero read, zero provider |
| `DENIED` | `77` | zero read, zero provider |
| `PROVIDER_BLOCKED` | `78` | inherit task contract; no external fallback |
| `PROVIDER_ERROR` | `79` | loopback may already have occurred; no partial payload |
| `CONTEXT_ERROR` | `80` | no provider call if context preparation failed |
| `KNOWLEDGE_ERROR` | `81` | no provider call on knowledge route; no partial payload |
| `QA_VALIDATION_ERROR` | `82` | no partial payload |
| `ORCHESTRATION_ERROR` | `83` | fail closed; no partial payload |
| `OUTPUT_ERROR` | `84` | fail closed; no partial payload |

The exact design must prove that existing route-specific exit codes are not collapsed or remapped. Stderr remains empty. Exceptions, native error codes, stack traces and diagnostic text never enter stdout.

## 10. Source and data-flow allowlists

### 10.1 Project-context allowlist

The task-context route and project-QA route may use only the exact four-file M4 Slice 3 context allowlist already bound by `EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1`. No fifth path, fallback file, directory enumeration or generated summary is permitted.

### 10.2 Project-knowledge allowlist

The knowledge and project-QA routes may use only the exact seven-file M4 Slice 4 knowledge allowlist already bound by the published knowledge contract and release profile. No integration documents, root-level `tests`, `.obsidian`, user-selected notes or recursive search are permitted.

### 10.3 Data-flow rules

1. `argv` is untrusted data.
2. Capability selection is closed before any root or content operation.
3. Guard sees the normalized bounded request, not provider output.
4. A denied request reaches no reader factory and no provider factory.
5. Roots are validated by the published native handle/path rules; raw roots never enter output.
6. Source bytes are untrusted data, never instructions, and remain inside the selected route.
7. Knowledge data cannot become task arguments; task context cannot widen the knowledge allowlist.
8. Only project QA may send bounded source projections to the provider, using its published prompt/data isolation format.
9. Provider output is untrusted and must pass the route-specific schema and semantic validator.
10. The outer serializer sees only a validated M4 payload and sanitized provenance.
11. No route writes files, registry values, IPC messages, logs, caches or transcripts.

## 11. Cross-capability threat model

| Threat ID | Threat | Mandatory control | Required evidence |
|---|---|---|---|
| `M5S1-T01` | Capability-string injection or prefix collision | Exact ordinal enum match; no prefix, case fold or alias | near-match and Unicode abuse vectors |
| `M5S1-T02` | Cross-route parameter smuggling | Exact argument count, order and route-specific flag set | every foreign/duplicate/extra flag denied before factory calls |
| `M5S1-T03` | Guard bypass through alternate entry | One common preauthorization function before every reader/provider factory | factory counters remain zero on every deny path |
| `M5S1-T04` | Confused deputy between task, knowledge and QA | Sealed routing record binds capability, allowlists, provider and payload contract | route-seal tamper and mismatched-payload cases fail closed |
| `M5S1-T05` | Prompt injection in repository content | Treat all source bytes as framed untrusted data; fixed prompts and closed output schemas | instruction-like, Markdown link, transclusion and tool-call specimens |
| `M5S1-T06` | Data exposure through outer wrapper | Fixed field list; no root, raw input, content, prompt, request/response body or per-file digest | sentinel non-disclosure scans on success and every failure |
| `M5S1-T07` | Provider output crosses route boundary | Provider exists only in task/Ollama and QA; validated payload contract bound in route seal | wrong schema, extra member, tool call and role confusion specimens |
| `M5S1-T08` | Extra provider call, retry or fallback | Exact factory/tags/chat counters and fixed endpoint/model/digest | call-count matrix for success and every failure cut-point |
| `M5S1-T09` | Read before allow | No root hydration/content access before static Guard allow | instrumented reader/factory zero-call denial evidence |
| `M5S1-T10` | Child-process or shell conversion | Direct in-process calls; static and IL metadata denylist | source, import/member-ref and runtime monitor evidence |
| `M5S1-T11` | Shared-state or cache leakage between sequential routes | Request-scoped immutable objects; no mutable static cache | adversarial sequential and repeated-run A/B cases |
| `M5S1-T12` | Partial result after downstream failure | Buffer validated payload in memory; emit exactly once after all seals pass | write-channel capture at every injected failure |
| `M5S1-T13` | Root/path traversal or Cloud Files recall | Inherit exact M4 native handle, equality, reparse, Offline/Recall and tag checks | full existing native/path verifier suite under unified route |
| `M5S1-T14` | Output-budget bypass | Byte-count complete UTF-8 line before write; one-line maximum | exact limit-minus-one, limit and limit-plus-one vectors |
| `M5S1-T15` | Trace replay treated as authorization | Trace is correlation only; Guard never trusts uniqueness | repeated trace yields independent request-scoped decisions |
| `M5S1-T16` | Cross-process replay detection falsely claimed | Slice 1 has no persistence and therefore makes no replay-prevention claim | contract language and negative verifier assertion |
| `M5S1-T17` | Release-profile or compiled-metadata drift | Bind sources, resources, harnesses, member refs, hashes and outputs | clean A/B build, exact profile and independent IL review |
| `M5S1-T18` | Legacy security regression | Run all M4 harnesses and golden vectors unchanged | byte-accurate compatibility evidence |

## 12. Deterministic offline acceptance and abuse matrix

The exact design and implementation harness must include, at minimum:

### 12.1 Command and routing

- all six canonical command forms;
- missing capability, unknown capability and case variants;
- missing, duplicate, reordered, extra and foreign-route flags;
- response-file, stdin, environment and configuration indirection attempts;
- trace, input and root boundary vectors;
- route-record golden bytes and SHA-256 values;
- mismatched route/payload/allowlist/provider seal rejection.

### 12.2 Guard and factory order

- allow and deny terms for all three routes;
- mixed-case, embedded and Unicode-confusable deny specimens already covered by M4 where applicable;
- zero reader/provider factory calls for malformed and denied requests;
- no Cloud Files hydration or content read before allow;
- exact route-local provider call count at every injected failure point.

### 12.3 Data isolation

- prompt-injection strings in every allowed source class;
- raw-root, raw-input, raw-content, prompt, request-body, response-body, per-file digest and native-error sentinels;
- route-to-route sentinel isolation across sequential requests;
- provider tool-call, image, thinking, wrong-role, unknown-member and duplicate-member specimens;
- citation IDs that are missing, duplicated, unknown or inconsistent with the allowed result set.

### 12.4 Output and failure atomicity

- exact canonical success, denial and error objects;
- one LF, empty stderr and no partial stdout;
- 20,479-, 20,480- and 20,481-byte complete outer-line vectors;
- injected failure before and after every role boundary;
- emitted payload digest and audit-chain validation;
- no exception text or host diagnostic in output.

### 12.5 Compatibility and release

- all published M4 harnesses unchanged;
- legacy CLI golden channels unchanged;
- static source denylist and compiled IL/member-reference denylist;
- exact entry-point and artifact-set verification;
- clean out-of-tree A and B builds with byte-identical unsigned artifacts;
- sanitized evidence outside the repository;
- one later, separately authorized live loopback probe after all offline gates pass.

Passing tests is necessary but not sufficient. The verifier must also prove that each named abuse requirement maps to at least one executed case and that no required case is silently omitted from the count or digest.

## 13. Proposed future changed-path manifest for Candidate A

This is a proposed implementation manifest, not current modification authority. The exact design Gate must confirm or narrow it. Widening requires a separate Human Project Owner authorization and independent review.

### 13.1 Product, contract and verification paths

| Disposition | Path | Purpose |
|---|---|---|
| New | `apps/agent-services/src/LocalOperator.cs` | Closed request, route, seal and outer result/error contracts |
| New | `apps/agent-services/src/LocalOperatorHost.cs` | Single exact CLI entry point and write-once channel |
| New | `apps/agent-services/tests/LocalOperatorHarness.cs` | Offline acceptance, abuse, call-order and channel evidence |
| New | `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md` | Published canonical operator contract |
| Modify | `apps/agent-services/src/AgentCore.cs` | Deterministic outer role ownership and validation primitives |
| Modify | `apps/agent-services/src/ProjectQa.cs` | Extract a reusable in-process QA runner without changing published behavior |
| Modify | `apps/agent-services/src/ProjectQaHost.cs` | Delegate legacy CLI to the same reusable runner |
| Modify | `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1` | Build, verify and package the new unsigned operator artifact |
| Modify | `apps/agent-services/release/gate25-unsigned-release-profile.json` | Bind exact contract, sources, harness, IL metadata and artifact hashes |
| Modify | `apps/agent-services/README.md` | Document the bounded entry point and non-authority boundary |

`LocalTaskIntake`, `ProjectKnowledgeQuery`, their hosts and all existing contracts are initially outside the modification manifest. The exact design must use their existing callable surfaces or request an explicit manifest change; it must not copy their security logic into the new host.

### 13.2 Documentary lifecycle paths

The future exact design, independent review, implementation evidence and controlled-state synchronization documents are lifecycle artifacts, not part of the ten-path product manifest. Each requires its own authorized Gate and exact path list. This scope package does not pre-authorize those writes.

### 13.3 Always excluded paths

The pre-existing untracked `docs/integrations/`, `scripts/claude_api.py` and repository-root `tests/` paths remain excluded. `.obsidian` remains excluded. They must not be read, modified, staged or used as build inputs by this lifecycle.

## 14. Readiness prerequisites before implementation authorization

Candidate A may proceed to implementation only after all of the following are independently verified:

1. The Human Project Owner records the exact scope candidate selection.
2. An exact implementation design fixes canonical bytes, domain separators, status enums, exit codes, limits and role seals.
3. Worst-case wrapper-size analysis proves the proposed 20,480-byte line limit or replaces it with a reviewed tighter bound.
4. The ten-path product manifest is proven complete and non-overlapping with excluded paths.
5. Reusable in-process APIs preserve all legacy M4 output and call-count behavior.
6. Static Guard preauthorization is proven to precede every reader and provider factory on every route.
7. The full abuse matrix has named cases, expected counters, exact output and case-list digest rules.
8. Static-source, IL metadata, native import and runtime monitors prove no write, IPC, shell, child-process or dynamic-load capability.
9. The release profile schema can bind the new artifact without weakening existing Gate 25 checks.
10. An independent reviewer returns `PASS` with no unresolved P1/P2 blocker.

## 15. Proposed Gate sequence

The sequence is intentionally separated by authority type. Remediation loops may add numbered revisions; they do not authorize skipping a Gate.

1. `SEPARATE_EVIDENCE_DRIVEN_EAIRA_M5_SLICE1_SCOPE_PACKAGE_PREPARATION` — this Gate.
2. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_REVIEW`.
3. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_SCOPE_SELECTION`.
4. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_AUTHORIZATION`.
5. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_REVIEW`.
6. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_IMPLEMENTATION_AUTHORIZATION`.
7. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_IMPLEMENTATION_AND_ABUSE_REVIEW`.
8. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_LIVE_LOOPBACK_VALIDATION_AUTHORIZATION`.
9. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_LIVE_LOOPBACK_VALIDATION_REVIEW`.
10. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_STAGING_AUTHORIZATION`.
11. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_STAGED_DIFF_AND_EVIDENCE_REVIEW`.
12. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_COMMIT_AUTHORIZATION`.
13. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_POST_COMMIT_VERIFICATION`.
14. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_NORMAL_PUSH_AUTHORIZATION`.
15. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_POST_PUSH_PUBLICATION_VERIFICATION`.
16. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_POST_PUBLICATION_CONTROLLED_STATE_AND_HANDOFF_SYNCHRONIZATION_AUTHORIZATION`.
17. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_POST_PUBLICATION_SYNCHRONIZATION_REVIEW`.
18. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_SYNCHRONIZATION_STAGING_AUTHORIZATION`.
19. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SYNCHRONIZATION_STAGED_DIFF_REVIEW`.
20. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_SYNCHRONIZATION_COMMIT_AUTHORIZATION`.
21. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SYNCHRONIZATION_POST_COMMIT_VERIFICATION`.
22. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_SYNCHRONIZATION_NORMAL_PUSH_AUTHORIZATION`.
23. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_FINAL_PUBLICATION_AND_CLEANLINESS_VERIFICATION`.

## 16. Independent review questions

The independent reviewer must answer all of these explicitly:

1. Does Candidate A satisfy the M5 charter without adding privilege, persistence or an alternate authority source?
2. Can the outer deterministic five-Agent ownership for knowledge and project QA be implemented without extra provider calls or duplicated security logic?
3. Does the common static Guard placement guarantee zero reads and zero provider activity on denial?
4. Is an embedded M4 payload inside the proposed outer schema safe, canonical and bounded?
5. Is 20,480 bytes the correct minimal outer output budget, supported by worst-case evidence?
6. Are the command forms closed enough to prevent cross-route parameter smuggling?
7. Is the ten-path future product manifest complete, and can it remain ten paths?
8. Are any existing M4 public behaviors unintentionally changed?
9. Does the threat matrix cover prompt injection, confused deputy, authorization bypass, exposure, replay, routing and output isolation as required by the charter?
10. Are the offline acceptance cases sufficient to prove controls rather than only happy-path behavior?
11. Are the three pre-existing untracked areas and `.obsidian` kept completely outside the lifecycle?
12. Should Candidate A pass, pass with bounded remediation, or fail in favor of Candidate B/C?

## 17. Completion statement

This scope package is complete as a planning candidate only. It records evidence, three alternatives, a recommended bounded scope, exact proposed command and schema surfaces, five-Agent ownership, allowlists, threats, acceptance requirements, a proposed ten-path implementation manifest and a 23-Gate lifecycle. It grants no implementation or publication authority.

The next permissible action is the separate independent scope-package review. No source, runtime, controlled status, Git index or remote state may change under this Gate.
