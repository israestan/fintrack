import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/data/repositories/budgets_repo.dart';
import 'package:fintrack/domain/models/budget.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await FinTrackDb.instance.init(dbName: 'test_fintrack.db');
  });

  tearDownAll(() async {
    await FinTrackDb.instance.close();
  });

  test('createBudget, addAccountToBudget and removeAccountFromBudget', () async {
    final db = await FinTrackDb.instance.db;
    // prepare account
    await db.rawInsert(
      'INSERT OR IGNORE INTO account_types (id, code, name) VALUES (?, ?, ?)',
      ['t-b', 'TB', 'TypeB'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['acct-b2', 'AcctB2', '#000', 'i', null, 0, 0, 1, 't-b'],
    );

    final repo = BudgetsRepository();
    final id = generateUuidV4();
    final b = Budget(
      id: id,
      entity: 'Food',
      period: 'monthly',
      targetDate: null,
      limitCents: 50000,
    );
    final created = await repo.createBudget(b);
    expect(created.id, id);

    // add account
    await repo.addAccountToBudget(id, 'acct-b2');
    final rows = await db.query(
      'budget_accounts',
      where: 'budget_id = ?',
      whereArgs: [id],
    );
    expect(rows.length, 1);

    // duplicate add should fail (PK)
    try {
      await repo.addAccountToBudget(id, 'acct-b2');
      fail('Expected duplicate insert to throw');
    } catch (e) {
      expect(e, isNotNull);
    }

    final removed = await repo.removeAccountFromBudget(id, 'acct-b2');
    expect(removed, 1);
  });
}
