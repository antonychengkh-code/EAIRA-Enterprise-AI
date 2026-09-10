# EAIRA M4 Slice 4 Bounded Read-Only Project Knowledge Query Readiness Package

## Package State

`GATE24_R2R2_TO_GATE28_CONTROLLED_LIFECYCLE_CANDIDATE`

## Evidence Basis

- M4 Slice 3 product commit: `a0e172f34ebc09f76e1bd894d680614ed901113d`.
- M4 Slice 3 post-publication synchronization commit: `7e1c1d04e6b92fcbf89f0b1268d189da9892071b`.
- R20: `PUBLICATION_VERIFIED=YES`, `GATE_SEQUENCE_COMPLETE=YES`, `P0=0`, `P1=0`, `P2=2`.
- Slice 3 production reader supplies the established handle-first, exact-path, Cloud Files metadata, no-recall, identity, stability, bounded-read and sanitized-error primitives. Slice 4 must impose the stricter exact local/hydrated-directory/hydrated-file attribute-tag truth table in its own policy layer; the published Slice 3 reader is not evidence that this stricter table is already enforced.
- Project-memory validator passes 16 required files and 9 memory frontmatters.

## Proposed Product Surface

One separate executable:

`EAIRA.ProjectKnowledge.Cli.exe --root <absolute-EAIRA-root> --query <literal-query>`

[Clause S4-READY-CODEC] The separate executable prevents query-output schema changes from weakening the existing five-Agent task-intake result contract. Exact design must first extract one platform-only compile seam from the Slice 3 reader and one codec-only source from `AgentCore.cs`. The platform seam owns a neutral `ProjectReadOnlyException`; the existing Slice 3 caller maps it to `ProjectContextException`, while the knowledge-query caller maps it to its own sanitized knowledge exception. No Slice 3 projection or loader-budget dependency may enter the platform seam. The codec seam has exactly `ContractException::.ctor(string)` and static `ContractCodec` members `ZeroHash`, `RequireWellFormedUtf16(string,string)`, `Sha256Hex(string)`, `Field(string)`, `Json(string)`, `RequireHash(string,string)`, `Utf8Strict(string)`, `Sha256(byte[])`, `Sha256Hex(byte[])`, `U32BE(uint)` and `Concat(byte[][])`. Dependency edges are closed to `System.Exception`, `System.IDisposable::Dispose`, primitive/string/array types, `System.Char`, `System.Text.Encoding`, `System.Text.UTF8Encoding`, `System.Text.StringBuilder`, `System.Globalization.CultureInfo`, `System.Security.Cryptography.HashAlgorithm`, `System.Security.Cryptography.SHA256` and calls among the listed members only. Both CLIs use the same native and codec implementations. The knowledge CLI compiles only those two seams plus query and host sources, references only `mscorlib.dll` and `System.dll`, and contains no Agent role, provider, HTTP, task-intake or Slice 3 projection metadata.

## Proposed Repository Change Classes

- one contract;
- one production query implementation;
- one CLI host;
- one deterministic harness;
- bounded build/profile additions;
- the four Slice 4 planning/decision artifacts; and
- controlled status/context/handoff synchronization.

The exact changed-path manifest must be frozen at the design gate before implementation.

## Readiness Prerequisites

| Prerequisite | State |
| --- | --- |
| Slice 3 publication and state sync | PASS |
| Exact seven-file allowlist | PRESENT FOR REVIEW |
| Authority classification | FIXED AS NAVIGATIONAL_NOT_AUTHORITY |
| HANDOFF/MEMORY_INBOX exclusion | FIXED |
| Query grammar and budgets | FIXED FOR REVIEW |
| Single extracted platform-only native seam | FIXED R2 REQUIREMENT |
| Runtime network/write/process boundary | NONE REQUIRED |
| Frontmatter/output/digest contract | FIXED R2 REQUIREMENT |
| Threat and complete native/abuse matrix | REVISED FOR REVIEW |
| Exact implementation design | MATERIALIZED; INDEPENDENT REVIEW REQUIRED |
| Implementation | GATE 23 R2 LOCAL CANDIDATE; DISCOVERY `_07` PASS; SEALED FINAL AND INDEPENDENT REVIEW REQUIRED |
| Repository recording | GATES 23-28 AUTHORIZED; NOT YET PERFORMED; EXACT STAGING/COMMIT/PUSH EVIDENCE REQUIRED |

