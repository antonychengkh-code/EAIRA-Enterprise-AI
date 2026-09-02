# EAIRA Minimum Functional Agent Slice V1

Contract revision: 6

## Scope

This contract defines the in-memory five-role functional slice. The deterministic mock profile remains offline and byte-reproducible. M4 Slice 2 additionally permits a separately contracted request-scoped local-model provider only through the task-intake CLI. It does not authorize external AI APIs, credentials, file or registry writes, IPC, child processes, Windows service activation, evidence persistence or production mutation.

## Flow

The allowed positive sequence is exactly:

```text
Planning -> Guard -> Operations -> Verification -> Audit
```

When Guard denies a task, the fail-closed sequence is exactly:

```text
Planning -> Guard(DENY) -> Audit(PERSISTED=NO)
```

Operations and Verification must not execute after a Guard denial.

## Roles

| Role | Input requirement | Output decision | Boundary |
| --- | --- | --- | --- |
| Planning | Valid V1 task envelope | `Candidate` | Produces a deterministic plan candidate only |
| Guard | Planning candidate bound to the same task | `Allow` or `Deny` | Denies prohibited `NOWRITE_A` terms |
| Operations | Guard `Allow` bound to the same task | `Candidate` | Produces an in-memory action candidate with `MUTATION=NONE` |
| Verification | Operations candidate bound to the same task | `Verified` | Verifies the complete deterministic structural and semantic prefix |
| Audit | Verification result or Guard denial | `RecordedCandidate` | Produces an audit-event candidate with `PERSISTED=NO` |

## Task envelope

The V1 task envelope contains:

- `schemaVersion`: exactly `1`;
- `traceId`: exactly 32 uppercase hexadecimal characters;
- `goal`: 1–512 characters with no control characters; and
- `taskDigest`: SHA-256 over a domain-separated, length-prefixed canonical representation.

Unknown schema versions, malformed trace IDs, empty or oversized goals, control characters and malformed UTF-16 fail closed. Valid paired UTF-16 surrogates remain accepted and distinct from the replacement character in the canonical digest.

## Agent result and handoff

Every Agent result contains:

- exact role and decision enumerations;
- the originating task digest;
- the exact previous-result digest, or zero SHA-256 only for Planning;
- a role-bound chain depth (`0` through `4`, with denied Audit at `2`);
- a bounded payload of 1–1024 characters; and
- a domain-separated SHA-256 result digest.

Each handoff is the preceding result itself. Before accepting it, the next Agent recomputes the preceding result digest from all canonical fields and validates the exact previous role, decision, task digest, chain depth and previous-result link. Planning must use the all-zero previous-result digest. Operations and later roles receive enough prior results to verify the complete prefix back to that zero root. Role bypass, forged links, payload or digest tampering, out-of-order execution and cross-task handoff fail closed.

Every Agent receiving a task recomputes the task digest from its current schema, trace identifier and goal. Every downstream role also replays the complete deterministic semantic prefix: Planning payload, Guard policy decision and payload, Operations `MUTATION=NONE` payload, Verification payload and Audit outcome payload must exactly match the values derived from the verified task and preceding results. A structurally valid rehashed payload is insufficient.

This SHA-256 model establishes deterministic integrity and semantic equivalence inside the offline single-process slice. It does not authenticate which principal produced a result and is not a security boundary against hostile code already executing in the same process. Cross-service hostile-principal handoff requires a separately reviewed MAC or digital-signature design.

## Deterministic mock

The mock model returns only a role-bound SHA-256-derived token. It uses no clock, randomness, environment variable, filesystem, network, process, registry or external state. Identical canonical input must produce identical canonical output.

All five roles receive the same enabled `IModelProvider` instance. The deterministic mock guarantees remain unchanged. A local provider may return nondeterministic model content, but semantic replay within one intake request must use its two-entry successful-result cache, so repeated Planning and Operations checks reuse exact validated strings without extra model calls. Cross-request byte identity is not claimed for the local provider. Policy continues to reject disabled or external providers.

## Prohibited terms

Guard denies goals containing these case-insensitive tokens:

```text
NETWORK
WRITE
IPC
CHILD_PROCESS
SHELL
CREDENTIAL
SECRET
```

This initial list is intentionally conservative and is not a general production policy language.

## Acceptance

- Positive flow contains all five roles in exact order.
- Denial flow omits Operations and Verification and ends with a non-persisted Audit candidate.
- Two mock executions of the same task are byte-identical in canonical JSON form.
- One local-provider request replays Planning and Operations semantics from its bounded request-local cache; cross-request model output identity is not required.
- Unknown schemas, malformed trace IDs, control characters, unpaired UTF-16 surrogates, role bypass and task-digest mismatch fail closed.
- Forged previous digests, modified payloads, modified result digests and forged Operations-to-Verification handoffs fail closed.
- Post-Guard task mutation, a correctly linked but policy-invalid Guard Allow, and an Operations payload modified then rehashed fail closed through task recomputation and deterministic semantic replay.
- Static source and compiled-metadata checks find no network, IPC, file-write, registry-write, runtime child-process, shell, dynamic-load or native-import implementation in the functional core, non-CLI harnesses or service outputs. The task-intake CLI alone may contain the frozen loopback HTTP/stream metadata allowlist defined by `EAIRA_LOCAL_MODEL_PROVIDER_V1`.
- Release builds require the exact compiler SHA-256 and Microsoft Authenticode identity bound by the release profile.
- The deterministic clean-build pipeline remains required for all five service executables.
