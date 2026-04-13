import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/models/product.dart';

void main() {
  group('Product', () {
    late Product base;

    setUp(() {
      base = Product(
        id: 'p-001',
        name: 'Notebook Dell',
        code: 'NB001',
        price: 3499.99,
        unit: 'UN',
      );
    });

    group('construtor', () {
      test('campos obrigatórios são atribuídos corretamente', () {
        final p = Product(id: 'x', name: 'Produto', price: 10.0);
        expect(p.id, 'x');
        expect(p.name, 'Produto');
        expect(p.price, 10.0);
      });

      test('campos opcionais têm valor padrão correto', () {
        final p = Product(id: 'x', name: 'Produto', price: 10.0);
        expect(p.code, '');
        expect(p.unit, 'UN');
      });

      test('todos os campos são armazenados corretamente', () {
        expect(base.id, 'p-001');
        expect(base.name, 'Notebook Dell');
        expect(base.code, 'NB001');
        expect(base.price, 3499.99);
        expect(base.unit, 'UN');
      });

      test('aceita diferentes unidades de medida', () {
        for (final unit in ['UN', 'PC', 'CX', 'KG', 'LT', 'MT', 'SC']) {
          final p = Product(id: 'x', name: 'X', price: 1.0, unit: unit);
          expect(p.unit, unit);
        }
      });
    });

    group('copyWith', () {
      test('retorna nova instância com o mesmo id', () {
        final copia = base.copyWith(name: 'Outro');
        expect(copia.id, base.id);
        expect(copia, isNot(same(base)));
      });

      test('altera apenas o campo name', () {
        final copia = base.copyWith(name: 'Mouse');
        expect(copia.name, 'Mouse');
        expect(copia.code, base.code);
        expect(copia.price, base.price);
        expect(copia.unit, base.unit);
      });

      test('altera apenas o campo code', () {
        final copia = base.copyWith(code: 'MS001');
        expect(copia.code, 'MS001');
        expect(copia.name, base.name);
        expect(copia.price, base.price);
      });

      test('altera apenas o campo price', () {
        final copia = base.copyWith(price: 99.90);
        expect(copia.price, 99.90);
        expect(copia.name, base.name);
        expect(copia.code, base.code);
      });

      test('altera apenas o campo unit', () {
        final copia = base.copyWith(unit: 'KG');
        expect(copia.unit, 'KG');
        expect(copia.name, base.name);
        expect(copia.price, base.price);
      });

      test('sem argumentos preserva todos os campos', () {
        final copia = base.copyWith();
        expect(copia.name, base.name);
        expect(copia.code, base.code);
        expect(copia.price, base.price);
        expect(copia.unit, base.unit);
      });

      test('altera múltiplos campos simultaneamente', () {
        final copia = base.copyWith(name: 'SSD', price: 349.90, unit: 'PC');
        expect(copia.name, 'SSD');
        expect(copia.price, 349.90);
        expect(copia.unit, 'PC');
        expect(copia.code, base.code);
      });
    });
  });
}
