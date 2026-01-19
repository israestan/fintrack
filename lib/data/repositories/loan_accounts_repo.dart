import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/loan_accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/domain/models/loan_account.dart';

class LoanAccountsRepository {
  Future<void> createLoanAccount(LoanAccount la) async {
    final db = await FinTrackDb.instance.db;
    final row = la.toMap();
    final toInsert = withCreateTimestamps(row);
    await insertLoanAccountRow(db, toInsert);
  }

  Future<LoanAccount?> getByAccountId(String accountId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryLoanAccountRows(db, where: 'account_id = ?', whereArgs: [accountId], limit: 1);
    if (rows.isEmpty) return null;
    return LoanAccount.fromMap(rows.first);
  }

  Future<int> updateLoanAccount(String accountId, Map<String, Object?> changes) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateLoanAccountRow(db, accountId, updateRow);
  }

  Future<int> deleteLoanAccount(String accountId) async {
    final db = await FinTrackDb.instance.db;
    return await deleteLoanAccountRow(db, accountId);
  }
}
