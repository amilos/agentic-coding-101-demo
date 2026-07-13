#requires -Version 5
<#
.SYNOPSIS
  Create the NorthBank (target) and NorthBank_dev (Atlas scratch) databases for
  the Agentic Coding 101 demo. Idempotent — safe to re-run.

.DESCRIPTION
  Uses local `sqlcmd` if it is on PATH (connecting to localhost:1433). If there is
  no local sqlcmd, it runs sqlcmd *inside* the SQL Server container named `sql2025`
  (connecting to localhost:1433 within the container).

  Local demo credentials: sa / Password123. Adjust the variables below if yours differ.
#>

$ErrorActionPreference = 'Stop'

# --- settings ---------------------------------------------------------------
$Sa        = 'sa'
$Password  = 'Password123'
$HostPort  = 'localhost,1433'     # host -> container published port
$Container = 'sql2025'
$Tsql      = "IF DB_ID('NorthBank') IS NULL CREATE DATABASE NorthBank; IF DB_ID('NorthBank_dev') IS NULL CREATE DATABASE NorthBank_dev;"
# ---------------------------------------------------------------------------

function Test-Cmd([string]$name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

if (Test-Cmd 'sqlcmd') {
    Write-Host "-> local sqlcmd against $HostPort"
    # -C trusts the server certificate (required by sqlcmd 18+); -b fails on SQL error.
    & sqlcmd -S $HostPort -U $Sa -P $Password -C -b -Q $Tsql
    if ($LASTEXITCODE -ne 0) { throw "sqlcmd failed (exit $LASTEXITCODE)." }
}
else {
    # No local sqlcmd: run sqlcmd bundled in the container image.
    # NOTE: assumes the container CLI uses docker-style `exec` (podman/docker do;
    # confirm your `wslc` syntax if this path is the one you use).
    $runtime = @('wslc','podman','docker') | Where-Object { Test-Cmd $_ } | Select-Object -First 1
    if (-not $runtime) {
        throw "No local sqlcmd found, and no container runtime (wslc/podman/docker) on PATH."
    }
    Write-Host "-> no local sqlcmd; using '$runtime exec $Container' (in-container sqlcmd)"

    # SQL Server images ship sqlcmd under mssql-tools18 (newer) or mssql-tools (older),
    # or on PATH. Try each until one works.
    $toolPaths = @('/opt/mssql-tools18/bin/sqlcmd', '/opt/mssql-tools/bin/sqlcmd', 'sqlcmd')
    $done = $false
    foreach ($tool in $toolPaths) {
        try {
            & $runtime exec $Container $tool -S localhost -U $Sa -P $Password -C -b -Q $Tsql
            if ($LASTEXITCODE -eq 0) { $done = $true; break }
        }
        catch { }
    }
    if (-not $done) {
        throw "Could not run sqlcmd inside container '$Container'. Check the runtime's exec syntax and the sqlcmd path in the image."
    }
}

Write-Host "OK - databases ready: NorthBank, NorthBank_dev"
