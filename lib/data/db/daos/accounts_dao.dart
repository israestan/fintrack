import 'package:sqflite_common/sqlite_api.dart';

const String _table = 'accounts';

Future<int> insertAccountRow(DatabaseExecutor db, Map<String, Object?> row) async {
  return await db.insert(_table, row);
}

Future<List<Map<String, Object?>>> queryAccountsRows(
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

Future<int> updateAccountRow(DatabaseExecutor db, String id, Map<String, Object?> row) async {
  return await db.update(_table, row, where: 'id = ?', whereArgs: [id]);
}

Future<int> deleteAccountRow(DatabaseExecutor db, String id) async {
  return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
}
