import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/controllers/product_controller.dart';
import 'package:afv_basico/models/product.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Product _product({
  String id = 'new-id',
  String name = 'Produto Novo',
  String code = 'PN001',
  double price = 99.90,
  String unit = 'UN',
}) =>
    Product(id: id, name: name, code: code, price: price, unit: unit);

void main() {
  group('ProductController', () {
    late ProductController ctrl;

    setUp(() => ctrl = ProductController());
    tearDown(() => ctrl.dispose());

    // ── Dados iniciais ─────────────────────────────────────────────────────────

    group('seed data', () {
      test('começa com 8 produtos pré-cadastrados', () {
        expect(ctrl.products.length, 8);
      });

      test('lista retornada é imutável (unmodifiable)', () {
        expect(
          () => (ctrl.products as List<Product>).add(_product()),
          throwsUnsupportedError,
        );
      });

      test('todos os produtos do seed têm preço positivo', () {
        expect(ctrl.products.every((p) => p.price > 0), isTrue);
      });

      test('todos os produtos do seed têm nome não vazio', () {
        expect(ctrl.products.every((p) => p.name.isNotEmpty), isTrue);
      });
    });

    // ── add ────────────────────────────────────────────────────────────────────

    group('add', () {
      test('aumenta o total de produtos em 1', () {
        ctrl.add(_product());
        expect(ctrl.products.length, 9);
      });

      test('produto adicionado está presente na lista', () {
        final p = _product(id: 'novo', name: 'Produto Especial');
        ctrl.add(p);
        expect(ctrl.products.any((x) => x.id == 'novo'), isTrue);
      });

      test('notifica listeners ao adicionar', () {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.add(_product());
        expect(notificacoes, 1);
      });

      test('mantém todos os atributos do produto', () {
        final p = _product(
          id: 'p-test',
          name: 'Produto KG',
          code: 'KG001',
          price: 15.50,
          unit: 'KG',
        );
        ctrl.add(p);
        final salvo = ctrl.products.firstWhere((x) => x.id == 'p-test');
        expect(salvo.name, 'Produto KG');
        expect(salvo.code, 'KG001');
        expect(salvo.price, 15.50);
        expect(salvo.unit, 'KG');
      });
    });

    // ── update ─────────────────────────────────────────────────────────────────

    group('update', () {
      test('altera os dados do produto existente pelo id', () {
        final original = ctrl.products.first;
        final atualizado = original.copyWith(price: 9999.99);
        ctrl.update(atualizado);

        final encontrado = ctrl.products.firstWhere((p) => p.id == original.id);
        expect(encontrado.price, 9999.99);
      });

      test('não altera o total de produtos', () {
        final original = ctrl.products.first;
        ctrl.update(original.copyWith(name: 'Outro Nome'));
        expect(ctrl.products.length, 8);
      });

      test('notifica listeners ao atualizar', () {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.update(ctrl.products.first.copyWith(price: 1.0));
        expect(notificacoes, 1);
      });

      test('id inexistente não altera a lista nem notifica', () {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.update(_product(id: 'nao-existe'));
        expect(ctrl.products.length, 8);
        expect(notificacoes, 0);
      });
    });

    // ── delete ─────────────────────────────────────────────────────────────────

    group('delete', () {
      test('diminui o total de produtos em 1', () {
        final id = ctrl.products.first.id;
        ctrl.delete(id);
        expect(ctrl.products.length, 7);
      });

      test('produto removido não está mais na lista', () {
        final id = ctrl.products.first.id;
        ctrl.delete(id);
        expect(ctrl.products.any((p) => p.id == id), isFalse);
      });

      test('notifica listeners ao remover', () {
        var notificacoes = 0;
        ctrl.addListener(() => notificacoes++);
        ctrl.delete(ctrl.products.first.id);
        expect(notificacoes, 1);
      });

      test('id inexistente não altera a lista', () {
        ctrl.delete('id-que-nao-existe');
        expect(ctrl.products.length, 8);
      });

      test('deletar todos os produtos resulta em lista vazia', () {
        final ids = ctrl.products.map((p) => p.id).toList();
        for (final id in ids) {
          ctrl.delete(id);
        }
        expect(ctrl.products, isEmpty);
      });
    });

    // ── search ─────────────────────────────────────────────────────────────────

    group('search', () {
      test('query vazia retorna todos os produtos', () {
        expect(ctrl.search('').length, ctrl.products.length);
      });

      test('busca por nome — correspondência parcial', () {
        final resultado = ctrl.search('Notebook');
        expect(resultado.every((p) => p.name.toLowerCase().contains('notebook')), isTrue);
      });

      test('busca é case-insensitive para nome', () {
        final maiusculo = ctrl.search('NOTEBOOK');
        final minusculo = ctrl.search('notebook');
        expect(maiusculo.length, equals(minusculo.length));
        expect(maiusculo.length, greaterThan(0));
      });

      test('busca por código', () {
        final codigo = ctrl.products.first.code;
        final resultado = ctrl.search(codigo);
        expect(resultado.any((p) => p.code == codigo), isTrue);
      });

      test('busca por código é case-insensitive', () {
        final codigo = ctrl.products.first.code.toLowerCase();
        expect(ctrl.search(codigo), isNotEmpty);
      });

      test('query sem correspondência retorna lista vazia', () {
        expect(ctrl.search('zzzzzzzzz'), isEmpty);
      });

      test('não modifica a lista original', () {
        ctrl.search('Notebook');
        expect(ctrl.products.length, 8);
      });

      test('produto recém-adicionado é pesquisável imediatamente', () {
        ctrl.add(_product(id: 'z', name: 'Produto Ultraespecífico'));
        expect(ctrl.search('Ultraespecífico'), isNotEmpty);
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
