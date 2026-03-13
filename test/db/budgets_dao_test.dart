import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/schema.dart';
import 'package:fintrack/data/db/daos/budget_dao.dart';
import 'package:fintrack/data/db/daos/budget_accounts_dao.dart';

void main() {
  late Database db;

  setUpAll(() async {
    sqfliteFfiInit();
    final factory = databaseFactoryFfi;
    db = await factory.openDatabase(inMemoryDatabasePath);
    for (final stmt in ddlV1) {
      final s = stmt.trim();
      if (s.isEmpty) continue;
      await db.execute(s);
    }
    // prepare a category for budget_categories FK
    await db.insert('categories', {
      'id': 'cat-b',
      'parent_id': null,
      'icon': 'i',
      'color': '#000',
      'name': 'CatB',
      'description': 'desc',
      'type': 'OUTCOME',
    });
  });

  tearDownAll(() async {
    await db.close();
  });

  test('insert, query, update and delete budget row', () async {
    final row = {
      'id': 'bud-1',
      'entity': 'House',
      'period': 'monthly',
      'target_date': null,
      'limit_cents': 100000,
      'created_at': null,
      'updated_at': null,
    };

    final inserted = await insertBudgetRow(db, row);
    expect(inserted, greaterThan(0));

    final res = await queryBudgetRows(
      db,
      where: 'id = ?',
      whereArgs: ['bud-1'],
    );
    expect(res, isNotEmpty);

    final updated = await updateBudgetRow(db, 'bud-1', {
      'limit_cents': 90000,
      'updated_at': 'now',
    });
    expect(updated, equals(1));

    final res2 = await queryBudgetRows(
      db,
      where: 'id = ?',
      whereArgs: ['bud-1'],
    );
    expect(res2.first['limit_cents'], 90000);

    // add category to budget
    final bc = {
      'budget_id': 'bud-1',
      'category_id': 'cat-b',
      'created_at': null,
      'updated_at': null,
    };
    final insertedBc = await insertBudgetCategoryRow(db, bc);
    expect(insertedBc, greaterThan(0));

    final bcRows = await queryBudgetCategoryRows(
      db,
      where: 'budget_id = ?',
      whereArgs: ['bud-1'],
    );
    expect(bcRows.length, 1);

    // deleting budget should cascade to budget_categories
    final deleted = await deleteBudgetRow(db, 'bud-1');
    expect(deleted, equals(1));

    final bcAfter = await queryBudgetCategoryRows(
      db,
      where: 'budget_id = ?',
      whereArgs: ['bud-1'],
    );
    expect(bcAfter, isEmpty);
  });
}
