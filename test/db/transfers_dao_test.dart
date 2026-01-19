import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fintrack/data/db/schema.dart';
import 'package:fintrack/data/db/daos/transfers_dao.dart';
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
    // required account data for movement FKs
    await db.insert('account_types', {'id': 't1', 'code': 'T1', 'name': 'Type1'});
    await db.insert('accounts', {
      'id': 'acct-A',
      'name': 'A',
      'color': '#000',
      'icon': 'i',
      'description': null,
      'initial_balance_cents': 10000,
      'actual_balance_cents': 10000,
      'active': 1,
      'type_id': 't1'
    });
    await db.insert('accounts', {
      'id': 'acct-B',
      'name': 'B',
      'color': '#000',
      'icon': 'i',
      'description': null,
      'initial_balance_cents': 5000,
      'actual_balance_cents': 5000,
      'active': 1,
      'type_id': 't1'
    });
  });

  tearDownAll(() async {
    await db.close();
  });

  test('insert and query transfer row referencing movements', () async {
    // insert two movements
    final movOut = {
      'id': 'm-out',
      'type': 'OUTCOME',
      'icon': 't',
      'description': 'out',
      'amount_cents': 1000,
      'date': '2025-12-28T00:00:00Z',
      'category_id': null,
      'account_id': 'acct-A',
      'created_at': null,
      'updated_at': null,
    };
    final movIn = {
      'id': 'm-in',
      'type': 'INCOME',
      'icon': 't',
      'description': 'in',
      'amount_cents': 1000,
      'date': '2025-12-28T00:00:00Z',
      'category_id': null,
      'account_id': 'acct-B',
      'created_at': null,
      'updated_at': null,
    };

    await insertMovementRow(db, movOut);
    await insertMovementRow(db, movIn);

    final transferRow = {
      'id': 'tr-1',
      'income_movement_id': 'm-in',
      'outcome_movement_id': 'm-out',
      'created_at': null,
      'updated_at': null,
    };

    final inserted = await insertTransferRow(db, transferRow);
    expect(inserted, greaterThan(0));

    final res = await queryTransfersRows(db, where: 'id = ?', whereArgs: ['tr-1']);
    expect(res, isNotEmpty);
    expect(res.first['income_movement_id'], 'm-in');

    final deleted = await deleteTransferRow(db, 'tr-1');
    expect(deleted, equals(1));
    final after = await queryTransfersRows(db, where: 'id = ?', whereArgs: ['tr-1']);
    expect(after, isEmpty);
  });
}
