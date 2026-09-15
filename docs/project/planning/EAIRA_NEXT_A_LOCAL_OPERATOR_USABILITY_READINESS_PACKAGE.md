# EAIRA NEXT_A Local Operator Usability Readiness Package

## Package control

- Package ID: `EAIRA_NEXT_A_LOCAL_OPERATOR_USABILITY_READINESS_V1`
- Date: 2026-09-15
- State: `M5_CLOSEOUT_NEXT_A_DOCUMENTARY_PACKAGE_PREPARED_FOR_INDEPENDENT_REVIEW`
- Scope: `NEXT_A_BOUNDED_LOCAL_OPERATOR_USABILITY_AND_ACCEPTANCE`
- M5 closeout: `M5_CLOSEOUT_A_BOUNDED_USER_MODE_WITH_EXPLICIT_CARRY_FORWARD`
- Independent package review: separate evidence required; no result inferred here.
- Implementation readiness: `NOT_READY_PENDING_EXACT_DESIGN_AND_AUTHORIZATION`
- Baseline: `7ff305ad4751211b7a82f98819cdb24f7e0a7aae`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_CLOSEOUT_AND_NEXT_A_SCOPE_READINESS_PACKAGE_REVIEW`

This is scope-level readiness planning, not an implementation specification.
The earlier R1 proposal PASS establishes only its reviewed proposal semantics.

## Exact current documentary manifest

Exactly ten repository paths may change in this preparation. A=new, M=modified.
No product path is in this mutation ceiling.

| Action | Path |
| --- | --- |
| A | `docs/project/strategy/EAIRA_M5_BOUNDED_CLOSEOUT_DECISION.md` |
| A | `docs/project/strategy/EAIRA_NEXT_A_LOCAL_OPERATOR_USABILITY_SCOPE_DECISION.md` |
| A | `docs/project/planning/EAIRA_NEXT_A_LOCAL_OPERATOR_USABILITY_READINESS_PACKAGE.md` |
| M | `docs/project/status/CURRENT_STATUS.md` |
| M | `docs/project/status/TODAY_OBJECTIVE.md` |
| M | `docs/project/status/ACTIVE_TASK.yaml` |
| M | `docs/project/status/AGENT_CONTEXT_VERSION.yaml` |
| M | `docs/project/context/CURRENT_CONTEXT.md` |
| M | `docs/project/memory/HANDOFF.md` |
| M | `docs/project/memory/DECISION_INDEX.md` |

The seven modified files consist of six controlled status/context/HANDOFF files
and a navigation-only decision index. Existing milestones/charters, previous
decisions, product source, build scripts and release profiles remain unchanged.
Future implementation path count/manifest is UNSELECTED, not this ten-path list.

## Read-only planning-source allowlist

In addition to the ten current documentary paths above, planning may inspect only
the following supporting repository paths (no recursive vault content discovery):

- `AGENTS.md`
- `docs/project/status/README.md`
- `docs/specifications/EAIRA_CONTEXT_CONTRACT_V1.md`
- `docs/project/memory/README.md`
- `docs/project/memory/MEMORY_SCHEMA.md`
- `docs/project/memory/MEMORY_INBOX.md`
- `docs/project/memory/OPEN_QUESTIONS.md`
- `docs/project/memory/DISCOVERY_INDEX.md`
- `docs/project/memory/PROCEDURE_INDEX.md`
- `docs/project/memory/STABILITY_CHECKLIST.md`
- `.agents/skills/obsidian-project-memory/SKILL.md`
- `.agents/skills/obsidian-project-memory/scripts/validate_memory.py`
- `docs/project/milestones/EAIRA_M5_INTEGRATED_LOCAL_RUNTIME_AND_OPERATOR_WORKFLOW_PROJECT_CHARTER.md`
- `docs/project/strategy/EAIRA_M4_CLOSEOUT_AND_M5_SCOPE_DECISION.md`
- `docs/project/strategy/EAIRA_M5_SLICE1_SCOPE_DECISION.md`
- `docs/project/strategy/EAIRA_M5_SLICE2_SCOPE_DECISION.md`
- `docs/project/strategy/EAIRA_M5_SLICE3_SCOPE_DECISION.md`
- `docs/project/strategy/EAIRA_M5_SLICE4_SCOPE_DECISION.md`
- `docs/project/strategy/EAIRA_M5_SLICE5_SCOPE_DECISION.md`
- `apps/agent-services/contracts/EAIRA_LOCAL_OPERATOR_V1.md`
- `apps/agent-services/contracts/EAIRA_UNSIGNED_CUSTOMER_PACKAGE_V1.md`
- `apps/agent-services/src/LocalOperator.cs`
- `apps/agent-services/src/ModelProviders.cs`

Exact local-only proposal/review paths in the closeout decision may be read/hash
checked for provenance, plus
`C:/Users/User/EAIRA_M5S5_STATE_SYNC_INDEPENDENT_POST_PUSH_REPORT_20260915.md`.
Git status/index/diff/HEAD and the six exact publication commits in the closeout
record may be checked read-only. Additional source dependencies must be proposed
explicitly before further scope-specific reads; path discovery is not read authority.

The memory validator reads the sixteen required files it names and checks link
existence. This documentary validation is distinct from future runtime, whose
project/vault content-source allowlist is empty.
Excluded contents remain `docs/integrations/`, `scripts/claude_api.py`,
root `tests/`, `.obsidian/`, and `docs/.tmp.driveupload`.

## Output and mutation boundary

This preparation writes only the ten text paths above and sanitized
repository-external review/validation reports under `C:/Users/User` with an
`EAIRA_M5_CLOSEOUT_NEXT_A_` prefix. No arbitrary directory creation, runtime
output, builds, release artifacts, raw environment data, SID or secrets.
The existing external R1 proposal/review are immutable inputs for this package.

At future runtime, output is memory-only presentation of bounded sanitized plan,
result, denial and error semantics. Numeric schemas/byte budgets require exact
design. No filesystem/network/persistence authority flows from documentary writes.

## Threat model and required evidence

| ID | Threat | Required control and future evidence |
| --- | --- | --- |
| T01 | Prompt/instruction injection | Treat human/model/instruction-shaped text as data; no shell/tools/new routes; malicious-text cases cannot change policy |
| T02 | Plan or trace used as permission | PLAN_NOT_AUTHORITY; explicit human submit creates fresh request; existing Guard before factories; forged/stale-plan tests |
| T03 | Provider construction before authority | Plan/cancel/malformed/DENY zero task adapters/providers; factory/call counters and call-graph/metadata evidence |
| T04 | Hidden live provider or data access | Exact mock only after ALLOW; zero other providers/network/project reads/persistence on every branch; negative selection/reference tests |
| T05 | Output or diagnostic leakage | Closed presentation mapped to existing public semantics; injection/echo/error/oversize specimens; raw prompt/path/provider body excluded |
| T06 | UI acts as confused deputy | Preserve request/role ownership and existing Guard; no UI-derived authority; deny/conflicting-field tests |
| T07 | Edited plan or repeated submission | Bind confirmed request and invalidate edited plans; single-request duplicate-submit/cancel/failure tests; no cross-process replay claim |
| T08 | Unicode/size/schema ambiguity | Exact inherited limits/encoding and canonical mapping defined before code; malformed/oversized/control/Unicode cases fail closed |
| T09 | Wrapper escapes in-process boundary | No shell/child process/dynamic load/listener or new dependencies without decision; source/metadata and abuse evidence |
| T10 | False completion/usability claims | Distinguish simulated mock result from real project work; human evaluator observes plan/cancel/submit/deny/result scenarios |
| T11 | Stale product evidence after doc edits | Preserve sealed historical inputs; future code/baseline changes need separately authorized clean A/B and independent review; no automatic rebaseline |
| T12 | Carry-forward lost during closeout | Link CF-01..CF-09; reactivate applicable prerequisites on any future widening; no production inference |

No live model, runtime or abuse specimens are executed by this preparation.

## Readiness ledger

| Item | Current disposition | Required before implementation |
| --- | --- | --- |
| Owner direction and bounded M5 closeout | Explicitly selected; this package records the decision | Independent review of this new ten-path record |
| R1 provider contradiction | Closed by independent proposal review | Preserve phase-dependent rules in exact design |
| UI form / framework / dependencies | UNSELECTED | Owner selection; no incompatible architecture silently introduced |
| Exact input/output contract | Existing semantics retained, presentation not designed | Exact grammar, bounds, encoding, trace handling, display/error maps |
| Confirmation/state machine | Required, not implemented | Request binding, duplicate-submit/cancel/failure rules and acceptance vectors |
| Exact code manifest / evidence roots | UNSELECTED | Enumerated product paths, out-of-tree test roots, build/evidence authority |
| Human acceptance protocol | Human Owner proposed; no session performed | Named scenarios, observable pass/fail and sanitized evidence handling |
| Implementation and tests | NOT_AUTHORIZED / NOT_RUN | Independent exact-design review then explicit implementation authority |
| Staging / commit / push | NOT_AUTHORIZED | Exact separate authorization and independent lifecycle checks |
| Services/signing/Annex/production | UNRESOLVED_OR_OUT_OF_SCOPE | Separate relevant future prerequisites; not waived by this package |

Scope review can pass while these later implementation items remain open; it must
not report implementation readiness or execute them.

## Documentary validation and Gate sequence

For this package only: verify the exact ten-path set, empty index, unchanged HEAD,
no excluded changes, YAML syntax/duplicate keys, required headings/version
cross-links, consistent M5/NEXT_A state and provider boundary, Markdown/wikilink
existence, and whitespace. Run the existing read-only project-memory validator.
Record physical per-path SHA-256 in an external independent report, not a
self-referential in-file digest.

Next: independent ten-path package review. Any material finding requires a bounded
remediation decision and repeat independent review. Passing review grants no new
permission. Later exact staging -> independent staged review -> authorized commit
-> independent post-commit -> authorized normal push -> independent post-push
remain separate gates. No force push. Only after scope/design prerequisites and
separate implementation authority may product work begin.
No fixed total gate count or test count is asserted before exact design.

Documentary preparation and read-only validation only. No product implementation, runtime execution, model/provider call, arbitrary project/vault read, Windows/service/IPC/account/group/membership/directory/ACL/certificate/signing change, external provider, credential, checkpoint-ref repair, scheduling or external synchronization. Staging, commit and push require separate authorization.
