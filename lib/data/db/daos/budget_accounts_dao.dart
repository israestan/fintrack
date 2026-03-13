import 'package:sqflite_common/sqlite_api.dart';

const String _table = 'budget_categories';

Future<int> insertBudgetCategoryRow(
  DatabaseExecutor db,
  Map<String, Object?> row,
) async {
  return await db.insert(_table, row);
}

Future<List<Map<String, Object?>>> queryBudgetCategoryRows(
  DatabaseExecutor db, {
  String? where,
  List<Object?>? whereArgs,
  int? limit,
  int? offset,
  String? orderBy,
}) async {
  return await db.query(
    _table,
    where: where,
    whereArgs: whereArgs,
    limit: limit,
    offset: offset,
    orderBy: orderBy,
  );
}

Future<int> deleteBudgetCategoryRow(
  DatabaseExecutor db,
  String budgetId,
  String categoryId,
) async {
  return await db.delete(
    _table,
    where: 'budget_id = ? AND category_id = ?',
    whereArgs: [budgetId, categoryId],
  );
}
