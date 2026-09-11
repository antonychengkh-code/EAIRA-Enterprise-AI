# EAIRA M5 Integrated Local Runtime and Operator Workflow Project Charter

## 1. Charter Control

| Field | Value |
| --- | --- |
| Milestone | `M5_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW` |
| Charter version | `0.1.0` |
| Date | 2026-09-12 |
| State | `AUTHORIZED_CHARTER_CANDIDATE_PENDING_INDEPENDENT_REVIEW` |
| Project Owner selection | `M5_A_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW` |
| Baseline | `023592cd62b1cd2f1efa94ab66f43817b43e07d3` |

## 2. Objective

Convert the independently published M4 capabilities into one coherent,
least-authority, user-mode local product workflow that a human operator can
invoke through one canonical entry point, without yet activating privileged
Windows services, persistence, external credentials, signing or customer
deployment.

## 3. Starting Assets

M5 starts from the published M4 capabilities:

- deterministic Planning, Guard, Operations, Verification and Audit flow;
- strict local task-intake contract and canonical result channels;
- deterministic mock provider and exact Ollama loopback provider for
  `qwen3:4b`;
- exact four-file controlled project-context projection;
- exact seven-file project-memory knowledge query;
- bounded local project QA with host-validated citations and explicit
  non-authority classifications;
- five service-host scaffolds and offline self-tests; and
- reproducible unsigned-release verification and abuse-case controls.

## 4. Milestone Scope

M5 may plan, design and, only under later separate authorizations, implement:

1. one canonical user-mode local entry point;
2. explicit request routing among the already published capabilities;
3. one end-to-end ownership model across all five Agent roles;
4. canonical, versioned request, result, error and provenance envelopes;
5. fail-closed Guard enforcement before data acquisition or provider activity;
6. deterministic mock and offline integration evidence;
7. bounded loopback-only model execution using the existing provider contract;
8. operator-visible lifecycle and health outcomes without raw sensitive data;
9. an exact threat model and abuse matrix for cross-capability composition; and
10. later separately gated transport, persistence, service and packaging slices.

## 5. M5 Slice 1 Boundary

The first slice is `M5_SLICE1_UNIFIED_USER_MODE_ORCHESTRATOR`.

Its planning package must define:

- exact user stories and command surface;
- exact capability-routing table;
- five-Agent ownership and Guard call graph;
- exact input, output, error and provenance schemas;
- source and data-flow allowlists;
- prompt-injection, confused-deputy, authorization-bypass, data-exposure,
  replay, routing and output-isolation threats;
- deterministic offline acceptance and abuse cases;
- changed-path manifest; and
- explicit evidence, staging and publication gates.

Slice 1 planning must begin from user mode and must not require Windows service,
IPC, account, group, membership, directory, ACL, certificate or signing changes.

## 6. Non-Goals for Initial M5 Scope

- arbitrary repository or vault access;
- runtime repository writes or automatic status/memory updates;
- external/cloud provider activation or credential storage;
- Windows service installation or service-to-service IPC;
- persistence, databases, telemetry or remote support collection;
- customer installer, auto-update, signed distribution or production rollout;
- Annex Field or blocker closure; and
- changing Human Project Owner or Guard authority.

## 7. Safety Invariants

- Denied work performs no project read and no provider construction.
- Repository text and model output are untrusted data and never authority.
- Capability routing cannot widen a source allowlist, provider selection or
  output channel.
- The Guard decision is deterministic and cannot depend on context, knowledge,
  provider output or Planning text.
- No raw root, absolute path, file content, prompt, provider body, credential or
  native diagnostic crosses a bounded public output.
- Runtime writes, IPC, listeners, shell and child processes remain prohibited
  unless a later exact slice changes the relevant invariant.
- Every widening change stops for separate Project Owner authorization and
  independent review.

## 8. Milestone Success Criteria

M5 is eligible for closeout only when separately authorized slices establish:

1. one independently verified integrated local operator workflow;
2. preserved five-Agent ownership and fail-closed Guard behavior;
3. deterministic mock end-to-end reproduction and bounded local-provider
   evidence;
4. complete cross-capability abuse coverage and output isolation;
5. explicit operational boundaries for any introduced transport or persistence;
6. customer packaging readiness only if its prerequisites are separately met;
   and
7. independently verified publication and controlled-state synchronization.

M5 completion does not automatically establish production readiness. Any
customer release still depends on the separate signing, Windows-security,
operations and Annex gates.

## 9. Risks

- combining currently separate surfaces may create confused-deputy or Guard
  bypass paths;
- context, knowledge and QA composition may expose raw or instruction-shaped
  content across role boundaries;
- local provider identity is not cryptographically attested;
- future IPC or persistence would add privileged identity, replay, retention,
  encryption and recovery risks; and
- packaging too early may freeze unstable interfaces and create signing cost.

## 10. Gate Model

Each M5 slice follows:

`SCOPE_DECISION -> READINESS_PACKAGE -> INDEPENDENT_SCOPE_REVIEW -> EXACT_DESIGN -> INDEPENDENT_DESIGN_REVIEW -> IMPLEMENTATION_AUTHORIZATION -> SEALED_EVIDENCE -> INDEPENDENT_IMPLEMENTATION_REVIEW -> EXACT_STAGING -> STAGED_REVIEW -> COMMIT -> POST_COMMIT_VERIFICATION -> NORMAL_PUSH -> POST_PUSH_VERIFICATION -> CONTROLLED_STATE_SYNCHRONIZATION`

Remediation gates are inserted when required. No later gate is inferred from an
earlier one.

## 11. Current Charter State

`M5_CHARTER_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW_NO_IMPLEMENTATION_AUTHORITY`

The next eligible gate is:

`SEPARATE_INDEPENDENT_EAIRA_M4_CLOSEOUT_AND_M5_CHARTER_PACKAGE_REVIEW`
