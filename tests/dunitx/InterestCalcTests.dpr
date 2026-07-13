program InterestCalcTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  uInterestCalc in '..\..\legacy\InterestCalc.pas',
  InterestCalcTests in 'InterestCalcTests.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
begin
  try
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;

    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);

    Results := Runner.Execute;

    if not Results.AllPassed then
      System.ExitCode := 1;
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
