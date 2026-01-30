import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../domain/models/movement.dart';
import '../view_models/movements_view_model.dart';
import '../view_models/accounts_view_model.dart';

class MovementDetails extends StatelessWidget {
  final Movement movement;
  final String categoryName;
  final String accountName;
  final IconData iconData;
  final Color iconColor;

  const MovementDetails({
    super.key,
    required this.movement,
    required this.categoryName,
    required this.accountName,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = movement.type == 'INCOME';
    final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade700;
    final amountSymbol = isIncome ? '+' : '-';
    final formattedAmount = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(movement.amountCents / 100);

    // Format Date: e.g., "5 de noviembre, 2023 - 14:30"
    // Using default locale or specifically Spanish if set in main
    final dateObj = DateTime.parse(movement.date);
    final formattedDate = DateFormat.yMMMMd('es').add_jm().format(dateObj);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle for dragging visual cue
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header: Icon + Amount + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$amountSymbol$formattedAmount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),

          if (movement.description != null &&
              movement.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: iconColor, width: 4),
                ),
              ),
              child: Text(
                movement.description!,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Details Section
          _buildDetailRow(Icons.calendar_today, 'Fecha', formattedDate),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.account_balance_wallet, 'Cuenta', accountName),
          const SizedBox(height: 16),
          _buildDetailRow(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            'Tipo',
            isIncome ? 'Ingreso' : 'Gasto',
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Salir',
                    style: TextStyle( color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar Movimiento'),
                        content: const Text(
                            '¿Estás seguro de que deseas eliminar este movimiento? El saldo de la cuenta será actualizado.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      try {
                        final msgVm = Provider.of<MovementsViewModel>(context, listen: false);
                        final accVm = Provider.of<AccountsViewModel>(context, listen: false);

                        await msgVm.deleteMovement(movement);
                        // Refresh accounts to reflect balance change
                        await accVm.loadAccounts();

                        if (context.mounted) {
                          Navigator.pop(context); // Close BottomSheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Movimiento eliminado correctamente')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al eliminar: $e')),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Eliminar'),
                ),
              ),
            ],
          ),
          
          // Safety padding for bottom notch on iPhones
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
