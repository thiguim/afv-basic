import 'package:flutter_test/flutter_test.dart';
import 'package:afv_basico/models/order.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

OrderItem _item({
  String productId = 'p1',
  String productName = 'Produto Teste',
  double quantity = 1,
  double unitPrice = 100.0,
  double discountPercent = 0,
}) =>
    OrderItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      discountPercent: discountPercent,
    );

Order _order({
  List<OrderItem>? items,
  double discountPercent = 0,
  double surchargePercent = 0,
  OrderStatus status = OrderStatus.pending,
}) =>
    Order(
      id: 1,
      createdAt: DateTime(2025, 6, 15),
      customerId: 'c1',
      customerName: 'Cliente Teste',
      items: items ?? [_item()],
      paymentConditionId: 'pc1',
      paymentConditionName: 'À Vista',
      discountPercent: discountPercent,
      surchargePercent: surchargePercent,
      status: status,
    );

void main() {
  // ── OrderStatus ─────────────────────────────────────────────────────────────

  group('OrderStatus - label', () {
    test('pending retorna "Pendente"', () {
      expect(OrderStatus.pending.label, 'Pendente');
    });

    test('confirmed retorna "Confirmado"', () {
      expect(OrderStatus.confirmed.label, 'Confirmado');
    });

    test('cancelled retorna "Cancelado"', () {
      expect(OrderStatus.cancelled.label, 'Cancelado');
    });
  });

  group('OrderStatusExt.fromString', () {
    test('converte "pending" corretamente', () {
      expect(OrderStatusExt.fromString('pending'), OrderStatus.pending);
    });

    test('converte "confirmed" corretamente', () {
      expect(OrderStatusExt.fromString('confirmed'), OrderStatus.confirmed);
    });

    test('converte "cancelled" corretamente', () {
      expect(OrderStatusExt.fromString('cancelled'), OrderStatus.cancelled);
    });

    test('valor desconhecido retorna pending como fallback', () {
      expect(OrderStatusExt.fromString('unknown'), OrderStatus.pending);
    });

    test('string vazia retorna pending como fallback', () {
      expect(OrderStatusExt.fromString(''), OrderStatus.pending);
    });
  });

  group('OrderStatus - colorValue', () {
    test('pending tem cor âmbar (0xFFF59E0B)', () {
      expect(OrderStatus.pending.colorValue, 0xFFF59E0B);
    });

    test('confirmed tem cor verde (0xFF10B981)', () {
      expect(OrderStatus.confirmed.colorValue, 0xFF10B981);
    });

    test('cancelled tem cor vermelha (0xFFEF4444)', () {
      expect(OrderStatus.cancelled.colorValue, 0xFFEF4444);
    });
  });

  // ── OrderItem ───────────────────────────────────────────────────────────────

  group('OrderItem - subtotal', () {
    test('sem desconto: qty × price', () {
      final item = _item(quantity: 3, unitPrice: 50.0);
      expect(item.subtotal, closeTo(150.0, 0.001));
    });

    test('com desconto de 10%', () {
      final item = _item(quantity: 2, unitPrice: 100.0, discountPercent: 10);
      // 2 × 100 × (1 - 0.10) = 180
      expect(item.subtotal, closeTo(180.0, 0.001));
    });

    test('com desconto de 50%', () {
      final item = _item(quantity: 1, unitPrice: 200.0, discountPercent: 50);
      expect(item.subtotal, closeTo(100.0, 0.001));
    });

    test('com desconto de 100% resulta em zero', () {
      final item = _item(quantity: 5, unitPrice: 99.0, discountPercent: 100);
      expect(item.subtotal, closeTo(0.0, 0.001));
    });

    test('sem desconto e quantidade fracionária', () {
      final item = _item(quantity: 1.5, unitPrice: 40.0);
      expect(item.subtotal, closeTo(60.0, 0.001));
    });

    test('valores padrão: discountPercent = 0', () {
      final item = OrderItem(
        productId: 'p1',
        productName: 'X',
        quantity: 1,
        unitPrice: 50.0,
      );
      expect(item.discountPercent, 0.0);
      expect(item.subtotal, closeTo(50.0, 0.001));
    });

    test('valores padrão: productCode e productUnit', () {
      final item = OrderItem(
        productId: 'p1',
        productName: 'X',
        quantity: 1,
        unitPrice: 10.0,
      );
      expect(item.productCode, '');
      expect(item.productUnit, 'UN');
    });
  });

  // ── Order ───────────────────────────────────────────────────────────────────

  group('Order - status padrão', () {
    test('status inicial é pending', () {
      expect(_order().status, OrderStatus.pending);
    });

    test('aceita status customizado', () {
      expect(_order(status: OrderStatus.confirmed).status, OrderStatus.confirmed);
    });
  });

  group('Order - itemsTotal', () {
    test('pedido com um item sem desconto', () {
      final o = _order(items: [_item(quantity: 2, unitPrice: 50.0)]);
      expect(o.itemsTotal, closeTo(100.0, 0.001));
    });

    test('pedido com múltiplos itens', () {
      final o = _order(items: [
        _item(quantity: 1, unitPrice: 100.0),
        _item(quantity: 2, unitPrice: 50.0),
        _item(quantity: 3, unitPrice: 10.0),
      ]);
      // 100 + 100 + 30 = 230
      expect(o.itemsTotal, closeTo(230.0, 0.001));
    });

    test('itens com desconto individual são considerados', () {
      final o = _order(items: [
        _item(quantity: 1, unitPrice: 100.0, discountPercent: 10), // subtotal = 90
        _item(quantity: 1, unitPrice: 50.0,  discountPercent: 0),  // subtotal = 50
      ]);
      expect(o.itemsTotal, closeTo(140.0, 0.001));
    });

    test('lista vazia resulta em zero', () {
      final o = _order(items: []);
      expect(o.itemsTotal, closeTo(0.0, 0.001));
    });
  });

  group('Order - discountAmount', () {
    test('sem desconto resulta em zero', () {
      final o = _order(items: [_item(unitPrice: 200.0)], discountPercent: 0);
      expect(o.discountAmount, closeTo(0.0, 0.001));
    });

    test('desconto de 10% sobre itemsTotal de 200', () {
      final o = _order(items: [_item(unitPrice: 200.0)], discountPercent: 10);
      expect(o.discountAmount, closeTo(20.0, 0.001));
    });

    test('desconto de 100% equivale ao itemsTotal', () {
      final o = _order(items: [_item(unitPrice: 100.0)], discountPercent: 100);
      expect(o.discountAmount, closeTo(100.0, 0.001));
    });
  });

  group('Order - surchargeAmount', () {
    test('sem acréscimo resulta em zero', () {
      final o = _order(items: [_item(unitPrice: 200.0)], surchargePercent: 0);
      expect(o.surchargeAmount, closeTo(0.0, 0.001));
    });

    test('acréscimo de 10% sem desconto prévio', () {
      final o = _order(items: [_item(unitPrice: 200.0)], surchargePercent: 10);
      // (200 - 0) × 10% = 20
      expect(o.surchargeAmount, closeTo(20.0, 0.001));
    });

    test('acréscimo é calculado sobre valor já descontado', () {
      final o = _order(
        items: [_item(unitPrice: 200.0)],
        discountPercent: 10,  // após desconto: 180
        surchargePercent: 10, // 10% de 180 = 18
      );
      expect(o.surchargeAmount, closeTo(18.0, 0.001));
    });
  });

  group('Order - total', () {
    test('sem desconto e sem acréscimo: total = itemsTotal', () {
      final o = _order(items: [_item(unitPrice: 300.0)]);
      expect(o.total, closeTo(300.0, 0.001));
    });

    test('com desconto e sem acréscimo', () {
      final o = _order(
        items: [_item(unitPrice: 200.0)],
        discountPercent: 25, // desconto = 50, total = 150
      );
      expect(o.total, closeTo(150.0, 0.001));
    });

    test('sem desconto e com acréscimo', () {
      final o = _order(
        items: [_item(unitPrice: 200.0)],
        surchargePercent: 10, // acréscimo = 20, total = 220
      );
      expect(o.total, closeTo(220.0, 0.001));
    });

    test('cálculo completo: itens + desconto de item + desconto de pedido + acréscimo', () {
      // Item: qty=2, price=100, itemDiscount=10% → subtotal = 180
      // itemsTotal = 180
      // orderDiscount = 10% → discountAmount = 18, afterDiscount = 162
      // orderSurcharge = 5% → surchargeAmount = 8.10
      // total = 162 + 8.10 = 170.10
      final o = _order(
        items: [_item(quantity: 2, unitPrice: 100.0, discountPercent: 10)],
        discountPercent: 10,
        surchargePercent: 5,
      );
      expect(o.total, closeTo(170.10, 0.01));
    });

    test('pedido vazio tem total zero', () {
      final o = _order(items: [], discountPercent: 10, surchargePercent: 5);
      expect(o.total, closeTo(0.0, 0.001));
    });

    test('status é mutável após criação', () {
      final o = _order();
      expect(o.status, OrderStatus.pending);
      o.status = OrderStatus.confirmed;
      expect(o.status, OrderStatus.confirmed);
    });
  });
}
