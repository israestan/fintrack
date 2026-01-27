import 'package:sqflite_common/sqlite_api.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/categories_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/domain/models/category.dart';

class CategoriesRepository {
  Future<Category> createCategory(Category category) async {
    final db = await FinTrackDb.instance.db;
    final id = category.id.isNotEmpty ? category.id : generateUuidV4();
    final row = category.toMap()..['id'] = id;
    final toInsert = withCreateTimestamps(row);
    await insertCategoryRow(db, toInsert);
    final inserted = await getCategoryById(id);
    return inserted!;
  }

  Future<Category?> getCategoryById(String id) async {
    final db = await FinTrackDb.instance.db;
    final res = await queryCategoriesRows(
      db,
      where: 'id = ?',
      whereArgs: [id],
      orderBy: null,
    );
    if (res.isEmpty) return null;
    return Category.fromMap(res.first);
  }

  Future<List<Category>> listByType(String type) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryCategoriesRows(
      db,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name',
    );
    return rows.map((r) => Category.fromMap(r)).toList();
  }

  Future<List<Category>> listChildren(String? parentId) async {
    final db = await FinTrackDb.instance.db;
    if (parentId == null) {
      final rows = await queryCategoriesRows(
        db,
        where: 'parent_id IS NULL',
        orderBy: 'name',
      );
      return rows.map((r) => Category.fromMap(r)).toList();
    }
    final rows = await queryCategoriesRows(
      db,
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'name',
    );
    return rows.map((r) => Category.fromMap(r)).toList();
  }

  /// Returns the subtree starting at `rootId` (inclusive) using a recursive CTE.
  Future<List<Category>> listHierarchy(String rootId) async {
    final db = await FinTrackDb.instance.db;
    final sql = '''WITH RECURSIVE subtree AS (
      SELECT * FROM categories WHERE id = ?
      UNION ALL
      SELECT c.* FROM categories c JOIN subtree s ON c.parent_id = s.id
    ) SELECT * FROM subtree;''';
    final res = await db.rawQuery(sql, [rootId]);
    return res.map((r) => Category.fromMap(r)).toList();
  }

  Future<int> updateCategory(String id, Map<String, Object?> changes) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateCategoryRow(db, id, updateRow);
  }

  Future<int> deleteCategory(String id) async {
    final db = await FinTrackDb.instance.db;
    return await deleteCategoryRow(db, id);
  }

  // Transactional helper
  Future<String> createCategoryInTransaction(
    DatabaseExecutor txn,
    Category category,
  ) async {
    final id = category.id.isNotEmpty ? category.id : generateUuidV4();
    final row = category.toMap()..['id'] = id;
    final toInsert = withCreateTimestamps(row);
    await insertCategoryRow(txn, toInsert);
    return id;
  }
}
