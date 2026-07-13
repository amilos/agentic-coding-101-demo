namespace NorthBank.PaymentService;

/// <summary>
/// A single posted movement of funds between two accounts.
/// </summary>
public record LedgerEntry(string From, string To, decimal Amount, DateTime Timestamp);

/// <summary>
/// Stores accounts and the ledger of posted transfers.
/// </summary>
public interface ILedger
{
    Account? GetAccount(string id);
    void AddEntry(LedgerEntry entry);

    /// <summary>
    /// Sum of all amounts transferred OUT of <paramref name="accountId"/> today (UTC).
    /// </summary>
    decimal SumTransfersToday(string accountId);
}

public class InMemoryLedger : ILedger
{
    private readonly Dictionary<string, Account> _accounts = new();
    private readonly List<LedgerEntry> _entries = new();

    public InMemoryLedger(IEnumerable<Account> accounts)
    {
        foreach (var account in accounts)
        {
            _accounts[account.Id] = account;
        }
    }

    public int EntryCount => _entries.Count;

    public Account? GetAccount(string id)
        => _accounts.TryGetValue(id, out var account) ? account : null;

    public void AddEntry(LedgerEntry entry) => _entries.Add(entry);

    public decimal SumTransfersToday(string accountId)
    {
        var today = DateTime.UtcNow.Date;
        return _entries
            .Where(e => e.From == accountId && e.Timestamp.Date == today)
            .Sum(e => e.Amount);
    }
}
