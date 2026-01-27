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

      await loadAccounts(); // Recargar lista
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-lanzar para que la UI sepa que falló
    } finally {
      _isLoading =
          false; // Solo si no re-lanzamos, pero aquí para asegurar reset
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
      // 1. Actualizar cuenta base
      await _accountsRepo.updateAccount(account.id, account.toMap());

      // 2. Manejar detalles bancarios
      // Si recibimos detalles, actualizamos o creamos (upsert lógico)
      if (bankDetails != null) {
        final existing = await _bankAccountsRepo.getByAccountId(account.id);
        if (existing != null) {
          // Actualizar
          await _bankAccountsRepo.updateBankAccount(account.id, {
            'bank_name': bankDetails['bank_name'],
            'number': bankDetails['number'],
          });
        } else {
          // Crear si no existía (ej. cambió de CASH a SAVINGS)
          final bankAccount = BankAccount(
            accountId: account.id,
            bankName: bankDetails['bank_name'] ?? '',
            number: bankDetails['number'] ?? '',
          );
          await _bankAccountsRepo.createBankAccount(bankAccount);
        }
      } else {
        // Si NO recibimos detalles bancarios, pero la cuenta antes tenía (ej. cambió de SAVINGS a CASH)
        // Deberíamos borrar los detalles bancarios?
        // Por ahora, asumimos que si el tipo cambia, el Repo de banco no se toca o se borra manual.
        // Dado el requerimiento "No inventes", lo dejaremos simple: solo actuamos si hay detalles nuevos.
        // Aunque para consistencia, si cambia a efectivo, los datos bancarios quedan huérfanos/ocultos.
        // Una mejora sería verificar el tipo de cuenta y borrar bank_account si ya no aplica.
        // Pero para MVP, actualizar es suficiente.
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
      // Silencioso o log
      return null;
    }
  }
}
