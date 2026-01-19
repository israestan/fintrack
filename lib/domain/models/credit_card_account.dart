class CreditCardAccount {
  final String accountId;
  final String bankName;
  final String lastDigits;
  final int limitCents;
  final String closingDate;
  final String dueDate;
  final String? createdAt;
  final String? updatedAt;

  CreditCardAccount({
    required this.accountId,
    required this.bankName,
    required this.lastDigits,
    required this.limitCents,
    required this.closingDate,
    required this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory CreditCardAccount.fromMap(Map<String, Object?> m) => CreditCardAccount(
        accountId: m['account_id'] as String,
        bankName: m['bank_name'] as String,
        lastDigits: m['last_digits'] as String,
        limitCents: m['limit_cents'] as int,
        closingDate: m['closing_date'] as String,
        dueDate: m['due_date'] as String,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, Object?> toMap() => {
        'account_id': accountId,
        'bank_name': bankName,
        'last_digits': lastDigits,
        'limit_cents': limitCents,
        'closing_date': closingDate,
        'due_date': dueDate,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
