import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/debt_accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/domain/models/debt_account.dart';

class DebtAccountsRepository {
  Future<void> createDebtAccount(DebtAccount da) async {
    final db = await FinTrackDb.instance.db;
    final row = da.toMap();
    final toInsert = withCreateTimestamps(row);
    await insertDebtAccountRow(db, toInsert);
  }

  Future<DebtAccount?> getByAccountId(String accountId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryDebtAccountRows(
      db,
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DebtAccount.fromMap(rows.first);
  }

  Future<int> updateDebtAccount(
    String accountId,
    Map<String, Object?> changes,
  ) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateDebtAccountRow(db, accountId, updateRow);
  }

  Future<int> deleteDebtAccount(String accountId) async {
    final db = await FinTrackDb.instance.db;
    return await deleteDebtAccountRow(db, accountId);
  }
}
