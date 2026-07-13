-- NorthBank core schema (SQL Server / T-SQL).

IF SCHEMA_ID(N'dbo') IS NULL
    EXEC(N'CREATE SCHEMA dbo');
GO

IF OBJECT_ID(N'dbo.Accounts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Accounts
    (
        AccountId   VARCHAR(16)     NOT NULL CONSTRAINT PK_Accounts PRIMARY KEY,
        Owner       NVARCHAR(200)   NOT NULL,
        Balance     DECIMAL(19, 4)  NOT NULL CONSTRAINT DF_Accounts_Balance DEFAULT (0),
        Currency    CHAR(3)         NOT NULL CONSTRAINT DF_Accounts_Currency DEFAULT ('GBP')
    );
END
GO

IF OBJECT_ID(N'dbo.LedgerEntries', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LedgerEntries
    (
        EntryId     BIGINT          NOT NULL IDENTITY(1, 1) CONSTRAINT PK_LedgerEntries PRIMARY KEY,
        FromAccount VARCHAR(16)     NOT NULL,
        ToAccount   VARCHAR(16)     NOT NULL,
        Amount      DECIMAL(19, 4)  NOT NULL,
        PostedAt    DATETIME2(3)    NOT NULL CONSTRAINT DF_LedgerEntries_PostedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT FK_LedgerEntries_From FOREIGN KEY (FromAccount) REFERENCES dbo.Accounts (AccountId),
        CONSTRAINT FK_LedgerEntries_To   FOREIGN KEY (ToAccount)   REFERENCES dbo.Accounts (AccountId)
    );
END
GO

-- Seed data used across the demos.
IF NOT EXISTS (SELECT 1 FROM dbo.Accounts WHERE AccountId = '1001')
    INSERT dbo.Accounts (AccountId, Owner, Balance, Currency)
    VALUES ('1001', N'Ada Okafor', 500.00, 'GBP'),
           ('1002', N'Ben Ferreira', 250.00, 'GBP');
GO
