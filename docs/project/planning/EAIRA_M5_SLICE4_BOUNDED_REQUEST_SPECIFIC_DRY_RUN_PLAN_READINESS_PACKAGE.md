# EAIRA M5 Slice 4 Bounded Request-Specific Dry-Run Plan Readiness Package

## 1. Control

| Field | Value |
| --- | --- |
| Package ID | `EAIRA_M5_SLICE4_A_READINESS_PACKAGE_V1R1` |
| Date | `2026-09-13` |
| Baseline | `a0ef10a38fa0ac7fb62b9693f65936b0ff61fda9` |
| Product predecessor | `7cf3b323c7b393ed817f7a9ac4562b27d1e512fc` |
| Selection | `M5S4_A_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN` |
| State | `R1R1_REVIEW_PASSED_EXACT_DESIGN_R2R1_CANDIDATE_PREPARED` |
| Exact-design authority | `GRANTED` |
| Implementation authority | `NOT_GRANTED` |
| Repository-recording authority | `NOT_GRANTED` |
| Next Gate | `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE4_A_EXACT_IMPLEMENTATION_DESIGN_R3_REVIEW` |

## 2. Outcome and user stories

The intended user outcome is a request-specific preview between generic route
preflight and any separately invoked execution.

1. As an operator, I can submit one exact existing command under `dry-run` and
   learn its derived route and compiled policy without executing it.
2. As an operator, I receive a canonical request digest and sanitized plan that
   can be compared manually with later evidence but cannot authorize execution.
3. As Guard owner, I can prove that denial occurs before route-policy lookup or
   payload construction and that no execution Guard result is reused.
4. As verifier, I can prove zero project reads, provider construction, model
   calls, network attempts, writes, shells, child processes and persistence.
5. As Audit owner, I receive only fixed enums and digests; raw request values
   never cross the public output.

## 3. Readiness baseline

| Prerequisite | Evidence | State |
| --- | --- | --- |
| M5 Slice 3 product publication | `7cf3b323c7b393ed817f7a9ac4562b27d1e512fc`, tree `808cc75ca7287b8fa78ded1fafeb20c51f9fc4a8`, exact 9 paths | `SATISFIED` |
| Slice 3 profile | SHA-256 `6FEA35EE7D0D28E03352CD552B5D1F56473A2228A294D93286278595A62428ED` | `SATISFIED` |
| Slice 3 sealed manifest | SHA-256 `EC3176CD11D687EBB8A5A1E8681E2EC57695B0453C28E730FA2B630B326A52AE` | `SATISFIED` |
| Slice 3 final publication | product and six-file state synchronization independently verified; endpoint `a0ef10a38fa0ac7fb62b9693f65936b0ff61fda9` | `SATISFIED` |
| Existing harness prefix | exactly 166 stable-name Local Operator cases; first 119 Slice 2 and first 96 Slice 1 cases retained | `SATISFIED` |
| Existing abuse baseline | exact fixed-order 15-row Slice 3 preflight matrix plus retained M4/M5 controls | `SATISFIED` |
| Signing, Windows and production prerequisites | not required for this user-mode planning scope and not established | `OUT_OF_SCOPE_NOT_SATISFIED` |

The known non-blocking Codex auxiliary checkpoint-ref maintenance finding is
not a product-path input and grants no repair authority.

## 4. Exact bounded input grammar

The exact design may refine internal identifiers but may not add a command
shape. It must accept only the seven forms below after the executable name:

| Derived route | Exact argv shape |
| --- | --- |
| `TASK_MOCK` | `dry-run task --provider mock --trace <TRACE> --goal <GOAL>` |
| `TASK_MOCK_CONTEXT` | `dry-run task --provider mock --trace <TRACE> --goal <GOAL> --context-root <ROOT>` |
| `TASK_OLLAMA_LOCAL` | `dry-run task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL>` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `dry-run task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ROOT>` |
| `KNOWLEDGE` | `dry-run knowledge --root <ROOT> --trace <TRACE> --query <QUERY>` |
| `PROJECT_QA_OLLAMA_LOCAL` | `dry-run project-qa --root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b` |
| `HEALTH` | `dry-run health --trace <TRACE>` |

The route is derived solely from ordinal exact grammar. A route selector is not
accepted. `preflight`, `dry-run`, executable paths, command-line strings and
shell fragments are not valid embedded targets.

Input sources are restricted to argv. Existing published validators remain the
maximum allowed language for `TRACE`, `GOAL`, `QUERY`, `QUESTION` and
`ROOT`. No filesystem-backed validation is permitted. No input may change the
provider, model, endpoint, network, data-source class, write policy, authority
classification or output schema.

## 5. Required no-effect processing order

A future exact design must bind this order in source, metadata, IL/control-flow
and runtime evidence:

1. reject null, malformed, duplicate, reordered, extra, aliased or over-budget
   argv without emitting partial output;
2. parse the exact dry-run grammar and validate bounded values in memory;
3. derive the sealed route ID from the accepted grammar, never from a separate
   user selector;
