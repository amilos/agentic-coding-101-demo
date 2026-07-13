# NorthBank demo repository

Starter repository for the **Agentic Coding 101** GitHub Copilot training
course. It models a fictional retail bank, **NorthBank** — accounts, funds
transfers, a ledger, and monthly interest/statements — across four stacks so
attendees can practise agentic workflows end to end:

- **C# / .NET 8** — `src/PaymentService` (payments core) + xUnit tests.
- **T-SQL / SQL Server** — `db/` schema and stored procedure, tSQLt tests,
  and Atlas declarative migrations under `atlas/`.
- **Delphi / Object Pascal** — legacy interest engine (`legacy/`), a Win64 VCL
  statement viewer (`ui/`), DUnitX unit tests, and an Appium/NovaWindows UI
  test.
- **Copilot customisation** — sample skills, a custom agent, and an MCP
  template under `.github/`.

Sample accounts used throughout: **1001** (Ada Okafor) and **1002**
(Ben Ferreira), both GBP.

## Prerequisites

See the course workbook for full setup. In short:

- .NET 8 SDK (`dotnet --version` ≥ 8).
- SQL Server (local or container) for the T-SQL and tSQLt exercises;
  [Atlas](https://atlasgo.io) CLI for migrations.
- RAD Studio / Delphi for the `legacy/` and `ui/` code and DUnitX tests
  (Win64). Note: there is **no native inline Copilot completion inside RAD
  Studio** — drive edits from the Copilot desktop app against the worktree.
- Node.js and Appium 3 for the NovaWindows UI test scaffold (Windows).

## Build & run

### C# (.NET 8)

```bash
# from demo-repo/
dotnet build NorthBank.sln
dotnet run --project src/PaymentService      # sample transfer + balances
dotnet test                                  # xUnit tests (happy path only)
```

### T-SQL (SQL Server)

```powershell
# one-time: create BOTH databases (NorthBank + the empty NorthBank_dev scratch DB).
# Uses local sqlcmd if present, else runs sqlcmd inside the sql2025 container.
pwsh ./scripts/create-databases.ps1
```

```bash
# apply schema + posting procedure, then the tSQLt tests (-C trusts the cert):
sqlcmd -S localhost,1433 -U sa -P Password123 -C -d NorthBank -i db/schema.sql
sqlcmd -S localhost,1433 -U sa -P Password123 -C -d NorthBank -i db/proc_PostTransaction.sql
sqlcmd -S localhost,1433 -U sa -P Password123 -C -d NorthBank -i tests/tsqlt/test_PostTransaction.sql
# then:  EXEC tSQLt.RunAll;
```

### Atlas (declarative migrations)

No Docker, no env vars — the connection strings are baked into `atlas/atlas.hcl` for the
local demo (localhost:1433, sa / Password123; `NorthBank` target + empty `NorthBank_dev`
scratch, both created by the script above).

```bash
cd atlas
atlas schema apply --env local            # apply schema.hcl to NorthBank
atlas migrate diff  --env local           # generate a migration after editing schema.hcl
```

The two databases are separate on purpose: Atlas requires its scratch/dev database to be
**empty and dedicated** (it errors if it isn't clean), so `NorthBank_dev` must not be
`NorthBank`. For real/shared use, switch `atlas.hcl` back to `getenv(...)` URLs.

### Delphi (DUnitX + UI)

- Open `tests/dunitx/InterestCalcTests.dpr` in RAD Studio and run it (Win32
  console) for the unit tests.
- Build `ui/StatementViewer.dpr` to produce `StatementViewer.exe`.

### Appium / NovaWindows (Windows)

```powershell
cd tests/appium
npm install
# Install Appium 3 and its NovaWindows driver, then start the server:
npm install -g appium@3
appium driver install --source=npm appium-novawindows-driver
appium
# In a second terminal, after building ui/StatementViewer.dpr:
$env:STATEMENT_VIEWER_PATH = (Resolve-Path ..\..\ui\StatementViewer.exe).Path
npm test
```

NovaWindows setup and supported UI Automation locators are documented by
the driver at https://github.com/AutomateThePlanet/appium-novawindows-driver.

---

## Planted issues (trainers only)

> This section is for facilitators. The demo repository ships with **two
> deliberate defects** and a set of tests written to fail, so the stations have
> something concrete to plan, implement, and verify. Do not point attendees at
> this section until debrief.

### The gap — no daily transfer limit enforcement

`Account` has a `DailyTransferLimit`, but `TransferService.Transfer`
(`src/PaymentService/TransferService.cs`) never enforces it. `ILedger` already
exposes `SumTransfersToday`, so the fix is a guard, not new plumbing.

- **Raised in:** Station 1 (Plan) as **ISSUES.md issue #1**.
- **Fixed in:** Station 3 (Implement in C#) — add the guard and xUnit tests.

### The bug — non-positive amounts are accepted

`TransferService.Transfer` does not reject `amount <= 0`. A zero amount posts a
meaningless ledger entry; a negative amount moves money the wrong way. The
balance check uses the correct comparison — this is the only C# defect, kept
crisp on purpose.

- **Discovered in:** Station 6 / QA review (and named in Station 3) as
  **ISSUES.md issue #2**.
- **Fixed in:** Station 3 — reject non-positive amounts before any balance
  change; add xUnit tests for zero and negative.

The same theme is mirrored in T-SQL: `dbo.PostTransaction`
(`db/proc_PostTransaction.sql`) has no negative-amount guard either.

### Tests intentionally written to fail

These fail against the **current, unfixed** code and motivate the exercises.
Each file carries a short note to that effect.

- `tests/tsqlt/test_PostTransaction.sql` — the *rejects non-positive amount*
  test fails until `dbo.PostTransaction` guards the amount (Station 4b).
- `tests/dunitx/InterestCalcTests.pas` — the rounding test fails because
  `CalculateMonthlyInterest` truncates instead of using banker's rounding to
  2dp (Station 5a/5b, ISSUES.md issue #4).

### Other exercise targets (not defects, but rough on purpose)

- `db/reports_slow.sql` — a non-SARGable, unindexed statement query;
  optimised in Station 4c (ISSUES.md issue #3).
- `.github/skills/pii-redaction-check/SKILL.md` — a starter skill with a TODO
  body; attendees complete it in Station 6.
