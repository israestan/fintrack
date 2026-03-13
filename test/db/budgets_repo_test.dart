import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/data/repositories/budgets_repo.dart';
import 'package:fintrack/domain/models/budget.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await FinTrackDb.instance.init(dbName: 'test_fintrack.db');
  });

  tearDownAll(() async {
    await FinTrackDb.instance.close();
  });

  test('createBudget, addCategoryToBudget and removeCategoryFromBudget', () async {
    final db = await FinTrackDb.instance.db;
    // prepare category
    await db.rawInsert(
      'INSERT OR IGNORE INTO categories (id, parent_id, icon, color, name, description, type) VALUES (?, ?, ?, ?, ?, ?, ?)',
      ['cat-b2', null, 'i', '#000', 'CatB2', 'desc', 'OUTCOME'],
    );

    final repo = BudgetsRepository();
    final id = generateUuidV4();
    final b = Budget(
      id: id,
      entity: 'Food',
      period: 'monthly',
      targetDate: null,
      limitCents: 50000,
    );
    final created = await repo.createBudget(b);
    expect(created.id, id);

    // add category
    await repo.addCategoryToBudget(id, 'cat-b2');
    final rows = await db.query(
      'budget_categories',
      where: 'budget_id = ?',
      whereArgs: [id],
    );
    expect(rows.length, 1);

    // duplicate add should fail (PK)
    try {
      await repo.addCategoryToBudget(id, 'cat-b2');
      fail('Expected duplicate insert to throw');
    } catch (e) {
      expect(e, isNotNull);
    }

    final removed = await repo.removeCategoryFromBudget(id, 'cat-b2');
    expect(removed, 1);
  });
}
