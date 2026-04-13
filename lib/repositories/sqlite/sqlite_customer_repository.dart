import 'package:sqflite/sqflite.dart';
import '../../models/customer.dart';
import '../../services/database_service.dart';
import '../customer_repository.dart';

/// Implementação SQLite do [CustomerRepository] — tabela TMVOCLI.
class SqliteCustomerRepository implements CustomerRepository {
  final DatabaseService _dbService;

  SqliteCustomerRepository(this._dbService);

  @override
  Future<List<Customer>> getAll() async {
    final db = await _dbService.database;
    final rows = await db.query('TMVOCLI', orderBy: 'NMCLIE ASC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(Customer customer) async {
    final db = await _dbService.database;
    await db.insert(
      'TMVOCLI',
      _toRow(customer),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbService.database;
    await db.delete('TMVOCLI', where: 'IDCLIE = ?', whereArgs: [id]);
  }

  // ── Mapeamento ────────────────────────────────────────────────────────────

  Map<String, dynamic> _toRow(Customer c) => {
        'IDCLIE': c.id,
        'NMCLIE': c.name,
        'CDDOCU': c.document,
        'NRFONE': c.phone,
        'TXEMAI': c.email,
        'TXENDE': c.address,
      };

  Customer _fromRow(Map<String, dynamic> row) => Customer(
        id: row['IDCLIE'] as String,
        name: row['NMCLIE'] as String,
        document: (row['CDDOCU'] as String?) ?? '',
        phone: (row['NRFONE'] as String?) ?? '',
        email: (row['TXEMAI'] as String?) ?? '',
        address: (row['TXENDE'] as String?) ?? '',
      );
}
