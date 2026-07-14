# Tasks: add-idempotent-transfers

Ticked off during `openspec apply`.

## 1. Key → result store
- [ ] 1.1 Add an in-memory store mapping `idempotencyKey → TransferResult`
      (in `TransferService`, or exposed via `ILedger`).

## 2. Idempotency in TransferService
- [ ] 2.1 Add `string idempotencyKey` to `Transfer(...)`.
- [ ] 2.2 Reject an empty/whitespace key with a clear failed `TransferResult`.
- [ ] 2.3 If the key is already stored, **return the stored result** — no
      balance change, no ledger entry.
- [ ] 2.4 Otherwise run the existing transfer logic (incl. the daily limit),
      then store the key with the produced result (success **or** failure).

## 3. Tests (xUnit)
- [ ] 3.1 First call with a key posts normally.
- [ ] 3.2 Exact replay (same key) returns the original result; balances and
      ledger are unchanged (assert ledger entry count does not increase).
- [ ] 3.3 A different key posts a new transfer.
- [ ] 3.4 Empty key is rejected.
- [ ] 3.5 Replaying a *rejected* transfer returns the same rejection and posts
      nothing.

## 4. Verify
- [ ] 4.1 `dotnet test` green.
- [ ] 4.2 `openspec validate add-idempotent-transfers` passes.
