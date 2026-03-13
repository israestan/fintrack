class BudgetCategory {
  final String budgetId;
  final String categoryId;
  final String? createdAt;
  final String? updatedAt;

  BudgetCategory({
    required this.budgetId,
    required this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  factory BudgetCategory.fromMap(Map<String, Object?> m) => BudgetCategory(
    budgetId: m['budget_id'] as String,
    categoryId: m['category_id'] as String,
    createdAt: m['created_at'] as String?,
    updatedAt: m['updated_at'] as String?,
  );

  Map<String, Object?> toMap() => {
    'budget_id': budgetId,
    'category_id': categoryId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
