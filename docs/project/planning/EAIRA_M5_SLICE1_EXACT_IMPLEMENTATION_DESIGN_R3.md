# EAIRA M5 Slice 1 Exact Implementation Design R3

## Control

- Design ID: `EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_V1R3`
- Date: `2026-09-12`
- Base: V1 design plus normative R2 overlay
- Prior R2 verdict: `FAIL/CANNOT_CLOSE`; P0 `0`, P1 `4`, P2 `0`
- State: `R3_READY_FOR_INDEPENDENT_EXACT_DESIGN_REVIEW`
- Implementation authority: `NOT_GRANTED_BY_THIS DOCUMENT`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3_REVIEW`

This R3 replaces only the four R2 sections identified below. All other R2 and V1 requirements remain normative.

## 1. Exact task semantic and transport call budgets

R3 replaces every R2 task `MODEL_COMPLETE=2` call-budget value. The route seal now distinguishes method invocations, unique semantic completions and transport calls.

| Allowed task route | `IModelProvider.Complete` method invocations | Unique semantic completions | Tags | Chat |
|---|---:|---:|---:|---:|
| mock, no context | 10 | 2 | 0 | 0 |
| mock, context | 6 | 2 | 0 | 0 |
| Ollama, no context | 10 | 2 | 2 | 2 |
| Ollama, context | 6 | 2 | 2 | 2 |

Exact route-seal call-budget strings are respectively:

- `COMPLETE_INVOCATIONS=10;UNIQUE_COMPLETIONS=2;TAGS=0;CHAT=0`
- `COMPLETE_INVOCATIONS=6;UNIQUE_COMPLETIONS=2;TAGS=0;CHAT=0`
- `COMPLETE_INVOCATIONS=10;UNIQUE_COMPLETIONS=2;TAGS=2;CHAT=2`
- `COMPLETE_INVOCATIONS=6;UNIQUE_COMPLETIONS=2;TAGS=2;CHAT=2`

Static denial occurs before the task adapter factory and therefore has `COMPLETE_INVOCATIONS=0;UNIQUE_COMPLETIONS=0;TAGS=0;CHAT=0` regardless of the requested allowed provider form.

The harness uses a counting provider whose cache behavior matches the existing local provider. It asserts both method invocations and cache misses/unique completions. Transport chat counts bind only cache misses; semantic validation replays do not create extra chat calls.

## 2. Exact QA runner stage, exception and counter closure

### 2.1 Observer and legacy compatibility

`ProjectQaRunner.Execute` accepts an optional `IProjectQaExecutionObserver`. The legacy host passes `null`; the operator passes a request-scoped observer. The observer records stages/counters only and never affects control flow or catches an exception.

`ProjectQaExecutionStage` values:

1. `Parsed=1`
2. `GuardAllowed=2`
3. `SnapshotFactoryCalled=3`
4. `SnapshotReadCalled=4`
5. `SnapshotReady=5`
6. `PromptReady=6`
7. `BodyReady=7`
8. `ProviderFactoryCalled=8`
9. `ProviderReady=9`
10. `ProviderReturned=10`
11. `AnswerDecoded=11`
12. `OutputReady=12`

The runner catches exactly the exception classes caught by the current host and returns the same fixed legacy lines. Any otherwise-unhandled exception continues to propagate unchanged from the runner. Consequently, the legacy CLI preserves its current no-contract/unhandled-exception behavior for such impossible/unexpected branches; R3 does not claim a new legacy guarantee.

The operator QA adapter catches a propagated unexpected exception outside the runner and uses the observer:

- stage 1–8: `ORCHESTRATION_ERROR`/83, network `NONE`, Operations/Failed then Audit;
- stage 9–12: `PROVIDER_ERROR`/79, network `LOOPBACK_ONLY`, Operations/Failed then Audit.

No exception type, message, stack or stage number enters output.

### 2.2 Exact counter tuple

Tuple order is:

`snapshotFactoryCalls, snapshotReadCalls, providerFactoryCalls, tagsCalls, chatCalls, preflightDigestValidated, postflightDigestValidated`.

| Cut-point | Exact tuple | Status / exit / network |
|---|---|---|
| parse invalid | `0,0,0,0,0,false,false` | INVALID_REQUEST / 64 / NONE |
| static deny | `0,0,0,0,0,false,false` | DENIED / 77 / NONE |
| snapshot factory throws | `1,0,0,0,0,false,false` | ORCHESTRATION_ERROR / 83 / NONE in operator; propagated in legacy if not a caught type |
| snapshot read context error | `1,1,0,0,0,false,false` | CONTEXT_ERROR / 80 / NONE |
| snapshot read knowledge error | `1,1,0,0,0,false,false` | KNOWLEDGE_ERROR / 81 / NONE |
| prompt build error | `1,1,0,0,0,false,false` | QA_VALIDATION_ERROR / 82 / NONE |
| body build error | `1,1,0,0,0,false,false` | QA_VALIDATION_ERROR / 82 / NONE |
| provider factory throws | `1,1,1,0,0,false,false` | ORCHESTRATION_ERROR / 83 / NONE in operator; propagated in legacy if not a caught type |
| preflight tags failure | `1,1,1,1,0,false,false` | PROVIDER_ERROR / 79 / LOOPBACK_ONLY |
| chat failure | `1,1,1,1,1,true,false` | PROVIDER_ERROR / 79 / LOOPBACK_ONLY |
| postflight tags failure | `1,1,1,2,1,true,false` | PROVIDER_ERROR / 79 / LOOPBACK_ONLY |
| decode/answer validation failure | `1,1,1,2,1,true,true` | QA_VALIDATION_ERROR / 82 / LOOPBACK_ONLY |
| success | `1,1,1,2,1,true,true` | PASS / 0 / LOOPBACK_ONLY |

The observer obtains provider counters through `IProjectQaProvider` after each reached stage and before disposal. A failing provider factory has no provider object, so its provider counters are zero. Disposal exceptions remain swallowed and do not alter the tuple or output, matching existing behavior.

`ProjectQaRunResult` adds `SnapshotFactoryCalls`, `SnapshotReadCalls`, `ProviderFactoryCalls` and `LastStage` to the R2 fields. It validates the exact tuple for its terminal status and never contains raw root, prompt, body, response or content.

## 3. Canonical 96-case harness channel

R3 appends the following exact cases to R2's 72 cases, preserving cases 1–72 unchanged:

73. `CROSSWALK_TASK_INVALID`
74. `CROSSWALK_TASK_PROVIDER_ERROR`
75. `CROSSWALK_TASK_CONTEXT_ERROR`
76. `CROSSWALK_KNOWLEDGE_DENIED`
77. `CROSSWALK_KNOWLEDGE_INVALID`
78. `CROSSWALK_KNOWLEDGE_ERROR`
79. `CROSSWALK_QA_DENIED`
80. `CROSSWALK_QA_INVALID`
81. `CROSSWALK_QA_PROVIDER_ERROR`
82. `CROSSWALK_QA_CONTEXT_ERROR`
83. `CROSSWALK_QA_KNOWLEDGE_ERROR`
84. `CROSSWALK_QA_VALIDATION_ERROR`
85. `CROSSWALK_ORCHESTRATION_ERROR`
86. `CROSSWALK_OUTPUT_ERROR`
87. `INVALID_STDIN_TOKEN`
88. `INVALID_ENV_TOKEN`
89. `INVALID_CONFIG_TOKEN`
90. `QA_FAILURE_SNAPSHOT_FACTORY`
91. `QA_FAILURE_SNAPSHOT_READ_CONTEXT`
92. `QA_FAILURE_SNAPSHOT_READ_KNOWLEDGE`
93. `QA_FAILURE_PROMPT_BUILD`
94. `QA_FAILURE_BODY_BUILD`
95. `QA_FAILURE_PROVIDER_FACTORY`
96. `QA_FAILURE_DECODE`

Execution order and digest order are exactly 1–96; no sorting occurs.

- Expected count: `96`.
- Canonical framed bytes: `2,409`.
- Expected SHA-256: `0AAF52EE6A087B487B6497676F48BA7AD0D36CB987C149CC1BADAD9CA5D2FE68`.

The harness output schema is replaced in full by one canonical JSON line with members in this exact order:

1. `schema`: `EAIRA_LOCAL_OPERATOR_HARNESS_V1`
2. `status`: `PASS` or `FAIL`
3. `testsPassed`
4. `caseNames`: exact ordered JSON array of all names reached; PASS requires all 96
5. `caseNameFramedBytes`
6. `caseNameSha256`
7. `wrapperMaximumBytes`
8. `network`: `NONE`
9. `writes`: `NONE`

On PASS, values are exactly 96, all 96 names, 2409, the digest above and 587. On FAIL, `caseNames` includes only the successfully completed prefix and the digest is recomputed over that prefix; no exception text is emitted.

The build verifier parses the emitted `caseNames`, requires exact count/order equality against its own fixed 96-string array, independently reconstructs the domain/NUL/Field framing, and checks bytes/digest. It does not trust harness-emitted count, framed bytes or digest alone.

Updated requirement mapping:

- canonical forms: 1–6;
- argv/provider/input/path including response/stdin/env/config tokens: 7–25 and 87–89;
- Guard/read/factory order: 26–31;
- chain/confused deputy/tamper: 32–41;
- provider budgets/cut-points: 42–48 and 90–96;
- exposure/injection/provider output: 49–59;
- sequential isolation: 60–61;
- size/channel atomicity: 62–70;
- replay: 71;
- legacy QA: 72;
- every non-PASS R2 crosswalk row: 73–86.

The full unchanged M4 harness suite remains a separate mandatory regression input and is not counted among the 96 operator cases.

## 4. Complete normative design binding

R3 replaces the R2 ordered `boundRepositoryInputs` count 24 with count 25. Insert the V1 base design immediately before R2 design:

1. M5 charter
2. scope V1
3. scope R1
4. scope R2
5. scope R3
6. scope decision
7. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN.md`
8. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R2.md`
9. `docs/project/planning/EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3.md`
10. `apps/agent-services/README.md`
11. new operator contract
12–25. the same ordered compile/product inputs that followed the R2 design entry, ending with the build script

For avoidance of ambiguity, the exact paths for entries 12–25 remain R2 entries 10–24 in their same order:

`ContractCodec.cs`, `AgentCore.cs`, `ModelProviders.cs`, `LocalTaskIntake.cs`, `LocalModelProvider.cs`, `OllamaLoopbackTransport.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectContext.cs`, `ProjectKnowledge.cs`, `ProjectQa.cs`, `ProjectQaHost.cs`, `LocalOperator.cs`, `LocalOperatorHost.cs`, `LocalOperatorHarness.cs`, then `Invoke-Gate25UnsignedRelease.ps1`.

The profile itself remains excluded from its own bound-input list and is externally bound by the mandatory pre-parse `ExpectedReleaseProfileSha256` in final mode.

Discovery path count/order is fixed at 25; only hashes may be discovered. Final mode requires all 25 reviewed hashes.

## 5. Gate state

`SEPARATE_PROJECT_OWNER_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3_REMEDIATION_AUTHORIZATION` is applied only to the four P1 findings above.

Next Gate:

`SEPARATE_INDEPENDENT_EAIRA_M5_SLICE1_EXACT_IMPLEMENTATION_DESIGN_R3_REVIEW`

No product implementation, live provider call, staging, commit or push is authorized by this design remediation document.
