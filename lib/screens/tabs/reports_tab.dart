import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/reports_view_model.dart';
import '../../widgets/charts/category_expenses_pie_chart.dart';
import '../../widgets/charts/income_expenses_line_chart.dart';
import '../../widgets/charts/period_income_expenses_summary.dart';
import '../../widgets/charts/top_expense_categories.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 60.0;
    final Color headerColor =
        Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Colors.white;

    return Column(
      children: [
        // Header con título + selector de periodo
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: headerColor,
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Container(
                  height: headerHeight,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Reportes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                // Selector de periodo
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Consumer<ReportsViewModel>(
                    builder: (context, vm, _) => _PeriodToggle(
                      selected: vm.period,
                      onSelected: (p) =>
                          context.read<ReportsViewModel>().setPeriod(p),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Consumer<ReportsViewModel>(
            builder: (context, vm, _) => SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  PeriodIncomeExpensesSummary(
                    dateFrom: vm.dateFrom,
                    dateTo: vm.dateTo,
                  ),
                  const SizedBox(height: 16),
                  IncomeExpensesLineChart(
                    dateFrom: vm.dateFrom,
                    dateTo: vm.dateTo,
                    period: vm.period,
                  ),
                  const SizedBox(height: 16),
                  CategoryExpensesPieChart(
                    dateFrom: vm.dateFrom,
                    dateTo: vm.dateTo,
                  ),
                  const SizedBox(height: 16),
                  TopExpenseCategories(
                    dateFrom: vm.dateFrom,
                    dateTo: vm.dateTo,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onSelected;

  const _PeriodToggle({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _option(ReportPeriod.weekly, 'Semanal'),
          _option(ReportPeriod.monthly, 'Mensual'),
          _option(ReportPeriod.yearly, 'Anual'),
        ],
      ),
    );
  }

  Widget _option(ReportPeriod period, String label) {
    final isSelected = selected == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
