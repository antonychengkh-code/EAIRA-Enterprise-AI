# EAIRA Read-Only Project Context V1

Contract revision: 2

## Purpose

Define the opt-in M4 Slice 3 request-local project-context snapshot used only by Planning. The feature is read-only, has no discovery surface, persists nothing and treats all loaded text as untrusted data rather than instructions or authority.

## Exact allowlist

The loader accepts one explicit absolute Windows repository root and reads exactly these relative paths in this order:

1. `docs/project/status/CURRENT_STATUS.md`;
2. `docs/project/status/TODAY_OBJECTIVE.md`;
3. `docs/project/status/ACTIVE_TASK.yaml`; and
4. `docs/project/status/AGENT_CONTEXT_VERSION.yaml`.

The caller cannot add, remove, reorder or substitute a path. Directory enumeration, wildcard matching, Git discovery, alternate data streams, UNC/device paths, short names and environment expansion are prohibited.

## Handle-first boundary

- Root and every hard-coded ancestor are opened read-only with `FILE_SHARE_READ`, `OPEN_EXISTING`, `OPEN_REPARSE_POINT`, `BACKUP_SEMANTICS` and `OPEN_NO_RECALL`, validated and pinned until the request ends.
- A final-file probe uses `OPEN_REPARSE_POINT | OPEN_NO_RECALL`; its identity must equal the subsequently opened content handle.
- Content is opened once with `SEQUENTIAL_SCAN | OPEN_NO_RECALL`, read sequentially once, and checked for same-handle metadata stability afterward.
- Exact canonical full-path equality, file identity, length, last-write time, attributes and tag are validated. All handles close on success or failure.
- Only tag zero or hydrated OneDrive tags `0x9000E01A` for directories and `0x9000601A` for files are accepted. Offline, recall-on-open, recall-on-data-access, name-surrogate and every other non-zero tag fail closed. The loader never requests hydration.

The implementation uses only six private static `kernel32.dll` entry points declared directly on the private sealed Win32 platform: `CreateFileW`, `GetFileInformationByHandle`, `GetFileInformationByHandleEx`, `GetFinalPathNameByHandleW`, `ReadFile` and `CloseHandle`.

## Content and schema limits

- Exactly four files, at most 262,144 bytes each and 1,048,576 bytes total.
- Strict UTF-8 without BOM; malformed sequences fail closed.
- Markdown requires every exact controlled `##` heading once. `TODAY_OBJECTIVE.md` must include its controlled `Version`; it is validated against `AGENT_CONTEXT_VERSION.yaml` but is not added to the fixed 27-field projection.
- Projected Markdown lists accept only one maximal run of top-level lines beginning exactly `- `; indented continuation lines and nested items fail closed.
- YAML projects only the six contracted required keys. Canonical quoted keys and the legacy unquoted harness form are accepted, and every visible top-level key must be unique. Additional top-level status fields remain opaque and unprojected unless the exact key is reserved to another controlled source; a cross-owner reserved key, malformed required scalar/list, absence or duplication fails closed. `Last Updated` is intentionally required and independently source-qualified in both YAML sources.
- Multi-entry Markdown `Current Milestone` and `Milestone` sections are serialized as all non-empty controlled lines in source order joined by LF; other selected paragraph/list rules remain fixed.
- The canonical projection contains exactly 27 source-qualified, length-framed fields in the reviewed fixed order and is at most 10,000 UTF-8 bytes.
- The complete provider request remains subject to the existing 16,384-byte canonical request limit. Nothing is truncated, summarized, retried or split.

Raw bytes are hashed before parsing. Aggregate SHA-256 uses the domain `EAIRA_M4_SLICE3_CONTEXT_BUNDLE_V1` plus NUL and the reviewed big-endian path/length/digest framing. YAML list hashes use unsigned 32-bit big-endian element lengths. The output carries only aggregate and projection evidence; per-file identities and digests are never emitted.

## Planning prompt and semantic isolation

The exact prompt is:

```text
EAIRA_M4_SLICE3_PLANNING_CONTEXT_V1
GOAL=<UTF-8-byte-count>:<exact-goal>
PROJECTION=<UTF-8-byte-count>:<exact-projection>
```

Before provider construction or lifecycle start, the canonical Planning request is built once as a 16,384-byte preflight. Planning receives the exact prompt. The context Planning result retains only `PLAN_CANDIDATE_CONTEXT_REDACTED`, a domain-separated SHA-256 summary of provider output, and the fixed step count; provider text is never serialized into the AgentResult chain. A content-free `ContextPlanningSeal` retains only task digest, Planning result digest and provider ID. Guard, Operations, Verification and Audit receive no root, path, raw text, projection, Planning prompt or provider-return text. Operations continues to call the provider only with the Guard result digest.

## Command-line forms

Context is enabled only by appending the root last:

```text
EAIRA.AgentTask.Cli.exe --provider mock --trace <TRACE> --goal <GOAL> --context-root <ABSOLUTE_ROOT>
EAIRA.AgentTask.Cli.exe --provider ollama-local --model qwen3:4b --trace <TRACE> --goal <GOAL> --context-root <ABSOLUTE_ROOT>
```

The `real` provider cannot be combined with context. Legacy six-argument mock/real and eight-argument local forms remain context-free and byte compatible.

## Canonical result and failure

Successful context-enabled output appends a `context` object after `result` and before provider observations with fields in this order: `allowlistId`, `aggregateSha256`, `projectionBytes`, `projectionSha256`, `provenance`, `classification`.

Every acquisition, schema, digest, projection or preflight failure returns exit code `80` and exactly:

```json
{"schemaVersion":1,"status":"CONTEXT_ERROR","errorType":"ProjectContextException","network":"NONE","writes":"NONE","context":null}
```

If static Guard preauthorization denies a context-enabled goal, no handle, provider factory, lifecycle or model call occurs. Exit code is `77`; `context` is exactly `{"state":"NOT_READ_GUARD_DENY"}` and the provider ID is statically mapped to `mock-v1` or `ollama-loopback-v1`.

No exception message, Win32 error, root, absolute path, content fragment, prompt or per-file evidence crosses the CLI boundary.

## Exclusions

This contract authorizes no runtime write, persistence, directory listing, listener, child process, shell, credential, external provider, Windows service activation or policy override. Project memory is navigational only and cannot override the four controlled sources or Human Project Owner authority.
