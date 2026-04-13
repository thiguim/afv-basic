import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:afv_basico/screens/orders_screen.dart';
import 'package:afv_basico/controllers/order_controller.dart';
import 'package:afv_basico/models/order.dart';
import '../helpers.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Adiciona um pedido simples ao controller de testes.
void _addOrder(
  OrderController ctrl, {
  required String id,
  required String customerName,
  OrderStatus status = OrderStatus.pending,
}) {
  ctrl.add(Order(
    id: id,
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
  ));
}

/// Envolve OrdersScreen com apenas OrderController (screen não precisa dos outros).
Widget _wrapWithCtrl(OrderController ctrl) =>
    ChangeNotifierProvider<OrderController>.value(
      value: ctrl,
      child: const MaterialApp(home: OrdersScreen()),
    );

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
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Empresa XYZ');
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();
        expect(find.text('Empresa XYZ'), findsOneWidget);
      });

      testWidgets('exibe badge de status "Pendente" no card', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Cliente A', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();
        // Badge no card + chip no filtro = findsWidgets
        expect(find.text('Pendente'), findsWidgets);
      });

      testWidgets('exibe badge de status "Confirmado" no card', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Cliente B', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();
        expect(find.text('Confirmado'), findsWidgets);
      });

      testWidgets('exibe múltiplos pedidos simultâneos', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Cliente Alpha');
        _addOrder(ctrl, id: 'order0002', customerName: 'Cliente Beta');
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();
        expect(find.text('Cliente Alpha'), findsOneWidget);
        expect(find.text('Cliente Beta'), findsOneWidget);
      });
    });

    // ── Filtros de status ──────────────────────────────────────────────────────

    group('filtros de status', () {
      testWidgets('filtro "Pendente" exibe apenas pedidos pendentes', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Pendente Alpha', status: OrderStatus.pending);
        _addOrder(ctrl, id: 'order0002', customerName: 'Confirmado Beta', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilterChip, 'Pendente'));
        await tester.pumpAndSettle();

        expect(find.text('Pendente Alpha'), findsOneWidget);
        expect(find.text('Confirmado Beta'), findsNothing);
      });

      testWidgets('filtro "Confirmado" exibe apenas pedidos confirmados', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Pendente Alpha', status: OrderStatus.pending);
        _addOrder(ctrl, id: 'order0002', customerName: 'Confirmado Beta', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilterChip, 'Confirmado'));
        await tester.pumpAndSettle();

        expect(find.text('Confirmado Beta'), findsOneWidget);
        expect(find.text('Pendente Alpha'), findsNothing);
      });

      testWidgets('filtro "Cancelado" exibe apenas pedidos cancelados', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Pendente X', status: OrderStatus.pending);
        _addOrder(ctrl, id: 'order0002', customerName: 'Cancelado Y', status: OrderStatus.cancelled);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilterChip, 'Cancelado'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelado Y'), findsOneWidget);
        expect(find.text('Pendente X'), findsNothing);
      });

      testWidgets('filtro ativo relicado retorna para "Todos"', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Cliente A', status: OrderStatus.pending);
        _addOrder(ctrl, id: 'order0002', customerName: 'Cliente B', status: OrderStatus.confirmed);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();

        // Ativa filtro Pendente → só Cliente A visível
        await tester.tap(find.widgetWithText(FilterChip, 'Pendente'));
        await tester.pumpAndSettle();
        expect(find.text('Cliente B'), findsNothing);

        // Toca novamente em Pendente → desativa filtro
        await tester.tap(find.widgetWithText(FilterChip, 'Pendente'));
        await tester.pumpAndSettle();
        expect(find.text('Cliente A'), findsOneWidget);
        expect(find.text('Cliente B'), findsOneWidget);
      });

      testWidgets('filtro sem correspondência exibe EmptyState', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Pendente X', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();

        // Não há confirmados
        await tester.tap(find.widgetWithText(FilterChip, 'Confirmado'));
        await tester.pumpAndSettle();
        expect(find.text('Nenhum pedido'), findsOneWidget);
      });
    });

    // ── Detalhe do pedido ──────────────────────────────────────────────────────

    group('detalhe do pedido', () {
      testWidgets('toque no card abre bottom sheet com detalhes', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Cliente Detalhe');
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cliente Detalhe'));
        await tester.pumpAndSettle();

        // Sheet exibe info do cliente e condição de pagamento
        expect(find.text('Cliente'), findsWidgets);
        expect(find.text('À Vista'), findsWidgets);
      });

      testWidgets('pedido pendente exibe botões Cancelar e Confirmar no detalhe', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Pendente Detail', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pendente Detail'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);
      });

      testWidgets('confirmar pedido altera status para Confirmado', (tester) async {
        final ctrl = OrderController();
        _addOrder(ctrl, id: 'order0001', customerName: 'Para Confirmar', status: OrderStatus.pending);
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(_wrapWithCtrl(ctrl));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Para Confirmar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(ctrl.orders.first.status, OrderStatus.confirmed);
      });
    });
  });
}
