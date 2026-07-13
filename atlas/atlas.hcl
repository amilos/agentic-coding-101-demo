# Atlas project configuration for NorthBank.
#
# Connection strings are hard-coded for the LOCAL TRAINING DEMO — SQL Server in the
# "sql2025" container on localhost:1443, sa / Password123. This keeps the 3-minute
# Station 4 exercise friction-free (no env vars). For real/shared use, switch these
# back to getenv("NORTHBANK_DB_URL") / getenv("NORTHBANK_DEV_DB_URL").
#
# Create both databases first:   pwsh ./scripts/create-databases.ps1
#   NorthBank      -> the schema Atlas manages
#   NorthBank_dev  -> an EMPTY scratch DB Atlas uses to plan migrations (no Docker needed)

env "local" {
  src = "file://schema.hcl"
  url = "sqlserver://sa:Password123@localhost:1443?database=NorthBank"

  # Scratch database Atlas rewrites freely — must be empty and dedicated.
  dev = "sqlserver://sa:Password123@localhost:1443?database=NorthBank_dev"

  migration {
    dir = "file://migrations"
  }

  format {
    migrate {
      diff = "{{ sql . \"  \" }}"
    }
  }
}
