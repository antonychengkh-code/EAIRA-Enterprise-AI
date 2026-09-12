# EAIRA Local Operator V1

`EAIRA.LocalOperator.Cli.exe` is an unsigned, unprivileged, single-request console entry point for the published task, knowledge and project-QA capabilities. It is assistive software, not project authority.

## Exact commands

```text
EAIRA.LocalOperator.Cli.exe task --provider mock --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe task --provider mock --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL>
EAIRA.LocalOperator.Cli.exe task --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ROOT>
EAIRA.LocalOperator.Cli.exe knowledge --root <ROOT> --trace <TRACE> --query <QUERY>
EAIRA.LocalOperator.Cli.exe project-qa --root <ROOT> --trace <TRACE> --question <QUESTION> --provider ollama-local --model qwen3:4b
```

No alias, default, reordered/duplicate/extra flag, response file, stdin, environment/config expansion, alternate provider, model or endpoint is accepted. Trace is 32 uppercase hexadecimal characters. Inputs and roots inherit the exact published M4 validation rules.

## Authorization and routing

Every valid request creates a `TaskEnvelope` and calls static Guard before any reader or provider factory. Denial executes Planning → Guard(DENY) → Audit with zero reads/provider calls. Allow executes Planning → Guard(ALLOW) → Operations → Verification → Audit.

- Task reuses `EAIRA_LOCAL_TASK_INTAKE_V1` in-process.
- Knowledge reads only the published ordered seven-file set and invokes no provider.
- Project QA reads only four context plus seven knowledge files and uses exact `qwen3:4b` through `127.0.0.1:11434`, tags/chat/tags, no retry/fallback.

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

PASS embeds one validated M4 canonical object. Denial/errors have null payload and payload digest. Invalid request before a sealed route has null trace/capability/digests/audit. Other terminal outcomes contain sanitized request/route and Audit chain digests. Stderr is empty and no partial stdout is emitted.

Bounds:

- embedded object: at most 16,383 UTF-8 bytes;
- maximum valid wrapper: 587 bytes including LF;
- complete line: at most 16,970 bytes including LF.

The output never contains an absolute root, raw prompt, provider body/response, raw source, per-file digest, native diagnostic, credential or exception.

## Replay and authority

Trace is correlation only, not authorization or a nonce. This no-persistence slice makes no cross-process replay-prevention claim. Knowledge is `NAVIGATIONAL_NOT_AUTHORITY`; QA is `ASSISTIVE_NOT_AUTHORITY`; task is `BOUNDED_EXECUTION_RESULT_NOT_PROJECT_AUTHORITY`.
