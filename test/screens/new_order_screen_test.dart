import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:afv_basico/screens/new_order_screen.dart';
import '../helpers.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR', null));

  group('NewOrderScreen', () {
    // ── Estrutura básica ───────────────────────────────────────────────────────

    group('estrutura básica', () {
      testWidgets('renderiza sem erros', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('exibe título "Novo Pedido" na AppBar', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Novo Pedido'), findsOneWidget);
      });

      testWidgets('botão Salvar ausente quando dados incompletos', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        // FilledButton "Salvar" só aparece quando _canSave = true
        expect(find.widgetWithText(FilledButton, 'Salvar'), findsNothing);
      });

      testWidgets('exibe cabeçalho de seção "Cliente"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Cliente'), findsOneWidget);
      });

      testWidgets('exibe placeholder "Selecionar cliente"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Selecionar cliente'), findsOneWidget);
      });

      testWidgets('exibe cabeçalho de seção "Produtos"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Produtos'), findsOneWidget);
      });

      testWidgets('exibe hint "Adicionar produtos" quando carrinho vazio', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Adicionar produtos'), findsOneWidget);
      });

      testWidgets('exibe cabeçalho "Ajustes no Pedido"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Ajustes no Pedido'), findsOneWidget);
      });

      testWidgets('exibe campos de desconto e acréscimo', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Desconto (%)'), findsOneWidget);
        expect(find.text('Acréscimo (%)'), findsOneWidget);
      });

      testWidgets('exibe cabeçalho "Condição de Pagamento"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Condição de Pagamento'), findsOneWidget);
      });

      testWidgets('exibe cabeçalho "Observações"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Observações'), findsOneWidget);
      });
    });

    // ── Condições de pagamento ─────────────────────────────────────────────────

    group('condições de pagamento', () {
      testWidgets('exibe chip "À Vista"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('À Vista'), findsOneWidget);
      });

      testWidgets('exibe chip "30 dias"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('30 dias'), findsOneWidget);
      });

      testWidgets('exibe chip "2x sem juros"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('2x sem juros'), findsOneWidget);
      });

      testWidgets('exibe chip "3x com juros (2%)"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('3x com juros (2%)'), findsOneWidget);
      });

      testWidgets('exibe chip "6x com juros (3,5%)"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('6x com juros (3,5%)'), findsOneWidget);
      });

      testWidgets('exibe chip "30/60/90 dias"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('30/60/90 dias'), findsOneWidget);
      });

      testWidgets('exibe todos os 6 chips de pagamento (ChoiceChip)', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.byType(ChoiceChip), findsNWidgets(6));
      });
    });

    // ── Barra de total ─────────────────────────────────────────────────────────

    group('barra de total', () {
      testWidgets('exibe label "Total"', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Total'), findsOneWidget);
      });

      testWidgets(r'total inicial é R$ 0,00', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        expect(find.textContaining('0,00'), findsWidgets);
      });

      testWidgets('botão "Confirmar Pedido" está desabilitado sem dados', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        final btn = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Confirmar Pedido'),
        );
        expect(btn.onPressed, isNull);
      });
    });

    // ── Seletor de cliente ─────────────────────────────────────────────────────

    group('seletor de cliente', () {
      testWidgets('toque no seletor abre picker de clientes', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Selecionar cliente'));
        await tester.pumpAndSettle();
        // Picker exibe "Selecionar Cliente"
        expect(find.text('Selecionar Cliente'), findsOneWidget);
      });

      testWidgets('picker de clientes exibe clientes do seed data', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Selecionar cliente'));
        await tester.pumpAndSettle();
        expect(find.text('João Silva'), findsOneWidget);
        expect(find.text('Maria Souza'), findsOneWidget);
      });
    });

    // ── Adicionar produtos ─────────────────────────────────────────────────────

    group('adicionar produtos', () {
      testWidgets('toque em "Adicionar" abre picker de produtos', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Adicionar'));
        await tester.pumpAndSettle();
        // Picker exibe "Adicionar Produto"
        expect(find.text('Adicionar Produto'), findsOneWidget);
      });

      testWidgets('picker de produtos exibe produtos do seed data', (tester) async {
        await tester.pumpWidget(testApp(const NewOrderScreen()));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Adicionar'));
        await tester.pumpAndSettle();
        expect(find.text('Notebook Dell Inspiron'), findsOneWidget);
        expect(find.text('Mouse Wireless Logitech'), findsOneWidget);
      });
    });
  });
}
