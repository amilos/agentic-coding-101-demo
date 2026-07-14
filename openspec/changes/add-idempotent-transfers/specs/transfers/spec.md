# Spec delta: transfers — idempotency

## ADDED Requirements

### Requirement: Transfers are idempotent by client key

`TransferService.Transfer` SHALL accept a client-supplied idempotency key and
SHALL ensure that repeating a request with the same key does not post more than
once.

#### Scenario: First request with a key posts
- **GIVEN** account 1001 has sufficient balance and remaining daily allowance
- **WHEN** `Transfer(1001, 1002, 50, key: "k-1")` is called for the first time
- **THEN** the transfer posts, balances update, one ledger entry is written
- **AND** the key `"k-1"` is recorded with the successful result

#### Scenario: Exact replay returns the original result
- **GIVEN** `Transfer(1001, 1002, 50, key: "k-1")` has already posted
- **WHEN** the same call `Transfer(1001, 1002, 50, key: "k-1")` is repeated
- **THEN** the original `TransferResult` is returned
- **AND** no balance changes and no new ledger entry is written

#### Scenario: A new key posts a new transfer
- **GIVEN** key `"k-1"` has been used
- **WHEN** `Transfer(1001, 1002, 50, key: "k-2")` is called
- **THEN** a new transfer posts as usual

#### Scenario: An empty key is rejected
- **WHEN** `Transfer(1001, 1002, 50, key: "")` is called
- **THEN** a failed `TransferResult` is returned and nothing is posted

#### Scenario: Replaying a rejected transfer replays the rejection
- **GIVEN** `Transfer(1001, 1002, 999999, key: "k-3")` was rejected (over limit)
- **WHEN** the same call is repeated with key `"k-3"`
- **THEN** the same rejection is returned and nothing is posted
