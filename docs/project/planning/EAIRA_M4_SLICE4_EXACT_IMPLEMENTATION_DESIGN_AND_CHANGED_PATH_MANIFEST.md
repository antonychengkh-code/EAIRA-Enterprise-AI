# EAIRA M4 Slice 4 Exact Implementation Design and Changed-Path Manifest

## Identity

- Design ID: `EAIRA_M4_SLICE4_EXACT_IMPLEMENTATION_DESIGN_V7_GATE24_R2R2`
- Revision: 7
- Authority: Human Project Owner authorization for Gate 23–28 remediation and repository lifecycle
- Scope decision: `SLICE4_A_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY`
- Product baseline: `7e1c1d04e6b92fcbf89f0b1268d189da9892071b`
- State: `GATE24_R2R2_TO_GATE28_CONTROLLED_LIFECYCLE_CANDIDATE`

Gate 20 closed at R2R8 with independent `CLOSEABLE`, `P0=0`, `P1=0`, and `P2=0`. This document authorizes no implementation by itself.

## Product Surface

The only new executable is:

`EAIRA.ProjectKnowledge.Cli.exe --root <absolute-EAIRA-root> --query <literal-query>`

It accepts exactly four argv elements in that order. It never accepts a path, file selector, output path, provider, endpoint, model, credential, environment override or configuration file. It emits only the exact success or sanitized error JSON defined by the R2R8 allowlist.

## Exact Source Topology

### Shared codec-only source

New `apps/agent-services/src/ContractCodec.cs` contains exactly:

- `ContractException::.ctor(string)`; and
- `ContractCodec.ZeroHash`, `RequireWellFormedUtf16(string,string)`, `Sha256Hex(string)`, `Field(string)`, `Json(string)`, `RequireHash(string,string)`, `Utf8Strict(string)`, `Sha256(byte[])`, `Sha256Hex(byte[])`, `U32BE(uint)`, and `Concat(byte[][])`.

The existing definitions are removed from `AgentCore.cs` without semantic change. Every existing executable and harness that previously compiled `AgentCore.cs` must compile the new codec source immediately before it. The knowledge CLI compiles the codec source but not `AgentCore.cs`.

Closed framework dependencies are primitive/string/array types plus `System.Exception`, `System.IDisposable::Dispose`, `System.Char`, `System.Text.Encoding`, `System.Text.UTF8Encoding`, `System.Text.StringBuilder`, `System.Globalization.CultureInfo`, `System.Security.Cryptography.HashAlgorithm`, and `System.Security.Cryptography.SHA256`. Calls among the listed codec members are allowed. No IO, environment, reflection, dynamic code, process, shell, network, registry, service, threading or persistence reference is allowed.

### Shared platform-only source

New `apps/agent-services/src/ProjectReadOnlyPlatform.cs` is the single source of:

- neutral `ProjectReadOnlyException`;
- `IPinnedAncestorHandle`, `ILeafProbeHandle`, and `IApprovedContentHandle`;
- immutable `ProjectContextFileMetadata`;
- `IProjectContextReadOnlyPlatform`; and
- top-level sealed `ProjectContextWin32Platform`.

The legacy type names for markers, metadata and interface are retained to keep the Slice 3 caller and harness source-compatible. They are classified as shared platform metadata, not Slice 3 projection metadata. Only `ProjectReadOnlyException` may escape the platform implementation. `ProjectContextLoader.Load` maps it through its existing catch-all to `ProjectContextException`; the knowledge query maps it to `ProjectKnowledgeException`.

`ProjectContextWin32Platform` contains the only six P/Invoke declarations in both product CLIs:

1. `CreateFileW`;
2. `GetFileInformationByHandle`;
3. `GetFileInformationByHandleEx`;
4. `GetFinalPathNameByHandleW`;
5. `ReadFile`; and
6. `CloseHandle`.

The declarations retain the published Slice 3 signatures, flags, raw masks, entry points, Unicode mapping and exact caller closure. The platform permits a bounded read request of 0 through 262,144 bytes so the published Slice 3 maximum remains compatible; each caller enforces its lower policy before calling it. It contains no allowlist, parsing, projection, model/provider, HTTP, task-intake, Agent-role or output-schema logic.

