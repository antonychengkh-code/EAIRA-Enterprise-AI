# EAIRA M4 Slice 4 Bounded Read-Only Project Knowledge Query Allowlist

## Package Identity

- Decision: `SLICE4_A_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY`
- Revision: 12
- State: `GATE24_R2R2_TO_GATE28_CONTROLLED_LIFECYCLE_CANDIDATE`

## Exact File Allowlist

[Clause S4-ALLOW-CLOSED-LIST]

The implementation must contain this ordered, closed list:

1. `docs/project/memory/README.md`
2. `docs/project/memory/DECISION_INDEX.md`
3. `docs/project/memory/DISCOVERY_INDEX.md`
4. `docs/project/memory/PROCEDURE_INDEX.md`
5. `docs/project/memory/OPEN_QUESTIONS.md`
6. `docs/project/memory/STABILITY_CHECKLIST.md`
7. `docs/project/memory/MEMORY_SCHEMA.md`

No caller value may alter the list or its order. Every allowlisted file is mandatory; missing, ambiguous or inaccessible input fails the complete query. Physical files outside the seven-file list are ignored because the implementation never enumerates. Any eighth path compiled into source, profile or build metadata is a static policy violation.

## Explicitly Excluded Memory Files

- `docs/project/memory/HANDOFF.md`: provisional continuation summary, excluded from query output.
- `docs/project/memory/MEMORY_INBOX.md`: unapproved candidate memory, excluded from query output.

No other file under `docs/project/memory` is implicitly allowed.

## Root and File Controls

The implementation must reuse the Slice 3 production read-only platform and enforce:

- absolute canonical repository root;
- exact ancestor handle pinning;
- exact full-path equality from handles;
- no directory enumeration;
- exact attribute/tag truth table: local directories and files have no reparse attribute and tag zero; hydrated Cloud directories have the reparse attribute and tag `0x9000E01A`; hydrated Cloud files have the reparse attribute and tag `0x9000601A`; every other combination fails closed;
- no Offline, RecallOnOpen or RecallOnDataAccess state;
- regular-file leaf type;
- probe/content handle identity equality;
- stable volume/file identity, byte count and last-write time;
- `FILE_OPEN_REPARSE_POINT` probes and `FILE_OPEN_NO_RECALL` content opens;
- read sharing only, with write and delete sharing denied; and
- exactly one bounded content read per file.

## Query Grammar

[Clause S4-ALLOW-QUERY]

- Required: one non-empty literal query.
- Processing order: reject malformed UTF-16, normalize the query to Unicode Form KC, count Unicode scalar values, then reject controls.
- Length: 1 through 64 Unicode scalar values after normalization.
- Prohibited: NUL, CR, LF, tab, C0/C1 controls, unpaired UTF-16 surrogates.
- Matching: normalize each searchable source line to Unicode Form KC for comparison only, then apply `OrdinalIgnoreCase` literal substring matching; returned heading and excerpt bytes remain derived from the original decoded text.
- No regex, glob, wildcard, stemming, fuzzy search, token expansion or model inference.

## Input Budgets

- Maximum per file: 65,536 post-BOM content bytes.
- Maximum seven-file aggregate: 262,144 post-BOM content bytes.
- Encoding: strict UTF-8; optional UTF-8 BOM may be accepted only if stripped before line accounting.
- Maximum logical line: 1,024 UTF-8 bytes.
- Maximum line count per file: 4,096.

Any exceeded boundary fails the complete query without partial results.

Mandatory below/at/above vectors and expected outcomes are exact:

| Boundary | Below | At | Above |
| --- | --- | --- | --- |
| normalized query scalars | 1 PASS | 64 PASS | 65 INVALID_REQUEST/64; zero is INVALID_REQUEST/64 |
| per-file post-BOM content bytes | 65,535 PASS | 65,536 PASS | 65,537 KNOWLEDGE_ERROR/81 |
| seven-file aggregate post-BOM content bytes | 262,143 PASS | 262,144 PASS | 262,145 KNOWLEDGE_ERROR/81 |
| logical-line UTF-8 bytes excluding terminator | 1,023 PASS | 1,024 PASS | 1,025 KNOWLEDGE_ERROR/81 |
| logical lines per file | 4,095 PASS | 4,096 PASS | 4,097 KNOWLEDGE_ERROR/81 |
| heading payload UTF-8 bytes | 159 emitted unchanged | 160 emitted unchanged | 161 PASS and truncated to 160 |
| excerpt payload UTF-8 bytes | 239 emitted unchanged | 240 emitted unchanged | 241 PASS and truncated to 240 |
| complete successful stdout bytes including LF | 16,383 PASS | 16,384 PASS | 16,385 KNOWLEDGE_ERROR/81 |

