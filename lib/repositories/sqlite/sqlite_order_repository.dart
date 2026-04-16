import 'package:sqflite/sqflite.dart';
import '../../models/order.dart';
import '../../models/payment_condition.dart';
import '../../services/database_service.dart';
import '../order_repository.dart';

/// Implementação SQLite do [OrderRepository] — tabelas TMVOCAB e TMVOITE.
///
/// TMVOCAB armazena o cabeçalho do pedido.
/// TMVOITE armazena os itens vinculados ao IDPEDI.
class SqliteOrderRepository implements OrderRepository {
  final DatabaseService _dbService;

  SqliteOrderRepository(this._dbService);

  @override
  Future<List<Order>> getAll() async {
    final db = await _dbService.database;

    final cabRows = await db.query('TMVOCAB', orderBy: 'IDPEDI DESC');
    final orders = <Order>[];

    for (final cab in cabRows) {
      final idPedi = cab['IDPEDI'] as int;
      final iteRows = await db.query(
        'TMVOITE',
        where: 'IDPEDI = ?',
        whereArgs: [idPedi],
      );
      orders.add(_fromRows(cab, iteRows));
    }

    return orders;
  }

  @override
  Future<List<PaymentCondition>> getPaymentConditions() async {
    final db = await _dbService.database;
    final rows = await db.query('TMVOCNDPGTO', orderBy: 'IDCPGT ASC');
    return rows.map((r) => PaymentCondition(
          id: r['IDCPGT'] as String,
          name: r['NMCPGT'] as String,
          days: r['NRPRAZ'] as int,
          interestRate: (r['PCTAXA'] as num).toDouble(),
        )).toList();
  }

  @override
  Future<int> save(Order order) async {
    final db = await _dbService.database;

    if (order.id == null) {
      // INSERT — retorna o IDPEDI gerado pelo AUTOINCREMENT
      final idPedi = await db.insert('TMVOCAB', _cabToRow(order));
      order.id = idPedi;
      await _insertItems(db, idPedi, order.items);
      return idPedi;
    } else {
      // UPDATE — substitui cabeçalho e recria os itens
      await db.update(
        'TMVOCAB',
        _cabToRow(order),
        where: 'IDPEDI = ?',
        whereArgs: [order.id],
      );
      await db.delete('TMVOITE', where: 'IDPEDI = ?', whereArgs: [order.id]);
      await _insertItems(db, order.id!, order.items);
      return order.id!;
    }
  }

  @override
  Future<void> updateStatus(int id, OrderStatus status) async {
    final db = await _dbService.database;
    await db.update(
      'TMVOCAB',
      {'STPEDI': status.name},
      where: 'IDPEDI = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _dbService.database;
    // TMVOITE é deletado em cascata via FK (PRAGMA foreign_keys = ON)
    await db.delete('TMVOCAB', where: 'IDPEDI = ?', whereArgs: [id]);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _insertItems(
      Database db, int idPedi, List<OrderItem> items) async {
    for (final item in items) {
      await db.insert('TMVOITE', _iteToRow(idPedi, item));
    }
  }

  // ── Mapeamento: Dart → banco ───────────────────────────────────────────────

  Map<String, dynamic> _cabToRow(Order o) => {
        'DTCRIA': o.createdAt.toIso8601String(),
        'IDCLIE': o.customerId,
        'NMCLIE': o.customerName,
        'IDCPGT': o.paymentConditionId,
        'NMCPGT': o.paymentConditionName,
        'PCDSCT': o.discountPercent,
        'PCACRE': o.surchargePercent,
        'STPEDI': o.status.name,
        'TXOBSE': o.notes,
      };

  Map<String, dynamic> _iteToRow(int idPedi, OrderItem i) => {
        'IDPEDI': idPedi,
        'IDPROD': i.productId,
        'NMPROD': i.productName,
        'CDPROD': i.productCode,
        'CDUNID': i.productUnit,
        'QTITEM': i.quantity,
        'VLPREC': i.unitPrice,
        'PCDSCT': i.discountPercent,
      };

  // ── Mapeamento: banco → Dart ───────────────────────────────────────────────

  Order _fromRows(
      Map<String, dynamic> cab, List<Map<String, dynamic>> iteRows) {
    return Order(
      id: cab['IDPEDI'] as int,
      createdAt: DateTime.parse(cab['DTCRIA'] as String),
      customerId: cab['IDCLIE'] as String,
      customerName: cab['NMCLIE'] as String,
      paymentConditionId: cab['IDCPGT'] as String,
      paymentConditionName: cab['NMCPGT'] as String,
      discountPercent: (cab['PCDSCT'] as num).toDouble(),
      surchargePercent: (cab['PCACRE'] as num).toDouble(),
      status: OrderStatusExt.fromString(cab['STPEDI'] as String),
      notes: (cab['TXOBSE'] as String?) ?? '',
      items: iteRows.map(_itemFromRow).toList(),
    );
  }

  OrderItem _itemFromRow(Map<String, dynamic> row) => OrderItem(
        productId: row['IDPROD'] as String,
        productName: row['NMPROD'] as String,
        productCode: (row['CDPROD'] as String?) ?? '',
        productUnit: row['CDUNID'] as String,
        quantity: (row['QTITEM'] as num).toDouble(),
        unitPrice: (row['VLPREC'] as num).toDouble(),
        discountPercent: (row['PCDSCT'] as num).toDouble(),
      );
}