`ProjectContext.cs` removes the moved marker/interface/metadata definitions and nested native implementation. Its native factory constructs the shared `ProjectContextWin32Platform`. No behavior or canonical output of the existing task CLI changes.

### Exact compile symbols and ordered source lists

`ProjectReadOnlyPlatform.cs` places only `ProjectContextWin32Platform`, its token/lease/native structures and its six P/Invokes inside `#if EAIRA_PROJECT_READONLY_NATIVE`. The neutral exception, three marker interfaces, metadata type and platform interface are unconditional. `ProjectContext.cs` retains its existing `#if EAIRA_PROJECT_CONTEXT_NATIVE` factory/coordinator region and existing `#if EAIRA_PROJECT_CONTEXT_TEST_SEAM` injection factory; every build defining the former must also define `EAIRA_PROJECT_READONLY_NATIVE`. `ProjectKnowledge.cs` places its native factory alone inside `#if EAIRA_PROJECT_KNOWLEDGE_NATIVE` and its injection factory alone inside `#if EAIRA_PROJECT_KNOWLEDGE_TEST_SEAM`; every build defining the former must also define `EAIRA_PROJECT_READONLY_NATIVE`. No source contains an implicit fallback factory.

| Output(s) | Complete defines | Exact ordered sources |
| --- | --- | --- |
| five existing service executables | each existing role symbol only | `AgentServiceHost.cs`, `ContractCodec.cs`, `AgentCore.cs`, `ModelProviders.cs` |
| `EAIRA.AgentCore.Harness.exe` | none | `ContractCodec.cs`, `AgentCore.cs`, `ModelProviders.cs`, `AgentCoreHarness.cs` |
| `EAIRA.LocalTaskIntake.Harness.exe` | `EAIRA_PROJECT_CONTEXT_TEST_SEAM` | `ContractCodec.cs`, `AgentCore.cs`, `ModelProviders.cs`, `LocalTaskIntake.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectContext.cs`, `LocalTaskIntakeHarness.cs` |
| `EAIRA.ProjectContext.Harness.exe` | `EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_CONTEXT_NATIVE,EAIRA_PROJECT_CONTEXT_TEST_SEAM` | `ContractCodec.cs`, `AgentCore.cs`, `ModelProviders.cs`, `LocalModelProvider.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectContext.cs`, `ProjectContextHarness.cs` |
| `EAIRA.LocalModelProvider.Harness.exe` | none | `ContractCodec.cs`, `AgentCore.cs`, `ModelProviders.cs`, `LocalTaskIntake.cs`, `LocalModelProvider.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectContext.cs`, `LocalModelProviderHarness.cs` |
| `EAIRA.LoopbackTransport.PolicyHarness.exe` | `TRANSPORT_POLICY_TESTS` | `ContractCodec.cs`, `AgentCore.cs`, `ModelProviders.cs`, `LocalTaskIntake.cs`, `LocalModelProvider.cs`, `OllamaLoopbackTransport.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectContext.cs` |
| `EAIRA.AgentTask.Cli.exe` | `EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_CONTEXT_NATIVE` | `ContractCodec.cs`, `AgentCore.cs`, `ModelProviders.cs`, `LocalTaskIntake.cs`, `LocalModelProvider.cs`, `OllamaLoopbackTransport.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectContext.cs`, `AgentTaskIntakeHost.cs` |
| `EAIRA.ProjectKnowledge.Cli.exe` | `EAIRA_PROJECT_READONLY_NATIVE,EAIRA_PROJECT_KNOWLEDGE_NATIVE` | `ContractCodec.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectKnowledge.cs`, `ProjectKnowledgeHost.cs` |
| `EAIRA.ProjectKnowledge.Harness.exe` | `EAIRA_PROJECT_KNOWLEDGE_TEST_SEAM` | `ContractCodec.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectKnowledge.cs`, `ProjectKnowledgeHost.cs`, `ProjectKnowledgeHarness.cs` |

All existing framework-reference lists retain their exact order. The two new knowledge outputs reference only `mscorlib.dll` then `System.dll`. The verifier rejects source-order or define-set drift before compilation.

### Knowledge-query source

