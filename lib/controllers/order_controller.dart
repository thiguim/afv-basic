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
  List<PaymentCondition> _paymentConditions = [];

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
    final results = await Future.wait([
      _repository.getAll(),
      _repository.getPaymentConditions(),
    ]);
    _orders = results[0] as List<Order>;
    _paymentConditions = results[1] as List<PaymentCondition>;
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
