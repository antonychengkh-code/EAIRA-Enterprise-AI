# EAIRA M5 Slice 3 Bounded Operator Preflight and Route Explanation Readiness Package

## 1. Control

| Field | Value |
| --- | --- |
| Package ID | `EAIRA_M5_SLICE3_A_READINESS_PACKAGE_V1R4` |
| Date | `2026-09-13` |
| Baseline | `0be3bb95447a45c60ab4cc950a44950b784b086e` |
| Selection | `M5S3_A_BOUNDED_OPERATOR_PREFLIGHT_AND_ROUTE_EXPLANATION` |
| State | `R4_EXACT_DESIGN_REMEDIATION_AUTHORIZED` |
| Exact-design authority | `GRANTED` |
| Implementation authority | `NOT_GRANTED` |
| Repository-recording authority | `NOT_GRANTED` |
| Next Gate | `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE3_A_EXACT_IMPLEMENTATION_DESIGN_R4_REVIEW` |

## 2. User outcome

Before choosing whether to run an existing Local Operator command, a human can
ask the same executable for a sanitized explanation of the compiled route
policy. The response helps the operator distinguish a route that is offline,
read-only or loopback-only without reading data or testing the environment.

Provisional command grammar:

```text
EAIRA.LocalOperator.Cli.exe preflight --trace <TRACE> --route <ROUTE_ID>
```

The exact design may refine canonical bytes and internal names, but it may not
add aliases, defaults, reordered/duplicate/extra flags, response files, stdin,
environment/config expansion, arbitrary arguments or an eighth route ID without
a new Project Owner remediation decision.

## 3. Static route policy table

The response is derived only from this compiled table. `writes` is `NONE`,
`guardRequirement` is `REQUIRED_BEFORE_EFFECT`, and successful output uses
`guardEvaluation=ALLOW_PREFLIGHT_ONLY` for every row. That value describes the
Guard result for emitting the explanation only; it never applies to execution of
the selected row.