New `apps/agent-services/src/ProjectKnowledge.cs` contains:

- sealed `ProjectKnowledgeRequestException` and sealed `ProjectKnowledgeException`;
- immutable match/result types;
- a sealed loader/query engine with an injection-only internal constructor;
- one native factory constructing the shared platform;
- the exact seven-element private static path array; and
- canonical parser, literal matcher, result serializer and digest framing.

The seven paths appear once, in exact allowlist order. No directory enumeration API or caller path can reach the loader. Root canonicalization and ancestor pinning occur before every leaf read. All seven ancestors remain pinned until the complete operation finishes. For each file, probe opens with reparse/no-recall, content opens with no-recall, identity and metadata are checked before and after the single bounded read, and leaf handles close content then probe immediately. Ancestors close in reverse order in an outer finally.

The stricter Slice 4 policy accepts only:

| Object | Directory bit | Reparse bit | Tag | Result |
| --- | ---: | ---: | --- | --- |
| local directory | 1 | 0 | `0` | PASS |
| local file | 0 | 0 | `0` | PASS |
| hydrated Cloud directory | 1 | 1 | `0x9000E01A` | PASS |
| hydrated Cloud file | 0 | 1 | `0x9000601A` | PASS |

Every other combination, Offline, RecallOnOpen, RecallOnDataAccess, name-surrogate tag, identity change, metadata change, partial read, close failure without a prior failure, or path mismatch fails the complete query.

The parser implements the R2R8 contract exactly. Metadata physical length must be at most 65,539 bytes. The platform performs exactly one physical read of that exact metadata length. The query layer strips only one leading `EF BB BF` sequence, if present, then requires the remaining post-BOM content length to be at most 65,536 bytes. Aggregate accounting adds only each post-BOM content length and rejects a total above 262,144. A non-leading BOM is content. The remaining controls are consistent LF or CRLF only, mandatory non-empty frontmatter closed by line 64 and end-exclusive byte 8,192, line bytes 1,024 and lines 4,096. Frontmatter is never searched. Query NFKC and scalar/control checks occur before native factory construction or any repository read. Matching is NFKC `OrdinalIgnoreCase` literal substring only. Search continues through all bounded files to set `truncated` accurately.

Canonical result and digest code uses only `ContractCodec`. It emits at most eight matches and enforces the complete stdout limit of 16,384 bytes including LF before returning success.

### Host and contract

New `apps/agent-services/src/ProjectKnowledgeHost.cs` owns the only `Main(string[])` for this executable. It:

1. validates exact argv shape;
2. calls `ProjectKnowledgeQuery.NormalizeQueryOrThrowRequest(string)` before constructing the native loader;
3. invokes one query;
4. writes one exact UTF-8-without-BOM stdout record through `Console.OpenStandardOutput`;
5. returns 0, 64 or 81; and
6. writes zero stderr bytes.

Exact error taxonomy and catch order are:

1. argv shape failure or `ProjectKnowledgeRequestException` -> exact `INVALID_REQUEST`, exit 64;
2. `ProjectKnowledgeException` -> exact `KNOWLEDGE_ERROR`, exit 81;
3. any other `Exception` -> exact `KNOWLEDGE_ERROR`, exit 81.

`NormalizeQueryOrThrowRequest` is pure and may reference only string/Unicode/codec operations. The native factory call appears only after it returns successfully. The verifier binds this caller order and the harness uses an open-count sentinel proving every invalid query performs zero platform opens. The host never emits exception type, message, stack, absolute path, query, file content, SID, handle, native code or environment value.

New `apps/agent-services/contracts/EAIRA_PROJECT_KNOWLEDGE_QUERY_V1.md` reproduces the controlling CLI, allowlist, parsing, output, digest, error and non-authority contracts. The planning documents remain the design authority if prose conflicts.

## Deterministic Harness

New `apps/agent-services/tests/ProjectKnowledgeHarness.cs` uses an injection-only fake platform. No live repository content or native handle is used by the ordinary harness.

The harness must include every mandatory case from `S4-THREAT-MATRIX`, including:

