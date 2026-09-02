# EAIRA Local Task Intake V1

Contract revision: 3

## Purpose

Define the bounded task-intake surface for M4 Functional Agent MVP. The intake is a local command-line executable that produces canonical JSON on standard output and performs no persistence. Mock and blocked-real perform no communication; the separately contracted local selection may use exact IPv4 loopback only.

## Invocation

The exact argument order is:

```text
EAIRA.AgentTask.Cli.exe --provider <mock|real> --trace <32-uppercase-hex> --goal <1-to-512-character-goal>
```

No alternate flags, environment-variable configuration, response files or implicit defaults are accepted.

The exact local-model form is:

    EAIRA.AgentTask.Cli.exe --provider ollama-local --model qwen3:4b --trace <32-uppercase-hex> --goal <1-to-512-character-goal>

## Provider policy

| Selection | Provider ID | Behavior |
| --- | --- | --- |
| `mock` | `mock-v1` | Executes the deterministic five-Agent in-memory pipeline |
| `real` | `real-disabled-v1` | Returns `PROVIDER_BLOCKED`; no network, credential or model call occurs |
| `ollama-local` | `ollama-loopback-v1` | Executes through `EAIRA_LOCAL_MODEL_PROVIDER_V1` |
| Any other value | none | Returns `INVALID_REQUEST` and fails closed |

The provider interface is neutral, but the only enabled implementation is the deterministic mock. Selecting `real` proves the configuration switch and safety boundary only; it does not constitute a real-model integration.

## Outcomes

| Outcome | Exit code | Meaning |
| --- | ---: | --- |
| `PASS` | `0` | Guard allowed and all five deterministic roles completed |
| `INVALID_REQUEST` | `64` | Argument, schema, trace, goal or provider selection was invalid |
| `DENIED` | `77` | Guard denied; Operations and Verification did not execute |
| `PROVIDER_BLOCKED` | `78` | External/real provider execution is disabled by policy |
| `LOCAL_PROVIDER_ERROR` | `79` | Local listener, timeout, protocol, digest, response, or validation failed closed |

## Safety boundary

- Local command-line input and standard output only.
- Network: `NONE` for mock, real and invalid; exact `LOOPBACK_ONLY` for an accepted local request.
- Runtime writes: none.
- IPC listener or server: none.
- Credentials and secrets: none.
- Shell and child-process creation: none.
- Windows service activation or configuration: none.
- External model provider execution: disabled.
- The local provider is request-scoped and injected only by the CLI host.

## Acceptance

- Identical mock inputs produce byte-identical canonical JSON.
- Allowed mock input returns all five roles.
- Unsafe mock input returns the three-role denial path.
- Real-provider selection returns `PROVIDER_BLOCKED` without calling a provider.
- The local form requires the exact model and cannot inject an endpoint.
- Local failures emit only `LOCAL_PROVIDER_ERROR/79`.
- Unknown providers and malformed arguments fail closed.
- Unpaired UTF-16 surrogates fail closed as `INVALID_REQUEST`; valid supplementary Unicode scalars remain accepted.
- Two clean builds of the CLI and harness are byte-identical.
