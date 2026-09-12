# EAIRA M5 Slice 2 Bounded Operator Health and Capability Status Scope Package

## 1. Control

| Field | Value |
| --- | --- |
| Package ID | `EAIRA_M5_SLICE2_SCOPE_PACKAGE_V1R1` |
| Date | `2026-09-12` |
| Baseline | `b32e947892b6b0ffd97411910f704394b6b805f2` |
| Selection | `M5S2_A_BOUNDED_OPERATOR_HEALTH_AND_CAPABILITY_STATUS` |
| State | `R1_LIVE_OBSERVATION_AND_CANONICAL_VECTOR_REMEDIATION_READY_FOR_INDEPENDENT_REVIEW` |
| Implementation authority | `AUTHORIZED_ONLY_AFTER_SCOPE_AND_EXACT_DESIGN_REVIEWS_PASS` |
| Next Gate | `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE2_SCOPE_PACKAGE_R1_REVIEW` |

## 2. User outcome

A human operator can ask the existing local operator which capabilities and
safety posture are compiled into that executable without reading project data,
constructing a provider or probing the machine.

Exact command:

```text
EAIRA.LocalOperator.Cli.exe health --trace <TRACE>
```

No other health alias, flag, positional value, response file, stdin input,
configuration source or environment expansion is accepted.

## 3. Semantic boundary

`health` means compiled-contract posture only. It is not a liveness, readiness,
availability, installation, network, model, service, signing or production
claim. The exact observation scope is `COMPILED_CONTRACT_ONLY` and the exact
authority is `OBSERVATIONAL_NOT_AUTHORITY`.

The fixed successful payload contract is `EAIRA_OPERATOR_HEALTH_V1` and exposes:

1. schema;
2. status `POLICY_READY`;
3. observation scope;
4. local-operator wrapper schema;
5. the ordered compiled capability names `TASK`, `KNOWLEDGE`, `PROJECT_QA`,
   `HEALTH`;
6. Guard posture `REQUIRED_BEFORE_EFFECT`;
7. network `NONE`;
8. reads `NONE`;
9. writes `NONE`;
10. provider construction `NONE`; and
11. authority `OBSERVATIONAL_NOT_AUTHORITY`.

No timestamp, host identity, path, model identity, provider state, version from
the environment, native diagnostic or free-form text is emitted.

The request uses exact internal intent `COMPILED CONTRACT STATUS`, input kind
`HEALTH`, provider/model/root values `NONE`, and the existing Slice 1 request,
route, payload and orchestration digest domains. The health route policy is
`EAIRA_STATIC_OPERATOR_HEALTH_V1`; its exact call budget is
`MODEL_COMPLETE=0;READS=0;TAGS=0;CHAT=0;FACTORIES=0`.

The canonical payload is exactly 366 UTF-8 bytes:

```json
{"schema":"EAIRA_OPERATOR_HEALTH_V1","status":"POLICY_READY","observationScope":"COMPILED_CONTRACT_ONLY","operatorSchema":"EAIRA_LOCAL_OPERATOR_V1","capabilities":["TASK","KNOWLEDGE","PROJECT_QA","HEALTH"],"guardPosture":"REQUIRED_BEFORE_EFFECT","network":"NONE","reads":"NONE","writes":"NONE","providerConstruction":"NONE","authority":"OBSERVATIONAL_NOT_AUTHORITY"}
```

Its `EAIRA_M5_SLICE1_PAYLOAD_V1` framed SHA-256 is
`9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181`.
For trace `0123456789ABCDEF0123456789ABCDEF`, the exact request, route and
final Audit chain SHA-256 values are respectively
`0E10A550738D8618EFB0C845E4E1C6357F11C64258BE78993E64791DC0456990`,
`613DCE7408D3B68CD51A2E1C01A51A0BA20E20A84B2BE20438319D102446B429`
and `228427F0DFB1B1592AC7912F68F94E183C741D2C62A58B7939FC02226534DE5F`.
The complete canonical wrapper is exactly 927 UTF-8 bytes including LF:

```json
{"schema":"EAIRA_LOCAL_OPERATOR_V1","status":"PASS","traceId":"0123456789ABCDEF0123456789ABCDEF","capability":"HEALTH","network":"NONE","writes":"NONE","authority":"OBSERVATIONAL_NOT_AUTHORITY","requestSha256":"0E10A550738D8618EFB0C845E4E1C6357F11C64258BE78993E64791DC0456990","routeSha256":"613DCE7408D3B68CD51A2E1C01A51A0BA20E20A84B2BE20438319D102446B429","payloadSha256":"9E3EFCDB24B49E2C27254772DFF72DEF88968ECF0A76C60D4E6724AE90E2E181","payload":{"schema":"EAIRA_OPERATOR_HEALTH_V1","status":"POLICY_READY","observationScope":"COMPILED_CONTRACT_ONLY","operatorSchema":"EAIRA_LOCAL_OPERATOR_V1","capabilities":["TASK","KNOWLEDGE","PROJECT_QA","HEALTH"],"guardPosture":"REQUIRED_BEFORE_EFFECT","network":"NONE","reads":"NONE","writes":"NONE","providerConstruction":"NONE","authority":"OBSERVATIONAL_NOT_AUTHORITY"},"audit":{"outcome":"PASS","chainSha256":"228427F0DFB1B1592AC7912F68F94E183C741D2C62A58B7939FC02226534DE5F"}}
```

## 4. Routing and ownership

1. Parser validates exact command shape and existing 32-uppercase-hex trace.
2. Planning creates the existing integrity-bound task/request envelope using a
   fixed internal health intent, never user-provided content.
