# EAIRA M4 Slice 3 Read-Only Project Context Readiness Package

Package ID: `EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_READINESS_V1`

Date: 2026-09-03

Baseline local HEAD: `b3bd69683ae873be59bf5a78e5df4dd6a4e71eec`

Revision: 20

Package state: `S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_COMPLETE_READY_FOR_INDEPENDENT_REVIEW`

Implementation state: `S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_COMPLETE_READY_FOR_INDEPENDENT_REVIEW`

## Authorized Candidate

This remediation package binds one documentary candidate consisting of exactly eight paths:

1. new `docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_3_SCOPE_DECISION.md`;
2. new `docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_ALLOWLIST.md`;
3. new `docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_THREAT_MODEL.md`;
4. new `docs/project/planning/EAIRA_M4_SLICE3_READ_ONLY_PROJECT_CONTEXT_READINESS_PACKAGE.md`;
5. new `docs/project/planning/EAIRA_M4_SLICE3_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md`;
6. modified `apps/agent-services/contracts/EAIRA_LOCAL_TASK_INTAKE_V1.md`, limited to its revision number and correction of the obsolete mock-only provider sentence;
7. modified `docs/project/status/TODAY_OBJECTIVE.md`, limited to the missing current Out of Scope section and its version; and
8. modified `docs/project/status/AGENT_CONTEXT_VERSION.yaml`, limited to the synchronized context and Today Objective versions and update date.

The existing unrelated untracked Claude API files are excluded and must remain untouched.

## Selected Product Contract

Slice 3 is a read-only project-context extension to the published Slice 2 task-intake path. It retains:

- the five existing Agent roles and their order;
- the existing task goal and trace requirements;
- deterministic `mock`;
- fail-closed disabled external `real`;
- separately contracted `ollama-local` behavior;
- the existing Guard and outcome model; and
- no persistence, no new listener, and no production or signing claim.

It adds only a future request-local context bundle sourced from the exact four-file allowlist. The context is untrusted data and cannot authorize actions.

## Proposed Future Implementation Surface

A later implementation package may propose:

- one bounded context-reader library with no write, shell, Git, network, renderer, or child-process capability;
- one explicit CLI repository-root argument or equivalent separately reviewed local configuration;
- an immutable context-envelope type containing only relative path IDs, byte counts, digests, provenance, and in-memory content;
- integration before provider invocation, with whole-request fail-closed behavior; and
- sanitized result metadata containing the allowlist ID and aggregate digest, never raw contents or absolute paths.

No class, flag, schema, executable, file, or test name in this section is approved until a later exact implementation package is independently reviewed and authorized.

## Readiness Prerequisites

| ID | Prerequisite | Current state |
| --- | --- | --- |
| S3-R01 | Project Owner selects Slice 3A documentary scope | PASS |
| S3-R02 | Exact four-path allowlist prepared | PASS |
| S3-R03 | Threat model and fail-closed controls prepared | PASS |
| S3-R04 | Stale task-intake mock-only wording corrected without behavior change | PASS in working-tree candidate |
| S3-R05 | Independent documentary review | R4R1 passed with P0=0, P1=0, P2=0; closed |
| S3-R06 | Separate authority to read the four file contents and capture non-sensitive feasibility evidence | AUTHORIZED_AND_COMPLETED |
| S3-R07 | Encoding, size, placeholder, reparse, and stability feasibility evidence | FULL_REPEAT_PASS; four files; 100,887 aggregate bytes; exact Cloud Files tags; 4,065-byte projection |
| S3-R08 | Exact implementation design and changed-path manifest | R9R4 independent review PASS; P0=0, P1=0, P2=0; closed |
| S3-R09 | Separate Project Owner implementation authorization | AUTHORIZED_2026_09_05; implementation lifecycle complete with formal pinned-compiler verification |
| S3-R10 | Independent implementation and abuse-case review | Initial, R10R1, R10R2, R10R3, R10R4 and R10R5 reviews failed closed; bounded R10R6 canonical readiness-identifier remediation completed; independent R10R6 review is next |

