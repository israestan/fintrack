import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/enums.dart';
import '../../view_models/categories_view_model.dart';
import '../../view_models/movements_view_model.dart';
import '../../theme/app_theme.dart';

class CategoryExpensesPieChart extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const CategoryExpensesPieChart({super.key, this.dateFrom, this.dateTo});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MovementsViewModel, CategoriesViewModel>(
      builder: (context, movementsVm, categoriesVm, child) {
        // 1. Filter Expenses (and optionally by date range)
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

        if (expenses.isEmpty) {
           return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
             child: const Center(
               child: Text('No hay gastos registrados aÃºn.', style: TextStyle(color: Colors.grey)),
             ),
           );
        }

        // 2. Group by Category ID and Sum Amounts
        final Map<String, double> categoryTotals = {};
        double totalExpenses = 0;

        for (var m in expenses) {
          final catId = m.categoryId ?? 'unknown';
          final amount = m.amountCents / 100.0;
          categoryTotals[catId] = (categoryTotals[catId] ?? 0) + amount;
          totalExpenses += amount;
        }

        if (totalExpenses == 0) return const SizedBox.shrink();

        // 3. Prepare Data for Chart
        final List<_ChartData> chartData = [];
        
        categoryTotals.forEach((catId, amount) {
          String name = 'Sin categorÃ­a';
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

          final percentage = (amount / totalExpenses) * 100;
          chartData.add(_ChartData(
            name: name,
            amount: amount,
            color: color,
            percentage: percentage,
          ));
        });

        chartData.sort((a, b) => b.amount.compareTo(a.amount));

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gastos por CategorÃ­a',
                style: TextStyle(
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // Pie Chart
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: chartData.map((data) {
                      return PieChartSectionData(
                        color: data.color,
                        value: data.amount,
                        title: '${data.percentage.toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Legend
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: chartData.map((data) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: data.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartData {
  final String name;
  final double amount;
  final Color color;
  final double percentage;

  _ChartData({
    required this.name,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}
