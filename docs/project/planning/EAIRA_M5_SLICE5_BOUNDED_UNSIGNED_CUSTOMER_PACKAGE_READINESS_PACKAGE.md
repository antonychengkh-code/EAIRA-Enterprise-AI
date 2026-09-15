# EAIRA M5 Slice 5 Bounded Unsigned Customer-Package Readiness Package

## 1. Control

| Field | Value |
| --- | --- |
| Package ID | `EAIRA_M5_SLICE5_A_READINESS_PACKAGE_V1R4` |
| Date | `2026-09-15` |
| Baseline | `e57307269e012afd9d01c45102c01e7eda2f2501` |
| Product predecessor | `872e9b7916c24a09eb52cee8a894d69c0221295d` |
| Selection | `M5S5_A_BOUNDED_UNSIGNED_CUSTOMER_PACKAGE_READINESS` |
| State | `GATE8_R4_REMEDIATION_REVIEW_PENDING` |
| Exact-design preparation authority | `CONSUMED_AFTER_R2R1_CLOSEABLE_REVIEW` |
| Implementation authority | `CONSUMED_FROM_PROJECT_OWNER_FULL_LIFECYCLE_AUTHORIZATION` |
| Repository-recording authority | `GRANTED_BY_PROJECT_OWNER_FULL_LIFECYCLE_AUTHORIZATION_PENDING_GATE_SEQUENCE` |
| Next Gate | `SEPARATE_INDEPENDENT_EAIRA_M5_SLICE5_A_GATE8_R4_IMPLEMENTATION_REMEDIATION_REVIEW` |

## 2. Outcome and user stories

1. A later separately authorized operator can construct an out-of-tree unsigned
   readiness bundle only from the
   exact sealed Slice 4 release payload.
2. A verifier can reproduce two byte-identical bundles and validate either bundle
   without executing payloads.
3. A release owner can inspect explicit version, upgrade, rollback and support
   boundaries without treating the bundle as installable or distributable.
4. Guard and Audit owners can prove only the exact profile and nine payloads were
   read, with no other repository/project/vault read, provider, network, credential,
   signing, Windows or service mutation.

## 3. Ten readiness prerequisites

| # | Prerequisite | Required evidence | State |
| --- | --- | --- | --- |
| 1 | M5 Slice 4 product publication | commit `872e9b7916c24a09eb52cee8a894d69c0221295d`, exact nine paths | `SATISFIED` |
| 2 | Slice 4 controlled-state publication | commit `e57307269e012afd9d01c45102c01e7eda2f2501` independently live-remote verified | `SATISFIED` |
| 3 | Sealed source evidence | manifest SHA-256 `4B9C72AC8A8134F4596CBA024F8A4C6EC21766F85084CB8174EBD77A33A04D85` | `SATISFIED` |
| 4 | Exact payload inventory | nine filenames, byte counts and SHA-256 values fixed by profile | `READY_TO_BIND` |
| 5 | Runtime non-mutation | existing runtime binaries are copied byte-for-byte; no source rebuild | `REQUIRED` |
| 6 | Deterministic output | A/B directory trees and canonical manifests byte-identical | `REQUIRED` |
| 7 | Verify-only mode | zero writes and exact closed-tree/hash validation | `REQUIRED` |
| 8 | Install/rollback boundary | documentary commands absent; no installer or rollback execution | `REQUIRED` |
| 9 | Signing boundary | unsigned readiness only; Gate 24 legal/certificate/HSM inputs remain deferred | `REQUIRED` |
| 10 | Repository boundary | exact nine changed paths; exclusions untouched | `REQUIRED` |

All ten prerequisites must be satisfied before sealed final evidence. A failed row
stops the lifecycle and requires a remediation Gate.

