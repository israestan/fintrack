import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/goal_accounts_dao.dart';
import 'package:fintrack/data/db/daos/accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/domain/models/account.dart';
import 'package:fintrack/domain/models/goal_account.dart';
import 'package:fintrack/domain/models/goal_entry.dart';

class GoalAccountsRepository {
  Future<void> createGoalAccount(GoalAccount ga) async {
    final db = await FinTrackDb.instance.db;
    final row = ga.toMap();
    final toInsert = withCreateTimestamps(row);
    await insertGoalAccountRow(db, toInsert);
  }

  Future<GoalAccount?> getByAccountId(String accountId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryGoalAccountRows(
      db,
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return GoalAccount.fromMap(rows.first);
  }

  Future<int> updateGoalAccount(
    String accountId,
    Map<String, Object?> changes,
  ) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateGoalAccountRow(db, accountId, updateRow);
  }

  Future<int> deleteGoalAccount(String accountId) async {
    final db = await FinTrackDb.instance.db;
    return await deleteGoalAccountRow(db, accountId);
  }

  /// Devuelve todas las metas activas con sus datos de cuenta asociados.
  Future<List<GoalEntry>> getAllGoals() async {
    final db = await FinTrackDb.instance.db;
    final rows = await db.rawQuery('''
      SELECT
        a.id               AS a_id,
        a.name             AS a_name,
        a.color            AS a_color,
        a.icon             AS a_icon,
        a.description      AS a_description,
        a.initial_balance_cents  AS a_initial_balance_cents,
        a.actual_balance_cents   AS a_actual_balance_cents,
        a.active           AS a_active,
        a.type_id          AS a_type_id,
        a.created_at       AS a_created_at,
        a.updated_at       AS a_updated_at,
        ga.objective,
        ga.target_amount_cents,
        ga.target_date,
        ga.created_at      AS ga_created_at,
        ga.updated_at      AS ga_updated_at
      FROM goal_accounts ga
      INNER JOIN accounts a ON a.id = ga.account_id
      WHERE a.active = 1
      ORDER BY ga.created_at ASC
    ''');

    return rows.map((r) {
      final account = Account.fromMap({
        'id': r['a_id'],
        'name': r['a_name'],
        'color': r['a_color'],
        'icon': r['a_icon'],
        'description': r['a_description'],
        'initial_balance_cents': r['a_initial_balance_cents'],
        'actual_balance_cents': r['a_actual_balance_cents'],
        'active': r['a_active'],
        'type_id': r['a_type_id'],
        'created_at': r['a_created_at'],
        'updated_at': r['a_updated_at'],
      });
      final goal = GoalAccount.fromMap({
        'account_id': r['a_id'],
        'objective': r['objective'],
        'target_amount_cents': r['target_amount_cents'],
        'target_date': r['target_date'],
        'created_at': r['ga_created_at'],
        'updated_at': r['ga_updated_at'],
      });
      return GoalEntry(account: account, goal: goal);
    }).toList();
  }

  /// Crea la account (tipo GOAL) y el goal_account en una sola transacción.
  Future<String> createGoalWithAccount(
    Account account,
    GoalAccount goalAccount,
  ) async {
    final db = await FinTrackDb.instance.db;
    final id = account.id.isNotEmpty ? account.id : generateUuidV4();
    await db.transaction((txn) async {
      final accountRow = account.toMap();
      accountRow['id'] = id;
      await insertAccountRow(txn, withCreateTimestamps(accountRow));

      final gaRow = goalAccount.toMap();
      gaRow['account_id'] = id;
      await insertGoalAccountRow(txn, withCreateTimestamps(gaRow));
    });
    return id;
  }
}
