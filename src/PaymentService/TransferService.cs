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
    private readonly object _transferLock = new();
    private readonly Dictionary<string, TransferResult> _successfulTransfers = new(StringComparer.Ordinal);

    public TransferService(ILedger ledger) => _ledger = ledger;

    public TransferResult Transfer(string fromId, string toId, decimal amount, string idempotencyKey)
    {
        if (string.IsNullOrWhiteSpace(idempotencyKey))
        {
            return TransferResult.Fail("An idempotency key is required.");
        }

        lock (_transferLock)
        {
            if (_successfulTransfers.TryGetValue(idempotencyKey, out var replayResult))
            {
                return replayResult;
            }

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

            var result = TransferResult.Ok();
            _successfulTransfers[idempotencyKey] = result;
            return result;
        }
    }
}
