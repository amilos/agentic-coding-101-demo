using NorthBank.PaymentService;
using Xunit;

namespace NorthBank.PaymentService.Tests;

public class TransferServiceTests
{
    private static (TransferService service, InMemoryLedger ledger) BuildService(decimal dailyTransferLimit = 1000.00m, decimal sourceBalance = 500.00m, decimal destinationBalance = 250.00m)
    {
        var accounts = new[]
        {
            new Account { Id = "1001", Owner = "Ada Okafor", Balance = sourceBalance, DailyTransferLimit = dailyTransferLimit },
            new Account { Id = "1002", Owner = "Ben Ferreira", Balance = destinationBalance, DailyTransferLimit = dailyTransferLimit },
        };
        var ledger = new InMemoryLedger(accounts);
        return (new TransferService(ledger), ledger);
    }

    [Fact]
    public void Transfer_MovesFundsBetweenAccounts_OnHappyPath()
    {
        var (service, ledger) = BuildService();

        var result = service.Transfer("1001", "1002", 100.00m);

        Assert.True(result.Success);
        Assert.Equal(400.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(350.00m, ledger.GetAccount("1002")!.Balance);
    }

    [Fact]
    public void Transfer_AllowsTransferWithinDailyLimit()
    {
        var (service, ledger) = BuildService(sourceBalance: 1000.00m, destinationBalance: 100.00m);

        var result = service.Transfer("1001", "1002", 400.00m);

        Assert.True(result.Success);
        Assert.Equal(600.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(500.00m, ledger.GetAccount("1002")!.Balance);
    }

    [Fact]
    public void Transfer_AllowsTransferExactlyAtDailyLimit()
    {
        var (service, ledger) = BuildService(sourceBalance: 1000.00m, destinationBalance: 100.00m);
        ledger.AddEntry(new LedgerEntry("1001", "1002", 600.00m, DateTime.UtcNow));

        var result = service.Transfer("1001", "1002", 400.00m);

        Assert.True(result.Success);
        Assert.Equal(600.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(500.00m, ledger.GetAccount("1002")!.Balance);
    }

    [Fact]
    public void Transfer_RejectsTransferThatWouldExceedDailyLimit()
    {
        var (service, ledger) = BuildService(sourceBalance: 1000.00m, destinationBalance: 100.00m);
        ledger.AddEntry(new LedgerEntry("1001", "1002", 700.00m, DateTime.UtcNow));

        var result = service.Transfer("1001", "1002", 400.00m);

        Assert.False(result.Success);
        Assert.Equal("Daily transfer limit exceeded for source account '1001'.", result.Message);
        Assert.Equal(1000.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(100.00m, ledger.GetAccount("1002")!.Balance);
    }
}
