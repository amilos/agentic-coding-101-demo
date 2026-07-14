# ADR 0001: Idempotent transfers via a client idempotency key

- **Status:** Accepted — designed in Station 2; to be implemented via the
  `add-idempotent-transfers` OpenSpec change (issue #6).
- **Date:** 2026-07-01

## Context

Callers retry `TransferService.Transfer` on failure (timeouts, dropped
connections). A retry of a request that actually succeeded the first time posts
a **second** ledger entry and moves the money twice — a double-charge.

## Decision

Require a **client-supplied idempotency key** with each transfer. On the first
call for a key, post normally and record the key together with its
`TransferResult`. A later call with the **same key** is a *replay*: return the
stored result, change no balances, and write no new ledger entry.

Alternatives considered and rejected:

- **Natural-key dedupe** (`from`+`to`+`amount` in a time window) — rejects
  legitimately-repeated identical transfers.
- **Time/amount heuristics** — ambiguous and racy under concurrency.

## Consequences

- `Transfer` gains an `idempotencyKey` parameter and a key → result store
  (in-memory for the demo).
- Retries become safe. Key expiry / eviction is out of scope for the demo.
