# EAIRA NEXT_A Local Operator Usability Scope Decision

## Decision control

- Decision ID: `EAIRA_NEXT_A_LOCAL_OPERATOR_USABILITY_SCOPE_DECISION_V1`
- Date: 2026-09-15
- Decision maker: Human Project Owner
- Selection: `NEXT_A_BOUNDED_LOCAL_OPERATOR_USABILITY_AND_ACCEPTANCE`
- Decision state: `OWNER_SELECTED_DIRECTION_DOCUMENTARY_PREPARATION_ONLY`
- Package state: `M5_CLOSEOUT_NEXT_A_DOCUMENTARY_PACKAGE_PREPARED_FOR_INDEPENDENT_REVIEW`
- Baseline: `7ff305ad4751211b7a82f98819cdb24f7e0a7aae`
- Milestone designation: `NOT_ESTABLISHED`; NEXT_A is not an automatic M6.
- Implementation / execution authority: `NOT_GRANTED`
- Staging / commit / push authority: `NOT_GRANTED`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_CLOSEOUT_AND_NEXT_A_SCOPE_READINESS_PACKAGE_REVIEW`

## Selected user outcome

Prepare one bounded, single-request local human-operator flow around existing
deterministic mock tasks: enter bounded input, understand a validated-but-not-
executed plan, cancel or explicitly submit, and understand a sanitized outcome.
This first slice does not provide real repository task execution, project Q&A,
persistent memory, background autonomy or customer deployment.

The Owner selected this direction after the R1 independent proposal review.
Canonical provenance and the separate M5 closeout decision are in
`docs/project/strategy/EAIRA_M5_BOUNDED_CLOSEOUT_DECISION.md`. Selection authorizes
scope/readiness preparation, not execution of the proposed flow.

## Phase-dependent authority and data-flow boundary

| Phase | Permitted future behavior | Prohibited |
| --- | --- | --- |
| Input / plan | Validate bounded user input in memory and describe a plan; PLAN_NOT_AUTHORITY | Task execution; task adapter/provider creation or call; project/vault read; network; persistence |
| Cancel / malformed input / execution Guard DENY | Terminate with bounded sanitized outcome, no task activity | Adapter/provider creation/call, retries or bypass |
| Explicit human submit | Create a fresh execution request; run the existing execution Guard before task factory/provider | Treating trace, UI state, preflight or dry-run result as authority; reusing stale approval |
| Fresh Guard ALLOW | Only then construct and call the existing deterministic mock task adapter/provider through the existing route | Ollama, external/other providers, alternate fake execution path, project/vault reads, network, persistence |
| Result | Present sanitized existing result/error semantics and logical ownership | Raw prompt/provider body, credentials, roots, file content or exception details |

Cancellation here is pre-execution cancellation. In-flight interruption semantics
are not invented; a future design must specify submission/failure/completion
behavior without widening the selected single-request scope.
Repeated submission cannot silently trigger additional execution; exact behavior,
state binding and tests must be settled in the independent exact-design gate.
No cross-process replay prevention is claimed.

## Input and output allowlist

Future runtime input is only explicit human-entered bounded mock task input and
explicit plan/cancel/submit actions in one request-local interaction. Values must
satisfy the existing mock task contract; numeric limits, encoding/Unicode rules,
action mapping and any trace handling must be copied from verified existing
contracts into the later exact design, not guessed here.

No project/context root, path selector, file picker, provider selector, endpoint,
URL, credentials, uploaded file or clipboard/file auto-import is allowed.
Instruction-shaped input is untrusted task data, never permission or code.

Future runtime output is only an in-memory sanitized plan/result/refusal/error
presentation using the existing public semantics. No file export, logs,
telemetry, saved history, database, credentials or persistent settings.
Raw prompts/provider bodies must not be added to output by a UI wrapper.
Exact display schema and byte budgets are future design prerequisites.

## Composition constraints

- In-process only. No shell, child process, dynamic loading or HTTP listener.
- Preserve the existing public CLI grammar, output schema, Guard and checks.
  A required contract change stops for separate exact authorization.
- Retain existing role sequence; UI cannot emulate successful execution itself.
- No arbitrary tool, filesystem capability, new provider or new data source.
- Planning must not construct execution adapters/providers; actual execution
  must pass a fresh existing Guard before factories/providers.
- Changing input after plan invalidates that plan for submission; the design
  must bind the submitted request to what the human confirmed and revalidate it.
- UI form/framework/dependencies are `UNSELECTED`. This scope does not authorize
  a GUI framework or select a console/TUI/desktop architecture.
- Exact implementation design, product changed-path manifest and approved
  evidence roots do not yet exist.

## Planning sources versus runtime sources

Repository documents/code may be inspected read-only for the authorized package
through the exact planning-source list in `docs/project/planning/EAIRA_NEXT_A_LOCAL_OPERATOR_USABILITY_READINESS_PACKAGE.md`.
That development-time access is not runtime authorization: future mock runtime
has zero project/vault content sources. Historical product source allowlists
are not inherited as permission by the new UI flow.

## Required future acceptance

1. A human distinguishes plan, cancellation, submission and completed result.
2. Plan/cancel/invalid/DENY construct and call zero task adapters/providers.
3. One explicit submit, fresh Guard ALLOW and only existing deterministic mock
   routing produce the bounded result and correct five-role sequence.
4. Prompt-injection, forged plan/trace, edited request, repeated submit and
   malformed/oversized/Unicode input do not widen execution or output.
5. Zero project/vault reads, network and persistent writes across every phase.
6. No raw input/provider body/path/credential/exception crosses the output.
7. Existing M4/M5 safety checks and public contracts remain intact.
8. Human Project Owner is the proposed acceptance evaluator; concrete scenarios,
   observable success criteria and evidence handling must be approved before
   human acceptance. Developer self-tests are not a substitute.

These are obligations for future design and evidence, not completed tests or
current permission to execute them.

## State and next Gate

Readiness requirements, threats, unresolved choices and the exact current
documentary changed-path ceiling are in `docs/project/planning/EAIRA_NEXT_A_LOCAL_OPERATOR_USABILITY_READINESS_PACKAGE.md`.
Independent review may approve this package for later documentary lifecycle
decisions; it cannot satisfy missing implementation prerequisites or approve
staging/commit/push automatically.

Documentary preparation and read-only validation only. No product implementation, runtime execution, model/provider call, arbitrary project/vault read, Windows/service/IPC/account/group/membership/directory/ACL/certificate/signing change, external provider, credential, checkpoint-ref repair, scheduling or external synchronization. Staging, commit and push require separate authorization.
