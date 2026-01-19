class Budget {
  final String id;
  final String entity;
  final String period;
  final String? targetDate;
  final int limitCents;
  final String? createdAt;
  final String? updatedAt;

  Budget({
    required this.id,
    required this.entity,
    required this.period,
    this.targetDate,
    required this.limitCents,
    this.createdAt,
    this.updatedAt,
  });

  factory Budget.fromMap(Map<String, Object?> m) => Budget(
        id: m['id'] as String,
        entity: m['entity'] as String,
        period: m['period'] as String,
        targetDate: m['target_date'] as String?,
        limitCents: m['limit_cents'] as int,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'entity': entity,
        'period': period,
        'target_date': targetDate,
        'limit_cents': limitCents,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
