import 'package:flutter/foundation.dart';
import '../data/repositories/movements_repo.dart';
import '../data/repositories/transfers_repo.dart';
import '../domain/models/movement.dart';

class MovementsViewModel extends ChangeNotifier {
  final MovementsRepository _movementsRepo = MovementsRepository();
  final TransfersRepository _transfersRepo = TransfersRepository();

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
      await _movementsRepo.createMovementAndUpdateBalance(movement);
      await loadMovements();
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
      final transfer = await _transfersRepo.getTransferByMovementId(movement.id);
      if (transfer != null) {
        await _transfersRepo.deleteTransfer(transfer.id);
      } else {
        await _movementsRepo.deleteMovementAndRevertBalance(movement.id);
      }

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
