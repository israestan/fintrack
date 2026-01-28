import 'package:fintrack/domain/models/movement.dart';
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
        // Update balances atomically using arithmetic
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
}
