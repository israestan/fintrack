import 'package:flutter/foundation.dart' hide Category;
import '../data/repositories/budgets_repo.dart';
import '../domain/models/budget.dart';
import '../domain/models/category.dart';

class BudgetsViewModel extends ChangeNotifier {
  final BudgetsRepository _budgetsRepo = BudgetsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Budget> _budgets = [];
  List<Budget> get budgets => _budgets;

  final Map<String, int> _spentByCentsByBudgetId = {};
  int spentCentsFor(String budgetId) => _spentByCentsByBudgetId[budgetId] ?? 0;

  final Map<String, List<Category>> _categoriesByBudgetId = {};
  List<Category> categoriesFor(String budgetId) =>
      _categoriesByBudgetId[budgetId] ?? [];

  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _budgetsRepo.getAllBudgets();
      await Future.wait(
        _budgets.map((b) async {
          _spentByCentsByBudgetId[b.id] =
              await _budgetsRepo.getSpentForBudget(b);
          _categoriesByBudgetId[b.id] =
              await _budgetsRepo.getCategoriesForBudget(b.id);
        }),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBudget(Budget budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _budgetsRepo.createBudget(budget);
      await loadBudgets();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _budgetsRepo.deleteBudget(budgetId);
      await loadBudgets();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategoryToBudget(String budgetId, String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _budgetsRepo.addCategoryToBudget(budgetId, categoryId);
      await loadBudgets();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeCategoryFromBudget(
    String budgetId,
    String categoryId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _budgetsRepo.removeCategoryFromBudget(budgetId, categoryId);
      await loadBudgets();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
