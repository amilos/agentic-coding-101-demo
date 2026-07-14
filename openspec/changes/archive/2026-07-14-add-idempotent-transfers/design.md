## Context

`TransferService.Transfer` currently has no request identity: a client retry
performs the full validation and posting flow a second time. This can
double-charge an account and add a duplicate ledger entry after a timeout or
dropped response. The accepted ADR requires a client-supplied idempotency key.
The demo is a single-process .NET service with in-memory persistence, so
cross-process durability is not available.

## Goals / Non-Goals

**Goals:**

- Make an accepted transfer safe to retry with the same client-supplied key.
- Return the original `TransferResult` on a replay without revalidating,
  modifying balances, or creating another ledger entry.
- Preserve normal posting for each distinct key, including otherwise identical
  transfer details.
- Keep the public API explicit about the required request key and validate it
  before a balance can move.

**Non-Goals:**

- Persisting keys across process restarts or sharing them across service
  instances.
- Key expiry, eviction, or reuse windows.
- Deduplicating requests from their account IDs, amount, or timestamp.
- Changing the existing account, currency, balance, or daily-limit rules.

## Decisions

### Add the key to the transfer API

`TransferService.Transfer` will require a non-empty `string idempotencyKey`
parameter. Blank or whitespace-only keys return a failure before any account
lookup, balance movement, or ledger write.

Requiring callers to supply the key is preferable to generating one in the
service: only a client can reuse the same identity after it loses a response.
A nullable or optional parameter would retain the unsafe path.

### Store successful results by exact key in the service

`TransferService` will own an in-memory dictionary from the exact key string to
the `TransferResult` produced by a successful transfer. A request first checks
this store; a match immediately returns the stored result. A successful
first-use request completes the existing validation and posting flow, then its
result is recorded under the key. Validation or business-rule failures are not
recorded, so a client can correct and retry a rejected request.

Keeping the store next to the transfer operation minimizes changes to
`ILedger`, which models accounts and posted ledger entries rather than request
execution state. Storing only the key and result avoids retaining account
identifiers or owner information in the replay store.

Natural-key deduplication by source, destination, amount, and time window was
rejected because it would suppress legitimate repeated payments. Time- or
amount-based heuristics have the same ambiguity and are prone to races.

### Make check, post, and record atomic for this in-memory service

The service will synchronize the replay lookup, balance movement, ledger write,
and successful-result recording as one critical section. This prevents two
concurrent requests using the same key from both observing an absent key and
posting twice. The lock is scoped to a `TransferService` instance, matching the
in-memory demo's process-local persistence model.

## Risks / Trade-offs

- [Keys and results disappear on restart] -> This is accepted for the
  in-memory demo; production persistence is explicitly out of scope.
- [Unbounded in-memory key growth] -> Key expiry and eviction are out of scope;
  document this limitation rather than silently discarding replay protection.
- [A lock serializes transfers per service instance] -> The demo prioritizes
  correctness over throughput; a production implementation would use durable
  uniqueness and transaction controls.
- [A replay key is reused with different request details] -> The previously
  stored result wins because the key is the client-declared request identity;
  clients must generate a fresh key for a new transfer.

## Migration Plan

1. Change all in-repository `Transfer` callers to provide a newly generated or
   fixed test idempotency key.
2. Add replay and distinct-key tests before releasing the API change.
3. Deploy the API change with the in-memory replay store empty. A process
   restart clears the store and is the rollback path for this demo.

## Open Questions

- None for the demo scope. Durable key storage, retention policy, and
  cross-instance coordination require a future production-oriented change.
