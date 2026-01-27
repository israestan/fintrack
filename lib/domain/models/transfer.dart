class Transfer {
  final String id;
  final String incomeMovementId;
  final String outcomeMovementId;
  final String? createdAt;
  final String? updatedAt;

  Transfer({
    required this.id,
    required this.incomeMovementId,
    required this.outcomeMovementId,
    this.createdAt,
    this.updatedAt,
  });

  factory Transfer.fromMap(Map<String, Object?> m) => Transfer(
    id: m['id'] as String,
    incomeMovementId: m['income_movement_id'] as String,
    outcomeMovementId: m['outcome_movement_id'] as String,
    createdAt: m['created_at'] as String?,
    updatedAt: m['updated_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'income_movement_id': incomeMovementId,
    'outcome_movement_id': outcomeMovementId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
