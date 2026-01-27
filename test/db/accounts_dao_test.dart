import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/schema.dart';
import 'package:fintrack/data/db/daos/accounts_dao.dart';

void main() {
  late Database db;

  setUpAll(() async {
    sqfliteFfiInit();
    final factory = databaseFactoryFfi;
    db = await factory.openDatabase(inMemoryDatabasePath);
    for (final stmt in ddlV1) {
      final s = stmt.trim();
      if (s.isEmpty) continue;
      await db.execute(s);
    }
  });

  tearDownAll(() async {
    await db.close();
  });

  test('insert, query, update and delete account row', () async {
    final row = {
      'id': 'acct-1',
      'name': 'Cash',
      'color': '#ffffff',
      'icon': 'cash',
      'description': 'Test cash',
      'initial_balance_cents': 10000,
      'actual_balance_cents': 10000,
      'active': 1,
      'type_id': 't1',
      'created_at': null,
      'updated_at': null,
    };

    final insertedId = await insertAccountRow(db, row);
    expect(insertedId, greaterThan(0));

    final res = await queryAccountsRows(
      db,
      where: 'id = ?',
      whereArgs: ['acct-1'],
    );
    expect(res, isNotEmpty);
    expect(res.first['name'], 'Cash');

    final updated = await updateAccountRow(db, 'acct-1', {
      'name': 'Cash2',
      'updated_at': 'now',
    });
    expect(updated, equals(1));

    final res2 = await queryAccountsRows(
      db,
      where: 'id = ?',
      whereArgs: ['acct-1'],
    );
    expect(res2.first['name'], 'Cash2');

    final deleted = await deleteAccountRow(db, 'acct-1');
    expect(deleted, equals(1));

    final res3 = await queryAccountsRows(
      db,
      where: 'id = ?',
      whereArgs: ['acct-1'],
    );
    expect(res3, isEmpty);
  });
}
