# EAIRA M4 Slice 3 Read-Only Project Context Allowlist

Allowlist ID: `EAIRA_M4_SLICE3_CONTEXT_ALLOWLIST_V1`

Date: 2026-09-03

Revision: 7

Status: `R10R3_VERIFIED_WORKING_TREE_CANDIDATE_NOT_PUBLISHED`

## Exact Runtime Read Allowlist

The future Slice 3 reader may open only these repository-relative paths, in this exact order:

| Order | Exact repository-relative path | Authority carried into context |
| ---: | --- | --- |
| 1 | `docs/project/status/CURRENT_STATUS.md` | Current project state, decision, blockers, and next action |
| 2 | `docs/project/status/TODAY_OBJECTIVE.md` | Current bounded objective and success criteria |
| 3 | `docs/project/status/ACTIVE_TASK.yaml` | Active task and authorization boundary |
| 4 | `docs/project/status/AGENT_CONTEXT_VERSION.yaml` | Context-version tracking state |

No prefix, suffix, wildcard, case variant, alternate separator, short-name alias, absolute form, URI, UNC path, device path, alternate data stream, or environment-variable expansion is equivalent to an allowlisted entry.

## Resolution Rules

A future Windows implementation must use this exact handle-first acquisition sequence:

1. receive one explicit absolute repository root through a separately approved configuration surface and reject relative, UNC, device, alternate-stream, trailing-space, trailing-dot, or short-name syntax;
2. open the root and each hard-coded ancestor with `GENERIC_READ`, `FILE_SHARE_READ` only, `OPEN_EXISTING`, `FILE_FLAG_OPEN_REPARSE_POINT`, `FILE_FLAG_BACKUP_SEMANTICS`, and `FILE_FLAG_OPEN_NO_RECALL`; hold every handle until request completion and require either no reparse tag or exact hydrated OneDrive directory tag `0x9000E01A`;
3. for every retained root/ancestor handle, reject offline/recall attributes, name-surrogate tags, non-directory type, failed identity query, or a canonical final volume path not exactly equal to the expected complete root/ancestor path;
4. probe the final file without following it by using `FILE_FLAG_OPEN_REPARSE_POINT` and `FILE_FLAG_OPEN_NO_RECALL`; require either no reparse tag or exact hydrated OneDrive file tag `0x9000601A`, reject offline/recall/name-surrogate state, then close the probe;
5. open the final content handle with `GENERIC_READ`, `FILE_SHARE_READ` only, `OPEN_EXISTING`, `FILE_FLAG_SEQUENTIAL_SCAN`, and `FILE_FLAG_OPEN_NO_RECALL`; do not use `FILE_FLAG_OPEN_REPARSE_POINT` for this content handle because an approved Cloud Files reparse point must be followed without recalling remote content;
6. before reading any byte, obtain canonical final path, volume serial, file ID, length, last-write timestamp, attributes and reparse tag from the opened content handle; require ordinal exact equality with `canonical-root + backslash + the complete hard-coded relative chain`, and require a regular non-offline, non-recall, non-name-surrogate file whose tag is zero or exact `0x9000601A`;
7. read the opened handle sequentially exactly once while computing its SHA-256, rejecting a fifth file, byte 262,145, aggregate byte 1,048,577, short read, decode error, cancellation, or I/O error;
8. after the read, query the same content handle again and require unchanged volume serial, file ID, length, last-write timestamp, attributes and reparse tag; the digest is the single-read digest and is not compared with an impossible second-read digest;
9. close all content, probe, ancestor and root handles on success or failure, retain no persistent lock, perform no directory listing or repository discovery, and never reopen a file within the request; and
10. reject the complete bundle before Planning or provider invocation if any step fails.

The two Cloud Files tags are exact environment-specific exceptions established by sanitized Gate 4 evidence. All other non-zero reparse tags fail closed. The exception does not authorize hydration: `FILE_FLAG_OPEN_NO_RECALL`, absence of offline/recall attributes, exact final-path equality and same-handle stability remain mandatory.

## Content Limits

| Control | Required value |
| --- | --- |
| File count | Exactly 4 |
| Maximum bytes per file | 262,144 |
| Maximum aggregate bytes | 1,048,576 |
| Encoding | Strict UTF-8 without BOM; malformed byte sequences fail closed |
| Read count | One bounded snapshot per task request |
| Retry | None |
| Persistence | None |
| Raw-content logging | Prohibited |
| Canonical context projection | At most 10,000 UTF-8 bytes |
| Complete canonical provider request | At most 16,384 UTF-8 bytes, including policy, role, goal, projection, escaping and JSON envelope |

The existing provider limit of 16,384 bytes remains unchanged and controlling. The implementation must build the exact request bytes through the existing canonical request builder as a preflight before any chat call. There is no token-count claim: the exact serialized-byte ceiling is the enforceable transport contract. A projection or request above either ceiling fails closed; it is never truncated, summarized, split, retried, or partially sent.

## Exact Validation and Projection Schema

Raw bytes are hashed before newline normalization. Decoded text may normalize CRLF and CR to LF for parsing only.

Markdown files require each exact `## <field>` heading once. A field value is the complete text until the next level-two heading; duplicate or missing headings fail. YAML files require one top-level value for every named field. Canonical quoted keys and the legacy unquoted harness form are accepted; every visible top-level key must be unique. Additional top-level fields and their indented data are opaque and unprojected unless the exact key is reserved to another controlled source. A cross-owner reserved key, required duplicate, missing key, malformed required scalar or malformed required list fails closed. Required scalars and required list elements must be quoted strings without C0/C1 controls, CR or LF. `Last Updated` is intentionally owned and projected independently by both YAML sources.

