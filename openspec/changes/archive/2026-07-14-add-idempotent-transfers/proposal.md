## Why

Network timeouts and dropped connections can cause clients to retry a transfer
that was already accepted. The current service posts that retry again, moving
funds twice and creating duplicate ledger entries. A client idempotency key
makes retries safe while preserving legitimate repeated transfers.

## What Changes

- **BREAKING** Add a client-supplied `idempotencyKey` parameter to
  `TransferService.Transfer`.
- Record the result of the first successful invocation for each idempotency key
  in the demo's in-memory persistence.
- Treat a subsequent invocation with the same key as a replay: return the
  original result without changing balances or adding ledger entries.
- Continue to post a new transfer when a different key is supplied, including
  when its transfer details match an earlier request.
- Add xUnit coverage for first posts, replays, and distinct-key posts.

## Capabilities

### New Capabilities

- `transfer-idempotency`: Safely replay a transfer request identified by a
  client-supplied idempotency key.

### Modified Capabilities

- None.

## Impact

- `src/PaymentService/TransferService.cs` public transfer API and its
  in-memory result storage.
- `src/PaymentService/Program.cs` call site.
- `tests/PaymentService.Tests/TransferServiceTests.cs` transfer test coverage.
- Clients must provide an idempotency key when requesting a transfer.
