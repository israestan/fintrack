import 'package:flutter/material.dart';
import '../data/repositories/accounts_repo.dart';
import '../domain/models/account.dart';

class AccountsViewModel extends ChangeNotifier {
  final AccountsRepository _accountsRepo;

  AccountsViewModel({AccountsRepository? accountsRepo})
      : _accountsRepo = accountsRepo ?? AccountsRepository();

  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _accountsRepo.listAccounts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAccount(Account account) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _accountsRepo.createAccount(account);
      await loadAccounts(); // Recargar lista
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-lanzar para que la UI sepa que falló
    } finally {
      _isLoading = false; // Solo si no re-lanzamos, pero aquí para asegurar reset
      notifyListeners();
    }
  }
}