Validation requires:

- `CURRENT_STATUS.md`: Context ID, Version, Updated At, Current Milestone, Active Phase, Current Decision, Blockers, Next Action;
- `TODAY_OBJECTIVE.md`: Date, Milestone, Current Scope, Out of Scope, Expected Deliverables, Success Criteria;
- `ACTIVE_TASK.yaml`: Task ID, Owner, Status, Priority, Dependencies, Last Updated; and
- `AGENT_CONTEXT_VERSION.yaml`: Context Version, Last Updated, Current Status Version, Today Objective Version, Knowledge Index Version, Verified Agents.

The canonical projection uses UTF-8 without BOM, LF only, and this exact fixed order:

1. from Current Status: Context ID, Version, Updated At, Current Milestone as all non-empty controlled lines joined by LF, the first paragraph of Active Phase, the first paragraph of Current Decision, the complete first unordered list in Blockers, and the first paragraph of Next Action;
2. from Today Objective: Date, Milestone as all non-empty controlled lines joined by LF, the first paragraph of Current Scope, the first paragraph of Expected Deliverables, and the complete first unordered list in Success Criteria;
3. from Active Task: Task ID, Owner, Status, Priority, Last Updated, dependency count, and SHA-256 of the canonical length-framed dependency scalars; and
4. from Agent Context Version: every required scalar plus verified-agent count and SHA-256 of the canonical length-framed verified-agent scalars.

Paragraph means the first maximal run of non-empty, non-heading, non-list lines after the heading; trim ASCII space/TAB from each line and join lines with one LF. Unordered list means the first maximal run of top-level lines beginning exactly with the two ASCII bytes `- `; continuation and nested items are rejected. For each accepted list line, remove exactly that leading `- ` marker, trim ASCII space/TAB from both edges of the remaining payload, and require the payload to be non-empty. The projected list value is only those payloads in source order joined by exactly one LF, with no leading or trailing LF and no retained list marker.

Each projected field label is the exact source name followed by a full stop and the exact projected field name: `Current Status.<field>`, `Today Objective.<field>`, `Active Task.<field>`, or `Agent Context Version.<field>`. Derived labels are exactly `Active Task.Dependency Count`, `Active Task.Dependency SHA-256`, `Agent Context Version.Verified Agent Count`, and `Agent Context Version.Verified Agent SHA-256`. This source-qualified form makes every label unique without caller-selected aliases.

Each projected field is framed as `<decimal UTF-8 label length>:<label><decimal UTF-8 value length>:<value>` followed by LF. Decimal is shortest ASCII base-10 with no leading zero except zero itself. YAML list-digest input uses, for each item in order, unsigned 32-bit big-endian UTF-8 byte length followed by exact UTF-8 item bytes; the empty list hashes the empty byte string. Empty required values, prohibited controls, missing paragraph/list forms, duplicate labels, or a projection above 10,000 bytes fail closed. No ellipsis or omitted tail is represented as full content. First-paragraph selection is a schema-defined bounded view, not adaptive truncation or summarization; the raw-file digests bind the complete source snapshot.

Authority precedence is fixed: Current Status owns project state/decision/blockers; Today Objective owns the bounded objective; Active Task owns task identity and authorization; Agent Context Version owns version tracking. A lower-precedence file cannot override another owner's field. Current Status Version and Today Objective Version in Agent Context Version must exactly equal their respective source versions. Any ownership conflict or mismatch fails closed.

## Aggregate Digest Framing

The aggregate digest is SHA-256 over these exact bytes:

1. ASCII domain tag `EAIRA_M4_SLICE3_CONTEXT_BUNDLE_V1` followed by one NUL byte;
2. for each of the four rows in allowlist order: unsigned 32-bit big-endian path-ID byte length, UTF-8 path-ID bytes, unsigned 64-bit big-endian raw-file byte length, then the 32 raw SHA-256 bytes; and
3. no separator, terminator, or additional field.

Path ID is the exact repository-relative path shown in the table with forward slashes. Future tests must contain fixed golden vectors for empty synthetic files, one-byte synthetic files, non-ASCII UTF-8, order changes, length-boundary changes, and content changes.

R10R2 implemented fixed empty, one-byte and non-ASCII aggregate vectors and exact per-file 262,144/262,145, aggregate 1,048,576/1,048,577, and projection 10,000/10,001 boundaries. R10R3 adds fixed reversed-path-order, 262,143/262,144 maximum-length-boundary and same-length content-change vectors. It also exercises every final file independently at probe, content-before and content-after validation and verifies that an extra file is neither enumerated, opened nor projected. These tests do not widen the allowlist.

## Non-Allowlisted Governance References

The following files inform design and validation but must not enter the runtime context payload:

- `AGENTS.md`;
- `docs/project/status/README.md`;
- `docs/specifications/EAIRA_CONTEXT_CONTRACT_V1.md`; and
- `docs/project/memory/README.md`.

The project-memory layer remains navigational only. No memory note may override the four controlled runtime sources.

## Deny Rule

Everything not enumerated in the four-row table is denied. A caller cannot widen this list. Any allowlist change requires a new Project Owner scope decision and independent review.
