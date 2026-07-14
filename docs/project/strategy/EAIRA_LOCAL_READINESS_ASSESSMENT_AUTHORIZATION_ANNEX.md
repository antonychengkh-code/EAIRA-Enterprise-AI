# EAIRA Local Readiness Assessment Authorization Annex

## 1. Document Metadata

| Field | Value |
| --- | --- |
| Title | EAIRA Local Readiness Assessment Authorization Annex |
| Document Type | Strategy-owned Project Layer authorization planning annex |
| Layer | Project Layer |
| Status | `DRAFT_WITH_BLOCKERS_FOR_PROJECT_OWNER_INPUT` |
| Execution Marker | `PROPOSED_NOT_AUTHORIZED_FOR_EXECUTION` |
| Assessment Evidence Collection | `UNAUTHORIZED` |
| Decision Authority | Project Owner |
| Planning Task | `LOCAL-READINESS-ASSESSMENT-AUTHORIZATION-ANNEX-PLANNING-001` |
| Date | 2026-07-14 |
| Version | 0.1.0 |

## 2. Purpose

Prepare the single Local Readiness Assessment Authorization Annex required by the Project Owner decision for future separate Project Owner review.

This Annex is a planning artifact only. It does not authorize, execute, simulate, or trial the Local Readiness Assessment. It does not authorize assessment-evidence collection, environment inspection, implementation, remediation, runtime activity, deployment, automation, database mutation, governance modification, production access, milestone establishment, M4, Platform Foundation, or a formal EAIRA Execution Layer.

## 3. Authorization and Traceability

This Annex derives its bounded planning authority from:

- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md`;
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md`.

The current Project Owner decision is `DEFER_PENDING_ADDITIONAL_PLANNING_EVIDENCE`. `AUTHORIZE_BOUNDED_ASSESSMENT` has not been granted. `AUTHORIZE_WITH_REQUIRED_REVISIONS` has not been granted as conditional execution authority.

The Annex addresses the twelve mandatory content areas in Section 6 of the decision record. Every unresolved execution-controlling input remains a blocker and is not converted into an approved fact.

## 4. Evidence Classification Rules

| Classification | Use in this Annex |
| --- | --- |
| Verified repository fact | Directly supported by cited repository content. |
| Project Owner decision | Explicitly recorded Project Owner decision. |
| Proposed assessment input | Candidate input requiring separate Project Owner approval. |
| Evidence gap | Information not supported by current repository evidence. |
| Assumption | Planning premise that must not be treated as evidence. |
| Risk | Identified safety, evidence, scope, or authority risk. |
| Future authorization requirement | Input that must be explicitly approved before assessment activity. |

Agent self-report, conversation memory, tool availability, and unstored local knowledge are not verified repository facts.

## 5. Mandatory Field Resolution Matrix

| # | Mandatory field | Resolution state | Current disposition |
| ---: | --- | --- | --- |
| 1 | Exact local environment boundary and complete target inventory | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | No exact environment or complete target inventory is approved in repository evidence. |
| 2 | Exact approved tool and command manifest | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | No tool or command is approved for assessment execution. |
| 3 | Command-specific arguments, working directory, privilege, target, purpose, expected output, timeout, and mutation-risk determination | `BLOCKED_BY_FIELD_2` | Cannot be completed until the exact command manifest is selected and approved. |
| 4 | Approved and prohibited services, endpoints, ports, network actions, and resources | `PARTIALLY_RESOLVED_WITH_BLOCKERS` | General prohibitions are verified; exact approved items remain unassigned. |
| 5 | Named operator and named independent verifier | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | Repository evidence does not assign either role. |
| 6 | Verifier independence, role separation, and named stop authority | `PARTIALLY_RESOLVED_WITH_BLOCKERS` | Independence principle is verified; named role holders and stop authority remain unresolved. |
| 7 | Observation window, timezone, clock source, freshness, staleness, and rerun rules | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | No approved observation window or freshness policy exists. |
| 8 | Evidence paths, readers, access, integrity, retention, disposal, and stopped-assessment handling | `BLOCKED_PENDING_PROJECT_OWNER_INPUT` | No approved evidence location or lifecycle controls exist. |
| 9 | Redaction, sensitive-data taxonomy, secret prohibition, and accidental-exposure procedure | `PARTIALLY_RESOLVED_WITH_BLOCKERS` | Secret capture is prohibited; detailed taxonomy and incident procedure remain unresolved. |
| 10 | Reproduction procedure for every material observation | `PROPOSED_NOT_APPROVED` | A reusable procedure format is proposed below; command-specific procedures remain blocked. |
| 11 | Criteria-to-evidence mapping | `PROPOSED_NOT_APPROVED` | A decision-use mapping framework is proposed below; exact criteria depend on approved targets and commands. |
| 12 | All-fields-resolved gate | `RESOLVED_AS_CONTROL` | Gate logic is defined below; the gate currently evaluates to `BLOCKED`. |

