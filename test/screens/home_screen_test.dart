import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:afv_basico/screens/home_screen.dart';
import '../helpers.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR', null));

  group('HomeScreen', () {
    testWidgets('renderiza sem erros', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
    });

    testWidgets('exibe título "Landix Basic" na AppBar', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Landix Basic'), findsWidgets);
    });

    testWidgets('exibe seção "Resumo do mês"', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Resumo do mês'), findsOneWidget);
    });

    testWidgets('exibe label do card "Clientes"', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Clientes'), findsOneWidget);
    });

    testWidgets('exibe label do card "Produtos"', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Produtos'), findsOneWidget);
    });

    testWidgets('exibe label do card "Pedidos"', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Pedidos'), findsOneWidget);
    });

    testWidgets('exibe label do card "Faturamento"', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Faturamento'), findsOneWidget);
    });

    testWidgets('card Clientes mostra 4 (seed data)', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      // CustomerController inicia com 4 clientes
      expect(find.text('4'), findsWidgets);
    });

    testWidgets('card Produtos mostra 8 (seed data)', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      // ProductController inicia com 8 produtos
      expect(find.text('8'), findsWidgets);
    });

    testWidgets('card Pedidos mostra 0 (sem pedidos iniciais)', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      // OrderController inicia sem pedidos — monthlyOrdersCount = 0
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('exibe seção "Pedidos recentes"', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Pedidos recentes'), findsOneWidget);
    });

    testWidgets('exibe mensagem vazia quando sem pedidos', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(
        find.text('Nenhum pedido ainda.\nCrie seu primeiro pedido!'),
        findsOneWidget,
      );
    });

    testWidgets('botão de tema está presente na AppBar', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      // Inicia em modo claro → ícone dark_mode
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });

    testWidgets('alternar tema muda ícone de dark para light', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    });

    testWidgets('exibe 4 cards de estatísticas no grid', (tester) async {
      await tester.pumpWidget(testApp(const HomeScreen()));
      await tester.pumpAndSettle();
      // GridView com 4 _StatCards
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
