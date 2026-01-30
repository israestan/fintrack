import 'package:flutter/material.dart';
import '../../widgets/accounts_carousel.dart';
import '../../widgets/income_expenses_home_overview.dart';
import '../categories_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const AccountsCarousel(),
            const SizedBox(height: 32),
            
          const SizedBox(height: 32),
          const IncomeExpensesHomeOverview(),
          ],
          ),
        ),
      ),
    );
  }
}


