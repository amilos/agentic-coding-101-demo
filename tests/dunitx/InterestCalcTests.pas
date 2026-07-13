unit InterestCalcTests;

{ DUnitX tests for uInterestCalc.CalculateMonthlyInterest. }

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

    [Test]
    procedure TestHalfCentRoundsToEvenCent;

    [Test]
    procedure TestHalfCentRoundsUpToEvenCent;
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
  // Rounding to 2dp gives 0.42.
  Assert.AreEqual(Currency(0.42), CalculateMonthlyInterest(100.00, 5.0));
end;

procedure TInterestCalcTests.TestHalfCentRoundsToEvenCent;
begin
  // 1.00 at 6% p.a. yields exactly 0.005 monthly, halfway to 0.01.
  Assert.AreEqual(Currency(0.00), CalculateMonthlyInterest(1.00, 6.0));
end;

procedure TInterestCalcTests.TestHalfCentRoundsUpToEvenCent;
begin
  // 1.00 at 18% p.a. yields exactly 0.015 monthly, halfway to 0.02.
  Assert.AreEqual(Currency(0.02), CalculateMonthlyInterest(1.00, 18.0));
end;

initialization
  TDUnitX.RegisterTestFixture(TInterestCalcTests);

end.