## 6. Mandatory Field 1 — Local Environment Boundary and Target Inventory

### Verified repository facts

- The proposed assessment must be local, bounded, read-only, evidence-collection only, non-remediating, and independently verifiable.
- External, deployment, production, and unlisted resources are outside the proposed boundary.
- No exact local environment or target inventory is approved by current repository evidence.

### Required Project Owner inputs

The Project Owner must explicitly identify:

- one named local environment;
- the physical or virtual host boundary;
- the operating-system boundary;
- every permitted repository working tree;
- every permitted tool installation;
- every permitted service, process, container, model, runtime, API, endpoint, database, and configuration target;
- every explicitly excluded target;
- whether network access is prohibited or limited to named local endpoints.

### Current status

`BLOCKED_PENDING_PROJECT_OWNER_INPUT`

No environment or target may be inspected, contacted, queried, executed, or inferred under this Annex-planning task.

## 7. Mandatory Fields 2 and 3 — Tool and Command Manifest

### Verified repository facts

- No exact tool or command is approved.
- Commands must be reviewed individually for mutation risk.
- A future execution authorization must approve exact tools, commands, arguments, targets, expected outputs, privilege levels, timeouts, and evidence locations.
- If Hermes is proposed, repository evidence does not currently establish it as an approved target or tool.

### Required manifest schema

| Manifest field | Requirement |
| --- | --- |
| Manifest ID | Stable unique identifier. |
| Tool | Exact executable or tool name and approved version constraint. |
| Command | Exact command text. |
| Arguments | Exact ordered arguments; no placeholders at authorization time. |
| Working directory | Exact approved path. |
| Privilege level | Named user and explicit statement that elevation is or is not permitted. |
| Target | Exact approved target from Field 1. |
| Purpose | One bounded observation purpose. |
| Expected output | Exact expected output form and safe fields. |
| Timeout | Explicit command-specific timeout. |
| Network action | None, local-only, or exact approved destination. |
| Mutation-risk determination | `READ_ONLY_CONFIRMED`, `MUTATION_RISK_UNRESOLVED`, or `PROHIBITED`. |
| Evidence path | Exact approved output location. |
| Reproduction ID | Link to Field 10 procedure. |
| Criteria mapping | Link to Field 11 mapping. |

### Current status

- Field 2: `BLOCKED_PENDING_PROJECT_OWNER_INPUT`
- Field 3: `BLOCKED_BY_FIELD_2`

No candidate command in planning text is authorized for execution.

## 8. Mandatory Field 4 — Services, Endpoints, Ports, Network Actions, and Resources

### Verified prohibited activities

The following remain prohibited unless a future unconditional Project Owner decision expressly changes the applicable item:

- external or production access;
- installation or upgrade;
- service start, stop, or restart;
- container creation, removal, execution, or mutation;
- model download, loading, inference, or execution;
- database query, migration, or mutation;
- API write activity;
- repository mutation;
- runtime mutation;
- deployment;
- credential or secret-value access;
- remediation;
- automation or CI/CD expansion.

### Required Project Owner inputs

A future review must list every approved service, endpoint, port, network action, and resource by exact identifier. Items not listed must remain prohibited.

### Current status

`PARTIALLY_RESOLVED_WITH_BLOCKERS`

General prohibitions are resolved. The approved allowlist is empty and unresolved.

## 9. Mandatory Fields 5 and 6 — Operator, Independent Verifier, Separation, and Stop Authority

### Verified repository facts

- The Project Owner is the decision authority.
- The planning execution owner is not assigned in current repository evidence.
- Agent self-report alone is insufficient evidence.
- Independent verification must rely on direct outputs and reproducible inspection within separately approved scope.

### Required role assignments

| Role | Required named assignment | Current state |
| --- | --- | --- |
| Assessment operator | Named individual or explicitly approved agent under human accountability | `UNASSIGNED` |
| Independent verifier | Named individual independent of observation execution | `UNASSIGNED` |
| Stop authority | Named individual authorized to stop immediately without remediation | `UNASSIGNED` |
| Project Owner | Final authorization and decision authority | `VERIFIED_ROLE`; named identity not restated in this Annex |

### Independence requirements

- The verifier must not generate the primary observation being verified.
- The verifier must have access to approved direct outputs, provenance, timestamps, command text, exit status, redactions, and relevant Git-state evidence.
- The verifier must be able to reject evidence as missing, stale, unsafe, non-reproducible, or outside scope.
- The operator and verifier must both be able to invoke the named stop authority.

### Current status

`PARTIALLY_RESOLVED_WITH_BLOCKERS`

