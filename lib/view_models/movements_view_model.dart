import 'package:flutter/foundation.dart';
import '../data/repositories/movements_repo.dart';
import '../data/repositories/accounts_repo.dart';
import '../domain/models/movement.dart';

class MovementsViewModel extends ChangeNotifier {
  final MovementsRepository _movementsRepo = MovementsRepository();
  final AccountsRepository _accountsRepo = AccountsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Movement> _movements = [];
  List<Movement> get movements => _movements;

  Future<void> loadMovements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movements = await _movementsRepo.getMovements();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovement(Movement movement) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Create the movement in DB
      await _movementsRepo.createMovement(movement);
      
      // Refresh local list
      await loadMovements();

      // 2. Update the associated account balance
      final account = await _accountsRepo.getAccountById(movement.accountId);
      if (account != null) {
        int newBalance = account.actualBalanceCents;
        
        // Income increases balance, Expense decreases balance
        if (movement.type == 'INCOME') {
          newBalance += movement.amountCents;
        } else {
          newBalance -= movement.amountCents;
        }
        
        await _accountsRepo.updateAccount(
          account.id, 
          {'actual_balance_cents': newBalance}
        );
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMovement(Movement movement) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Update the associated account balance (Reverse logic)
      final account = await _accountsRepo.getAccountById(movement.accountId);
      if (account != null) {
        int newBalance = account.actualBalanceCents;
        
        // If we are deleting an Income, we remove the money.
        // If we are deleting an Outcome (Expense), we give the money back.
        if (movement.type == 'INCOME') {
          newBalance -= movement.amountCents;
        } else {
          newBalance += movement.amountCents;
        }
        
        await _accountsRepo.updateAccount(
          account.id, 
          {'actual_balance_cents': newBalance}
        );
      }

      // 2. Delete the movement from DB
      await _movementsRepo.deleteMovement(movement.id);
      
      // Refresh local list
      await loadMovements();

    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
