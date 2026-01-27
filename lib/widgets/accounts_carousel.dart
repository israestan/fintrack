import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/account_screen.dart';
import '../domain/enums.dart';
import '../domain/models/account.dart';
import '../view_models/accounts_view_model.dart';

class AccountsCarousel extends StatelessWidget {
  const AccountsCarousel({super.key});

  String _formatCurrency(int cents) {
    final amount = cents / 100.0;
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tus cuentas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
              },
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Ver y crear cuentas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Consumer<AccountsViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.accounts.isEmpty) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Text('No tienes una cuenta aún'),
                  ),
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vm.accounts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final account = vm.accounts[index];
                  return _AccountCard(
                    account: account,
                    formatter: _formatCurrency,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final String Function(int) formatter;

  const _AccountCard({required this.account, required this.formatter});

  @override
  Widget build(BuildContext context) {
    AccountColor accColor = AccountColor.GREY;
    AccountIcon accIcon = AccountIcon.OTHER;

    try {
      accColor = AccountColor.values.firstWhere((e) => e.name == account.color);
    } catch (_) {}

    try {
      accIcon = AccountIcon.values.firstWhere((e) => e.name == account.icon);
    } catch (_) {}

    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: accColor.toColor.withValues(alpha: 0.2),
                child: Icon(
                  accIcon.toIconData,
                  color: accColor.toColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  account.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatter(account.actualBalanceCents),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