- exact argv and query scalar/control/NFKC boundaries;
- seven-file order, missing file and proof no eighth file is opened;
- root, every ancestor and every final-file canonical-path substitution;
- local and two hydrated Cloud accepted states;
- every rejected attribute/tag/Offline/Recall/non-regular state at probe, content-before and content-after stages for all seven leaves;
- probe/content identity mismatch and content mutation for every leaf;
- every native open/query/read/close failure, partial read and cleanup precedence;
- per-file, aggregate, line-byte, line-count, frontmatter byte/line, BOM and newline below/at/above vectors;
- physical no-BOM lengths 65,535/65,536/65,537 and physical BOM lengths 65,538/65,539/65,540;
- exactly seven aggregate fixtures, each with a leading three-byte BOM: post-BOM totals 262,143/262,144/262,145 correspond exactly to physical totals 262,164/262,165/262,166 and PASS/PASS/KNOWLEDGE_ERROR;
- frontmatter exclusion, ATX recognition, ASCII trim, Unicode complete-scalar truncation;
- zero/one/eight/nine results, duplicates and deterministic ordering;
- query/result/stdout fixed SHA-256 vectors;
- isolated 16,383/16,384/16,385 serializer vectors;
- exact stdout/stderr/exit channels and raw-content/path/query non-emission; and
- literal regex/glob/wildcard/Markdown/wikilink/instruction-shaped inputs.

Every exact case has a stable name. The final test count and ordered case-name digest are frozen in the release profile only after a pinned-compiler evidence run; changing either requires a new review.

## Production Verifier

`Invoke-Gate25UnsignedRelease.ps1` is extended without weakening any Slice 1-3 check. It must:

- compile two clean A/B builds using the already pinned Roslyn compiler and framework references;
- add `ContractCodec.cs` to every legacy source list;
- compile the knowledge CLI from exactly `ContractCodec.cs`, `ProjectReadOnlyPlatform.cs`, `ProjectKnowledge.cs`, and `ProjectKnowledgeHost.cs`;
- compile the knowledge harness from exactly the codec, platform, query and harness sources with the test-seam symbol and no native symbol;
- require byte-identical A/B outputs;
- execute all legacy harnesses and the knowledge harness;
- execute exact invalid, zero-result, one-result and budget channel vectors;
- assert the knowledge CLI has exactly one entry point and the platform TypeDef owns exactly six P/Invoke MethodDefs;
- compute for every native output a normalized six-row P/Invoke tuple in entry-point order: declaring semantic type role, module, entry point, managed return type, ordered managed parameter types and by-ref/out markers, CharSet, CallingConvention, ExactSpelling, SetLastError, BestFitMapping, ThrowOnUnmappableChar, PreserveSig, return marshal, method attributes, implementation attributes and import attributes;
- compare the normalized tuple and token-normalized call graph across task and knowledge CLIs while retaining separate per-output raw signature blobs and raw IL hashes in the profile;
- for `ContractCodec`, retain the complete output-specific raw closure for the CLI and harness, require exact raw stability across clean A/B builds, and profile-bind each raw closure independently; because metadata tokens are PE-local addresses, require cross-output equality only for the separately recorded token-relocation-aware semantic closure, while recording that the two raw hashes are expected to differ;
- normalize each approved native call edge as caller full semantic signature, opcode, callee entry point/full semantic signature and occurrence ordinal; normalize IL by replacing metadata tokens with full semantic identities and branch targets with instruction ordinals before hashing;
- close the codec TypeDef/MethodDef/MemberRef inventory;
- close the exact seven path literals and reject an eighth;
- reject Agent role, provider, HTTP, URI, socket, file/directory enumeration, write, process, shell, environment, registry, service, reflection, dynamic-code and serialization-framework references in the knowledge outputs;
- compile and reject negative specimens for duplicate/moved P/Invoke, extra allowlist entry, directory enumeration, arbitrary path, output field/schema change, raw content/path/query emission, wrong digest framing, alternate factory/constructor/caller, reflection/dynamic dispatch and write/network references;
- require every negative specimen to compile successfully before verifier rejection; and
- emit a sanitized out-of-tree manifest with no SID, absolute repository path, file content, query text, handle, credential or recovery material.

