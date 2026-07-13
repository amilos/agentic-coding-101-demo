# Implementation Plan: Issue #1 Daily Transfer Limit Enforcement

## Overview
Implement daily transfer limit enforcement in `TransferService.Transfer` so a source account cannot transfer more than `DailyTransferLimit` within the same UTC day, while preserving existing successful transfer behavior.

## Architecture Decisions
- Keep enforcement in `TransferService` and use existing `ILedger.SumTransfersToday` rather than adding new persistence plumbing.
- Enforce against projected total (`alreadyTransferredToday + amount`) and fail before any balance mutation or ledger post.
- Keep UTC-day semantics aligned with ledger contract and verify via tests focused on service behavior.
- Use a generic but explicit over-limit rejection message (no numeric limit/remaining interpolation).

## Task List

### Phase 1: Foundation and Test Coverage
- [ ] Task 1: Add xUnit scenarios for daily-limit outcomes
- [ ] Task 2: Add xUnit assertion that rejected over-limit transfers do not mutate balances

### Checkpoint: Foundation
- [ ] New daily-limit tests fail on current behavior and clearly express expected outcomes

### Phase 2: Core Behavior
- [ ] Task 3: Implement daily transfer limit guard in `TransferService.Transfer`
- [ ] Task 4: Ensure failure message is explicit and consistent for over-limit rejection

### Checkpoint: Core Features
- [ ] Tests for within-limit and exactly-at-limit pass
- [ ] Over-limit test passes and confirms no posting side effects

### Phase 3: UTC-Day Semantics and Final Verification
- [ ] Task 5: Add/adjust tests that validate total is measured per source account and per UTC day through ledger-backed behavior
- [ ] Task 6: Run full solution tests to confirm no regressions in existing payment flow

### Checkpoint: Complete
- [ ] All Issue #1 acceptance criteria are satisfied
- [ ] Solution is ready for review

## Edge-Case Test Matrix
| Scenario | Expected result |
|----------|-----------------|
| First transfer of the UTC day is below the limit | Succeeds; the full limit is available before any outgoing transfers are posted. |
| First transfer of the UTC day equals the limit | Succeeds; equality must be permitted. |
| First transfer of the UTC day exceeds the limit | Fails before balances or ledger entries change. |
| Subsequent transfer leaves cumulative total below the limit | Succeeds. |
| Subsequent transfer brings cumulative total exactly to the limit | Succeeds. |
| Subsequent transfer would take cumulative total above the limit | Fails; both account balances remain unchanged and no new entry is added. |
| Prior outgoing transfer belongs to a different source account | Does not consume this source account's allowance. |
| Incoming transfer to the source account | Does not consume the source account's outgoing-transfer allowance. |
| Ledger entry from the prior UTC day | Does not consume today's allowance. |
| Ledger entry within the current UTC day | Is included in today's outgoing total. |
| Rejected over-limit attempt followed by an allowed transfer | The rejected attempt does not consume allowance; the allowed transfer succeeds if its projected total is within limit. |

## Structured Task Breakdown

## Task 1: Create daily-limit behavior tests in TransferServiceTests
**Description:** Add failing tests that define the three required business outcomes for daily-limit handling: within limit succeeds, exactly at remaining limit succeeds, over limit fails.

**Acceptance criteria:**
- [ ] Test covers a transfer that remains below the daily limit and expects success.
- [ ] Test covers a transfer that lands exactly on the daily limit and expects success.
- [ ] Test covers a transfer that exceeds the daily limit and expects failure.
- [ ] Test covers the first transfer of the UTC day with no prior outgoing total.
- [ ] Test covers successive transfers whose cumulative total is below, exactly at, and above the limit.

**Verification:**
- [ ] Tests pass: `dotnet test --filter TransferServiceTests`
- [ ] Build succeeds: `dotnet build NorthBank.sln`
- [ ] Manual check: test names and assertions map directly to Issue #1 acceptance bullets.

**Dependencies:** None

**Files likely touched:**
- `tests/PaymentService.Tests/TransferServiceTests.cs`

**Estimated scope:** S

## Task 2: Add no-side-effects assertions for over-limit failures
**Description:** Expand the over-limit test to explicitly verify there is no balance mutation and no successful post path when rejection occurs.

**Acceptance criteria:**
- [ ] Over-limit failure test asserts source balance remains unchanged.
- [ ] Over-limit failure test asserts destination balance remains unchanged.
- [ ] Failure path assertion is present for rejection message content.

