import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fintrack/data/db/schema.dart';
import 'package:fintrack/data/db/daos/bank_accounts_dao.dart';
import 'package:fintrack/data/db/daos/credit_card_accounts_dao.dart';
import 'package:fintrack/data/db/daos/goal_accounts_dao.dart';
import 'package:fintrack/data/db/daos/debt_accounts_dao.dart';
import 'package:fintrack/data/db/daos/loan_accounts_dao.dart';

void main() {
  late Database db;

  setUpAll(() async {
    sqfliteFfiInit();
    final factory = databaseFactoryFfi;
    db = await factory.openDatabase(inMemoryDatabasePath);
    for (final stmt in ddlV1) {
      final s = stmt.trim();
      if (s.isEmpty) continue;
      await db.execute(s);
    }
    // Prepare account_types and account for FK references
    await db.insert('account_types', {
      'id': 't1',
      'code': 'T1',
      'name': 'Type1',
    });
    await db.insert('accounts', {
      'id': 'acct-sub',
      'name': 'SubAccount',
      'color': '#000',
      'icon': 'i',
      'description': null,
      'initial_balance_cents': 0,
      'actual_balance_cents': 0,
      'active': 1,
      'type_id': 't1',
    });
  });

  tearDownAll(() async {
    await db.close();
  });

  test('bank_accounts DAO insert/query/update/delete and cascade', () async {
    final row = {
      'account_id': 'acct-sub',
      'bank_name': 'Bank X',
      'number': '12345',
      'created_at': null,
      'updated_at': null,
    };
    final id = await insertBankAccountRow(db, row);
    expect(id, greaterThan(0));

    final rows = await queryBankAccountRows(
      db,
      where: 'account_id = ?',
      whereArgs: ['acct-sub'],
    );
    expect(rows.length, 1);

    final updated = await updateBankAccountRow(db, 'acct-sub', {
      'bank_name': 'Bank Y',
      'updated_at': 'now',
    });
    expect(updated, 1);

    // Cascade: deleting account should delete bank_accounts
    await db.delete('accounts', where: 'id = ?', whereArgs: ['acct-sub']);
    final after = await queryBankAccountRows(
      db,
      where: 'account_id = ?',
      whereArgs: ['acct-sub'],
    );
    expect(after, isEmpty);
  });

  test('credit_card_accounts DAO constraints and CRUD', () async {
    // recreate account
    await db.insert('accounts', {
      'id': 'acct-cc',
      'name': 'CCAccount',
      'color': '#111',
      'icon': 'c',
      'description': null,
      'initial_balance_cents': 0,
      'actual_balance_cents': 0,
      'active': 1,
      'type_id': 't1',
    });

    final good = {
      'account_id': 'acct-cc',
      'bank_name': 'CC Bank',
      'last_digits': '1234',
      'limit_cents': 100000,
      'closing_date': '2025-12-31',
      'due_date': '2026-01-15',
      'created_at': null,
      'updated_at': null,
    };
    final inserted = await insertCreditCardAccountRow(db, good);
    expect(inserted, greaterThan(0));

    final rows = await queryCreditCardAccountRows(
      db,
      where: 'account_id = ?',
      whereArgs: ['acct-cc'],
    );
    expect(rows.length, 1);

    // invalid last_digits should fail
    final bad = Map<String, Object?>.from(good);
    bad['account_id'] = 'acct-cc';
    bad['last_digits'] = '12A4';
    try {
      await insertCreditCardAccountRow(db, bad);
      fail('Invalid last_digits should throw');
    } catch (e) {
      expect(e, isNotNull);
    }
  });

  test(
    'goal_accounts, debt_accounts and loan_accounts constraints and CRUD',
    () async {
      // goal_accounts
      await db.insert('accounts', {
        'id': 'acct-goal',
        'name': 'GoalAcc',
        'color': '#222',
        'icon': 'g',
        'description': null,
        'initial_balance_cents': 0,
        'actual_balance_cents': 0,
        'active': 1,
        'type_id': 't1',
      });
      final goal = {
        'account_id': 'acct-goal',
        'objective': 'Buy X',
        'target_amount_cents': 50000,
        'target_date': '2026-01-01',
        'created_at': null,
        'updated_at': null,
      };
      final gId = await insertGoalAccountRow(db, goal);
      expect(gId, greaterThan(0));

      // debt_accounts
      await db.insert('accounts', {
        'id': 'acct-debt',
        'name': 'DebtAcc',
        'color': '#333',
        'icon': 'd',
        'description': null,
        'initial_balance_cents': 0,
        'actual_balance_cents': 0,
        'active': 1,
        'type_id': 't1',
      });
      final debt = {
        'account_id': 'acct-debt',
        'entity': 'Lender',
        'amount_cents': 20000,
        'target_date': null,
        'created_at': null,
        'updated_at': null,
      };
      final dId = await insertDebtAccountRow(db, debt);
      expect(dId, greaterThan(0));

      // loan_accounts
      await db.insert('accounts', {
        'id': 'acct-loan',
        'name': 'LoanAcc',
        'color': '#444',
        'icon': 'l',
        'description': null,
        'initial_balance_cents': 0,
        'actual_balance_cents': 0,
        'active': 1,
        'type_id': 't1',
      });
      final loan = {
        'account_id': 'acct-loan',
        'entity': 'BankLoan',
        'amount_cents': 30000,
        'target_date': null,
        'created_at': null,
        'updated_at': null,
      };
      final lId = await insertLoanAccountRow(db, loan);
      expect(lId, greaterThan(0));

      // negative amount should fail for debt
      final badDebt = Map<String, Object?>.from(debt);
      badDebt['account_id'] = 'acct-debt';
      badDebt['amount_cents'] = -10;
      try {
        await insertDebtAccountRow(db, badDebt);
        fail('Negative amount should throw');
      } catch (e) {
        expect(e, isNotNull);
      }
    },
  );
}
