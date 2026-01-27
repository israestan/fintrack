import 'package:sqflite_common/sqlite_api.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/movements_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/domain/models/movement.dart';

class MovementsRepository {
  /// Create a movement. If [txn] is provided the insertion will use it (for transactions).
  Future<String> createMovement(
    Movement movement, {
    DatabaseExecutor? txn,
  }) async {
    final db = txn ?? await FinTrackDb.instance.db;
    final id = movement.id.isNotEmpty ? movement.id : generateUuidV4();
    final row = movement.toMap()..['id'] = id;
    final toInsert = withCreateTimestamps(row);
    await insertMovementRow(db, toInsert);
    return id;
  }

  Future<Movement?> getMovementById(String id) async {
    final db = await FinTrackDb.instance.db;
    final res = await queryMovementsRows(
      db,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return Movement.fromMap(res.first);
  }

  Future<List<Movement>> listByAccountAndDateRange({
    required String accountId,
    required String dateFromIso,
    required String dateToIso,
    int? limit,
    int? offset,
  }) async {
    final db = await FinTrackDb.instance.db;
    final where = 'account_id = ? AND date BETWEEN ? AND ?';
    final rows = await queryMovementsRows(
      db,
      where: where,
      whereArgs: [accountId, dateFromIso, dateToIso],
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((r) => Movement.fromMap(r)).toList();
  }

  /// Sum amounts (in cents) grouped by optional filters. Returns 0 if no rows.
  Future<int> sumAmounts({
    String? type,
    String? categoryId,
    String? accountId,
    String? dateFromIso,
    String? dateToIso,
  }) async {
    final db = await FinTrackDb.instance.db;
    final whereParts = <String>[];
    final args = <Object?>[];
    if (type != null) {
      whereParts.add('type = ?');
      args.add(type);
    }
    if (categoryId != null) {
      whereParts.add('category_id = ?');
      args.add(categoryId);
    }
    if (accountId != null) {
      whereParts.add('account_id = ?');
      args.add(accountId);
    }
    if (dateFromIso != null && dateToIso != null) {
      whereParts.add('date BETWEEN ? AND ?');
      args.addAll([dateFromIso, dateToIso]);
    }

    final where = whereParts.isEmpty ? '' : 'WHERE ${whereParts.join(' AND ')}';
    final sql =
        'SELECT COALESCE(SUM(amount_cents), 0) as total FROM movements $where';
    final res = await db.rawQuery(sql, args);
    if (res.isEmpty) return 0;
    final v = res.first['total'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  Future<int> updateMovement(String id, Map<String, Object?> changes) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateMovementRow(db, id, updateRow);
  }

  Future<int> deleteMovement(String id) async {
    final db = await FinTrackDb.instance.db;
    return await deleteMovementRow(db, id);
  }
}
