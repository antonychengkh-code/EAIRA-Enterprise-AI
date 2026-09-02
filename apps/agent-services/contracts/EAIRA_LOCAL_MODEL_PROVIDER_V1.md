# EAIRA Local Model Provider V1

Contract revision: 1

## Purpose

This contract defines a bounded local-model path for the M4 Slice 2 task-intake CLI. It connects only to a separately running, human-controlled Ollama listener at exact IPv4 loopback. It does not authorize external providers, credentials, process launch, service activation, persistence, or Windows changes.

## Exact selection

    EAIRA.AgentTask.Cli.exe --provider ollama-local --model qwen3:4b --trace <32-uppercase-hex> --goal <1-to-512-character-goal>

The exact provider ID is ollama-loopback-v1, base URI is http://127.0.0.1:11434/, paths are api/tags and api/chat, model is qwen3:4b, and full digest is 359d7dd4bcdab3d86b87d73ac27966f4dbb9f5efdfcc75d34a8764a09474fae7.

No endpoint input, alternate order, implicit model, environment configuration, response file, hostname, IPv6 address, proxy, redirect, credential, or process-launch fallback is accepted.

## Trust statement

The local Ollama API is unauthenticated. Exact name/full-digest checks before and after generation are consistency controls under a trusted-local-host assumption; they are not cryptographic model pinning and do not prevent another local process from impersonating the listener. The EAIRA client reports network=LOOPBACK_ONLY and writes=NONE; these claims do not cover Ollama daemon logs, caches, model storage, or provider-side network behavior.

## Request lifecycle

One non-static provider and cache belong to one accepted intake request:

1. Start one shared 60-second cancellation budget.
2. Perform exactly one tags preflight and require exactly one matching name/full-digest record.
3. Execute the pipeline with at most two successful cached completion entries.
4. Key entries ordinally by length-prefixed provider ID, model, full digest, Agent role, and exact prompt.
5. Cache only fully validated results; never cache failures or partial responses.
6. Reject a third distinct completion key without a third chat request.
7. Perform exactly one tags postflight before canonical output.
8. Dispose all provider, transport, HTTP, stream, and cancellation resources.

A PASS lifecycle has two tags and two chat calls. A DENIED lifecycle has two tags and one chat call. Semantic replay for an existing key adds no chat call. Successful canonical local output includes only these observed call counts plus boolean preflight/postflight digest-validation results; it includes no body, prompt, process, path, or credential detail.

## Canonical chat body

The fixed Ollama role is user. The restrictive generation instruction and EAIRA role are represented only in content as LF-separated strings:

    EAIRA_OUTPUT_POLICY=PLAIN_TEXT_MAX_128_UTF16_NO_EXPLANATION
    EAIRA_AGENT_ROLE=<Planning|Operations>
    PROMPT=<exactPrompt>

The byte-exact UTF-8/no-BOM JSON property order is:

    {"model":"qwen3:4b","messages":[{"role":"user","content":"<escaped-content>"}],"stream":false,"think":false,"options":{"temperature":0,"seed":42,"num_predict":32}}

There is no non-string whitespace or final newline. The body is at most 16,384 bytes. Existing canonical JSON escaping applies; malformed UTF-16 and roles other than Planning or Operations fail closed. The requested 128-unit output policy and 32-token generation cap shape generation but are not trusted enforcement; the client still rejects normalized output above 512 UTF-16 code units.

## HTTP and response boundary

- Proxy, redirects, cookies, default or explicit credentials, preauthentication, client certificates, and decompression are disabled.
- Only HTTP 200 application/json is accepted. Content-Type has either zero parameters or exactly one charset parameter whose value is UTF-8 case-insensitively; every additional or different parameter, media type, charset, or content encoding is rejected.
- ResponseHeadersRead and a shared cancellation token are mandatory.
- Content-Length above 65,536 is rejected before reading; bounded incremental reading rejects byte 65,537.
- Unbounded string/byte helpers and response-body logging are prohibited.
- UTF-8 uses throwing decode; BOM, invalid UTF-8, and unpaired surrogates are rejected.

The local parser permits depth 8, 512 nodes, 32,768 UTF-16 code units per string, and 65,536 input bytes. It rejects duplicates, comments, trailing commas, invalid numbers or escapes, unknown schema members, trailing documents, invalid Unicode, streaming responses, tool calls, images, and thinking output.

Tags contains exactly top-level models. Each item requires string name and digest and permits only documented bounded fields. The selected name must occur exactly once with the exact digest. Chat requires exact model, a message containing only assistant role and content, and done=true. Only enumerated bounded timing/count metadata is optional.

## Output normalization

Reject all C0/C1 controls except TAB, CR, and LF. Collapse maximal runs of ASCII space, TAB, CRLF, lone CR, and lone LF to one ASCII space, trim produced edge spaces, then reject empty, malformed UTF-16, or more than 512 UTF-16 code units.

No provider body, exception text, status description, prompt, credential, or endpoint detail enters diagnostics.

## Exit contract

| Condition | Status | Exit |
| --- | --- | ---: |
| malformed selection, trace, goal, or arguments | INVALID_REQUEST | 64 |
| Guard denial | DENIED | 77 |
| existing disabled real selection | PROVIDER_BLOCKED | 78 |
| local timeout, listener, protocol, size, UTF, JSON, model, digest, cache, or output failure | LOCAL_PROVIDER_ERROR | 79 |
| completed allowed pipeline | PASS | 0 |

Exit 79 emits only the fixed LocalProviderException record with network=LOOPBACK_ONLY and writes=NONE.

## Compilation boundary

Among runtime and release outputs, OllamaLoopbackTransport.cs and System.Net.Http.dll are compiled only into EAIRA.AgentTask.Cli.exe. Five services, functional harness, existing intake harness, and fake-provider harness contain zero network or stream metadata references. The fake harness injects byte responses and never opens a socket. A separately compiled, offline-only transport-policy harness exercises HTTP/status/header/length and bounded-stream helpers without opening a socket; it is test evidence and is never copied into the unsigned release.

Before staging, the release profile and verifier bind exact compiler-emitted CLI TypeRef/MemberRef signatures and counts. Two isolated builds must be byte-identical, all offline tests must pass, and the live loopback probe must finish inside the unchanged 60-second budget. Signing eligibility remains false.
