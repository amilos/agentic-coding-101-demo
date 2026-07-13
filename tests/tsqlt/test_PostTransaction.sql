-- tSQLt tests for dbo.PostTransaction.
--
-- NOTE: test_rejects_non_positive_amount is EXPECTED TO FAIL against the
-- current procedure. dbo.PostTransaction has no guard for zero/negative
-- amounts, so the failing test motivates the Station 4b fix. Once the proc
-- rejects non-positive amounts, this test will pass.

EXEC tSQLt.NewTestClass 'PostTransactionTests';
GO

CREATE PROCEDURE PostTransactionTests.[test posts a ledger row and moves balances]
AS
BEGIN
    -- Arrange: isolate the tables tSQLt touches.
    EXEC tSQLt.FakeTable 'dbo.Accounts';
    EXEC tSQLt.FakeTable 'dbo.LedgerEntries';

    INSERT dbo.Accounts (AccountId, Owner, Balance, Currency)
        VALUES ('1001', N'Ada Okafor', 500.00, 'GBP'),
               ('1002', N'Ben Ferreira', 250.00, 'GBP');

    -- Act
    EXEC dbo.PostTransaction @FromAccount = '1001', @ToAccount = '1002', @Amount = 100.00;

    -- Assert: balances moved.
    DECLARE @from DECIMAL(19, 4) = (SELECT Balance FROM dbo.Accounts WHERE AccountId = '1001');
    DECLARE @to   DECIMAL(19, 4) = (SELECT Balance FROM dbo.Accounts WHERE AccountId = '1002');

    EXEC tSQLt.AssertEquals @Expected = 400.00, @Actual = @from;
    EXEC tSQLt.AssertEquals @Expected = 350.00, @Actual = @to;

    -- Assert: exactly one ledger row was written.
    DECLARE @rows INT = (SELECT COUNT(*) FROM dbo.LedgerEntries);
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @rows;
END
GO

CREATE PROCEDURE PostTransactionTests.[test rejects non positive amount]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo.Accounts';
    EXEC tSQLt.FakeTable 'dbo.LedgerEntries';

    INSERT dbo.Accounts (AccountId, Owner, Balance, Currency)
        VALUES ('1001', N'Ada Okafor', 500.00, 'GBP'),
               ('1002', N'Ben Ferreira', 250.00, 'GBP');

    -- Act & Assert: a zero amount must raise an error and post nothing.
    EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%non-positive%';
    EXEC dbo.PostTransaction @FromAccount = '1001', @ToAccount = '1002', @Amount = 0.00;

    DECLARE @rows INT = (SELECT COUNT(*) FROM dbo.LedgerEntries);
    EXEC tSQLt.AssertEquals @Expected = 0, @Actual = @rows;
END
GO
