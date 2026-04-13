class PaymentCondition {
  final String id;
  final String name;
  final int days;
  final double interestRate;

  const PaymentCondition({
    required this.id,
    required this.name,
    this.days = 0,
    this.interestRate = 0.0,
  });
}
