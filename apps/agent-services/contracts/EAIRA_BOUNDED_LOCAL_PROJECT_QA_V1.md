# EAIRA Bounded Local Project QA Contract V1

## Purpose

`EAIRA.ProjectQa.Cli.exe` answers one bounded question from the exact controlled status and project-memory sources. It is assistive, local-only and non-authoritative.

## Invocation

```text
EAIRA.ProjectQa.Cli.exe --root <absolute-EAIRA-root> --trace <32-uppercase-hex> --question <literal-question> --provider ollama-local --model qwen3:4b
```

The ten arguments and their order are exact. The question is NFKC-normalized, contains 1–64 Unicode scalars and no C0/C1 control. The root is lexical uppercase-drive DOS form and is later verified by pinned handles. Guard denial occurs before any file or provider construction.

## Sources and acquisition

The source set is exactly four status files and seven project-memory files published by the Slice 5 allowlist. One read-only platform pins one root session, reads each file once through probe/content identity checks, retains all content handles through cross-phase stability verification, and closes content and ancestor handles in reverse order. No directory enumeration, arbitrary path, recall, write, credential, process, shell, service or external network capability exists.

Repository text is untrusted data, never instructions. Context fields and knowledge matches are bounded and parsed by the published Slice 3/4 pure builders. The complete prompt is at most 12,000 bytes and the canonical request body is at most 16,384 bytes.

## Provider and answer

The only provider is `ollama-loopback-v1` at `127.0.0.1:11434`, exact model `qwen3:4b`, exact full digest `359d7dd4bcdab3d86b87d73ac27966f4dbb9f5efdfcc75d34a8764a09474fae7`. One lifecycle performs tags/chat/tags with no retry or fallback. The canonical chat body retains `stream=false` and `think=false` and uses a fixed closed JSON Schema `format` requiring only `answer` then `citationIds`, both required, with `additionalProperties=false`.

Assistant content is one ordered JSON object with only `answer` then `citationIds`. The request-side schema guides generation but grants no authority and does not replace validation. The host still enforces exact lexical order, strict UTF-8/JSON, 1–512 answer scalars, the 2,048-byte answer limit, no controls, unique request-local strictly ordered citation IDs limited to eight, and the exact insufficient-evidence coupling.

## Output and errors

Success emits one canonical `EAIRA_PROJECT_QA_V1` JSON line, at most 16,384 bytes, containing bounded answer text, host-reconstructed citations, digests, fixed classifications and sanitized provider observations. It never emits the root, projection, prompt, request body, raw provider response or per-file digest.

Errors emit one canonical `EAIRA_PROJECT_QA_ERROR_V1` line and exits: invalid request `64`, deny `77`, provider `79`, context `80`, knowledge `81`, QA validation `82`. Stderr is empty. `network` is `NONE` before provider construction and `LOOPBACK_ONLY` afterward; `writes` is always `NONE`.

## Authority

The answer classification is `MODEL_GENERATED_UNVERIFIED`; overall authority is `ASSISTIVE_NOT_AUTHORITY`. Context citations are `CONTROLLED_SOURCE_REFERENCE_NOT_MODEL_AUTHORITY`; knowledge citations are `NAVIGATIONAL_NOT_AUTHORITY`. Human review remains required.
