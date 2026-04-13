import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/models/payment_condition.dart';

void main() {
  group('PaymentCondition', () {
    group('construtor', () {
      test('atribui id e name obrigatórios', () {
        const pc = PaymentCondition(id: 'pc1', name: 'À Vista');
        expect(pc.id, 'pc1');
        expect(pc.name, 'À Vista');
      });

      test('valores padrão: days = 0, interestRate = 0.0', () {
        const pc = PaymentCondition(id: 'x', name: 'Teste');
        expect(pc.days, 0);
        expect(pc.interestRate, 0.0);
      });

      test('days e interestRate customizados são atribuídos corretamente', () {
        const pc = PaymentCondition(
          id: 'pc4',
          name: '3x com juros (2%)',
          days: 30,
          interestRate: 2.0,
        );
        expect(pc.days, 30);
        expect(pc.interestRate, 2.0);
      });

      test('é const — pode ser declarada em tempo de compilação', () {
        const pc = PaymentCondition(id: 'pc1', name: 'À Vista', days: 0, interestRate: 0);
        expect(pc, isNotNull);
      });

      test('interestRate zero indica ausência de juros', () {
        const pc = PaymentCondition(id: 'pc2', name: '30 dias', days: 30, interestRate: 0);
        expect(pc.interestRate, 0.0);
      });

      test('interestRate 3.5 representa taxa de 3,5%', () {
        const pc = PaymentCondition(
          id: 'pc5',
          name: '6x com juros (3,5%)',
          days: 30,
          interestRate: 3.5,
        );
        expect(pc.interestRate, 3.5);
      });
    });

    group('condições padrão do sistema', () {
      const conditions = [
        PaymentCondition(id: 'pc1', name: 'À Vista', days: 0, interestRate: 0),
        PaymentCondition(id: 'pc2', name: '30 dias', days: 30, interestRate: 0),
        PaymentCondition(id: 'pc3', name: '2x sem juros', days: 30, interestRate: 0),
        PaymentCondition(id: 'pc4', name: '3x com juros (2%)', days: 30, interestRate: 2.0),
        PaymentCondition(id: 'pc5', name: '6x com juros (3,5%)', days: 30, interestRate: 3.5),
        PaymentCondition(id: 'pc6', name: '30/60/90 dias', days: 30, interestRate: 0),
      ];

      test('há exatamente 6 condições', () {
        expect(conditions.length, 6);
      });

      test('todos os IDs são únicos', () {
        final ids = conditions.map((pc) => pc.id).toSet();
        expect(ids.length, conditions.length);
      });

      test('todos os nomes são não vazios', () {
        expect(conditions.every((pc) => pc.name.isNotEmpty), isTrue);
      });

      test('pc1 é À Vista com days = 0 e sem juros', () {
        expect(conditions[0].name, 'À Vista');
        expect(conditions[0].days, 0);
        expect(conditions[0].interestRate, 0.0);
      });

      test('pc4 tem taxa de juros de 2%', () {
        expect(conditions[3].interestRate, 2.0);
      });

      test('pc5 tem taxa de juros de 3,5%', () {
        expect(conditions[4].interestRate, 3.5);
      });

      test('pc1, pc2, pc3 e pc6 não têm juros', () {
        for (final i in [0, 1, 2, 5]) {
          expect(conditions[i].interestRate, 0.0,
              reason: '${conditions[i].name} não deve ter juros');
        }
      });
    });
  });
}
