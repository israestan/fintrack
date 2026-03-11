import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/models/account.dart';
import '../view_models/accounts_view_model.dart';
import '../domain/models/category.dart';
import '../domain/models/movement.dart';
import '../view_models/categories_view_model.dart';
import '../view_models/movements_view_model.dart';
import '../view_models/transfers_view_model.dart';
import '../domain/enums/enums.dart';

enum TransactionMode { income, outcome, transfer }

extension TransactionModeExt on TransactionMode {
  String get displayName {
    switch (this) {
      case TransactionMode.income:
        return 'Ingreso';
      case TransactionMode.outcome:
        return 'Gasto';
      case TransactionMode.transfer:
        return 'Transferencia';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionMode.income:
        return Icons.input;
      case TransactionMode.outcome:
        return Icons.output;
      case TransactionMode.transfer:
        return Icons.swap_horiz;
    }
  }
}

class CreateMovementScreen extends StatefulWidget {
  const CreateMovementScreen({super.key});

  @override
  State<CreateMovementScreen> createState() => _CreateMovementScreenState();
}

class _CreateMovementScreenState extends State<CreateMovementScreen> {
  TransactionMode _transactionMode = TransactionMode.income;
  Account? _selectedAccount;
  Account? _selectedToAccount;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _amountErrorText; // Nuevo estado para el error de monto
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Pre-select the first account if available and none selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountsVm = Provider.of<AccountsViewModel>(context, listen: false);
      if (accountsVm.accounts.isNotEmpty && _selectedAccount == null) {
        setState(() {
          _selectedAccount = accountsVm.accounts.first;
        });
      }
      