| Route ID | Capability | Source class | Provider policy | Network | Authority |
| --- | --- | --- | --- | --- | --- |
| `TASK_MOCK` | `TASK` | `USER_ARGUMENTS_ONLY` | `MOCK` | `NONE` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_MOCK_CONTEXT` | `TASK` | `CONTROLLED_PROJECT_CONTEXT` | `MOCK` | `NONE` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_OLLAMA_LOCAL` | `TASK` | `USER_ARGUMENTS_ONLY` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `TASK` | `CONTROLLED_PROJECT_CONTEXT` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY` |
| `KNOWLEDGE` | `KNOWLEDGE` | `CONTROLLED_PROJECT_MEMORY` | `NONE` | `NONE` | `NAVIGATIONAL_NOT_AUTHORITY` |
| `PROJECT_QA_OLLAMA_LOCAL` | `PROJECT_QA` | `CONTROLLED_CONTEXT_AND_PROJECT_MEMORY` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `ASSISTIVE_NOT_AUTHORITY` |
| `HEALTH` | `HEALTH` | `COMPILED_CONTRACT_ONLY` | `NONE` | `NONE` | `OBSERVATIONAL_NOT_AUTHORITY` |

`LOOPBACK_ONLY` describes the policy of the later selected route. Preflight
itself always has effective network `NONE` and does not check endpoint or model
availability. A source class names a previously published bounded class; it
does not reveal a root, filename, path, content, digest or current availability.

## 4. Provisional canonical output

A later exact design must define one fixed `EAIRA_OPERATOR_PREFLIGHT_V1`
payload within the existing `EAIRA_LOCAL_OPERATOR_V1` wrapper. The payload may
contain only these ordered members:

1. `schema`
2. `status`
3. `observationScope`
4. `routeId`
5. `capability`
6. `guardRequirement`
7. `guardEvaluation`
8. `sourceClass`
9. `providerPolicy`
10. `routeNetwork`
11. `preflightNetwork`
12. `writes`
13. `routeAuthority`
14. `authority`

Required fixed values include:

- `schema=EAIRA_OPERATOR_PREFLIGHT_V1`;
- `status=POLICY_EXPLAINED`;
- `observationScope=COMPILED_CONTRACT_ONLY`;
- `guardRequirement=REQUIRED_BEFORE_EFFECT`;
- `guardEvaluation=ALLOW_PREFLIGHT_ONLY`;
- `preflightNetwork=NONE`;
- `writes=NONE`; and
- `authority=EXPLANATORY_NOT_AUTHORITY` for the preflight response itself.

`routeAuthority` is the exact value from the selected policy-table row. It must
remain separate from the fixed preflight response authority. Missing, additional,
reordered or wrongly typed members fail closed.

No free-form explanation string is allowed. Human-facing clients may map the
fixed enums outside the trusted response, but that mapping is not part of this
slice.

## 5. Read-only source and output allowlist

### Inputs allowed to the preflight route

- literal tokens `preflight`, `--trace`, and `--route`;
- one trace satisfying the existing exact 32-uppercase-hex rule;
- exactly one of the seven route IDs; and
- compile-time constants needed to construct the canonical request, route and
  payload.

### Runtime sources denied

- goal, query, question, root or arbitrary user content;
- repository, vault, project-memory and `.obsidian` files;
- filesystem metadata or directory enumeration;
- environment variables, configuration, registry, clock and randomness;
- process, service, account, group, ACL, certificate and native diagnostics;
- stdin, response files, shell, child process, dynamic loading and IPC; and
- provider factories, model APIs, sockets, HTTP, loopback and external network.

### Outputs allowed

- one canonical existing Local Operator wrapper on stdout;
- one fixed preflight payload containing only reviewed enum values and digests;
- empty stderr; and
- existing fail-closed parse, denial/orchestration and output exit classes as
  explicitly selected by exact design.

### Outputs denied

- raw argv, goal, query, question, root or path;
- raw file content, prompt, provider request/response or model content;
- environment, host, user, service, process or network diagnostics;
- live readiness, availability or authorization claims;
- secrets, credentials, personal data and recovery material; and
- logs, files, registry values, telemetry or any persistent output.

## 6. Five-Agent ownership and control flow

1. Parser validates the exact preflight grammar and route ID.
2. Planning constructs one fixed, integrity-bound preflight envelope with intent
   `EXPLAIN COMPILED ROUTE POLICY`; it receives no user-supplied goal, query,
   question or root.
3. The generic outer preflight route is constructed to bind the request and a
   possible denial wrapper; it contains no described-route policy tuple. Static
   Guard is then called exactly once. Deny returns the existing sanitized
   Planning -> Guard(DENY) -> Audit chain before seven-row described-route lookup
   or payload creation.
4. On allow, Operations performs only a fixed-table lookup and constructs the
   payload. `ALLOW_PREFLIGHT_ONLY` cannot be reused for the described route.
5. Verification validates exact member order, enum membership, route-table
   consistency, canonical bytes and digest chain.
6. Audit binds the sanitized result digest without logging or persistence.

This preserves the current rule that every valid Local Operator request calls
Guard before a successful result. The fixed preflight Guard result is never
represented as authorization, readiness or replayable permission for another
request.

## 7. Threat model

| Threat | Required fail-closed control |
| --- | --- |
| Preflight executes the described command | No dispatch to task/knowledge/QA/Health adapters; poison factories and execution counters remain zero |
| User smuggles a prompt or path | Exact five-token argv after executable; route ID is closed enum; no trailing argv or stdin |
| Route explanation becomes authorization | `ALLOW_PREFLIGHT_ONLY`, separate route/response authority and fixed `EXPLANATORY_NOT_AUTHORITY` |
| Compiled policy is mistaken for live readiness | Fixed `COMPILED_CONTRACT_ONLY`; no machine or provider observation |
| Loopback policy causes a probe | Preflight effective network is always `NONE`; socket/HTTP/provider references forbidden in closure |
| Confused-deputy route mismatch | One route ID maps to one exact row; capability/provider/source/network/authority tuple is byte-bound |
| Route table drifts from implemented grammar | Verifier derives and compares the parser's accepted existing routes against the seven-row table |
| Raw argument reflection or output injection | No user-controlled string except validated trace/route ID; payload contains only fixed enums |
| Guard bypass in later execution | Explanation states Guard requirement but does not alter existing route dispatch or Guard call graph |
| Existing command regression | Exact current Local Operator harness prefix and every retained M4/M5 test remain mandatory |
| Metadata or dynamic-call bypass | Existing source, PE metadata, P/Invoke, native, call-graph and negative-specimen controls remain mandatory |
| False persistence or audit claim | No file/log/registry/telemetry output; Audit is digest-chain construction only |

## 8. Required acceptance and abuse coverage

Exact design must define stable cases for at least:

- each of the seven route IDs with exact canonical policy tuples;
- same valid trace/route produces byte-identical output;
- different valid traces preserve policy payload bytes while request/route/Audit
  digests and wrapper vary according to the existing digest contract;
- malformed/lowercase/short/long/non-hex trace rejection;
- unknown, lowercase, prefix/suffix and Unicode-confusable route IDs;
- missing, duplicate, reordered and extra flags/arguments;
- goal/query/question/root/provider/model/endpoint injection attempts;
- response file, stdin, environment and configuration attempts;
- zero selected-route execution, zero reads, zero provider/factory calls and
  zero connect attempts for success and every failure path;
- exactly one Guard call for each valid preflight allow or deny, zero table lookup
  and payload construction on deny, and positive one-call preservation tests for
  every existing route family;
- fixed output member order, enum membership, bounded bytes and empty stderr;
- route-authority versus response-authority non-confusion;
- no live-health/readiness claim and no claim that the preflight Guard result is
  a Guard decision or authorization for the described route;
- parser/table drift specimens for every existing route grammar;
- source mutations adding filesystem, environment, provider, network, IPC,
  process, clock, randomness or dynamic-load access;
- all current 119 Local Operator cases with the first 96 legacy cases unchanged;
- all existing M4/M5 regression and negative specimen suites; and
- two clean byte-identical builds with non-circular profile calibration.

## 9. Provisional changed-path ceiling

A later exact design may select only from these nine paths:

1. `apps/agent-services/README.md`
2. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`
3. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
4. `apps/agent-services/release/gate25-unsigned-release-profile.json`
5. `apps/agent-services/src/LocalOperator.cs`
6. `apps/agent-services/tests/LocalOperatorHarness.cs`
7. `docs/project/planning/EAIRA_M5_SLICE3_BOUNDED_OPERATOR_PREFLIGHT_AND_ROUTE_EXPLANATION_READINESS_PACKAGE.md`
8. `docs/project/planning/EAIRA_M5_SLICE3_EXACT_IMPLEMENTATION_DESIGN.md`
9. `docs/project/strategy/EAIRA_M5_SLICE3_SCOPE_DECISION.md`