## Gate Sequence

1. independent scope/allowlist/threat/readiness review;
2. exact implementation design and changed-path manifest;
3. independent design review;
4. bounded implementation and evidence;
5. independent implementation and abuse-case review;
6. exact staging and independent staged review;
7. exact commit and independent post-commit verification;
8. normal push and independent post-push verification; and
9. one later post-publication controlled-state checkpoint.

Any P0 or P1 fails closed and requires bounded remediation plus a new independent review.

## Review Finding Traceability and Current R2R8 Closure Requirements

| Finding ID | Exact disposition | Controlling clause ID |
| --- | --- | --- |
| I-P1-01 | single platform-only P/Invoke seam shared by both CLIs | S4-SCOPE-R2-01 |
| I-P1-02 | exact local/cloud directory/cloud file truth table | S4-SCOPE-R2-02 |
| I-P1-03 | exact frontmatter/output/digest contract | S4-ALLOW-FRONTMATTER; S4-ALLOW-DIGEST; S4-ALLOW-CHANNELS |
| I-P1-04 | mandatory native/verifier abuse matrix | S4-THREAT-MATRIX |
| I-P2-01 | physical extras ignored; compiled eighth rejected | S4-ALLOW-CLOSED-LIST |
| I-P2-02 | UTF-16, NFKC, scalar/control/match order fixed | S4-ALLOW-QUERY |
| R2-P1-01 | NUL separator, boolean byte and emitted-match set fixed | S4-ALLOW-DIGEST |
| R2-P1-02 | raw byte/newline/frontmatter boundary fixed | S4-ALLOW-FRONTMATTER |
| R2-P1-03 | active context links corrected | S4-STATE-ACTIVE-LINKS |
| R2-P1-04 | current success criteria corrected | S4-STATE-TODAY-CRITERIA |
| R2R1-P1-01 | end-exclusive 8,192 count fixed | S4-ALLOW-FRONTMATTER |
| R2R1-P1-02 | four-byte U32BE and UTF-8 payloads fixed | S4-ALLOW-DIGEST |
| R2R1-P1-03 | active Slice 4 dependencies fixed | S4-STATE-DEPENDENCIES |
| R2R1-P1-04 | one canonical readiness identifier | S4-STATE-CANONICAL-ID |
| R2R1-P2-01 | HANDOFF current state corrected | S4-STATE-HANDOFF |
| R2R2-P1-01 | codec-only seam and dependency closure fixed | S4-SCOPE-R2-05; S4-READY-CODEC |
| R2R2-P1-02 | full review history and current state synchronized | S4-READY-TRACE; S4-STATE-CURRENT |
| R2R2-P1-03 | exact ATX/trim/truncation bytes fixed | S4-ALLOW-RESULT-BYTES |
| R2R2-P2-01 | BOM/newline/byte/line cross-product fixed | S4-THREAT-MATRIX |
| R2R3-P1-01 | executable below/at/above fixtures and goldens fixed | S4-ALLOW-VECTORS |
| R2R3-P1-02 | exact success/error channel bytes fixed | S4-ALLOW-CHANNELS |
| R2R3-P1-03 | stable finding IDs map to exact clause IDs | S4-READY-TRACE |
| R2R3-P2-01 | leaf/ancestor cleanup and failure precedence fixed | S4-THREAT-CLEANUP |
| R2R3-P2-02 | codec type/member/helper inventory fixed | S4-READY-CODEC |
| R2R4-P1-01 | executable legal-document and serializer/output-budget fixtures with fixed SHA-256 | S4-ALLOW-VECTORS |
| R2R4-P1-02 | every historical finding has a stable row and durable normative clause label | S4-READY-TRACE |
| R2R4-P1-03 | all current and deep historical-baseline references synchronized | S4-STATE-CURRENT |
| R2R4-P2-01 | complete codec dependency inventory includes abstract/base MemberRefs | S4-READY-CODEC |
| R2R4-P2-02 | post-BOM content accounting and physical BOM boundary vectors fixed | S4-ALLOW-FRONTMATTER; S4-ALLOW-VECTORS |
| R2R5-P1-01 | one-match golden moved to legal body line 4 and recomputed | S4-ALLOW-VECTORS |
| R2R5-P1-02 | deep current authority baseline corrected to Version 0.33.0 | S4-STATE-CURRENT |
| R2R5-P1-03 | output-budget vectors explicitly isolated from legal-document end-to-end vectors | S4-ALLOW-VECTORS |
| R2R5-P2-01 | codec dependency inventory expanded or exact design must eliminate the edges | S4-READY-CODEC |
| R2R5-P2-02 | current product decision explicitly separated from Annex decision | S4-STATE-CURRENT |
| R2R6-P1-01 | every referenced clause ID is physically attached to one exact normative paragraph or controlled field | S4-ALLOW-CLOSED-LIST; S4-ALLOW-QUERY; S4-ALLOW-RESULT-BYTES; S4-STATE-* |
| R2R6-P2-01 | codec dependency closure includes `System.IDisposable::Dispose` | S4-READY-CODEC |
| R2R6-P2-02 | the Annex ten-gate authorization is explicitly historical and separate from the Slice 4 nine-gate lifecycle | S4-STATE-CURRENT |
| R2R7-P1-01 | the current product-decision paragraph names R2R8 consistently | S4-STATE-CURRENT |
| S4-R04-P1-01 | exact per-output defines, source order and conditional factory/native guards | S4-R03R2 design: Exact compile symbols and ordered source lists |
| S4-R04-P1-02 | normalized semantic native tuples/call graph/IL plus separate raw inventories | S4-R03R2 design: Production Verifier |
| S4-R04-P1-03 | non-circular discovery, reviewed binding and sealed final run | S4-R03R2 design: Production Verifier |
| S4-R04-P1-04 | 65,539 physical cap, post-BOM accounting and exact physical vectors | S4-R03R2 design: Knowledge-query source; Deterministic Harness |
| S4-R04-P2-01 | exact request/knowledge exception taxonomy and validation-before-open | S4-R03R2 design: Host and contract |
| S4-R04R1-P1-01 | reviewed external expected profile SHA binds path 15; profile binds other 20 | S4-R03R2 design: Production Verifier |
| S4-R04R1-P2-01 | seven-BOM aggregate placements and physical totals fixed | S4-R03R2 design: Deterministic Harness |
| S4-R04R1-P2-02 | Gate 22 findings receive stable trace rows | S4-READY-TRACE |
| GATE24-P1-01 | 383 stable-name boundary/abuse/channel cases and ordered case-name digest | Harness and release profile |
| GATE24-P1-02 | external profile SHA plus exact ordered 20 non-profile input hashes | Production verifier and release profile |
| GATE24-P1-03 | exact source/path/capability and native metadata closure | Production verifier |
| GATE24-P1-04 | empty/unterminated frontmatter, body line budget and full metadata stability | Product and harness |
| GATE24-P1-05 | current implementation/review lifecycle synchronization | Six controlled/context/HANDOFF artifacts |
| GATE24-P2-01 | standalone exact product contract | EAIRA_PROJECT_KNOWLEDGE_QUERY_V1.md |
| GATE24-R1-P1-01 | missing exact boundary, digest, ATX, cleanup, zero-open and CLI-channel cases | Harness, host seam and production verifier |
| GATE24-R1-P1-02 | incomplete codec/native IL closure and compile-then-reject specimen coverage | Production verifier and release profile |
| GATE24-R1-P1-03 | lifecycle input circularity | Phase-stable Gate 24-28 state in all six bound controlled/context/HANDOFF inputs |
| GATE24-R1-P2-01 | two control characters and duplicated contract prose | EAIRA_PROJECT_KNOWLEDGE_QUERY_V1.md |
| GATE23-TOKEN-P1-01 | PE-local metadata-token relocation prevents meaningful cross-output raw-hash equality | Exact per-output raw profile binding, clean A/B raw stability and cross-output token-relocation-aware semantic equality |
| GATE24-R2-P1-01 | external profile SHA was compared after JSON parsing | R2R1 verifier computes and ordinal-compares the mandatory external SHA before `ConvertFrom-Json`; new clean A/B and independent review required |
| GATE24-R2R1-P1-01 | mandatory stable-name abuse coverage omitted the full Cloud Files cross-matrix, unrelated physical eighth file, Unicode scalar/whitespace cases, explicit NUL/CR/tab rejection and zero-result query non-emission | R2R2 harness adds every named case without weakening prior checks |
| GATE24-R2R1-P1-02 | allowlist retained the obsolete R1 package state | R2R2 allowlist Revision 12 and all phase-stable lifecycle identifiers use one canonical state |

