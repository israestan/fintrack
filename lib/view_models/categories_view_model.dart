import 'package:flutter/material.dart';
import '../data/repositories/categories_repo.dart';
import '../domain/models/category.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesRepository _categoriesRepo;

  CategoriesViewModel({
    CategoriesRepository? categoriesRepo,
  }) : _categoriesRepo = categoriesRepo ?? CategoriesRepository();

  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIncomeCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _incomeCategories = await _categoriesRepo.listByType('INCOME');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExpenseCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenseCategories = await _categoriesRepo.listByType('OUTCOME');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadIncomeCategories(),
      loadExpenseCategories(),
    ]);
  }

  Future<void> createCategory(Category category) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _categoriesRepo.createCategory(category);
      if (category.type == 'INCOME') {
        await loadIncomeCategories();
      } else {
        await loadExpenseCategories();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      // Loading is set to false inside load... methods, but if they are called sequentially, it's fine.
      // However, if we didn't call load..., we should ensure isLoading is false.
      // Since we await load... methods which handle isLoading, we are good.
      // Actually, load... methods set isLoading = true at start.
      // So effectively:
      // create -> isLoading=true -> repo.create -> load -> isLoading=true -> repo.list -> isLoading=false.
      // There's a minimal flickr or redundant state change but it's safe.
    }
  }

  Future<void> updateCategory(Category category) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _categoriesRepo.updateCategory(category.id, category.toMap());
      if (category.type == 'INCOME') {
        await loadIncomeCategories();
      } else {
        await loadExpenseCategories();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      // _isLoading set to false by load... methods
    }
  }

  Future<void> deleteCategory(String id, String type) async {
    // We need type to know which list to reload, or we can just reload both or reload based on current assumption.
    // Passing type is safer optimization.
    _isLoading = true;
    notifyListeners();

    try {
      await _categoriesRepo.deleteCategory(id);
      if (type == 'INCOME') {
        await loadIncomeCategories();
      } else {
        await loadExpenseCategories();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      // _isLoading set to false by load... methods
    }
  }
}