This preparation creates only paths 7 and 9. Path 8 and product paths 1–6 are
not authorized for creation or modification at this Gate.

`AgentCore.cs`, `LocalOperatorHost.cs`, all other product sources, repository-root
`tests/`, `docs/integrations/`, `scripts/claude_api.py` and `.obsidian/` are
excluded. An independent P0/P1 finding may recommend a minimum additional path,
but adding it requires a separate Project Owner remediation authorization.

## 10. Readiness prerequisites

| Prerequisite | Current evidence | State |
| --- | --- | --- |
| M5 Slice 2 publication synchronized | live/local/cached `master` at `0be3bb95447a45c60ab4cc950a44950b784b086e` under prior Gate 27 | `SATISFIED` |
| Existing canonical entry point | `EAIRA.LocalOperator.Cli.exe` contract exposes seven exact command profiles | `SATISFIED` |
| No-write/no-IPC user-mode baseline | M5 charter and Local Operator V1 contract | `SATISFIED` |
| Closed route identifiers | seven IDs in this package | `PROVISIONAL_PENDING_INDEPENDENT_REVIEW` |
| Route/response authority separation | exact separate `routeAuthority` and fixed response `authority` fields | `DEFINED_PENDING_INDEPENDENT_REVIEW` |
| Parser-to-table drift proof | required verifier design in sections 7–8 | `OPEN_DESIGN_ITEM` |
| Exact canonical bytes/digests | not guessed at scope stage | `OPEN_EXACT_DESIGN_ITEM` |
| Changed-path sufficiency | nine-path ceiling, only six product paths | `PROVISIONAL_PENDING_INDEPENDENT_REVIEW` |

Scope review is closeable only if every open item is either resolved within a
document-only remediation or explicitly carried into exact design without
allowing ambiguous authority, route drift or implementation.

## 11. Core Gate sequence

1. Scope selection — complete by Project Owner response.
2. Decision/readiness package preparation — this candidate Gate.
3. Independent scope and readiness review.
4. Exact implementation-design authorization.
5. Exact design and changed-path manifest preparation.
6. Independent exact-design review.
7. Separate implementation authorization.
8. Implementation.
9. Offline discovery evidence.
10. Independent implementation and profile review.
11. Native/final validation authorization.
12. Sealed final and bounded native validation.
13. Independent sealed-evidence/validation review.
14. Exact product staging.
15. Independent staged-product review.
16. Exact product commit.
17. Independent post-commit verification.
18. Normal product push.
19. Independent post-push publication verification.
20. Controlled-state and HANDOFF synchronization.
21. Independent synchronization-candidate review.
22. Exact synchronization staging.
23. Independent staged-synchronization review.
24. Exact synchronization commit.
25. Independent synchronization post-commit verification.
26. Normal synchronization push.
27. Independent final publication verification.

Remediation Gates are inserted whenever a review returns P0/P1 and do not replace
or merge any of these 27 core Gates. No later Gate is inferred from this package.

## 12. Stop conditions

Stop on any attempt to execute an existing route, read project/vault content,
construct a provider, open network, write state, accept arbitrary input, emit
raw input/path/content, report the preflight Guard result as a decision or
authorization for the described route, report a live readiness claim, widen
the route enum, change an excluded path, weaken an existing regression, create
final/release evidence during discovery, stage, commit, push, mutate Windows or
repair refs. Any P0/P1 independent finding blocks exact-design eligibility until
separately authorized remediation is reviewed.
