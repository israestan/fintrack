import 'package:sqflite_common/sqlite_api.dart';

const String _table = 'transfers';

Future<int> insertTransferRow(
  DatabaseExecutor db,
  Map<String, Object?> row,
) async {
  return await db.insert(_table, row);
}

Future<List<Map<String, Object?>>> queryTransfersRows(
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

Future<int> deleteTransferRow(DatabaseExecutor db, String id) async {
  return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
}
