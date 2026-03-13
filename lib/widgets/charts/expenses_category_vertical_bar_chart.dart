import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/enums.dart';
import '../../theme/app_theme.dart';
import '../../view_models/categories_view_model.dart';
import '../../view_models/movements_view_model.dart';

class ExpensesCategoryVerticalBarChart extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ExpensesCategoryVerticalBarChart({super.key, this.dateFrom, this.dateTo});

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
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'No hay gastos registrados aún.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // 2. Group by Category ID and Sum Amounts
        final Map<String, double> categoryTotals = {};
        double maxAmount = 0;

        for (var m in expenses) {
          final catId = m.categoryId ?? 'unknown';
          final amount = m.amountCents / 100.0;
          categoryTotals[catId] = (categoryTotals[catId] ?? 0) + amount;
          if (categoryTotals[catId]! > maxAmount) {
            maxAmount = categoryTotals[catId]!;
          }
        }

        if (maxAmount == 0) return const SizedBox.shrink();

        // 3. Prepare Data for Chart
        final List<_BarChartData> chartData = [];

        categoryTotals.forEach((catId, amount) {
          String name = 'Sin cat.';
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

          chartData.add(_BarChartData(
            name: name,
            amount: amount,
            color: color,
          ));
        });

        // Sort by amount descending to look cleaner
        chartData.sort((a, b) => b.amount.compareTo(a.amount));

        return Semantics(
          label: 'Gráfico de barras de gastos por categoría',
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gastos por Categoría',
                  style: TextStyle(
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.bold,
                  ),
                  semanticsLabel: 'Gastos por Categoría',
                ),
                const SizedBox(height: 32),
                Semantics(
                  label: 'Detalle del gráfico',
                  excludeSemantics: true, // Ocultamos los detalles internos complejos del gráfico para el lector
                  child: SizedBox(
                    height: 250,
                    child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxAmount * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${chartData[groupIndex].name}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '\$${rod.toY.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value == meta.max || value == meta.min) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                value >= 1000
                                    ? '${(value / 1000).toStringAsFixed(1)}k'
                                    : value.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: AppFontSizes.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= chartData.length) {
                                return const SizedBox.shrink();
                              }
                              final name = chartData[index].name;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  name.length > 5 ? '${name.substring(0, 4)}.' : name,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: AppFontSizes.bodySmall,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxAmount / 5,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.amount,
                              color: data.color,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxAmount * 1.1,
                                color: Colors.grey.shade100,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BarChartData {
  final String name;
  final double amount;
  final Color color;

  _BarChartData({
    required this.name,
    required this.amount,
    required this.color,
  });
}
