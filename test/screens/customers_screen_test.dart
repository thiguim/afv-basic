import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/screens/customers_screen.dart';
import '../helpers.dart';

void main() {
  group('CustomersScreen', () {
    testWidgets('renderiza sem erros', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
    });

    testWidgets('exibe SearchBar de busca', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(SearchBar), findsOneWidget);
    });

    testWidgets('hint text é "Buscar clientes..."', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(SearchBar, 'Buscar clientes...'), findsOneWidget);
    });

    testWidgets('exibe FAB com ícone de adicionar cliente', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
    });

    testWidgets('exibe todos os 4 clientes do seed data', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('Maria Souza'), findsOneWidget);
      expect(find.text('Empresa Carlos Ltda'), findsOneWidget);
      expect(find.text('Ana Ferreira'), findsOneWidget);
    });

    testWidgets('busca por nome filtra corretamente', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'João');
      await tester.pumpAndSettle();
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('Maria Souza'), findsNothing);
      expect(find.text('Ana Ferreira'), findsNothing);
    });

    testWidgets('busca por documento filtra corretamente', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      // João Silva tem documento "123.456.789-00"
      await tester.enterText(find.byType(SearchBar), '123.456');
      await tester.pumpAndSettle();
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('Maria Souza'), findsNothing);
    });

    testWidgets('busca sem resultado exibe EmptyState "Nenhum resultado"', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'zzzzzzzzzz');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum resultado'), findsOneWidget);
    });

    testWidgets('ícone fechar (×) aparece ao digitar na busca', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsNothing);
      await tester.enterText(find.byType(SearchBar), 'teste');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('toque no ícone fechar limpa busca e restaura lista completa', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'João');
      await tester.pumpAndSettle();
      expect(find.text('Maria Souza'), findsNothing);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Maria Souza'), findsOneWidget);
      expect(find.text('João Silva'), findsOneWidget);
    });

    testWidgets('busca é case-insensitive', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'JOÃO');
      await tester.pumpAndSettle();
      expect(find.text('João Silva'), findsOneWidget);
    });

    testWidgets('exibe ícone de busca na SearchBar', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('toque no card do cliente abre bottom sheet de detalhe', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('João Silva'));
      await tester.pumpAndSettle();
      // Bottom sheet de detalhe exibe botões Editar e Excluir
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
    });

    testWidgets('toque no FAB abre formulário de novo cliente', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Novo Cliente'), findsOneWidget);
    });

    testWidgets('formulário de novo cliente exige campo Nome', (tester) async {
      await tester.pumpWidget(testApp(const CustomersScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      // Toca em Cadastrar sem preencher nome
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();
      expect(find.text('Nome obrigatório'), findsOneWidget);
    });
  });
}
