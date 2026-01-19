class DebtAccount {
  final String accountId;
  final String entity;
  final int amountCents;
  final String? targetDate;
  final String? createdAt;
  final String? updatedAt;

  DebtAccount({
    required this.accountId,
    required this.entity,
    required this.amountCents,
    this.targetDate,
    this.createdAt,
    this.updatedAt,
  });

  factory DebtAccount.fromMap(Map<String, Object?> m) => DebtAccount(
        accountId: m['account_id'] as String,
        entity: m['entity'] as String,
        amountCents: m['amount_cents'] as int,
        targetDate: m['target_date'] as String?,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, Object?> toMap() => {
        'account_id': accountId,
        'entity': entity,
        'amount_cents': amountCents,
        'target_date': targetDate,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
