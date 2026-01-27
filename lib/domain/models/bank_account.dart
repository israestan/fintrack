class BankAccount {
  final String accountId;
  final String bankName;
  final String number;
  final String? createdAt;
  final String? updatedAt;

  BankAccount({
    required this.accountId,
    required this.bankName,
    required this.number,
    this.createdAt,
    this.updatedAt,
  });

  factory BankAccount.fromMap(Map<String, Object?> m) => BankAccount(
    accountId: m['account_id'] as String,
    bankName: m['bank_name'] as String,
    number: m['number'] as String,
    createdAt: m['created_at'] as String?,
    updatedAt: m['updated_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'account_id': accountId,
    'bank_name': bankName,
    'number': number,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
