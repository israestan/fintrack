import 'package:sqflite_common/sqlite_api.dart';

const String _table = 'movements';

Future<int> insertMovementRow(
  DatabaseExecutor db,
  Map<String, Object?> row,
) async {
  return await db.insert(_table, row);
}

Future<List<Map<String, Object?>>> queryMovementsRows(
  DatabaseExecutor db, {
  String? where,
  List<Object?>? whereArgs,
  String? orderBy,
  int? limit,
  int? offset,
}) async {
  return await db.query(
    _table,
    where: where,
    whereArgs: whereArgs,
    orderBy: orderBy,
    limit: limit,
    offset: offset,
  );
}

Future<int> updateMovementRow(
  DatabaseExecutor db,
  String id,
  Map<String, Object?> row,
) async {
  return await db.update(_table, row, where: 'id = ?', whereArgs: [id]);
}

Future<int> deleteMovementRow(DatabaseExecutor db, String id) async {
  return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
}