## Mandatory Future Acceptance Evidence

A future implementation cannot pass readiness without:

1. exact changed-path and reference-version binding;
2. two clean byte-identical builds;
3. existing Slice 1 and Slice 2 regression suites unchanged and passing;
4. positive tests for the exact four-file stable snapshot;
5. all negative and abuse cases listed in the threat model;
6. proof that services retain their existing I/O and network restrictions;
7. proof that no runtime write, persistence, raw-content log, external provider, credential, or unauthorized endpoint was introduced;
8. sanitized manifest and report artifacts with no absolute paths or source content; and
9. a separate independent review reporting P0/P1/P2 findings.

## R2 Remediation Binding

R2 addresses every R1 independent-review finding:

- handle-first no-follow/no-recall acquisition, request-scoped deny-write/delete sharing, same-handle identity checks and a single-read digest replace the ambiguous read-once/digest-change rules;
- goal-only Guard pre-authorization occurs before context read, raw context is structurally excluded from authorization, and only Planning receives the bounded projection;
- the projection is capped at 10,000 bytes and the complete canonical request must satisfy the unchanged 16,384-byte provider ceiling;
- aggregate digest serialization has an exact domain tag, encoding, integer width/endian, framing and required golden vectors; and
- exact Markdown/YAML validation, bounded projection fields, authority precedence and cross-version checks are defined.

R2 does not claim that the current four files satisfy these rules. That requires S3-R06 authority and S3-R07 evidence after R2 independently passes.

## Sanitized Initial Feasibility Evidence

- exact allowed files: 4;
- aggregate bytes: 100,539;
- each file: below 262,144 bytes, strict UTF-8 valid, no BOM, not offline, no recall-on-open and no recall-on-data-access;
- each allowed file reparse tag: exact OneDrive Cloud Files `0x9000601A`;
- repository root and exact `docs`, `docs/project`, `docs/project/status` ancestors: reparse, hydrated, no offline/recall attributes, exact OneDrive Cloud Files directory tag `0x9000E01A`;
- Current Status, Active Task and Agent Context Version required labels were present;
- Today Objective lacked an exact current `Out of Scope` heading, causing the initial S3-R07 fail-closed result; and
- no Agent, provider, build, service, staging, commit or push action occurred.

Per-file feasibility hashes are retained in the Gate response and are not copied into ordinary product output.

## R3 Remediation Binding

R3 permits only the two exact observed hydrated OneDrive Cloud Files tags while retaining no-recall, exact full-path, handle identity, same-handle stability and name-surrogate rejection. It also fixes the three R2 non-blocking findings by pinning all ancestor handles, making per-file digests internal-only, and defining parser whitespace/list/decimal/list-hash framing.

The controlled Today Objective correction restores the required current Out of Scope heading without changing product implementation, Windows state, provider configuration or operational authority.

## Sanitized R3 Repeat Feasibility Evidence

- exact hydrated root/ancestor directory tag `0x9000E01A`: PASS;
- exact hydrated allowed-file tag `0x9000601A`: PASS;
- offline/recall rejection, retained ancestor handles, exact full-path equality, same-handle identity/stability, strict UTF-8 and required schema: PASS;
- Current Status and Today Objective version cross-checks: PASS;
- corrected dependency-list digest framing: PASS with 33 items;
- verified-agent empty-list digest framing: PASS with 0 items; and
- canonical projection: FAIL_CLOSED at 14,932 bytes against the unchanged 10,000-byte limit.

The dominant projected value was the complete Current Status `Active Phase` section at 11,440 bytes. No Planning/provider call occurred after the budget failure.

## R4 Projection-Budget Remediation Binding

