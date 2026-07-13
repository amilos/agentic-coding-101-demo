# NorthBank declarative schema for Atlas (SQL Server / mssql).
# Mirrors db/schema.sql. Applied with:  atlas schema apply --env local

schema "dbo" {
}

table "Accounts" {
  schema = schema.dbo

  column "AccountId" {
    type = varchar(16)
    null = false
  }
  column "Owner" {
    type = nvarchar(200)
    null = false
  }
  column "Balance" {
    type = decimal(19, 4)
    null = false
  }
  column "Currency" {
    type = char(3)
    null = false
  }

  primary_key {
    columns = [column.AccountId]
  }
}

table "LedgerEntries" {
  schema = schema.dbo

  column "EntryId" {
    type = bigint
    null = false
    identity {
      seed      = 1
      increment = 1
    }
  }
  column "FromAccount" {
    type = varchar(16)
    null = false
  }
  column "ToAccount" {
    type = varchar(16)
    null = false
  }
  column "Amount" {
    type = decimal(19, 4)
    null = false
  }
  column "PostedAt" {
    type = datetime2(3)
    null = false
  }

  # Station 4a: add this nullable column declaratively, then generate the
  # migration with `atlas migrate diff`.
  #
  # column "Reference" {
  #   type = nvarchar(100)
  #   null = true
  # }

  primary_key {
    columns = [column.EntryId]
  }

  foreign_key "FK_LedgerEntries_From" {
    columns     = [column.FromAccount]
    ref_columns = [table.Accounts.column.AccountId]
  }
  foreign_key "FK_LedgerEntries_To" {
    columns     = [column.ToAccount]
    ref_columns = [table.Accounts.column.AccountId]
  }
}
