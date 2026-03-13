import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../view_models/movements_view_model.dart';

class PeriodIncomeExpensesSummary extends StatelessWidget {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const PeriodIncomeExpensesSummary({super.key, this.dateFrom, this.dateTo});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovementsViewModel>(
      builder: (context, vm, _) {
        // 1. Aggregate totals for the period
        double totalIncome = 0;
        double totalExpense = 0;

        for (var m in vm.movements) {
          if (dateFrom != null || dateTo != null) {
            final date = DateTime.tryParse(m.date);
            if (date == null) continue;
            if (dateFrom != null && date.isBefore(dateFrom!)) continue;
            if (dateTo != null && date.isAfter(dateTo!)) continue;
          }
          final amount = m.amountCents / 100.0;
          if (m.type == 'INCOME') {
            totalIncome += amount;
          } else if (m.type == 'OUTCOME') {
            totalExpense += amount;
          }
        }

        final netBalance = totalIncome - totalExpense;
        final totalFlow = totalIncome + totalExpense;
        final safeTotal = totalFlow == 0 ? 1.0 : totalFlow;
        final incomeFlex = (totalIncome / safeTotal * 100).round();
        final expenseFlex = (totalExpense / safeTotal * 100).round();

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
                'Resumen del Periodo',
                style: TextStyle(
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Income / Expense figures
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Ingresos',
                      amount: totalIncome,
                      color: Colors.green.shade700,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: Colors.grey.shade100,
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Gastos',
                      amount: totalExpense,
                      color: Colors.red.shade700,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Comparison bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: totalFlow > 0
                    ? SizedBox(
                        height: 8,
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
                      )
                    : Container(
                        height: 8,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                      ),
              ),

              const SizedBox(height: 20),

              // Net balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo neto',
                    style: TextStyle(
                      fontSize: AppFontSizes.subtitle,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${netBalance >= 0 ? '+' : ''}\$${_formatAmount(netBalance.abs())}',
                    style: TextStyle(
                      fontSize: AppFontSizes.headline,
                      fontWeight: FontWeight.bold,
                      color: netBalance >= 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSizes.bodySmall,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${_formatAmount(amount)}',
            style: TextStyle(
              fontSize: AppFontSizes.headline,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
