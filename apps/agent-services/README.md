# EAIRA Agent Services — Gate 25 unsigned-release preparation

This directory contains the repository-owned R3 `NOWRITE_A` service-host, the five-Agent functional baseline, the published M4 task/context/knowledge/project-QA capabilities, the M5 Slice 1 bounded local operator, the M5 Slice 2 compiled-contract Health capability, the M5 Slice 3 bounded route-policy preflight, and the M5 Slice 4 request-specific dry-run-plan candidate. Publication state is defined by controlled project status, not inferred from directory contents. The component remains a bounded release-engineering and contract-verification input, not a production-readiness claim.

## Bound service profiles

| Role | Service key | Output |
| --- | --- | --- |
| Planning | `svcEAIRAPlan` | `EAIRA.Planning.Service.exe` |
| Operations | `svcEAIROps` | `EAIRA.Operations.Service.exe` |
| Verification | `svcEAIRVerify` | `EAIRA.Verification.Service.exe` |
| Guard | `svcEAIRGuard` | `EAIRA.Guard.Service.exe` |
| Audit | `svcEAIRAudit` | `EAIRA.Audit.Service.exe` |

Each executable is a distinct x64 .NET Framework 4.8 `ServiceBase` host with a compile-time role, service key and absolute configuration path. The scaffold implements bounded start/stop behavior and fail-closed configuration-presence validation. Its self-test invokes the role's pure functional contract, but the service runtime has no task-intake path. It implements no evidence mutation, listener, network access, IPC, shell, dynamic code or child-process creation.

## Minimum functional Agent slice

Revision 7 of the `EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1` contract is implemented by `src/AgentCore.cs` and exercised by `tests/AgentCoreHarness.cs` entirely in memory:

- allowed flow: Planning candidate -> Guard allow -> Operations no-mutation candidate -> Verification verified -> Audit non-persisted record candidate;
- denied flow: Planning candidate -> Guard deny -> Audit non-persisted record candidate;
- versioned task envelope, role-bound result records, recomputed SHA-256 task/result digests, exact chain depths and previous-result chain links;
- deterministic mock outputs with no clock, randomness, environment, network, IPC, file write or child process; and
- fail-closed rejection of an unknown schema, malformed trace identifier, unsafe goal, task-digest mismatch, role-order bypass, forged previous link, payload/digest tampering and forged Operations handoff.
- task digest recomputation and complete deterministic semantic replay reject post-Guard task mutation, policy-invalid Guard Allow and payload modification followed by digest recomputation.
- malformed UTF-16 is rejected before canonicalization so distinct task text cannot collapse through encoder replacement fallback.

The authoritative contract and limitations are in `contracts/EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1.md`. This slice demonstrates that the five roles can enforce one deterministic handoff policy. SHA-256 does not authenticate hostile in-process principals; a future cross-service trust boundary requires separately reviewed MAC or signature-based handoff. This slice does not connect the Windows services to live tasks, models, credentials, storage or external systems.

## Local task intake

M4 Slice 1 adds a separate, bounded local command-line intake executable. The exact invocation is:

```powershell
& .\EAIRA.AgentTask.Cli.exe --provider mock --trace 0123456789ABCDEF0123456789ABCDEF --goal 'prepare bounded release plan'
```

The `mock` selection executes the deterministic in-memory pipeline and emits canonical JSON on standard output. The `real` selection is present only as a fail-closed configuration boundary: it returns `PROVIDER_BLOCKED` with exit code `78` and does not use a network, credential or external model. Invalid requests return exit code `64`; a Guard denial returns exit code `77`.

The `real` selection remains disabled. M4 Slice 2 adds a separately bounded local selection:

    & .\EAIRA.AgentTask.Cli.exe --provider ollama-local --model qwen3:4b --trace 0123456789ABCDEF0123456789ABCDEF --goal 'prepare bounded release plan'

The local path uses only exact IPv4 loopback `127.0.0.1:11434`, performs exact model-name/full-digest checks before and after generation, uses a request-local two-entry cache, and enforces strict HTTP, UTF-8, JSON, 60-second, 65,536-byte, and 512-UTF-16-unit boundaries. It is a trusted-local consistency design, not cryptographic model pinning. Local failures return only `LOCAL_PROVIDER_ERROR/79`.

