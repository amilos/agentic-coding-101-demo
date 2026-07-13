unit uInterestCalc;

{ NorthBank legacy interest engine.

  CalculateMonthlyInterest returns the interest earned on a balance for a
  single month, given an annual rate expressed as a percentage (e.g. 5.0 for
  5% per annum). Used by the monthly statement run. }

interface

function CalculateMonthlyInterest(Balance: Currency; AnnualRatePercent: Double): Currency;

implementation

function CalculateMonthlyInterest(Balance: Currency; AnnualRatePercent: Double): Currency;
var
  MonthlyRate: Double;
  Raw: Double;
begin
  MonthlyRate := (AnnualRatePercent / 100.0) / 12.0;
  Raw := Balance * MonthlyRate;
  Result := Trunc(Raw * 100) / 100;
end;

end.
