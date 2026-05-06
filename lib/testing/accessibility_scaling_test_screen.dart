import 'package:flutter/material.dart';
import '../widgets/total_balance.dart';
import '../widgets/income_expenses_home_overview.dart';

class AccessibilityScalingTestScreen extends StatefulWidget {
  const AccessibilityScalingTestScreen({super.key});

  @override
  State<AccessibilityScalingTestScreen> createState() => _AccessibilityScalingTestScreenState();
}

class _AccessibilityScalingTestScreenState extends State<AccessibilityScalingTestScreen> {
  bool _isScaled = false;

  @override
  Widget build(BuildContext context) {
    final textScaler = TextScaler.linear(_isScaled ? 2.0 : 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Accesibilidad'),
        actions: [
          Row(
            children: [
              const Text('200%', style: TextStyle(fontSize: 12)),
              Switch(
                value: _isScaled,
                onChanged: (val) => setState(() => _isScaled = val),
                activeThumbColor: Colors.white,
              ),
            ],
          )
        ],
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vista Real de FinTrack',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Center(child: TotalBalance()),
              const SizedBox(height: 32),
              const IncomeExpensesHomeOverview(),
            ],
          ),
        ),
      ),
    );
  }
}
