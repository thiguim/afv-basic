import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:afv_basico/screens/orders_screen.dart';
import 'package:afv_basico/controllers/order_controller.dart';
import 'package:afv_basico/models/order.dart';
import 'package:afv_basico/repositories/memory/memory_order_repository.dart';
import '../helpers.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Cria e adiciona um pedido ao controller, aguardando a operação async.
Future<Order> _addOrder(
  OrderController ctrl, {
  required String customerName,
  OrderStatus status = OrderStatus.pending,
}) async {
  final order = Order(
    createdAt: DateTime.now(),
    customerId: 'c1',
    customerName: customerName,
    items: [
      OrderItem(
        productId: 'p1',
        productName: 'Produto Teste',
        quantity: 1,
        unitPrice: 100.0,
      ),
    ],
    paymentConditionId: 'pc1',
    paymentConditionName: 'À Vista',
    status: status,
  );
  ctrl.add(order);
  await Future.delayed(Duration.zero);
  return order;
}

/// Cria um [OrderController] com repositório em memória limpo.
OrderController _freshCtrl() =>
    OrderController(MemoryOrderRepository());

/// Envolve OrdersScreen com apenas OrderController (screen não precisa dos outros).
Widget _wrapWithCtrl(OrderController ctrl) =>
    ChangeNotifierProvider<OrderController>.value(
      value: ctrl,
      child: const MaterialApp(home: OrdersScreen()),
    );

