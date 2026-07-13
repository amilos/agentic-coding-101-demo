unit InterestCalcTests;

{ DUnitX tests for uInterestCalc.CalculateMonthlyInterest.

  NOTE: TestRoundingToTwoDecimalPlaces is EXPECTED TO FAIL against the current
  implementation. CalculateMonthlyInterest uses Trunc rather than banker's
  rounding to 2dp, so amounts that should round up are truncated down. The
  failing test motivates the Station 5a/5b fix and should pass once rounding
  is corrected. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TInterestCalcTests = class
  public
    [Test]
    procedure TestZeroBalanceEarnsNothing;

    [Test]
    procedure TestSimpleMonthlyInterest;

    [Test]
    procedure TestRoundingToTwoDecimalPlaces;
  end;

implementation

uses
  System.SysUtils,
  uInterestCalc;

procedure TInterestCalcTests.TestZeroBalanceEarnsNothing;
begin
  Assert.AreEqual(Currency(0.00), CalculateMonthlyInterest(0.00, 5.0));
end;

procedure TInterestCalcTests.TestSimpleMonthlyInterest;
begin
  // 1200.00 at 12% p.a. => 1% per month => 12.00 exactly.
  Assert.AreEqual(Currency(12.00), CalculateMonthlyInterest(1200.00, 12.0));
end;

procedure TInterestCalcTests.TestRoundingToTwoDecimalPlaces;
begin
  // 100.00 at 5% p.a. => monthly = 100 * (0.05 / 12) = 0.416666...
  // Correct half-even rounding to 2dp gives 0.42. The current Trunc-based
  // implementation yields 0.41, so this assertion fails until the fix.
  Assert.AreEqual(Currency(0.42), CalculateMonthlyInterest(100.00, 5.0));
end;

initialization
  TDUnitX.RegisterTestFixture(TInterestCalcTests);

end.
