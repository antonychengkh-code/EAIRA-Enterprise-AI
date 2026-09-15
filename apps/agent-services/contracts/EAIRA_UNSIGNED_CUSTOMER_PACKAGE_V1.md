# EAIRA Unsigned Customer Package V1

## Purpose

This contract defines a deterministic, offline customer-package readiness artifact.
It is unsigned, non-installable and non-production. It grants no distribution,
deployment, signing, installation, service, provider or Windows authority.

## Fixed inputs

- Source: `C:\Temp\EAIRA_M5S4_SEALED_FINAL_003\unsigned-release`.
- Profile: `release/unsigned-customer-package-profile.json`, raw SHA-256
  `CDDF0BA541888222681DBA5BE9C60F92648C25C8D8ADF92CF6C20E57C62B4C67`.
- Source-manifest SHA-256:
  `4B9C72AC8A8134F4596CBA024F8A4C6EC21766F85084CB8174EBD77A33A04D85`.
- Product commit: `872e9b7916c24a09eb52cee8a894d69c0221295d`.
- Payload inventory: exactly nine ordered rows in the profile; no payload is
  executed or loaded.

## CLI

The compiled tool accepts exactly one of:

```text
Build --package-evidence-root C:\Temp\EAIRA_M5S5_PACKAGE_A_XXXXXXXXXXXX
Verify --package-evidence-root C:\Temp\EAIRA_M5S5_PACKAGE_A_XXXXXXXXXXXX
```

The side is `A_` or `B_`; the suffix is exactly 12 uppercase ASCII letters or
digits. Build requires an absent root. Verify requires the existing exact closed
tree. Invalid argv exits 64; all other failure exits 1; success exits 0.

## Output tree

```text
package/
  payload/<exact nine binaries>
  EAIRA_UNSIGNED_CUSTOMER_PACKAGE_MANIFEST_V1.json
  README.txt
```

README and manifest bytes are fixed ASCII/UTF-8 without BOM, LF-only and have one
terminal LF. The content digest uses domain
`EAIRA_UNSIGNED_CUSTOMER_PACKAGE_CONTENT_V1`, one zero byte and UInt32LE-length
framed UTF-8 fields. Production requires the nine-row digest
`DD51108C50DD4C1069695593DBEFF39C12927148E7DDBFEE98939CFD16B19DAB`.

## Canonical channel

Success is exactly one LF-terminated JSON line with schema
`EAIRA_UNSIGNED_CUSTOMER_PACKAGE_RESULT_V1`; status, mode, classification, version,
payload count, content digest and explicit `network`, `writes`, `cleanup`,
`persistentOutput`, `signing`, `installation` and `authority` fields are ordered and
sanitized. Build reports `writes=OUTPUT_ROOT_ONLY`; Verify reports `writes=NONE`.
No path, exception, timestamp, user, host, environment value or raw diagnostic is
emitted.

## Safety boundary

Verification performs no write. Building may write only its paired package root.
No installer, archive, autorun, updater, rollback executor, credential, certificate,
telemetry, network client, service registration or runtime activation is present.
The directory must be replaced by a separately verified signed release before any
customer distribution.
