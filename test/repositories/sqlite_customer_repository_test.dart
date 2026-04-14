import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:afv_basico/models/customer.dart';
import 'package:afv_basico/repositories/sqlite/sqlite_customer_repository.dart';
import 'package:afv_basico/services/database_service.dart';
import 'sqlite_test_helper.dart';

Customer _customer({
  String id = 'test-id',
  String name = 'Cliente Teste',
  String document = '000.000.000-00',
  String phone = '(11) 99999-0000',
  String email = 'teste@email.com',
  String address = 'Rua Teste, 1',
}) =>
    Customer(
      id: id,
      name: name,
      document: document,
      phone: phone,
      email: email,
      address: address,
    );

void main() {
  setUpAll(initSqliteFfi);

  group('SqliteCustomerRepository', () {
    late Database db;
    late SqliteCustomerRepository repo;

    setUp(() async {
      db = await openTestDatabase();
      repo = SqliteCustomerRepository(DatabaseService.instance);
    });

    tearDown(() async => db.close());

    // ── getAll ─────────────────────────────────────────────────────────────────

    group('getAll', () {
      test('banco vazio retorna lista vazia', () async {
        expect(await repo.getAll(), isEmpty);
      });

      test('retorna todos os clientes inseridos', () async {
        await repo.save(_customer(id: 'c1', name: 'Ana'));
        await repo.save(_customer(id: 'c2', name: 'Bruno'));
        expect((await repo.getAll()).length, 2);
      });

      test('retorna ordenado por NMCLIE ASC', () async {
        await repo.save(_customer(id: 'c1', name: 'Zé'));
        await repo.save(_customer(id: 'c2', name: 'Ana'));
        final all = await repo.getAll();
        expect(all.first.name, 'Ana');
        expect(all.last.name, 'Zé');
      });
    });

    // ── save (insert) ──────────────────────────────────────────────────────────

    group('save — insert', () {
      test('persiste cliente no banco', () async {
        await repo.save(_customer(id: 'c1'));
        expect((await repo.getAll()).any((c) => c.id == 'c1'), isTrue);
      });

      test('preserva todos os campos', () async {
        final c = _customer(
          id: 'full',
          name: 'Nome Completo',
          document: '123.456.789-00',
          phone: '(11) 91111-2222',
          email: 'full@email.com',
          address: 'Av. Completa, 100',
        );
        await repo.save(c);
        final saved = (await repo.getAll()).first;
        expect(saved.name, 'Nome Completo');
        expect(saved.document, '123.456.789-00');
        expect(saved.phone, '(11) 91111-2222');
        expect(saved.email, 'full@email.com');
        expect(saved.address, 'Av. Completa, 100');
      });
    });

    // ── save (update / replace) ────────────────────────────────────────────────

    group('save — update (upsert)', () {
      test('atualiza cliente existente sem duplicar', () async {
        await repo.save(_customer(id: 'c1', name: 'Original'));
        await repo.save(_customer(id: 'c1', name: 'Atualizado'));
        final all = await repo.getAll();
        expect(all.length, 1);
        expect(all.first.name, 'Atualizado');
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('remove cliente do banco', () async {
        await repo.save(_customer(id: 'c1'));
        await repo.delete('c1');
        expect((await repo.getAll()).any((c) => c.id == 'c1'), isFalse);
      });

      test('id inexistente não gera erro e não altera o banco', () async {
        await repo.save(_customer(id: 'c1'));
        await repo.delete('nao-existe');
        expect((await repo.getAll()).length, 1);
      });
    });
  });
}