4. construct a fixed `DRY_RUN_PLAN` envelope containing no raw root, goal,
   query or question;
5. invoke static Guard with a fixed plan-only intent before policy lookup or
   plan payload construction;
6. on denial, execute only the existing sanitized Audit terminal path;
7. on allow, look up the compiled route-policy row and build the fixed plan;
8. produce one canonical wrapper line and terminate.

The selected route's execution Guard, Operations, Verification, project
readers, provider factories and loopback transports are never entered. The
actual route must later perform a completely separate parse and fresh Guard
decision if the operator invokes it.

Each valid allow or deny request invokes the plan-only Guard exactly once.
Invalid argv invokes Guard zero times. A Guard denial performs exactly zero
described-policy lookups and zero plan-payload constructions. Exact-design
test seams must count Guard, policy lookup and payload construction separately.

## 6. Output allowlist

The outer wrapper remains `EAIRA_LOCAL_OPERATOR_V1` with its fixed ordered
members and sanitized terminal behavior. A successful dry-run uses capability
`DRY_RUN_PLAN`, network `NONE`, writes `NONE` and authority
`PLAN_NOT_AUTHORITY`.

The new payload is `EAIRA_OPERATOR_DRY_RUN_PLAN_V1`. Its exact design must use
exactly these 13 semantic fields, in this fixed order:

1. `schema`;
2. `planStatus=VALIDATED_NOT_EXECUTED`;
3. one derived `routeId`;
4. fixed `capability`;
5. fixed `sourceClass`;
6. fixed `providerPolicy`;
7. fixed `routeNetwork`;
8. fixed `routeAuthority`;
9. `writes=NONE`;
10. `planGuardEvaluation=ALLOW_DRY_RUN_ONLY`;
11. `executionGuardEvaluation=NOT_EVALUATED`;
12. `executionStatus=NOT_EXECUTED`; and
13. `authority=PLAN_NOT_AUTHORITY`.

The described `capability`, `sourceClass`, `providerPolicy`, `routeNetwork`
and route authority values must come directly from the same published
`LocalOperatorPreflightPolicy` row used by Slice 3 preflight. A single shared
canonical table is required; a copied or independently maintained Slice 4
policy table is forbidden. The existing exact enum bytes must not be renamed.
Dry-run-specific meaning belongs only in its plan, Guard, execution, writes and
authority fields.

The outer request and route digests identify this dry-run request and its
generic dry-run route. They are not confirmation material, need not equal any
later execution hash, and must not be presented as binding the described policy
row. The existing outer `payloadSha256` binds the complete successful
13-member payload, including its canonical policy tuple. No separate
described-policy digest or any other additional digest, raw length,
input-presence bitmap, normalized root, free-form explanation or
provider-derived value is allowed.

## 7. Static route-policy projection

The exact design must define one closed row per derived route:

| Route | Data-source class | Provider policy | Network policy | Project read during dry-run | Route execution |
| --- | --- | --- | --- | --- | --- |
| `TASK_MOCK` | `USER_ARGUMENTS_ONLY` | `MOCK` | `NONE` | `NONE` | `NOT_EXECUTED` |
| `TASK_MOCK_CONTEXT` | `CONTROLLED_PROJECT_CONTEXT` | `MOCK` | `NONE` | `NONE` | `NOT_EXECUTED` |
| `TASK_OLLAMA_LOCAL` | `USER_ARGUMENTS_ONLY` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `NONE` | `NOT_EXECUTED` |
| `TASK_OLLAMA_LOCAL_CONTEXT` | `CONTROLLED_PROJECT_CONTEXT` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `NONE` | `NOT_EXECUTED` |
| `KNOWLEDGE` | `CONTROLLED_PROJECT_MEMORY` | `NONE` | `NONE` | `NONE` | `NOT_EXECUTED` |
| `PROJECT_QA_OLLAMA_LOCAL` | `CONTROLLED_CONTEXT_AND_PROJECT_MEMORY` | `OLLAMA_LOCAL_QWEN3_4B` | `LOOPBACK_ONLY` | `NONE` | `NOT_EXECUTED` |
| `HEALTH` | `COMPILED_CONTRACT_ONLY` | `NONE` | `NONE` | `NONE` | `NOT_EXECUTED` |

These are the exact published Slice 3 enum bytes. They are obtained through the
single shared `LocalOperatorPreflightPolicy` source of truth, not a Slice 4
copy. They describe the selected route's compiled policy, not observed
readiness, present permission or a promise about a later binary.

## 8. Threat model

