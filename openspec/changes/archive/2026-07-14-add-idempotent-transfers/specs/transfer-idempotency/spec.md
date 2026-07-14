## ADDED Requirements

### Requirement: Client transfer request identity
The transfer service SHALL require a client-supplied, non-empty idempotency key
for every transfer request. The service SHALL reject a missing, empty, or
whitespace-only key before moving a balance or writing a ledger entry.

#### Scenario: Missing idempotency key is rejected
- **WHEN** a caller submits a transfer with an empty or whitespace-only idempotency key
- **THEN** the service returns a failed transfer result
- **AND THEN** no account balance or ledger entry is changed

### Requirement: First use of an idempotency key posts once
The transfer service SHALL process a valid transfer whose idempotency key has
not been used as a new request. After it posts successfully, the service SHALL
record the key with the resulting `TransferResult`.

#### Scenario: First keyed transfer succeeds
- **WHEN** a caller submits a valid transfer with a previously unused idempotency key
- **THEN** the service moves the requested funds and writes one ledger entry
- **AND THEN** the service returns and records a successful transfer result for that key

### Requirement: Idempotent transfer replay
The transfer service SHALL treat a transfer request whose idempotency key has a
recorded successful result as a replay. The service SHALL return that recorded
result without performing transfer validation, changing account balances, or
writing a ledger entry.

#### Scenario: Exact-key retry returns the original result
- **GIVEN** a transfer has successfully posted with an idempotency key
- **WHEN** a caller submits another transfer with the same idempotency key
- **THEN** the service returns the result from the original transfer
- **AND THEN** account balances and the ledger remain unchanged by the replay

#### Scenario: Reused key ignores changed transfer details
- **GIVEN** a transfer has successfully posted with an idempotency key
- **WHEN** a caller submits a request with that same key and different transfer details
- **THEN** the service returns the result from the original transfer
- **AND THEN** account balances and the ledger remain unchanged by the replay

### Requirement: Distinct keys identify distinct transfers
The transfer service SHALL process a valid request with an unrecorded
idempotency key as a new transfer, even when its account IDs and amount match a
previous successful request.

#### Scenario: Identical transfer with a different key posts again
- **GIVEN** a transfer has successfully posted with one idempotency key
- **WHEN** a caller submits the same valid transfer details with a different unused key
- **THEN** the service posts a new transfer and returns a new successful result
