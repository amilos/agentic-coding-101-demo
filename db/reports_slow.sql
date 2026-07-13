-- Daily statement query for a single account.

DECLARE @AccountId VARCHAR(16) = '1001';
DECLARE @Day       DATE        = '2026-06-30';

;WITH StatementEntries AS
(
    SELECT  e.EntryId,
            e.FromAccount,
            e.ToAccount,
            e.Amount,
            e.PostedAt
    FROM    dbo.LedgerEntries AS e
    WHERE   e.FromAccount = @AccountId
        AND e.PostedAt >= @Day
        AND e.PostedAt < DATEADD(day, 1, @Day)

    UNION ALL

    SELECT  e.EntryId,
            e.FromAccount,
            e.ToAccount,
            e.Amount,
            e.PostedAt
    FROM    dbo.LedgerEntries AS e
    WHERE   e.ToAccount = @AccountId
        AND e.FromAccount <> @AccountId
        AND e.PostedAt >= @Day
        AND e.PostedAt < DATEADD(day, 1, @Day)
)
SELECT  EntryId,
        FromAccount,
        ToAccount,
        Amount,
        PostedAt
FROM    StatementEntries
ORDER BY PostedAt;