| Threat | Required control | Required evidence |
| --- | --- | --- |
| Grammar smuggling through reordered, duplicate, extra or abbreviated flags | exact ordinal argv grammar; no generic option parser fallback | valid/invalid channel matrix and compile-then-reject specimens |
| Nested dry-run, preflight, executable or shell injection | seven closed shapes; no delimiter payload, command string or executable path | negative cases for nested and shell-shaped forms |
| Prompt injection in goal/query/question | values remain opaque data; no value affects route or policy; no raw echo | adversarial instruction-shaped inputs with identical fixed policy |
| Root probing or path disclosure | syntax-only validation; no exists/type/hydration/ACL/content check; no raw root output | filesystem/native call inventory and missing/existing-root equivalence |
| Provider or network side effect during preview | provider/adapter/transport constructors unreachable; connect-attempt delta zero | constructor sentinels, IL dominance and loopback instrumentation |
| Guard confusion | fixed plan-only Guard intent; execution Guard explicitly not evaluated or reusable | control-flow proof and distinct enum/value tests |
| Digest treated as confirmation or authority | fixed `PLAN_NOT_AUTHORITY`; no receipt consumption path or state | API/contract search, abuse tests and no persistence inventory |
| TOCTOU between preview and later execution | no binding claim; later invocation reparses and reauthorizes | contract wording and absence of confirmation-token branch |
| Cross-route policy substitution | route derived from grammar and exact closed policy table | seven golden vectors and mutation specimens |
| Output injection or data exfiltration | canonical fixed-order enum-only payload; no free text, raw values, per-field digest or exception | byte-exact goldens and forbidden-content tests |
| Replay or stale plan | plan has no nonce/capability semantics and unlocks nothing | repeated-call equivalence plus no cache/registry/file writes |
| Hidden environment/config expansion | argv-only; no stdin, response file, environment, config or registry | source/IL forbidden-reference checks |

## 9. Acceptance and abuse coverage

A future exact design must specify fixed vectors and the release verifier must
enforce at least:

- one success golden for each of the seven shapes;
- one plan-only Guard denial for each derived route;
- exact plan-only Guard call count of one for every valid allow and denial;
- zero Guard calls for invalid argv and zero described-policy lookup/payload
  construction calls for every Guard denial;
- exact wrapper and payload member order, enums, bytes and digests;
- retention of all 166 published Local Operator case names as an unchanged
  prefix before Slice 4 cases;
- malformed, missing, duplicate, reordered, extra and alternate-value flags;
- nested dry-run/preflight, executable path, shell metacharacter, response-file,
  stdin, environment/config and route-override attempts;
- NUL, control, malformed Unicode, noncanonical trace and over-budget inputs;
- instruction-shaped goal/query/question values that remain opaque;
- existing, missing, offline and inaccessible root paths with zero probe/read
  difference during dry-run;
- provider-factory, reader, model, network and connect-attempt counters fixed at
  zero;
- zero file, directory, registry, IPC, listener, shell, process, dynamic-load,
  cache, log and transcript writes;
- compile-then-reject specimens for Guard bypass, route substitution, raw-value
  output, execution-Guard reuse, provider construction and persistence; and
- retained M4 and M5 Slice 1–3 regression, metadata, P/Invoke, native,
  loopback-policy, output-isolation and sealed A/B checks without weakening.

## 10. Release-profile and verifier constraints

No release-profile or verifier modification is authorized by this package.
A later exact design must:

- preserve the current non-circular external profile-hash precondition;
- bind every changed repository input and exact reference/compiler identity;
- preserve clean A/B byte-for-byte reproduction;
- add Slice 4 cases after the exact 166-case prefix;
- forbid discovery bypass in final evidence;
- copy release outputs only after all non-signing checks pass;
- retain `NotSigned`, `externalSigningEligible=false`,
  `signatureOnlyBlocked=false` and `gate25Complete=false`; and
- add no network, Windows or external-provider prerequisite.

## 11. Changed-path ceiling

The present preparation candidate is exactly two new documentation paths:

1. `docs/project/strategy/EAIRA_M5_SLICE4_SCOPE_DECISION.md`
2. `docs/project/planning/EAIRA_M5_SLICE4_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN_READINESS_PACKAGE.md`

The complete future candidate ceiling is exactly the nine paths listed in the
scope decision. No status, context, HANDOFF, integration, Claude API,
repository-root tests or Obsidian path belongs to implementation scope.

## 12. Core Gate sequence

1. Project Owner scope selection.
2. Scope-decision/readiness-package preparation — this candidate Gate.
3. Independent scope and readiness review.
4. Exact implementation-design authorization.
5. Exact design and changed-path manifest preparation.
6. Independent exact-design review.
7. Separate implementation authorization.
8. Implementation.
9. Offline discovery evidence.
10. Independent implementation and profile review.
11. Native/final validation authorization.
12. Sealed final validation.
13. Independent sealed-evidence review.
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

Remediation Gates are inserted whenever review produces a blocking finding and
do not replace or merge the core Gates.

## 13. Readiness determination

The selected scope is narrow enough for a separate independent scope/readiness
review. It advances the human operator workflow without creating confirmation,
execution, persistence, provider, network, Windows, signing or production
authority.

`READINESS_R1R1_REVIEW_PASSED_EXACT_DESIGN_CANDIDATE_PREPARED`

The exact-design preparation Gate is authorized and its candidate is present.
Implementation is not inferred. The next Gate is:

`SEPARATE_INDEPENDENT_EAIRA_M5_SLICE4_A_EXACT_IMPLEMENTATION_DESIGN_R3_REVIEW`
