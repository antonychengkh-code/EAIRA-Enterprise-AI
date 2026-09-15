# EAIRA M5 Slice 5 Scope Decision

## Decision control

- Decision ID: `EAIRA_M5_SLICE5_SCOPE_DECISION_V1R4`
- Date: `2026-09-15`
- Project Owner selection: `M5S5_A_BOUNDED_UNSIGNED_CUSTOMER_PACKAGE_READINESS`
- Baseline: `e57307269e012afd9d01c45102c01e7eda2f2501`
- Product predecessor: `872e9b7916c24a09eb52cee8a894d69c0221295d`
- Decision state: `GATE8_R4_REMEDIATION_REVIEW_PENDING`
- Exact-design preparation authority: `CONSUMED_AFTER_R2R1_CLOSEABLE_REVIEW`
- Implementation authority: `CONSUMED_FROM_PROJECT_OWNER_FULL_LIFECYCLE_AUTHORIZATION`
- Repository-recording authority: `GRANTED_BY_PROJECT_OWNER_FULL_LIFECYCLE_AUTHORIZATION_PENDING_GATE_SEQUENCE`
- Force-push authority: `NOT_GRANTED`
- Next Gate: `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE5_A_GATE8_R4_IMPLEMENTATION_REMEDIATION_REVIEW`

## Selected outcome

Prepare one deterministic, unsigned and explicitly non-installable customer-package
readiness bundle from the exact nine outputs of a previously sealed EAIRA unsigned
release. The bundle proves packaging structure, version identity, payload integrity,
offline verification, rollback/support documentation and reproducibility without
claiming signing, installation, deployment or production readiness.

This slice does not change any EAIRA runtime binary. A later separately authorized
implementation may introduce an offline packaging tool, a closed profile and a
contract. The tool may read and copy only nine
profile-pinned unsigned binaries from a separately supplied source directory into
an out-of-tree destination and emit canonical sanitized metadata. It may not execute
those binaries, read any other repository/project/vault content, use a network,
install software, or mutate Windows configuration.

## Package boundary

The only successful output layout is:

```text
<PACKAGE_EVIDENCE_ROOT>/package/
  payload/
    EAIRA.Planning.Service.exe
    EAIRA.Operations.Service.exe
    EAIRA.Verification.Service.exe
    EAIRA.Guard.Service.exe
    EAIRA.Audit.Service.exe
    EAIRA.AgentTask.Cli.exe
    EAIRA.ProjectKnowledge.Cli.exe
    EAIRA.ProjectQa.Cli.exe
    EAIRA.LocalOperator.Cli.exe
  EAIRA_UNSIGNED_CUSTOMER_PACKAGE_MANIFEST_V1.json
  README.txt
```

Tool `OUTPUT_ROOT` means exactly `<PACKAGE_EVIDENCE_ROOT>\package`; it is derived
from the paired A/B package-evidence root and cannot be redirected. Wrapper work
artifacts use a separate work-evidence root and are never part of the package.

`README.txt` is fixed generated safety text. It must state that the bundle is
unsigned, non-installable, non-production, performs no registration or service
activation, and must be replaced by a separately signed release before distribution.
No installer, archive, bootstrapper, updater, script autorun, config, credential,
log, telemetry, certificate or recovery material may be included.

## Inputs

Only explicit command-line parameters and the reviewed tool/profile bytes are inputs:

- the exact source directory
  `C:\Temp\EAIRA_M5S4_SEALED_FINAL_003\unsigned-release`;
- one absolute, initially non-existing work-evidence root that is a direct child of
  `C:\Temp` with leaf `EAIRA_M5S5_WORK_[A-Z0-9]{12}`;
- exact A/B package-evidence roots under `C:\Temp`; Build requires both initially
  absent and Verify requires both existing, with distinct A/B leaf patterns;
- the repository-bounded profile resolved by the reviewed script itself; and
- mode `Build` or `Verify`.
- the exact compiler path; framework reference root remains a reviewed constant.

The reviewed script and compiled tool each contain the independently accepted
authorized profile SHA-256; the caller cannot supply or override it. The exact
profile is limited to 64 KiB, must be a non-reparse regular file at the fixed
repository-relative path, and is opened once with no write/delete sharing. Its raw
bytes are SHA-256 checked before those same held bytes are parsed. The fully static
profile is materialized and independently raw-byte reviewed first; only its accepted
hash is then embedded in wrapper/tool constants before the first no-bypass discovery
compile/run. Discovery never changes the profile. Independent discovery review must
pass before the same constants are used for sealed final.

The source directory must contain exactly the nine pinned filenames and no
unexpected file or directory. Each byte count and SHA-256 must match the profile.
The profile pins source sealed-manifest SHA-256
`4B9C72AC8A8134F4596CBA024F8A4C6EC21766F85084CB8174EBD77A33A04D85`
and product commit `872e9b7916c24a09eb52cee8a894d69c0221295d` as provenance labels only.
The packaging tool does not read the 9 MB source manifest or any other project/vault
file and does not infer trust
from filenames, timestamps, Authenticode state or directory location.

All accepted paths use absolute DOS drive syntax only. UNC, device namespaces,
volume GUIDs, ADS, relative/dot segments, trailing dot/space aliases, 8.3 short-name
aliases and case/normalization ambiguity fail closed. The tool rejects every reparse
point from `C:\Temp` through each final object, resolves final paths from held handles,
requires exact ordinal case-insensitive full-path equality, compares volume/file IDs
to prevent source/profile/output aliasing, and rejects source/output containment in
either direction.

