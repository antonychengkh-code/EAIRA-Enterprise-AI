# EAIRA M5 Slice 1 Unified User-Mode Orchestrator Scope Package R1

## Document control

- Package ID: `EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_V1R1`
- Prepared: `2026-09-12`
- Baseline: `c50ccb8d22926220ac8712aaaa9eaacff1e9de93`
- Milestone: `M5_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW`
- State: `R1_CANDIDATE_READY_FOR_INDEPENDENT_SCOPE_REVIEW`
- Scope selection: `NOT_YET_RECORDED`
- Implementation authority: `NOT_GRANTED`
- Supersedes as planning candidate: `EAIRA_M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR_SCOPE_PACKAGE_V1`
- Prior independent review: `PASS_WITH_REMEDIATION`; P0 `0`, P1 `0`, P2 `5`
- R1 authority: Human Project Owner authorization to complete the listed Slice 1 lifecycle, bounded to the five review findings
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R1_REVIEW`

This R1 file is the complete planning candidate. The unsuffixed V1 file remains immutable review evidence and is not current authority.

## 1. Authority boundary

This Gate authorizes only a planning revision. It does not authorize product implementation, arbitrary vault reads, live model calls, Windows/service/IPC/account/group/ACL/certificate/signing changes, external providers, runtime persistence, staging, commit or push.

The controlled status at baseline is authoritative: M4 is closed; M5 is active; `M5_A_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW` is selected. Historical candidate-stage wording in the published charter is not current state and is not rewritten here.

## 2. R1 closure of prior findings

1. The outer status enum, presence/null rules, audit outcomes and per-route M4 crosswalk are now closed.
2. Five roles describe system responsibility. Allowed execution uses all five roles; denied execution uses exactly Planning → Guard(DENY) → Audit. Operations and Verification are forbidden on denial.
3. The prior unproven 20,480-byte proposal is replaced by an 18,432-byte complete-line cap, a 16,383-byte embedded-payload cap and a 2,048-byte wrapper budget.
4. The Project QA baseline is corrected to ten argv elements comprising five exact flag/value pairs.
5. The ten-path manifest is conditionally closed by explicit compile/source-closure conditions; failure of any condition requires separately reviewed manifest widening.

## 3. Published evidence and integration problem

| Capability | M4 entry point | Read/provider boundary | Role execution |
|---|---|---|---|
| Task | `EAIRA.AgentTask.Cli.exe` | Optional exact four-file context; mock or pinned Ollama loopback | Full M4 pipeline; denial is Planning/Guard/Audit |
| Knowledge | `EAIRA.ProjectKnowledge.Cli.exe` | Exact seven-file knowledge allowlist; no provider | Standalone deterministic path |
| Project QA | `EAIRA.ProjectQa.Cli.exe` | Exact four context plus seven knowledge files; pinned tags/chat/tags | Static Guard plus bounded QA path |

Evidence-backed facts:

- Task intake creates `TaskEnvelope`, calls `GuardAgent.ExpectedDecision`, and does not prepare context before static denial.
- `MinimumFunctionalPipeline` implements Planning → Guard → Operations → Verification → Audit, with the exact three-role denial sequence.
- Knowledge accepts four argv elements: `--root <ROOT> --query <QUERY>`.
- Project QA accepts ten argv elements: `--root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b`.
- Knowledge and QA each cap their complete UTF-8 output line at 16,384 bytes including LF.
- QA hides raw root, projection, prompt, provider request/response and per-file digests.
- No published CLI currently routes all three capabilities.

The integration must be in-process. A launcher or shell would violate the M5 no-child-process boundary and would not provide one reviewable role and provenance chain.

## 4. Scope candidates and recommendation

### Candidate A — `M5S1_A_IN_PROCESS_THREE_ROUTE_ORCHESTRATOR` (recommended)

Create one unprivileged console executable, provisionally `EAIRA.LocalOperator.Cli.exe`, with exact `task`, `knowledge` and `project-qa` routes. Call reviewed M4 components in-process. Preserve all legacy executables and contracts. Add deterministic outer role/provenance records without adding provider calls.

### Candidate B — `M5S1_B_IN_PROCESS_ROUTE_ADAPTER_WITHOUT_FULL_ROLE_UNIFICATION`

Provide one in-process router but no explicit five-role ownership around knowledge/QA. Smaller, but it does not fully meet the selected M5 charter.

### Candidate C — `M5S1_C_PROJECT_QA_ONLY_OPERATOR_ENTRY`

Expose only QA and defer task/knowledge routing. Smallest, but not a canonical multi-capability entry point.

No candidate is selected by this R1 Gate. Candidate A remains recommended; selection requires a separate Project Owner Gate.

## 5. Candidate A exact scope

Included:

- one unsigned, user-mode, console-only executable;
- three closed routes and no implicit default;
- in-process reuse of reviewed M4 components;
- static Guard before every reader/provider factory;
- five-role responsibility with exact allowed and denied sequences;
- versioned request, route, result/error and provenance schemas;
- unchanged four-file and seven-file allowlists;
- unchanged endpoint, model, digest and call counts;
- deterministic offline/abuse evidence and reproducible A/B builds;
- later separately authorized loopback probe;
- all legacy M4 harnesses and CLIs preserved.

Excluded:

- REPL, GUI, web/tray/background process, service or scheduler;
- IPC/listener, shell, child process, dynamic load or executable dispatch;
- arbitrary paths, enumeration, globs, user allowlists or repository writes;
- Internet/external provider, retries, fallback, alternate URI/model/digest;
- credentials, persistence, logging, cache, transcript, installer or signing;
- authentication, multi-user concurrency or cross-process replay storage;
- removal or behavioral change of a legacy M4 CLI.

## 6. Closed command surface

```text
EAIRA.LocalOperator.Cli.exe task --provider mock --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe task --provider mock --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe knowledge --root <ROOT> --trace <TRACE> --query <QUERY>
EAIRA.LocalOperator.Cli.exe project-qa --root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b
```

Rules:

- Trace is exactly 32 uppercase hexadecimal characters.
- Flags occur once and in the exact order shown.
- Route inputs inherit their published length, Unicode and path rules.
- No aliases, case folding, response files, stdin, environment/config expansion or cross-route flags.
- Extra, missing, duplicate, reordered or case-variant elements return `INVALID_REQUEST` before factory calls.
- `--help`, `--version` and diagnostic modes are outside Slice 1.

## 7. Closed route budgets

| Route | Reads after allow | Provider | Calls | Network/writes |
|---|---|---|---|---|
| Task mock, no context | none | deterministic mock | exact M4 pipeline | `NONE` / `NONE` |
| Task mock, context | four-file context | deterministic mock | exact M4 context pipeline | `NONE` / `NONE` |
| Task Ollama, no context | none | exact pinned loopback | exact M4 lifecycle | `LOOPBACK_ONLY` / `NONE` |
| Task Ollama, context | four-file context | exact pinned loopback | exact M4 context lifecycle | `LOOPBACK_ONLY` / `NONE` |
| Knowledge | seven knowledge files | none | zero provider construction/calls | `NONE` / `NONE` |
| Project QA | four context + seven knowledge | exact pinned loopback | exactly tags/chat/tags | `LOOPBACK_ONLY` / `NONE` |
| Any static denial | none | none | zero reader/provider factory calls | `NONE` / `NONE` |

Routing is exact ordinal enum dispatch. Reflection, dynamic loading, URI activation, shell association and child processes are forbidden.

## 8. Guard and role call graph

```text
argv
  -> exact parser
  -> normalized request + digest
  -> TaskEnvelope
  -> static Guard preauthorization
       DENY -> deterministic Planning record
               -> Guard(DENY) replay/seal
               -> Audit denial
               -> canonical output
               [no Operations; no Verification; no reads/provider]
       ALLOW -> closed route dispatch
               -> Planning
               -> Guard(ALLOW) replay/seal
               -> Operations adapter
               -> Verification
               -> Audit
               -> canonical output
