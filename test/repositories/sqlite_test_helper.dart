import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:afv_basico/services/database_service.dart';

/// Inicializa o SQLite FFI (necessário para rodar em desktop / CI).
/// Chame uma vez antes de qualquer teste SQLite (setUpAll).
void initSqliteFfi() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Abre um banco em memória com o schema completo do app e o injeta no
/// [DatabaseService.instance] para que os repositórios SQLite o usem.
Future<Database> openTestDatabase() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) => DatabaseService.applySchema(db),
    ),
  );
  DatabaseService.overrideForTesting(db);
  return db;
}
