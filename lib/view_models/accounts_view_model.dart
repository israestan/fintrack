import 'package:flutter/material.dart';
import '../data/repositories/accounts_repo.dart';
import '../data/repositories/bank_accounts_repo.dart';
import '../domain/models/account.dart';
import '../domain/models/bank_account.dart';

class AccountsViewModel extends ChangeNotifier {
  final AccountsRepository _accountsRepo;
  final BankAccountsRepository _bankAccountsRepo;

  AccountsViewModel({
    AccountsRepository? accountsRepo,
    BankAccountsRepository? bankAccountsRepo,
  }) : _accountsRepo = accountsRepo ?? AccountsRepository(),
       _bankAccountsRepo = bankAccountsRepo ?? BankAccountsRepository();

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

  Future<void> createAccount(
    Account account, {
    Map<String, String>? bankDetails,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final createdAccount = await _accountsRepo.createAccount(account);

      if (bankDetails != null) {
        final bankAccount = BankAccount(
          accountId: createdAccount.id,
          bankName: bankDetails['bank_name'] ?? '',
          number: bankDetails['number'] ?? '',
        );
        await _bankAccountsRepo.createBankAccount(bankAccount);
      }

      await loadAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAccount(
    Account account, {
    Map<String, String>? bankDetails,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _accountsRepo.updateAccount(account.id, account.toMap());

      if (bankDetails != null) {
        final existing = await _bankAccountsRepo.getByAccountId(account.id);
        if (existing != null) {
          await _bankAccountsRepo.updateBankAccount(account.id, {
            'bank_name': bankDetails['bank_name'],
            'number': bankDetails['number'],
          });
        } else {
          final bankAccount = BankAccount(
            accountId: account.id,
            bankName: bankDetails['bank_name'] ?? '',
            number: bankDetails['number'] ?? '',
          );
          await _bankAccountsRepo.createBankAccount(bankAccount);
        }
      } else {
      }

      await loadAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _accountsRepo.softDeleteAccount(id);
      await loadAccounts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BankAccount?> getBankAccount(String accountId) async {
    try {
      return await _bankAccountsRepo.getByAccountId(accountId);
    } catch (e) {
      return null;
    }
  }
}
