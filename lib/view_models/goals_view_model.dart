import 'package:flutter/foundation.dart';
import '../data/repositories/goal_accounts_repo.dart';
import '../data/repositories/accounts_repo.dart';
import '../data/repositories/transfers_repo.dart';
import '../data/utils/uuid_util.dart';
import '../domain/models/account.dart';
import '../domain/models/goal_account.dart';
import '../domain/models/goal_entry.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalAccountsRepository _repo = GoalAccountsRepository();
  final AccountsRepository _accountsRepo = AccountsRepository();
  final TransfersRepository _transfersRepo = TransfersRepository();

  List<GoalEntry> _goals = [];
  List<GoalEntry> get goals => _goals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _goals = await _repo.getAllGoals();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGoal({
    required String name,
    required String objective,
    required int targetAmountCents,
    required String targetDate,
    required String color,
    required String icon,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final id = generateUuidV4();
      final account = Account(
        id: id,
        name: name,
        color: color,
        icon: icon,
        initialBalanceCents: 0,
        actualBalanceCents: 0,
        active: 1,
        typeId: 'GOAL',
      );
      final goal = GoalAccount(
        accountId: id,
        objective: objective,
        targetAmountCents: targetAmountCents,
        targetDate: targetDate,
      );
      await _repo.createGoalWithAccount(account, goal);
      await loadGoals();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> closeGoal({
    required String goalAccountId,
    required String targetAccountId,
    required int amountCents,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (amountCents > 0) {
        await _transfersRepo.createTransfer(
          fromAccountId: goalAccountId,
          toAccountId: targetAccountId,
          amountCents: amountCents,
          description: 'Cierre de meta de ahorro',
        );
      }
      await _accountsRepo.softDeleteAccount(goalAccountId);
      await loadGoals();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalAccountId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _accountsRepo.softDeleteAccount(goalAccountId);
      await loadGoals();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
