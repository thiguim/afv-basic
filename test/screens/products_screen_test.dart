import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:afv_basico/screens/products_screen.dart';
import '../helpers.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR', null));

  group('ProductsScreen', () {
    testWidgets('renderiza sem erros', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
    });

    testWidgets('exibe SearchBar de busca', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(SearchBar), findsOneWidget);
    });

    testWidgets('hint text é "Buscar produtos..."', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SearchBar, 'Buscar produtos...'), findsOneWidget);
    });

    testWidgets('exibe FAB com ícone de adicionar', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('exibe Notebook Dell Inspiron do seed data', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Notebook Dell Inspiron'), findsOneWidget);
    });

    testWidgets('exibe Mouse Wireless Logitech do seed data', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Mouse Wireless Logitech'), findsOneWidget);
    });

    testWidgets('exibe preço do Notebook formatado em reais', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      // Notebook Dell Inspiron: R$ 3.499,99
      expect(find.textContaining('3.499,99'), findsWidgets);
    });

    testWidgets('busca por nome filtra resultados corretamente', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'Notebook');
      await tester.pumpAndSettle();
      expect(find.text('Notebook Dell Inspiron'), findsOneWidget);
      expect(find.text('Mouse Wireless Logitech'), findsNothing);
    });

    testWidgets('busca por código (NB001) filtra corretamente', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'NB001');
      await tester.pumpAndSettle();
      expect(find.text('Notebook Dell Inspiron'), findsOneWidget);
      expect(find.text('Mouse Wireless Logitech'), findsNothing);
    });

    testWidgets('busca sem resultado exibe EmptyState "Nenhum resultado"', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'zzzzzzzzzz');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum resultado'), findsOneWidget);
    });

    testWidgets('ícone fechar (×) aparece ao digitar na busca', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsNothing);
      await tester.enterText(find.byType(SearchBar), 'abc');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('toque no ícone fechar restaura lista completa', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'Notebook');
      await tester.pumpAndSettle();
      expect(find.text('Mouse Wireless Logitech'), findsNothing);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Mouse Wireless Logitech'), findsOneWidget);
    });

    testWidgets('busca é case-insensitive', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'NOTEBOOK');
      await tester.pumpAndSettle();
      expect(find.text('Notebook Dell Inspiron'), findsOneWidget);
    });

    testWidgets('toque no card do produto abre formulário de edição', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notebook Dell Inspiron'));
      await tester.pumpAndSettle();
      expect(find.text('Editar Produto'), findsOneWidget);
    });

    testWidgets('toque no FAB abre formulário de novo produto', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Novo Produto'), findsOneWidget);
    });

    testWidgets('formulário de novo produto exige campo Nome', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      // Toca em Cadastrar sem preencher nome
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();
      expect(find.text('Nome obrigatório'), findsOneWidget);
    });

    testWidgets('formulário de novo produto exige campo Preço', (tester) async {
      await tester.pumpWidget(testApp(const ProductsScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      // Preenche nome mas não preço
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome do produto *'), 'Produto Teste');
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();
      expect(find.text('Preço obrigatório'), findsOneWidget);
    });
  });
}
