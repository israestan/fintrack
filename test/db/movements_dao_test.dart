import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/schema.dart';
import 'package:fintrack/data/db/daos/movements_dao.dart';

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
    // insert minimal referenced rows for foreign keys
    await db.insert('account_types', {
      'id': 't1',
      'code': 'T1',
      'name': 'Type1',
    });
    await db.insert('accounts', {
      'id': 'acct-1',
      'name': 'A1',
      'color': '#fff',
      'icon': 'i',
      'description': null,
      'initial_balance_cents': 0,
      'actual_balance_cents': 0,
      'active': 1,
      'type_id': 't1',
    });
  });

  tearDownAll(() async {
    await db.close();
  });

  test('insert, query, update and delete movement row', () async {
    final row = {
      'id': 'mov-1',
      'type': 'INCOME',
      'icon': 'icon',
      'description': 'Test movement',
      'amount_cents': 2000,
      'date': '2025-12-28T00:00:00Z',
      'category_id': null,
      'account_id': 'acct-1',
      'created_at': null,
      'updated_at': null,
    };

    final inserted = await insertMovementRow(db, row);
    expect(inserted, greaterThan(0));

    final res = await queryMovementsRows(
      db,
      where: 'id = ?',
      whereArgs: ['mov-1'],
    );
    expect(res, isNotEmpty);
    expect(res.first['amount_cents'], 2000);

    final updated = await updateMovementRow(db, 'mov-1', {
      'description': 'Updated',
      'updated_at': 'now',
    });
    expect(updated, equals(1));

    final res2 = await queryMovementsRows(
      db,
      where: 'id = ?',
      whereArgs: ['mov-1'],
    );
    expect(res2.first['description'], 'Updated');

    final deleted = await deleteMovementRow(db, 'mov-1');
    expect(deleted, equals(1));

    final res3 = await queryMovementsRows(
      db,
      where: 'id = ?',
      whereArgs: ['mov-1'],
    );
    expect(res3, isEmpty);
  });
}
