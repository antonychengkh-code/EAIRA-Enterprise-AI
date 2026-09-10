# EAIRA M4 Slice 4 Bounded Read-Only Project Knowledge Query Threat Model

## Security Objective

Provide useful deterministic project-memory lookup without creating arbitrary file-read, instruction-following, model, network, write or authority-escalation capability.

## Assets

- repository and OneDrive file confidentiality outside the exact allowlist;
- controlled status authority;
- integrity of the existing Slice 3 read-only platform;
- absence of runtime writes and external activity;
- bounded canonical output; and
- deterministic evidence suitable for independent review.

## Trust Boundaries

- The repository root and query are untrusted caller inputs.
- Every Markdown byte is untrusted data.
- The seven path strings compiled into the product are the only path authority.
- Memory frontmatter and body text are not project authorization.
- Git state, OneDrive sync state and external providers are outside the query result's authority.

## Threats and Required Controls

| Threat | Required fail-closed control |
| --- | --- |
| Traversal or alternate root | absolute canonical root, pinned ancestors, exact handle-derived path |
| Symlink/junction/name-surrogate substitution | exact tag policy, identity pinning, probe/content equality |
| OneDrive hydration or recall | local objects: no reparse attribute/tag zero; hydrated Cloud directory: reparse plus `0x9000E01A`; hydrated Cloud file: reparse plus `0x9000601A`; all mismatches, Offline/Recall flags and name-surrogate states rejected; no-recall open |
| TOCTOU replacement | pinned ancestors, denied write/delete sharing, pre/post metadata equality |
| Dynamic file expansion | compiled exact seven-file list; no enumeration or caller path |
| Hidden candidate authority | HANDOFF and MEMORY_INBOX excluded; authority label fixed |
| Query language abuse | literal bounded query; no regex, glob, wildcard or model |
| Markdown instruction injection | no execution, no link following, inert excerpt only |
| Raw-file exfiltration | eight-result, line, heading, excerpt and total-output budgets |
| Frontmatter disclosure | frontmatter body not searchable or returnable |
| Partial-result ambiguity | any file/control failure rejects complete query |
| Error leakage | one sanitized error status and exit code |
| Nondeterministic ranking | fixed file/line order; no scores |
| Capability creep | exact API/metadata verifier and changed-path manifest |

## Mandatory Abuse Matrix

[Clause S4-THREAT-MATRIX]

Tests must cover:

- relative, UNC, device, alternate-separator, case-variant and trailing-separator roots;
- the complete directory/file attribute-tag cross-matrix, including local accepted pairs, hydrated Cloud accepted pairs and every mismatch/rejected tag;
- non-directory ancestor, directory leaf, identity replacement and unstable metadata;
- missing allowlisted files, a compiled eighth path, and proof that unrelated physical files are ignored without enumeration;
- exact per-file and aggregate byte boundaries;
- malformed UTF-8, BOM behavior, overlong line and overlong line-count inputs;
- empty, minimum, maximum, maximum-plus-one, control-containing and malformed-surrogate queries;
- literal handling of regex, glob, wildcard, Markdown link, wikilink and instruction-shaped text;
- absent, empty, late and unterminated frontmatter; frontmatter-only matches producing zero results; and post-frontmatter body delimiter handling;
- the cross-product of optional BOM with LF and CRLF, closing-terminator end-exclusive byte counts 8,191/8,192/8,193, logical closing lines 63/64/65, bare-CR and mixed-newline rejection, and EOF without a closing-line terminator;
- zero, one, eight and nine-or-more matches;
- duplicate lines, non-ASCII case behavior and deterministic ordering;
- excerpt and heading Unicode byte-boundary truncation;
- exact ATX recognition, ASCII-only trim and longest-complete-scalar truncation vectors;
- exact canonical JSON constants/order, match-count/truncation semantics, empty-heading behavior, uppercase hashes and 16,384-byte output boundary;
- fixed domain-separated digest vectors, including empty, non-ASCII and multi-match inputs;
- output field closure, authority labels and sanitized errors;
- platform-only compile closure proving zero provider, HTTP, task-intake, network, write, process, shell and dynamic-code references;
- every native operation failing at each call site, short and partial content reads, seven-file reverse-order cleanup and close failure;
- [Clause S4-THREAT-CLEANUP] leaf cleanup closes content then probe immediately for each file; ancestor handles remain pinned across all seven files and close in reverse open order in an outer finally; every close is attempted even after another close fails; a primary read/control failure remains the outcome, while any close failure without a primary failure changes the complete query to `KNOWLEDGE_ERROR/81`;
- direct and indirect attempts to enumerate or open a non-allowlisted file;
- IL/metadata specimens for duplicate P/Invoke, wrong constructor/factory/caller graph, schema tampering and extra allowlist entries; and
- every negative verifier specimen must compile successfully and then be rejected by the verifier; compilation failure is not acceptable negative evidence.
- exact below/at/above vectors from the allowlist, including canonical stdout byte counts and exact success/error channel bytes.

## Non-Claims

This slice does not prove that the memory set is complete, current, authoritative, secret-free or free from malicious text. It provides a bounded locator over seven repository-owned navigation files only.
