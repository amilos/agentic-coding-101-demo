# Atlas project configuration for NorthBank.
#
# No Docker required. Provide two SQL Server connection strings via environment
# variables — the target database, and an EMPTY scratch database that Atlas uses
# to normalise schemas and plan migrations:
#
#   NORTHBANK_DB_URL      -> the database Atlas manages (holds your real schema)
#   NORTHBANK_DEV_DB_URL  -> a dedicated EMPTY database Atlas may freely rewrite
#
# Example (SQL Server on localhost — use YOUR host/port, e.g. 1433 or 1443):
#   export NORTHBANK_DB_URL="sqlserver://sa:P%40ssw0rd@localhost:1433?database=NorthBank"
#   export NORTHBANK_DEV_DB_URL="sqlserver://sa:P%40ssw0rd@localhost:1433?database=NorthBank_dev"
# Create the scratch database once:  CREATE DATABASE NorthBank_dev;
# URL-encode special characters in the password (@ -> %40, : -> %3A, / -> %2F).

env "local" {
  src = "file://schema.hcl"
  url = getenv("NORTHBANK_DB_URL")

  # Scratch database Atlas uses to plan migrations safely.
  # Point it at an EMPTY database on your own SQL Server — no Docker needed.
  dev = getenv("NORTHBANK_DEV_DB_URL")

  migration {
    dir = "file://migrations"
  }

  format {
    migrate {
      diff = "{{ sql . \"  \" }}"
    }
  }
}
