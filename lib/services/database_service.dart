import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

/// Gerencia a conexão com o banco SQLite local.
///
/// Caminho no aparelho: /storage/emulated/0/landix/dados/afvbasico.db
/// A pasta é criada automaticamente na primeira inicialização.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  /// Injeta um banco já aberto — usar apenas em testes.
  @visibleForTesting
  static void overrideForTesting(Database db) => instance._db = db;

  // ── Abertura ──────────────────────────────────────────────────────────────

  static const _dbPath = '/storage/emulated/0/landix/dados';
  static const _dbFile = 'afvbasico.db';
  static const _dbVersion = 1;

  Future<Database> _open() async {
    await _ensurePermission();
    final dir = Directory(_dbPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return openDatabase(
      '$_dbPath/$_dbFile',
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  /// Habilita suporte a chaves estrangeiras (desativado por padrão no SQLite).
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ── Permissões ────────────────────────────────────────────────────────────

  Future<void> _ensurePermission() async {
    if (Platform.isAndroid) {
      final manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      // Fallback para Android ≤ 9
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isDenied) {
        await Permission.storage.request();
      }
    }
  }

  // ── Schema ────────────────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await applySchema(db);
    await _seedData(db);
  }

  // ── Seed ──────────────────────────────────────────────────────────────────

  /// Insere dados iniciais de exemplo — executado apenas na criação do banco.
  static Future<void> _seedData(Database db) async {
    // Clientes
    await db.insert('TMVOCLI', {
      'IDCLIE': 'cli-001',
      'NMCLIE': 'Mercado Central Ltda',
      'CDDOCU': '12.345.678/0001-90',
      'NRFONE': '(11) 98765-4321',
      'TXEMAI': 'compras@mercadocentral.com.br',
      'TXENDE': 'Av. Paulista, 1000 - Bela Vista, São Paulo/SP',
    });
    await db.insert('TMVOCLI', {
      'IDCLIE': 'cli-002',
      'NMCLIE': 'Distribuidora Norte S.A.',
      'CDDOCU': '98.765.432/0001-10',
      'NRFONE': '(21) 99001-2345',
      'TXEMAI': 'pedidos@distrnorte.com.br',
      'TXENDE': 'Rua das Flores, 250 - Centro, Rio de Janeiro/RJ',
    });
    await db.insert('TMVOCLI', {
      'IDCLIE': 'cli-003',
      'NMCLIE': 'Supermercado Bom Preço',
      'CDDOCU': '45.678.901/0001-55',
      'NRFONE': '(31) 97654-3210',
      'TXEMAI': 'gerencia@bompreco.com.br',
      'TXENDE': 'Rua Tupinambás, 80 - Floresta, Belo Horizonte/MG',
    });

    // Produtos
    await db.insert('TMVOPROD', {
      'IDPROD': 'prod-001',
      'NMPROD': 'Arroz Tipo 1 Branco',
      'CDPROD': 'ARR-001',
      'VLPREC': 28.90,
      'CDUNID': 'SC',
    });
    await db.insert('TMVOPROD', {
      'IDPROD': 'prod-002',
      'NMPROD': 'Feijão Carioca',
      'CDPROD': 'FEI-001',
      'VLPREC': 12.50,
      'CDUNID': 'SC',
    });
    await db.insert('TMVOPROD', {
      'IDPROD': 'prod-003',
      'NMPROD': 'Óleo de Soja Refinado 900ml',
      'CDPROD': 'OLE-001',
      'VLPREC': 8.75,
      'CDUNID': 'UN',
    });
    await db.insert('TMVOPROD', {
      'IDPROD': 'prod-004',
      'NMPROD': 'Açúcar Cristal',
      'CDPROD': 'ACU-001',
      'VLPREC': 22.00,
      'CDUNID': 'SC',
    });
    await db.insert('TMVOPROD', {
      'IDPROD': 'prod-005',
      'NMPROD': 'Macarrão Espaguete 500g',
      'CDPROD': 'MAC-001',
      'VLPREC': 4.30,
      'CDUNID': 'CX',
    });

    // Condições de pagamento (espelham os IDs estáticos do OrderController)
    await db.insert('TMVOCNDPGTO', {
      'IDCPGT': 'pc1',
      'NMCPGT': 'À Vista',
      'NRPRAZ': 0,
      'PCTAXA': 0.0,
    });
    await db.insert('TMVOCNDPGTO', {
      'IDCPGT': 'pc2',
      'NMCPGT': '30 dias',
      'NRPRAZ': 30,
      'PCTAXA': 0.0,
    });
    await db.insert('TMVOCNDPGTO', {
      'IDCPGT': 'pc3',
      'NMCPGT': '2x sem juros',
      'NRPRAZ': 30,
      'PCTAXA': 0.0,
    });
    await db.insert('TMVOCNDPGTO', {
      'IDCPGT': 'pc4',
      'NMCPGT': '3x com juros (2%)',
      'NRPRAZ': 30,
      'PCTAXA': 2.0,
    });
    await db.insert('TMVOCNDPGTO', {
      'IDCPGT': 'pc5',
      'NMCPGT': '6x com juros (3,5%)',
      'NRPRAZ': 30,
      'PCTAXA': 3.5,
    });
    await db.insert('TMVOCNDPGTO', {
      'IDCPGT': 'pc6',
      'NMCPGT': '30/60/90 dias',
      'NRPRAZ': 30,
      'PCTAXA': 0.0,
    });

    // Pedido de exemplo
    final idPedi = await db.insert('TMVOCAB', {
      'DTCRIA': DateTime(2026, 4, 15, 9, 30).toIso8601String(),
      'IDCLIE': 'cli-001',
      'NMCLIE': 'Mercado Central Ltda',
      'IDCPGT': 'pc2',
      'NMCPGT': '30 dias',
      'PCDSCT': 5.0,
      'PCACRE': 0.0,
      'STPEDI': 'confirmed',
      'TXOBSE': 'Entrega na quinta-feira no período da manhã.',
    });

    // Itens do pedido
    await db.insert('TMVOITE', {
      'IDPEDI': idPedi,
      'IDPROD': 'prod-001',
      'NMPROD': 'Arroz Tipo 1 Branco',
      'CDPROD': 'ARR-001',
      'CDUNID': 'SC',
      'QTITEM': 10.0,
      'VLPREC': 28.90,
      'PCDSCT': 0.0,
    });
    await db.insert('TMVOITE', {
      'IDPEDI': idPedi,
      'IDPROD': 'prod-003',
      'NMPROD': 'Óleo de Soja Refinado 900ml',
      'CDPROD': 'OLE-001',
      'CDUNID': 'UN',
      'QTITEM': 24.0,
      'VLPREC': 8.75,
      'PCDSCT': 0.0,
    });
  }

  /// Cria todas as tabelas — exposto para ser reutilizado nos testes.
  static Future<void> applySchema(Database db) async {
    await db.execute('''
      CREATE TABLE TMVOCLI (
        IDCLIE  TEXT PRIMARY KEY,
        NMCLIE  TEXT NOT NULL,
        CDDOCU  TEXT,
        NRFONE  TEXT,
        TXEMAI  TEXT,
        TXENDE  TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TMVOPROD (
        IDPROD  TEXT PRIMARY KEY,
        NMPROD  TEXT NOT NULL,
        CDPROD  TEXT,
        VLPREC  REAL NOT NULL,
        CDUNID  TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE TMVOCNDPGTO (
        IDCPGT  TEXT PRIMARY KEY,
        NMCPGT  TEXT NOT NULL,
        NRPRAZ  INTEGER NOT NULL,
        PCTAXA  REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE TMVOCAB (
        IDPEDI  INTEGER PRIMARY KEY AUTOINCREMENT,
        DTCRIA  TEXT    NOT NULL,
        IDCLIE  TEXT    NOT NULL,
        NMCLIE  TEXT    NOT NULL,
        IDCPGT  TEXT    NOT NULL,
        NMCPGT  TEXT    NOT NULL,
        PCDSCT  REAL    NOT NULL DEFAULT 0,
        PCACRE  REAL    NOT NULL DEFAULT 0,
        STPEDI  TEXT    NOT NULL,
        TXOBSE  TEXT,
        FOREIGN KEY (IDCLIE) REFERENCES TMVOCLI(IDCLIE),
        FOREIGN KEY (IDCPGT) REFERENCES TMVOCNDPGTO(IDCPGT)
      )
    ''');

    await db.execute('''
      CREATE TABLE TMVOITE (
        IDITEM  INTEGER PRIMARY KEY AUTOINCREMENT,
        IDPEDI  INTEGER NOT NULL,
        IDPROD  TEXT    NOT NULL,
        NMPROD  TEXT    NOT NULL,
        CDPROD  TEXT,
        CDUNID  TEXT    NOT NULL,
        QTITEM  REAL    NOT NULL,
        VLPREC  REAL    NOT NULL,
        PCDSCT  REAL    NOT NULL DEFAULT 0,
        FOREIGN KEY (IDPEDI) REFERENCES TMVOCAB(IDPEDI) ON DELETE CASCADE,
        FOREIGN KEY (IDPROD) REFERENCES TMVOPROD(IDPROD)
      )
    ''');
  }
}
