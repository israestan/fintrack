class Account {
  final String id;
  final String name;
  final String color;
  final String icon;
  final String? description;
  final int initialBalanceCents;
  final int actualBalanceCents;
  final int active; // 0 or 1
  final String typeId;
  final String? createdAt;
  final String? updatedAt;

  Account({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.description,
    required this.initialBalanceCents,
    required this.actualBalanceCents,
    required this.active,
    required this.typeId,
    this.createdAt,
    this.updatedAt,
  });

  factory Account.fromMap(Map<String, Object?> m) => Account(
    id: m['id'] as String,
    name: m['name'] as String,
    color: m['color'] as String,
    icon: m['icon'] as String,
    description: m['description'] as String?,
    initialBalanceCents: (m['initial_balance_cents'] as int),
    actualBalanceCents: (m['actual_balance_cents'] as int),
    active: (m['active'] as int),
    typeId: m['type_id'] as String,
    createdAt: m['created_at'] as String?,
    updatedAt: m['updated_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'color': color,
    'icon': icon,
    'description': description,
    'initial_balance_cents': initialBalanceCents,
    'actual_balance_cents': actualBalanceCents,
    'active': active,
    'type_id': typeId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
