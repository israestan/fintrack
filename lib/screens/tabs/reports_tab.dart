import 'package:flutter/material.dart';
import '../../widgets/category_expenses_pie_chart.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Definir altura consistente para Headers
    const double headerHeight = 60.0;
    final Color headerColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white;

    return Column(
      children: [
        // Header Consistente que cubre el StatusBar
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
            child: Container(
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
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const CategoryExpensesPieChart(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
