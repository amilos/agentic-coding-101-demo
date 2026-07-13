---
name: banking-review
description: Reviews a code diff against NorthBank core-banking rules — money must use decimal/Currency (never float/double), no PII in logs, every transfer path validated, and ledger entries balanced. Use before merging changes that touch payments, accounts, or the ledger.
---

# Banking review

Review the supplied diff (or the current staged changes) against NorthBank's
core-banking rules. Report each finding with the file, the line, the rule it
breaks, and a concrete fix. If everything passes, say so explicitly.

## Rules to enforce

1. **Money is `decimal` / `Currency`, never `float` or `double`.**
   Flag any monetary field, parameter, calculation, or column that uses a
   binary floating-point type. Interest, balances, amounts, and rates that feed
   a balance must stay in exact decimal arithmetic.

2. **No PII in logs or console output.**
   Flag any log, `Console.Write`, exception message, or trace that emits
   account numbers, owner names, or email addresses. Suggest redaction
   (e.g. mask all but the last 4 digits of an account id).

3. **Every transfer path is validated.**
   A transfer must reject: unknown accounts, currency mismatch, insufficient
   funds, **non-positive amounts**, and amounts that would exceed the
   account's **DailyTransferLimit**. Flag any path that mutates a balance
   without all of these guards.

4. **Ledger entries balance.**
   Every posted transfer must debit the source and credit the destination by
   the same amount and write exactly one ledger entry. Flag one-sided updates,
   missing ledger writes, or entries whose amount differs from the balance
   change.

## Output format

- **Summary** — one line: pass, or N issues found.
- **Findings** — a numbered list; each item: `file:line` — rule — problem — fix.
- **Suggested tests** — any missing test that would have caught a finding.
