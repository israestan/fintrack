import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/schema.dart';
import 'package:fintrack/data/db/daos/categories_dao.dart';

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
  });

  tearDownAll(() async {
    await db.close();
  });

  test('insert, listByType, children and delete category rows', () async {
    // Insert root category
    final root = {
      'id': 'cat-root',
      'parent_id': null,
      'icon': 'root_icon',
      'color': '#111111',
      'name': 'Root',
      'description': 'Root category',
      'type': 'OUTCOME',
      'created_at': null,
      'updated_at': null,
    };
    await insertCategoryRow(db, root);

    // Insert child
    final child = {
      'id': 'cat-child',
      'parent_id': 'cat-root',
      'icon': 'child_icon',
      'color': '#222222',
      'name': 'Child',
      'description': 'Child category',
      'type': 'OUTCOME',
      'created_at': null,
      'updated_at': null,
    };
    await insertCategoryRow(db, child);

    // listByType
    final outcomes = await queryCategoriesRows(
      db,
      where: 'type = ?',
      whereArgs: ['OUTCOME'],
    );
    expect(outcomes.length, greaterThanOrEqualTo(2));

    // children of root
    final children = await queryCategoriesRows(
      db,
      where: 'parent_id = ?',
      whereArgs: ['cat-root'],
    );
    expect(children.length, 1);
    expect(children.first['id'], 'cat-child');

    // hierarchy via recursive CTE executed in repo (rawQuery) not here; at least ensure rows exist

    // update
    final updated = await updateCategoryRow(db, 'cat-child', {
      'name': 'Child2',
      'updated_at': 'now',
    });
    expect(updated, equals(1));

    final res = await queryCategoriesRows(
      db,
      where: 'id = ?',
      whereArgs: ['cat-child'],
    );
    expect(res.first['name'], 'Child2');

    // delete
    final deleted = await deleteCategoryRow(db, 'cat-child');
    expect(deleted, equals(1));
    final res2 = await queryCategoriesRows(
      db,
      where: 'id = ?',
      whereArgs: ['cat-child'],
    );
    expect(res2, isEmpty);
  });
}
