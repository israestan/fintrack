import 'package:sqflite_common/sqlite_api.dart';

const String _table = 'budget_accounts';

Future<int> insertBudgetAccountRow(
  DatabaseExecutor db,
  Map<String, Object?> row,
) async {
  return await db.insert(_table, row);
}

Future<List<Map<String, Object?>>> queryBudgetAccountRows(
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

Future<int> deleteBudgetAccountRow(
  DatabaseExecutor db,
  String accountId,
  String budgetId,
) async {
  return await db.delete(
    _table,
    where: 'account_id = ? AND budget_id = ?',
    whereArgs: [accountId, budgetId],
  );
}
