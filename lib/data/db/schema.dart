// Schema constants and DDL for FinTrack (version 1)
// Generated from FinTrack_Flutter_SQLite_Implementation.md

// ignore_for_file: constant_identifier_names

const String TABLE_ACCOUNT_TYPES = 'account_types';
const String TABLE_ACCOUNTS = 'accounts';
const String TABLE_BANK_ACCOUNTS = 'bank_accounts';
const String TABLE_CREDIT_CARD_ACCOUNTS = 'credit_card_accounts';
const String TABLE_GOAL_ACCOUNTS = 'goal_accounts';
const String TABLE_DEBT_ACCOUNTS = 'debt_accounts';
const String TABLE_LOAN_ACCOUNTS = 'loan_accounts';
const String TABLE_CATEGORIES = 'categories';
const String TABLE_MOVEMENTS = 'movements';
const String TABLE_TRANSFERS = 'transfers';
const String TABLE_BUDGET = 'budget';
const String TABLE_BUDGET_CATEGORIES = 'budget_categories';

// Common columns
const String COL_ID = 'id';
const String COL_CREATED_AT = 'created_at';
const String COL_UPDATED_AT = 'updated_at';

// accounts columns
const String COL_ACCOUNT_NAME = 'name';
const String COL_ACCOUNT_COLOR = 'color';
const String COL_ACCOUNT_ICON = 'icon';
const String COL_ACCOUNT_DESCRIPTION = 'description';
const String COL_ACCOUNT_INITIAL_BALANCE = 'initial_balance_cents';
const String COL_ACCOUNT_ACTUAL_BALANCE = 'actual_balance_cents';
const String COL_ACCOUNT_ACTIVE = 'active';
const String COL_ACCOUNT_TYPE_ID = 'type_id';

// categories
const String COL_CATEGORY_PARENT_ID = 'parent_id';
const String COL_CATEGORY_ICON = 'icon';
const String COL_CATEGORY_COLOR = 'color';
const String COL_CATEGORY_NAME = 'name';
const String COL_CATEGORY_DESCRIPTION = 'description';
const String COL_CATEGORY_TYPE = 'type';

// movements
const String COL_MOVEMENT_TYPE = 'type';
const String COL_MOVEMENT_ICON = 'icon';
const String COL_MOVEMENT_DESCRIPTION = 'description';
const String COL_MOVEMENT_AMOUNT = 'amount_cents';
const String COL_MOVEMENT_DATE = 'date';
const String COL_MOVEMENT_CATEGORY_ID = 'category_id';
const String COL_MOVEMENT_ACCOUNT_ID = 'account_id';

// transfers
const String COL_TRANSFER_INCOME_MOVEMENT_ID = 'income_movement_id';
const String COL_TRANSFER_OUTCOME_MOVEMENT_ID = 'outcome_movement_id';

// budget
const String COL_BUDGET_ENTITY = 'entity';
const String COL_BUDGET_PERIOD = 'period';
const String COL_BUDGET_TARGET_DATE = 'target_date';
const String COL_BUDGET_LIMIT = 'limit_cents';

// budget_categories
const String COL_BUDGET_CATEGORY_BUDGET_ID = 'budget_id';
const String COL_BUDGET_CATEGORY_CATEGORY_ID = 'category_id';

