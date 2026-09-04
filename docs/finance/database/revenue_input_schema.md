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
| business_day_cutoff | time | Yes | Start of the business day. Sources observed to date use `04:00`, not midnight. |
| currency | string | Yes | ISO-style currency code. |
| source_label | string | Yes | Human-readable identity of the source document. |
| source_sha256 | string | Yes | Digest of the exact ingested source document. |
| ingested_at | datetime | Yes | Timestamp of ingestion. |

`business_day_cutoff` is required because every date in the source sources is a business
date, not a calendar date. An entry recorded after midnight belongs to the preceding
business day.

## Revenue Record

The period total is decomposed three separate ways: by item category, by week, and by
revenue stream. These are alternative cuts of one total, not a hierarchy. The record
therefore carries an explicit `breakdown` discriminator rather than pretending the
dimensions nest.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| revenue_input_id | string | Yes | Unique identifier for one revenue record. |
| period_id | string | Yes | Owning period. |
| breakdown | enum | Yes | `TOTAL`, `CATEGORY`, `WEEK`, or `STREAM`. |
| scope | string | No | Week label when `breakdown` is `WEEK`; otherwise null. |
| category | string | No | Item category when `breakdown` is `CATEGORY`; otherwise null. |
| stream | string | No | Revenue stream when `breakdown` is `STREAM`; otherwise null. |
| amount_ex_vat | decimal | Yes | Amount excluding output VAT. Must be zero or greater. |
| output_vat | decimal | Yes | Output VAT. Must be zero or greater. |
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

## Verification Record

Records the comparison between an authoritative stream figure and an independent
external source.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| verification_id | string | Yes | Unique identifier. |
| period_id | string | Yes | Owning period. |
| stream | string | Yes | Revenue stream being verified. |
| authoritative_amount | decimal | Yes | Amount from the accounting workbook. |
| external_source | string | Yes | Identity of the verifying source. |
| external_amount | decimal | Yes | Amount from that source. |
| difference | decimal | Yes | `authoritative_amount - external_amount`. |
| status | enum | Yes | `MATCHED` when the difference is zero, otherwise `DIVERGED`. |

A `DIVERGED` status means one of the two records is wrong. It is a finding, not a value
to be reconciled away by adjusting either side.

## Validation Rules

Ingestion must reject a period that fails any of these. Partial ingestion is not
permitted.

1. `amount_ex_vat` and `output_vat` are zero or greater.
2. `amount_incl_vat` equals `amount_ex_vat + output_vat` for every record.
3. The sum of `CATEGORY` records equals the `TOTAL` record.
4. The sum of `WEEK` records equals the `TOTAL` record.
5. The sum of `STREAM` records equals the `TOTAL` record.
6. `currency` is not blank.
7. `period_start`, `period_end`, and `business_day_cutoff` are not blank.
8. `client_id` and `project_id` preserve task traceability.

Rules 3 to 5 are the identities observed to hold exactly in the source workbook. A
source that violates them is malformed and must not be ingested.

## Ingestion Boundary

The source workbook is maintained by hand. Its weekly sheets vary in layout between
sheets and between months, so only the `P&L` sheet is a supported ingestion target at
this stage. Purchase-level detail from the weekly sheets is out of scope.

This schema does not authorize ingestion, external connection, or runtime action.
