import 'package:fintrack/screens/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../screens/account_screen.dart';
import '../domain/enums/enums.dart';
import '../domain/models/account.dart';
import '../domain/models/movement.dart';
import '../view_models/accounts_view_model.dart';
import '../view_models/movements_view_model.dart';
import '../theme/app_theme.dart';

class AccountsAndCategories extends StatelessWidget {
  const AccountsAndCategories({super.key});

  String _formatCurrency(int cents) {
    final amount = cents / 100.0;
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sección de cuentas y categorías',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus cuentas y categorías',
            style: TextStyle(fontSize: AppFontSizes.title, fontWeight: FontWeight.bold),
            semanticsLabel: 'Tus cuentas y categorías',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
          builder: (context, constraints) {
            // Check if we have enough width for side-by-side buttons
            // A rough heuristic: if width < 300 or text scale is > 1.5, start stacking
            // Or better: let Wrap handle it naturally.
            // But we want them to be full width when stacked, and shared width when side-by-side.
            // Responsive approach using Wrap with constrained children:

            final width = constraints.maxWidth;
            
            // If itemWidth is too small for content, Wrap will push second item down?
            // No, Custom 'Flow' or just Wrap.
            // Let's use a Wrap where children try to be 48% but if text breaks, they wrap?
            // Actually, the user asked for "when text overflows".
            // Since we use Expanded in Row currently, text overflow means text wrapping inside the button or elipsis.
            // To detect overflow *before* rendering is hard. 
            // Better strategy: switch to Column if textScaleFactor is high or screen is narrow.
            
            // ignore: deprecated_member_use
            final textScale = MediaQuery.of(context).textScaleFactor;
            final bool useColumn = textScale > 1.3 || width < 320;

            if (useColumn) {
               return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
                    },
                    icon: const Icon(Icons.account_balance_wallet, size: 20),
                    label: const Text('Cuentas', textAlign: TextAlign.center),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                       Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                      );
                    },
                    icon: const Icon(Icons.category, size: 20),
                    label: const Text('Categorías', textAlign: TextAlign.center),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
               );
            }

            return Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => const AccountScreen()));
                    },
                    icon: const Icon(Icons.account_balance_wallet, size: 20),
                    label: const Text('Cuentas'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                       Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                      );
                    },
                    icon: const Icon(Icons.category, size: 20),
                    label: const Text('Categorías'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            );
          }
        ),
        const SizedBox(height: 16),
        // Usamos IntrinsicHeight para que el contenedor se adapte a la altura de la tarjeta más alta
        IntrinsicHeight(
          child: Consumer2<AccountsViewModel, MovementsViewModel>(
            builder: (context, accountsVm, movementsVm, child) {
              if (accountsVm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (accountsVm.accounts.isEmpty) {
                return Container(
                  width: double.infinity,
                  height: 120, // Altura mínima para el estado vacío
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
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(accountsVm.accounts.length, (index) {
                    final account = accountsVm.accounts[index];
                    
                    // Obtener último movimiento
                    final accountMovements = movementsVm.movements
                        .where((m) => m.accountId == account.id)
                        .toList();
                    
                    accountMovements.sort((a, b) => b.date.compareTo(a.date));
                    final lastMovement = accountMovements.isNotEmpty 
                        ? accountMovements.first 
                        : null;

                    final card = _AccountCard(
                      account: account,
                      formatter: _formatCurrency,
                      lastMovement: lastMovement,
                    );

                    if (index == accountsVm.accounts.length - 1) {
                      return card;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: card,
                    );
                  }),
                ),
              );
            },
          ),
        ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final String Function(int) formatter;
  final Movement? lastMovement;

  const _AccountCard({
    required this.account, 
    required this.formatter,
    this.lastMovement,
  });

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

    return Semantics(
      label: 'Cuenta: ${account.name}, Balance: ${formatter(account.actualBalanceCents)}',
      button: true,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    semanticsLabel: '', // Oculto, ya lo lee el padre
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              formatter(account.actualBalanceCents),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
              semanticsLabel: '', // Oculto, ya lo lee el padre
            ),
            const SizedBox(height: 4),
            _buildLastMovementInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildLastMovementInfo() {
    if (lastMovement == null) {
      return Semantics(
        label: 'Sin movimientos recientes',
        child: const Text(
          'Sin movimientos',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          semanticsLabel: '', // Oculto, ya lo lee el padre
        ),
      );
    }

    final isIncome = lastMovement!.type == 'INCOME';
    final amount = lastMovement!.amountCents / 100.0;
    final amountStr = NumberFormat.simpleCurrency(decimalDigits: 2).format(amount);
    final color = isIncome ? Colors.green[700] : Colors.red[700];
    final prefix = isIncome ? '+' : '-';
    final tipoMovimiento = isIncome ? 'Ingreso' : 'Gasto';

    return Semantics(
      label: 'Último movimiento: $tipoMovimiento de $amountStr, ${lastMovement!.description ?? ''}',
      child: Row(
        children: [
          Icon(
            isIncome ? Icons.input : Icons.output,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '$prefix$amountStr ${lastMovement!.description ?? ''}',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              semanticsLabel: '', // Oculto, ya lo lee el padre
            ),
          ),
        ],
      ),
    );
  }
}
