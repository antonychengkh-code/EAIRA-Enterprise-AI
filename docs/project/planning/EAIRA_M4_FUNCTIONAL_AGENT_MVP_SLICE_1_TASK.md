# EAIRA M4 Functional Agent MVP Slice 1 Task

## Task

Implement and verify the first locally invocable EAIRA Agent MVP slice.

## Objective

Provide deterministic local task intake with provider-neutral selection while keeping all external and mutating behavior disabled.

## Inputs

- M4 authorization decision and Charter.
- Existing R3 five-Agent functional slice.
- Gate 25 deterministic unsigned-build pipeline.

## Scope

- Add the local task-intake and provider contracts.
- Implement `mock` and fail-closed `real` selections.
- Produce canonical no-write CLI responses.
- Extend clean-build and offline verification evidence.
- Synchronize controlled status after verification.

## Rules

- Exact argument allowlist only.
- No implicit provider or environment configuration.
- No network, credentials, persistence, IPC listener, shell or child process.
- No Windows mutation, signing, commit or push.

## Non-Goals

- Real provider calls.
- Long-running service intake.
- Persistent audit records.
- Production deployment.

## Required Content

- Source, tests, contract, build evidence and state synchronization.

## Acceptance

- All M4 Charter Slice 1 success criteria pass.

## Final Decision

Decision: `ACTIVE_IMPLEMENTATION_TASK`.
