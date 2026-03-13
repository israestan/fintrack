import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../view_models/movements_view_model.dart';
import '../../view_models/reports_view_model.dart';

class IncomeExpensesLineChart extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ReportPeriod period;

  const IncomeExpensesLineChart({
    super.key,
    this.dateFrom,
    this.dateTo,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementsViewModel>(
      builder: (context, movementsVm, child) {
        // 1. Filter movements by date range
        final filtered = movementsVm.movements.where((m) {
          if (dateFrom != null || dateTo != null) {
            final date = DateTime.tryParse(m.date);
            if (date == null) return false;
            if (dateFrom != null && date.isBefore(dateFrom!)) return false;
            if (dateTo != null && date.isAfter(dateTo!)) return false;
          }
          return m.type == 'INCOME' || m.type == 'OUTCOME';
        }).toList();

        // 2. Define buckets and labels based on period
        final int bucketCount;
        final List<String> xLabels;

        switch (period) {
          case ReportPeriod.weekly:
            bucketCount = 7;
            xLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
          case ReportPeriod.monthly:
            final daysInMonth = DateUtils.getDaysInMonth(
              dateFrom?.year ?? DateTime.now().year,
              dateFrom?.month ?? DateTime.now().month,
            );
            bucketCount = daysInMonth;
            xLabels = List.generate(daysInMonth, (i) => '${i + 1}');
          case ReportPeriod.yearly:
            bucketCount = 12;
            xLabels = [
              'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
              'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
            ];
        }

        // 3. Aggregate amounts by bucket
        final Map<int, double> incomeBuckets = {};
        final Map<int, double> expenseBuckets = {};

        for (var m in filtered) {
          final date = DateTime.tryParse(m.date);
          if (date == null) continue;

          final int bucket;
          switch (period) {
            case ReportPeriod.weekly:
              bucket = date.weekday - 1; // 0=Mon .. 6=Sun
            case ReportPeriod.monthly:
              bucket = date.day - 1; // 0 .. 30
            case ReportPeriod.yearly:
              bucket = date.month - 1; // 0=Ene .. 11=Dic
          }

          final amount = m.amountCents / 100.0;
          if (m.type == 'INCOME') {
            incomeBuckets[bucket] = (incomeBuckets[bucket] ?? 0) + amount;
          } else {
            expenseBuckets[bucket] = (expenseBuckets[bucket] ?? 0) + amount;
          }
        }

        // 4. Build spots (one per bucket, 0 if no data)
        final incomeSpots = List.generate(
          bucketCount,
          (i) => FlSpot(i.toDouble(), incomeBuckets[i] ?? 0),
        );
        final expenseSpots = List.generate(
          bucketCount,
          (i) => FlSpot(i.toDouble(), expenseBuckets[i] ?? 0),
        );

        final hasData = incomeBuckets.isNotEmpty || expenseBuckets.isNotEmpty;

        // 5. Y-axis scale
        final allValues = [...incomeBuckets.values, ...expenseBuckets.values];
        final maxY = allValues.fold(0.0, (prev, v) => v > prev ? v : prev);
        final chartMaxY = maxY == 0 ? 100.0 : maxY * 1.2;

        return Container(
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
                'Evolución de Ingresos y Gastos',
                style: TextStyle(
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Leyenda
              Row(
                children: [
                  _LegendDot(color: Colors.green.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Ingresos',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _LegendDot(color: Colors.red.shade400),
                  const SizedBox(width: 6),
                  Text(
                    'Gastos',
                    style: TextStyle(
                      fontSize: AppFontSizes.bodySmall,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!hasData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No hay movimientos en este periodo.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (bucketCount - 1).toDouble(),
                      minY: 0,
                      maxY: chartMaxY,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => Colors.blueGrey.shade700,
                          getTooltipItems: (spots) => spots.map((s) {
                            final isIncome = s.barIndex == 0;
                            return LineTooltipItem(
                              '\$${s.y.toStringAsFixed(2)}',
                              TextStyle(
                                color: isIncome
                                    ? Colors.green.shade300
                                    : Colors.red.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: AppFontSizes.bodySmall,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: chartMaxY / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
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
                            reservedSize: 28,
                            interval: _xInterval(bucketCount),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= xLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  xLabels[index],
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: AppFontSizes.bodySmall,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        // Línea de ingresos
                        LineChartBarData(
                          spots: incomeSpots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: Colors.green.shade600,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withValues(alpha: 0.08),
                          ),
                        ),
                        // Línea de gastos
                        LineChartBarData(
                          spots: expenseSpots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: Colors.red.shade400,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _xInterval(int bucketCount) {
    if (bucketCount <= 12) return 1; // semanal (7) y anual (12)
    return 5; // mensual (28-31 días)
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
