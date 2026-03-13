import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/budget_dao.dart';
import 'package:fintrack/data/db/daos/budget_accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/domain/models/budget.dart';
import 'package:fintrack/domain/models/budget_account.dart';
import 'package:fintrack/domain/models/category.dart';

class BudgetsRepository {
  Future<Budget> createBudget(Budget b) async {
    final db = await FinTrackDb.instance.db;
    final id = b.id.isNotEmpty ? b.id : generateUuidV4();
    final row = b.toMap();
    row['id'] = id;
    final toInsert = withCreateTimestamps(row);
    await insertBudgetRow(db, toInsert);
    final res = await queryBudgetRows(
      db,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return Budget.fromMap(res.first);
  }

  Future<Budget?> getBudgetById(String id) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryBudgetRows(
      db,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Budget.fromMap(rows.first);
  }

  Future<int> updateBudget(String id, Map<String, Object?> changes) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateBudgetRow(db, id, updateRow);
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryBudgetRows(db, orderBy: 'created_at ASC');
    return rows.map(Budget.fromMap).toList();
  }

  Future<int> deleteBudget(String id) async {
    final db = await FinTrackDb.instance.db;
    return await deleteBudgetRow(db, id);
  }

  Future<void> addCategoryToBudget(String budgetId, String categoryId) async {
    final db = await FinTrackDb.instance.db;
    final bc = BudgetCategory(budgetId: budgetId, categoryId: categoryId);
    final row = withCreateTimestamps(bc.toMap());
    await insertBudgetCategoryRow(db, row);
  }

  Future<int> removeCategoryFromBudget(
    String budgetId,
    String categoryId,
  ) async {
    final db = await FinTrackDb.instance.db;
    return await deleteBudgetCategoryRow(db, budgetId, categoryId);
  }

  /// Devuelve las categorías vinculadas a un presupuesto.
  Future<List<Category>> getCategoriesForBudget(String budgetId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await db.rawQuery('''
      SELECT c.*
      FROM categories c
      INNER JOIN budget_categories bc ON bc.category_id = c.id
      WHERE bc.budget_id = ?
    ''', [budgetId]);
    return rows.map(Category.fromMap).toList();
  }

  /// Suma los gastos (OUTCOME) de las categorías vinculadas al presupuesto
  /// dentro de la ventana temporal del periodo actual.
  Future<int> getSpentForBudget(Budget budget) async {
    final db = await FinTrackDb.instance.db;
    final now = DateTime.now();
    final String periodStart;

    switch (budget.period) {
      case 'daily':
        periodStart = DateTime(now.year, now.month, now.day).toIso8601String();
      case 'weekly':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        periodStart =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
                .toIso8601String();
      case 'monthly':
        periodStart = DateTime(now.year, now.month, 1).toIso8601String();
      case 'yearly':
        periodStart = DateTime(now.year, 1, 1).toIso8601String();
      default:
        periodStart = DateTime(now.year, now.month, 1).toIso8601String();
    }

    final endDate = budget.targetDate ?? now.toIso8601String();

    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(m.amount_cents), 0) AS total
      FROM movements m
      INNER JOIN budget_categories bc ON bc.category_id = m.category_id
      WHERE bc.budget_id = ?
        AND m.type = 'OUTCOME'
        AND m.date >= ?
        AND m.date <= ?
    ''', [budget.id, periodStart, endDate]);

    return (result.first['total'] as int? ?? 0);
  }
}
