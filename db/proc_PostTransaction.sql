-- Posts a transfer: records a ledger row and moves the balances.

IF OBJECT_ID(N'dbo.PostTransaction', N'P') IS NOT NULL
    DROP PROCEDURE dbo.PostTransaction;
GO

CREATE PROCEDURE dbo.PostTransaction
    @FromAccount VARCHAR(16),
    @ToAccount   VARCHAR(16),
    @Amount      DECIMAL(19, 4)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    UPDATE dbo.Accounts
        SET Balance = Balance - @Amount
        WHERE AccountId = @FromAccount;

    UPDATE dbo.Accounts
        SET Balance = Balance + @Amount
        WHERE AccountId = @ToAccount;

    INSERT dbo.LedgerEntries (FromAccount, ToAccount, Amount, PostedAt)
        VALUES (@FromAccount, @ToAccount, @Amount, SYSUTCDATETIME());

    COMMIT TRANSACTION;
END
GO
