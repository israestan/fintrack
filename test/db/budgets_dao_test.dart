import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/schema.dart';
import 'package:fintrack/data/db/daos/budget_dao.dart';
import 'package:fintrack/data/db/daos/budget_accounts_dao.dart';

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
    // prepare an account for budget_accounts FK
    await db.insert('account_types', {'id': 't1', 'code': 'T1', 'name': 'Type1'});
    await db.insert('accounts', {
      'id': 'acct-b',
      'name': 'AcctB',
      'color': '#000',
      'icon': 'i',
      'description': null,
      'initial_balance_cents': 0,
      'actual_balance_cents': 0,
      'active': 1,
      'type_id': 't1'
    });
  });

  tearDownAll(() async {
    await db.close();
  });

  test('insert, query, update and delete budget row', () async {
    final row = {
      'id': 'bud-1',
      'entity': 'House',
      'period': 'monthly',
      'target_date': null,
      'limit_cents': 100000,
      'created_at': null,
      'updated_at': null,
    };

    final inserted = await insertBudgetRow(db, row);
    expect(inserted, greaterThan(0));

    final res = await queryBudgetRows(db, where: 'id = ?', whereArgs: ['bud-1']);
    expect(res, isNotEmpty);

    final updated = await updateBudgetRow(db, 'bud-1', {'limit_cents': 90000, 'updated_at': 'now'});
    expect(updated, equals(1));

    final res2 = await queryBudgetRows(db, where: 'id = ?', whereArgs: ['bud-1']);
    expect(res2.first['limit_cents'], 90000);

    // add account to budget
    final ba = {'account_id': 'acct-b', 'budget_id': 'bud-1', 'created_at': null, 'updated_at': null};
    final insertedBa = await insertBudgetAccountRow(db, ba);
    expect(insertedBa, greaterThan(0));

    final baRows = await queryBudgetAccountRows(db, where: 'budget_id = ?', whereArgs: ['bud-1']);
    expect(baRows.length, 1);

    // deleting budget should cascade to budget_accounts
    final deleted = await deleteBudgetRow(db, 'bud-1');
    expect(deleted, equals(1));

    final baAfter = await queryBudgetAccountRows(db, where: 'budget_id = ?', whereArgs: ['bud-1']);
    expect(baAfter, isEmpty);
  });
}
