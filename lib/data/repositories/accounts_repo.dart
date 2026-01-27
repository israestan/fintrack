import 'package:sqflite_common/sqlite_api.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/domain/models/account.dart';

class AccountsRepository {
  Future<Account> createAccount(Account account) async {
    final db = await FinTrackDb.instance.db;
    final id = account.id.isNotEmpty ? account.id : generateUuidV4();
    final row = account.toMap();
    row['id'] = id;
    final toInsert = withCreateTimestamps(row);
    await insertAccountRow(db, toInsert);
    final inserted = await getAccountById(id);
    return inserted!;
  }

  Future<Account?> getAccountById(String id) async {
    final db = await FinTrackDb.instance.db;
    final res = await queryAccountsRows(
      db,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return Account.fromMap(res.first);
  }

  Future<List<Account>> listAccounts({bool onlyActive = true}) async {
    final db = await FinTrackDb.instance.db;
    final where = onlyActive ? 'active = 1' : null;
    final rows = await queryAccountsRows(db, where: where);
    return rows.map((r) => Account.fromMap(r)).toList();
  }

  Future<int> updateAccount(String id, Map<String, Object?> changes) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateAccountRow(db, id, updateRow);
  }

  Future<int> softDeleteAccount(String id) async {
    return await updateAccount(id, {'active': 0});
  }

  // Low-level helper to allow transactional usage in services/tests
  Future<String> createAccountInTransaction(
    DatabaseExecutor txn,
    Account account,
  ) async {
    final id = account.id.isNotEmpty ? account.id : generateUuidV4();
    final row = account.toMap();
    row['id'] = id;
    final toInsert = withCreateTimestamps(row);
    await insertAccountRow(txn, toInsert);
    return id;
  }
}
