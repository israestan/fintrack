import 'package:flutter/foundation.dart';
import '../data/repositories/transfers_repo.dart';

class TransfersViewModel extends ChangeNotifier {
  final TransfersRepository _transfersRepo;

  TransfersViewModel({TransfersRepository? transfersRepo})
      : _transfersRepo = transfersRepo ?? TransfersRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required int amountCents,
    String? description,
    String? dateIso,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (fromAccountId == toAccountId) {
        throw ArgumentError('Las cuentas de origen y destino deben ser diferentes.');
      }
      
      await _transfersRepo.createTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amountCents: amountCents,
        description: description,
        dateIso: dateIso,
        updateAccountBalances: true,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransfer(String transferId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _transfersRepo.deleteTransfer(
        transferId,
        updateAccountBalances: true,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
