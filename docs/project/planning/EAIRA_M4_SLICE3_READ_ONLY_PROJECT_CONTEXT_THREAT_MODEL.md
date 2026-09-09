# EAIRA M4 Slice 3 Read-Only Project Context Threat Model

Threat-model ID: `EAIRA_M4_SLICE3_READ_ONLY_CONTEXT_TM_V1`

Date: 2026-09-03

Revision: 7

Status: `R10R3_CONTROLS_VERIFIED_WORKING_TREE_NOT_PUBLISHED`

## Assets and Trust Boundaries

Protected assets are the repository contents, the four controlled context artifacts, their confidentiality and integrity, the task authorization boundary, the five-Agent pipeline, and sanitized task results.

Trust boundaries are:

1. caller to task-intake CLI;
2. configured repository root to exact allowed file;
3. filesystem bytes to validated immutable snapshot;
4. untrusted snapshot text to prompt construction;
5. EAIRA client to the already contracted provider; and
6. provider output to the existing Guard and result contract.

Read-only access is not assumed harmless. Reading can disclose data, hydrate cloud placeholders, race with writers, amplify prompt injection, or cause raw content to enter logs or provider history.

## Threats and Required Controls

| ID | Threat | Required fail-closed control |
| --- | --- | --- |
| S3-T01 | Path traversal or absolute-path injection | No caller path input; hard-coded exact relative paths; canonical containment check |
| S3-T02 | Symlink, junction, mount-point, or reparse escape | Retained handle chain and exact final-path equality; allow only zero tag or exact hydrated OneDrive directory/file tags `0x9000E01A`/`0x9000601A`; reject every other or name-surrogate tag |
| S3-T03 | NTFS alternate stream, device, UNC, short-name, or case ambiguity | Reject alternate syntax and require exact canonical path identity |
| S3-T04 | OneDrive placeholder hydration or unavailable content | Exact hydrated Cloud Files tags only, `FILE_FLAG_OPEN_NO_RECALL` on every open, and pre/post rejection of offline or recall attributes |
| S3-T05 | File substitution or mutation during read | Handle-first no-follow/no-recall open, deny write/delete sharing, same-handle pre/post identity and metadata checks, single-read SHA-256, whole-request rejection |
| S3-T06 | Oversized or malformed input | Exact file-count, per-file, aggregate, strict UTF-8, schema-defined first-paragraph projection, and complete-request limits |
| S3-T07 | Markdown link, transclusion, or embedded-command expansion | Treat bytes as plain text; do not render, resolve, invoke, or follow references |
| S3-T08 | Prompt injection in project text | Goal-only Guard pre-authorization is sealed before context read; raw context is excluded from authorization inputs and is available only to non-authorizing Planning after allow |
| S3-T09 | Authority confusion between controlled and navigational sources | Runtime allowlist contains only four controlled artifacts; fixed precedence; memory excluded |
| S3-T10 | Partial or internally inconsistent context | Exact schema, ownership precedence and cross-version checks; validate all four artifacts before Planning/provider invocation |
| S3-T11 | Raw-content leakage through console, logs, reports, cache, crash text, or telemetry | No persistence or cache; sanitized error codes only; never include content excerpts or absolute paths |
| S3-T12 | Disclosure beyond the intended local provider boundary | Send only the bounded projection to Planning through the selected provider; raw bytes never enter provider input; no new external provider, credential, endpoint, or listener |
| S3-T13 | Stale or uncommitted working-tree content mistaken for published state | Label provenance as current working-tree snapshot; emit digests; make no Git cleanliness or commit claim |
| S3-T14 | Reader gains write or execution capability | Read-only Win32 handles with request-scoped deny-write/delete sharing; no file mutation APIs, shell, Git, plugin, script, renderer, or child process |
| S3-T15 | Context or provider output authorizes an action | Existing Guard and Human Project Owner authority remain controlling; data cannot self-authorize |
| S3-T16 | Cross-request reuse or contamination | Request-local immutable bundle only; dispose after result; no cross-request cache |

## Authorization-Isolation Invariant

The Guard pre-authorization consumes only the validated TaskEnvelope goal and existing policy constants. It runs before any context handle is opened. Denial reads no context. On allow, the context projection may be supplied only to Planning. The later existing Guard result must replay the same goal-only policy and equal the sealed pre-authorization result. Context, Planning text, provider output and digests cannot select provider, path, role, operation, or authority. Operations remains digest-only and cannot receive raw or projected context.