/// Substituto de [pumpAndSettle] para testes com [_wrapWithCtrl].
///
/// [pumpAndSettle] fica em loop infinito porque o [CustomScrollView] com
/// [SliverAppBar.large] + [SliverList] mantém a simulação de física de scroll
/// ativa mesmo sem interação do usuário. Pumpar por duração fixa é o padrão
/// recomendado para widgets com animações contínuas.
Future<void> _pumpFrames(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 300),
]) async {
  await tester.pump();
  await tester.pump(duration);
}

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR', null));

  group('OrdersScreen', () {
    // ── Estado inicial ─────────────────────────────────────────────────────────

    group('estado inicial (sem pedidos)', () {
      testWidgets('renderiza sem erros', (tester) async {
        await tester.pumpWidget(testApp(const OrdersScreen()));
        await tester.pumpAndSettle();
      });

      testWidgets('exibe chip "Todos" selecionado', (tester) async {
        await tester.pumpWidget(testApp(const OrdersScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Todos'), findsOneWidget);
      });

      testWidgets('exibe chip "Pendente"', (tester) async {
        await tester.pumpWidget(testApp(const OrdersScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Pendente'), findsOneWidget);
      });

      testWidgets('exibe chip "Confirmado"', (tester) async {
        await tester.pumpWidget(testApp(const OrdersScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Confirmado'), findsOneWidget);
      });

      testWidgets('exibe chip "Cancelado"', (tester) async {
        await tester.pumpWidget(testApp(const OrdersScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Cancelado'), findsOneWidget);
      });

      testWidgets('exibe EmptyState quando não há pedidos', (tester) async {
        await tester.pumpWidget(testApp(const OrdersScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Nenhum pedido'), findsOneWidget);
      });

      testWidgets('exibe FAB "Novo Pedido"', (tester) async {
        await tester.pumpWidget(testApp(const OrdersScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Novo Pedido'), findsOneWidget);
      });

      testWidgets('exibe ícone de adicionar na AppBar', (tester) async {
        await tester.pumpWidget(testApp(const OrdersScreen()));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.add), findsWidgets);
      });
    });

    // ── Exibição de pedidos ────────────────────────────────────────────────────

    group('exibição de pedidos', () {
      testWidgets('exibe nome do cliente do pedido', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Empresa XYZ');
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);
        expect(find.text('Empresa XYZ'), findsOneWidget);
      });

      testWidgets('exibe badge de status "Pendente" no card', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Cliente A', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);
        expect(find.text('Pendente'), findsWidgets);
      });

      testWidgets('exibe badge de status "Confirmado" no card', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Cliente B', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);
        expect(find.text('Confirmado'), findsWidgets);
      });

      testWidgets('exibe múltiplos pedidos simultâneos', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Cliente Alpha');
        await _addOrder(ctrl, customerName: 'Cliente Beta');
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);
        expect(find.text('Cliente Alpha'), findsOneWidget);
        expect(find.text('Cliente Beta'), findsOneWidget);
      });
    });

    // ── Filtros de status ──────────────────────────────────────────────────────

    group('filtros de status', () {
      testWidgets('filtro "Pendente" exibe apenas pedidos pendentes', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Pendente Alpha', status: OrderStatus.pending);
        await _addOrder(ctrl, customerName: 'Confirmado Beta', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.widgetWithText(FilterChip, 'Pendente'));
        await _pumpFrames(tester);

        expect(find.text('Pendente Alpha'), findsOneWidget);
        expect(find.text('Confirmado Beta'), findsNothing);
      });

      testWidgets('filtro "Confirmado" exibe apenas pedidos confirmados', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Pendente Alpha', status: OrderStatus.pending);
        await _addOrder(ctrl, customerName: 'Confirmado Beta', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.widgetWithText(FilterChip, 'Confirmado'));
        await _pumpFrames(tester);

        expect(find.text('Confirmado Beta'), findsOneWidget);
        expect(find.text('Pendente Alpha'), findsNothing);
      });

      testWidgets('filtro "Cancelado" exibe apenas pedidos cancelados', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Pendente X', status: OrderStatus.pending);
        await _addOrder(ctrl, customerName: 'Cancelado Y', status: OrderStatus.cancelled);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.widgetWithText(FilterChip, 'Cancelado'));
        await _pumpFrames(tester);

        expect(find.text('Cancelado Y'), findsOneWidget);
        expect(find.text('Pendente X'), findsNothing);
      });

      testWidgets('filtro ativo replicado retorna para "Todos"', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Cliente A', status: OrderStatus.pending);
        await _addOrder(ctrl, customerName: 'Cliente B', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.widgetWithText(FilterChip, 'Pendente'));
        await _pumpFrames(tester);
        expect(find.text('Cliente B'), findsNothing);

        await tester.tap(find.widgetWithText(FilterChip, 'Pendente'));
        await _pumpFrames(tester);
        expect(find.text('Cliente A'), findsOneWidget);
        expect(find.text('Cliente B'), findsOneWidget);
      });

      testWidgets('filtro sem correspondência exibe EmptyState', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Pendente X', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.widgetWithText(FilterChip, 'Confirmado'));
        await _pumpFrames(tester);
        expect(find.text('Nenhum pedido'), findsOneWidget);
      });
    });

    // ── Detalhe do pedido ──────────────────────────────────────────────────────

    group('detalhe do pedido', () {
      testWidgets('toque no card abre bottom sheet com detalhes', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Cliente Detalhe');
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.text('Cliente Detalhe'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));

        expect(find.text('Cliente'), findsWidgets);
        expect(find.text('À Vista'), findsWidgets);
      });

      testWidgets('pedido pendente exibe botões Cancelar e Confirmar no detalhe', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Pendente Detail', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.text('Pendente Detail'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);
      });

      testWidgets('confirmar pedido altera status para Confirmado', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Para Confirmar', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.text('Para Confirmar'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));
        await tester.tap(find.text('Confirmar'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));

        expect(ctrl.orders.first.status, OrderStatus.confirmed);
      });
    });

    // ── Botão Editar ───────────────────────────────────────────────────────────

    group('botão Editar', () {
      testWidgets('pedido pendente exibe botão Editar Pedido no detalhe', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Pendente Edit', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.text('Pendente Edit'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));

        expect(find.text('Editar Pedido'), findsOneWidget);
      });

      testWidgets('pedido confirmado NÃO exibe botão Editar Pedido', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Confirmado Edit', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.text('Confirmado Edit'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));

        expect(find.text('Editar Pedido'), findsNothing);
      });

      testWidgets('pedido cancelado NÃO exibe botão Editar Pedido', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Cancelado Edit', status: OrderStatus.cancelled);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.text('Cancelado Edit'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));

        expect(find.text('Editar Pedido'), findsNothing);
      });

      testWidgets('pedido confirmado NÃO exibe botões Cancelar e Confirmar', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Confirmado Sem Ações', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.text('Confirmado Sem Ações'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));

        expect(find.text('Cancelar'), findsNothing);
        expect(find.text('Confirmar'), findsNothing);
      });

      testWidgets('pedido cancelado NÃO exibe botões Cancelar e Confirmar', (tester) async {
        final ctrl = _freshCtrl();
        await _addOrder(ctrl, customerName: 'Cancelado Sem Ações', status: OrderStatus.cancelled);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await _pumpFrames(tester);

        await tester.tap(find.text('Cancelado Sem Ações'));
        await _pumpFrames(tester, const Duration(milliseconds: 500));

        expect(find.text('Cancelar'), findsNothing);
        expect(find.text('Confirmar'), findsNothing);
      });
    });
  });
}
