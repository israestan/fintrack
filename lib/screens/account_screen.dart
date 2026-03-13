import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/enums/enums.dart';
import '../theme/app_theme.dart';
import '../view_models/accounts_view_model.dart';
import '../domain/models/account.dart';
import '../domain/models/bank_account.dart';
import '../widgets/create_account_dialog.dart';
import '../widgets/edit_account_dialog.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountsViewModel>().loadAccounts();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatCents(int cents) {
    final d = cents / 100.0;
    return '\$${d.toStringAsFixed(2)}';
  }

  Future<void> _showCreateDialog() async {
    if (!mounted) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateAccountDialog(),
    );

    if (result != null && mounted) {
      final account = result['account'] as Account;
      final bankDetails = result['bank_name'] != null
          ? {
              'bank_name': result['bank_name'] as String,
              'number': result['number'] as String,
            }
          : null;

      try {
        await context.read<AccountsViewModel>().createAccount(
          account,
          bankDetails: bankDetails,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta creada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al crear cuenta: $e')));
        }
      }
    }
  }

  Future<void> _showEditDialog(Account account) async {
    BankAccount? bankDetails;
    try {
      bankDetails = await context.read<AccountsViewModel>().getBankAccount(
        account.id,
      );
    } catch (_) {}

    if (!mounted) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          EditAccountDialog(account: account, bankDetails: bankDetails),
    );

    if (result != null && mounted) {
      final action = result['action'] as String;
      final updatedAccount = result['account'] as Account;

      try {
        final vm = context.read<AccountsViewModel>();

        if (action == 'delete') {
          await vm.deleteAccount(updatedAccount.id);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Cuenta eliminada')));
          }
        } else if (action == 'update') {
          // Check for bank details
          final bankData = result['bank_name'] != null
              ? {
                  'bank_name': result['bank_name'] as String,
                  'number': result['number'] as String,
                }
              : null;

          await vm.updateAccount(updatedAccount, bankDetails: bankData);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Cuenta actualizada')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(),
            tooltip: 'Crear cuenta',
          ),
        ],
      ),
      body: Consumer<AccountsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }
          if (vm.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No tienes cuentas registradas'),
                  TextButton(
                    onPressed: _showCreateDialog,
                    child: const Text('Crear mi primera cuenta'),
                  ),
                ],
              ),
            );
          }

          const typeOrder = [
            AccountType.CASH,
            AccountType.CREDIT_CARD,
            AccountType.SAVINGS_ACCOUNT,
            AccountType.CURRENT_ACCOUNT,
            AccountType.GOAL,
            AccountType.DEBT,
            AccountType.LOAN,
            AccountType.BUDGET,
          ];

          final grouped = <AccountType, List<Account>>{};
          for (final account in vm.accounts) {
            AccountType type = AccountType.CASH;
            try {
              type = AccountType.values.firstWhere(
                (e) => e.name == account.typeId,
              );
            } catch (_) {}
            grouped.putIfAbsent(type, () => []).add(account);
          }

          final slivers = <Widget>[
            SliverToBoxAdapter(
              child: _SummaryCard(
                accounts: vm.accounts,
                formatCents: _formatCents,
              ),
            ),
          ];

          for (final type in typeOrder) {
            final group = grouped[type];
            if (group == null || group.isEmpty) continue;
            slivers.add(SliverToBoxAdapter(child: _SectionHeader(type: type)));
            slivers.add(SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _AccountTile(
                  account: group[index],
                  formatCents: _formatCents,
                  onTap: () => _showEditDialog(group[index]),
                ),
                childCount: group.length,
              ),
            ));
          }

          return CustomScrollView(slivers: slivers);
        },
      ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.accounts, required this.formatCents});
  final List<Account> accounts;
  final String Function(int) formatCents;

  @override
  Widget build(BuildContext context) {
    final total = accounts.fold<int>(0, (sum, a) => sum + a.actualBalanceCents);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance total',
                    style: TextStyle(
                      fontSize: AppFontSizes.subtitle,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCents(total),
                    style: TextStyle(
                      fontSize: AppFontSizes.headline,
                      fontWeight: FontWeight.bold,
                      color: total >= 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.type});
  final AccountType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(type.toIconData, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            type.displayName,
            style: TextStyle(
              fontSize: AppFontSizes.subtitle,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.formatCents,
    required this.onTap,
  });

  final Account account;
  final String Function(int) formatCents;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var color = AccountColor.GREY;
    var icon = AccountIcon.OTHER;
    AccountType type = AccountType.CASH;
    try {
      color = AccountColor.values.firstWhere((e) => e.name == account.color);
    } catch (_) {}
    try {
      icon = AccountIcon.values.firstWhere((e) => e.name == account.icon);
    } catch (_) {}
    try {
      type = AccountType.values.firstWhere((e) => e.name == account.typeId);
    } catch (_) {}

    final balance = account.actualBalanceCents;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: color.toColor,
            child: Icon(icon.toIconData, color: Colors.white, size: 20),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ],
              ),
              child: Icon(
                type.toIconData,
                size: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        account.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        type.displayName,
        style: TextStyle(
          fontSize: AppFontSizes.bodySmall,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Text(
        formatCents(balance),
        style: TextStyle(
          fontSize: AppFontSizes.subtitle,
          fontWeight: FontWeight.bold,
          color: balance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }
}
