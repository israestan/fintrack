import 'package:sqflite_common/sqlite_api.dart';

const String _table = 'categories';

Future<int> insertCategoryRow(DatabaseExecutor db, Map<String, Object?> row) async {
  return await db.insert(_table, row);
}

Future<List<Map<String, Object?>>> queryCategoriesRows(
  DatabaseExecutor db, {
  String? where,
  List<Object?>? whereArgs,
  String? orderBy,
}) async {
  return await db.query(
    _table,
    where: where,
    whereArgs: whereArgs,
    orderBy: orderBy,
  );
}

Future<int> updateCategoryRow(DatabaseExecutor db, String id, Map<String, Object?> row) async {
  return await db.update(_table, row, where: 'id = ?', whereArgs: [id]);
}

Future<int> deleteCategoryRow(DatabaseExecutor db, String id) async {
  return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
}