[Clause S4-ALLOW-VECTORS] Fixture construction is byte-exact. `REP(b,n)` means byte `b` repeated exactly `n` times. `DOC(N)` starts with ASCII bytes for `---\nx: y\n---\n`, then appends body records of `REP(0x61,min(1024,remaining-1)) || 0x0A` until its post-BOM content total is exactly `N`; when `remaining=1`, append only `0x0A`. `AGG(T)` creates seven `DOC` values: each receives `floor(T/7)` post-BOM content bytes and the first `T mod 7` receive one additional byte. `LINES(n)` is ASCII `---\nx: y\n---\n` followed by exactly `n-3` ASCII `a\n` records. Boundary vectors use `DOC(65535/65536/65537)`, `AGG(262143/262144/262145)`, a body line of `REP(0x61,1023/1024/1025)||0x0A`, and `LINES(4095/4096/4097)`. Heading and excerpt vectors use ASCII `a` payloads of the stated 159/160/161 and 239/240/241 lengths. Without BOM, the corresponding physical file lengths are 65,535/65,536/65,537 bytes; with a three-byte BOM they are 65,538/65,539/65,540 bytes and the same PASS/PASS/FAIL outcomes apply because each BOM is excluded before per-file and aggregate accounting.

The 16,383/16,384/16,385-byte constructions are isolated canonical serializer/output-budget fixtures, not end-to-end file fixtures. They contain eight synthetic matches at `docs/project/memory/README.md`, lines 1 through 8, with `truncated=false`; the line values are serializer inputs and do not assert that repository frontmatter is searchable. Each of the 16 heading/excerpt payloads starts with ASCII `a`; their additional raw-byte capacities in canonical order are alternately 159 then 239. Allocate the stated NUL count in canonical payload order, filling each capacity before the next, then allocate the stated ASCII `b` count into the remaining first available capacity. For 16,383 bytes use 2,511 NUL and 4 `b` bytes: result-set SHA-256 `97382904FC236BA99121F0CBC24B655A54FC918DDCE98BC6B54915952D64557D`, stdout SHA-256 `2997BAA63754C53C18C57E3DA5056F5E1CD735CAF1D434FF5569DA9658656A97`, PASS. For 16,384 use 2,511 NUL and 5 `b` bytes: result-set SHA-256 `9956033C0206EF102D148F423B78DDC0F7A7705454CA0FED9978140A906F41FC`, stdout SHA-256 `FA84EDE1711750621C69778785061E4566D742E55A31E36FED6D2300404F10BF`, PASS. For the hypothetical 16,385 serialization use 2,512 NUL and zero `b` bytes: result-set SHA-256 `AA2EFF114D6176FDBEF4414D6BE7E0F2072323E32D2D9665A0844CABF30EE14B`, hypothetical stdout SHA-256 `8B38D637CBE42F2E7BD9013D1826266F040080CF51C1DD382DBE8D27C04C0E7F`; it must emit only the exact `KNOWLEDGE_ERROR/81` error stdout instead.

## Search and Result Rules

[Clause S4-ALLOW-RESULT-BYTES]

- Search file order is the exact allowlist order.
- Search line order is ascending one-based source line number.
- YAML frontmatter delimiters and frontmatter body are not searchable or returnable.
- A body line is blank only when it is empty after removing its line terminator; such a line is ignored.
- An ATX heading is recognized only at column one as one through six ASCII `#` bytes followed by end of line or one ASCII space. Heading text is the original remainder after the marker and, when present, exactly one following ASCII space. Other leading whitespace, tabs after the marker, seven or more `#` bytes and closing-hash interpretation are not headings.
- The nearest preceding recognized body ATX heading supplies context. Heading text is trimmed by removing only leading and trailing ASCII space and tab characters.
- A matching line yields one result; duplicate matching text on different lines remains distinct.
- Maximum results: 8. Additional matches set `truncated=true`; content is never searched beyond the required full bounded scan.
- Excerpt: original matched body line after removing its line terminator and then removing only leading and trailing ASCII space and tab characters; maximum 240 UTF-8 bytes.
- Heading: exact recognized and ASCII-trimmed heading text; maximum 160 UTF-8 bytes.
- Byte truncation emits the longest leading sequence of complete Unicode scalar values whose strict UTF-8 encoding fits the stated byte maximum. It emits no ellipsis, suffix or replacement character.
- Output order is deterministic and cannot be score-ranked.
- Maximum successful canonical JSON output: 16,384 UTF-8 bytes including the terminating LF. Exceeding it fails the complete query with `KNOWLEDGE_ERROR/81`.

## Frontmatter Grammar

[Clause S4-ALLOW-FRONTMATTER]

- Input may use LF or CRLF consistently; a bare CR or mixed LF/CRLF file fails closed. Both forms count as one logical line terminator and source line numbers are independent of terminator width.
- After removing an optional three-byte UTF-8 BOM, byte offset zero is the first byte after that BOM. The first logical line must be exactly `---` and must be terminated.
- The first later line exactly equal to `---` closes frontmatter. After BOM removal, the end-exclusive byte count immediately after its complete line terminator must be less than or equal to 8,192, and it must be logical line 64 or earlier. The first remaining byte has zero-based offset zero; no decode/re-encode measurement is used.
- Missing frontmatter means the first logical line is not the opening delimiter. Empty frontmatter means the closing delimiter immediately follows the opening delimiter. Missing, empty, late or unterminated frontmatter fails the complete query with `KNOWLEDGE_ERROR/81`.
- Opening delimiter, closing delimiter and every enclosed line are excluded from search, heading context and output.
- Any `---` line after the closing delimiter is ordinary body text.
- All per-file and aggregate byte counts include every byte after the optional BOM, including all line terminators and a final body line whether or not that final body line has a terminator. A closing delimiter without its required terminator is unterminated frontmatter.

