# Change: add-idempotent-transfers

Source: issue #6 · design: `docs/adr/0001-idempotent-transfers.md`

## Why

Callers retry `TransferService.Transfer` on failure. A retry of a request that
already succeeded posts a second ledger entry and moves the money twice — a
double-charge. Transfers must be safe to retry.

## What changes

Introduce a **client idempotency key** on `Transfer`:

- `Transfer` accepts an `idempotencyKey`.
- The first call for a key posts normally; the key and its resulting
  `TransferResult` are recorded.
- A later call with the **same key** is a *replay*: return the stored result,
  move no money, write no new ledger entry.
- A call with a **new key** posts a new transfer as usual.

## Scope

- **In scope:** the idempotency key parameter, an in-memory key → result store,
  replay behaviour, and xUnit coverage.
- **Out of scope:** key expiry / eviction, cross-process persistence, and the
  daily-limit rule (already shipped).

## Impact

- **Specs:** adds requirements under `specs/transfers/`.
- **Code:** `TransferService.cs` (record/replay), a small key → result store.
- **Tests:** `tests/PaymentService.Tests/TransferServiceTests.cs`.
- **Behaviour:** retried transfers with the same key are safe; first-time and
  distinct-key transfers are unaffected.
