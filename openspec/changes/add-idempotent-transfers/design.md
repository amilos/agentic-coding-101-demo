# Design: add-idempotent-transfers

Implements the decision in `docs/adr/0001-idempotent-transfers.md`.

## Approach

Add `string idempotencyKey` to `TransferService.Transfer`. Keep a store mapping
`idempotencyKey → TransferResult` for keys that have already been processed.

On each call:

1. If the key is already in the store, **return the stored result** immediately —
   no validation side effects, no balance change, no ledger entry (a replay).
2. Otherwise run the existing transfer logic (including the daily-limit check).
3. Record the key with the produced `TransferResult` — **including failures**,
   so retrying a rejected transfer replays the same rejection rather than
   re-running it. (A failed post changed nothing, so this is safe.)

## Key decisions

- **Store scope:** in-memory (`Dictionary<string, TransferResult>` inside the
  service or the ledger) — sufficient for the demo; persistence is out of scope.
- **Cache failures too:** yes — a key identifies a *request*, and replays must be
  deterministic.
- **Empty/missing key:** reject with a clear failed result rather than treating
  "" as a shared key.

## Edge cases

- Same key, different parameters (from/to/amount): return the **original**
  result; do not re-post. (The key is the contract.)
- Concurrent calls with the same key: out of scope for the in-memory demo; note
  a real system needs an atomic check-and-set.

## Alternatives considered

- **Natural-key dedupe** (`from`+`to`+`amount`+window): rejects legitimate
  identical transfers — rejected in ADR 0001.