[Clause S4-READY-TRACE] Clause IDs above name these exact normative locations: `S4-SCOPE-R2-01` through `05` are numbered R2 scope corrections 1-5; `S4-ALLOW-CLOSED-LIST`, `QUERY`, `VECTORS`, `FRONTMATTER`, `RESULT-BYTES`, `DIGEST`, and `CHANNELS` are the corresponding labelled normative allowlist paragraphs; `S4-THREAT-MATRIX` and `CLEANUP` are the mandatory abuse list and cleanup bullet; `S4-STATE-*` are the current corresponding fields in the six controlled/context/HANDOFF artifacts; `S4-READY-CODEC` is the labelled Proposed Product Surface paragraph; and this table is `S4-READY-TRACE`.

R2R8 is eligible to close scope only if a new independent reviewer confirms:

1. one platform-only native seam and one codec-only seam can serve both CLIs without bringing Agent role, provider, HTTP, task-intake or Slice 3 projection metadata into the knowledge executable;
2. the exact local/hydrated-directory/hydrated-file attribute-tag truth table is internally consistent;
3. frontmatter, exact ATX recognition, ASCII trim, complete-scalar truncation, canonical JSON, 16,384-byte output, match/truncation meaning and domain-separated digest inputs are complete; and
4. the abuse matrix covers platform and codec closure, every native failure/cleanup path and precedence, the exact BOM/newline/byte/line cross-product, all below/at/above vectors, digest vectors, exact output channels and compile-then-reject verifier specimens.

## Retained Boundaries

- The separate production-signing Gate 24 remains partial.
- Gate 25 remains incomplete and external signing eligibility remains false.
- Fields, Annex counts, blockers and the all-fields-resolved gate do not move.
- No Windows, service, account, membership, directory, ACL, encryption, certificate, HSM, signing or production mutation is authorized by this package.
- The 18 long Codex checkpoint refs remain a separate maintenance finding.

## Current Determination

`GATE24_R2R2_TO_GATE28_CONTROLLED_LIFECYCLE_CANDIDATE`

The remaining controlled lifecycle consists of independently reviewed profile calibration, a new empty-root sealed A/B run, full independent Gate 24 implementation/abuse review, exact 21-path staging and staged review, one normal commit and post-commit verification, one normal push and independent live-publication verification. Every newly generated baseline must originate from clean A/B builds and be independently reviewed. This phase-stable state does not itself claim that any later step has completed.
