using NorthBank.PaymentService;
using Xunit;

namespace NorthBank.PaymentService.Tests;

public class TransferServiceTests
{
    private static (TransferService service, InMemoryLedger ledger) BuildService(decimal balance = 500.00m, decimal dailyTransferLimit = 1000.00m)
    {
        var accounts = new[]
        {
            new Account { Id = "1001", Owner = "Ada Okafor", Balance = balance, DailyTransferLimit = dailyTransferLimit },
            new Account { Id = "1002", Owner = "Ben Ferreira", Balance = 250.00m, DailyTransferLimit = dailyTransferLimit },
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

    [Theory]
    [InlineData(0.00)]
    [InlineData(-50.00)]
    public void Transfer_RejectsNonPositiveAmountsWithoutChangingBalancesOrLedger(decimal amount)
    {
        var (service, ledger) = BuildService(balance: 1500.00m);
        var initialFromBalance = ledger.GetAccount("1001")!.Balance;
        var initialToBalance = ledger.GetAccount("1002")!.Balance;
        var initialEntryCount = ledger.EntryCount;

        var result = service.Transfer("1001", "1002", amount);

        Assert.False(result.Success);
        Assert.Equal("Transfer amount must be greater than zero.", result.Message);
        Assert.Equal(initialFromBalance, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(initialToBalance, ledger.GetAccount("1002")!.Balance);
        Assert.Equal(initialEntryCount, ledger.EntryCount);
    }

    [Fact]
    public void Transfer_FailsWhenDailyLimitWouldBeExceeded()
    {
        var (service, ledger) = BuildService(balance: 1500.00m);

        var firstTransfer = service.Transfer("1001", "1002", 800.00m);
        var secondTransfer = service.Transfer("1001", "1002", 300.00m);

        Assert.True(firstTransfer.Success);
        Assert.False(secondTransfer.Success);
        Assert.Equal("Daily transfer limit exceeded.", secondTransfer.Message);
        Assert.Equal(700.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(1050.00m, ledger.GetAccount("1002")!.Balance);
    }

    [Fact]
    public void Transfer_AllowsTransferUpToDailyLimit()
    {
        var (service, ledger) = BuildService(balance: 1500.00m);

        var result = service.Transfer("1001", "1002", 1000.00m);

        Assert.True(result.Success);
        Assert.Equal(500.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(1250.00m, ledger.GetAccount("1002")!.Balance);
    }

    [Fact]
    public async Task Transfer_EnforcesDailyLimitAcrossConcurrentCalls()
    {
        var (service, ledger) = BuildService(balance: 2000.00m, dailyTransferLimit: 1000.00m);

        var results = await Task.WhenAll(
            Task.Run(() => service.Transfer("1001", "1002", 600.00m)),
            Task.Run(() => service.Transfer("1001", "1002", 600.00m)));

        Assert.Equal(1, results.Count(result => result.Success));
        Assert.Equal(1400.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(850.00m, ledger.GetAccount("1002")!.Balance);
        Assert.Equal(1, ledger.EntryCount);
    }
}
