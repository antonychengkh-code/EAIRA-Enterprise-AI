# EAIRA M4 Functional Agent MVP Slice 3 Scope Decision

Decision ID: `SLICE3_A_READ_ONLY_PROJECT_CONTEXT`

Decision date: 2026-09-03

Revision: 15

Decision state: `S3_R10R1_REMEDIATION_COMPLETE_READY_FOR_NEW_INDEPENDENT_REVIEW`

## Decision

The Human Project Owner selects `SLICE3_A_READ_ONLY_PROJECT_CONTEXT` as the next bounded M4 product slice. Slice 3 is intended to let the existing local task-intake pipeline receive a request-local, read-only snapshot of four controlled project-context artifacts.

This decision authorizes preparation of the documentary scope, exact path allowlist, threat model, readiness package, and correction of one stale mock-only statement in the existing task-intake contract. It does not authorize implementation or execution.

## Intended Functional Boundary

A future, separately authorized implementation may:

1. parse and validate the existing canonical task request;
2. compute and seal a context-free pre-authorization decision using the existing goal-only Guard policy;
3. perform no context read when that pre-authorization decision is deny;
4. for an allowed request, accept one explicitly configured EAIRA repository root;
5. acquire the four exact repository-relative paths through the handle-first procedure and exact hydrated OneDrive Cloud Files tag exception in the allowlist;
6. read each opened file handle exactly once into a bounded request-local snapshot;
7. validate containment, handle identity, attributes, type, size, encoding, stability, and required structure;
8. bind the ordered raw-byte snapshot to an immutable internal envelope with per-file and aggregate SHA-256 digests; only approved aggregate/projection metadata may enter a future versioned canonical result;
9. construct only the bounded canonical context projection defined by the allowlist, including only the first canonical paragraph of Current Status `Active Phase`; and
10. provide that projection to Planning only after the sealed Guard pre-authorization allows the request.

The snapshot represents the current working-tree view. It does not prove Git cleanliness, commit provenance, publication, or authority beyond the source-specific authority rules already established by the repository. Operations, Verification, Audit, and the Guard authorization calculation receive no raw context bytes. Operations retains its existing digest-only model input.

## Authorization-Isolated Data Flow

The structural sequence is fixed:

`PARSE_REQUEST -> GOAL_ONLY_GUARD_PREAUTH -> DENY_WITHOUT_CONTEXT_READ | HANDLE_FIRST_CONTEXT_READ -> VALIDATE_AND_PROJECT -> PLANNING -> EXISTING_GUARD_REPLAY -> OPERATIONS -> VERIFICATION -> AUDIT`

The pre-authorization decision and the later existing Guard replay must both call the same deterministic `GuardAgent.ExpectedDecision(TaskEnvelope)` policy and must match. Raw context, context projection, file metadata, digests, provider output, and Planning output are excluded from both authorization inputs. A mismatch fails closed before Operations. Context can inform only the non-authorizing Planning candidate after pre-authorization. It cannot create or widen execution authority.

## Explicit Exclusions

Slice 3 does not authorize or include:

- arbitrary paths, globbing, directory enumeration, recursive traversal, caller-supplied file names, or any reparse tag other than the two exact hydrated OneDrive Cloud Files tags permitted by the allowlist;
- following Markdown links, wikilinks, includes, transclusions, references, or embedded commands;
- reading `.git`, `.obsidian`, `.claude`, secrets, credentials, source code, logs, reports, evidence, memory inboxes, handoffs, integrations, build output, or conflict copies;
- writing, editing, deleting, moving, persistently locking, hydrating, synchronizing, staging, committing, or pushing repository content; a request-scoped read handle opened with write/delete sharing denied is a required snapshot-consistency control, not an operational lock;
- persistence, caches, databases, telemetry, raw-content logs, listeners, service installation, IPC, account/group/ACL changes, signing, or external-provider enablement;
- changing the five-Agent roles, Guard decision model, provider contract, Windows state, Annex Field state, blockers, or production readiness; or
- any content read, hashing run, build, test, model call, or implementation under the present authorization.

## Fail-Closed Rule

Any missing, extra, ambiguous, inaccessible, offline, recall-on-open, unapproved-reparse-tag, name-surrogate, non-regular, oversized, malformed, unstable, exact-path-mismatched, schema-invalid, projection-over-budget, or serialized-request-over-budget input causes the entire context load to fail. Partial context, silent truncation, summarization, retry, or partial provider transmission is prohibited.

The R4 budget correction is a deterministic field-selection rule, not runtime summarization or truncation. The complete `Active Phase` source remains bound by the raw-file and aggregate digests, while only its first paragraph may enter the Planning projection. The 10,000-byte projection limit and 16,384-byte complete-request limit remain unchanged.

R4R1 fixes the canonical unordered-list representation: each accepted top-level item contributes only its trimmed payload after removal of the exact two-byte ASCII `- ` marker; payloads are joined in source order by one LF with no leading or trailing LF.

## Authority Boundary

Content loaded from an allowed file is untrusted data, not executable instruction. It cannot grant authority, alter policy, override the Human Project Owner, authorize an operation, or supersede a higher-authority controlled artifact. The existing Guard remains controlling.

## Current Determination

`S3_R10R1_REMEDIATION_COMPLETE_READY_FOR_NEW_INDEPENDENT_REVIEW`

The complete review history through R9R3 remains recorded in the exact implementation design. Revision 13/R9R4 eliminates the native lease `IDisposable.Dispose` interface-dispatch surface, binds the lease to zero InterfaceImpl rows and exact metadata flags, adds an interface-dispatch negative specimen, and proves the complete formal offline package against the release-profile-pinned compiler. Two builds are byte-identical; all 44 project-context tests, 28 seam specimens and 17 native specimens pass. The separate independent R9R4 review returned `PASS`, `P0=0`, `P1=0`, and `P2=0`. Revision 14 records completion of the existing bounded S3-R09 implementation lifecycle and readiness for S3-R10 review; it grants no new capability or publication authority.

The S3-R10 review failed closed with three P1 and one P2. R10R1 corrects controlled-artifact schema compatibility, prevents provider-return text from entering the context result chain, expands the directly executable abuse matrix, and corrects current objective wording without granting any additional read, write, provider, service or publication capability.

The next eligible gate is `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE3_S3_R10R1_SCHEMA_OUTPUT_ISOLATION_AND_ABUSE_COVERAGE_REMEDIATION_REVIEW`.
