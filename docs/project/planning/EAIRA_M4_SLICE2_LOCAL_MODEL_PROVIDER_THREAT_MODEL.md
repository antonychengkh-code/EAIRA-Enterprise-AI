# EAIRA M4 Slice 2 Local Model Provider Threat Model

## Boundary

The EAIRA CLI may contact only http://127.0.0.1:11434/ through fixed api/tags and api/chat paths. The local Ollama API is unauthenticated; another local process could impersonate it. Model name/full-digest preflight and postflight are consistency checks, not cryptographic pinning.

| Threat | Control | Residual risk |
| --- | --- | --- |
| Endpoint injection or SSRF | No endpoint input; compiled numeric IPv4 loopback URI | Host compromise can replace the listener |
| DNS, proxy, redirect escape | No DNS name; proxy and redirects disabled | Ollama daemon behavior is outside client control |
| Credential leakage | No auth/default credential/cookie/client-certificate path | None inside the bounded client path |
| Model/tag substitution | Exact name/full digest before and after generation; duplicates rejected | Same local endpoint is trusted for identity |
| Oversized/malformed response | ResponseHeadersRead, 65,536-byte bounded stream, strict UTF-8/JSON | Provider can consume time until deadline |
| Long or controlled output | Restrictive 128-unit request; client hard-rejects over 512 or controls | Generation instruction is not enforcement |
| Semantic replay network amplification | Request-local two-entry successful cache | No cache across requests |
| Timeout/resource retention | One 60-second token; deterministic disposal | Provider daemon side effects are not measured |
| Capability smuggling | Source partition plus frozen compiled TypeRef/MemberRef signatures/counts | Compiler/toolchain remains a trusted input |
| Secret or body disclosure | Fixed exit 79 and no body/exception logging | Canonical successful result contains validated model text |

## Fail-Closed Rule

Any listener, timeout, status, content type, encoding, JSON, schema, name, digest, response role/completion, cache, normalization, or output failure returns only LOCAL_PROVIDER_ERROR with exit 79. Limits cannot be weakened dynamically.

## Non-Claims

This slice does not prove Ollama binary/process identity at request time, model cryptographic immutability, no daemon writes, no daemon external network, hostile same-host isolation, production readiness, signing readiness, or Windows-service integration.
