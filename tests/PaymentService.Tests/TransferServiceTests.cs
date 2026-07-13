using NorthBank.PaymentService;
using Xunit;

namespace NorthBank.PaymentService.Tests;

public class TransferServiceTests
{
    private static (TransferService service, ILedger ledger) BuildService()
    {
        var accounts = new[]
        {
            new Account { Id = "1001", Owner = "Ada Okafor",  Balance = 500.00m, DailyTransferLimit = 1000.00m },
            new Account { Id = "1002", Owner = "Ben Ferreira", Balance = 250.00m, DailyTransferLimit = 1000.00m },
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
}
