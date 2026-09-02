# EAIRA Agent Services — Gate 25 unsigned-release preparation

This directory contains the repository-owned R3 `NOWRITE_A` service-host and five-Agent functional baseline plus the current M4 working-tree candidate. Publication state is defined by the controlled project status, not inferred from directory contents. The component remains a bounded release-engineering and contract-verification input, not a claim that production readiness is complete.

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

Revision 5 of the `EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1` contract is implemented by `src/AgentCore.cs` and exercised by `tests/AgentCoreHarness.cs` entirely in memory:

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

The provider-neutral interface is not a real-provider integration. The CLI performs no runtime writes, starts no listener or child process, and does not activate or connect the five Windows service hosts. The authoritative intake contract is `contracts/EAIRA_LOCAL_TASK_INTAKE_V1.md`.

## Gate 25 build

`build/Invoke-Gate25UnsignedRelease.ps1`:

1. verifies the hash-bound .NET Framework 4.8 reference assemblies;
2. requires a Roslyn compiler supporting both deterministic output and path mapping;
3. requires the exact compiler SHA-256 and Microsoft Authenticode signer bound in the release profile;
4. performs two isolated clean builds of all five role-bound executables;
5. scans compiled metadata for prohibited runtime API tokens;
6. builds a separate x64 functional harness and runs the complete in-memory five-role flow, denial flow and negative contract tests;
7. builds the local task-intake CLI and its harness, then verifies deterministic mock, Guard denial, disabled-real-provider and malformed-request outcomes;
8. runs every role-bound service's offline self-test and negative argument test;
9. verifies x64 PE machine type and `NotSigned` Authenticode state;
10. requires byte-identical SHA-256 values across both builds; and
11. emits a sanitized manifest and an unsigned release directory only after every non-signing check passes.

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
- A successful unsigned build means only `M4_SLICE_1_UNSIGNED_TECHNICAL_CHECKS_PASS`. It explicitly records `externalSigningEligible=false` and `signatureOnlyBlocked=false`. Gate 25 remains incomplete, and signing eligibility depends on separately completed Gate 24 governance and release prerequisites.
