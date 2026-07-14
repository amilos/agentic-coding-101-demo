# Project: NorthBank core

NorthBank is a fictional retail bank core used for training. This service owns
**accounts, funds transfers, and the ledger** (monthly interest and statements
live in adjacent components).

## Tech

- **`PaymentService`** — .NET (`net8.0`) class library + console, C#.
- Money is always `decimal` (`Currency`), never floating point.
- In-memory persistence for the demo (`InMemoryLedger`).

## Key types

- `Account` — `{ string Id; string Owner; decimal Balance; decimal DailyTransferLimit; string Currency; }`
- `ILedger` / `InMemoryLedger` — stores accounts and a list of
  `LedgerEntry(from, to, amount, timestamp)`.
- `TransferService` — `TransferResult Transfer(string fromId, string toId, decimal amount)`.

## Conventions

- Every transfer path must be validated before any balance moves.
- Ledger entries must balance (a debit has a matching credit).
- No PII (account numbers, owner names, emails) written to logs or console.
- Tests are xUnit under `tests/PaymentService.Tests`.

## Current state (relevant to open changes)

- The per-account **daily transfer limit is enforced** (shipped from the earlier
  stations — merged to `main`).
- Transfers are **not yet idempotent**: retrying a `Transfer` that already
  succeeded posts a second time and double-charges. Closing that gap is the
  `add-idempotent-transfers` change — designed in
  `docs/adr/0001-idempotent-transfers.md` and tracked as issue #6.
