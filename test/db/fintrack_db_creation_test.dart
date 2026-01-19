import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/schema.dart';

void main() {
  test('create schema v1 in memory and check tables and foreign_keys pragma', () async {
    // Init ffi
    sqfliteFfiInit();

    final databaseFactory = databaseFactoryFfi;

    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    try {
      // Ensure foreign_keys pragma is enabled (mimic onConfigure behavior)
      await db.execute('PRAGMA foreign_keys = ON');

      // Execute DDL inside a transaction, skipping PRAGMA statements
      await db.transaction((txn) async {
        for (final stmt in ddlV1) {
          final s = stmt.trim();
          if (s.isEmpty) continue;
          final up = s.toUpperCase();
          if (up.startsWith('PRAGMA')) continue;
          await txn.execute(s);
        }
      });

      // Check PRAGMA foreign_keys = ON
      final fkResult = await db.rawQuery('PRAGMA foreign_keys');
      expect(fkResult, isNotEmpty);
      final fkValue = fkResult.first.values.first as int;
      expect(fkValue, 1);

      // Check that 'accounts' table exists
      final tbl = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='accounts';");
      expect(tbl, isNotEmpty);

      // Check that movements indexes exist
      final idx = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='index' AND name='idx_movements_account_date';");
      expect(idx, isNotEmpty);
    } finally {
      await db.close();
    }
  });
}
