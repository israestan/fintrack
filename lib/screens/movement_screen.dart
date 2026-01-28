import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/account.dart';
import '../view_models/accounts_view_model.dart';
import '../domain/enums.dart';

class MovementScreen extends StatefulWidget {
  const MovementScreen({super.key});

  @override
  State<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen> {
  bool _isIncome = true;
  Account? _selectedAccount;
  
  @override
  void initState() {
    super.initState();
    // Pre-select the first account if available and none selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<AccountsViewModel>(context, listen: false);
      if (vm.accounts.isNotEmpty && _selectedAccount == null) {
        setState(() {
          _selectedAccount = vm.accounts.first;
        });
      }
    });
  }

  void _showAccountSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<AccountsViewModel>(
                    builder: (context, vm, _) {
                      if (vm.accounts.isEmpty) {
                        return const Center(child: Text('No accounts available'));
                      }
                      return ListView.separated(
                        controller: controller,
                        itemCount: vm.accounts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final account = vm.accounts[index];
                          AccountColor accColor = AccountColor.GREY;
                          AccountIcon accIcon = AccountIcon.OTHER;
                          
                          try {
                            accColor = AccountColor.values.firstWhere((e) => e.name == account.color);
                          } catch (_) {}
                          
                          try {
                            accIcon = AccountIcon.values.firstWhere((e) => e.name == account.icon);
                          } catch (_) {}

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: accColor.toColor.withValues(alpha: 0.2),
                              child: Icon(accIcon.toIconData, color: accColor.toColor),
                            ),
                            title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('\$${(account.actualBalanceCents / 100.0).toStringAsFixed(2)}'),
                            onTap: () {
                              setState(() => _selectedAccount = account);
                              Navigator.pop(context);
                            },
                            trailing: _selectedAccount?.id == account.id
                                ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Añadir movimiento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Income / Expense Toggle
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isIncome = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isIncome ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isIncome
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.input,
                                    color: _isIncome ? Colors.black : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ingreso',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _isIncome ? Colors.black : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isIncome = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isIncome ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isIncome
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.output,
                                    color: !_isIncome ? Colors.black : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Gasto',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: !_isIncome ? Colors.black : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Monto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Makes it look active like in design
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _buildSelectionTile(
                    label: 'Cuenta',
                    value: _selectedAccount?.name ?? 'Selecciona una cuenta',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: _showAccountSelectionModal,
                  ),
                  
                  const SizedBox(height: 16),

                  _buildSelectionTile(
                    label: 'Categoría',
                    value: 'Salary', // Assuming Income for example, or based on default
                    icon: Icons.local_offer_outlined,
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  
                  _buildSelectionTile(
                    label: 'Fecha',
                    value: 'Nov 30, 2025',
                    icon: Icons.calendar_today_outlined,
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: const TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.edit_outlined, color: Colors.grey),
                        hintText: 'Añade una descripción (opcional)',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
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
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                         fontWeight: FontWeight.w600,
                         fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Guardar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade600),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
