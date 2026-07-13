namespace NorthBank.PaymentService;

public record TransferResult(bool Success, string Message)
{
    public static TransferResult Ok() => new(true, "Transfer posted.");
    public static TransferResult Fail(string message) => new(false, message);
}

/// <summary>
/// Moves funds between two NorthBank accounts and records the movement in the ledger.
/// </summary>
public class TransferService
{
    private readonly ILedger _ledger;

    public TransferService(ILedger ledger) => _ledger = ledger;

    public TransferResult Transfer(string fromId, string toId, decimal amount)
    {
        var from = _ledger.GetAccount(fromId);
        var to = _ledger.GetAccount(toId);

        if (from is null)
        {
            return TransferResult.Fail($"Unknown source account '{fromId}'.");
        }

        if (to is null)
        {
            return TransferResult.Fail($"Unknown destination account '{toId}'.");
        }

        if (from.Currency != to.Currency)
        {
            return TransferResult.Fail("Currency mismatch between accounts.");
        }

        if (from.Balance < amount)
        {
            return TransferResult.Fail("Insufficient funds.");
        }

        from.Balance -= amount;
        to.Balance += amount;
        _ledger.AddEntry(new LedgerEntry(fromId, toId, amount, DateTime.UtcNow));

        return TransferResult.Ok();
    }
}
