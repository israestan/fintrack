class Category {
  final String id;
  final String? parentId;
  final String icon;
  final String color;
  final String name;
  final String description;
  final String type; // 'INCOME' | 'OUTCOME'
  final String? createdAt;
  final String? updatedAt;

  Category({
    required this.id,
    this.parentId,
    required this.icon,
    required this.color,
    required this.name,
    required this.description,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromMap(Map<String, Object?> m) => Category(
        id: m['id'] as String,
        parentId: m['parent_id'] as String?,
        icon: m['icon'] as String,
        color: m['color'] as String,
        name: m['name'] as String,
        description: m['description'] as String,
        type: m['type'] as String,
        createdAt: m['created_at'] as String?,
        updatedAt: m['updated_at'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'parent_id': parentId,
        'icon': icon,
        'color': color,
        'name': name,
        'description': description,
        'type': type,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
