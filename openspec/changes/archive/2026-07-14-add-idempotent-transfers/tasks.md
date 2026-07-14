## 1. Transfer API and Replay Store

- [x] 1.1 Change `TransferService.Transfer` to require a non-empty `idempotencyKey` and return a failure before any transfer work for an invalid key.
- [x] 1.2 Add process-local storage for successful idempotency-key and `TransferResult` pairs without storing account or owner information.
- [x] 1.3 Synchronize replay lookup, validation, balance movement, ledger posting, and successful-result recording so concurrent requests with the same key cannot post twice.
- [x] 1.4 Return the stored result immediately for a replay, without performing validation or changing balances or ledger entries.

## 2. Callers and Tests

- [x] 2.1 Update `Program.cs` and all existing test call sites to supply idempotency keys.
- [x] 2.2 Add xUnit coverage that a first valid request posts once and records its result.
- [x] 2.3 Add xUnit coverage that an exact-key replay returns the original result with unchanged balances and transfer total.
- [x] 2.4 Add xUnit coverage that otherwise identical transfer details with a distinct key post as a new transfer.
- [x] 2.5 Add xUnit coverage that a blank idempotency key fails without changing balances or the ledger.
- [x] 2.6 Add xUnit coverage that concurrent requests sharing a key produce only one posted transfer.

## 3. Verification

- [x] 3.1 Run the PaymentService xUnit test project and confirm all transfer tests pass.
- [x] 3.2 Build `NorthBank.sln` to confirm the breaking transfer API has no remaining callers.
