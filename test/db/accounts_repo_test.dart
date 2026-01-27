import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/schema.dart';
import 'package:fintrack/data/repositories/accounts_repo.dart';
import 'package:fintrack/domain/models/account.dart';
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

  test(
    'createAccountInTransaction inserts and returns id; timestamps applied',
    () async {
      final repo = AccountsRepository();
      final acct = Account(
        id: '',
        name: 'Wallet',
        color: '#000000',
        icon: 'wallet',
        description: 'Test wallet',
        initialBalanceCents: 5000,
        actualBalanceCents: 5000,
        active: 1,
        typeId: 't1',
      );

      await db.transaction((txn) async {
        final id = await repo.createAccountInTransaction(txn, acct);
        expect(id, isNotEmpty);
      });

      final rows = await queryAccountsRows(
        db,
        where: 'name = ?',
        whereArgs: ['Wallet'],
      );
      expect(rows.length, 1);
      expect(rows.first['created_at'], isNotNull);
    },
  );
}
