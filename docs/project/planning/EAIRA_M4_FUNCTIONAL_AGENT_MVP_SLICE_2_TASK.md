# EAIRA M4 Functional Agent MVP Slice 2 Task

## Task

Task ID: M4-FUNCTIONAL-AGENT-MVP-SLICE-2

Implement and publish one bounded local-model provider for the existing task-intake CLI while retaining deterministic mock behavior and fail-closed disabled external-provider behavior.

## Implemented Candidate

- Exact selection: ollama-local with model qwen3:4b.
- Exact EAIRA-client network boundary: IPv4 loopback 127.0.0.1:11434 only.
- Exact model name/full-digest checks before and after generation under a trusted-local-host assumption.
- One request-scoped provider, two-entry successful-result cache, and no cross-request cache.
- Strict 60-second lifecycle, 16,384-byte request, 65,536-byte response, strict UTF-8/JSON, and 512 UTF-16 output boundaries.
- Fixed LOCAL_PROVIDER_ERROR exit 79 without exception or response-body disclosure.
- CLI-only HTTP transport; five services and all non-live harnesses retain zero network/stream metadata references.

## Validation

- Functional harness: 34 tests per build.
- Existing intake harness: 15 tests per build.
- Local-provider fake harness: 41 tests per build.
- Offline no-socket transport-policy harness: 10 tests per build.
- Two isolated deterministic builds are byte-identical.
- Frozen CLI metadata policy: 18 TypeRefs and 35 MemberRefs.
- The manifest binds all 22 candidate paths plus exact reference-assembly hashes and versions.
- A fresh live denial probe and its sanitized external evidence are required before repeating independent Gate 9.
- Generated manifest, CLI, and report hashes are external validation evidence and are intentionally not embedded in this repository-bound candidate.

## Exclusions

No external provider, credential, provider install/download/start, service routing, persistence, Windows/ACL/account/group change, signing, or production activation. Ollama daemon behavior is outside the EAIRA-client side-effect claim. Gate 25 and signing eligibility remain incomplete/false.

## Current Gate

The 22-path working-tree candidate is uncommitted and unstaged. It requires independent implementation review before any staging.
