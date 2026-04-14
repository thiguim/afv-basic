import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/models/order.dart';
import 'package:afv_basico/repositories/memory/memory_order_repository.dart';

Order _order({OrderStatus status = OrderStatus.pending}) => Order(
      createdAt: DateTime.now(),
      customerId: 'c1',
      customerName: 'Cliente Teste',
      items: [
        OrderItem(
          productId: 'p1',
          productName: 'Produto',
          quantity: 1,
          unitPrice: 100.0,
        ),
      ],
      paymentConditionId: 'pc1',
      paymentConditionName: 'À Vista',
      status: status,
    );

void main() {
  group('MemoryOrderRepository', () {
    late MemoryOrderRepository repo;

    setUp(() => repo = MemoryOrderRepository());

    // ── getAll ─────────────────────────────────────────────────────────────────

    group('getAll', () {
      test('inicia vazio', () async {
        expect(await repo.getAll(), isEmpty);
      });

      test('retorna cópia — modificar a lista não afeta o repositório', () async {
        await repo.save(_order());
        final list = await repo.getAll();
        list.clear();
        expect((await repo.getAll()).length, 1);
      });
    });

    // ── save (insert) ──────────────────────────────────────────────────────────

    group('save — insert', () {
      test('atribui id = 1 ao primeiro pedido', () async {
        final o = _order();
        await repo.save(o);
        expect(o.id, 1);
      });

      test('ids são incrementais: 1, 2, 3...', () async {
        final o1 = _order();
        final o2 = _order();
        final o3 = _order();
        await repo.save(o1);
        await repo.save(o2);
        await repo.save(o3);
        expect(o1.id, 1);
        expect(o2.id, 2);
        expect(o3.id, 3);
      });

      test('retorna o id gerado', () async {
        final id = await repo.save(_order());
        expect(id, 1);
      });

      test('insere no início (mais recente primeiro)', () async {
        await repo.save(_order());
        await repo.save(_order());
        final all = await repo.getAll();
        expect(all.first.id, 2);
        expect(all.last.id, 1);
      });
    });

    // ── save (update) ──────────────────────────────────────────────────────────

    group('save — update (upsert)', () {
      test('atualiza pedido existente pelo id', () async {
        final o = _order(status: OrderStatus.pending);
        await repo.save(o);
        o.status = OrderStatus.confirmed;
        await repo.save(o);

        final all = await repo.getAll();
        expect(all.length, 1);
        expect(all.first.status, OrderStatus.confirmed);
      });

      test('total não muda ao atualizar', () async {
        final o = _order();
        await repo.save(o);
        await repo.save(o);
        expect((await repo.getAll()).length, 1);
      });
    });

    // ── updateStatus ───────────────────────────────────────────────────────────

    group('updateStatus', () {
      test('muda status de pending para confirmed', () async {
        final o = _order(status: OrderStatus.pending);
        await repo.save(o);
        await repo.updateStatus(o.id!, OrderStatus.confirmed);
        expect((await repo.getAll()).first.status, OrderStatus.confirmed);
      });

      test('muda status de pending para cancelled', () async {
        final o = _order();
        await repo.save(o);
        await repo.updateStatus(o.id!, OrderStatus.cancelled);
        expect((await repo.getAll()).first.status, OrderStatus.cancelled);
      });

      test('altera apenas o pedido com o id correspondente', () async {
        final o1 = _order(status: OrderStatus.pending);
        final o2 = _order(status: OrderStatus.pending);
        await repo.save(o1);
        await repo.save(o2);
        await repo.updateStatus(o1.id!, OrderStatus.cancelled);

        final all = await repo.getAll();
        expect(all.firstWhere((o) => o.id == o1.id).status, OrderStatus.cancelled);
        expect(all.firstWhere((o) => o.id == o2.id).status, OrderStatus.pending);
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('remove pedido pelo id', () async {
        final o = _order();
        await repo.save(o);
        await repo.delete(o.id!);
        expect(await repo.getAll(), isEmpty);
      });

      test('total diminui em 1 após delete', () async {
        final o1 = _order();
        final o2 = _order();
        await repo.save(o1);
        await repo.save(o2);
        await repo.delete(o1.id!);
        expect((await repo.getAll()).length, 1);
      });

      test('pedido correto é removido em lista com múltiplos itens', () async {
        final o1 = _order();
        final o2 = _order();
        await repo.save(o1);
        await repo.save(o2);
        await repo.delete(o1.id!);
        expect((await repo.getAll()).first.id, o2.id);
      });
    });
  });
}
