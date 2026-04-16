import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/controllers/order_controller.dart';
import 'package:afv_basico/models/order.dart';
import 'package:afv_basico/models/payment_condition.dart';
import 'package:afv_basico/repositories/memory/memory_order_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

OrderItem _item({double unitPrice = 100.0, double quantity = 1}) => OrderItem(
      productId: 'p1',
      productName: 'Produto Teste',
      quantity: quantity,
      unitPrice: unitPrice,
    );

Order _order({
  OrderStatus status = OrderStatus.pending,
  DateTime? createdAt,
  List<OrderItem>? items,
  double discountPercent = 0,
  double surchargePercent = 0,
}) =>
    Order(
      createdAt: createdAt ?? DateTime.now(),
      customerId: 'c1',
      customerName: 'Cliente Teste',
      items: items ?? [_item()],
      paymentConditionId: 'pc1',
      paymentConditionName: 'À Vista',
      discountPercent: discountPercent,
      surchargePercent: surchargePercent,
      status: status,
    );

/// Adiciona um pedido e aguarda a operação async completar.
Future<void> _add(OrderController ctrl, Order order) async {
  ctrl.add(order);
  await Future.delayed(Duration.zero);
}

void main() {
  group('OrderController', () {
    late OrderController ctrl;

    setUp(() async {
      ctrl = OrderController(MemoryOrderRepository());
      await Future.delayed(Duration.zero); // aguarda _load() completar
    });
    tearDown(() => ctrl.dispose());

    // ── Estado inicial ─────────────────────────────────────────────────────────

    group('estado inicial', () {
      test('começa sem pedidos', () {
        expect(ctrl.orders, isEmpty);
      });

      test('lista de pedidos é imutável (unmodifiable)', () {
        expect(
          () => (ctrl.orders as List<Order>).add(_order()),
          throwsUnsupportedError,
        );
      });
    });

    // ── paymentConditions ──────────────────────────────────────────────────────

    group('paymentConditions', () {
      test('retorna todas as condições do repositório (26)', () {
        expect(ctrl.paymentConditions.length, 26);
      });

      test('primeira condição é À Vista (dias = 0)', () {
        expect(ctrl.paymentConditions.first.name, 'À Vista');
        expect(ctrl.paymentConditions.first.days, 0);
      });

      test('lista é imutável (unmodifiable)', () {
        const pc = PaymentCondition(id: 'x', name: 'X', days: 0, interestRate: 0);
        expect(
          () => (ctrl.paymentConditions as List<PaymentCondition>).add(pc),
          throwsUnsupportedError,
        );
      });

      test('todos os IDs são únicos', () {
        final ids = ctrl.paymentConditions.map((pc) => pc.id).toList();
        expect(ids.toSet().length, ids.length);
      });

      test('todas as condições têm nome não vazio', () {
        expect(ctrl.paymentConditions.every((pc) => pc.name.isNotEmpty), isTrue);
      });
    });

    // ── add ────────────────────────────────────────────────────────────────────

    group('add', () {
      test('aumenta o total de pedidos em 1', () async {
        await _add(ctrl, _order());
        expect(ctrl.orders.length, 1);
      });

      test('atribui id autoincrement a partir de 1', () async {
        final o = _order();
        await _add(ctrl, o);
        expect(o.id, 1);
      });

      test('segundo pedido recebe id = 2', () async {
        final o1 = _order();
        final o2 = _order();
        await _add(ctrl, o1);
        await _add(ctrl, o2);
        expect(o1.id, 1);
        expect(o2.id, 2);
      });

      test('inserido no início da lista (mais recente primeiro)', () async {
        await _add(ctrl, _order());
        await _add(ctrl, _order());
        expect(ctrl.orders.first.id, 2);
      });

      test('notifica listeners ao adicionar', () async {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        await _add(ctrl, _order());
        expect(notificacoes, greaterThanOrEqualTo(1));
      });

      test('preserva todos os atributos do pedido', () async {
        final pedido = _order(
          status: OrderStatus.confirmed,
          discountPercent: 5,
          surchargePercent: 2,
        );
        await _add(ctrl, pedido);
        final salvo = ctrl.orders.first;
        expect(salvo.status, OrderStatus.confirmed);
        expect(salvo.discountPercent, 5);
        expect(salvo.surchargePercent, 2);
      });
    });

    // ── update ─────────────────────────────────────────────────────────────────

    group('update', () {
      test('substitui os dados do pedido na lista', () async {
        final o = _order(status: OrderStatus.pending);
        await _add(ctrl, o);

        final atualizado = Order(
          id: o.id,
          createdAt: o.createdAt,
          status: OrderStatus.pending,
          customerId: 'c2',
          customerName: 'Novo Cliente',
          items: [_item(unitPrice: 200.0)],
          paymentConditionId: 'pc2',
          paymentConditionName: '30 dias',
        );
        ctrl.update(atualizado);
        await Future.delayed(Duration.zero);

        expect(ctrl.orders.first.customerName, 'Novo Cliente');
        expect(ctrl.orders.first.itemsTotal, closeTo(200.0, 0.001));
      });

      test('não altera o id do pedido', () async {
        final o = _order(status: OrderStatus.pending);
        await _add(ctrl, o);
        final idOriginal = o.id;

        final atualizado = Order(
          id: o.id,
          createdAt: o.createdAt,
          status: OrderStatus.pending,
          customerId: 'c2',
          customerName: 'Outro Cliente',
          items: [_item()],
          paymentConditionId: 'pc1',
          paymentConditionName: 'À Vista',
        );
        ctrl.update(atualizado);
        await Future.delayed(Duration.zero);

        expect(ctrl.orders.first.id, idOriginal);
      });

      test('não altera o total de pedidos', () async {
        final o = _order(status: OrderStatus.pending);
        await _add(ctrl, o);

        final atualizado = Order(
          id: o.id,
          createdAt: o.createdAt,
          status: OrderStatus.pending,
          customerId: 'c2',
          customerName: 'Cliente X',
          items: [_item()],
          paymentConditionId: 'pc1',
          paymentConditionName: 'À Vista',
        );
        ctrl.update(atualizado);
        await Future.delayed(Duration.zero);

        expect(ctrl.orders.length, 1);
      });

      test('notifica listeners ao atualizar', () async {
        final o = _order(status: OrderStatus.pending);
        await _add(ctrl, o);

        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);

        final atualizado = Order(
          id: o.id,
          createdAt: o.createdAt,
          status: OrderStatus.pending,
          customerId: 'c2',
          customerName: 'Cliente Y',
          items: [_item()],
          paymentConditionId: 'pc1',
          paymentConditionName: 'À Vista',
        );
        ctrl.update(atualizado);
        await Future.delayed(Duration.zero);

        expect(notificacoes, greaterThanOrEqualTo(1));
      });

      test('lança ArgumentError ao tentar editar pedido confirmado', () async {
        final o = _order(status: OrderStatus.confirmed);
        await _add(ctrl, o);

        final tentativa = Order(
          id: o.id,
          createdAt: o.createdAt,
          status: OrderStatus.confirmed,
          customerId: 'c2',
          customerName: 'Inválido',
          items: [_item()],
          paymentConditionId: 'pc1',
          paymentConditionName: 'À Vista',
        );

        expect(() => ctrl.update(tentativa), throwsArgumentError);
      });

      test('lança ArgumentError ao tentar editar pedido cancelado', () async {
        final o = _order(status: OrderStatus.cancelled);
        await _add(ctrl, o);

        final tentativa = Order(
          id: o.id,
          createdAt: o.createdAt,
          status: OrderStatus.cancelled,
          customerId: 'c2',
          customerName: 'Inválido',
          items: [_item()],
          paymentConditionId: 'pc1',
          paymentConditionName: 'À Vista',
        );

        expect(() => ctrl.update(tentativa), throwsArgumentError);
      });

      test('atualiza apenas o pedido especificado (múltiplos pedidos)', () async {
        final o1 = _order(status: OrderStatus.pending);
        final o2 = _order(status: OrderStatus.pending);
        await _add(ctrl, o1);
        await _add(ctrl, o2);

        final atualizado = Order(
          id: o1.id,
          createdAt: o1.createdAt,
          status: OrderStatus.pending,
          customerId: 'c9',
          customerName: 'Apenas o1',
          items: [_item()],
          paymentConditionId: 'pc1',
          paymentConditionName: 'À Vista',
        );
        ctrl.update(atualizado);
        await Future.delayed(Duration.zero);

        final found1 = ctrl.orders.firstWhere((o) => o.id == o1.id);
        final found2 = ctrl.orders.firstWhere((o) => o.id == o2.id);
        expect(found1.customerName, 'Apenas o1');
        expect(found2.customerName, 'Cliente Teste');
      });
    });

    // ── updateStatus ───────────────────────────────────────────────────────────

    group('updateStatus', () {
      test('altera status de pending para confirmed', () async {
        final o = _order(status: OrderStatus.pending);
        await _add(ctrl, o);
        ctrl.updateStatus(o.id!, OrderStatus.confirmed);
        await Future.delayed(Duration.zero);
        expect(ctrl.orders.first.status, OrderStatus.confirmed);
      });

      test('altera status de pending para cancelled', () async {
        final o = _order(status: OrderStatus.pending);
        await _add(ctrl, o);
        ctrl.updateStatus(o.id!, OrderStatus.cancelled);
        await Future.delayed(Duration.zero);
        expect(ctrl.orders.first.status, OrderStatus.cancelled);
      });

      test('não altera o total de pedidos', () async {
        final o = _order();
        await _add(ctrl, o);
        ctrl.updateStatus(o.id!, OrderStatus.confirmed);
        await Future.delayed(Duration.zero);
        expect(ctrl.orders.length, 1);
      });

      test('atualiza apenas o pedido especificado (múltiplos pedidos)', () async {
        final o1 = _order(status: OrderStatus.pending);
        final o2 = _order(status: OrderStatus.pending);
        await _add(ctrl, o1);
        await _add(ctrl, o2);

        ctrl.updateStatus(o1.id!, OrderStatus.cancelled);
        await Future.delayed(Duration.zero);

        final found1 = ctrl.orders.firstWhere((o) => o.id == o1.id);
        final found2 = ctrl.orders.firstWhere((o) => o.id == o2.id);
        expect(found1.status, OrderStatus.cancelled);
        expect(found2.status, OrderStatus.pending);
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('diminui o total de pedidos em 1', () async {
        final o = _order();
        await _add(ctrl, o);
        ctrl.delete(o.id!);
        await Future.delayed(Duration.zero);
        expect(ctrl.orders, isEmpty);
      });

      test('pedido removido não está mais na lista', () async {
        final o1 = _order();
        final o2 = _order();
        await _add(ctrl, o1);
        await _add(ctrl, o2);
        ctrl.delete(o1.id!);
        await Future.delayed(Duration.zero);
        expect(ctrl.orders.any((o) => o.id == o1.id), isFalse);
        expect(ctrl.orders.any((o) => o.id == o2.id), isTrue);
      });

      test('notifica listeners ao remover', () async {
        final o = _order();
        await _add(ctrl, o);
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.delete(o.id!);
        await Future.delayed(Duration.zero);
        expect(notificacoes, greaterThanOrEqualTo(1));
      });
    });

    // ── filtered ───────────────────────────────────────────────────────────────

    group('filtered', () {
      setUp(() async {
        await _add(ctrl, _order(status: OrderStatus.pending));
        await _add(ctrl, _order(status: OrderStatus.pending));
        await _add(ctrl, _order(status: OrderStatus.confirmed));
        await _add(ctrl, _order(status: OrderStatus.cancelled));
      });

      test('null retorna todos os pedidos', () {
        expect(ctrl.filtered(null).length, 4);
      });

      test('filtra apenas pedidos pendentes', () {
        final resultado = ctrl.filtered(OrderStatus.pending);
        expect(resultado.length, 2);
        expect(resultado.every((o) => o.status == OrderStatus.pending), isTrue);
      });

      test('filtra apenas pedidos confirmados', () {
        final resultado = ctrl.filtered(OrderStatus.confirmed);
        expect(resultado.length, 1);
        expect(resultado.first.status, OrderStatus.confirmed);
      });

      test('filtra apenas pedidos cancelados', () {
        final resultado = ctrl.filtered(OrderStatus.cancelled);
        expect(resultado.length, 1);
        expect(resultado.first.status, OrderStatus.cancelled);
      });
    });

    // ── monthlyRevenue ─────────────────────────────────────────────────────────

    group('monthlyRevenue', () {
      test('sem pedidos retorna zero', () {
        expect(ctrl.monthlyRevenue, 0.0);
      });

      test('soma pedidos pending e confirmed do mês atual', () async {
        await _add(ctrl, _order(status: OrderStatus.pending, items: [_item(unitPrice: 100.0)]));
        await _add(ctrl, _order(status: OrderStatus.confirmed, items: [_item(unitPrice: 200.0)]));
        expect(ctrl.monthlyRevenue, closeTo(300.0, 0.001));
      });

      test('exclui pedidos cancelados do faturamento', () async {
        await _add(ctrl, _order(status: OrderStatus.pending, items: [_item(unitPrice: 100.0)]));
        await _add(ctrl, _order(status: OrderStatus.cancelled, items: [_item(unitPrice: 500.0)]));
        expect(ctrl.monthlyRevenue, closeTo(100.0, 0.001));
      });

      test('exclui pedidos de meses anteriores', () async {
        final mesPassado = DateTime.now().subtract(const Duration(days: 32));
        await _add(ctrl, _order(createdAt: mesPassado, items: [_item(unitPrice: 999.0)]));
        await _add(ctrl, _order(items: [_item(unitPrice: 100.0)]));
        expect(ctrl.monthlyRevenue, closeTo(100.0, 0.001));
      });

      test('cancelar pedido o exclui do faturamento', () async {
        final o = _order(items: [_item(unitPrice: 100.0)]);
        await _add(ctrl, o);
        expect(ctrl.monthlyRevenue, closeTo(100.0, 0.001));
        ctrl.updateStatus(o.id!, OrderStatus.cancelled);
        await Future.delayed(Duration.zero);
        expect(ctrl.monthlyRevenue, closeTo(0.0, 0.001));
      });
    });

    // ── monthlyOrdersCount ─────────────────────────────────────────────────────

    group('monthlyOrdersCount', () {
      test('sem pedidos retorna zero', () {
        expect(ctrl.monthlyOrdersCount, 0);
      });

      test('conta todos os status do mês atual', () async {
        await _add(ctrl, _order(status: OrderStatus.pending));
        await _add(ctrl, _order(status: OrderStatus.confirmed));
        await _add(ctrl, _order(status: OrderStatus.cancelled));
        expect(ctrl.monthlyOrdersCount, 3);
      });

      test('exclui pedidos de meses anteriores', () async {
        final mesPassado = DateTime.now().subtract(const Duration(days: 32));
        await _add(ctrl, _order(createdAt: mesPassado));
        await _add(ctrl, _order());
        expect(ctrl.monthlyOrdersCount, 1);
      });
    });

    // ── recentOrders ───────────────────────────────────────────────────────────

    group('recentOrders', () {
      test('sem pedidos retorna lista vazia', () {
        expect(ctrl.recentOrders, isEmpty);
      });

      test('com menos de 5 pedidos retorna todos', () async {
        await _add(ctrl, _order());
        await _add(ctrl, _order());
        await _add(ctrl, _order());
        expect(ctrl.recentOrders.length, 3);
      });

      test('com mais de 5 pedidos retorna apenas os 5 primeiros da lista', () async {
        for (var i = 0; i < 7; i++) {
          await _add(ctrl, _order());
        }
        expect(ctrl.recentOrders.length, 5);
      });

      test('ordem é do mais recente (índice 0) para o mais antigo', () async {
        final o1 = _order();
        final o2 = _order();
        await _add(ctrl, o1);
        await _add(ctrl, o2);
        expect(ctrl.recentOrders.first.id, o2.id);
        expect(ctrl.recentOrders.last.id, o1.id);
      });
    });
  });
}