Principles are defined; named assignments and explicit stop authority require Project Owner input.

## 10. Mandatory Field 7 — Observation Window and Evidence Freshness

### Required Project Owner inputs

The future authorization must explicitly define:

- observation start and end timestamps;
- approved timezone;
- authoritative clock source;
- maximum acceptable evidence age;
- staleness conditions;
- rerun triggers;
- whether reruns require renewed authorization;
- handling of evidence captured outside the approved window.

### Proposed control states

| State | Meaning |
| --- | --- |
| `FRESH` | Captured within the approved window using the approved clock source. |
| `STALE` | Older than the approved freshness threshold. |
| `OUTSIDE_WINDOW` | Captured before or after the authorized window. |
| `RERUN_REQUIRED` | A defined change or discrepancy invalidates prior evidence. |
| `UNUSABLE` | Timestamp, provenance, or clock basis is missing or conflicting. |

### Current status

`BLOCKED_PENDING_PROJECT_OWNER_INPUT`

## 11. Mandatory Field 8 — Evidence Handling and Integrity

### Required Project Owner inputs

The future authorization must define:

- exact evidence root path;
- approved readers and writers;
- access-control method;
- naming and indexing rules;
- file-integrity mechanism;
- provenance requirements;
- retention duration;
- disposal procedure;
- handling of partial, failed, or stopped assessments;
- whether repository storage is prohibited or separately approved;
- whether evidence may leave the named local environment.

### Minimum integrity controls proposed for review

- preserve exact command text and ordered arguments;
- record start and end timestamps and exit status;
- identify operator, verifier, host, target, and manifest ID;
- preserve original direct output before any approved redacted derivative;
- record every redaction without retaining prohibited secret values;
- make missing, partial, conflicting, and unexpected output explicit;
- prevent evidence overwrite or silent replacement;
- record verifier disposition separately from operator notes.

### Current status

`BLOCKED_PENDING_PROJECT_OWNER_INPUT`

## 12. Mandatory Field 9 — Sensitive Data, Redaction, and Accidental Exposure

### Verified repository facts

- Secret-value capture or disclosure is prohibited.
- Assessment activity must stop if credentials or sensitive values are requested or exposed.
- Evidence must not infer or disclose sensitive information outside approved scope.

### Required Project Owner inputs

The future authorization must define:

- sensitive-data taxonomy;
- secret, credential, token, key, personal-data, business-data, and configuration-value categories;
- fields that may be retained as names or presence indicators;
- mandatory redaction method;
- prohibited capture patterns;
- accidental-exposure reporting path;
- quarantine, access restriction, retention, and disposal rules for accidentally exposed material;
- who determines whether safe evidence may be retained.

### Current status

`PARTIALLY_RESOLVED_WITH_BLOCKERS`

Secret capture prohibition is resolved. Detailed taxonomy and accidental-exposure controls remain blocked.

## 13. Mandatory Field 10 — Reproduction Procedure

### Proposed standard procedure format

Every material observation must have a separately approved reproduction record containing:

1. reproduction ID;
2. linked manifest ID;
3. exact environment and target identifiers;
4. exact tool and version;
5. exact command and ordered arguments;
6. exact working directory and privilege level;
7. expected safe output;
8. approved timeout;
9. operator action sequence;
10. timestamp and clock source;
11. exit status and direct-output location;
12. redaction steps;
13. verifier repetition or direct-output inspection steps;
14. discrepancy handling;
15. stop conditions;
16. linked criteria-to-evidence mapping.

### Current status

`PROPOSED_NOT_APPROVED`

The format is available for Project Owner review. No material observation or executable reproduction procedure exists until Fields 1–9 are approved.

## 14. Mandatory Field 11 — Criteria-to-Evidence Mapping

### Decision-use rules

- Tool presence may support only a tool-presence observation.
- Version output may support only the observed version at the recorded time.
- Service status may support only observed service availability, not workload or functional readiness.
- File presence may support only existence at the approved path, not correctness or operational validity.
- Local connectivity may support only the approved connection observation, not end-to-end readiness.
- No single observation may establish Local Readiness, a milestone, implementation authority, Platform Foundation, or an Execution Layer.

### Required mapping schema

| Mapping field | Requirement |
| --- | --- |
| Criterion ID | Stable criterion identifier. |
| Decision question | Exact future decision question informed. |
| Required observation | Exact bounded observation. |
| Manifest ID | Approved command or method. |
| Evidence artifact | Exact approved evidence path and type. |
| Verifier action | Exact independent-verification step. |
| Sufficient result | Exact result that supports the criterion only. |
| Insufficient result | Missing, stale, conflicting, partial, or unexpected result. |
| Non-inference boundary | Conclusions explicitly prohibited from this evidence. |
| Decision use | How the evidence may inform, but not determine, a later decision. |

