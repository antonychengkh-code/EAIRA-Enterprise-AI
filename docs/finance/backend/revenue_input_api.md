# Finance Period Input Backend API

## Purpose

Define the backend service/API for Finance revenue and expense input.

The original endpoint accepted one revenue record carrying a single amount. That shape
cannot express the authoritative source, in which a period total is decomposed several
ways and expenses form their own hierarchy. The endpoint is therefore defined at period
granularity, so that a period is accepted or rejected as a whole.

It does not establish a reusable backend platform API.

## Why a Period, Not a Row

The validation rules in the revenue and expense schemas are cross-record identities: the
category, week, and stream breakdowns must each sum to the period total, and expense
lines must sum to their group. None of these can be checked one record at a time. A
row-level endpoint would accept a period that is internally inconsistent, one valid row
at a time.

## Endpoint

| Field | Value |
| --- | --- |
| Method | POST |
| Path | `/finance/periods` |
| Purpose | Accept one complete reporting period and return the accepted period identity. |

## Request Body

| Field | Type | Required |
| --- | --- | --- |
| client_id | string | Yes |
| project_id | string | Yes |
| period_start | date | Yes |
| period_end | date | Yes |
| business_day_cutoff | time | Yes |
| currency | string | Yes |
| source_label | string | Yes |
| source_sha256 | string | Yes |
| revenue_records | array | Yes |
| expense_records | array | Yes |
| verifications | array | No |

Each array element follows the corresponding persistence schema:

- `revenue_records`: `docs/finance/database/revenue_input_schema.md`
- `expense_records`: `docs/finance/database/expense_input_schema.md`
- `verifications`: the verification record in the revenue input schema

## Response Body

| Field | Type | Notes |
| --- | --- | --- |
| period_id | string | Identifier assigned to the accepted period. |
| status | string | `accepted` for a valid period. |
| revenue_record_count | integer | Number of revenue records persisted. |
| expense_record_count | integer | Number of expense records persisted. |
| verification_status | string | `MATCHED`, `DIVERGED`, or `NOT_VERIFIED`. |

## Rejection Response

| Field | Type | Notes |
| --- | --- | --- |
| status | string | `rejected`. |
| failed_rules | array | Identities or field rules that failed, by rule identifier. |

A rejection persists nothing.

## Minimal Service Behavior

1. Reject requests missing any required field.
2. Reject a period whose revenue records fail any validation rule in the revenue input
   schema, including the category, week, and stream sum identities.
3. Reject a period whose expense records fail any validation rule in the expense input
   schema, including the line-to-group and group-to-total sum identities.
4. Reject a period whose derived profit does not equal the profit stated by the source.
5. Persist an accepted period atomically. A partially persisted period is not a valid
   outcome.
6. Reject a second submission carrying a `source_sha256` already accepted for the same
   client and project, so that re-ingesting the same document does not double count.
7. Record a verification as `DIVERGED` without rejecting the period. Divergence is a
   finding for human review, not a validation failure.
8. Return `status = accepted` with the assigned `period_id`.

## Boundary

This artifact defines an interface only. It does not authorize ingestion, external
connection, scheduled execution, or runtime action.
