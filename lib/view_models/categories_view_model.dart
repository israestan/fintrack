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

  Category? getCategoryById(String id) {
    try {
      return [..._incomeCategories, ..._expenseCategories].firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

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
    }
  }

  Future<void> deleteCategory(String id, String type) async {
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

    }
  }
}
