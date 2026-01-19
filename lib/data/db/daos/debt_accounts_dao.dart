import 'package:sqflite_common/sqlite_api.dart';

const String _table = 'debt_accounts';

Future<int> insertDebtAccountRow(DatabaseExecutor db, Map<String, Object?> row) async {
  return await db.insert(_table, row);
}

Future<List<Map<String, Object?>>> queryDebtAccountRows(
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

Future<int> updateDebtAccountRow(DatabaseExecutor db, String accountId, Map<String, Object?> row) async {
  return await db.update(_table, row, where: 'account_id = ?', whereArgs: [accountId]);
}

Future<int> deleteDebtAccountRow(DatabaseExecutor db, String accountId) async {
  return await db.delete(_table, where: 'account_id = ?', whereArgs: [accountId]);
}
