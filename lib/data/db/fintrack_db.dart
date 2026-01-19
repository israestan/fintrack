import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

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
      version: 1,
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
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Placeholder for future migrations.
        // Implement migrations here when schema version increases.
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
