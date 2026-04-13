import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:afv_basico/utils/formatters.dart';

void main() {
  setUpAll(() async {
    // Inicializa os dados de locale pt_BR necessários para DateFormat
    await initializeDateFormatting('pt_BR', null);
  });

  // ── formatCurrency ───────────────────────────────────────────────────────────

  group('formatCurrency', () {
    test('valor zero é formatado com separador decimal', () {
      final resultado = formatCurrency(0);
      expect(resultado, contains('0,00'));
    });

    test('valor inteiro tem duas casas decimais', () {
      final resultado = formatCurrency(100);
      expect(resultado, contains('100,00'));
    });

    test('valor decimal usa vírgula como separador', () {
      final resultado = formatCurrency(49.99);
      expect(resultado, contains('49,99'));
    });

    test('milhares usam ponto como separador', () {
      final resultado = formatCurrency(1234.56);
      expect(resultado, contains('1.234,56'));
    });

    test('símbolo R\$ está presente', () {
      final resultado = formatCurrency(100);
      expect(resultado, contains('R\$'));
    });

    test('valor grande com múltiplos separadores de milhar', () {
      final resultado = formatCurrency(1000000);
      expect(resultado, contains('1.000.000,00'));
    });

    test('arredonda corretamente para duas casas decimais', () {
      final resultado = formatCurrency(1.999);
      // 1.999 arredondado → 2,00
      expect(resultado, contains('2,00'));
    });
  });

  // ── formatPercent ────────────────────────────────────────────────────────────

  group('formatPercent', () {
    test('valor zero retorna "0%"', () {
      expect(formatPercent(0), '0%');
    });

    test('valor inteiro não mostra casas decimais desnecessárias', () {
      expect(formatPercent(10), '10%');
    });

    test('valor decimal usa vírgula como separador', () {
      final resultado = formatPercent(3.5);
      expect(resultado, contains('3,5'));
      expect(resultado, endsWith('%'));
    });

    test('valor com duas casas decimais', () {
      final resultado = formatPercent(2.75);
      expect(resultado, contains('2,75'));
      expect(resultado, endsWith('%'));
    });

    test('100% é formatado corretamente', () {
      expect(formatPercent(100), '100%');
    });

    test('valor menor que 1%', () {
      final resultado = formatPercent(0.5);
      expect(resultado, contains('0,5'));
      expect(resultado, endsWith('%'));
    });
  });

  // ── formatDate ───────────────────────────────────────────────────────────────

  group('formatDate', () {
    test('formato é dd/MM/yyyy', () {
      final data = DateTime(2025, 1, 5);
      expect(formatDate(data), '05/01/2025');
    });

    test('dia e mês com dois dígitos (com zero à esquerda)', () {
      expect(formatDate(DateTime(2025, 3, 7)), '07/03/2025');
    });

    test('data com dia e mês acima de 9 não tem zero à esquerda', () {
      expect(formatDate(DateTime(2025, 12, 31)), '31/12/2025');
    });

    test('ano de 4 dígitos', () {
      final resultado = formatDate(DateTime(2030, 6, 15));
      expect(resultado, endsWith('2030'));
    });

    test('ignora a parte de horário', () {
      final comHorario = DateTime(2025, 6, 20, 14, 30, 59);
      expect(formatDate(comHorario), '20/06/2025');
    });
  });

  // ── formatDateTime ────────────────────────────────────────────────────────────

  group('formatDateTime', () {
    test('formato é dd/MM/yyyy HH:mm', () {
      final dt = DateTime(2025, 6, 15, 9, 5);
      expect(formatDateTime(dt), '15/06/2025 09:05');
    });

    test('hora e minuto com zero à esquerda', () {
      final dt = DateTime(2025, 1, 1, 0, 0);
      expect(formatDateTime(dt), '01/01/2025 00:00');
    });

    test('hora e minuto acima de 9 sem zero à esquerda desnecessário', () {
      final dt = DateTime(2025, 12, 31, 23, 59);
      expect(formatDateTime(dt), '31/12/2025 23:59');
    });

    test('contém separador de data e espaço antes do horário', () {
      final dt = DateTime(2025, 6, 15, 14, 30);
      final resultado = formatDateTime(dt);
      expect(resultado, contains('/'));
      expect(resultado, contains(' '));
      expect(resultado, contains(':'));
    });

    test('formatDateTime e formatDate começam com a mesma data', () {
      final dt = DateTime(2025, 8, 20, 10, 45);
      expect(formatDateTime(dt), startsWith(formatDate(dt)));
    });
  });
}
