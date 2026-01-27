class GoalAccount {
  final String accountId;
  final String objective;
  final int targetAmountCents;
  final String targetDate;
  final String? createdAt;
  final String? updatedAt;

  GoalAccount({
    required this.accountId,
    required this.objective,
    required this.targetAmountCents,
    required this.targetDate,
    this.createdAt,
    this.updatedAt,
  });

  factory GoalAccount.fromMap(Map<String, Object?> m) => GoalAccount(
    accountId: m['account_id'] as String,
    objective: m['objective'] as String,
    targetAmountCents: m['target_amount_cents'] as int,
    targetDate: m['target_date'] as String,
    createdAt: m['created_at'] as String?,
    updatedAt: m['updated_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'account_id': accountId,
    'objective': objective,
    'target_amount_cents': targetAmountCents,
    'target_date': targetDate,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
