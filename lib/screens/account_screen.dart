import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/enums/enums.dart';
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
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: vm.accounts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final account = vm.accounts[index];
              var color = AccountColor.GREY;
              var icon = AccountIcon.OTHER;
              try {
                color = AccountColor.values.firstWhere(
                  (e) => e.name == account.color,
                );
              } catch (_) {}
              try {
                icon = AccountIcon.values.firstWhere(
                  (e) => e.name == account.icon,
                );
              } catch (_) {}

              return ListTile(
                onTap: () => _showEditDialog(account),
                leading: CircleAvatar(
                  backgroundColor: color.toColor,
                  child: Icon(icon.toIconData, color: Colors.white),
                ),
                title: Text(account.name),
                subtitle: Text('ID: ${account.id.substring(0, 8)}...'),
                trailing: Text(
                  _formatCents(account.actualBalanceCents),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