The release profile gains one `projectKnowledge` section containing exact sources, framework references, path literals, TypeDef/MethodDef/MemberRef inventories, normalized P/Invoke/caller/IL identities, separate output-specific raw inventories, harness case count/digest, fixed vector bytes/hashes, specimen names and expected A/B artifact hashes.

Calibration is an exact three-phase lifecycle:

1. `-ProjectKnowledgeDiscovery`: execution is independent only of the new `projectKnowledge` expected-value section. It must still load and enforce the pre-existing controlled `compilerPolicy`, including compiler hash, signature and product version, before compilation. It validates exact source and define lists, exact seven paths, all documentary constants/goldens, full harness and abuse matrix, forbidden-capability absence, normalized native equality, legacy regressions and A/B byte identity. It accepts no learned project-knowledge expected value. It emits provisional count/digest/raw-metadata/artifact values only to a sanitized out-of-tree discovery JSON and sets `finalEvidence=false`.
2. A bounded repository mutation copies only those discovery values and exact SHA-256 for the other 20 manifest inputs into the `projectKnowledge` profile section after review. A reviewer independently computes the resulting release-profile SHA-256. The review response records the discovery JSON hash, the exact resulting profile SHA-256 and all 20 profile-bound input hashes; the response and out-of-tree JSON are never repository inputs.
3. A new empty output root runs with discovery disabled and requires the invocation parameter `-ExpectedReleaseProfileSha256 <64-uppercase-hex>`. Before parsing the profile, the verifier computes its SHA-256 and compares it in constant ordinal form to that separately reviewed parameter. It then loads the already-bound profile, verifies the other 20 exact input hashes, rejects missing or placeholder values, enforces every project-knowledge value without learning or updating it, and emits final A/B evidence with `finalEvidence=true`. Thus the external reviewed parameter binds manifest path 15 and the profile binds the other 20 paths, verifying all 21 without self-hash.

Final evidence is invalid unless phase 1 passed, the profile mutation and its resulting SHA-256 were independently reviewed, `-ExpectedReleaseProfileSha256` is present and matches before JSON parsing, discovery is disabled, output roots are new, the pinned compiler identity is unchanged, all profile values are already non-placeholder, the other 20 profile-bound hashes match and all 21 manifest inputs are thereby bound.

## Exact Golden Acceptance

The implementation and build verifier must reproduce:

- query `a`: `AC87D75CD0EDF9A4DFEA57A1503749811E01E2362DFEF7B4503F4CDF029A6FAF`;
- zero result: `9F73299A3BBE37839C2F3B2105027A59E001B06ACC1216849FF6873437B05DC5`;
- legal line-4 one result: `F1A152FD8406D4464E796603AF513B956D6F68F500FE95788D4D1D2D96019D73`;
- zero stdout: 362 bytes, `406C4FCF3040C1ACD9D1272DC098164FE17545A120C612AC403A6205B30A0019`;
- one stdout: 479 bytes, `7D425FFAA9DA666FB500B1D4FE0A395320132EDFE67BF715522EA957E73FFDF5`; and
- serializer stdout 16,383/16,384/hypothetical 16,385 hashes exactly as fixed in the allowlist, with 16,385 producing only `KNOWLEDGE_ERROR/81`.

## Exact Changed-Path Manifest

Implementation and repository recording are limited to these 21 paths in this order:

1. `docs/project/strategy/EAIRA_M4_FUNCTIONAL_AGENT_MVP_SLICE_4_SCOPE_DECISION.md`
2. `docs/project/planning/EAIRA_M4_SLICE4_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY_ALLOWLIST.md`
3. `docs/project/planning/EAIRA_M4_SLICE4_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY_THREAT_MODEL.md`
4. `docs/project/planning/EAIRA_M4_SLICE4_BOUNDED_READ_ONLY_PROJECT_KNOWLEDGE_QUERY_READINESS_PACKAGE.md`
5. `docs/project/planning/EAIRA_M4_SLICE4_EXACT_IMPLEMENTATION_DESIGN_AND_CHANGED_PATH_MANIFEST.md`
6. `apps/agent-services/contracts/EAIRA_PROJECT_KNOWLEDGE_QUERY_V1.md`
7. `apps/agent-services/src/ContractCodec.cs`
8. `apps/agent-services/src/AgentCore.cs`
9. `apps/agent-services/src/ProjectReadOnlyPlatform.cs`
10. `apps/agent-services/src/ProjectContext.cs`
11. `apps/agent-services/src/ProjectKnowledge.cs`
12. `apps/agent-services/src/ProjectKnowledgeHost.cs`
13. `apps/agent-services/tests/ProjectKnowledgeHarness.cs`
14. `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1`
15. `apps/agent-services/release/gate25-unsigned-release-profile.json`
16. `docs/project/status/CURRENT_STATUS.md`
17. `docs/project/status/TODAY_OBJECTIVE.md`
18. `docs/project/status/ACTIVE_TASK.yaml`
19. `docs/project/status/AGENT_CONTEXT_VERSION.yaml`
20. `docs/project/context/CURRENT_CONTEXT.md`
21. `docs/project/memory/HANDOFF.md`

