import 'package:fintrack/domain/models/movement.dart';
import 'package:fintrack/domain/models/transfer.dart';
import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/transfers_dao.dart';
import 'package:fintrack/data/utils/uuid_util.dart';
import 'package:fintrack/data/utils/time_utils.dart';
import 'package:fintrack/data/repositories/movements_repo.dart';

class TransfersRepository {
  final MovementsRepository _movementsRepo = MovementsRepository();

  /// Create a transfer as a single transaction: outcome movement (from), income movement (to), transfer record.
  /// Optionally updates `accounts.actual_balance_cents` (default true).
  Future<String> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required int amountCents,
    String? description,
    String? dateIso,
    bool updateAccountBalances = true,
  }) async {
    if (amountCents <= 0) throw ArgumentError('amountCents must be > 0');
    if (fromAccountId == toAccountId) {
      throw ArgumentError('fromAccountId and toAccountId must differ');
    }

    final db = await FinTrackDb.instance.db;
    final transferId = generateUuidV4();
    final now = dateIso ?? nowIsoUtc();

    await db.transaction((txn) async {
      // Outcome movement (money leaving fromAccount)
      final outcomeId = await _movementsRepo.createMovement(
        // build movement map via Movement model map shape
        // Using minimal required fields: id generated inside createMovement
        // type = 'OUTCOME'
        // icon required by schema, use 'transfer'
        // account_id = fromAccountId
        // amount_cents positive
        // date = now
        // description optional
        // category_id null
        // created_at/updated_at handled by helper
        // Pass txn to ensure transaction context
        // Create Movement object inline
        Movement(
          id: '',
          type: 'OUTCOME',
          icon: 'transfer',
          description: description,
          amountCents: amountCents,
          date: now,
          categoryId: null,
          accountId: fromAccountId,
        ),
        txn: txn,
      );

      // Income movement (money entering toAccount)
      final incomeId = await _movementsRepo.createMovement(
        Movement(
          id: '',
          type: 'INCOME',
          icon: 'transfer',
          description: description,
          amountCents: amountCents,
          date: now,
          categoryId: null,
          accountId: toAccountId,
        ),
        txn: txn,
      );

      // Insert transfer record
      final transferRow = {
        'id': transferId,
        'income_movement_id': incomeId,
        'outcome_movement_id': outcomeId,
        'created_at': now,
        'updated_at': now,
      };
      await insertTransferRow(txn, transferRow);

      if (updateAccountBalances) {
        // Validate that the origin account has sufficient balance before subtracting.
        final fromRows = await txn.query(
          'accounts',
          columns: ['actual_balance_cents'],
          where: 'id = ?',
          whereArgs: [fromAccountId],
          limit: 1,
        );
        if (fromRows.isEmpty) {
          throw ArgumentError('Cuenta de origen no encontrada');
        }
        final currentBalance = fromRows.first['actual_balance_cents'] as int;
        if (currentBalance < amountCents) {
          throw ArgumentError(
            'Saldo insuficiente en la cuenta de origen. '
            'Disponible: ${(currentBalance / 100).toStringAsFixed(2)}, '
            'requerido: ${(amountCents / 100).toStringAsFixed(2)}.',
          );
        }

        // Update balances atomically using arithmetic.
        await txn.rawUpdate(
          'UPDATE accounts SET actual_balance_cents = actual_balance_cents - ? WHERE id = ?',
          [amountCents, fromAccountId],
        );
        await txn.rawUpdate(
          'UPDATE accounts SET actual_balance_cents = actual_balance_cents + ? WHERE id = ?',
          [amountCents, toAccountId],
        );
      }
    });

    return transferId;
  }

  /// Retrieves a transfer by its ID
  Future<Transfer?> getTransferById(String transferId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryTransfersRows(db, where: 'id = ?', whereArgs: [transferId]);
    if (rows.isEmpty) return null;
    return Transfer.fromMap(rows.first);
  }

  /// Retrieves the transfer associated with a given movement ID (whether it's the income or outcome movement).
  Future<Transfer?> getTransferByMovementId(String movementId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryTransfersRows(
      db, 
      where: 'income_movement_id = ? OR outcome_movement_id = ?', 
      whereArgs: [movementId, movementId],
    );
    if (rows.isEmpty) return null;
    return Transfer.fromMap(rows.first);
  }

  /// Deletes a transfer and its associated income and outcome movements, 
  /// and reverses the account balances if updateAccountBalances is true.
  Future<void> deleteTransfer(String transferId, {bool updateAccountBalances = true}) async {
    final db = await FinTrackDb.instance.db;
    
    await db.transaction((txn) async {
      final transferRows = await queryTransfersRows(txn, where: 'id = ?', whereArgs: [transferId]);
      if (transferRows.isEmpty) {
        throw Exception('Transfer not found');
      }
      final transfer = Transfer.fromMap(transferRows.first);

      // Get the corresponding movements to find the amount and accounts
      final incomeRows = await txn.query('movements', where: 'id = ?', whereArgs: [transfer.incomeMovementId]);
      final outcomeRows = await txn.query('movements', where: 'id = ?', whereArgs: [transfer.outcomeMovementId]);

      if (incomeRows.isEmpty || outcomeRows.isEmpty) {
        throw Exception('Associated movements not found for this transfer');
      }

      final incomeMovement = Movement.fromMap(incomeRows.first);
      final outcomeMovement = Movement.fromMap(outcomeRows.first);

      // Reverse account balances
      if (updateAccountBalances) {
        // Income movement gave money to toAccountId. We must subtract it.
        await txn.rawUpdate(
          'UPDATE accounts SET actual_balance_cents = actual_balance_cents - ? WHERE id = ?',
          [incomeMovement.amountCents, incomeMovement.accountId],
        );
        // Outcome movement took money from fromAccountId. We must add it back.
        await txn.rawUpdate(
          'UPDATE accounts SET actual_balance_cents = actual_balance_cents + ? WHERE id = ?',
          [outcomeMovement.amountCents, outcomeMovement.accountId],
        );
      }

      // Delete the transfer record
      await deleteTransferRow(txn, transferId);

      // Delete the associated movements
      await txn.delete('movements', where: 'id = ?', whereArgs: [transfer.incomeMovementId]);
      await txn.delete('movements', where: 'id = ?', whereArgs: [transfer.outcomeMovementId]);
    });
  }
}
