import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/models/product.dart';
import 'package:afv_basico/repositories/memory/memory_product_repository.dart';

Product _product({
  String id = 'test-id',
  String name = 'Produto Teste',
  double price = 10.0,
}) =>
    Product(id: id, name: name, code: 'TST', price: price, unit: 'UN');

void main() {
  group('MemoryProductRepository', () {
    late MemoryProductRepository repo;

    setUp(() => repo = MemoryProductRepository());

    // ── getAll ─────────────────────────────────────────────────────────────────

    group('getAll', () {
      test('retorna os 8 produtos do seed inicial', () async {
        expect((await repo.getAll()).length, 8);
      });

      test('retorna cópia — modificar a lista não afeta o repositório', () async {
        final list = await repo.getAll();
        list.clear();
        expect((await repo.getAll()).length, 8);
      });
    });

    // ── save (insert) ──────────────────────────────────────────────────────────

    group('save — insert', () {
      test('adiciona produto novo ao repositório', () async {
        await repo.save(_product(id: 'novo'));
        expect((await repo.getAll()).any((p) => p.id == 'novo'), isTrue);
      });

      test('total aumenta em 1 após insert', () async {
        await repo.save(_product(id: 'x'));
        expect((await repo.getAll()).length, 9);
      });

      test('preserva todos os campos do produto', () async {
        final p = Product(id: 'full', name: 'Produto KG', code: 'KG001', price: 15.50, unit: 'KG');
        await repo.save(p);
        final saved = (await repo.getAll()).firstWhere((x) => x.id == 'full');
        expect(saved.name, 'Produto KG');
        expect(saved.code, 'KG001');
        expect(saved.price, 15.50);
        expect(saved.unit, 'KG');
      });
    });

    // ── save (update) ──────────────────────────────────────────────────────────

    group('save — update (upsert)', () {
      test('atualiza produto existente pelo id', () async {
        final original = (await repo.getAll()).first;
        await repo.save(original.copyWith(price: 9999.99));
        final found = (await repo.getAll()).firstWhere((p) => p.id == original.id);
        expect(found.price, 9999.99);
      });

      test('total não muda ao atualizar', () async {
        final original = (await repo.getAll()).first;
        await repo.save(original.copyWith(name: 'X'));
        expect((await repo.getAll()).length, 8);
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('remove produto pelo id', () async {
        final id = (await repo.getAll()).first.id;
        await repo.delete(id);
        expect((await repo.getAll()).any((p) => p.id == id), isFalse);
      });

      test('total diminui em 1 após delete', () async {
        final id = (await repo.getAll()).first.id;
        await repo.delete(id);
        expect((await repo.getAll()).length, 7);
      });

      test('id inexistente não altera o repositório', () async {
        await repo.delete('nao-existe');
        expect((await repo.getAll()).length, 8);
      });
    });
  });
}
