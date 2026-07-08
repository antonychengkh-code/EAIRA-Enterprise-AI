# Finance Revenue Input Persistence Schema

## Purpose

Define the minimal persistence artifact for the M3.4 Finance Revenue Input Task.

This artifact is limited to the candidate validation slice. It does not establish a reusable Finance platform schema.

## Revenue Input Record

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| revenue_input_id | string | Yes | Unique identifier for one revenue input record. |
| project_id | string | Yes | Project context associated with the revenue input. |
| client_id | string | Yes | Client context associated with the revenue input. |
| revenue_date | date | Yes | Business date for the revenue entry. |
| amount | decimal | Yes | Revenue amount. Must be zero or greater. |
| currency | string | Yes | ISO-style currency code, such as TWD or USD. |
| source_label | string | No | Optional source or note for the revenue entry. |
| created_at | datetime | Yes | Timestamp when the record is created. |

## Minimal Validation Rules

- `amount` must be greater than or equal to zero.
- `currency` must not be blank.
- `revenue_date` must not be blank.
- `client_id` and `project_id` must preserve task traceability.

## Slice Boundary

This schema is a persistence description for the M3.4 Revenue Input Task only.
It does not define reporting, invoicing, accounting close, CRM, inventory, HR, or cross-module behavior.
