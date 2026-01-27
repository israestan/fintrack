class Movement {
  final String id;
  final String type; // 'INCOME' | 'OUTCOME'
  final String icon;
  final String? description;
  final int amountCents;
  final String date; // ISO-8601 datetime
  final String? categoryId;
  final String accountId;
  final String? createdAt;
  final String? updatedAt;

  Movement({
    required this.id,
    required this.type,
    required this.icon,
    this.description,
    required this.amountCents,
    required this.date,
    this.categoryId,
    required this.accountId,
    this.createdAt,
    this.updatedAt,
  });

  factory Movement.fromMap(Map<String, Object?> m) => Movement(
    id: m['id'] as String,
    type: m['type'] as String,
    icon: m['icon'] as String,
    description: m['description'] as String?,
    amountCents: (m['amount_cents'] as int),
    date: m['date'] as String,
    categoryId: m['category_id'] as String?,
    accountId: m['account_id'] as String,
    createdAt: m['created_at'] as String?,
    updatedAt: m['updated_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'type': type,
    'icon': icon,
    'description': description,
    'amount_cents': amountCents,
    'date': date,
    'category_id': categoryId,
    'account_id': accountId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
