# Atlas project configuration for NorthBank.
# Set NORTHBANK_DB_URL to your SQL Server connection string, e.g.
#   sqlserver://sa:P%40ssw0rd@localhost:1433?database=NorthBank

env "local" {
  src = "file://schema.hcl"
  url = getenv("NORTHBANK_DB_URL")

  # A separate throwaway database Atlas uses to plan migrations safely.
  dev = "docker://sqlserver/2022-latest/dev"

  migration {
    dir = "file://migrations"
  }

  format {
    migrate {
      diff = "{{ sql . \"  \" }}"
    }
  }
}
