import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/models/customer.dart';
import 'package:afv_basico/repositories/memory/memory_customer_repository.dart';

Customer _customer({
  String id = 'test-id',
  String name = 'Cliente Teste',
}) =>
    Customer(id: id, name: name, document: '000.000.000-00');

void main() {
  group('MemoryCustomerRepository', () {
    late MemoryCustomerRepository repo;

    setUp(() => repo = MemoryCustomerRepository());

    // ── getAll ─────────────────────────────────────────────────────────────────

    group('getAll', () {
      test('retorna os 4 clientes do seed inicial', () async {
        final result = await repo.getAll();
        expect(result.length, 4);
      });

      test('retorna cópia — modificar a lista não afeta o repositório', () async {
        final list = await repo.getAll();
        list.clear();
        expect((await repo.getAll()).length, 4);
      });
    });

    // ── save (insert) ──────────────────────────────────────────────────────────

    group('save — insert', () {
      test('adiciona cliente novo ao repositório', () async {
        await repo.save(_customer(id: 'novo'));
        final all = await repo.getAll();
        expect(all.any((c) => c.id == 'novo'), isTrue);
      });

      test('total aumenta em 1 após insert', () async {
        await repo.save(_customer(id: 'x'));
        expect((await repo.getAll()).length, 5);
      });

      test('preserva todos os campos do cliente', () async {
        final c = Customer(
          id: 'full',
          name: 'Nome Completo',
          document: '123.456.789-00',
          phone: '(11) 99999-0000',
          email: 'full@test.com',
          address: 'Rua Teste, 1',
        );
        await repo.save(c);
        final saved = (await repo.getAll()).firstWhere((x) => x.id == 'full');
        expect(saved.name, 'Nome Completo');
        expect(saved.document, '123.456.789-00');
        expect(saved.phone, '(11) 99999-0000');
        expect(saved.email, 'full@test.com');
        expect(saved.address, 'Rua Teste, 1');
      });
    });

    // ── save (update) ──────────────────────────────────────────────────────────

    group('save — update (upsert)', () {
      test('atualiza cliente existente pelo id', () async {
        final original = (await repo.getAll()).first;
        final updated = original.copyWith(name: 'Nome Atualizado');
        await repo.save(updated);

        final found = (await repo.getAll()).firstWhere((c) => c.id == original.id);
        expect(found.name, 'Nome Atualizado');
      });

      test('total não muda ao atualizar', () async {
        final original = (await repo.getAll()).first;
        await repo.save(original.copyWith(name: 'X'));
        expect((await repo.getAll()).length, 4);
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('remove cliente pelo id', () async {
        final id = (await repo.getAll()).first.id;
        await repo.delete(id);
        expect((await repo.getAll()).any((c) => c.id == id), isFalse);
      });

      test('total diminui em 1 após delete', () async {
        final id = (await repo.getAll()).first.id;
        await repo.delete(id);
        expect((await repo.getAll()).length, 3);
      });

      test('id inexistente não altera o repositório', () async {
        await repo.delete('nao-existe');
        expect((await repo.getAll()).length, 4);
      });
    });
  });
}
