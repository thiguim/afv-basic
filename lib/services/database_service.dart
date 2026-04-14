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

  Future<void> _onCreate(Database db, int version) => applySchema(db);

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
