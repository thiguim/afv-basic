import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/controllers/customer_controller.dart';
import 'package:afv_basico/models/customer.dart';
import 'package:afv_basico/repositories/memory/memory_customer_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Customer _customer({
  String id = 'new-id',
  String name = 'Cliente Novo',
  String document = '000.000.000-00',
  String phone = '(11) 99999-0000',
  String email = 'novo@email.com',
  String address = 'Rua Nova, 1',
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
  group('CustomerController', () {
    late CustomerController ctrl;

    setUp(() async {
      ctrl = CustomerController(MemoryCustomerRepository());
      await Future.delayed(Duration.zero); // aguarda _load() completar
    });
    tearDown(() => ctrl.dispose());

    // ── Dados iniciais ─────────────────────────────────────────────────────────

    group('seed data', () {
      test('começa com 4 clientes pré-cadastrados', () {
        expect(ctrl.customers.length, 4);
      });

      test('lista retornada é imutável (unmodifiable)', () {
        expect(
          () => (ctrl.customers as List<Customer>).add(_customer()),
          throwsUnsupportedError,
        );
      });
    });

    // ── add ────────────────────────────────────────────────────────────────────

    group('add', () {
      test('aumenta o total de clientes em 1', () async {
        ctrl.add(_customer());
        await Future.delayed(Duration.zero);
        expect(ctrl.customers.length, 5);
      });

      test('cliente adicionado está presente na lista', () async {
        final c = _customer(id: 'novo', name: 'Maria Nova');
        ctrl.add(c);
        await Future.delayed(Duration.zero);
        expect(ctrl.customers.any((x) => x.id == 'novo'), isTrue);
      });

      test('notifica listeners ao adicionar', () async {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.add(_customer());
        await Future.delayed(Duration.zero);
        expect(notificacoes, 1);
      });

      test('adicionar múltiplos clientes acumula corretamente', () async {
        ctrl.add(_customer(id: 'a'));
        ctrl.add(_customer(id: 'b'));
        ctrl.add(_customer(id: 'c'));
        await Future.delayed(Duration.zero);
        expect(ctrl.customers.length, 7);
      });
    });

    // ── update ─────────────────────────────────────────────────────────────────

    group('update', () {
      test('altera os dados do cliente existente pelo id', () async {
        final original = ctrl.customers.first;
        final atualizado = original.copyWith(name: 'Nome Alterado');
        ctrl.update(atualizado);
        await Future.delayed(Duration.zero);

        final encontrado = ctrl.customers.firstWhere((c) => c.id == original.id);
        expect(encontrado.name, 'Nome Alterado');
      });

      test('não altera o total de clientes', () async {
        final original = ctrl.customers.first;
        ctrl.update(original.copyWith(name: 'Outro'));
        await Future.delayed(Duration.zero);
        expect(ctrl.customers.length, 4);
      });

      test('notifica listeners ao atualizar', () async {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.update(ctrl.customers.first.copyWith(name: 'X'));
        await Future.delayed(Duration.zero);
        expect(notificacoes, 1);
      });

      test('id inexistente não altera a lista nem notifica', () async {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.update(_customer(id: 'nao-existe'));
        await Future.delayed(Duration.zero);
        expect(ctrl.customers.length, 4);
        expect(notificacoes, 0);
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('diminui o total de clientes em 1', () async {
        final id = ctrl.customers.first.id;
        ctrl.delete(id);
        await Future.delayed(Duration.zero);
        expect(ctrl.customers.length, 3);
      });

      test('cliente removido não está mais na lista', () async {
        final id = ctrl.customers.first.id;
        ctrl.delete(id);
        await Future.delayed(Duration.zero);
        expect(ctrl.customers.any((c) => c.id == id), isFalse);
      });

      test('notifica listeners ao remover', () async {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.delete(ctrl.customers.first.id);
        await Future.delayed(Duration.zero);
        expect(notificacoes, 1);
      });

      test('id inexistente não altera a lista', () async {
        ctrl.delete('id-que-nao-existe');
        await Future.delayed(Duration.zero);
        expect(ctrl.customers.length, 4);
      });
    });

    // ── search ─────────────────────────────────────────────────────────────────

    group('search', () {
      test('query vazia retorna todos os clientes', () {
        expect(ctrl.search('').length, ctrl.customers.length);
      });

      test('busca por nome — correspondência parcial', () {
        final resultado = ctrl.search('João');
        expect(resultado.any((c) => c.name.contains('João')), isTrue);
      });

      test('busca é case-insensitive para nome', () {
        final maiusculo = ctrl.search('JOÃO');
        final minusculo = ctrl.search('joão');
        expect(maiusculo.length, minusculo.length);
      });

      test('busca por CPF/CNPJ', () {
        final doc = ctrl.customers.first.document;
        final resultado = ctrl.search(doc.substring(0, 6));
        expect(resultado.isNotEmpty, isTrue);
      });

      test('busca por telefone', () {
        final tel = ctrl.customers.first.phone;
        final resultado = ctrl.search(tel.substring(0, 5));
        expect(resultado.isNotEmpty, isTrue);
      });

      test('query sem correspondência retorna lista vazia', () {
        expect(ctrl.search('xxxxxxxxxxx'), isEmpty);
      });

      test('não modifica a lista original', () {
        ctrl.search('João');
        expect(ctrl.customers.length, 4);
      });

      test('adicionar cliente novo o torna pesquisável', () async {
        ctrl.add(_customer(id: 'z', name: 'Zélia Novak'));
        await Future.delayed(Duration.zero);
        expect(ctrl.search('Zélia'), isNotEmpty);
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
