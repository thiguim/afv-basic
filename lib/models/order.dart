enum OrderStatus { pending, confirmed, cancelled }

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  int get colorValue {
    switch (this) {
      case OrderStatus.pending:
        return 0xFFF59E0B;
      case OrderStatus.confirmed:
        return 0xFF10B981;
      case OrderStatus.cancelled:
        return 0xFFEF4444;
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productCode;
  final String productUnit;
  double quantity;
  double unitPrice;
  double discountPercent;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productCode = '',
    this.productUnit = 'UN',
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0.0,
  });

  double get subtotal => quantity * unitPrice * (1 - discountPercent / 100);
}

class Order {
  /// Nulo até o primeiro INSERT no banco — preenchido com o IDPEDI gerado.
  int? id;
  final DateTime createdAt;
  String customerId;
  String customerName;
  List<OrderItem> items;
  String paymentConditionId;
  String paymentConditionName;
  double discountPercent;
  double surchargePercent;
  OrderStatus status;
  String notes;

  Order({
    this.id,
    required this.createdAt,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.paymentConditionId,
    required this.paymentConditionName,
    this.discountPercent = 0.0,
    this.surchargePercent = 0.0,
    this.status = OrderStatus.pending,
    this.notes = '',
  });

  double get itemsTotal => items.fold(0.0, (s, i) => s + i.subtotal);
  double get discountAmount => itemsTotal * discountPercent / 100;
  double get surchargeAmount => (itemsTotal - discountAmount) * surchargePercent / 100;
  double get total => itemsTotal - discountAmount + surchargeAmount;
}