### Current status

`PROPOSED_NOT_APPROVED`

Exact criterion mappings remain blocked by unresolved target and command inputs.

## 15. Mandatory Field 12 — All-Fields-Resolved Gate

### Gate rule

No future assessment-execution authorization decision may be made unless every mandatory field is explicitly classified as one of:

- `RESOLVED_AND_APPROVED_BY_PROJECT_OWNER`;
- `NOT_APPLICABLE_APPROVED_BY_PROJECT_OWNER`.

The following states fail the gate:

- `BLOCKED_PENDING_PROJECT_OWNER_INPUT`;
- `BLOCKED_BY_FIELD_n`;
- `PARTIALLY_RESOLVED_WITH_BLOCKERS`;
- `PROPOSED_NOT_APPROVED`;
- `EVIDENCE_GAP`;
- `ASSUMPTION`;
- unresolved conflict, exception, ambiguity, or unlisted target.

### Current gate evaluation

`BLOCKED`

Blocking fields: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, and 11.

Field 12 is resolved only as gate logic; it does not satisfy the gate.

## 16. Consolidated Project Owner Input Queue

The following decisions are required before this Annex can be finalized for an assessment-authorization decision:

1. Name the exact local environment and approve the complete target inventory.
2. Approve or reject every exact tool and command.
3. Approve command-specific working directories, privilege levels, targets, expected outputs, timeouts, network actions, mutation-risk determinations, and evidence locations.
4. Approve exact service, endpoint, port, network, and resource allowlists and prohibitions.
5. Name the operator.
6. Name the independent verifier and confirm independence requirements.
7. Name the stop authority.
8. Approve observation window, timezone, clock source, freshness, staleness, and rerun rules.
9. Approve evidence paths, access roles, integrity controls, retention, disposal, and stopped-assessment handling.
10. Approve sensitive-data taxonomy, redaction method, secret-handling prohibition, and accidental-exposure procedure.
11. Approve the reproduction procedure format and every command-specific procedure.
12. Approve the criteria-to-evidence mappings and non-inference boundaries.
13. Confirm that all mandatory fields, exceptions, conflicts, and ambiguities satisfy the all-fields-resolved gate.

## 17. Stop Conditions

Annex planning must stop and return to the Project Owner if work would:

- execute, simulate, or trial any assessment activity;
- collect local-readiness evidence;
- inspect or exercise a local service, process, container, endpoint, runtime, model, API, database, credential, deployment, production resource, or unapproved environment;
- modify repository files outside this single Annex deliverable without separate authorization;
- modify runtime, configuration, service, database, deployment, production, governance, decision, Bootstrap, validation, or status state;
- expose or infer sensitive information;
- leave a mandatory field ambiguously classified;
- imply milestone, implementation, conditional execution, or assessment authority.

No remediation or corrective action is authorized after a stop condition is reached.

## 18. Current Annex Decision Readiness

| Question | Current answer |
| --- | --- |
| Are all twelve mandatory fields addressed? | Yes, as planning fields. |
| Are all execution-controlling fields resolved and approved? | No. |
| Is the all-fields-resolved gate satisfied? | No — `BLOCKED`. |
| Is assessment execution authorized? | No. |
| Is assessment-evidence collection authorized? | No. |
| Is a new milestone established? | No. |
| Is implementation or runtime work authorized? | No. |
| Is this Annex ready for an execution-authorization decision? | No; Project Owner inputs are required. |

## 19. Future Review Requirement

After the mandatory inputs are supplied and every field is explicitly resolved, this Annex must undergo direct file review and independent repository verification, including exact Git status, exact Git diff, and direct reading of the finalized Annex.

The Project Owner must then conduct a separate review and record an unconditional decision. Annex completion, acceptance, silence, conditional language, or approval with unresolved revisions is insufficient to authorize any assessment command, observation, interaction, or evidence collection.

## 20. Source Paths

- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE.md`
- `docs/project/strategy/EAIRA_LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_DECISION.md`
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_PACKAGE_001.md`
- `docs/tasks/LOCAL_READINESS_ASSESSMENT_AUTHORIZATION_ANNEX_PLANNING_001.md`
- `docs/project/status/CURRENT_STATUS.md`
- `docs/project/status/TODAY_OBJECTIVE.md`
- `docs/project/status/ACTIVE_TASK.yaml`
- `docs/project/context/CURRENT_CONTEXT.md`

## 21. Boundary

This Annex records bounded Project Layer planning only. It does not authorize or perform the Local Readiness Assessment, collect assessment evidence, establish a milestone, establish M4, approve implementation, authorize runtime work, establish Platform Foundation, establish a formal EAIRA Execution Layer, modify governance, authorize deployment, or permit production change.