## 4. Fixed payload inventory

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `EAIRA.Planning.Service.exe` | 29184 | `2767AD2DE938083F575C705BCC835D54E4419FC49D53E2A62AFD7CB04FC2708E` |
| `EAIRA.Operations.Service.exe` | 29184 | `7251BDEB23CDAC25A7BECE110D4A6101BD89C3112733358E3171A206AAD3C983` |
| `EAIRA.Verification.Service.exe` | 29184 | `B0BD6714FC7048CBD46998433CADEB9913E2C0EE6822EE7AE2C0EE7B5E5892FC` |
| `EAIRA.Guard.Service.exe` | 28672 | `D32C265F72222C52383399908273B1E1F574C84DEE32BF6FBC5776F4AE878D46` |
| `EAIRA.Audit.Service.exe` | 28672 | `01EAA5FC43A4B1D49D915CE1459C8661F04A6CAA6440BC85FF44BFF577D9AE10` |
| `EAIRA.AgentTask.Cli.exe` | 72192 | `04EDEDDA8755F4B5FC76E7DB473C37CB49F67A53DA28A9AA83C167A521E9C752` |
| `EAIRA.ProjectKnowledge.Cli.exe` | 22016 | `08ABD5E90A0AAAB219639A7724A6B9C8EDE532199B23E84D459BE9DD40FD0F9A` |
| `EAIRA.ProjectQa.Cli.exe` | 97280 | `C4C786CABE71CFB0034D6B2F58937906A5D2649E4E1AE81BA2F339EE762C3288` |
| `EAIRA.LocalOperator.Cli.exe` | 139264 | `85F718BBCCDA14972B864F045F00D408BFD434C748141F50C692DD89F3481BA4` |

The profile order is canonical. The package-content digest is SHA-256 over exact
ASCII domain `EAIRA_UNSIGNED_CUSTOMER_PACKAGE_CONTENT_V1` followed by one actual
`0x00` byte, then release
version, product commit, source-manifest SHA-256, profile SHA-256, README SHA-256 and
every ordered filename/byte-count/payload SHA-256 tuple. Every field is framed as
`UInt32LE(UTF8 byte count) || UTF8(value)`. Numeric payload byte-count values use
invariant unsigned base-10 ASCII without sign or leading zero before framing. The
exact design must publish at least
three fixed golden vectors including an empty conceptual list, one row and all nine
rows; the production profile accepts only the all-nine vector.

## 5. Build and verify contract

Build mode uses the reviewed internal profile SHA and fixed repository-relative
profile path; no caller profile/hash override exists. It reads at most 64 KiB through
one non-write/delete-share handle, validates the raw hash before parsing those exact
held bytes, validates absolute DOS paths, final handle paths, volume/file identities,
every ancestor reparse state and closed source inventory, and rejects every source/
output/profile alias or containment relationship. Each source payload remains on one
non-write/delete-share handle from validation through copy. Build requires a
non-existing paired package-evidence root under `C:\Temp`, then continuously holds
verified directory handles for `C:\Temp`, that package root and `package.building`.
The exact repository profile alone may be a fully hydrated, non-Offline OneDrive
Cloud File after its fixed bytes and SHA are verified; no sealed source or output
reparse point is accepted.
Every destination child create/open is handle-relative to its held parent. Before any
write, the opened child handle must prove non-reparse state, expected volume/file
identity and containment. All bytes are written only through that held child handle.
After destination validation, publication uses same-parent handle-relative rename of
the held `package.building` directory to `package`; therefore `OUTPUT_ROOT` is exactly
`<PACKAGE_EVIDENCE_ROOT>\package`. No path is re-resolved for a mutating operation.

Verify mode opens the package read-only, pins final paths and identities, rejects
reparse points and any missing/extra entry, verifies fixed README bytes, re-computes
every hash and package-content digest, regenerates the one permitted canonical
manifest byte sequence and requires byte equality. This rejects duplicate keys,
unknown members, alternate order/escaping/numbers, BOM, invalid UTF-8, oversized/
deep JSON and trailing tokens without permissive parsing. The compiled Verify tool
performs zero write,
create, delete, rename or metadata mutation, observed by an exact before/after tree
identity/content snapshot. The wrapper uses a separately new work-evidence root for
compilation, snapshots and specimens; those wrapper writes are classified only as
`WORK_EVIDENCE_ROOT_ONLY` and cannot be confused with tool/package writes.

Canonical manifest bytes are UTF-8 without BOM, LF-only, exactly one terminal LF,
fixed property order, invariant decimal integers, uppercase 64-hex digests and exact
reviewed JSON escaping. A/B equality compares the ordered relative path plus length
and SHA-256 of every file; filesystem timestamps, ACLs and directory metadata are
neither normalized nor treated as evidence.

