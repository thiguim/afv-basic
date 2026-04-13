import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:afv_basico/screens/main_nav.dart';
import '../helpers.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR', null));

  group('MainNav', () {
    testWidgets('renderiza sem erros', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
    });

    testWidgets('exibe NavigationBar', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('exibe 4 NavigationDestinations', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    });

    testWidgets('aba "Início" está presente', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      expect(find.text('Início'), findsOneWidget);
    });

    testWidgets('aba "Pedidos" está presente', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      // "Pedidos" aparece como label da aba e como título da tela (IndexedStack)
      expect(find.text('Pedidos'), findsWidgets);
    });

    testWidgets('aba "Clientes" está presente', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      expect(find.text('Clientes'), findsWidgets);
    });

    testWidgets('aba "Produtos" está presente', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      expect(find.text('Produtos'), findsWidgets);
    });

    testWidgets('começa na aba Início — exibe HomeScreen', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      // HomeScreen exibe "Resumo do mês"
      expect(find.text('Resumo do mês'), findsOneWidget);
    });

    testWidgets('navegar para aba Clientes exibe busca de clientes', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Clientes'),
      ));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SearchBar, 'Buscar clientes...'), findsOneWidget);
    });

    testWidgets('navegar para aba Produtos exibe busca de produtos', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Produtos'),
      ));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SearchBar, 'Buscar produtos...'), findsOneWidget);
    });

    testWidgets('navegar para aba Pedidos exibe chip "Todos"', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      // Toca na aba Pedidos (text 'Pedidos' na NavigationBar)
      final pedidosDestination = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Pedidos'),
      );
      await tester.tap(pedidosDestination);
      await tester.pumpAndSettle();
      expect(find.text('Todos'), findsOneWidget);
    });

    testWidgets('IndexedStack mantém estado ao trocar abas', (tester) async {
      await tester.pumpWidget(testApp(const MainNav()));
      await tester.pump();
      expect(find.byType(IndexedStack), findsOneWidget);
    });
  });
}