R4 changes only the projection rule for Current Status `Active Phase`: the first canonical paragraph is projected instead of the complete section. The paragraph algorithm, source-qualified field labels, framing, raw-file digest, aggregate digest, 10,000-byte projection limit, 16,384-byte complete-request limit, no-truncation rule and every authorization boundary remain fixed. R4 does not alter any runtime source content.

Sanitized R4 projection-only recalculation produced 4,065 bytes, 5,935 bytes of projection headroom, projected Active Phase size 575 bytes, and projection SHA-256 `25E9AF7AFB8CD01DFF135E8C6B814C6B2CF6D487509DB7542AC05F6FFE2A7D2B`. Both controlled version cross-checks passed. This result did not by itself replace independent review or claim that the complete canonical provider request satisfies 16,384 bytes.

## R4 Independent-Review Finding and R4R1 Binding

The independent R4 delta review failed closed with `P0=0`, `P1=1`, and `P2=1`. The P1 found that unordered-list marker removal and item joining were not normative, allowing both a 4,079-byte marker-retaining representation and the recorded 4,065-byte marker-free representation. The P2 found that the Scope document retained a stale generic next-gate label.

R4R1 closes only those findings. It requires removal of each exact `- ` marker, ASCII-edge trimming of each non-empty payload, source-order joining by one LF, and no leading or trailing LF. It also synchronizes the Scope next-gate label with this package. The subsequent independent R4R1 review reproduced 4,065 bytes and SHA-256 `25E9AF7AFB8CD01DFF135E8C6B814C6B2CF6D487509DB7542AC05F6FFE2A7D2B` and passed with `P0=0`, `P1=0`, and `P2=0`.

## Full Repeat S3-R07 Evidence

The separately authorized, memory-only full repeat passed without persisted evidence or provider invocation:

- file count 4 and aggregate bytes 100,887;
- exact hydrated directory/file tags `0x9000E01A`/`0x9000601A`;
- no offline or recall attributes;
- pinned ancestors, exact full paths and same-handle stability;
- strict UTF-8, required schemas and both version cross-checks;
- 27 fields, dependency count 33 and verified-agent count 0;
- aggregate SHA-256 `5B10C493DF5D720209BBBD9287BB089BE2211C55F2D6A7AC23D41550EFF966A2`; and
- projection 4,065 of 10,000 bytes with SHA-256 `25E9AF7AFB8CD01DFF135E8C6B814C6B2CF6D487509DB7542AC05F6FFE2A7D2B`.

This closes S3-R07 only. It does not prove the complete 16,384-byte provider request, authorize implementation, or create runtime/publication evidence.

## S3-R08 Design Binding

The exact implementation design and changed-path manifest is `docs/project/planning/EAIRA_M4_SLICE3_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md`. Its complete review and remediation history through R9R3 remains recorded there. The independent R9R3 review returned `P0=0`, `P1=1`, `P2=1`, and `CANNOT_CLOSE` because an `IDisposable.Dispose` interface-dispatch path was not bound or eliminated and the final probe did not prove compatibility with the release-profile-pinned compiler.

Revision 13/R9R4 removes `IDisposable` from the native lease, uses the controlled non-public `Close()` wrapper, profile-binds zero InterfaceImpl rows plus exact lease type/method flags, and adds an exact interface-dispatch regression specimen. A formal non-development run with the pinned Roslyn compiler SHA-256 `2DC1461B1A6E95BE9C1BECEB4B263141B7BB90E704029344A0C2D1A5693D9007` produced two byte-identical builds and passed all 44 context tests, 28 seam specimens and 17 native specimens. Its sanitized out-of-tree manifest status is `M4_SLICE_3_UNSIGNED_TECHNICAL_CHECKS_PASS`; the computed manifest hash is deliberately not embedded in any manifest input. The separate independent R9R4 review returned `PASS`, `P0=0`, `P1=0`, and `P2=0`. Revision 14 therefore records the existing S3-R09 implementation lifecycle as complete and advances only to S3-R10 review readiness.

