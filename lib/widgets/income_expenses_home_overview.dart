import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_models/movements_view_model.dart';
import '../domain/models/movement.dart';
import '../theme/app_theme.dart';

class IncomeExpensesHomeOverview extends StatefulWidget {
  const IncomeExpensesHomeOverview({super.key});

  @override
  State<IncomeExpensesHomeOverview> createState() => _IncomeExpensesHomeOverviewState();
}

class _IncomeExpensesHomeOverviewState extends State<IncomeExpensesHomeOverview> {
  bool _isWeekly = true; //true = This Week, false = This Month

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementsViewModel>(
      builder: (context, vm, _) {
        final totals = _calculateTotals(vm.movements);
        final totalIncome = totals['income']!;
        final totalExpense = totals['expense']!;
        final totalFlow = totalIncome + totalExpense;
        
        final safeTotal = totalFlow == 0 ? 1.0 : totalFlow;
        final incomeFlex = (totalIncome / safeTotal * 100).round();
        final expenseFlex = (totalExpense / safeTotal * 100).round();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: AppFontSizes.title,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _PeriodToggle(
                          label: 'Semana',
                          isSelected: _isWeekly,
                          onTap: () => setState(() => _isWeekly = true),
                        ),
                        _PeriodToggle(
                          label: 'Mes',
                          isSelected: !_isWeekly,
                          onTap: () => setState(() => _isWeekly = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Row
              Semantics(
                label: 'Resumen de flujo de caja',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      label: 'Ingresos',
                      amount: totalIncome,
                      color: Colors.green.shade700,
                      icon: Icons.input,
                    ),
                    _StatItem(
                      label: 'Gastos',
                      amount: totalExpense,
                      color: Colors.red.shade700,
                      icon: Icons.output,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Comparison Bar
              Semantics(
                label: 'Barra de comparación visual: Ingresos frente a Gastos',
                excludeSemantics: true, // Ocultamos los detalles internos visuales
                child: totalFlow > 0
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 12,
                          child: Row(
                            children: [
                              if (totalIncome > 0)
                                Expanded(
                                  flex: incomeFlex,
                                  child: Container(color: Colors.green.shade400),
                                ),
                              if (totalExpense > 0)
                                Expanded(
                                  flex: expenseFlex,
                                  child: Container(color: Colors.red.shade400),
                                ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, double> _calculateTotals(List<Movement> movements) {
    double income = 0;
    double expense = 0;

    final now = DateTime.now();
    DateTime start, end;

    if (_isWeekly) {
      // Find Monday of current week
      start = now.subtract(Duration(days: now.weekday - 1));
      // End of Sunday
      end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      // Normalize start to beginning of day
      start = DateTime(start.year, start.month, start.day);
    } else {
      // First day of month
      start = DateTime(now.year, now.month, 1);
      // Last moment of month
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    for (var m in movements) {
      final date = DateTime.parse(m.date);
      // Check if date is within range
      if (date.isAfter(start.subtract(const Duration(seconds: 1))) && 
          date.isBefore(end.add(const Duration(seconds: 1)))) {
        
        final amount = m.amountCents / 100.0;
        if (m.type == 'INCOME') {
          income += amount;
        } else {
          expense += amount;
        }
      }
    }

    return {'income': income, 'expense': expense};
  }
}

class _PeriodToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Ver balance por $label',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey.shade600,
            ),
            semanticsLabel: '', // Ocultamos el texto porque Semantics ya lo lee
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSizes.small,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatted,
          style: TextStyle(
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
