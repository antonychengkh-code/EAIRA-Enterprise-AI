# EAIRA Local Operator V1

`EAIRA.LocalOperator.Cli.exe` is an unsigned, unprivileged, single-request console entry point for the published task, knowledge, project-QA and compiled-contract Health capabilities plus bounded route-policy preflight and request-specific dry-run planning. It is assistive software, not project authority.

## Exact commands

```text
EAIRA.LocalOperator.Cli.exe task --provider mock --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe task --provider mock --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe knowledge --root <ROOT> --trace <TRACE> --query <QUERY>
EAIRA.LocalOperator.Cli.exe project-qa --root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b
EAIRA.LocalOperator.Cli.exe health --trace <TRACE>
EAIRA.LocalOperator.Cli.exe preflight --trace <TRACE> --route <ROUTE_ID>
EAIRA.LocalOperator.Cli.exe dry-run task --provider mock --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe dry-run task --provider mock --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe dry-run task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe dry-run task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe dry-run knowledge --root <ROOT> --trace <TRACE> --query <QUERY>
EAIRA.LocalOperator.Cli.exe dry-run project-qa --root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b
EAIRA.LocalOperator.Cli.exe dry-run health --trace <TRACE>
```

Preflight accepts exactly one of `TASK_MOCK`, `TASK_MOCK_CONTEXT`,
`TASK_OLLAMA_LOCAL`, `TASK_OLLAMA_LOCAL_CONTEXT`, `KNOWLEDGE`,
`PROJECT_QA_OLLAMA_LOCAL`, or `HEALTH` as `ROUTE_ID`.

No alias, default, reordered/duplicate/extra flag, response file, stdin, environment/config expansion, alternate provider, model or endpoint is accepted. Trace is 32 uppercase hexadecimal characters. Inputs and roots inherit the exact published M4 validation rules.

## Authorization and routing

Every valid request creates a `TaskEnvelope` and calls static Guard before any reader or provider factory. Denial executes Planning → Guard(DENY) → Audit with zero reads/provider calls. Allow executes Planning → Guard(ALLOW) → Operations → Verification → Audit.

- Task reuses `EAIRA_LOCAL_TASK_INTAKE_V1` in-process.
- Knowledge reads only the published ordered seven-file set and invokes no provider.
- Project QA reads only four context plus seven knowledge files and uses exact `qwen3:4b` through `127.0.0.1:11434`, tags/chat/tags, no retry/fallback.
- Health returns only the compile-time `EAIRA_OPERATOR_HEALTH_V1` payload. It performs zero reads, writes, provider/factory construction, model calls or network calls and reports `COMPILED_CONTRACT_ONLY` with `OBSERVATIONAL_NOT_AUTHORITY`.
- Preflight uses a fixed internal Guard intent, then explains only the selected
  route's compiled capability, source class, provider, network, write and
  authority policy. `ALLOW_PREFLIGHT_ONLY` authorizes only this explanation,
  never the described route. It performs zero reads, writes, adapter/provider
  construction, model calls or network calls.
- Dry-run uses the fixed Guard goal `PLAN REQUEST WITHOUT EXECUTION`, then
  describes exactly one request-specific route using the same seven-row policy
  lookup as Preflight. `ALLOW_DRY_RUN_ONLY` authorizes only emission of the
  canonical plan and never authorizes or executes the described route. It
  performs zero reads, writes, adapter/provider construction, model calls,
  network calls, shell/child-process operations or persistence.

Health, Preflight and dry-run use the exact call budget `MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0`. Static Guard runs before any of these branches. Their allowed and denied paths require a same-process connect-attempt delta of zero; the two sanctioned loopback entrypoints are independently instrumented and IL-verified, but none of these branches invokes either entrypoint. Preflight and dry-run denial occurs before the seven-row policy lookup or payload construction.

No route writes files/registry/IPC/log/cache/transcript, starts a child process or shell, dynamically loads code, reads `.obsidian`, or invokes an external provider.

## Output

One canonical UTF-8 JSON line is emitted with exact member order:

`schema`, `status`, `traceId`, `capability`, `network`, `writes`, `authority`, `requestSha256`, `routeSha256`, `payloadSha256`, `payload`, `audit`.

Schema is `EAIRA_LOCAL_OPERATOR_V1`. Valid statuses and exits are:

- `PASS` 0
- `INVALID_REQUEST` 64
- `DENIED` 77
- `PROVIDER_ERROR` 79
- `CONTEXT_ERROR` 80
- `KNOWLEDGE_ERROR` 81
- `QA_VALIDATION_ERROR` 82
- `ORCHESTRATION_ERROR` 83
- `OUTPUT_ERROR` 84

`PROVIDER_BLOCKED`/78 is not part of this contract. Legacy task behavior is unchanged.

PASS embeds one validated M4 canonical object, the fixed Health object, an exact 14-member `EAIRA_OPERATOR_PREFLIGHT_V1` object, or an exact 13-member `EAIRA_OPERATOR_DRY_RUN_PLAN_V1` object. The dry-run payload order is `schema`, `planStatus`, `routeId`, `capability`, `sourceClass`, `providerPolicy`, `routeNetwork`, `routeAuthority`, `writes`, `planGuardEvaluation`, `executionGuardEvaluation`, `executionStatus`, `authority`; its fixed plan status is `VALIDATED_NOT_EXECUTED`, write policy is `NONE`, plan Guard state is `ALLOW_DRY_RUN_ONLY`, execution Guard state is `NOT_EVALUATED`, execution status is `NOT_EXECUTED`, and outer authority is `PLAN_NOT_AUTHORITY`. Preflight and dry-run keep the described route authority separate from their fixed outer authority and contain no free-form explanation or raw input. Denial/errors have null payload and payload digest. Invalid request before a sealed route has null trace/capability/digests/audit. Other terminal outcomes contain sanitized request/route and Audit chain digests. Stderr is empty and no partial stdout is emitted.

Bounds:

- embedded object: at most 16,383 UTF-8 bytes;
- maximum valid wrapper: 587 bytes including LF;
- complete line: at most 16,970 bytes including LF.

The output never contains an absolute root, raw prompt, provider body/response, raw source, per-file digest, native diagnostic, credential or exception.

## Replay and authority

Trace is correlation only, not authorization or a nonce. This no-persistence slice makes no cross-process replay-prevention claim. Knowledge is `NAVIGATIONAL_NOT_AUTHORITY`; QA is `ASSISTIVE_NOT_AUTHORITY`; task is `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY`.
Health is `OBSERVATIONAL_NOT_AUTHORITY`: `POLICY_READY` describes the compiled contract only and is not live provider, service, operating-system, credential, certificate, deployment or production health.
Preflight is `EXPLANATORY_NOT_AUTHORITY`: its Guard result applies only to
emitting compiled policy and is not readiness, permission or authorization for
the described route. Running that route separately requires its own Guard check.
Dry-run is `PLAN_NOT_AUTHORITY`: it records `NOT_EXECUTED`, never evaluates the
described route's execution Guard, and cannot be used as authority, readiness,
permission or evidence that the described route was executed.
