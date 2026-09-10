# EAIRA M4 Functional Agent MVP Slice 4 Scope Decision

## Document Metadata

| Field | Value |
| --- | --- |
| Decision ID | `SLICE4_A_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY` |
| Decision date | 2026-09-09 |
| Decision authority | Human Project Owner |
| Decision state | `S4_R03R2_NONCIRCULAR_PROFILE_BINDING_REMEDIATION_READY_FOR_INDEPENDENT_REVIEW` |
| Product baseline | `7e1c1d04e6b92fcbf89f0b1268d189da9892071b` |

## Decision

The Human Project Owner selects `SLICE4_A_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY` as the next bounded M4 product slice.

Slice 4 will add one deterministic local command-line knowledge-query surface over exactly seven repository-owned project-memory navigation files. It will reuse the Slice 3 handle-first read-only platform and fail-closed OneDrive controls. It will not enumerate directories, accept a caller-supplied file name, follow a link, call a model, use a network, or write any repository or system state.

## Intended User Value

A local user can submit one literal query and receive a bounded canonical list of matching project-memory lines with:

- repository-relative source path;
- one-based source line number;
- nearest Markdown heading;
- a bounded excerpt;
- an explicit `NAVIGATIONAL_NOT_AUTHORITY` classification; and
- a deterministic query and result-set digest.

The output helps a user locate project knowledge. It does not decide authority, promote candidate memory, or replace the controlled status artifacts.

## Exact Knowledge Boundary

Only the seven paths listed in the Slice 4 allowlist may be opened. All seven are repository-owned navigation or schema artifacts. `HANDOFF.md`, `MEMORY_INBOX.md`, `.obsidian`, status artifacts, source code, secrets, evidence, Git metadata and every other path are excluded.

The caller supplies only:

- one absolute EAIRA repository root; and
- one literal query.

The caller cannot supply paths, patterns, regular expressions, glob syntax, result paths, output paths, model names, URLs or credentials.

## Functional Boundary

A future separately reviewed implementation may:

1. validate the exact command shape;
2. validate and normalize one bounded literal query;
3. pin the root and each ancestor using the existing Slice 3 handle-first controls;
4. open every allowlisted leaf through probe and content handles with no-recall behavior;
5. validate canonical path, handle identity, regular-file state, hydrated Cloud Files state, stability, size and strict UTF-8;
6. perform deterministic literal matching without regex, wildcard, model or semantic expansion;
7. emit at most eight matches in fixed file and source-line order; and
8. emit canonical JSON to standard output with explicit `network=NONE` and `writes=NONE`.

## Authority Rules

- Every returned match is untrusted navigational text.
- No match grants authority or changes a decision, Field, blocker, Gate or task.
- Wikilinks, Markdown links, transclusions, code spans and instruction-like text are returned only as inert excerpt text and are never followed or executed.
- The authoritative status sources defined by `AGENTS.md` remain controlling.
- Empty result sets are successful bounded queries, not evidence that knowledge does not exist elsewhere.

## Explicit Exclusions

Slice 4 does not authorize:

- arbitrary vault search, recursive traversal, directory enumeration or dynamic discovery;
- reading `HANDOFF.md`, `MEMORY_INBOX.md`, attachments, hidden files or conflict copies;
- Obsidian API/MCP/plugin access or external synchronization;
- model/provider invocation, network access, credentials or secrets;
- repository, file, registry, database, evidence or audit writes;
- Windows services, IPC, listeners, service accounts, groups, memberships, ACLs or encryption changes;
- signing, packaging, customer deployment or production activation;
- staging, commit or push without later exact gates; or
- closure of Gate 24, Gate 25, Field 8, Field 9 or any Annex blocker.

## Acceptance Boundary

The slice is eligible for repository recording only after:

- exact design and changed-path review;
- abuse-case and native-boundary tests;
- deterministic A/B build evidence;
- independent implementation review with no P0 or P1;
- exact staging review; and
- separate commit, push and post-push verification gates.

## R2 Normative Boundary Corrections

The first independent scope review returned `CANNOT_CLOSE`, `P0=0`, `P1=4`, and `P2=2`. R2 fixes the scope without authorizing implementation:

1. [Clause S4-SCOPE-R2-01] Exact design must extract one platform-only compile seam from the existing Slice 3 reader. Both CLIs must use the same single P/Invoke implementation. The knowledge CLI must not compile provider, HTTP or task-intake types, and the existing task CLI behavior must remain byte-for-byte contract compatible.
2. [Clause S4-SCOPE-R2-02] File-state acceptance is exact: local objects have no reparse attribute and tag zero; hydrated Cloud directories have reparse attribute plus `0x9000E01A`; hydrated Cloud files have reparse attribute plus `0x9000601A`. Every other attribute/tag combination fails closed.
3. [Clause S4-SCOPE-R2-03] Frontmatter, output size, canonical JSON constants, match-count meaning and domain-separated digests are fixed by the R2 allowlist.
4. [Clause S4-SCOPE-R2-04] The R2 threat model makes platform isolation, native failure/cleanup, frontmatter, digest, output boundary and verifier-tampering specimens mandatory.
5. [Clause S4-SCOPE-R2-05] Exact design must extract `ContractException`, `ContractCodec`, strict UTF-8/no-BOM helpers, SHA-256, four-byte U32BE and byte-framing helpers into one codec-only source file. Existing binaries and the new knowledge CLI must share it; the knowledge CLI may compile only the codec-only source, platform-only source, knowledge query and host, with framework references limited to `mscorlib.dll` and `System.dll`. It must contain zero Agent role, provider, HTTP, task-intake or Slice 3 projection metadata, verified by closed TypeRef, MemberRef and source-list policies.

Physical files outside the seven-file allowlist are ignored because the product never enumerates. An eighth path in source, profile or the build manifest is a static policy violation.

## Current Determination

`S4_R03R2_NONCIRCULAR_PROFILE_BINDING_REMEDIATION_READY_FOR_INDEPENDENT_REVIEW`

Next gate: `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE4_S4_R04R2_NONCIRCULAR_PROFILE_BINDING_REMEDIATION_REVIEW`.