No root `tests/`, `docs/integrations/` or `scripts/claude_api.py` path is part of the manifest. No `.obsidian`, Windows, service, account, group, membership, directory, ACL, BitLocker, TPM, certificate, HSM, signing, provider, credential or production resource is in scope.

Existing implementation-input baselines at Gate 21 are:

| Path | Bytes | SHA-256 |
| --- | ---: | --- |
| `apps/agent-services/src/AgentCore.cs` | 38,600 | `26D6AEEE50857D93C0A9A74D2D82FD0B034D8CC3A247CF073B6A6476657AD913` |
| `apps/agent-services/src/ProjectContext.cs` | 50,094 | `CE0903ECFDBED387DB6CFBD7060326E3BC33AD0DC2505C5114C2ACD23B5E7643` |
| `apps/agent-services/build/Invoke-Gate25UnsignedRelease.ps1` | 184,358 | `257D581DA7E12410317AEB2C4C6E339760962F3C631CAE3355A3745993AD0442` |
| `apps/agent-services/release/gate25-unsigned-release-profile.json` | 13,094 | `B1D4452C363EF504B6E64AC97B1ED1CE26B2A7B6C498FA0E424A4788817864FA` |

Any baseline mismatch before implementation fails closed and requires reconciliation.

## Gate Determination

`GATE24_R2R2_TO_GATE28_CONTROLLED_LIFECYCLE_CANDIDATE`

The controlled lifecycle is: independently review the calibrated profile; generate a new empty-root sealed A/B run; independently review the complete Gate 24 implementation and abuse evidence; stage exactly the 21 manifest paths; independently review the staged snapshot; create one normal commit; independently verify that commit; normally push it; and independently verify live publication. Any new baseline must come from a new clean A/B run and receive independent review before it can advance.

Discovery `_07` passed with manifest SHA-256 `9D7215AD311E4CF5518E2164F9CF2571F04C928338B590FB3F2B55F6DB125F54`, 383 stable-name harness cases, exact output-specific raw codec closures, equal token-relocation-aware semantic codec closures, 17 compiled-and-rejected knowledge specimens, exact CLI channel checks and byte-identical A/B outputs. It remains `finalEvidence=false`. At the time this candidate state was written, no Slice 4 staging, commit or push had occurred; later lifecycle stages must be established only by their own evidence.

Independent D08 profile-calibration review returned `CANNOT_CLOSE`, `P0=0`, `P1=1`, `P2=0` because the verifier parsed the profile before checking its external SHA. R2R1 moves SHA computation, mandatory expected-SHA validation and ordinal comparison before `ConvertFrom-Json`. Since the verifier is a bound input, every later accepted value must come from a new clean A/B discovery and a new independent calibration review.

The first R2R1 sealed-final Gate 24 review returned `CANNOT_CLOSE`, `P0=0`, `P1=2`, `P2=0`. R2R2 adds stable-name coverage for the complete directory/file Cloud Files attribute-and-tag cross-matrix at every ancestor and leaf probe/content stage, an unrelated physical eighth file that must remain unenumerated and unopened, complete-scalar heading truncation, ASCII-only trim with Unicode whitespace preservation, explicit NUL/CR/tab query rejection, and zero-result raw-query non-emission. It also synchronizes the allowlist state. The prior sealed final is superseded; a new clean A/B discovery and independent calibration review are mandatory.
