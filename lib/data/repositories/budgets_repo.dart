
import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/budget_dao.dart';
import 'package:fintrack/data/db/daos/budget_accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/domain/models/budget.dart';
import 'package:fintrack/domain/models/budget_account.dart';

class BudgetsRepository {
  Future<Budget> createBudget(Budget b) async {
    final db = await FinTrackDb.instance.db;
    final id = b.id.isNotEmpty ? b.id : generateUuidV4();
    final row = b.toMap();
    row['id'] = id;
    final toInsert = withCreateTimestamps(row);
    await insertBudgetRow(db, toInsert);
    final res = await queryBudgetRows(db, where: 'id = ?', whereArgs: [id], limit: 1);
    return Budget.fromMap(res.first);
  }

  Future<Budget?> getBudgetById(String id) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryBudgetRows(db, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Budget.fromMap(rows.first);
  }

  Future<int> updateBudget(String id, Map<String, Object?> changes) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateBudgetRow(db, id, updateRow);
  }

  Future<int> deleteBudget(String id) async {
    final db = await FinTrackDb.instance.db;
    return await deleteBudgetRow(db, id);
  }

  Future<void> addAccountToBudget(String budgetId, String accountId) async {
    final db = await FinTrackDb.instance.db;
    final ba = BudgetAccount(accountId: accountId, budgetId: budgetId);
    final row = withCreateTimestamps(ba.toMap());
    await insertBudgetAccountRow(db, row);
  }

  Future<int> removeAccountFromBudget(String budgetId, String accountId) async {
    final db = await FinTrackDb.instance.db;
    return await deleteBudgetAccountRow(db, accountId, budgetId);
  }
}
