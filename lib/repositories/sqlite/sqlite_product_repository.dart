import 'package:sqflite/sqflite.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import '../product_repository.dart';

/// Implementação SQLite do [ProductRepository] — tabela TMVOPROD.
class SqliteProductRepository implements ProductRepository {
  final DatabaseService _dbService;

  SqliteProductRepository(this._dbService);

  @override
  Future<List<Product>> getAll() async {
    final db = await _dbService.database;
    final rows = await db.query('TMVOPROD', orderBy: 'NMPROD ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(Product product) async {
    final db = await _dbService.database;
    await db.insert(
      'TMVOPROD',
      _toRow(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbService.database;
    await db.delete('TMVOPROD', where: 'IDPROD = ?', whereArgs: [id]);
  }

  // ── Mapeamento ────────────────────────────────────────────────────────────

  Map<String, dynamic> _toRow(Product p) => {
        'IDPROD': p.id,
        'NMPROD': p.name,
        'CDPROD': p.code,
        'VLPREC': p.price,
        'CDUNID': p.unit,
      };

  Product _fromRow(Map<String, dynamic> row) => Product(
        id: row['IDPROD'] as String,
        name: row['NMPROD'] as String,
        code: (row['CDPROD'] as String?) ?? '',
        price: (row['VLPREC'] as num).toDouble(),
        unit: row['CDUNID'] as String,
      );
}
