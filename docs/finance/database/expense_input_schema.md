# Finance Expense Input Persistence Schema

## Purpose

Define the persistence model for Finance expense input.

No expense model previously existed. Finance persistence covered revenue only. This
artifact adds the expense side, matching the structure of the authoritative monthly
accounting workbook recorded in
`docs/tasks/ACCOUNTING_WORKBOOK_FIELD_STRUCTURE_ANALYSIS_001.md`.

It does not define reporting, invoicing, accounting close, payroll processing,
procurement, or cross-module behavior.

## Source Model

| Source | Role |
| --- | --- |
| Monthly accounting workbook, `P&L` sheet | Authoritative |
| FABi D03 cash export | Cash drawer reconciliation only; never an expense record |

The FABi D03 export contains no income rows, carries no structured expense category, and
was observed to record well under half of the cash tips present in the workbook for the
same period. It is not a usable expense source and must not be ingested as one.

## Expense Record

Expenses form a two-level hierarchy: a numbered group and a line within that group.
Unlike revenue, the group and line levels do nest.

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| expense_input_id | string | Yes | Unique identifier for one expense record. |
| period_id | string | Yes | Owning period, as defined in the revenue input schema. |
| source_id | string | Yes | The source document the record was read from. |
| breakdown | enum | Yes | `TOTAL`, `GROUP`, or `LINE`. |
| scope | string | No | Week label for a weekly figure; null for a period figure. |
| group_code | string | No | Group number when `breakdown` is `GROUP` or `LINE`. |
| group_label | string | No | Group name, such as the rental, payroll, cost of sales, or operating group. |
| line_label | string | No | Line name within the group when `breakdown` is `LINE`. |
| amount | decimal | Yes | Amount. May be zero. |
| created_at | datetime | Yes | Timestamp when the record is created. |

### Populated combinations

| breakdown | group_code | line_label |
| --- | --- | --- |
| `TOTAL` | null | null |
| `GROUP` | set | null |
| `LINE` | set | set |

### Observed groups

The workbook organises expenses into four numbered groups: a rental group, a payroll and
insurance group, a cost of sales group covering beverage and food including input VAT,
and an operating expenses group. Group membership is defined by the source document and
must be read from it, not assumed.

## Sign Convention

`amount` is stored as a positive magnitude. An expense is not stored as a negative
revenue. Profit is derived, never stored as an input.

## Validation Rules

Ingestion must reject a period that fails any of these. Partial ingestion is not
permitted.

1. `amount` is a number. Zero is valid; a zero line is a real observation, not missing
   data.
2. The sum of `LINE` records within a group equals that group's `GROUP` record.
3. The sum of `GROUP` records equals the `TOTAL` record.
4. `period_id` refers to an existing period record.
5. A period carries at most one `TOTAL` expense record per scope.
6. `source_id` refers to a source belonging to the same period.

## Derived Profit

Profit is not an input record. For a period it is defined as the revenue `TOTAL`
including VAT minus the expense `TOTAL`, and must equal the profit line stated by the
source document. A mismatch is a rejection condition, not a rounding difference to
absorb.

## Cash Reconciliation Boundary

A cash export may be compared against expense records to detect unrecorded cash
movement. Such a comparison has no shared key with the workbook and can only be attempted
on amount and date proximity, so it produces findings for human review. It never creates,
amends, or supersedes an expense record.

This schema does not authorize ingestion, external connection, or runtime action.
