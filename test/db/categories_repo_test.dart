import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/repositories/categories_repo.dart';
import 'package:fintrack/domain/models/category.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    // Use ffi databaseFactory so FinTrackDb can open DB in tests
    databaseFactory = databaseFactoryFfi;
    // initialize FinTrackDb which will run ddlV1 in onCreate
    await FinTrackDb.instance.init(dbName: 'test_fintrack.db');
  });

  tearDownAll(() async {
    await FinTrackDb.instance.close();
  });

  test('createCategory and listHierarchy via repo', () async {
    final repo = CategoriesRepository();

    final root = Category(
      id: '',
      parentId: null,
      icon: 'root_icon',
      color: '#123456',
      name: 'RootRepo',
      description: 'Root from repo',
      type: 'OUTCOME',
    );

    final child = Category(
      id: '',
      parentId: null, // will set after root created
      icon: 'child_icon',
      color: '#654321',
      name: 'ChildRepo',
      description: 'Child from repo',
      type: 'OUTCOME',
    );

    // create root
    final createdRoot = await repo.createCategory(root);
    expect(createdRoot.id, isNotEmpty);

    // create child with parent id
    final childWithParent = Category(
      id: '',
      parentId: createdRoot.id,
      icon: child.icon,
      color: child.color,
      name: child.name,
      description: child.description,
      type: child.type,
    );

    final createdChild = await repo.createCategory(childWithParent);
    expect(createdChild.id, isNotEmpty);

    // listByType
    final byType = await repo.listByType('OUTCOME');
    expect(byType.any((c) => c.id == createdRoot.id), isTrue);
    expect(byType.any((c) => c.id == createdChild.id), isTrue);

    // children of root
    final children = await repo.listChildren(createdRoot.id);
    expect(children.length, 1);
    expect(children.first.id, createdChild.id);

    // hierarchy (CTE)
    final hierarchy = await repo.listHierarchy(createdRoot.id);
    expect(hierarchy.any((c) => c.id == createdChild.id), isTrue);

    // update
    final updated = await repo.updateCategory(createdChild.id, {'name': 'ChildRepo2'});
    expect(updated, 1);
    final fetched = await repo.getCategoryById(createdChild.id);
    expect(fetched?.name, 'ChildRepo2');

    // delete
    final deleted = await repo.deleteCategory(createdChild.id);
    expect(deleted, 1);
    final after = await repo.getCategoryById(createdChild.id);
    expect(after, isNull);
  });
}
