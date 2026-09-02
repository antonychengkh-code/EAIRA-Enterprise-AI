# EAIRA M4 Functional Agent MVP Slice 2 Scope Decision

## Decision

Selected direction: SLICE2_A_LOCAL_MODEL_PROVIDER.

Use the existing local Ollama installation and qwen3:4b model through a strictly bounded loopback-only task-intake path. Preserve mock execution and the disabled real/external selection.

## Evidence Basis

Readiness packages R2, R3, and R4 passed fresh independent review with P0=0 and P1=0. The first Gate 9 implementation review failed closed with P0=0, P1=3, and P2=2. Its bounded remediation candidate passes 34 functional tests, 15 intake tests, 41 fake-provider tests, 10 no-socket transport-policy tests, five service self-tests, exact 22-path/reference evidence binding, and frozen 18-TypeRef/35-MemberRef CLI metadata closure. A fresh live probe and repeat independent Gate 9 remain required before staging.

## Scope

Exactly 22 repository paths: seven new and fifteen modified. Generated binaries, manifests, live bodies, tool caches, credentials, and the three unrelated Claude paths are excluded.

## Authority Boundary

This decision authorizes the bounded product candidate and its conditional gate sequence only. It does not establish external-provider use, credentials, Windows-service task routing, persistence, account/group/membership/ACL changes, signing, certificate/HSM activity, production activation, Annex Field movement, blocker closure, or Gate 25 completion.

## Next Decision

Independent implementation review must pass before exact staging. A P0/P1 finding stops the sequence and returns to bounded remediation.
