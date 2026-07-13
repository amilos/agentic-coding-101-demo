# ADR-0001: Make transfer posting idempotent with a durable request record

## Status

Accepted

## Date

2026-07-13

## Context

Clients retry a transfer when a timeout, connection failure, or other uncertain
outcome occurs. Today `TransferService.Transfer` accepts only source account,
destination account, and amount; `dbo.PostTransaction` accepts the same
information and always inserts a new `LedgerEntries` row. Repeating either call
therefore debits and credits the accounts again.

The transfer operation changes two account balances and creates the audit
record. A retry must either return the original result or report a request-key
conflict; it must never post a second movement. Concurrent delivery of the same
retry must have the same property. The solution must preserve SQL Server as the
authoritative transaction boundary and must work for both the C# service and
the T-SQL posting path.

## Decision

Require every transfer command to include a caller-generated, opaque
`IdempotencyKey`. Add a durable `TransferRequests` table with a unique primary
key on that value, the transfer fields, a canonical request fingerprint, the
outcome, the ledger entry identifier when posted, and the response data needed
to replay the result.

The application and `dbo.PostTransaction` will pass the key, source account,
destination account, amount, and fingerprint to one database posting
procedure. That procedure will perform all of the following in one SQL Server
transaction:

1. Read or create the request record under serializable/key-range protection.
2. If the key already exists, compare its fingerprint. Return its stored result
   when it matches; reject the request when it differs.
3. For a new request, validate the transfer, update both account balances,
   insert exactly one ledger entry, and store the successful result and ledger
   entry ID in the request record.
4. Store a deterministic business rejection as the request result so a retry
   receives the same result without a later post.

The unique constraint is the final concurrency guard. The procedure must lock
the two account rows in a stable account-ID order before changing balances to
avoid opposite-direction transfers deadlocking. Unexpected infrastructure
failures roll back the entire transaction, including the request record, so a
later retry can safely attempt the transfer.

The service returns the original outcome for a repeated key; it does not
silently turn a replay into a new transfer. Clients must retain a key until
they no longer retry the command. Request records will have a retention period
that exceeds the maximum client retry window and applicable audit requirements.

## Alternatives Considered

### Unique idempotency key on `LedgerEntries`

Add an `IdempotencyKey` column and unique index to `LedgerEntries`, then treat a
duplicate-key error as an already-posted transfer.

- Pros: smallest schema change; uniqueness directly protects the audit record.
- Cons: a ledger row does not retain enough information to replay validation
  failures or an API response, detect a key reused with different input, or
  distinguish a concurrent request still being processed. The service also
  needs extra query and error-handling logic around duplicate-key exceptions.
- Rejected: it protects successful posts but gives weak, ambiguous semantics for
  retries and key misuse.

### Durable transfer-request record (chosen)

Record a keyed command and its outcome, and post the ledger entry in the same
database transaction.

- Pros: gives an explicit retry contract, detects key reuse with altered
  parameters, replays both successful and deterministic rejected results, and
  makes the database enforce the invariant across all callers.
- Cons: adds a table, a procedure contract, key-retention operations, and a
  required idempotency-key field for callers.
- Chosen: the request record models the client command separately from its
  financial posting while keeping the decision and posting atomic.

### Application-side cache or distributed lock

Have the C# service remember recently completed keys in memory, Redis, or a
distributed lock service before calling the current posting procedure.

- Pros: can be added at the service edge and may reduce duplicate work.
- Cons: cache eviction, lock expiry, process restarts, and network partitions
  reintroduce duplicate posting. It cannot make the balance updates and ledger
  insert atomic with the deduplication decision, and it does not protect direct
  database callers.
- Rejected: an advisory external mechanism is insufficient for a money-movement
  invariant.

## Consequences

- `TransferService.Transfer` and its public callers must accept and propagate
  `IdempotencyKey`; the current three-argument operation is not a safe retry
  interface.
- The database schema and Atlas definition must add `TransferRequests`, its
  unique key, and an appropriate ledger-entry relationship.
- `dbo.PostTransaction` becomes the sole database posting path and owns
  deduplication, validation, balance movement, ledger insertion, and result
  replay in one transaction.
- Tests must cover sequential and concurrent retries with the same key,
  request-key reuse with a changed payload, retry after a deterministic
  rejection, and rollback after an injected posting failure.
- Monitoring should count replayed requests and key/payload conflicts without
  logging account identifiers, names, full keys, or other customer data.
