import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/fintrack_db.dart';
import 'package:fintrack/data/repositories/bank_accounts_repo.dart';
import 'package:fintrack/data/repositories/credit_card_accounts_repo.dart';
import 'package:fintrack/data/repositories/goal_accounts_repo.dart';
import 'package:fintrack/data/repositories/debt_accounts_repo.dart';
import 'package:fintrack/data/repositories/loan_accounts_repo.dart';
import 'package:fintrack/domain/models/bank_account.dart';
import 'package:fintrack/domain/models/credit_card_account.dart';
import 'package:fintrack/domain/models/goal_account.dart';
import 'package:fintrack/domain/models/debt_account.dart';
import 'package:fintrack/domain/models/loan_account.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await FinTrackDb.instance.init(dbName: 'test_fintrack.db');
  });

  tearDownAll(() async {
    await FinTrackDb.instance.close();
  });

  test('bank account repo create/get/update/delete', () async {
    final db = await FinTrackDb.instance.db;
    await db.rawInsert(
      'INSERT OR IGNORE INTO account_types (id, code, name) VALUES (?, ?, ?)',
      ['t1', 'T1', 'Type1'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['acct-br', 'BR', '#000', 'i', null, 0, 0, 1, 't1'],
    );

    final repo = BankAccountsRepository();
    final ba = BankAccount(
      accountId: 'acct-br',
      bankName: 'RepoBank',
      number: '999',
    );
    await repo.createBankAccount(ba);
    final fetched = await repo.getByAccountId('acct-br');
    expect(fetched?.bankName, 'RepoBank');
    await repo.updateBankAccount('acct-br', {'bank_name': 'RepoBank2'});
    final fetched2 = await repo.getByAccountId('acct-br');
    expect(fetched2?.bankName, 'RepoBank2');
    await repo.deleteBankAccount('acct-br');
    final after = await repo.getByAccountId('acct-br');
    expect(after, isNull);
  });

  test('credit card repo create invalid should throw', () async {
    final db = await FinTrackDb.instance.db;
    await db.rawInsert(
      'INSERT OR IGNORE INTO account_types (id, code, name) VALUES (?, ?, ?)',
      ['t2', 'T2', 'Type2'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['acct-cc-r', 'CCR', '#000', 'i', null, 0, 0, 1, 't2'],
    );

    final repo = CreditCardAccountsRepository();
    final bad = CreditCardAccount(
      accountId: 'acct-cc-r',
      bankName: 'B',
      lastDigits: '12A4',
      limitCents: 1000,
      closingDate: '2025-12-31',
      dueDate: '2026-01-15',
    );
    try {
      await repo.createCreditCardAccount(bad);
      fail('Invalid credit card last digits should throw');
    } catch (e) {
      expect(e, isNotNull);
    }
  });

  test('goal, debt and loan repos create/get/update/delete', () async {
    final db = await FinTrackDb.instance.db;
    await db.rawInsert(
      'INSERT OR IGNORE INTO account_types (id, code, name) VALUES (?, ?, ?)',
      ['t3', 'T3', 'Type3'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['acct-g', 'G', '#000', 'i', null, 0, 0, 1, 't3'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['acct-d', 'D', '#000', 'i', null, 0, 0, 1, 't3'],
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO accounts (id, name, color, icon, description, initial_balance_cents, actual_balance_cents, active, type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      ['acct-l', 'L', '#000', 'i', null, 0, 0, 1, 't3'],
    );

    final goalRepo = GoalAccountsRepository();
    final ga = GoalAccount(
      accountId: 'acct-g',
      objective: 'Save',
      targetAmountCents: 10000,
      targetDate: '2026-01-01',
    );
    await goalRepo.createGoalAccount(ga);
    final fetchedG = await goalRepo.getByAccountId('acct-g');
    expect(fetchedG?.objective, 'Save');

    final debtRepo = DebtAccountsRepository();
    final da = DebtAccount(accountId: 'acct-d', entity: 'L', amountCents: 2000);
    await debtRepo.createDebtAccount(da);
    final fetchedD = await debtRepo.getByAccountId('acct-d');
    expect(fetchedD?.entity, 'L');

    final loanRepo = LoanAccountsRepository();
    final la = LoanAccount(
      accountId: 'acct-l',
      entity: 'Loan',
      amountCents: 3000,
    );
    await loanRepo.createLoanAccount(la);
    final fetchedL = await loanRepo.getByAccountId('acct-l');
    expect(fetchedL?.entity, 'Loan');
  });
}
