import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/payment_condition.dart';
import '../repositories/order_repository.dart';

/// Gerencia pedidos, condições de pagamento e estatísticas mensais.
class OrderController extends ChangeNotifier {
  OrderController(this._repository) {
    _load();
  }

  final OrderRepository _repository;

  List<Order> _orders = [];

  static const List<PaymentCondition> _paymentConditions = [
    PaymentCondition(id: 'pc1', name: 'À Vista', days: 0, interestRate: 0),
    PaymentCondition(id: 'pc2', name: '30 dias', days: 30, interestRate: 0),
    PaymentCondition(id: 'pc3', name: '2x sem juros', days: 30, interestRate: 0),
    PaymentCondition(id: 'pc4', name: '3x com juros (2%)', days: 30, interestRate: 2.0),
    PaymentCondition(id: 'pc5', name: '6x com juros (3,5%)', days: 30, interestRate: 3.5),
    PaymentCondition(id: 'pc6', name: '30/60/90 dias', days: 30, interestRate: 0),
  ];

  // ── Getters ──────────────────────────────────────────────────────────────────

  List<Order> get orders => List.unmodifiable(_orders);
  List<PaymentCondition> get paymentConditions =>
      List.unmodifiable(_paymentConditions);

  /// Retorna pedidos filtrados por status. Passa [null] para todos.
  List<Order> filtered(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((o) => o.status == status).toList();
  }

  // ── Estatísticas do mês ───────────────────────────────────────────────────────

  double get monthlyRevenue {
    final now = DateTime.now();
    return _orders
        .where((o) =>
            o.createdAt.month == now.month &&
            o.createdAt.year == now.year &&
            o.status != OrderStatus.cancelled)
        .fold(0.0, (s, o) => s + o.total);
  }

  int get monthlyOrdersCount {
    final now = DateTime.now();
    return _orders
        .where((o) =>
            o.createdAt.month == now.month && o.createdAt.year == now.year)
        .length;
  }

  List<Order> get recentOrders => _orders.take(5).toList();

  // ── CRUD ─────────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    _orders = await _repository.getAll();
    notifyListeners();
  }

  /// Persiste o pedido e atualiza o [order.id] com o IDPEDI gerado pelo banco.
  void add(Order order) async {
    await _repository.save(order); // popula order.id via autoincrement
    _orders.insert(0, order);
    notifyListeners();
  }

  /// Atualiza os dados de um pedido existente.
  ///
  /// Lança [ArgumentError] se o pedido não estiver com status [OrderStatus.pending].
  /// Pedidos confirmados ou cancelados são imutáveis.
  void update(Order order) async {
    if (order.status != OrderStatus.pending) {
      throw ArgumentError(
          'Só é possível editar pedidos com status pendente.');
    }
    await _repository.save(order);
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
      notifyListeners();
    }
  }

  void updateStatus(int id, OrderStatus status) async {
    await _repository.updateStatus(id, status);
    final o = _orders.firstWhere((x) => x.id == id);
    o.status = status;
    notifyListeners();
  }

  void delete(int id) async {
    await _repository.delete(id);
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}
