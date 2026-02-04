import 'package:flutter/material.dart';
import '../../widgets/accounts_and_categories.dart';
import '../../widgets/income_expenses_home_overview.dart';
import '../../widgets/charts/expenses_category_vertical_bar_chart.dart';
import '../../widgets/total_balance.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/splash/icon.png',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FinTrack',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2, // Altura de texto consistente
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Contenido desplazable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), // Espacio inicial compensando
                const Center(child: TotalBalance()),
                const SizedBox(height: 32),
                const AccountsAndCategories(),
                const SizedBox(height: 32),
                const IncomeExpensesHomeOverview(),
                const SizedBox(height: 32),
                const ExpensesCategoryVerticalBarChart(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


