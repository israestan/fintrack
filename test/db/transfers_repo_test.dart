import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/movements_dao.dart';
import 'package:fintrack/data/db/daos/transfers_dao.dart';
import 'package:fintrack/data/repositories/transfers_repo.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await FinTrackDb.instance.init(dbName: 'test_fintrack.db');
  });

  tearDownAll(() async {
    await FinTrackDb.instance.close();
  });

  test('createTransfer updates balances and inserts movements + transfer', () async {
    final db = await FinTrackDb.instance.db;
    // prepare accounts (use OR IGNORE to avoid duplicate insertions across tests)
    await db.rawInsert(
      'INSERT OR IGNORE INTO account_types (id, code, name) VALUES (?, ?, ?)',
      ['t1', 'T1', 'Type1'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['from-1', 'From', '#000', 'i', null, 2000, 2000, 1, 't1'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['to-1', 'To', '#000', 'i', null, 500, 500, 1, 't1'],
    );

    final repo = TransfersRepository();
    final transferId = await repo.createTransfer(
      fromAccountId: 'from-1',
      toAccountId: 'to-1',
      amountCents: 500,
      description: 'test transfer',
    );

    // verify transfer row
    final trs = await queryTransfersRows(
      db,
      where: 'id = ?',
      whereArgs: [transferId],
    );
    expect(trs.length, 1);
    final incomeId = trs.first['income_movement_id'] as String;
    final outcomeId = trs.first['outcome_movement_id'] as String;

    // verify movements exist
    final movIn = await queryMovementsRows(
      db,
      where: 'id = ?',
      whereArgs: [incomeId],
      limit: 1,
    );
    final movOut = await queryMovementsRows(
      db,
      where: 'id = ?',
      whereArgs: [outcomeId],
      limit: 1,
    );
    expect(movIn.length, 1);
    expect(movOut.length, 1);

    // verify balances updated
    final fromRow = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: ['from-1'],
      limit: 1,
    );
    final toRow = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: ['to-1'],
      limit: 1,
    );
    expect(fromRow.first['actual_balance_cents'], 1500);
    expect(toRow.first['actual_balance_cents'], 1000);
  });

  test('createTransfer rollback on missing destination account', () async {
    final db = await FinTrackDb.instance.db;
    // prepare only source account (use OR IGNORE)
    await db.rawInsert(
      'INSERT OR IGNORE INTO account_types (id, code, name) VALUES (?, ?, ?)',
      ['t2', 'T2', 'Type2'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['from-2', 'From2', '#000', 'i', null, 1000, 1000, 1, 't2'],
    );

    final repo = TransfersRepository();

    try {
      await repo.createTransfer(
        fromAccountId: 'from-2',
        toAccountId: 'missing-account',
        amountCents: 100,
        description: 'should rollback',
      );
      fail('Expected exception due to missing destination account');
    } catch (e) {
      // expected
    }

    // ensure no partial movements or transfers were inserted for from-2
    final moves = await queryMovementsRows(
      await FinTrackDb.instance.db,
      where: 'account_id = ?',
      whereArgs: ['from-2'],
    );
    expect(moves, isEmpty);
    final transfers = await queryTransfersRows(await FinTrackDb.instance.db);
    // There may be existing transfers from previous tests; ensure none reference movements for from-2
    // Collect any transfers that reference any movement id present in `moves` and assert the list is empty
    final referenced = transfers.where((t) {
      final inc = t['income_movement_id'] as String?;
      final out = t['outcome_movement_id'] as String?;
      return moves.any((m) => m['id'] == inc || m['id'] == out);
    }).toList();
    expect(referenced, isEmpty);
  });
}