Prompt labels and delimiters are defense-in-depth only and are not claimed as an authorization boundary.

## Required Context Envelope

A future implementation must bind these fields into an immutable request-local envelope:

- allowlist ID and ordered path IDs;
- per-file byte count and SHA-256;
- aggregate SHA-256 using the exact domain tag, fixed-width big-endian lengths and raw digest framing in the allowlist;
- canonical projection byte count and SHA-256;
- provenance label `WORKING_TREE_SNAPSHOT_NO_GIT_PROVENANCE_CLAIM`;
- context classification `UNTRUSTED_DATA_NOT_INSTRUCTIONS`; and
- trace ID already validated by the task-intake contract.

Raw absolute paths and file contents must not appear in ordinary result JSON or error output. Raw file contents may exist only in memory for validation and projection, then must be released. Only the bounded projection may enter the Planning provider request.

Per-file counts, identities and digests remain internal-only. A future versioned canonical result may expose only allowlist ID, aggregate bundle digest, projection byte count and projection digest. Any per-file disclosure requires separate Project Owner authorization.

## End-to-End Budget

The raw read ceiling protects local resource use and is not a provider budget. The canonical projection is capped at 10,000 UTF-8 bytes. The exact Planning request, after goal inclusion, policy text, role text, escaping and JSON framing, must be constructed and rejected unless it is at most the existing 16,384-byte provider ceiling. Mock and ollama-local use the same projection and preflight rule. No token-window sufficiency is claimed, no provider contract is expanded, and no truncation or multi-request fallback is allowed.

R4 selects only the first canonical paragraph of Current Status `Active Phase`. This is a fixed schema rule applied identically to every request, not content-dependent truncation. The complete source file remains integrity-bound by its internal raw-file digest and the aggregate bundle digest.

R4R1 additionally fixes unordered-list projection to marker-free, ASCII-edge-trimmed item payloads joined by one LF without a leading or trailing LF. Alternative marker retention, separators, caller-selected formatting, or adaptive serialization must fail closed.

## Validation and Abuse Cases Required Before Implementation Acceptance

Acceptance tests must cover traversal, alternate separators, case variants, ADS syntax, UNC/device paths, every allowed and rejected Cloud Files state at every root/ancestor and final file, root/ancestor/final-handle substitution, no-recall open failure, deny-write/delete sharing, missing and extra files, exact per-file/aggregate/projection boundaries, complete request byte 16,384/16,385 boundaries, malformed UTF-8 and BOM, mid-read mutation, partial bundles, duplicate/missing fields, duplicate YAML keys, ownership conflicts, version mismatch, fixed digest golden vectors, content-injected instructions, Markdown references, raw-content log scanning, provider failure, cancellation, and repeated requests.

At least one isolated test must prove that a path which passes lexical checks but resolves outside the root is rejected. At least one isolated test must prove that instruction-like text inside an allowed document cannot enter either Guard input, change the sealed/replayed Guard outcome, select an additional path/provider, or enable an operation.

## Residual Risks

- A local account already able to read the files can observe them independently of EAIRA.
- Local Ollama process retention or diagnostics cannot be proven solely by the EAIRA client and requires separate provider-operational verification.
- Working-tree snapshots may contain authorized but unpublished edits; Slice 3 reports that limitation rather than claiming Git provenance.
- Operating-system and storage-layer behavior can change after validation; acceptance therefore requires independent implementation review and runtime evidence.

## Current Determination

`R10R3_COMPLETE_ABUSE_MATRIX_OWNERSHIP_CONFLICT_AND_CONTROLLED_STATE_REMEDIATION_VERIFIED_READY_FOR_INDEPENDENT_REVIEW`

R10R3 retains the R10R1 canonical parser and R10R2 output-isolation verifier, adds non-directory ancestor and directory final-file cases, independently exercises every final file at probe/content-before/content-after state and canonical-path validation, applies identity substitution and content-open failure per file, completes the fixed path-order/maximum-length/content-change digest vectors, and rejects cross-owner reserved YAML keys. Formal pinned-toolchain evidence remains out of tree and does not establish publication, signing or production activation.
