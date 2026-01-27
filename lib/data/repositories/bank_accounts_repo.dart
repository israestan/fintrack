import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/bank_accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/domain/models/bank_account.dart';

class BankAccountsRepository {
  Future<void> createBankAccount(BankAccount ba) async {
    final db = await FinTrackDb.instance.db;
    final row = ba.toMap();
    final toInsert = withCreateTimestamps(row);
    await insertBankAccountRow(db, toInsert);
  }

  Future<BankAccount?> getByAccountId(String accountId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryBankAccountRows(
      db,
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return BankAccount.fromMap(rows.first);
  }

  Future<int> updateBankAccount(
    String accountId,
    Map<String, Object?> changes,
  ) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateBankAccountRow(db, accountId, updateRow);
  }

  Future<int> deleteBankAccount(String accountId) async {
    final db = await FinTrackDb.instance.db;
    return await deleteBankAccountRow(db, accountId);
  }
}
