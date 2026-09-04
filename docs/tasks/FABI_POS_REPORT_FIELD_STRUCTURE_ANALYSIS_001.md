# FABi POS Report Field Structure Analysis

## Purpose

Record the observed field structure of two FABi (iPOS.vn) report exports so that a
future Finance ingestion path can be designed against evidence rather than assumption.

This artifact records structural observations only. It does not define a schema, does
not authorize ingestion, and does not change any Finance persistence or API artifact.

## Data Handling Boundary

No real revenue, expense, or personal values are reproduced here. This repository is
public. Source exports are excluded from version control by `.gitignore`.

## Sources Examined

| Report | Export scope | Rows | Columns |
| --- | --- | --- | --- |
| D03 Cash in / cash out | 01/08/2026 04:00 - 01/09/2026 03:59 | 20 data + 2 total | 8 |
| D05 Sales report | 01/08/2026 04:00 - 01/09/2026 03:59 | 817 data + 1 total | 39 |

Both exports state a business day boundary of 04:00, not midnight. Any date field
derived from these reports is a business date, not a calendar date.

## D03 Field Structure

| # | Header | Type | Notes |
| --- | --- | --- | --- |
| 0 | 班次编号 | string | Shift identifier; repeats across rows |
| 1 | 员工 | string | Staff email address; personal data |
| 2 | 时间 | string | `DD/MM/YYYY HH:MM`, not a date type |
| 3 | 类型 | string | Single observed value `COMMON--CASH_OUT` |
| 4 | 业务类型 | string | Single observed value `Chi phí khác` |
| 5 | 支付方式 | string | Single observed value `CASH` |
| 6 | 备注 | string | Free text; the only expense descriptor |
| 7 | 金额 | integer | Amount |

### D03 Observations

- The export contains no cash-in rows. Its `总收入` total row is zero.
- Expense entries appear on five dates within the month, not daily.
- There is no structured expense category. Classification exists only as free text
  in `备注`, and that text may reference a date earlier than the transaction time.
- There is no per-transaction identifier suitable as an idempotency key.

D03 therefore does not constitute a complete expense record for the business.

## D05 Field Structure

Selected columns relevant to monetary interpretation:

| # | Header | Type | Observed meaning |
| --- | --- | --- | --- |
| 11 | 传输 ID | string | Transaction identifier; idempotency key candidate |
| 13 | 陈日期 | string | Business date, `DD/MM/YYYY` |
| 14 | 小时 | string | Time of day, separate column |
| 15 | 数量 | integer | Gross line amount before discount; see below |
| 19 | 折扣付款 | integer | Discount |
| 24 | 税 | integer | VAT |
| 27 | 总金额（不含增值税） | integer | Net amount excluding VAT |
| 36 | 总金额 | integer | Gross amount including VAT |

Columns 30-34 (`促销名称`, `优惠券代码`, `顾客姓名`, `客人编号`, `电话号码`) were empty in
this export but are customer-identifying fields when populated.

### Column 15 is mislabelled

The column titled `数量` (quantity) does not contain a quantity. Its values match the
line price, and both of the following identities hold exactly across all 817 data rows
of the examined export:

```
[15] - [19] = [27]
[27] + [24] = [36]
```

Column 15 is the gross line amount before discount. Treating it as a quantity produces
incorrect unit-price and volume figures.

### Total rows must be excluded

D05 ends with a `Tổng` row and D03 ends with `总收入` and `总支出` rows. These carry
column totals in the same columns as the data. A naive aggregation over all rows of the
D05 export returns exactly twice the true total. Any parser must drop the trailing
total rows before aggregating.

### Zero-amount rows

33 D05 rows carry a zero amount and item names marked `FOC`. These are complimentary
items, not data errors, and should be retained as zero-amount records.

## Consequences for a Future Ingestion Path

1. Revenue and expense originate from structurally unrelated reports. They cannot share
   one parser.
2. D05 supplies revenue with a usable transaction identifier.
3. D03 does not supply a usable expense record: no category, no identifier, and an
   incomplete view of business expenditure.
4. Reconciliation between D03 and an external accounting record can only be attempted on
   amount and date proximity, because no shared key exists.

## Boundary

This analysis does not authorize schema change, ingestion, or any external connection.
`docs/finance/database/revenue_input_schema.md` and
`docs/finance/backend/revenue_input_api.md` are unchanged by this artifact.
