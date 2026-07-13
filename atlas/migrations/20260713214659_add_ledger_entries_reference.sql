-- Create "Accounts" table
CREATE TABLE [Accounts] (
  [AccountId] varchar(16) NOT NULL,
  [Owner] nvarchar(200) NOT NULL,
  [Balance] decimal(19,4) NOT NULL,
  [Currency] char(3) NOT NULL,
  CONSTRAINT [PK_Accounts] PRIMARY KEY CLUSTERED ([AccountId] ASC)
);
-- Create "LedgerEntries" table
CREATE TABLE [LedgerEntries] (
  [EntryId] bigint IDENTITY (1, 1) NOT NULL,
  [FromAccount] varchar(16) NOT NULL,
  [ToAccount] varchar(16) NOT NULL,
  [Amount] decimal(19,4) NOT NULL,
  [PostedAt] datetime2(3) NOT NULL,
  [Reference] nvarchar(100) NULL,
  CONSTRAINT [PK_LedgerEntries] PRIMARY KEY CLUSTERED ([EntryId] ASC),
  CONSTRAINT [FK_LedgerEntries_From] FOREIGN KEY ([FromAccount]) REFERENCES [Accounts] ([AccountId]) ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT [FK_LedgerEntries_To] FOREIGN KEY ([ToAccount]) REFERENCES [Accounts] ([AccountId]) ON UPDATE NO ACTION ON DELETE NO ACTION
);
