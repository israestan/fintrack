import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'migrations/migration_v2_20260311.dart';
import 'schema.dart';

class FinTrackDb {
  FinTrackDb._privateConstructor();

  static final FinTrackDb instance = FinTrackDb._privateConstructor();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    return await init();
  }

  Future<Database> init({String dbName = 'fintrack.db'}) async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, dbName);

    _db = await openDatabase(
      path,
      version: 2,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (Database db, int version) async {
        // Execute all DDL statements defined in schema.dart
        for (final stmt in ddlV1) {
          // Trim and skip empty statements
          final s = stmt.trim();
          if (s.isEmpty) continue;
          await db.execute(s);
        }

        final batch = db.batch();

        batch.insert('account_types', {
          'id': 'type_general',
          'code': 'GENERAL',
          'name': 'General',
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        final types = [
          ('CASH', 'CASH', 'Efectivo'),
          ('CREDIT_CARD', 'CREDIT_CARD', 'Tarjeta de Crédito'),
          ('SAVINGS_ACCOUNT', 'SAVINGS_ACCOUNT', 'Cuenta de Ahorros'),
          ('CURRENT_ACCOUNT', 'CURRENT_ACCOUNT', 'Cuenta Corriente'),
          ('GOAL', 'GOAL', 'Meta'),
          ('DEBT', 'DEBT', 'Deuda'),
          ('LOAN', 'LOAN', 'Préstamo'),
          ('BUDGET', 'BUDGET', 'Presupuesto'),
        ];

        for (final t in types) {
          batch.insert('account_types', {
            'id': t.$1,
            'code': t.$2,
            'name': t.$3,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        await batch.commit(noResult: true);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) await migrateV1toV2(db);
      },
    );

    return _db!;
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
