# Finance Revenue Input Persistence Schema

## Purpose

Define the persistence model for Finance revenue input.

This schema was originally written for the M3.4 Revenue Input validation slice, which
recorded a single amount per entry. It has been widened to match the structure actually
present in the authoritative monthly accounting workbook, as recorded in
`docs/tasks/ACCOUNTING_WORKBOOK_FIELD_STRUCTURE_ANALYSIS_001.md`.

It does not define reporting, invoicing, accounting close, CRM, inventory, HR, or
cross-module behavior.

## Source Model

Revenue originates from one authoritative source and is verified against a second,
narrower one.

| Source | Role |
| --- | --- |
| Monthly accounting workbook, `P&L` sheet | Authoritative |
| FABi D05 sales export | Verification of one revenue stream only |

The FABi export covers a single revenue stream and must never be treated as the whole
of revenue.

## Period Record

One record per ingested reporting period. Every revenue and expense record belongs to
exactly one period.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| period_id | string | Yes | Unique identifier for one reporting period. |
| client_id | string | Yes | Client context. |
| project_id | string | Yes | Project context. |
| period_start | date | Yes | First business date in the period. |
| period_end | date | Yes | Last business date in the period. |
| currency | string | Yes | ISO-style currency code. |
| ingested_at | datetime | Yes | Timestamp of ingestion. |

Every date in the sources is a business date, not a calendar date: an entry recorded
after midnight belongs to the preceding business day. The cutoff that defines the
business day is **not** a property of the period. Two revenue streams observed in the
same period state different cutoffs, so a single period-level cutoff cannot describe
them. The cutoff belongs to a source, and is recorded there.

## Source Record

One record per document read for a period. A period has exactly one authoritative
source and any number of verification sources.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| source_id | string | Yes | Unique identifier for one source document. |
| period_id | string | Yes | Owning period. |
| role | enum | Yes | `AUTHORITATIVE` or `VERIFICATION`. |
| label | string | Yes | Human-readable identity, including the sheet actually read. |
| sha256 | string | Yes | Digest of the exact document read. |
| stream | string | No | The revenue stream a verification source covers. Null for an authoritative source. |
| business_day_cutoff | time | No | Start of the business day, as stated by the document itself. |
| window_start | date | No | First business date the document declares it covers. |

`business_day_cutoff` is read from the document, never asserted by the caller. A POS
export states its own window in its heading; that statement is the evidence, and a value
supplied by hand would not be.

It is null on the authoritative workbook, which states no cutoff of its own: it
aggregates streams whose cutoffs differ, so no single value would be true of it. A null
here records that the cutoff is unknown for that document, which is the fact.

`window_start` must equal the period's `period_start`. A document covering a different
period cannot verify this one, and the mismatch is a rejection rather than a finding.

## Revenue Record

The period total is decomposed three separate ways: by item category, by week, and by
revenue stream. These are alternative cuts of one total, not a hierarchy. The record
therefore carries an explicit `breakdown` discriminator rather than pretending the
dimensions nest.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| revenue_input_id | string | Yes | Unique identifier for one revenue record. |
| period_id | string | Yes | Owning period. |
| source_id | string | Yes | The source document the record was read from. |
| breakdown | enum | Yes | `TOTAL`, `CATEGORY`, `WEEK`, or `STREAM`. |
| scope | string | No | Week label when `breakdown` is `WEEK`; otherwise null. |
| category | string | No | Item category when `breakdown` is `CATEGORY`; otherwise null. |
| stream | string | No | Revenue stream when `breakdown` is `STREAM`; otherwise null. |
| amount_ex_vat | decimal | No | Amount excluding output VAT. Must be zero or greater when present. |
| output_vat | decimal | No | Output VAT. Must be zero or greater when present. |
| amount_incl_vat | decimal | Yes | Amount including output VAT. |
| created_at | datetime | Yes | Timestamp when the record is created. |

### Populated combinations

| breakdown | scope | category | stream |
| --- | --- | --- | --- |
| `TOTAL` | null | null | null |
| `CATEGORY` | null | set | null |
| `WEEK` | set | null | null |
| `STREAM` | null | null | set |

The stream split is available only at period level. It is not available per week or per
category, and the schema must not imply otherwise.

The source states the stream split as a single figure per stream, with no VAT breakdown.
`amount_ex_vat` and `output_vat` are therefore null on `STREAM` records. They are
required on every other breakdown. Deriving a stream VAT split by apportionment would
invent a figure the source does not hold, and is not permitted.

## Verification Record

Records the comparison between an authoritative stream figure and an independent
external source.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| verification_id | string | Yes | Unique identifier. |
| period_id | string | Yes | Owning period. |
| stream | string | Yes | Revenue stream being verified. |
| authoritative_amount | decimal | Yes | Amount from the accounting workbook. |
| external_source_id | string | Yes | The verification source record. |
| external_amount | decimal | Yes | Amount from that source. |
| difference | decimal | Yes | `authoritative_amount - external_amount`. |
| status | enum | Yes | `MATCHED` when the difference is zero, otherwise `DIVERGED`. |

A `DIVERGED` status means one of the two records is wrong. It is a finding, not a value
to be reconciled away by adjusting either side. It does not reject the period.

The external source must be checked for internal consistency before it is used. The
sales export states its own column totals in a closing row; summing its data rows and
comparing against that stated total detects a truncated or edited export. An export that
fails this check cannot verify anything, so verification fails rather than silently
comparing against a partial figure.

## Validation Rules

Ingestion must reject a period that fails any of these. Partial ingestion is not
permitted.

1. `amount_ex_vat` and `output_vat` are zero or greater.
2. `amount_incl_vat` equals `amount_ex_vat + output_vat` for every record that carries
   both, and both are present on every breakdown except `STREAM`.
3. The sum of `CATEGORY` records equals the `TOTAL` record.
4. The sum of `WEEK` records equals the `TOTAL` record.
5. The sum of `STREAM` records equals the `TOTAL` record.
6. `currency` is not blank.
7. `period_start` and `period_end` are not blank.
8. `client_id` and `project_id` preserve task traceability.
9. Every record references a source belonging to the same period.
10. Exactly one source carries the `AUTHORITATIVE` role.
11. Every source stating a `window_start` states one equal to `period_start`.

Rules 3 to 5 are the identities observed to hold exactly in the source workbook. A
source that violates them is malformed and must not be ingested.

## Ingestion Boundary

The source workbook is maintained by hand. Its weekly sheets vary in layout between
sheets and between months, so only the `P&L` sheet is a supported ingestion target at
this stage. Purchase-level detail from the weekly sheets is out of scope.

This schema does not authorize ingestion, external connection, or runtime action.
