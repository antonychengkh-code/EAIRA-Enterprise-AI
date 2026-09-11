# EAIRA M4 Slice 5 Bounded Local Project QA Readiness Package

## Package Identity

- Decision: `SLICE5_A_BOUNDED_LOCAL_PROJECT_QA`
- Revision: 5.2
- Package state: `SLICE5_A_R5R2_STRUCTURED_OUTPUT_REMEDIATION_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW`
- Repository baseline: `b4a871ffa9b18c86179a79d3b876fd314f853f7b`
- Date: 2026-09-11

## Evidence Basis

- M4 charter: `docs/project/milestones/EAIRA_M4_FUNCTIONAL_AGENT_MVP_PROJECT_CHARTER.md`.
- Slice 2 product publication: `d43a4bc170df38e29f6115e927ad2c07190da821`.
- Slice 2 controlled-state synchronization: `b3bd69683ae873be59bf5a78e5df4dd6a4e71eec`.
- Slice 3 product publication: `a0e172f34ebc09f76e1bd894d680614ed901113d`.
- Slice 3 controlled-state synchronization: `7e1c1d04e6b92fcbf89f0b1268d189da9892071b`.
- Slice 4 product publication: `8fefd6b7bb2369b80724270b64e74d33a7e1aa9f`.
- Slice 4 post-publication controlled-state/HANDOFF synchronization: `b4a871ffa9b18c86179a79d3b876fd314f853f7b`.
- Slice 4 final publication verification: `PUBLICATION_VERIFIED=YES`, `GATE_SEQUENCE_COMPLETE=YES`, `P0=0`, `P1=0`, `P2=0`.
- Project-memory validation at the baseline: 16 required files and 9 frontmatters pass.

This evidence establishes repository-recorded components and contracts. It does not establish that Ollama is currently running, that the R5R2 composed QA candidate has passed fresh sealed verification, or that a live answer is acceptable.

## Product Surface

One separate local executable:

```text
EAIRA.ProjectQa.Cli.exe --root <absolute-EAIRA-root> --trace <32-uppercase-hex> --question <literal-question> --provider ollama-local --model qwen3:4b
```

The proposed execution is one request-local composition:

```text
exact CLI validation
  -> static Guard preauthorization
  -> one pinned root/session
  -> Slice 3 exact context projection
  -> Slice 4 exact literal knowledge query
  -> bounded length-framed QA prompt
  -> exact Ollama preflight
  -> at most one QA chat
  -> exact Ollama postflight
  -> strict answer/citation-ID validation
  -> host-reconstructed canonical result
```

Any error fails the whole request. No fallback, retry, partial result, ungrounded answer, external provider or write is allowed.

## Exact Current Candidate Boundary

[Clause S5-READY-PATHS]

The current working-tree candidate is the exact 15-path manifest frozen in `EAIRA_M4_SLICE5_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md`. It contains the five planning/context paths, the exact-design document, contract and README, three product-source paths, the dedicated harness, release verifier and release profile. R5 changes only the nine structured-output remediation paths identified by that manifest; the other six paths retain their reviewed predecessor bytes. No controlled status artifact, HANDOFF, `.obsidian` or excluded untracked path belongs to this candidate. The candidate is not staged.

## Readiness Prerequisites