The CLI performs no runtime writes, starts no listener or child process, and does not activate or connect the five Windows service hosts. Ollama daemon behavior is outside the EAIRA-client side-effect claim. The authoritative contracts are `contracts/EAIRA_LOCAL_TASK_INTAKE_V1.md` and `contracts/EAIRA_LOCAL_MODEL_PROVIDER_V1.md`.

## Read-only project context

M4 Slice 3 optionally appends `--context-root <absolute-root>` to the mock or `ollama-local` form. A static Guard denial returns before any context or provider construction. An allowed request reads only four controlled status artifacts through pinned Win32 read-only handles, validates exact paths, hydrated Cloud Files state, strict UTF-8, schemas and versions, and sends a bounded 27-field canonical projection only to Planning. Downstream Agents receive a content-free semantic seal. Context failures return sanitized `CONTEXT_ERROR/80`.

The authoritative boundary is `contracts/EAIRA_READ_ONLY_PROJECT_CONTEXT_V1.md`. The feature does not list directories, hydrate files, write the vault, use Git provenance, activate services or contact an external provider.

## Bounded local project QA

Slice 5 adds `EAIRA.ProjectQa.Cli.exe`, a non-production, read-only local QA surface over the exact controlled status and project-memory allowlist. It uses one pinned eleven-file snapshot and the fixed `qwen3:4b` Ollama loopback identity. Output is assistive and model-generated, with host-reconstructed citations; it performs no repository write, directory enumeration, external network call, retry or fallback. See `contracts/EAIRA_BOUNDED_LOCAL_PROJECT_QA_V1.md`.

## Integrated local operator

M5 Slice 1 adds `EAIRA.LocalOperator.Cli.exe`, one unprivileged, single-request console entry point. M5 Slice 2 appends compiled-contract Health. M5 Slice 3 appends bounded route-policy preflight. M5 Slice 4 appends request-specific dry-run planning over the same fixed seven-route policy table. The legacy task, project-knowledge, project-QA and Health routes remain unchanged and call their published typed implementations only after static Guard authorization. Invalid and denied requests construct no reader or provider factory.

Examples:

```powershell
& .\EAIRA.LocalOperator.Cli.exe task --provider mock --trace 0123456789ABCDEF0123456789ABCDEF --goal 'prepare bounded release plan'
& .\EAIRA.LocalOperator.Cli.exe knowledge --root 'C:\EAIRA' --trace 0123456789ABCDEF0123456789ABCDEF --query 'current milestone'
& .\EAIRA.LocalOperator.Cli.exe project-qa --root 'C:\EAIRA' --trace 0123456789ABCDEF0123456789ABCDEF --question 'what is the current objective?' --provider ollama-local --model qwen3:4b
& .\EAIRA.LocalOperator.Cli.exe health --trace 0123456789ABCDEF0123456789ABCDEF
& .\EAIRA.LocalOperator.Cli.exe preflight --trace 0123456789ABCDEF0123456789ABCDEF --route TASK_OLLAMA_LOCAL_CONTEXT
& .\EAIRA.LocalOperator.Cli.exe dry-run task --provider mock --trace 0123456789ABCDEF0123456789ABCDEF --goal 'prepare bounded release plan'
& .\EAIRA.LocalOperator.Cli.exe dry-run knowledge --root 'C:\EAIRA' --trace 0123456789ABCDEF0123456789ABCDEF --query 'current milestone'
& .\EAIRA.LocalOperator.Cli.exe dry-run project-qa --root 'C:\EAIRA' --trace 0123456789ABCDEF0123456789ABCDEF --question 'what is the current objective?' --provider ollama-local --model qwen3:4b
& .\EAIRA.LocalOperator.Cli.exe dry-run health --trace 0123456789ABCDEF0123456789ABCDEF
```

