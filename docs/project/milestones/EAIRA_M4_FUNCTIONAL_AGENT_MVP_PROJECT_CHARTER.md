# EAIRA M4 Functional Agent MVP Project Charter

## Task

Establish and govern `M4 Functional Agent MVP` as the active EAIRA product-development milestone.

## Objective

Move EAIRA from a verified offline five-Agent contract to a locally invocable, provider-neutral, no-write functional MVP while preserving fail-closed production and security boundaries.

## Inputs

- `docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_AUTHORIZATION_DECISION.md`
- `apps/agent-services/contracts/EAIRA_MINIMUM_FUNCTIONAL_AGENT_SLICE_V1.md`
- `apps/agent-services/contracts/EAIRA_LOCAL_TASK_INTAKE_V1.md`
- R3 publication commit `a10c2ae098bb26455cd9004c0c5a503545a2ef7f`
- Current controlled status and Local Readiness Authorization Annex artifacts

## Scope

M4 Slice 1 authorizes:

- exact local CLI task intake;
- provider-neutral model selection;
- deterministic mock execution;
- disabled real-provider selection with explicit `PROVIDER_BLOCKED` behavior;
- canonical JSON output to standard output;
- deterministic testing and unsigned build evidence; and
- controlled Project Layer reconciliation.

## Rules

- Default and only executable provider is `mock-v1`.
- `real-disabled-v1` must not read credentials or perform network activity.
- Runtime writes, IPC listeners, shell calls and child processes are prohibited.
- Guard denial must skip Operations and Verification.
- Existing R3 task/result integrity and deterministic semantic replay controls remain mandatory.
- Production/readiness Annex blockers remain independent and fail closed.
- No commit or push is inferred from implementation success.

## Non-Goals

- Real LLM/API integration.
- Windows service deployment.
- Cross-service IPC or authentication.
- Persistent task, result, evidence or audit storage.
- Installer, updater, telemetry or customer tenancy.
- Certificate purchase, signing or production release.
- Closure of Field 8, Field 9 or any substantive Annex blocker.

## Deliverables

- `EAIRA_LOCAL_TASK_INTAKE_V1` contract.
- Provider-neutral interface and two bounded provider implementations.
- Local CLI task-intake executable source.
- Task-intake test harness.
- Extended deterministic build manifest.
- Synchronized controlled status and working handoff.

## Success Criteria

- The CLI processes a valid mock request through all five Agents.
- Unsafe goals fail closed through Guard denial.
- `real` selection is observable but cannot execute.
- Malformed inputs return a bounded invalid-request status.
- The new CLI, both harnesses and five services are reproducible across two clean builds.
- No network, persistence, credential or Windows mutation occurs.

## Acceptance

M4 Slice 1 is complete when the verified evidence satisfies every success criterion. This does not close M4; later slices for an authorized real provider, persistence, service transport, security isolation and customer packaging require separate decisions.

## Final Decision

Decision: `M4_ACTIVE_SLICE_1_AUTHORIZED`.

Authority derives from `docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_AUTHORIZATION_DECISION.md`.
