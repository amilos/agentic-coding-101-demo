using NorthBank.PaymentService;

var accounts = new[]
{
    new Account { Id = "1001", Owner = "Ada Okafor",  Balance = 500.00m, DailyTransferLimit = 1000.00m },
    new Account { Id = "1002", Owner = "Ben Ferreira", Balance = 250.00m, DailyTransferLimit = 1000.00m },
};

var ledger = new InMemoryLedger(accounts);
var transfers = new TransferService(ledger);

Console.WriteLine("NorthBank sample transfer");
Console.WriteLine($"Before: 1001={ledger.GetAccount("1001")!.Balance:C} 1002={ledger.GetAccount("1002")!.Balance:C}");

var result = transfers.Transfer("1001", "1002", 75.00m, "sample-transfer-1");
Console.WriteLine($"Transfer 75.00 from 1001 to 1002: {result.Message}");

Console.WriteLine($"After:  1001={ledger.GetAccount("1001")!.Balance:C} 1002={ledger.GetAccount("1002")!.Balance:C}");
