
import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/db/daos/credit_card_accounts_dao.dart';
import 'package:fintrack/data/utils/db_helpers.dart';
import 'package:fintrack/domain/models/credit_card_account.dart';

class CreditCardAccountsRepository {
  Future<void> createCreditCardAccount(CreditCardAccount cca) async {
    final db = await FinTrackDb.instance.db;
    final row = cca.toMap();
    final toInsert = withCreateTimestamps(row);
    await insertCreditCardAccountRow(db, toInsert);
  }

  Future<CreditCardAccount?> getByAccountId(String accountId) async {
    final db = await FinTrackDb.instance.db;
    final rows = await queryCreditCardAccountRows(db, where: 'account_id = ?', whereArgs: [accountId], limit: 1);
    if (rows.isEmpty) return null;
    return CreditCardAccount.fromMap(rows.first);
  }

  Future<int> updateCreditCardAccount(String accountId, Map<String, Object?> changes) async {
    final db = await FinTrackDb.instance.db;
    final updateRow = withUpdateTimestamp(changes);
    return await updateCreditCardAccountRow(db, accountId, updateRow);
  }

  Future<int> deleteCreditCardAccount(String accountId) async {
    final db = await FinTrackDb.instance.db;
    return await deleteCreditCardAccountRow(db, accountId);
  }
}