| ID | Prerequisite | Current state |
| --- | --- | --- |
| `S5-RP-01` | Slice 2 loopback-provider product and contract published | PASS |
| `S5-RP-02` | Slice 3 exact four-file context loader/projection published | PASS |
| `S5-RP-03` | Slice 4 exact seven-file literal knowledge query published | PASS |
| `S5-RP-04` | Slice 4 post-publication synchronization independently verified | PASS |
| `S5-RP-05` | Human Project Owner selected `SLICE5_A_BOUNDED_LOCAL_PROJECT_QA` | PASS |
| `S5-RP-06` | Exact eleven-file closed source list | ESTABLISHED IN REVIEWED PREDECESSOR DESIGN; RETAINED BY R5 |
| `S5-RP-07` | Exact provider/model/digest/loopback boundary | ESTABLISHED IN REVIEWED PREDECESSOR DESIGN; RETAINED BY R5 |
| `S5-RP-08` | Question grammar and source/citation IDs | ESTABLISHED IN REVIEWED PREDECESSOR DESIGN; RETAINED BY R5 |
| `S5-RP-09` | Prompt-injection and data-leakage threat model | ESTABLISHED; R5 STRUCTURED-OUTPUT ABUSE CASE ADDED |
| `S5-RP-10` | Stale Slice 4 current-context paragraph | CORRECTED IN CURRENT 15-PATH WORKING-TREE CANDIDATE |
| `S5-RP-11` | Unified root/session ownership and cleanup topology | ESTABLISHED IN EXACT DESIGN; RETAINED BY R5 |
| `S5-RP-12` | Byte-exact prompt framing and 16,384-byte request proof | R5 VECTORS ESTABLISHED; FRESH DISCOVERY REQUIRED |
| `S5-RP-13` | Byte-exact answer/result schemas, digests and golden vectors | R5 SCHEMA AND VECTORS ESTABLISHED; FRESH DISCOVERY REQUIRED |
| `S5-RP-14` | Closed source/metadata/caller/verifier inventory | PREDECESSOR CLOSED; R5 PROFILE RECALIBRATION REQUIRED |
| `S5-RP-15` | Implementation and A/B evidence | R5 PREDECESSOR SEALED PASS; STRUCTURED-OUTPUT REMEDIATION REQUIRES NEW DISCOVERY/PROFILE/SEALED EVIDENCE |
| `S5-RP-16` | Live-loopback evidence | TWO SINGLE-CALL ATTEMPTS SAFELY FAILED CLOSED AT `PROJECT_QA_ERROR/82`; R5 PRODUCT REMEDIATION REQUIRED |
| `S5-RP-17` | Repository recording | NOT ELIGIBLE UNTIL R5 SEALED AND LIVE REVIEWS CLOSE |

## Exact-Design Questions That Must Close

[Clause S5-READY-DESIGN-QUESTIONS]

The exact design and changed-path manifest proves:

1. how one root/session preserves identity across the Slice 3 and Slice 4 phases without adding a second native implementation or substitution window;
2. whether the published provider can carry the strict QA answer JSON without weakening existing task-intake behavior or adding an unreviewed role/message surface;
3. the exact prompt bytes, length framing, domain separation and complete canonical Ollama request body at below/at/above limits;
4. the exact insufficient-evidence answer and when zero citations are legal;
5. the exact answer parser, citation-ID subset/uniqueness rules and host-side citation reconstruction;
6. the exact outer canonical JSON fields/order, digest inputs, byte budgets, stdout/error bytes and golden vectors;
7. how raw projection, raw prompt and raw provider content are prevented from entering downstream result, diagnostic or log objects;
8. how the separate QA executable's source/reference/TypeRef/MemberRef/MethodDef/P/Invoke/caller graph is closed while the existing Slice 1-4 binaries remain contract-compatible;
9. how the verifier proves one chat, no retry, no fallback, no external endpoint, no write/persistence and no model-supplied citation metadata; and
10. how deterministic mock evidence and nondeterministic live-loopback evidence are separated without treating model text as byte-reproducible.

An unresolved answer is a P1 design blocker. Observation of current code is not a substitute for a frozen exact design.

## Required Evidence Classes for a Later Implementation

[Clause S5-READY-EVIDENCE]

The implementation evidence package must include:

- exact source/input manifest with hashes and ordered paths;
- pinned compiler identity and deterministic clean A/B builds;
- unchanged published Slice 1-4 regression suites;
- dedicated CLI, question, root/session, context, knowledge, prompt, provider, answer-schema, citation and output tests;
- the complete stable-name abuse matrix from the threat model;
- compile-success-and-verifier-rejection specimens for every capability-widening case;
- static source/reference/metadata/network/write/process/shell/dynamic-code closure;
- byte-exact success and error channels;
- zero-open/zero-provider evidence for Guard denial;
- request counters proving no retry/fallback and at most one QA chat;
- sanitized evidence with no prompt, raw source, provider body, absolute root, credential or sensitive diagnostic; and
- a separate live-loopback result that records bounded behavior but makes no deterministic-answer or daemon-isolation claim.

## Gate Sequence

[Clause S5-READY-GATES]

The adopted core lifecycle is exactly these 21 Gate identifiers, in this order:

1. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_SCOPE_PACKAGE_REVIEW`.
2. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST_AUTHORIZATION`.
3. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_EXACT_IMPLEMENTATION_DESIGN_REVIEW`.
4. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_BOUNDED_IMPLEMENTATION_AND_OFFLINE_EVIDENCE_AUTHORIZATION`.
5. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_IMPLEMENTATION_AND_ABUSE_REVIEW`.
6. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_LIVE_LOOPBACK_VALIDATION_AUTHORIZATION`.
7. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_LIVE_LOOPBACK_VALIDATION_REVIEW`.
8. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_EXACT_STAGING_AUTHORIZATION`.
9. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_STAGED_SNAPSHOT_REVIEW`.
10. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_EXACT_COMMIT_AUTHORIZATION`.
11. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_POST_COMMIT_VERIFICATION`.
12. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_EXACT_NORMAL_PUSH_AUTHORIZATION`.
13. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_POST_PUSH_PUBLICATION_VERIFICATION`.
14. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_POST_PUBLICATION_CONTROLLED_STATE_AND_HANDOFF_SYNCHRONIZATION_AUTHORIZATION`.
15. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_POST_PUBLICATION_CONTROLLED_STATE_AND_HANDOFF_SYNCHRONIZATION_REVIEW`.
16. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_POST_PUBLICATION_SYNCHRONIZATION_EXACT_STAGING_AUTHORIZATION`.
17. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_POST_PUBLICATION_SYNCHRONIZATION_STAGED_SNAPSHOT_REVIEW`.
18. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_POST_PUBLICATION_SYNCHRONIZATION_EXACT_COMMIT_AUTHORIZATION`.
19. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_POST_PUBLICATION_SYNCHRONIZATION_POST_COMMIT_VERIFICATION`.
20. `SEPARATE_PROJECT_OWNER_EAIRA_M4_SLICE5_A_POST_PUBLICATION_SYNCHRONIZATION_EXACT_NORMAL_PUSH_AUTHORIZATION`.
21. `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_POST_PUBLICATION_SYNCHRONIZATION_POST_PUSH_PUBLICATION_VERIFICATION`.

The initial Gate 1 review returned `CANNOT_CLOSE`, `P0=0`, `P1=2`, `P2=0`. R2 closed both findings, but its review returned `CANNOT_CLOSE`, `P0=0`, `P1=1`, `P2=1` because the scope acceptance boundary created a circular implementation prerequisite and used one production-ambiguous phrase. The Project Owner's authorization to complete all core Gates and add required steps authorizes the bounded R3 remediation represented here. Its added review Gate is `SEPARATE_INDEPENDENT_EAIRA_M4_SLICE5_A_R3_SCOPE_PACKAGE_REVIEW`; after it closes, the lifecycle resumes at core Gate 2. Any later P0/P1 adds exactly a Project Owner remediation authorization Gate and a fresh independent remediation-review Gate without renumbering, merging or consuming a core Gate.

Any P0 or P1 stops fail-closed. A remediation creates a new candidate and requires a fresh independent review. No Gate is satisfied merely because it appears in this list.

## Retained Boundaries

- Product source, contract, harness, verifier and profile are part of the current 15-path implementation candidate; only manifest-authorized R5 deltas are permitted.
- The exact eleven project files remain the runtime read allowlist enforced by the candidate; documentation review itself does not authorize reading project-file contents.
- External providers, credentials and internet endpoints remain prohibited.
- Runtime writes, persistence, telemetry, service/IPC routing and operational activation remain prohibited.
- Windows, account, group, membership, directory, ACL, encryption, backup, certificate, HSM and signing state remain unchanged.
- Production-signing Gate 24 remains partial; Gate 25 and external signing eligibility remain incomplete.
- Field 8, Field 9, Category 14, B2-MAN-007 counts, Annex blockers and the all-fields-resolved gate do not move.
- The retained long checkpoint-ref maintenance finding is not in scope.
- The current candidate remains unstaged; staging, commit and push occur only at their ordered core Gates after fresh sealed and live reviews close.

## Current Determination

`SLICE5_A_R5R2_STRUCTURED_OUTPUT_REMEDIATION_CANDIDATE_READY_FOR_INDEPENDENT_REVIEW`

The predecessor sealed implementation passed with manifest SHA-256 `113888B17C2690CB98326E4F5A740ED25E364EA365B38617E43F98928DEB3256`, but two separately authorized live calls returned the same sanitized `PROJECT_QA_ERROR/82` after successful provider round trips. R5 replaces only the legacy JSON-mode shorthand with a fixed closed JSON Schema. New QA-only discovery, profile calibration, clean sealed A/B evidence, one new-baseline live validation and independent reviews are mandatory before staging.