## Canonical Output Fields

[Clause S4-ALLOW-DIGEST]

Top-level fields are exactly:

1. `schema`
2. `status`
3. `querySha256`
4. `resultSetSha256`
5. `matchCount`
6. `truncated`
7. `authority`
8. `network`
9. `writes`
10. `matches`

Each match contains exactly:

1. `path`
2. `line`
3. `heading`
4. `excerpt`
5. `authority`

`authority` is always `NAVIGATIONAL_NOT_AUTHORITY`; `network` and `writes` are always `NONE`.

The top-level constants and meanings are exact:

- `schema` is `EAIRA_PROJECT_KNOWLEDGE_QUERY_V1`.
- `status` is `KNOWLEDGE_QUERY_OK`.
- `matchCount` is the number of emitted matches and is in the range 0 through 8.
- `truncated` is `true` exactly when the complete bounded scan found more than eight matches.
- A match with no preceding body ATX heading has `heading` equal to the empty string.
- SHA-256 values are uppercase hexadecimal.
- Canonical JSON uses the listed field order, invariant decimal integers, lowercase JSON booleans, no insignificant whitespace and the existing `ContractCodec.Json` escaping rules.

Digest input is domain-separated and length-prefixed:

- `U32BE(n)` is exactly four unsigned big-endian bytes for an integer in the range 0 through 4,294,967,295;
- query digest input is `UTF8("EAIRA-KNOWLEDGE-QUERY-V1") || BYTE(0x00) || U32BE(queryUtf8Length) || normalizedQueryUtf8`;
- result-set digest input is `UTF8("EAIRA-KNOWLEDGE-RESULTSET-V1") || BYTE(0x00) || U32BE(matchCount) || BYTE(truncated ? 0x01 : 0x00) || framedMatches`;
- `framedMatches` contains exactly the emitted zero through eight matches in canonical output order and contains no non-emitted match;
- each framed match is `U32BE(pathLen)||UTF8(path)||U32BE(line)||U32BE(headingLen)||UTF8(heading)||U32BE(excerptLen)||UTF8(excerpt)||U32BE(authorityLen)||UTF8(authority)`, with every string length measured as the byte length of the immediately following exact UTF-8 payload.

Golden vectors are fixed:

- normalized query exact UTF-8 bytes `61` (`a`) produce query SHA-256 `AC87D75CD0EDF9A4DFEA57A1503749811E01E2362DFEF7B4503F4CDF029A6FAF`;
- zero emitted matches and `truncated=false` produce result-set SHA-256 `9F73299A3BBE37839C2F3B2105027A59E001B06ACC1216849FF6873437B05DC5`;
- one end-to-end emitted body match from the legal document bytes `---\nx: y\n---\na\n`, represented as `{path=docs/project/memory/README.md,line=4,heading="",excerpt="a",authority=NAVIGATIONAL_NOT_AUTHORITY}`, produces result-set SHA-256 `F1A152FD8406D4464E796603AF513B956D6F68F500FE95788D4D1D2D96019D73`;
- the corresponding zero-match success stdout is 362 bytes with SHA-256 `406C4FCF3040C1ACD9D1272DC098164FE17545A120C612AC403A6205B30A0019`;
- the corresponding one-match success stdout is 479 bytes with SHA-256 `7D425FFAA9DA666FB500B1D4FE0A395320132EDFE67BF715522EA957E73FFDF5`.

## Error Boundary

[Clause S4-ALLOW-CHANNELS]

Invalid CLI shape returns `INVALID_REQUEST/64`. Any root, file, state, identity, size, encoding, stability or schema failure returns sanitized `KNOWLEDGE_ERROR/81`. Errors contain no absolute path, file content, query text, handle value, SID, environment value or native diagnostic.

Output-channel bytes are exact:

- success: exit code 0; stdout is strict UTF-8 without BOM containing exactly the canonical success JSON followed by one LF byte `0x0A`; stderr is zero bytes;
- invalid CLI/query: exit code 64; stdout is exactly UTF-8 without BOM for `{"schema":"EAIRA_PROJECT_KNOWLEDGE_ERROR_V1","status":"INVALID_REQUEST","network":"NONE","writes":"NONE"}` followed by one LF; stderr is zero bytes;
- any knowledge/native/control failure: exit code 81; stdout is exactly UTF-8 without BOM for `{"schema":"EAIRA_PROJECT_KNOWLEDGE_ERROR_V1","status":"KNOWLEDGE_ERROR","network":"NONE","writes":"NONE"}` followed by one LF; stderr is zero bytes;
- stdout contains no CR, BOM, additional whitespace or trailing bytes.