Compiled package-tool failure cleanup never recurses and never calls a pathname
deletion API. A
created-object ledger records every original handle and FileId. Before descendant
close, cleanup uses those still-held handles in reverse order with identity and close
verification. NTFS requires descendant close before parent rename; after that boundary,
any failure retains the tree as INCOMPLETE/POSSIBLE and never reopens for deletion. Foreign/concurrent or substituted entries are left
in place and the run fails closed. All check-then-path mutation is forbidden. Fault
and race injection exercises production Build/Verify using an in-memory I/O backend;
real A/B execution separately checks native filesystem behavior. Neither substitutes
for the other, and memory tests do not claim native race-scheduling coverage.
This paragraph does not apply to wrapper work evidence, which remains persistent,
requests no DELETE and is reported separately as `WORK_EVIDENCE_ROOT_ONLY`.

Each compiled tool success output is exactly one JSON line with schema, status, mode, classification,
releaseVersion, payloadCount, packageContentSha256, network, writes, signing,
installation and authority. Failure output is one fixed sanitized JSON line and a
nonzero exit code; no path, exception, stack, user, host or input is emitted. The
wrapper captures both tool lines without forwarding them and records a separate
sanitized evidence summary containing wrapper-write and tool-write classifications.

## 6. Version, upgrade, rollback and support boundary

The fixed readiness version is `5.5.0-readiness.1`. It is not a product semantic
version promise and cannot be used for auto-update. There is no upgrade executor.
A future signed package, if separately created and approved, must replace the entire
unsigned bundle and independently verify its own payloads. Rollback is conditional
future guidance only: no current signed package, installer or rollback mechanism is
asserted to exist. A future operator may retain a prior separately verified signed
package and use only a later authorized installer/rollback mechanism.
This slice provides no rollback command, backup, restore or state migration.

Support evidence is limited to sanitized manifest/result identifiers and exact
hashes. No logs, dumps, environment capture, telemetry, remote support, upload or
network collection is included.

## 7. Abuse and acceptance matrix

The exact design must bind a fixed-order named abuse inventory and expected
count/framed-name digest. It includes positive A/B build and verify tests plus
negative specimens for wrong/oversized/reparse/swapped profile; relative, UNC,
device, volume-GUID, ADS, dot-segment, short-name, trailing-dot/space and overlapping
paths; source/output ancestor and final-object substitution; source/profile swap
after validation; reparse insertion at every ancestor; pre-existing/nonempty output;
missing/extra/renamed/changed source; changed destination/README/manifest; cleanup
injection and failure after every create/write/flush/rename/verify stage; duplicate,
unknown, reordered, wrong-type/range/case/count/digest members; BOM, invalid UTF-8,
oversized/deep JSON, alternate escapes/numbers, trailing tokens/bytes; unexpected
package entries; and a verify-only before/after mutation observation.
It must statically reject forbidden network, process, registry, service, ACL,
certificate, signing, archive and installer references.

## 8. Exact changed-path ceiling

Exactly the nine paths listed in the scope decision are permitted. The two new C#
files compile only the offline packager and its harness. No existing runtime
source, harness, Gate25 verifier/profile, integration, root test or Obsidian path may
change. Out-of-tree evidence is permitted only under an exact caller-supplied
direct child of `C:\Temp` whose leaf matches `EAIRA_M5S5_WORK_[A-Z0-9]{12}`,
`EAIRA_M5S5_PACKAGE_A_[A-Z0-9]{12}` or `EAIRA_M5S5_PACKAGE_B_[A-Z0-9]{12}`,
with each mode's existence rules defined by the exact design.

## 9. Lifecycle phases and separate Gate boundary

The following are lifecycle phases, not combined authorization Gates: scope/readiness
review; exact-design preparation; design review; implementation authorization;
implementation/discovery; implementation review; sealed final evidence; final review;
exact staging; staged review; commit; post-commit review; normal push; post-push
review; controlled-state/HANDOFF mutation; state staging; state staged review; state
commit; state post-commit review; state normal push; and final live publication review.
Every mutation/action and every independent review remains separately evidenced.
This document deliberately publishes no fixed numeric Gate count: dynamic remediation
and separately authorized state-publication steps are not compressible into one
atomic authorization list.

Remediation Gates are inserted whenever an independent review returns a P0 or P1.

## 10. Determination

The V1R4 package tracks the Gate 8 R4 implementation-remediation candidate. The
Project Owner's full-lifecycle authorization permits validation, exact staging,
normal commit and normal fast-forward push only after the ordered independent Gates
pass. It grants no authority to sign, install, distribute, deploy, mutate Windows or
represent the bundle as a customer release.
