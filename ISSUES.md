# NorthBank — ready-to-assign issues

Four issues used across the training stations. Each is written so it can be
copied straight into GitHub and assigned to a Copilot agent session.

---

## Issue #1 — Enforce daily transfer limit in TransferService

**Labels:** `enhancement`, `payments`

**Body**

`Account` carries a `DailyTransferLimit`, but `TransferService.Transfer` never
checks it. A customer can move more than their limit in a single day across
several transfers.

Add enforcement: before posting a transfer, sum the amounts already transferred
out of the source account today (see `ILedger.SumTransfersToday`) and reject the
transfer if this transfer would push the day's total above the account's
`DailyTransferLimit`.

**Acceptance criteria**

- [ ] A transfer that would exceed `DailyTransferLimit` for the source account
      is rejected with a clear message and no balance change.
- [ ] Transfers at or below the remaining daily allowance still succeed.
- [ ] The daily total is measured per source account, per UTC day.
- [ ] New xUnit tests cover: within limit, exactly at limit, and over limit.

---

## Issue #2 — Reject non-positive transfer amounts

**Labels:** `bug`, `payments`

**Body**

`TransferService.Transfer` accepts any amount, including `0` and negative
values. A negative amount effectively moves money the wrong way (crediting the
source and debiting the destination), and a zero amount posts a meaningless
ledger entry.

Reject non-positive amounts before any balance is changed.

**Acceptance criteria**

- [ ] `Transfer` returns a failure result for `amount <= 0` and posts nothing.
- [ ] Positive amounts continue to work as before.
- [ ] New xUnit tests cover a zero amount and a negative amount.

---

## Issue #3 — Speed up the daily statement query

**Labels:** `performance`, `data`

**Body**

`db/reports_slow.sql` filters ledger rows with `CONVERT(date, PostedAt) = @Day`,
which is non-SARGable and forces a full scan. There is no supporting index.

Rewrite the query to a SARGable half-open range on `PostedAt`, and add a
supporting index declaratively via Atlas (`atlas/schema.hcl`).

**Acceptance criteria**

- [ ] The rewritten query uses a range predicate
      (`PostedAt >= @Day AND PostedAt < DATEADD(day, 1, @Day)`) and returns the
      same rows.
- [ ] A supporting index on `LedgerEntries` is added in `atlas/schema.hcl` and a
      migration is generated.
- [ ] The execution plan shows an index seek rather than a scan.

---

## Issue #4 — Modernise InterestCalc rounding to banker's rounding, 2dp

**Labels:** `bug`, `legacy`, `delphi`

**Body**

`legacy/InterestCalc.pas` computes monthly interest by truncating
(`Trunc`) to 2 decimal places. Truncation understates interest and is not the
bank's rounding policy. Switch to banker's rounding (round half to even) at 2
decimal places without changing the public function signature.

**Acceptance criteria**

- [ ] `CalculateMonthlyInterest` rounds to 2dp using banker's rounding.
- [ ] The public signature is unchanged.
- [ ] The DUnitX rounding test in `tests/dunitx/InterestCalcTests.pas` passes.