**Verification:**
- [ ] Tests pass: `dotnet test --filter TransferServiceTests`
- [ ] Build succeeds: `dotnet build NorthBank.sln`
- [ ] Manual check: assertions execute against pre/post-transfer balances.

**Dependencies:** Task 1

**Files likely touched:**
- `tests/PaymentService.Tests/TransferServiceTests.cs`

**Estimated scope:** XS

## Task 3: Enforce daily limit in TransferService before mutation
**Description:** Introduce a guard that reads `SumTransfersToday(fromId)`, computes projected daily total, and rejects if the projected total exceeds `from.DailyTransferLimit`.

**Acceptance criteria:**
- [ ] Transfer fails when projected daily outgoing total is above `DailyTransferLimit`.
- [ ] Transfer still succeeds when projected total is at or below `DailyTransferLimit`.
- [ ] Guard executes before balance changes and before ledger posting.

**Verification:**
- [ ] Tests pass: `dotnet test --filter TransferServiceTests`
- [ ] Build succeeds: `dotnet build NorthBank.sln`
- [ ] Manual check: guard appears in control flow before `from.Balance -= amount`.

**Dependencies:** Task 1

**Files likely touched:**
- `src/PaymentService/TransferService.cs`

**Estimated scope:** XS

## Task 4: Return clear over-limit failure message
**Description:** Add a deterministic failure message that clearly communicates daily-limit rejection to satisfy issue clarity requirements.

**Acceptance criteria:**
- [ ] Over-limit rejection returns a clear, user-readable message.
- [ ] Message assertion is covered by tests.
- [ ] Existing success message behavior remains unchanged.

**Verification:**
- [ ] Tests pass: `dotnet test --filter TransferServiceTests`
- [ ] Build succeeds: `dotnet build NorthBank.sln`
- [ ] Manual check: failure text names daily limit context.

**Dependencies:** Task 3

**Files likely touched:**
- `src/PaymentService/TransferService.cs`
- `tests/PaymentService.Tests/TransferServiceTests.cs`

**Estimated scope:** XS

## Task 5: Validate source-account and UTC-day semantics
**Description:** Add tests that prove the daily total is keyed by source account and respects UTC-day boundaries through ledger-backed totals.

**Acceptance criteria:**
- [ ] Tests demonstrate limit calculations are source-account specific.
- [ ] Tests demonstrate totals are evaluated for the current UTC day.
- [ ] Tests demonstrate entries from a prior UTC day do not consume today's allowance.
- [ ] Tests demonstrate incoming and other-account outgoing entries do not consume the source account's allowance.
- [ ] Existing `ILedger.SumTransfersToday` contract remains the single source of daily-total logic.

**Verification:**
- [ ] Tests pass: `dotnet test --filter TransferServiceTests`
- [ ] Build succeeds: `dotnet build NorthBank.sln`
- [ ] Manual check: test setup and assertions explicitly model UTC-day behavior.

**Dependencies:** Tasks 1, 3

**Files likely touched:**
- `tests/PaymentService.Tests/TransferServiceTests.cs`
- `src/PaymentService/Ledger.cs` (only if testability gap requires narrow adjustment)

**Estimated scope:** S

## Task 6: Finalize and run full suite check
**Description:** Run full solution-level checks to confirm the daily-limit change does not break existing payment-service behavior.

**Acceptance criteria:**
- [ ] `NorthBank.sln` builds successfully.
- [ ] Existing happy-path transfer test remains green.
- [ ] New daily-limit tests are green.

**Verification:**
- [ ] Tests pass: `dotnet test`
- [ ] Build succeeds: `dotnet build NorthBank.sln`
- [ ] Manual check: no unintended changes outside daily-limit scope.

**Dependencies:** Tasks 2, 4, 5

**Files likely touched:**
- `src/PaymentService/TransferService.cs`
- `tests/PaymentService.Tests/TransferServiceTests.cs`
- `src/PaymentService/Ledger.cs` (optional, only if needed by Task 5)

**Estimated scope:** XS

## Risks and Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Ambiguity around UTC-day boundary in tests | Medium | Build tests that use ledger semantics explicitly and avoid local-time assumptions |
| Overly brittle message assertions | Low | Assert key phrase stability rather than incidental punctuation |
| Hidden coupling to existing transfer checks | Medium | Keep new guard narrowly placed after account/currency checks and before mutation |

## Open Questions
- None.
