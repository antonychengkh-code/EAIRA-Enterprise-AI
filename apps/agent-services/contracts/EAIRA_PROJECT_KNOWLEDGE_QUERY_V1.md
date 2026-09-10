# EAIRA Project Knowledge Query V1

The command is exactly `EAIRA.ProjectKnowledge.Cli.exe --root <absolute-EAIRA-root> --query <literal-query>`.

It searches only the seven ordered project-memory navigation/schema files fixed by the Slice 4 allowlist. It performs no directory enumeration, model/provider call, network access or write. Returned material is `NAVIGATIONAL_NOT_AUTHORITY`.

## Closed input and platform contract

The repository root is one canonical absolute DOS path. The implementation pins the root, `docs`, `docs/project` and `docs/project/memory`, then opens exactly these seven required leaves in order: `README.md`, `DECISION_INDEX.md`, `DISCOVERY_INDEX.md`, `PROCEDURE_INDEX.md`, `OPEN_QUESTIONS.md`, `STABILITY_CHECKLIST.md`, and `MEMORY_SCHEMA.md`. No eighth path, caller-supplied file, traversal, enumeration, link following, IPC, service, credential or provider operation is permitted.

Each directory/file handle must return its exact requested canonical path. Local objects use no reparse attribute and tag zero. Hydrated Cloud directories use reparse tag `0x9000E01A`; hydrated Cloud files use `0x9000601A`. Offline, RecallOnOpen, RecallOnDataAccess, type mismatch, tag mismatch, identity replacement or any probe/content-before/content-after metadata change fails the complete query. Content opens use read-only, read-share-only, open-existing, sequential-scan and no-recall semantics. There is exactly one bounded physical read per leaf; content and probe handles close immediately, and pinned ancestors close in reverse order. Any close failure without a prior failure changes the result to `KNOWLEDGE_ERROR`.

## Query, parsing and budgets

The query is NFKC-normalized, contains 1–64 Unicode scalar values, and contains no C0 or C1 control. Matching is literal `OrdinalIgnoreCase`; regex, glob, wildcard, Markdown, wikilink and instruction-shaped bytes have no special meaning.

Strict UTF-8 is mandatory. One leading UTF-8 BOM is removed; every later BOM is content. Limits are 65,539 physical bytes, 65,536 post-BOM bytes per file, 262,144 post-BOM bytes total, 1,024 UTF-8 bytes per logical line, and 4,096 logical lines per file. A file uses LF or CRLF consistently. Bare CR and mixed newlines fail closed.

Every file has non-empty frontmatter: the first terminated line is `---`, a later terminated `---` closes it by logical line 64 and end-exclusive post-BOM byte 8,192. Missing, empty, late or unterminated frontmatter fails closed. Frontmatter is never searched or returned.

## Result and digest contract

Search order is file order then ascending one-based line. At most eight matches are emitted; scanning continues to set `truncated` exactly. ATX headings are column-one ASCII `#` markers of levels 1–6 followed by end-of-line or one ASCII space. Heading and excerpt trim only ASCII space/tab and are truncated only on complete Unicode scalar boundaries to 160 and 240 UTF-8 bytes.

Success fields are exactly `schema`, `status`, `querySha256`, `resultSetSha256`, `matchCount`, `truncated`, `authority`, `network`, `writes`, and `matches`; each match contains exactly `path`, `line`, `heading`, `excerpt`, and `authority`. SHA-256 inputs use the domain-separated, U32BE length-prefixed framing fixed by the allowlist. Successful canonical JSON plus its LF is at most 16,384 UTF-8 bytes and contains no absolute root, raw file, frontmatter, per-file digest, handle or credential.

## Exact channels

Success exits 0 and writes one UTF-8-without-BOM canonical JSON line to stdout. Invalid argv or query emits exactly the `EAIRA_PROJECT_KNOWLEDGE_ERROR_V1/INVALID_REQUEST` object and exits 64. Repository, native, parsing, integrity or budget failure emits exactly the `EAIRA_PROJECT_KNOWLEDGE_ERROR_V1/KNOWLEDGE_ERROR` object and exits 81. Stderr is always empty; no partial result is emitted.

The query, file-state, BOM, frontmatter, line, search, truncation, canonical JSON, digest, output-budget and error-channel rules are controlled by:

- `docs/project/planning/EAIRA_M4_SLICE4_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY_ALLOWLIST.md`;
- `docs/project/planning/EAIRA_M4_SLICE4_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY_THREAT_MODEL.md`; and
- `docs/project/planning/EAIRA_M4_SLICE4_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md`.