3. Static Guard evaluates before any observable effect.
4. On deny: Planning -> Guard(DENY) -> Audit; output is the existing sanitized
   `DENIED`/77 wrapper and no health payload is constructed.
5. On allow: Planning -> Guard(ALLOW) -> Operations constructs fixed constants;
   Verification validates exact bytes and invariants; Audit binds the final
   digest.
6. No `ILocalOperatorAdapterFactory` method is called for this route.

## 5. Data-flow allowlist

Allowed inputs:

- literal command tokens `health`, `--trace`;
- one trace satisfying the existing validation rule; and
- compile-time constants required by the fixed request, route and health payload.

Allowed outputs:

- exactly one existing operator wrapper line on stdout;
- empty stderr; and
- process exit `0`, `64`, `77`, `83` or `84` according to existing parse,
  orchestration and output-isolation behavior.

All filesystem, repository, vault, `.obsidian`, environment, registry, network,
provider, model, process enumeration, child process, shell, clock, randomness,
IPC, service-control and persistence sources are denied.

## 6. Threat model and required controls

| Threat | Required fail-closed control |
| --- | --- |
| Static status mistaken for live health | Exact `COMPILED_CONTRACT_ONLY` scope and no live-health wording |
| Guard bypass | Guard decision precedes payload construction; denial has zero factory calls |
| Provider or reader construction | Health path has zero adapter-factory calls and tests poison every factory method |
| Environment/path disclosure | No runtime source API and fixed byte-exact golden output |
| Capability-list drift | Ordered four-value list is exact-profile bound |
| Schema/output injection | No user text enters payload; strict canonical object and wrapper validation |
| Route confusion | Unique `HEALTH` capability and route digest; reordered/extra flags rejected |
| Legacy regression | All existing 96 Slice 1 cases and M4 suites remain mandatory |
| Metadata bypass | Existing source, PE metadata, P/Invoke and native allowlists remain mandatory |
| False production claim | Fixed observational authority and explicit unsigned/non-production boundary |

## 7. Acceptance matrix

The exact design must define stable names and fixed vectors for at least:

- valid health success with exact canonical payload and wrapper;
- identical complete argv and trace produce a byte-identical full line;
- different valid traces retain identical payload bytes and payload digest, while
  request, route, Audit chain digests and the complete wrapper must differ;
- trace remains correlation only, never authorization or a nonce;
- malformed, lowercase, short, long and non-hex traces;
- missing, duplicate, reordered and extra flags/arguments;
- response-file and command-looking payload rejection;
- Guard denial with zero payload/factory activity;
- poison task/knowledge/project-QA factories never called;
- byte-exact schema/member order, capability order, authority and posture;
- output tamper, payload-digest tamper and route-digest mismatch rejection;
- no filesystem, environment, network, provider, clock, randomness, IPC, process
  or native surface introduced by the health implementation;
- all existing Slice 1 and M4 regression suites; and
- clean A/B reproducibility and complete release-profile binding.

## 8. Provisional changed-path ceiling

Exact design may select only from this ceiling:

1. `apps/agent-services/README.md`
2. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`
3. `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
4. `apps/agent-services/release/gate25-unsigned-release-profile.json`
5. `apps/agent-services/src/LocalOperator.cs`
6. `apps/agent-services/tests/LocalOperatorHarness.cs`
7. `docs/project/planning/EAIRA_M5_SLICE2_BOUNDED_OPERATOR_HEALTH_AND_CAPABILITY_STATUS_SCOPE_PACKAGE.md`
8. `docs/project/planning/EAIRA_M5_SLICE2_EXACT_IMPLEMENTATION_DESIGN.md`
9. `docs/project/strategy/EAIRA_M5_SLICE2_SCOPE_DECISION.md`

`AgentCore.cs`, `LocalOperatorHost.cs`, all other product sources, root `tests/`,
`docs/integrations/`, `scripts/claude_api.py` and `.obsidian/` are excluded unless
a later independent finding proves a minimum required addition and the Project
Owner's existing lifecycle authority is applied through an explicit remediation
record and new independent review.

## 9. Evidence and lifecycle

Required evidence:

- exact design and changed-path manifest;
- two isolated clean byte-identical builds;
- existing 96-case Slice 1 harness plus exact new health cases;
- all retained M4 functional, intake, context, knowledge, project-QA, provider,
  transport and abuse checks;
- metadata/PInvoke/native/output-isolation verification;
- sanitized out-of-tree final manifest with all discovery flags false; and
- independent scope, design, implementation, staged, post-commit, post-push and
  controlled-state reviews.

No live provider call or provider observation is required or permitted for this
static route. The native validation Gate executes only the actual candidate
executable with `health --trace ...` and no project root. Evidence of zero
adapter/provider/network reachability comes from poison factory counters,
control-flow/IL call-graph checks, P/Invoke/member-reference deny lists and a
process-scoped connect-attempt monitor. The verifier must not query Ollama, read
Ollama state or logs, probe its endpoint, or claim that Ollama exists, is absent,
available or healthy.

## 10. R1 remediation traceability

The first independent scope review returned `CANNOT_CLOSE`, `P0=0`, `P1=1`,
`P2=2`. R1 removes the undefined Ollama request-count observation, fixes the
complete canonical payload/member order and golden vectors, and defines exact
same-trace versus cross-trace replay behavior. No product authority or source
ceiling is widened.

## 11. Gate rule

Any independent P0 or P1 finding blocks progression. Remediation must be exact,
bounded and independently re-reviewed. P2 may proceed only when explicitly shown
not to weaken safety, evidence or publication integrity. Normal fast-forward push
only; force push is prohibited.
