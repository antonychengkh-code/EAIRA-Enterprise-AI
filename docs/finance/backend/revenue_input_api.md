# Finance Revenue Input Backend API

## Purpose

Define the minimal backend service/API artifact for the M3.4 Finance Revenue Input Task.

This artifact is limited to the candidate validation slice. It does not establish a reusable backend platform API.

## Endpoint

| Field | Value |
| --- | --- |
| Method | POST |
| Path | `/finance/revenue-inputs` |
| Purpose | Accept one revenue input record and return the accepted record identity. |

## Request Body

| Field | Type | Required |
| --- | --- | --- |
| client_id | string | Yes |
| project_id | string | Yes |
| revenue_date | date | Yes |
| amount | decimal | Yes |
| currency | string | Yes |
| source_label | string | No |

## Response Body

| Field | Type | Notes |
| --- | --- | --- |
| revenue_input_id | string | Identifier assigned to the accepted record. |
| status | string | `accepted` for a valid input. |

## Minimal Service Behavior

1. Reject requests missing `client_id`, `project_id`, `revenue_date`, `amount`, or `currency`.
2. Reject requests where `amount` is less than zero.
3. Persist valid input according to the Finance Revenue Input Persistence Schema.
4. Return `status = accepted` with the assigned `revenue_input_id`.

## Slice Boundary

This API artifact covers only revenue input creation for the M3.4 validation slice.
It does not define frontend behavior, authentication, invoicing, reporting, accounting close, or cross-module integration.