// DDL list (version 1)
final List<String> ddlV1 = [
  // '''PRAGMA foreign_keys = ON;''', // Moved to onConfigure
  '''
CREATE TABLE account_types (
  id   TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  created_at TEXT NULL,
  updated_at TEXT NULL
);
''',

  '''
CREATE TABLE accounts (
  id                    TEXT PRIMARY KEY,
  name                  TEXT NOT NULL,
  color                 TEXT NOT NULL,
  icon                  TEXT NOT NULL,
  description           TEXT NULL,
  initial_balance_cents INTEGER NOT NULL,
  actual_balance_cents  INTEGER NOT NULL,
  active                INTEGER NOT NULL CHECK(active IN (0,1)),
  type_id               TEXT NOT NULL REFERENCES account_types(id),
  created_at TEXT NULL,
  updated_at TEXT NULL
);
''',

  '''
CREATE TABLE bank_accounts (
  account_id TEXT PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  bank_name  TEXT NOT NULL,
  number     TEXT NOT NULL,
  created_at TEXT NULL,
  updated_at TEXT NULL
);
''',

  '''
CREATE TABLE credit_card_accounts (
  account_id    TEXT PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  bank_name     TEXT NOT NULL,
  last_digits   TEXT NOT NULL
    CHECK(length(last_digits)=4 AND last_digits GLOB '[0-9][0-9][0-9][0-9]'),
  limit_cents   INTEGER NOT NULL CHECK(limit_cents > 0),
  closing_date  TEXT NOT NULL,  -- YYYY-MM-DD
  due_date      TEXT NOT NULL,  -- YYYY-MM-DD
  created_at TEXT NULL,
  updated_at TEXT NULL
);
''',

  '''
CREATE TABLE goal_accounts (
  account_id          TEXT PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  objective           TEXT NOT NULL,
  target_amount_cents INTEGER NOT NULL CHECK(target_amount_cents > 0),
  target_date         TEXT NOT NULL, -- YYYY-MM-DD
  created_at TEXT NULL,
  updated_at TEXT NULL
);
''',

  '''
CREATE TABLE debt_accounts (
  account_id   TEXT PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  entity       TEXT NOT NULL,
  amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
  target_date  TEXT NULL, -- YYYY-MM-DD
  created_at TEXT NULL,
  updated_at TEXT NULL
);
''',

  '''
CREATE TABLE loan_accounts (
  account_id   TEXT PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  entity       TEXT NOT NULL,
  amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
  target_date  TEXT NULL, -- YYYY-MM-DD
  created_at TEXT NULL,
  updated_at TEXT NULL
);
''',

  '''
CREATE TABLE categories (
  id          TEXT PRIMARY KEY,
  parent_id   TEXT NULL REFERENCES categories(id) ON DELETE SET NULL,
  icon        TEXT NOT NULL,
  color       TEXT NOT NULL,
  name        TEXT NOT NULL,
  description TEXT NOT NULL,
  type        TEXT NOT NULL CHECK(type IN ('INCOME','OUTCOME')),
  created_at TEXT NULL,
  updated_at TEXT NULL,
  CHECK(parent_id IS NULL OR parent_id <> id)
);
''',

  '''
CREATE TABLE movements (
  id           TEXT PRIMARY KEY,
  type         TEXT NOT NULL CHECK(type IN ('INCOME','OUTCOME')),
  icon         TEXT NOT NULL,
  description  TEXT NULL,
  amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
  date         TEXT NOT NULL, -- ISO-8601 datetime
  category_id  TEXT NULL REFERENCES categories(id) ON DELETE SET NULL,
  account_id   TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  created_at TEXT NULL,
  updated_at TEXT NULL
);

CREATE INDEX idx_movements_account_date ON movements(account_id, date);
CREATE INDEX idx_movements_category_date ON movements(category_id, date);
CREATE INDEX idx_movements_type_date ON movements(type, date);
''',

  '''
CREATE TABLE transfers (
  id                  TEXT PRIMARY KEY,
  income_movement_id  TEXT NOT NULL UNIQUE REFERENCES movements(id) ON DELETE CASCADE,
  outcome_movement_id TEXT NOT NULL UNIQUE REFERENCES movements(id) ON DELETE CASCADE,
  created_at TEXT NULL,
  updated_at TEXT NULL,
  CHECK(income_movement_id <> outcome_movement_id)
);
''',

  '''
CREATE TABLE budget (
  id          TEXT PRIMARY KEY,
  entity      TEXT NOT NULL,
  period      TEXT NOT NULL CHECK(period IN ('daily','weekly','monthly','yearly')),
  target_date TEXT NULL,  -- YYYY-MM-DD
  limit_cents INTEGER NOT NULL CHECK(limit_cents > 0),
  created_at TEXT NULL,
  updated_at TEXT NULL
);
''',

  '''
CREATE TABLE budget_categories (
  budget_id   TEXT NOT NULL REFERENCES budget(id) ON DELETE CASCADE,
  category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at  TEXT NULL,
  updated_at  TEXT NULL,
  PRIMARY KEY (budget_id, category_id)
);
''',
];
