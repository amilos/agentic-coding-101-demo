namespace NorthBank.PaymentService;

/// <summary>
/// Describes the outcome of a transfer attempt.
/// </summary>
public record TransferResult(bool Success, string Message)
{
    /// <summary>
    /// Returns a success result for a posted transfer.
    /// </summary>
    public static TransferResult Ok() => new(true, "Transfer posted.");

    /// <summary>
    /// Returns a failure result with the supplied message.
    /// </summary>
    public static TransferResult Fail(string message) => new(false, message);
}

/// <summary>
/// Moves funds between two NorthBank accounts and records the movement in the ledger.
/// </summary>
public class TransferService
{
    private readonly ILedger _ledger;

    /// <summary>
    /// Creates a transfer service backed by the supplied ledger.
    /// </summary>
    public TransferService(ILedger ledger) => _ledger = ledger;

    /// <summary>
    /// Attempts to move funds between two accounts and posts the transfer if validation succeeds.
    /// </summary>
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

        var dailyTotal = _ledger.SumTransfersToday(fromId);
        if (dailyTotal + amount > from.DailyTransferLimit)
        {
            return TransferResult.Fail($"Daily transfer limit exceeded for source account '{fromId}'.");
        }

        from.Balance -= amount;
        to.Balance += amount;
        _ledger.AddEntry(new LedgerEntry(fromId, toId, amount, DateTime.UtcNow));

        return TransferResult.Ok();
    }
}
