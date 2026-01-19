import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/repositories/movements_repo.dart';
import 'package:fintrack/domain/models/movement.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await FinTrackDb.instance.init(dbName: 'test_fintrack.db');
  });

  tearDownAll(() async {
    await FinTrackDb.instance.close();
  });

  test('createMovement, listByAccountAndDateRange and sumAmounts', () async {
    final repo = MovementsRepository();

    // create account row required by FK
    final db = await FinTrackDb.instance.db;
    await db.insert('account_types', {'id': 't1', 'code': 'T1', 'name': 'Type1'});
    await db.insert('accounts', {
      'id': 'acct-1',
      'name': 'A1',
      'color': '#fff',
      'icon': 'i',
      'description': null,
      'initial_balance_cents': 0,
      'actual_balance_cents': 0,
      'active': 1,
      'type_id': 't1'
    });

    final m1 = Movement(
      id: '',
      type: 'INCOME',
      icon: 'i',
      description: 'm1',
      amountCents: 1000,
      date: '2025-12-01T00:00:00Z',
      categoryId: null,
      accountId: 'acct-1',
    );

    final m2 = Movement(
      id: '',
      type: 'OUTCOME',
      icon: 'i',
      description: 'm2',
      amountCents: 500,
      date: '2025-12-15T00:00:00Z',
      categoryId: null,
      accountId: 'acct-1',
    );

    final id1 = await repo.createMovement(m1);
    final id2 = await repo.createMovement(m2);
    expect(id1, isNotEmpty);
    expect(id2, isNotEmpty);

    final list = await repo.listByAccountAndDateRange(
      accountId: 'acct-1',
      dateFromIso: '2025-12-01T00:00:00Z',
      dateToIso: '2025-12-31T23:59:59Z',
    );
    expect(list.length, 2);

    final total = await repo.sumAmounts(accountId: 'acct-1');
    expect(total, 1500);

    // constraint test: negative amount should fail at DB level
    final bad = Movement(
      id: '',
      type: 'OUTCOME',
      icon: 'i',
      description: 'bad',
      amountCents: -100,
      date: '2025-12-10T00:00:00Z',
      categoryId: null,
      accountId: 'acct-1',
    );

    try {
      await repo.createMovement(bad);
      fail('Negative amount should have thrown');
    } catch (e) {
      expect(e, isNotNull);
    }
  });
}