Only the exact positional forms in `contracts/EAIRA_LOCAL_OPERATOR_V1.md` are accepted. Health returns a fixed 366-byte `EAIRA_OPERATOR_HEALTH_V1` payload and a fixed-trace 927-byte canonical line. Preflight accepts one of seven exact route IDs and returns only a canonical `EAIRA_OPERATOR_PREFLIGHT_V1` policy tuple; `ALLOW_PREFLIGHT_ONLY` never authorizes the described route. Dry-run accepts exactly seven request forms, performs the same shared policy lookup only after a dedicated static Guard allow, and emits an exact 13-member `EAIRA_OPERATOR_DRY_RUN_PLAN_V1` object in the order `schema`, `planStatus`, `routeId`, `capability`, `sourceClass`, `providerPolicy`, `routeNetwork`, `routeAuthority`, `writes`, `planGuardEvaluation`, `executionGuardEvaluation`, `executionStatus`, `authority`, with `planStatus=VALIDATED_NOT_EXECUTED`, `writes=NONE`, `planGuardEvaluation=ALLOW_DRY_RUN_ONLY`, `executionGuardEvaluation=NOT_EVALUATED`, `executionStatus=NOT_EXECUTED`, and `authority=PLAN_NOT_AUTHORITY`. Health, Preflight and dry-run perform no factory/provider construction, reads, writes or network calls and are non-authoritative. Output is one validated canonical UTF-8 JSON line, written once after complete in-memory construction. Payloads are capped at 16,383 bytes, the maximum wrapper is 587 bytes, and complete stdout is capped at 16,970 bytes. The operator adds no persistence, listener, IPC, shell, child process, credential, external provider, arbitrary vault read, or project-authority surface. Knowledge remains navigational; QA remains assistive and model-generated; trace identifiers are correlation only.

## Gate 25 build

`build/Invoke-Gate25UnsignedRelease.ps1`:

1. verifies the hash-bound .NET Framework 4.8 reference assemblies;
2. requires a Roslyn compiler supporting both deterministic output and path mapping;
3. requires the exact compiler SHA-256 and Microsoft Authenticode signer bound in the release profile;
4. performs two isolated clean builds of all five role-bound executables;
5. scans compiled metadata for prohibited runtime API tokens;
6. builds a separate x64 functional harness and runs the complete in-memory five-role flow, denial flow and negative contract tests;
7. builds the local task-intake CLI, the context-aware intake harness, the 52-test project-context harness, the 41-test fake-provider harness, and the 10-test no-socket transport-policy harness, then verifies mock, Guard denial, disabled-real, malformed request, bounded local-provider behavior, complete read-only context abuse matrices, and fail-closed context handling;
8. runs every role-bound service's offline self-test and negative argument test;
9. verifies x64 PE machine type and `NotSigned` Authenticode state;
10. compiles the M5 local-operator harness and CLI in exact source order, preserves the 96-case Slice 1, 119-case Slice 2 and 166-case Slice 3 prefixes, verifies the complete 224-case Slice 4 list as 6,650 framed bytes and the appended 58-case suffix as 1,901 framed bytes, checks invalid/deny/mock/health/preflight/dry-run stdout channels, and compile-then-rejects the retained matrix plus the exact ordered 15-row Preflight and 15-row dry-run abuse matrices;
11. requires byte-identical SHA-256 values across both builds; and
12. binds the exact 32-path historical candidate scopes plus the operator's ordered 37 inputs and exact reference-assembly hashes/versions, verifies the six-method project-context P/Invoke boundary, native caller IL, loopback and output-isolation policies, and performs decoded IL/CFG/dominance checks over the Health, Preflight and dry-run dispatches, their transitive allowed closures and the two instrumented loopback entrypoints, then emits a sanitized manifest. Discovery modes never create an unsigned-release directory; final mode copies the unsigned operator CLI only after every non-signing check and the separately reviewed profile SHA-256 pass.

Example after an approved Roslyn build toolchain is available:

```powershell
& .\apps\agent-services\build\Invoke-Gate25UnsignedRelease.ps1 `
  -RoslynCscPath '<approved-absolute-path-to-Roslyn-csc.exe>' `
  -OutputRoot 'C:\Users\User\EAIRA_GATE25_UNSIGNED_RC1'
```

The legacy .NET Framework compiler may be assessed only with `-DevelopmentProbe`. That mode can validate compilation and runtime checks but cannot emit the accepted M4 technical-check status or satisfy reproducibility.

## Explicit exclusions

- No certificate, private key, signing credential, timestamp or production signature is used.
- The produced functional and service runtimes do not create child processes. The build pipeline necessarily starts the approved compiler and the newly built offline test executables; that bounded build-time activity is recorded separately from the runtime policy.
- No Windows service, account, group, membership, directory, ACL, TPM object or firewall rule is created or changed.
- No output is written into the repository unless the caller explicitly chooses such a path; generated release evidence should remain outside the repository.
- A successful M5 Slice 4 final build means only `M5_SLICE4_UNSIGNED_TECHNICAL_CHECKS_PASS`. It explicitly records `externalSigningEligible=false` and `signatureOnlyBlocked=false`; a dry-run result is not execution or authority, and the build is not live provider/service health, signing, Windows-service, customer-deployment or production-readiness evidence.
