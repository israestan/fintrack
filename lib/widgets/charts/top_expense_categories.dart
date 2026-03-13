import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/enums.dart';
import '../../theme/app_theme.dart';
import '../../view_models/categories_view_model.dart';
import '../../view_models/movements_view_model.dart';

class TopExpenseCategories extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const TopExpenseCategories({super.key, this.dateFrom, this.dateTo});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MovementsViewModel, CategoriesViewModel>(
      builder: (context, movementsVm, categoriesVm, child) {
        // 1. Filter OUTCOME movements by date range
        final expenses = movementsVm.movements.where((m) {
          if (m.type != 'OUTCOME') return false;
          if (dateFrom != null || dateTo != null) {
            final date = DateTime.tryParse(m.date);
            if (date == null) return false;
            if (dateFrom != null && date.isBefore(dateFrom!)) return false;
            if (dateTo != null && date.isAfter(dateTo!)) return false;
          }
          return true;
        }).toList();

        final cardDecoration = BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

        if (expenses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration,
            child: const Center(
              child: Text(
                'No hay gastos registrados aún.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // 2. Group by category and sum amounts
        final Map<String, double> categoryTotals = {};
        double totalExpenses = 0;

        for (var m in expenses) {
          final catId = m.categoryId ?? 'unknown';
          final amount = m.amountCents / 100.0;
          categoryTotals[catId] = (categoryTotals[catId] ?? 0) + amount;
          totalExpenses += amount;
        }

        if (totalExpenses == 0) return const SizedBox.shrink();

        // 3. Build sorted list
        final List<_CategoryRow> rows = [];

        categoryTotals.forEach((catId, amount) {
          String name = 'Sin categoría';
          Color color = Colors.grey;

          if (catId != 'unknown') {
            final category = categoriesVm.getCategoryById(catId);
            if (category != null) {
              name = category.name;
              try {
                final accColor = AccountColor.values.firstWhere(
                  (e) => e.name == category.color,
                  orElse: () => AccountColor.GREY,
                );
                color = accColor.toColor;
              } catch (_) {
                color = Colors.grey;
              }
            }
          }

          rows.add(_CategoryRow(
            name: name,
            color: color,
            amount: amount,
            percentage: (amount / totalExpenses) * 100,
          ));
        });

        rows.sort((a, b) => b.amount.compareTo(a.amount));

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Categorías de Gasto',
                style: TextStyle(
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...rows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return _RowItem(
                  rank: index + 1,
                  row: row,
                  isLast: index == rows.length - 1,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _RowItem extends StatelessWidget {
  final int rank;
  final _CategoryRow row;
  final bool isLast;

  const _RowItem({
    required this.rank,
    required this.row,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Rank number
              SizedBox(
                width: 20,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodySmall,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Color dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: row.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              // Category name (expands)
              Expanded(
                child: Text(
                  row.name,
                  style: const TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Percentage pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: row.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${row.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodySmall,
                    color: row.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Amount
              Text(
                '\$${_formatAmount(row.amount)}',
                style: const TextStyle(
                  fontSize: AppFontSizes.subtitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(2);
  }
}

class _CategoryRow {
  final String name;
  final Color color;
  final double amount;
  final double percentage;

  _CategoryRow({
    required this.name,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}
