import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/models/customer.dart';

void main() {
  group('Customer', () {
    late Customer base;

    setUp(() {
      base = Customer(
        id: 'c-001',
        name: 'João Silva',
        document: '123.456.789-00',
        phone: '(11) 98765-4321',
        email: 'joao@email.com',
        address: 'Rua das Flores, 123',
      );
    });

    group('construtor', () {
      test('campos obrigatórios são atribuídos corretamente', () {
        final c = Customer(id: 'x', name: 'Teste');
        expect(c.id, 'x');
        expect(c.name, 'Teste');
      });

      test('campos opcionais têm valor padrão vazio', () {
        final c = Customer(id: 'x', name: 'Teste');
        expect(c.document, '');
        expect(c.phone, '');
        expect(c.email, '');
        expect(c.address, '');
      });

      test('todos os campos são armazenados corretamente', () {
        expect(base.id, 'c-001');
        expect(base.name, 'João Silva');
        expect(base.document, '123.456.789-00');
        expect(base.phone, '(11) 98765-4321');
        expect(base.email, 'joao@email.com');
        expect(base.address, 'Rua das Flores, 123');
      });
    });

    group('copyWith', () {
      test('retorna nova instância com o mesmo id', () {
        final copia = base.copyWith(name: 'Outro Nome');
        expect(copia.id, base.id);
        expect(copia, isNot(same(base)));
      });

      test('altera apenas o campo name', () {
        final copia = base.copyWith(name: 'Maria');
        expect(copia.name, 'Maria');
        expect(copia.document, base.document);
        expect(copia.phone, base.phone);
        expect(copia.email, base.email);
        expect(copia.address, base.address);
      });

      test('altera apenas o campo document', () {
        final copia = base.copyWith(document: '000.000.000-00');
        expect(copia.document, '000.000.000-00');
        expect(copia.name, base.name);
      });

      test('altera apenas o campo phone', () {
        final copia = base.copyWith(phone: '(21) 99999-0000');
        expect(copia.phone, '(21) 99999-0000');
        expect(copia.name, base.name);
      });

      test('altera apenas o campo email', () {
        final copia = base.copyWith(email: 'novo@email.com');
        expect(copia.email, 'novo@email.com');
        expect(copia.name, base.name);
      });

      test('altera apenas o campo address', () {
        final copia = base.copyWith(address: 'Av. Paulista, 1000');
        expect(copia.address, 'Av. Paulista, 1000');
        expect(copia.name, base.name);
      });

      test('sem argumentos preserva todos os campos', () {
        final copia = base.copyWith();
        expect(copia.name, base.name);
        expect(copia.document, base.document);
        expect(copia.phone, base.phone);
        expect(copia.email, base.email);
        expect(copia.address, base.address);
      });

      test('altera múltiplos campos simultaneamente', () {
        final copia = base.copyWith(name: 'Ana', email: 'ana@email.com');
        expect(copia.name, 'Ana');
        expect(copia.email, 'ana@email.com');
        expect(copia.phone, base.phone);
      });
    });
  });
}
