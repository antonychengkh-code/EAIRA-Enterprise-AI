# EAIRA M5 Slice 4 Scope Decision

## Decision control

- Decision ID: `EAIRA_M5_SLICE4_SCOPE_DECISION_V1R1`
- Date: `2026-09-13`
- Project Owner selection: `M5S4_A_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN`
- Baseline: `a0ef10a38fa0ac7fb62b9693f65936b0ff61fda9`
- Product predecessor: `7cf3b323c7b393ed817f7a9ac4562b27d1e512fc`
- Decision state: `SCOPE_READINESS_PASSED_EXACT_DESIGN_R2R1_CANDIDATE_PREPARED`
- Scope/readiness preparation authority: `GRANTED`
- Exact-design authority: `GRANTED`
- Implementation authority: `NOT_GRANTED`
- Repository-recording authority: `NOT_GRANTED`
- Force-push authority: `NOT_GRANTED`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE4_A_EXACT_IMPLEMENTATION_DESIGN_R3_REVIEW`

## Selected outcome

Add one bounded request-specific dry-run planning surface to the published
user-mode Local Operator. A human may submit one exact existing route command
under a `dry-run` prefix and receive a canonical sanitized plan describing how
the current binary classifies that request.

The plan validates command grammar and bounded argument syntax only. It does not
execute the selected route, evaluate the selected route's execution Guard,
read project or vault content, check whether a path exists, construct an adapter
or provider, connect to any endpoint, call a model, write state, persist a
receipt, or grant authority.

## Provisional command surface

Only these seven shapes may proceed to exact-design consideration:

```text
EAIRA.LocalOperator.Cli.exe dry-run task --provider mock --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe dry-run task --provider mock --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe dry-run task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe dry-run task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe dry-run knowledge --root <ROOT> --trace <TRACE> --query <QUERY>
EAIRA.LocalOperator.Cli.exe dry-run project-qa --root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b
EAIRA.LocalOperator.Cli.exe dry-run health --trace <TRACE>
```

The route ID is derived from the accepted grammar. There is no user-supplied
route override, alias, default, flag reordering, duplicate or extra flag,
response file, stdin, environment/config expansion, alternate provider, model
or endpoint. The published input validation and byte ceilings remain the upper
bounds; the exact design may reduce but not enlarge them.

The existing `preflight` command is not a dry-run target. Dry-run cannot wrap
dry-run or preflight, and cannot accept an executable path, shell string or
opaque command line.

## Input allowlist

The only inputs are the process argv values shown above. They are treated as
untrusted data.

- `TRACE` retains the exact 32-character uppercase hexadecimal rule.
- `GOAL`, `QUERY`, `QUESTION` and `ROOT` retain their published
  character, Unicode and byte-validation rules.
- `ROOT` receives syntax-only validation. No existence, type, hydration,
  Cloud Files, ACL or content check is permitted.
- Free-form values may contain instruction-shaped text but never influence
  routing, policy constants, Guard intent or output member names.
- No project file, vault file, environment value, config file, registry value,
  stdin byte, response file or network response is an input.

## Output allowlist

Success emits one canonical UTF-8 JSON line using the existing
`EAIRA_LOCAL_OPERATOR_V1` wrapper and a new bounded
`EAIRA_OPERATOR_DRY_RUN_PLAN_V1` payload.

The payload contains exactly the fixed ordered 13-member schema defined by the
readiness package and no other member. The
policy projection values must be obtained from the published seven-row
`LocalOperatorPreflightPolicy` table; Slice 4 may not define a second policy
vocabulary or duplicate an independently maintained table:

- plan status `VALIDATED_NOT_EXECUTED`;
- one of the seven derived route IDs;
- the exact published capability, source-class, provider-policy,
  route-network and route-authority bytes for the derived route;
- `writes=NONE`;
- `planGuardEvaluation=ALLOW_DRY_RUN_ONLY` or a sanitized denial;
- `executionGuardEvaluation=NOT_EVALUATED`;
- `executionStatus=NOT_EXECUTED`;
- `authority=PLAN_NOT_AUTHORITY`; and
- canonical whole-request, generic dry-run route and payload digests carried by
  the outer wrapper.

The output must not contain or derive a reversible form of the root, goal,
query, question, prompt, provider body, project content, per-file digest,
credential, environment value, exception, stack trace or native diagnostic.
No per-field digest, raw length or echo is permitted. Invalid and denied
requests use fixed sanitized terminal forms, empty stderr and no partial stdout.

## Authority and replay boundary

The dry-run plan is explanation, not authority.

- `ALLOW_DRY_RUN_ONLY` permits only creation of this in-memory plan.
- The selected route's execution Guard is not evaluated.
- A later execution must parse its own argv and perform its own fresh Guard
  decision.
- The request, route or payload digest is not a nonce, capability, signature,
  confirmation token, lock, reservation or replay defense.
- Outer `requestSha256` and `routeSha256` identify the dry-run request and its
  generic dry-run route. They neither identify nor equal a later execution
  request or execution route.
- Outer `payloadSha256` binds the complete successful 13-member payload,
  including the selected canonical policy tuple. Outer `routeSha256` does not
  bind that described row. No separate described-policy digest is permitted.
- No cross-process, cross-version or time-of-check/time-of-use binding is
  claimed.

## Canonical policy reuse and Guard observability

The dry-run implementation must directly reuse the published Slice 3
`LocalOperatorPreflightPolicy` lookup or a single shared canonical table used by
both preflight and dry-run. The exact bytes remain:

- source classes: `USER_ARGUMENTS_ONLY`, `CONTROLLED_PROJECT_CONTEXT`,
  `CONTROLLED_PROJECT_MEMORY`, `CONTROLLED_CONTEXT_AND_PROJECT_MEMORY`, and
  `COMPILED_CONTRACT_ONLY`;
- provider policies: `MOCK`, `OLLAMA_LOCAL_QWEN3_4B`, and `NONE`;
- route networks: `NONE` and `LOOPBACK_ONLY`; and
- route authorities: the exact existing per-route Slice 3 values.

Dry-run-only meaning belongs solely in `planStatus`,
`planGuardEvaluation`, `executionGuardEvaluation`, `executionStatus`,
`writes` and `authority`; it must not rename the described policy.

For every syntactically valid dry-run request, the plan-only Guard is called
exactly once. Invalid argv calls Guard zero times. A denied request performs
zero described-policy lookups and zero plan-payload constructions. Test seams
must expose exact call counts without changing production behavior.

## Changed-path ceilings

This preparation Gate creates exactly two candidate documents:

1. `docs/project/strategy/EAIRA_M5_SLICE4_SCOPE_DECISION.md`
2. `docs/project/planning/EAIRA_M5_SLICE4_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN_READINESS_PACKAGE.md`

A future complete Slice 4 implementation candidate may contain at most these
nine paths:

1. `apps/agent-services/README.md`
2. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`
3. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
4. `apps/agent-services/release/gate25-unsigned-release-profile.json`
5. `apps/agent-services/src/LocalOperator.cs`
6. `apps/agent-services/tests/LocalOperatorHarness.cs`
7. `docs/project/planning/EAIRA_M5_SLICE4_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN_READINESS_PACKAGE.md`
8. `docs/project/planning/EAIRA_M5_SLICE4_EXACT_IMPLEMENTATION_DESIGN.md`
9. `docs/project/strategy/EAIRA_M5_SLICE4_SCOPE_DECISION.md`

The exact design may reduce this ceiling. Adding a tenth path or substituting a
path requires a separate Project Owner scope-remediation decision.

## Out of scope

This decision does not authorize:

- implementation, build, test execution or release evidence generation;
- task, knowledge, project-QA, health or preflight execution;
- execution confirmation, approval receipts, replay prevention or persistence;
- project or vault content reads, directory enumeration or path probing;
- provider/adapter construction, model calls or any network activity;
- repository, filesystem, registry, IPC, log, cache or transcript writes;
- shell, child process, dynamic loading, listener or Windows service activity;
- account, group, membership, directory, ACL, BitLocker, TPM, certificate,
  signing, external-provider or production changes;
- changes under `docs/integrations/`, `scripts/claude_api.py`, repository-root
  `tests/` or `.obsidian/`; or
- staging, commit, push, force push or publication.

## Decision

`M5S4_A_BOUNDED_REQUEST_SPECIFIC_DRY_RUN_PLAN` is selected as a bounded
planning scope only. The accompanying readiness package is eligible for a
fresh separate independent R1R1 review. The exact-design candidate is now
prepared under the later phase authorization. No implementation or repository
recording authority is inferred from this document.
