-- Daily statement query for a single account.
--
-- This is the optimisation target for Station 4c. The predicate wraps the
-- PostedAt column in CONVERT(date, ...), which is non-SARGable: SQL Server
-- cannot seek an index on PostedAt and must scan every ledger row. There is
-- also no supporting index on (FromAccount / ToAccount, PostedAt).

DECLARE @AccountId VARCHAR(16) = '1001';
DECLARE @Day       DATE        = '2026-06-30';

SELECT  e.EntryId,
        e.FromAccount,
        e.ToAccount,
        e.Amount,
        e.PostedAt
FROM    dbo.LedgerEntries AS e
WHERE   CONVERT(date, e.PostedAt) = @Day
    AND (e.FromAccount = @AccountId OR e.ToAccount = @AccountId)
ORDER BY e.PostedAt;
