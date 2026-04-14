import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:afv_basico/models/customer.dart';
import 'package:afv_basico/models/order.dart';
import 'package:afv_basico/models/product.dart';
import 'package:afv_basico/repositories/sqlite/sqlite_customer_repository.dart';
import 'package:afv_basico/repositories/sqlite/sqlite_order_repository.dart';
import 'package:afv_basico/repositories/sqlite/sqlite_product_repository.dart';
import 'package:afv_basico/services/database_service.dart';
import 'sqlite_test_helper.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

OrderItem _item({double unitPrice = 100.0, double quantity = 2.0}) => OrderItem(
      productId: 'p1',
      productName: 'Produto Teste',
      productCode: 'PT001',
      productUnit: 'UN',
      quantity: quantity,
      unitPrice: unitPrice,
      discountPercent: 0,
    );

Order _order({
  OrderStatus status = OrderStatus.pending,
  String notes = '',
  double discountPercent = 0,
  double surchargePercent = 0,
  List<OrderItem>? items,
}) =>
    Order(
      createdAt: DateTime(2025, 6, 15, 10, 0),
      customerId: 'c1',
      customerName: 'Cliente Teste',
      paymentConditionId: 'pc1',
      paymentConditionName: 'À Vista',
      items: items ?? [_item()],
      status: status,
      notes: notes,
      discountPercent: discountPercent,
      surchargePercent: surchargePercent,
    );

void main() {
  setUpAll(initSqliteFfi);

  group('SqliteOrderRepository', () {
    late Database db;
    late SqliteOrderRepository repo;

    setUp(() async {
      db = await openTestDatabase();
      final dbService = DatabaseService.instance;
      repo = SqliteOrderRepository(dbService);

      // Insere pré-requisitos de FK: condição de pagamento, cliente e produto
      await db.insert('TMVOCNDPGTO', {
        'IDCPGT': 'pc1',
        'NMCPGT': 'À Vista',
        'NRPRAZ': 0,
        'PCTAXA': 0.0,
      });
      await SqliteCustomerRepository(dbService).save(
        Customer(id: 'c1', name: 'Cliente Teste'),
      );
      await SqliteProductRepository(dbService).save(
        Product(id: 'p1', name: 'Produto Teste', price: 100.0, unit: 'UN'),
      );
    });

    tearDown(() async => db.close());

    // ── getAll ─────────────────────────────────────────────────────────────────

    group('getAll', () {
      test('banco vazio retorna lista vazia', () async {
        expect(await repo.getAll(), isEmpty);
      });

      test('retorna todos os pedidos inseridos', () async {
        await repo.save(_order());
        await repo.save(_order());
        expect((await repo.getAll()).length, 2);
      });

      test('retorna ordenado por IDPEDI DESC (mais recente primeiro)', () async {
        await repo.save(_order());
        await repo.save(_order());
        final all = await repo.getAll();
        expect(all.first.id, greaterThan(all.last.id!));
      });
    });

    // ── save (insert) ──────────────────────────────────────────────────────────

    group('save — insert', () {
      test('atribui id autoincrement ao primeiro pedido', () async {
        final o = _order();
        await repo.save(o);
        expect(o.id, 1);
      });

      test('ids são incrementais', () async {
        final o1 = _order();
        final o2 = _order();
        await repo.save(o1);
        await repo.save(o2);
        expect(o2.id, o1.id! + 1);
      });

      test('persiste cabeçalho com todos os campos', () async {
        final o = _order(
          status: OrderStatus.confirmed,
          notes: 'Entrega urgente',
          discountPercent: 5.0,
          surchargePercent: 2.0,
        );
        await repo.save(o);
        final saved = (await repo.getAll()).first;
        expect(saved.customerName, 'Cliente Teste');
        expect(saved.paymentConditionName, 'À Vista');
        expect(saved.status, OrderStatus.confirmed);
        expect(saved.notes, 'Entrega urgente');
        expect(saved.discountPercent, closeTo(5.0, 0.001));
        expect(saved.surchargePercent, closeTo(2.0, 0.001));
      });

      test('persiste itens do pedido', () async {
        final o = _order(items: [
          _item(unitPrice: 50.0, quantity: 3.0),
          _item(unitPrice: 200.0, quantity: 1.0),
        ]);
        await repo.save(o);
        final saved = (await repo.getAll()).first;
        expect(saved.items.length, 2);
      });

      test('itens recuperados preservam campos', () async {
        final o = _order(items: [_item(unitPrice: 75.0, quantity: 4.0)]);
        await repo.save(o);
        final item = (await repo.getAll()).first.items.first;
        expect(item.productId, 'p1');
        expect(item.productName, 'Produto Teste');
        expect(item.unitPrice, closeTo(75.0, 0.001));
        expect(item.quantity, closeTo(4.0, 0.001));
      });

      test('data de criação é preservada com precisão', () async {
        await repo.save(_order());
        final saved = (await repo.getAll()).first;
        expect(saved.createdAt, DateTime(2025, 6, 15, 10, 0));
      });
    });

    // ── save (update) ──────────────────────────────────────────────────────────

    group('save — update (upsert)', () {
      test('atualiza cabeçalho do pedido existente', () async {
        final o = _order(status: OrderStatus.pending);
        await repo.save(o);
        o.status = OrderStatus.confirmed;
        await repo.save(o);

        final all = await repo.getAll();
        expect(all.length, 1);
        expect(all.first.status, OrderStatus.confirmed);
      });

      test('substitui itens ao atualizar', () async {
        final o = _order(items: [_item(quantity: 1.0)]);
        await repo.save(o);
        o.items = [_item(quantity: 5.0), _item(quantity: 3.0)];
        await repo.save(o);

        final saved = (await repo.getAll()).first;
        expect(saved.items.length, 2);
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

      test('afeta apenas o pedido especificado', () async {
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
      test('remove pedido do banco', () async {
        final o = _order();
        await repo.save(o);
        await repo.delete(o.id!);
        expect(await repo.getAll(), isEmpty);
      });

      test('itens são removidos junto com o pedido (cascade via FK)', () async {
        final o = _order();
        await repo.save(o);
        await repo.delete(o.id!);
        final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM TMVOITE WHERE IDPEDI = ?', [o.id]),
        );
        expect(count, 0);
      });

      test('id inexistente não gera erro', () async {
        await repo.save(_order());
        await repo.delete(9999);
        expect((await repo.getAll()).length, 1);
      });
    });
  });
}
