import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:afv_basico/models/product.dart';
import 'package:afv_basico/repositories/sqlite/sqlite_product_repository.dart';
import 'package:afv_basico/services/database_service.dart';
import 'sqlite_test_helper.dart';

Product _product({
  String id = 'test-id',
  String name = 'Produto Teste',
  String code = 'TST001',
  double price = 99.90,
  String unit = 'UN',
}) =>
    Product(id: id, name: name, code: code, price: price, unit: unit);

void main() {
  setUpAll(initSqliteFfi);

  group('SqliteProductRepository', () {
    late Database db;
    late SqliteProductRepository repo;

    setUp(() async {
      db = await openTestDatabase();
      repo = SqliteProductRepository(DatabaseService.instance);
    });

    tearDown(() async => db.close());

    // ── getAll ─────────────────────────────────────────────────────────────────

    group('getAll', () {
      test('banco vazio retorna lista vazia', () async {
        expect(await repo.getAll(), isEmpty);
      });

      test('retorna todos os produtos inseridos', () async {
        await repo.save(_product(id: 'p1'));
        await repo.save(_product(id: 'p2'));
        expect((await repo.getAll()).length, 2);
      });

      test('retorna ordenado por NMPROD ASC', () async {
        await repo.save(_product(id: 'p1', name: 'Zebra'));
        await repo.save(_product(id: 'p2', name: 'Abacaxi'));
        final all = await repo.getAll();
        expect(all.first.name, 'Abacaxi');
        expect(all.last.name, 'Zebra');
      });
    });

    // ── save (insert) ──────────────────────────────────────────────────────────

    group('save — insert', () {
      test('persiste produto no banco', () async {
        await repo.save(_product(id: 'p1'));
        expect((await repo.getAll()).any((p) => p.id == 'p1'), isTrue);
      });

      test('preserva todos os campos', () async {
        await repo.save(_product(id: 'full', name: 'Produto KG', code: 'KG001', price: 15.50, unit: 'KG'));
        final saved = (await repo.getAll()).first;
        expect(saved.name, 'Produto KG');
        expect(saved.code, 'KG001');
        expect(saved.price, closeTo(15.50, 0.001));
        expect(saved.unit, 'KG');
      });
    });

    // ── save (update / replace) ────────────────────────────────────────────────

    group('save — update (upsert)', () {
      test('atualiza produto existente sem duplicar', () async {
        await repo.save(_product(id: 'p1', price: 10.0));
        await repo.save(_product(id: 'p1', price: 20.0));
        final all = await repo.getAll();
        expect(all.length, 1);
        expect(all.first.price, closeTo(20.0, 0.001));
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('remove produto do banco', () async {
        await repo.save(_product(id: 'p1'));
        await repo.delete('p1');
        expect((await repo.getAll()).any((p) => p.id == 'p1'), isFalse);
      });

      test('id inexistente não gera erro e não altera o banco', () async {
        await repo.save(_product(id: 'p1'));
        await repo.delete('nao-existe');
        expect((await repo.getAll()).length, 1);
      });
    });
  });
}
