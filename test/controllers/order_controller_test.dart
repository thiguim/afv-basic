import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/controllers/order_controller.dart';
import 'package:afv_basico/models/order.dart';
import 'package:afv_basico/models/payment_condition.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

OrderItem _item({double unitPrice = 100.0, double quantity = 1}) =>
    OrderItem(
      productId: 'p1',
      productName: 'Produto Teste',
      quantity: quantity,
      unitPrice: unitPrice,
    );

Order _order({
  String id = 'o-001',
  OrderStatus status = OrderStatus.pending,
  DateTime? createdAt,
  List<OrderItem>? items,
  double discountPercent = 0,
  double surchargePercent = 0,
}) =>
    Order(
      id: id,
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

void main() {
  group('OrderController', () {
    late OrderController ctrl;

    setUp(() => ctrl = OrderController());
    tearDown(() => ctrl.dispose());

    // ── Dados iniciais ─────────────────────────────────────────────────────────

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
      test('retorna exatamente 6 condições', () {
        expect(ctrl.paymentConditions.length, 6);
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
      test('aumenta o total de pedidos em 1', () {
        ctrl.add(_order());
        expect(ctrl.orders.length, 1);
      });

      test('inserido no início da lista (mais recente primeiro)', () {
        ctrl.add(_order(id: 'o-1'));
        ctrl.add(_order(id: 'o-2'));
        expect(ctrl.orders.first.id, 'o-2');
      });

      test('notifica listeners ao adicionar', () {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.add(_order());
        expect(notificacoes, 1);
      });

      test('preserva todos os atributos do pedido', () {
        final pedido = _order(
          id: 'o-xxx',
          status: OrderStatus.confirmed,
          discountPercent: 5,
          surchargePercent: 2,
        );
        ctrl.add(pedido);
        final salvo = ctrl.orders.first;
        expect(salvo.id, 'o-xxx');
        expect(salvo.status, OrderStatus.confirmed);
        expect(salvo.discountPercent, 5);
        expect(salvo.surchargePercent, 2);
      });
    });

    // ── updateStatus ───────────────────────────────────────────────────────────

    group('updateStatus', () {
      test('altera status de pending para confirmed', () {
        ctrl.add(_order(id: 'o1', status: OrderStatus.pending));
        ctrl.updateStatus('o1', OrderStatus.confirmed);
        expect(ctrl.orders.first.status, OrderStatus.confirmed);
      });

      test('altera status de pending para cancelled', () {
        ctrl.add(_order(id: 'o1', status: OrderStatus.pending));
        ctrl.updateStatus('o1', OrderStatus.cancelled);
        expect(ctrl.orders.first.status, OrderStatus.cancelled);
      });

      test('não altera o total de pedidos', () {
        ctrl.add(_order(id: 'o1'));
        ctrl.updateStatus('o1', OrderStatus.confirmed);
        expect(ctrl.orders.length, 1);
      });

      test('notifica listeners ao atualizar status', () {
        ctrl.add(_order(id: 'o1'));
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.updateStatus('o1', OrderStatus.confirmed);
        expect(notificacoes, 1);
      });

      test('atualiza apenas o pedido especificado (múltiplos pedidos)', () {
        ctrl.add(_order(id: 'o1', status: OrderStatus.pending));
        ctrl.add(_order(id: 'o2', status: OrderStatus.pending));
        ctrl.updateStatus('o1', OrderStatus.cancelled);

        final o1 = ctrl.orders.firstWhere((o) => o.id == 'o1');
        final o2 = ctrl.orders.firstWhere((o) => o.id == 'o2');
        expect(o1.status, OrderStatus.cancelled);
        expect(o2.status, OrderStatus.pending);
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('diminui o total de pedidos em 1', () {
        ctrl.add(_order(id: 'o1'));
        ctrl.delete('o1');
        expect(ctrl.orders, isEmpty);
      });

      test('pedido removido não está mais na lista', () {
        ctrl.add(_order(id: 'o1'));
        ctrl.add(_order(id: 'o2'));
        ctrl.delete('o1');
        expect(ctrl.orders.any((o) => o.id == 'o1'), isFalse);
        expect(ctrl.orders.any((o) => o.id == 'o2'), isTrue);
      });

      test('notifica listeners ao remover', () {
        ctrl.add(_order(id: 'o1'));
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.delete('o1');
        expect(notificacoes, 1);
      });

      test('id inexistente não altera a lista', () {
        ctrl.add(_order(id: 'o1'));
        ctrl.delete('nao-existe');
        expect(ctrl.orders.length, 1);
      });
    });

    // ── filtered ───────────────────────────────────────────────────────────────

    group('filtered', () {
      setUp(() {
        ctrl.add(_order(id: 'p1', status: OrderStatus.pending));
        ctrl.add(_order(id: 'p2', status: OrderStatus.pending));
        ctrl.add(_order(id: 'c1', status: OrderStatus.confirmed));
        ctrl.add(_order(id: 'x1', status: OrderStatus.cancelled));
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
        expect(resultado.first.id, 'c1');
      });

      test('filtra apenas pedidos cancelados', () {
        final resultado = ctrl.filtered(OrderStatus.cancelled);
        expect(resultado.length, 1);
        expect(resultado.first.id, 'x1');
      });

      test('filtro sem correspondência retorna lista vazia', () {
        final ctrl2 = OrderController();
        ctrl2.add(_order(id: 'o1', status: OrderStatus.pending));
        expect(ctrl2.filtered(OrderStatus.confirmed), isEmpty);
        ctrl2.dispose();
      });
    });

    // ── monthlyRevenue ─────────────────────────────────────────────────────────

    group('monthlyRevenue', () {
      test('sem pedidos retorna zero', () {
        expect(ctrl.monthlyRevenue, 0.0);
      });

      test('soma pedidos pending e confirmed do mês atual', () {
        ctrl.add(_order(
          id: 'o1',
          status: OrderStatus.pending,
          items: [_item(unitPrice: 100.0)],
        ));
        ctrl.add(_order(
          id: 'o2',
          status: OrderStatus.confirmed,
          items: [_item(unitPrice: 200.0)],
        ));
        expect(ctrl.monthlyRevenue, closeTo(300.0, 0.001));
      });

      test('exclui pedidos cancelados do faturamento', () {
        ctrl.add(_order(
          id: 'o1',
          status: OrderStatus.pending,
          items: [_item(unitPrice: 100.0)],
        ));
        ctrl.add(_order(
          id: 'o2',
          status: OrderStatus.cancelled,
          items: [_item(unitPrice: 500.0)],
        ));
        expect(ctrl.monthlyRevenue, closeTo(100.0, 0.001));
      });

      test('exclui pedidos de meses anteriores', () {
        final mesPassado = DateTime.now().subtract(const Duration(days: 32));
        ctrl.add(_order(
          id: 'o-antigo',
          status: OrderStatus.confirmed,
          createdAt: mesPassado,
          items: [_item(unitPrice: 999.0)],
        ));
        ctrl.add(_order(
          id: 'o-atual',
          status: OrderStatus.confirmed,
          items: [_item(unitPrice: 100.0)],
        ));
        expect(ctrl.monthlyRevenue, closeTo(100.0, 0.001));
      });

      test('considera total com desconto e acréscimo', () {
        // 1 item × R$200, desconto 10% → total = 180
        ctrl.add(_order(
          id: 'o1',
          items: [_item(unitPrice: 200.0)],
          discountPercent: 10,
        ));
        expect(ctrl.monthlyRevenue, closeTo(180.0, 0.001));
      });

      test('cancelar pedido o exclui do faturamento', () {
        ctrl.add(_order(id: 'o1', items: [_item(unitPrice: 100.0)]));
        expect(ctrl.monthlyRevenue, closeTo(100.0, 0.001));

        ctrl.updateStatus('o1', OrderStatus.cancelled);
        expect(ctrl.monthlyRevenue, closeTo(0.0, 0.001));
      });
    });

    // ── monthlyOrdersCount ─────────────────────────────────────────────────────

    group('monthlyOrdersCount', () {
      test('sem pedidos retorna zero', () {
        expect(ctrl.monthlyOrdersCount, 0);
      });

      test('conta todos os status do mês atual', () {
        ctrl.add(_order(id: 'o1', status: OrderStatus.pending));
        ctrl.add(_order(id: 'o2', status: OrderStatus.confirmed));
        ctrl.add(_order(id: 'o3', status: OrderStatus.cancelled));
        expect(ctrl.monthlyOrdersCount, 3);
      });

      test('exclui pedidos de meses anteriores', () {
        final mesPassado = DateTime.now().subtract(const Duration(days: 32));
        ctrl.add(_order(id: 'o-antigo', createdAt: mesPassado));
        ctrl.add(_order(id: 'o-atual'));
        expect(ctrl.monthlyOrdersCount, 1);
      });
    });

    // ── recentOrders ───────────────────────────────────────────────────────────

    group('recentOrders', () {
      test('sem pedidos retorna lista vazia', () {
        expect(ctrl.recentOrders, isEmpty);
      });

      test('com menos de 5 pedidos retorna todos', () {
        ctrl.add(_order(id: 'o1'));
        ctrl.add(_order(id: 'o2'));
        ctrl.add(_order(id: 'o3'));
        expect(ctrl.recentOrders.length, 3);
      });

      test('com mais de 5 pedidos retorna apenas os 5 primeiros da lista', () {
        for (var i = 1; i <= 7; i++) {
          ctrl.add(_order(id: 'o$i'));
        }
        expect(ctrl.recentOrders.length, 5);
      });

      test('ordem é do mais recente (índice 0) para o mais antigo', () {
        ctrl.add(_order(id: 'o1'));
        ctrl.add(_order(id: 'o2')); // inserido no início
        expect(ctrl.recentOrders.first.id, 'o2');
        expect(ctrl.recentOrders.last.id, 'o1');
      });
    });

    // ── generateId ─────────────────────────────────────────────────────────────

    group('generateId', () {
      test('retorna string não vazia', () {
        expect(ctrl.generateId(), isNotEmpty);
      });

      test('gera IDs únicos em chamadas consecutivas', () {
        final ids = List.generate(10, (_) => ctrl.generateId());
        expect(ids.toSet().length, 10);
      });
    });
  });
}
