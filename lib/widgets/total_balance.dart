import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_models/accounts_view_model.dart';
import '../theme/app_theme.dart';

class TotalBalance extends StatelessWidget {
  const TotalBalance({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountsViewModel>(
      builder: (context, vm, _) {
        final totalCents = vm.accounts.fold<int>(
          0,
          (sum, account) => sum + account.actualBalanceCents,
        );
        final totalAmount = totalCents / 100.0;
        final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

        return Semantics(
          label: 'Balance Total: ${formatter.format(totalAmount)}',
          header: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Balance Total',
                style: TextStyle(
                  fontSize: AppFontSizes.subtitle,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                semanticsLabel: '', // Ocultamos este texto individual porque ya lo lee el padre
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(totalAmount),
                style: const TextStyle(
                  fontSize: AppFontSizes.display, 
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -1.0,
                ),
                semanticsLabel: '', // Ocultamos este texto individual porque ya lo lee el padre
              ),
            ],
          ),
        );
      },
    );
  }
}