Revision 16/R10R2 completes the mandatory abuse matrix and output-isolation verifier coverage. The formal release-profile-pinned run passed two byte-identical builds, 52 project-context tests, 31 seam specimens and 17 native specimens. All three new specimens—directory enumeration, raw-content output and per-file-digest output—compiled and were rejected by the production verifier. The resulting manifest reports `M4_SLICE_3_UNSIGNED_TECHNICAL_CHECKS_PASS`, `reproducibleByteForByte=true`, `projectContext.testsPass=true`, and no runtime writes. The computed out-of-tree manifest hash is deliberately not embedded in this manifest input.

Revision 17/R10R3 closes the subsequent two P1 and one P2 findings by exercising every final file independently through probe/content-before/content-after state and substitution paths, adding the missing file-type cases and complete fixed aggregate vectors, rejecting cross-owner reserved YAML keys, and synchronizing all current Slice 3 fields in `ACTIVE_TASK.yaml`. The formal release-profile-pinned run remains at 52 context assertions, 31 seam specimens and 17 native specimens with two byte-identical builds. A new independent R10R3 review remains mandatory.

The independent R10R3 review confirmed those technical controls but returned `CANNOT_CLOSE`, `P0=0`, `P1=1`, and `P2=1`, because three current `ACTIVE_TASK.yaml` fields still described R10R1, the projected `Priority` was stale, `CURRENT_CONTEXT.md` retained Revision 15/R10R1 wording, and `HANDOFF.md` overclaimed synchronization. Revision 18/R10R4 corrects only those controlled-state and summary contradictions, records the review result, and refreshes hash-bound evidence. It changes no product code, allowlist, parser, verifier or capability. The refreshed pinned run retains two byte-identical builds, 52 context tests, 31 seam specimens, 17 native specimens and all three output-isolation specimens; final manifest identity remains out of tree.

The independent R10R4 review confirmed the original controlled-state findings were corrected but returned `CANNOT_CLOSE`, `P0=0`, `P1=1`, and `P2=1`, because the exact design artifact still declared V17 while Revision and active-task identity had advanced, and this package's S3-R10 row retained an obsolete R10R3 next-review statement. Revision 19/R10R5 assigns one exact V19/R10R5 design identity across the design and active task, corrects the S3-R10 row, and refreshes hash-bound evidence without product or capability change.

The independent R10R5 review confirmed the V19/R10R5 design identity, Revision, readiness row and technical evidence but returned `CANNOT_CLOSE`, `P0=0`, `P1=1`, and `P2=0`, because current machine-like readiness fields mixed `READY_FOR_INDEPENDENT_REVIEW` and `READY_FOR_NEW_INDEPENDENT_REVIEW`. Revision 20/R10R6 assigns the exact canonical identifier `S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_COMPLETE_READY_FOR_INDEPENDENT_REVIEW` unchanged to the design State and Current Determination, this package's Package state, Implementation state and Current Determination, and the active-task Status.

## Stop Conditions

Stop before implementation if independent review finds a material ambiguity, if feasibility requires reading outside the four-path allowlist, if any file must be hydrated, if a write-capable or execution-capable dependency is required, if the existing provider or Guard contracts must be weakened, or if the requested work would alter Windows, services, IPC, identities, groups, ACLs, certificates, signing, or external providers.

## Present Verification Boundary

This candidate may be checked for design structure, exact path scope, internal consistency, diff scope and absence of staging. S3-R07 content evidence is complete; another runtime-source read requires separate authority. No other repository content may enter runtime projection or feasibility evidence.

## Current Determination

`S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_COMPLETE_READY_FOR_INDEPENDENT_REVIEW`

The R10R6 candidate retains all prior technical and controlled-state corrections while making every current review-readiness state identifier exactly equal.

Next gate: `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE3_S3_R10R6_REVIEW_READINESS_STATE_IDENTIFIER_CONSISTENCY_REMEDIATION_REVIEW`.
