namespace NorthBank.PaymentService;

/// <summary>
/// A NorthBank customer account. Money is always represented with <see cref="decimal"/>.
/// </summary>
public record Account
{
    public required string Id { get; init; }
    public required string Owner { get; init; }
    public decimal Balance { get; set; }
    public decimal DailyTransferLimit { get; init; }
    public string Currency { get; init; } = "GBP";
}