      // Load categories
      Provider.of<CategoriesViewModel>(context, listen: false).loadAll();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMovement() async {
    // 1. Validation
    if (_transactionMode == TransactionMode.transfer) {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una cuenta de origen')),
        );
        return;
      }
      if (_selectedToAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una cuenta de destino')),
        );
        return;
      }
      if (_selectedAccount!.id == _selectedToAccount!.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las cuentas de origen y destino deben ser diferentes')),
        );
        return;
      }
    } else {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una cuenta')),
        );
        return;
      }
    }

    // Parse amount
    final amountString = _amountController.text.trim();
    if (amountString.isEmpty) {
      setState(() {
         _amountErrorText = 'Por favor ingresa un monto superior a 0';
      });
      return;
    }

    final amount = double.tryParse(amountString);
    if (amount == null || amount <= 0) {
      setState(() {
         _amountErrorText = 'El monto debe ser mayor a 0';
      });
      return;
    }
    
    // Si la validación pasa, limpiamos el error
    setState(() {
         _amountErrorText = null;
    });

    // Convert to cents
    final amountCents = (amount * 100).round();

    try {
      if (_transactionMode == TransactionMode.transfer) {
        final transfersVm = Provider.of<TransfersViewModel>(context, listen: false);
        await transfersVm.createTransfer(
          fromAccountId: _selectedAccount!.id,
          toAccountId: _selectedToAccount!.id,
          amountCents: amountCents,
          description: _descriptionController.text.trim(),
          dateIso: _selectedDate.toIso8601String(),
        );

        // Fetch new records so the dashboard reflects the two recent transfer movements  
        if (mounted) {
          Provider.of<MovementsViewModel>(context, listen: false).loadMovements();
        }
      } else {
        // 2. Build Movement Object
        final isIncome = _transactionMode == TransactionMode.income;
        final newMovement = Movement(
          id: '', // Will be generated by repo
          type: isIncome ? 'INCOME' : 'OUTCOME',
          icon: _selectedCategory?.icon ?? (isIncome ? 'wallet_travel' : 'shopping_bag'),
          description: _descriptionController.text.trim(),
          amountCents: amountCents,
          date: _selectedDate.toIso8601String(),
          categoryId: _selectedCategory?.id,
          accountId: _selectedAccount!.id,
        );

        // 3. Save via ViewModel
        final movementsVm = Provider.of<MovementsViewModel>(context, listen: false);
        await movementsVm.addMovement(newMovement);
      }
      
      // 4. Refresh Accounts (to update balance in UI)
      if (mounted) {
        Provider.of<AccountsViewModel>(context, listen: false).loadAccounts();
        Navigator.pop(context); // Go back on success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  void _showCategorySelectionModal() {
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
                  'Selecciona una categoría',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<CategoriesViewModel>(
                    builder: (context, vm, _) {
                      final categories = _transactionMode == TransactionMode.income 
                          ? vm.incomeCategories 
                          : vm.expenseCategories;
                      
                      // Add "No Category" option at the beginning
                      // We build list manually to include it
                      
                      return ListView.separated(
                        controller: controller,
                        itemCount: categories.length + 1, // +1 for "No Category"
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.category_outlined, color: Colors.white),
                              ),
                              title: const Text('Sin categoría', style: TextStyle(fontWeight: FontWeight.w600)),
                              onTap: () {
                                setState(() => _selectedCategory = null);
                                Navigator.pop(context);
                              },
                              trailing: _selectedCategory == null
                                  ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                                  : null,
                            );
                          }

                          final category = categories[index - 1];
                          AccountColor catColor = AccountColor.GREY;
                          AccountIcon catIcon = AccountIcon.OTHER;
                          
                          try {
                            catColor = AccountColor.values.firstWhere((e) => e.name == category.color);
                          } catch (_) {}
                          
                          try {
                            catIcon = AccountIcon.values.firstWhere((e) => e.name == category.icon);
                          } catch (_) {}

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: catColor.toColor.withValues(alpha: 0.2),
                              child: Icon(catIcon.toIconData, color: catColor.toColor),
                            ),
                            title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: category.description.isNotEmpty ? Text(category.description) : null,
                            onTap: () {
                              setState(() => _selectedCategory = category);
                              Navigator.pop(context);
                            },
                            trailing: _selectedCategory?.id == category.id
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

  void _showAccountSelectionModal({bool isToAccount = false}) {
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
                Text(
                  isToAccount ? 'Seleccionar cuenta de destino' : 'Seleccionar cuenta',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        separatorBuilder: (_, _) => const Divider(height: 1),
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

                          final isSelected = isToAccount 
                              ? _selectedToAccount?.id == account.id 
                              : _selectedAccount?.id == account.id;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: accColor.toColor.withValues(alpha: 0.2),
                              child: Icon(accIcon.toIconData, color: accColor.toColor),
                            ),
                            title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('\$${(account.actualBalanceCents / 100.0).toStringAsFixed(2)}'),
                            onTap: () {
                              setState(() {
                                if (isToAccount) {
                                  _selectedToAccount = account;
                                } else {
                                  _selectedAccount = account;
                                }
                              });
                              Navigator.pop(context);
                            },
                            trailing: isSelected
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

  IconData _resolveIcon(String? iconName, IconData defaultIcon) {
    if (iconName == null) return defaultIcon;
    try {
      return AccountIcon.values.firstWhere((e) => e.name == iconName).toIconData;
    } catch (_) {
      return defaultIcon;
    }
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
                  // Transaction Type Toggles
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildModeToggle(
                                title: 'Ingreso',
                                icon: Icons.input,
                                mode: TransactionMode.income,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _buildModeToggle(
                                title: 'Gasto',
                                icon: Icons.output,
                                mode: TransactionMode.outcome,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        _buildModeToggle(
                          title: 'Transferencia',
                          icon: Icons.swap_horiz,
                          mode: TransactionMode.transfer,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      if (_amountErrorText != null)
                        Text(
                          _amountErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
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
                      Expanded(
                        child: Semantics(
                          textField: true,
                          label: 'Monto de la transacción',
                          hint: 'Ingresa el valor numérico',
                          value: _amountController.text,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) {
                              if (_amountErrorText != null) {
                                setState(() {
                                  _amountErrorText = null;
                                });
                              }
                            },
                            style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.00',
                              // El error se muestra visualmente arriba, pero mantenemos esto para semántica y borde
                              errorText: _amountErrorText, 
                              errorStyle: const TextStyle(height: 0, color: Colors.transparent), 
                              hintStyle: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Makes it look active like in design
                              ),
                            ),
                        ),
                      ),
                      ),
                      ],
                  ),

                  const SizedBox(height: 32),

                  if (_transactionMode == TransactionMode.transfer) ...[
                    _buildSelectionTile(
                      label: 'Cuenta de origen',
                      value: _selectedAccount != null
                          ? '${_selectedAccount!.name} (${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_selectedAccount!.actualBalanceCents / 100)})'
                          : 'Selecciona una cuenta',
                      icon: _resolveIcon(_selectedAccount?.icon, Icons.account_balance_wallet_outlined),
                      onTap: () => _showAccountSelectionModal(isToAccount: false),
                      semanticsHint: 'Doble toque para cambiar la cuenta de origen',
                    ),
                    const SizedBox(height: 16),
                    _buildSelectionTile(
                      label: 'Cuenta de destino',
                      value: _selectedToAccount != null
                          ? '${_selectedToAccount!.name} (${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_selectedToAccount!.actualBalanceCents / 100)})'
                          : 'Selecciona una cuenta',
                      icon: _resolveIcon(_selectedToAccount?.icon, Icons.account_balance_wallet_outlined),
                      onTap: () => _showAccountSelectionModal(isToAccount: true),
                      semanticsHint: 'Doble toque para cambiar la cuenta de destino',
                    ),
                  ] else ...[
                    _buildSelectionTile(
                      label: 'Cuenta',
                      value: _selectedAccount != null
                          ? '${_selectedAccount!.name} (${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_selectedAccount!.actualBalanceCents / 100)})'
                          : 'Selecciona una cuenta',
                      icon: _resolveIcon(_selectedAccount?.icon, Icons.account_balance_wallet_outlined),
                      onTap: () => _showAccountSelectionModal(isToAccount: false),
                      semanticsHint: 'Doble toque para cambiar la cuenta seleccionada',
                    ),
                    const SizedBox(height: 16),
                    _buildSelectionTile(
                      label: 'Categoría',
                      value: _selectedCategory?.name ?? 'Sin categoría',
                      icon: _resolveIcon(_selectedCategory?.icon, Icons.local_offer_outlined),
                      onTap: _showCategorySelectionModal,
                      semanticsHint: 'Doble toque para cambiar la categoría',
                    ),
                  ],

                  const SizedBox(height: 16),
                  
                  _buildSelectionTile(
                    label: 'Fecha',
                    value: DateFormat.yMMMd().format(_selectedDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _selectDate(context),
                    semanticsHint: 'Doble toque para cambiar la fecha',
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
                    child: Semantics(
                      textField: true,
                      label: 'Descripción de la transacción',
                      hint: 'Opcional',
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600),
                          hintText: 'Añade una descripción (opcional)',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                        ),
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
                    onPressed: _saveMovement,
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
    String? semanticsHint,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Semantics(
        button: true, //Confirma que es un botón
        label: '$label: $value', //Combina etiqueta y valor para la lectura
        hint: semanticsHint, //Instrucción adicional
        excludeSemantics: true, //Excluye los hijos para evitar lecturas duplicadas e incoherentes
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
      ),
    );
  }

  Widget _buildModeToggle({
    required String title,
    required IconData icon,
    required TransactionMode mode,
  }) {
    final isSelected = _transactionMode == mode;
    return Semantics(
      button: true,
      label: 'Seleccionar tipo $title',
      selected: isSelected,
      hint: 'Toca para cambiar el tipo de movimiento a $title',
      child: GestureDetector(
        onTap: () {
          if (_transactionMode != mode) {
            setState(() {
              _transactionMode = mode;
              if (mode != TransactionMode.transfer) {
                _selectedToAccount = null;
              }
            });
          }
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
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
                icon,
                color: isSelected ? Colors.black : Colors.grey.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.black : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
