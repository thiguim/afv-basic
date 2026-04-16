import '../../models/order.dart';
import '../../models/payment_condition.dart';
import '../order_repository.dart';

/// Implementação em memória do [OrderRepository].
/// Simula AUTOINCREMENT com contador interno — comportamento idêntico ao SQLite.
class MemoryOrderRepository implements OrderRepository {
  final List<Order> _data = [];
  int _nextId = 1;

  @override
  Future<List<Order>> getAll() async => List.of(_data);

  @override
  Future<List<PaymentCondition>> getPaymentConditions() async => const [
        PaymentCondition(id: 'pc1',  name: 'À Vista',                   days: 0,   interestRate: 0.0),
        PaymentCondition(id: 'pc2',  name: '30 dias',                   days: 30,  interestRate: 0.0),
        PaymentCondition(id: 'pc3',  name: '2x sem juros',              days: 30,  interestRate: 0.0),
        PaymentCondition(id: 'pc4',  name: '3x com juros (2%)',         days: 30,  interestRate: 2.0),
        PaymentCondition(id: 'pc5',  name: '6x com juros (3,5%)',       days: 30,  interestRate: 3.5),
        PaymentCondition(id: 'pc6',  name: '30/60/90 dias',             days: 30,  interestRate: 0.0),
        PaymentCondition(id: 'pc7',  name: '45 dias',                   days: 45,  interestRate: 0.0),
        PaymentCondition(id: 'pc8',  name: '60 dias',                   days: 60,  interestRate: 0.0),
        PaymentCondition(id: 'pc9',  name: '90 dias',                   days: 90,  interestRate: 0.0),
        PaymentCondition(id: 'pc10', name: '4x sem juros',              days: 30,  interestRate: 0.0),
        PaymentCondition(id: 'pc11', name: '5x sem juros',              days: 30,  interestRate: 0.0),
        PaymentCondition(id: 'pc12', name: '4x com juros (1,5%)',       days: 30,  interestRate: 1.5),
        PaymentCondition(id: 'pc13', name: '5x com juros (1,99%)',      days: 30,  interestRate: 1.99),
        PaymentCondition(id: 'pc14', name: '8x com juros (2,5%)',       days: 30,  interestRate: 2.5),
        PaymentCondition(id: 'pc15', name: '10x com juros (3%)',        days: 30,  interestRate: 3.0),
        PaymentCondition(id: 'pc16', name: '12x com juros (3,5%)',      days: 30,  interestRate: 3.5),
        PaymentCondition(id: 'pc17', name: '18x com juros (4%)',        days: 30,  interestRate: 4.0),
        PaymentCondition(id: 'pc18', name: '24x com juros (4,5%)',      days: 30,  interestRate: 4.5),
        PaymentCondition(id: 'pc19', name: '28/56 dias',                days: 28,  interestRate: 0.0),
        PaymentCondition(id: 'pc20', name: '30/60 dias',                days: 30,  interestRate: 0.0),
        PaymentCondition(id: 'pc21', name: '30/60/90/120 dias',         days: 30,  interestRate: 0.0),
        PaymentCondition(id: 'pc22', name: 'Boleto 15 dias',            days: 15,  interestRate: 0.0),
        PaymentCondition(id: 'pc23', name: 'Boleto 21 dias',            days: 21,  interestRate: 0.0),
        PaymentCondition(id: 'pc24', name: 'Boleto 45 dias c/ juros',   days: 45,  interestRate: 1.0),
        PaymentCondition(id: 'pc25', name: 'Cheque pré 30 dias',        days: 30,  interestRate: 0.0),
        PaymentCondition(id: 'pc26', name: 'Cheque pré 60 dias',        days: 60,  interestRate: 0.0),
      ];

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
