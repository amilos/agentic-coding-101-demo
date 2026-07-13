-- Create index "IX_LedgerEntries_FromAccount_PostedAt" to table: "LedgerEntries"
CREATE NONCLUSTERED INDEX [IX_LedgerEntries_FromAccount_PostedAt] ON [LedgerEntries] ([FromAccount] ASC, [PostedAt] ASC) INCLUDE ([ToAccount], [Amount]);
-- Create index "IX_LedgerEntries_ToAccount_PostedAt" to table: "LedgerEntries"
CREATE NONCLUSTERED INDEX [IX_LedgerEntries_ToAccount_PostedAt] ON [LedgerEntries] ([ToAccount] ASC, [PostedAt] ASC) INCLUDE ([FromAccount], [Amount]);
