import '../../models/order.dart';
import '../order_repository.dart';

/// Implementação em memória do [OrderRepository].
/// Simula AUTOINCREMENT com contador interno — comportamento idêntico ao SQLite.
class MemoryOrderRepository implements OrderRepository {
  final List<Order> _data = [];
  int _nextId = 1;

  @override
  Future<List<Order>> getAll() async => List.of(_data);

  @override
  Future<int> save(Order order) async {
    if (order.id == null) {
      order.id = _nextId++;
      _data.insert(0, order);
    } else {
      final i = _data.indexWhere((o) => o.id == order.id);
      if (i != -1) _data[i] = order;
    }
    return order.id!;
  }

  @override
  Future<void> updateStatus(int id, OrderStatus status) async {
    final o = _data.firstWhere((x) => x.id == id);
    o.status = status;
  }

  @override
  Future<void> delete(int id) async {
    _data.removeWhere((o) => o.id == id);
  }
}