```

Knowledge and QA Planning records are deterministic ownership metadata, not model calls and not source reads. Task preserves the existing M4 semantic pipeline. Exact domain separators and seals belong to the later exact-design Gate.

## 9. Closed schema proposal

### 9.1 Request

`EAIRA_LOCAL_OPERATOR_REQUEST_V1` has these logical fields in order:

1. `schema`
2. `capability`: `TASK`, `KNOWLEDGE`, `PROJECT_QA`
3. `traceId`
4. `provider`: `MOCK`, `OLLAMA_LOOPBACK_V1`, `NONE`
5. `model`: `qwen3:4b` or `NONE`
6. `rootPresent`
7. `rootSha256` or `NONE`
8. `inputKind`: `GOAL`, `QUERY`, `QUESTION`
9. `inputSha256`

The request digest covers every canonical field and explicit `NONE`. Raw root and raw input never enter outer provenance.

### 9.2 Route seal

`EAIRA_LOCAL_OPERATOR_ROUTE_V1` binds request digest, capability, allowlist IDs, provider policy, network/write class, expected M4 payload contract, role sequence and provider-call budget. It contains no raw input, root, content, prompt or response.

### 9.3 Outer result

One canonical UTF-8 JSON line has these members in exact order:

1. `schema`: `EAIRA_LOCAL_OPERATOR_V1`
2. `status`
3. `traceId`
4. `capability`
5. `network`
6. `writes`: always `NONE`
7. `authority`
8. `requestSha256`
9. `routeSha256`
10. `payloadSha256`
11. `payload`
12. `audit`: `null` or `{outcome,chainSha256}` in that order

Status is exactly one of:

`PASS`, `DENIED`, `INVALID_REQUEST`, `PROVIDER_BLOCKED`, `PROVIDER_ERROR`, `CONTEXT_ERROR`, `KNOWLEDGE_ERROR`, `QA_VALIDATION_ERROR`, `ORCHESTRATION_ERROR`, `OUTPUT_ERROR`.

Presence/null rules:

- `PASS`: trace, capability, all digests, payload and audit are non-null; audit outcome is `PASS`.
- `DENIED`: trace, capability, request/route digests and audit are non-null; payload digest/payload are null; audit outcome is `DENIED`.
- `INVALID_REQUEST`: payload digest, payload and audit are null. Trace, capability and request/route digests are non-null only when the complete corresponding value was validated and sealed before failure; otherwise each is null.
- All other errors: trace, capability, request/route digests and audit are non-null; payload digest/payload are null; audit outcome exactly equals status.
- `network` describes activity that may already have occurred, never merely requested activity.

Authority is fixed by route: task `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY`; knowledge `NAVIGATIONAL_NOT_AUTHORITY`; QA `ASSISTIVE_NOT_AUTHORITY`. On invalid request before route selection it is `NONE`.

### 9.4 Byte budget

- Complete outer line: maximum 18,432 UTF-8 bytes including LF.
- Embedded canonical M4 object: maximum 16,383 bytes excluding LF.
- Wrapper including punctuation and LF: maximum 2,048 bytes.
- Knowledge/QA already enforce a 16,384-byte complete line including LF.
- The operator adds the same 16,383-byte embedded-object cap to task output without changing the legacy task CLI.
- Exact design must enumerate maximum wrapper bytes and prove `<= 2,048`; failure blocks design and does not widen the cap.

### 9.5 M4-to-outer crosswalk

| M4 route/status | Outer status | Exit | Payload |
|---|---|---:|---|
| Task `PASS` | `PASS` | 0 | validated task object |
| Task `DENIED` | `DENIED` | 77 | null |
| Task `PROVIDER_BLOCKED` | `PROVIDER_BLOCKED` | 78 | null |
| Task `LOCAL_PROVIDER_ERROR` | `PROVIDER_ERROR` | 79 | null |
| Task `CONTEXT_ERROR` | `CONTEXT_ERROR` | 80 | null |
| Knowledge `KNOWLEDGE_QUERY_OK` | `PASS` | 0 | validated knowledge object |
| Knowledge `INVALID_REQUEST` | `INVALID_REQUEST` | 64 | null |
| Knowledge `KNOWLEDGE_ERROR` | `KNOWLEDGE_ERROR` | 81 | null |
| QA `PROJECT_QA_OK` | `PASS` | 0 | validated QA object |
| QA `DENIED` | `DENIED` | 77 | null |
| QA `LOCAL_PROVIDER_ERROR` | `PROVIDER_ERROR` | 79 | null |
| QA `CONTEXT_ERROR` | `CONTEXT_ERROR` | 80 | null |
| QA `KNOWLEDGE_ERROR` | `KNOWLEDGE_ERROR` | 81 | null |
| QA `PROJECT_QA_ERROR` | `QA_VALIDATION_ERROR` | 82 | null |
| Outer validation/chain failure | `ORCHESTRATION_ERROR` | 83 | null |
| Outer byte/serialization failure | `OUTPUT_ERROR` | 84 | null |

Stderr is empty. No partial stdout, exception, stack, native code or diagnostic is emitted.

## 10. Source/data allowlists and flow

- Task context and QA use only `EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1`'s exact four files.
- Knowledge and QA use only the published exact seven knowledge files.
- No integration documents, root `tests`, `.obsidian`, user notes, fallback files or recursive enumeration.

Flow invariants:

1. argv and repository bytes are untrusted data.
2. Capability and request are closed before any content operation.
3. Denial reaches no reader/provider factory.
4. Native M4 root/handle/Cloud Files rules remain intact.
5. Route data cannot cross into another route.
6. Only QA sends bounded source projection to a provider.
7. Provider output is untrusted and schema validated.
8. Outer serializer receives only validated M4 payload plus sanitized provenance.
9. No files, registry, IPC, logs, cache or transcripts are written.

## 11. Mandatory threat coverage

The exact design and harness must cover:

- exact capability matching and Unicode/prefix confusion;
- duplicate, reordered, extra and cross-route flags;
- Guard bypass and read/provider-before-allow;
- confused-deputy route/allowlist/provider/payload mismatch;
- repository prompt injection and provider-output injection;
- root, input, content, prompt, body, response and per-file digest exposure;
- retry, fallback and excess provider calls;
- child process, shell, IPC, write and dynamic-load metadata;
- mutable shared state and sequential route leakage;
- partial stdout after any downstream failure;
- native path, reparse, Offline/Recall and tag abuse;
- 18,431/18,432/18,433-byte output specimens;
- trace reuse. Trace is correlation only, never authorization;
- no cross-process replay-prevention claim because Slice 1 has no persistence;
- release-profile/IL drift and legacy M4 regression.

## 12. Deterministic acceptance evidence

Required offline evidence includes:

- all six canonical forms plus every invalid argv family;
- route request/seal/output golden bytes and SHA-256;
- zero reader/provider factory counters on invalid/deny;
- exact calls at each allowed/failure cut-point;
- prompt-injection and data-exposure sentinels across all source classes;
- wrong/extra/duplicate provider JSON members and tool/image/thinking output;
- route-to-route sequential isolation;
- one LF, empty stderr and failure atomicity;
- embedded payload cap and wrapper-byte proof;
- every unchanged M4 harness and legacy channel;
- static source, IL/member-reference, native import and runtime-monitor denylists;
- clean out-of-tree A/B builds with byte-identical unsigned artifacts;
- sanitized out-of-tree evidence;
- one later separately authorized exact loopback probe.

The verifier must map each mandatory abuse requirement to at least one executed named case and bind the complete case-name list/count/digest.

## 13. Conditionally closed ten-path product manifest

| Change | Path |
|---|---|
| New | `apps/agent-services/src/LocalOperator.cs` |
| New | `apps/agent-services/src/LocalOperatorHost.cs` |
| New | `apps/agent-services/tests/LocalOperatorHarness.cs` |
| New | `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md` |
| Modify | `apps/agent-services/src/AgentCore.cs` |
| Modify | `apps/agent-services/src/ProjectQa.cs` |
| Modify | `apps/agent-services/src/ProjectQaHost.cs` |
| Modify | `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1` |
| Modify | `apps/agent-services/release/gate25-unsigned-release-profile.json` |
| Modify | `apps/agent-services/README.md` |

The manifest remains exactly ten paths only if exact compile/source closure proves:

1. task adapter and provider factory live wholly in new `LocalOperator.cs`;
2. existing `LocalTaskIntake.Execute` is sufficient unchanged;
3. knowledge calls existing `ProjectKnowledgeQuery` unchanged;
4. QA reuse changes only `ProjectQa.cs` and `ProjectQaHost.cs`;
5. existing M4 contracts remain unchanged.

`LocalTaskIntake.cs`, `AgentTaskIntakeHost.cs`, `ProjectKnowledge.cs`, `ProjectKnowledgeHost.cs` and all M4 contracts are explicitly outside the manifest. If any condition fails, implementation must stop for a separately reviewed manifest-widening authorization. Security logic must not be copied.

Lifecycle/design/evidence/status documents are separately authorized documentary paths and are not product-manifest entries.

Pre-existing untracked `docs/integrations/`, `scripts/claude_api.py`, root `tests/`, and `.obsidian` remain excluded from reading, modification, staging and build inputs.

## 14. Implementation prerequisites

1. Independent R1 review passes without unresolved P1/P2 blocker.
2. Project Owner records Candidate A/B/C selection.
3. Exact design fixes bytes, domains, enums, limits, seals and case matrix.
4. Wrapper proof establishes the fixed 18,432/16,383/2,048 limits.
5. Compile/source closure proves the ten-path manifest.
6. Reusable APIs preserve legacy channels and call counts.
7. Guard ordering is proven with factory counters.
8. Static/IL/runtime checks prove no write/IPC/shell/child/dynamic load.
9. Release profile binds the new artifact without weaker checks.
10. Independent exact-design review passes.

## 15. Updated Gate sequence

1. `SEPARATE_EVIDENCE_DRIVEN_EAIRA_M5_SLICE1_SCOPE_PACKAGE_PREPARATION` — complete.
2. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_REVIEW` — `PASS_WITH_REMEDIATION`.
3. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R1_REMEDIATION_AUTHORIZATION` — applied.
4. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SCOPE_PACKAGE_R1_REVIEW`.
5. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_SCOPE_SELECTION`.
6. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_AUTHORIZATION`.
7. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_REVIEW`.
8. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_IMPLEMENTATION_AUTHORIZATION`.
9. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_IMPLEMENTATION_AND_ABUSE_REVIEW`.
10. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_LIVE_LOOPBACK_VALIDATION_AUTHORIZATION`.
11. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_LIVE_LOOPBACK_VALIDATION_REVIEW`.
12. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_STAGING_AUTHORIZATION`.
13. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_STAGED_DIFF_AND_EVIDENCE_REVIEW`.
14. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_COMMIT_AUTHORIZATION`.
15. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_POST_COMMIT_VERIFICATION`.
16. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_NORMAL_PUSH_AUTHORIZATION`.
17. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_POST_PUSH_PUBLICATION_VERIFICATION`.
18. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_POST_PUBLICATION_CONTROLLED_STATE_AND_HANDOFF_SYNCHRONIZATION_AUTHORIZATION`.
19. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_POST_PUBLICATION_SYNCHRONIZATION_REVIEW`.
20. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_SYNCHRONIZATION_STAGING_AUTHORIZATION`.
21. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SYNCHRONIZATION_STAGED_DIFF_REVIEW`.
22. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_SYNCHRONIZATION_COMMIT_AUTHORIZATION`.
23. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_SYNCHRONIZATION_POST_COMMIT_VERIFICATION`.
24. `SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_SYNCHRONIZATION_NORMAL_PUSH_AUTHORIZATION`.
25. `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_FINAL_PUBLICATION_AND_CLEANLINESS_VERIFICATION`.

Remediation revisions may add Gates but never skip or merge authority boundaries.

## 16. R1 review questions

The independent reviewer must explicitly decide whether:

1. all five P2 findings are closed;
2. Candidate A remains charter-conformant;
3. denied execution is unambiguously three roles with zero read/provider;
4. schema presence/null and status crosswalk are complete;
5. 18,432/16,383/2,048 is safe and least-authority;
6. ten-path closure conditions are sufficient;
7. no M4 behavior or excluded path is widened;
8. the package may proceed to Project Owner scope selection.

## 17. Completion statement

R1 is complete as a planning candidate only. It grants no implementation, system mutation or Git publication authority. The next permissible action is the separate independent R1 review.
