# EAIRA M5 Slice 3 Scope Decision

## Decision control

- Decision ID: `EAIRA_M5_SLICE3_SCOPE_DECISION_V1R4`
- Date: `2026-09-13`
- Project Owner selection: `M5S3_A_BOUNDED_OPERATOR_PREFLIGHT_AND_ROUTE_EXPLANATION`
- Baseline: `0be3bb95447a45c60ab4cc950a44950b784b086e`
- Decision state: `R4_EXACT_DESIGN_REMEDIATION_AUTHORIZED`
- Guard remediation: `GUARD_PRESERVING_FIXED_PREFLIGHT_INTENT`
- Exact-design authority: `GRANTED`
- Implementation authority: `NOT_GRANTED`
- Repository-recording authority: `NOT_GRANTED`
- Force-push authority: `NOT_GRANTED`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE3_A_EXACT_IMPLEMENTATION_DESIGN_R4_REVIEW`

## Selected outcome

Add one deterministic preflight route to the published user-mode Local Operator.
It explains only the compiled policy for one exact existing route ID. It does not
accept or replay the existing command's goal, query, question, root or other
runtime values, and it does not execute the selected route.

Provisional command shape for exact-design review:

```text
EAIRA.LocalOperator.Cli.exe preflight --trace <TRACE> --route <ROUTE_ID>
```

The seven provisional route IDs are:

1. `TASK_MOCK`
2. `TASK_MOCK_CONTEXT`
3. `TASK_OLLAMA_LOCAL`
4. `TASK_OLLAMA_LOCAL_CONTEXT`
5. `KNOWLEDGE`
6. `PROJECT_QA_OLLAMA_LOCAL`
7. `HEALTH`

A successful response explains only the route's capability, required Guard
posture, source class, provider policy, network policy, write policy and
authority classification. It is static compiled-contract information, not a
Guard decision or permission grant for the described route, liveness result,
environment probe or promise that the route will succeed. The static Guard
decision authorizes only production
of this bounded preflight explanation; it never authorizes the described route.

## Mandatory invariants

- Preflight performs parsing, a fixed preflight-envelope Guard check and
  fixed-table lookup only.
- Preflight never invokes the selected route or any capability adapter.
- Preflight creates or executes no Task capability adapter/intake, context,
  knowledge, QA, Health or provider object. It does create the mandatory fixed
  `TaskEnvelope` used only by the preflight Guard check.
- A valid preflight request creates one fixed, integrity-bound preflight envelope
  containing no user-supplied goal, query, question or root; it contains only the
  fixed internal intent `EXPLAIN COMPILED ROUTE POLICY` and calls static Guard
  exactly once.
- Before Guard, only the generic outer preflight route needed to bind the denial
  wrapper and `routeSha256` may be constructed. On Guard deny, no seven-row
  described-route policy lookup or payload construction occurs and the existing
  sanitized denial chain is returned.
- On Guard allow, `guardEvaluation` is `ALLOW_PREFLIGHT_ONLY`; this is not an
  authorization result for the described route. The described route still must
  perform its own Guard check if later invoked separately.
- Preflight accepts no user-supplied goal, query, question, root, provider,
  model, endpoint,
  response file, stdin, environment/config expansion or arbitrary argv tail.
- Preflight performs no file, repository, vault, `.obsidian`, environment,
  registry, process, service, IPC, network, model, clock or randomness access.
- Preflight emits no raw user text, path, prompt, source, provider response,
  credential, host identity or native diagnostic.
- Existing task, knowledge, project-QA and Health command behavior remains
  byte-compatible.
- Output is bounded, canonical UTF-8 and deterministic.

## Non-authority boundary

This selection grants no feature implementation, arbitrary path access, runtime
discovery, Guard decision or authorization for the described route, provider
probe, credential use, runtime write,
logging, persistence, IPC, listener, Windows/service/account/group/ACL change,
certificate, signing, external-provider activation, deployment, production
activation, Annex transition, checkpoint-ref repair, staging, commit, push or
force push. Every later lifecycle step requires a separate Gate.
