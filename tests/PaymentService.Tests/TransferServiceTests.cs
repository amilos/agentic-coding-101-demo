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
    public void Transfer_PostsFirstUseOfIdempotencyKey()
    {
        var (service, ledger) = BuildService();

        var result = service.Transfer("1001", "1002", 100.00m, "transfer-1");

        Assert.True(result.Success);
        Assert.Equal(400.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(350.00m, ledger.GetAccount("1002")!.Balance);
        Assert.Equal(100.00m, ledger.SumTransfersToday("1001"));
    }

    [Fact]
    public void Transfer_ReplaysSuccessfulRequestWithoutPostingAgain()
    {
        var (service, ledger) = BuildService();

        var first = service.Transfer("1001", "1002", 100.00m, "transfer-2");
        var replay = service.Transfer("missing", "1002", 1000.00m, "transfer-2");

        Assert.True(first.Success);
        Assert.Equal(first, replay);
        Assert.Equal(400.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(350.00m, ledger.GetAccount("1002")!.Balance);
        Assert.Equal(100.00m, ledger.SumTransfersToday("1001"));
    }

    [Fact]
    public void Transfer_PostsAgainForDistinctIdempotencyKey()
    {
        var (service, ledger) = BuildService();

        var first = service.Transfer("1001", "1002", 100.00m, "transfer-3a");
        var second = service.Transfer("1001", "1002", 100.00m, "transfer-3b");

        Assert.True(first.Success);
        Assert.True(second.Success);
        Assert.Equal(300.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(450.00m, ledger.GetAccount("1002")!.Balance);
        Assert.Equal(200.00m, ledger.SumTransfersToday("1001"));
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public void Transfer_RejectsBlankIdempotencyKey(string idempotencyKey)
    {
        var (service, ledger) = BuildService();

        var result = service.Transfer("1001", "1002", 100.00m, idempotencyKey);

        Assert.False(result.Success);
        Assert.Equal(500.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(250.00m, ledger.GetAccount("1002")!.Balance);
        Assert.Equal(0.00m, ledger.SumTransfersToday("1001"));
    }

    [Fact]
    public async Task Transfer_PostsOnlyOnceForConcurrentRequestsWithSameIdempotencyKey()
    {
        var (service, ledger) = BuildService();

        var results = await Task.WhenAll(
            Enumerable.Range(0, 2)
                .Select(_ => Task.Run(() => service.Transfer("1001", "1002", 100.00m, "transfer-4"))));

        Assert.All(results, result => Assert.True(result.Success));
        Assert.Equal(400.00m, ledger.GetAccount("1001")!.Balance);
        Assert.Equal(350.00m, ledger.GetAccount("1002")!.Balance);
        Assert.Equal(100.00m, ledger.SumTransfersToday("1001"));
    }
}
