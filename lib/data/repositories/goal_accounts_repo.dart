import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/goal_accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/domain/models/goal_account.dart';

class GoalAccountsRepository {
  Future<void> createGoalAccount(GoalAccount ga) async {
    final db = await FinTrackDb.instance.db;
    final row = ga.toMap();
    final toInsert = withCreateTimestamps(row);
    await insertGoalAccountRow(db, toInsert);
  }

  Future<GoalAccount?> getByAccountId(String accountId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryGoalAccountRows(
      db,
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return GoalAccount.fromMap(rows.first);
  }

  Future<int> updateGoalAccount(
    String accountId,
    Map<String, Object?> changes,
  ) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateGoalAccountRow(db, accountId, updateRow);
  }

  Future<int> deleteGoalAccount(String accountId) async {
    final db = await FinTrackDb.instance.db;
    return await deleteGoalAccountRow(db, accountId);
  }
}