## Outputs and authority

The canonical package manifest is UTF-8 without BOM, uses LF only with exactly one
terminal LF, fixed property order, uppercase 64-hex digests, invariant base-10
integers, JSON escaping limited to the exact reviewed encoder and no insignificant
whitespace. It contains only schema/version/classification,
product/profile/source-manifest identifiers, fixed safety flags, exact ordered
payload filename/byte-count/SHA-256 rows, README SHA-256 and a package-content
digest. It contains no absolute path, user name, timestamp, host identifier,
environment value or raw diagnostic.

The package-content digest is SHA-256 over ASCII domain bytes
`EAIRA_UNSIGNED_CUSTOMER_PACKAGE_CONTENT_V1` followed by one actual byte `0x00`,
then each semantic field as `UInt32LE(byteLength) || UTF8(value)` in exact design
order. Numeric byte-count field values are invariant unsigned base-10 ASCII with no
sign or leading zero before UTF-8 framing. Build and Verify
regenerate the complete canonical manifest and require byte-for-byte equality;
duplicate keys, unknown members, alternate ordering/escaping/numbers, BOM, invalid
UTF-8, trailing tokens or bytes therefore fail without a permissive reserialization.

The bundle classification is `UNSIGNED_READINESS_ONLY_NOT_INSTALLABLE`. Its
authority is `PACKAGE_NOT_RELEASE_AUTHORITY`. Successful build or verification is
not signing eligibility, publisher identity, customer-distribution approval,
installation authorization, service readiness, rollback execution authority or
production approval.

## Threat model

- Path traversal, namespace aliases, ADS, symlinks/reparse points and unexpected
  source entries fail closed through handle-resolved identity checks.
- Output-inside-source and source-inside-output relationships fail closed.
- Profile substitution fails before JSON parsing through the reviewed internal
  profile SHA-256 and the same held raw-byte buffer.
- Duplicate, missing, renamed, oversized, changed or additional payloads fail closed.
- Each source payload is opened once with no write/delete share; validation and copy
  use that same pinned handle, followed by destination revalidation.
- A second hash/size validation occurs after every copy.
- Build accepts only non-existing package-evidence roots and continuously holds
  verified directory handles from `C:\Temp` through each created package root and
  `package.building`. Every destination directory/file create or open is relative to
  its still-held parent handle; the opened child handle is checked for non-reparse
  state, volume/file identity and containment before any data or metadata write.
- Bytes are written only through that verified child handle. Publication uses a
  same-parent handle-relative rename of the still-held `package.building` directory
  to `package`; no pathname is re-resolved for create, write or rename.
- Before descendant close, failure cleanup uses only original ledger handles and
  original FileIds in reverse order with checked disposition and close. After the
  first descendant close required for NTFS rename, failure retains the tree and
  reports INCOMPLETE/POSSIBLE. It never reopens for deletion or deletes a foreign entry.
- All check-then-path filesystem mutation is explicitly forbidden. Race specimens
  must attempt substitution at relative create/open, publish rename and disposition.
- Verification is read-only and rejects any extra package entry or changed byte.
  This describes the compiled tool; wrapper compiler/snapshot/specimen artifacts are
  confined to a distinct new work root and reported as `WORK_EVIDENCE_ROOT_ONLY`.
- No payload execution, dynamic loading, Authenticode signing, network, registry,
  service control, ACL, account, group, certificate or provider operation is allowed.

## Exact changed-path ceiling

A complete Slice 5A implementation may contain exactly these nine repository paths:

1. `apps/agent-services/README.md`
2. `apps/agent-services/build/Invoke-UnsignedCustomerPackageReadiness.ps1`
3. `apps/agent-services/contracts/EAIRA_UNSIGNED_CUSTOMER_PACKAGE_V1.md`
4. `apps/agent-services/release/unsigned-customer-package-profile.json`
5. `apps/agent-services/src/UnsignedCustomerPackageReadiness.cs`
6. `apps/agent-services/tests/UnsignedCustomerPackageHarness.cs`
7. `docs/project/planning/EAIRA_M5_SLICE5_BOUNDED_UNSIGNED_CUSTOMER_PACKAGE_READINESS_PACKAGE.md`
8. `docs/project/planning/EAIRA_M5_SLICE5_EXACT_IMPLEMENTATION_DESIGN.md`
9. `docs/project/strategy/EAIRA_M5_SLICE5_SCOPE_DECISION.md`

Adding, removing or substituting a path requires a separate scope-remediation Gate.
The existing Gate25 verifier/profile and all runtime source/harness files are excluded.

## Exclusions

This decision does not authorize certificate purchase/enrollment, legal-publisher
completion, HSM/cloud resources, signing, installer creation or execution, archive
distribution, customer upload, Windows/service/IPC/account/group/ACL/registry
mutation, external provider, network use, production activation, force push or
checkpoint-ref repair. It excludes `docs/integrations/`, `scripts/claude_api.py`,
repository-root `tests/` and `.obsidian/`.

## Decision

`M5S5_A_BOUNDED_UNSIGNED_CUSTOMER_PACKAGE_READINESS` is selected as scope only.
This Gate grants no exact-design preparation, implementation, validation execution,
staging, commit or push authority; each requires its separate Project Owner Gate.
No signing, installation, distribution or production authority is inferred.
