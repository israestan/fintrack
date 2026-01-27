class BudgetAccount {
  final String accountId;
  final String budgetId;
  final String? createdAt;
  final String? updatedAt;

  BudgetAccount({
    required this.accountId,
    required this.budgetId,
    this.createdAt,
    this.updatedAt,
  });

  factory BudgetAccount.fromMap(Map<String, Object?> m) => BudgetAccount(
    accountId: m['account_id'] as String,
    budgetId: m['budget_id'] as String,
    createdAt: m['created_at'] as String?,
    updatedAt: m['updated_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'account_id': accountId,
    'budget_id': budgetId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
