import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/widgets/empty_state.dart';

Widget _build(EmptyState widget) =>
    MaterialApp(home: Scaffold(body: widget));

void main() {
  group('EmptyState', () {
    testWidgets('exibe o título passado', (tester) async {
      await tester.pumpWidget(_build(const EmptyState(
        icon: Icons.inbox,
        title: 'Lista vazia',
        subtitle: 'Adicione um item',
      )));
      expect(find.text('Lista vazia'), findsOneWidget);
    });

    testWidgets('exibe o subtítulo passado', (tester) async {
      await tester.pumpWidget(_build(const EmptyState(
        icon: Icons.inbox,
        title: 'Lista vazia',
        subtitle: 'Toque em + para adicionar',
      )));
      expect(find.text('Toque em + para adicionar'), findsOneWidget);
    });

    testWidgets('exibe o ícone correto', (tester) async {
      await tester.pumpWidget(_build(const EmptyState(
        icon: Icons.people_outline,
        title: 'Nenhum cliente',
        subtitle: 'Adicione um cliente',
      )));
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('ícone diferente é exibido corretamente', (tester) async {
      await tester.pumpWidget(_build(const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Nenhum produto',
        subtitle: 'Cadastre um produto',
      )));
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('título e subtítulo distintos são exibidos simultaneamente', (tester) async {
      await tester.pumpWidget(_build(const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Nenhum pedido',
        subtitle: 'Crie seu primeiro pedido',
      )));
      expect(find.text('Nenhum pedido'), findsOneWidget);
      expect(find.text('Crie seu primeiro pedido'), findsOneWidget);
    });

    testWidgets('widget está centralizado na tela', (tester) async {
      await tester.pumpWidget(_build(const EmptyState(
        icon: Icons.inbox,
        title: 'Título',
        subtitle: 'Subtítulo',
      )));
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('não exibe ícone de outro tipo', (tester) async {
      await tester.pumpWidget(_build(const EmptyState(
        icon: Icons.people_outline,
        title: 'Título',
        subtitle: 'Subtítulo',
      )));
      expect(find.byIcon(Icons.inbox), findsNothing);
    });

    testWidgets('exibe coluna de conteúdo', (tester) async {
      await tester.pumpWidget(_build(const EmptyState(
        icon: Icons.inbox,
        title: 'Título',
        subtitle: 'Subtítulo',
      )));
      expect(find.byType(Column), findsWidgets);
    });
  });
}
