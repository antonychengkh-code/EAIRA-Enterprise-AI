# EAIRA M5 Slice 2 Scope Decision

## Decision control

- Decision ID: `EAIRA_M5_SLICE2_SCOPE_DECISION_V1`
- Date: `2026-09-12`
- Project Owner selection: `M5S2_A_BOUNDED_OPERATOR_HEALTH_AND_CAPABILITY_STATUS`
- Baseline: `b32e947892b6b0ffd97411910f704394b6b805f2`
- Decision state: `SELECTED_FOR_SCOPE_PACKAGE_AND_INDEPENDENT_REVIEW`
- Lifecycle authority: complete the bounded Slice 2 Gate sequence, including independently reviewed implementation, evidence, staging, normal commit, normal fast-forward push, controlled-state synchronization and final verification
- Force-push authority: `NOT_GRANTED`
- Next Gate: `SEPARATE_EVIDENCE_DRIVEN_EAIRA_M5_SLICE2_SCOPE_PACKAGE_PREPARATION`

## Selected outcome

Add one deterministic `health` route to the published user-mode local operator.
The route reports only compiled contract and policy posture. It does not claim
that Ollama, a model, a repository root, a Windows service, a credential, a
network endpoint or an external dependency is currently available or healthy.

The selected command is:

```text
EAIRA.LocalOperator.Cli.exe health --trace <TRACE>
```

The successful result is one canonical `EAIRA_OPERATOR_HEALTH_V1` object inside
the existing `EAIRA_LOCAL_OPERATOR_V1` wrapper. Its observation scope is
`COMPILED_CONTRACT_ONLY`; its authority is `OBSERVATIONAL_NOT_AUTHORITY`.

## Mandatory invariants

- Static Guard runs before health-result construction.
- The route creates no task, knowledge or project-QA adapter.
- The route performs no file, repository, vault, environment, registry, process,
  service, IPC, network, model, clock or randomness access.
- Output is fixed-schema, bounded, canonical UTF-8 and deterministic.
- Existing `task`, `knowledge` and `project-qa` commands and outputs remain
  byte-compatible.
- A static compiled-policy result must not be represented as live dependency or
  operational readiness.

## Non-authority boundary

This selection grants no arbitrary path access, dynamic discovery, provider
probe, credential use, runtime write, logging, persistence, IPC, listener,
Windows/service/account/group/ACL change, signing, deployment, production
activation, Annex Field transition, checkpoint-ref repair or force push.
Independent review must fail closed on any widening beyond the exact health
route.
