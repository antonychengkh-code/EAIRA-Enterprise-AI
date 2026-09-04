# Accounting Workbook Field Structure Analysis

## Purpose

Record the observed structure of the monthly revenue and expense workbook maintained
outside FABi, and the relationship between that workbook and the FABi POS exports
described in `FABI_POS_REPORT_FIELD_STRUCTURE_ANALYSIS_001.md`.

This artifact records structure and observed relationships only. It does not reproduce
any monetary value.

## Data Handling Boundary

No revenue, expense, salary, or personal value appears in this artifact. This repository
is public. The workbook contains staff names, salary lines, supplier names, and complete
profit and loss figures, and is excluded from version control by `.gitignore`.

## Source Examined

One monthly workbook covering August 2026, comprising ten sheets:

| Sheet | Content |
| --- | --- |
| `WEEK 1` - `WEEK 4` | Daily revenue by floor and payment method, plus purchase detail |
| `Cash book` | Cash movement, receivables, and payment status |
| `Bank` | Bank statement reconciliation |
| `Salary` | Per-employee monthly payroll |
| `Cocktail` | Per-bartender commission |
| `Vy` | Expense summary by category |
| `P&L` | Monthly profit and loss statement |

## Principal Finding: FABi Covers One Revenue Stream Only

The business records two revenue streams, labelled `2F` and `1F` in the workbook.

The FABi D05 sales export total for the examined month equals the workbook's `2F` net
revenue figure exactly. The `1F` stream does not appear in FABi at all.

Consequences:

1. FABi is not a complete revenue source. An ingestion path built on FABi alone omits
   the entire `1F` stream.
2. The exact equality between the FABi D05 total and the workbook `2F` figure is a
   usable automated control: any future divergence indicates that one of the two records
   is wrong.

## P&L Sheet Structure

The `P&L` sheet is the most stable region of the workbook. Row labels are fixed strings
and the column layout is constant.

| Column | Meaning |
| --- | --- |
| 0 | Line label |
| 1 | Monthly actual |
| 2 - 5 | Week 1 to Week 4 |
| 7 | `2F` stream, present on the net revenue row only |
| 8 | `1F` stream, present on the net revenue row only |

### Line hierarchy

```
I - Net Revenue          Beverage, Beverage output VAT, Food, Food output VAT,
                         Service charge
II - Expenses            1 - Rental fee
                         2 - Payroll & Insurance   Salary, Public Holiday,
                                                   Service charge, Cocktail,
                                                   Tip (Cash), Bonus, Insurance
                         3 - Food & Beverage cost  Beverage, Beverage input VAT,
                                                   Food, Food input VAT
                         4 - Operating Expenses    Electricity, Water, Wifi + phone,
                                                   Marketing, Software copyright,
                                                   Gas, Ice water, Audio, Band,
                                                   Singer, Tax, Bank fee, Other
III - Profit (loss)
```

### Verified internal identities

All of the following held exactly for the examined month:

```
Beverage + Beverage VAT + Food + Food VAT  = I
Week 1 + Week 2 + Week 3 + Week 4          = I
2F + 1F                                    = I
Rental + Payroll + F&B cost + Operating    = II
I - II                                     = III
```

These are suitable as ingestion validation rules. A workbook that fails any of them
must be rejected rather than partially ingested.

### Dimensions do not nest

The monthly net revenue total is decomposed three separate ways: by item category
(Beverage / Food), by week, and by stream (`2F` / `1F`). These are alternative cuts of
one total, not a hierarchy. The stream split exists only at the net revenue line; it is
not available per week or per category.

## Week Sheet Structure

Each `WEEK n` sheet stacks two unrelated regions:

1. A daily revenue block: date, then cash / card / transfer / POS columns per floor,
   plus service charge and VAT columns, ending in a total row.
2. A purchase detail block holding four side-by-side tables (`BAR`, `KITCHEN`, `ORTHER`,
   `NOTE`), each with its own `Items` / `Supplier` / `unit` / `Quantity` / `VAT` /
   `total` / `Date` columns.

### Why the week sheets are unsuitable as a first ingestion target

- The header row position differs between sheets because the number of days differs.
- Four parallel tables share one row space, so column position alone does not identify
  a field.
- `Supplier` holds three unrelated kinds of value: a supplier name, a document number,
  or a payment method.
- Merged cells, `Hide` markers, and residual zero rows are present.
- The layout is maintained by hand and may change between months.

The `P&L` sheet should therefore be the initial ingestion target, with the week sheets
deferred until the monthly path is proven.

## Second Finding: The Non-POS Stream Records Cash Only

A POS export covering the `1F` stream was examined after the workbook. It is a separate
store under the same POS account, with its own store identifier, its own business day
cutoff, and item categories unrelated to the other stream.

Comparing it against the workbook establishes that the workbook's `1F` net revenue figure
equals the POS total for cash payments alone. The card and transfer portions of that
stream's sales do not appear in the workbook's revenue at all:

- The cash book records the `1F` figure under a heading for cash receipts, not revenue.
- The bank sheet's `1F` block records zero bank credit, zero card fee, and zero transfer
  for the whole period.
- That cash figure is then carried into the `P&L` as the whole of `1F` net revenue.

The stream's revenue is therefore understated by its entire non-cash portion, and the
output VAT on that portion is not recorded either. This also explains an earlier
observation that the period's total output VAT equals the VAT of the other stream alone.

This is a finding about the source records, not a parsing defect. It is exactly what the
verification control exists to surface: the control reports `MATCHED` for the POS-backed
stream and `DIVERGED` for this one.

## Business Day Cutoff Belongs To A Source

The two streams state different business day cutoffs, so a single period-level cutoff
cannot describe both. The cutoff is a property of the document it is stated in, and the
schema now records it on a source record rather than on the period.

Each POS export states its own window in its heading, so the cutoff is read from the
document rather than asserted by whoever runs the ingestion. The authoritative workbook
states no cutoff of its own, because it aggregates streams whose cutoffs differ; its
source record leaves the field null, which records that the value is unknown for that
document rather than implying a default.

Reading the window also establishes which period a document covers. An export declaring
a different period cannot verify this one, and is rejected rather than compared.

## Relationship to the FABi Exports

| Source | Role |
| --- | --- |
| Accounting workbook `P&L` | Authoritative revenue and expense record |
| FABi D05 sales export | Independent verification of the `2F` revenue stream |
| FABi D03 cash export | Cash drawer reconciliation only |

D03 remains incomplete even within the categories it does record: its cash tip entries
account for well under half of the workbook's recorded cash tips for the same month.
It cannot be used to verify an expense total.

## Boundary

This analysis does not authorize ingestion, external connection, or any runtime action.
