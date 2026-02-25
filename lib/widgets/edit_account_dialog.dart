import 'package:flutter/material.dart';
import '../domain/enums/enums.dart';
import '../domain/models/account.dart';
import '../domain/models/bank_account.dart';
import 'color_picker.dart';
import 'icon_picker.dart';
import '../theme/app_theme.dart';

class EditAccountDialog extends StatefulWidget {
  final Account account;
  final BankAccount? bankDetails;

  const EditAccountDialog({
    super.key, 
    required this.account,
    this.bankDetails,
  });

  @override
  State<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<EditAccountDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _actualBalanceController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  
  var _selectedColor = AccountColor.GREY;
  var _selectedIcon = AccountIcon.OTHER;
  var _selectedType = AccountType.CASH;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    _nameController = TextEditingController(text: acc.name);
    _balanceController = TextEditingController(text: (acc.initialBalanceCents / 100.0).toStringAsFixed(2));
    _actualBalanceController = TextEditingController(text: (acc.actualBalanceCents / 100.0).toStringAsFixed(2));
    
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();

    try { _selectedColor = AccountColor.values.firstWhere((e) => e.name == acc.color); } catch(_) {}
    try { _selectedIcon = AccountIcon.values.firstWhere((e) => e.name == acc.icon); } catch(_) {}
    try { _selectedType = AccountType.values.firstWhere((e) => e.name == acc.typeId); } catch(_) {}

    if (widget.bankDetails != null) {
      _bankNameController.text = widget.bankDetails!.bankName;
      _accountNumberController.text = widget.bankDetails!.number;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _actualBalanceController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'El nombre es requerido';
      });
      return;
    }

    final newAccount = Account(
      id: widget.account.id,
      name: name,
      color: _selectedColor.name,
      icon: _selectedIcon.name,
      initialBalanceCents: widget.account.initialBalanceCents,
      actualBalanceCents: widget.account.actualBalanceCents,
      active: widget.account.active,
      typeId: _selectedType.name,
    );
    
    final Map<String, dynamic> result = {
      'action': 'update',
      'account': newAccount,
    };

    if (_selectedType == AccountType.SAVINGS_ACCOUNT || _selectedType == AccountType.CURRENT_ACCOUNT) {
      result['bank_name'] = _bankNameController.text.trim();
      result['number'] = _accountNumberController.text.trim();
    }

    Navigator.of(context).pop(result);
  }

  void _delete() {
    Navigator.of(context).pop({
      'action': 'delete',
      'account': widget.account,
    });
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: AppFontSizes.bodySmall)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value, style: const TextStyle(fontSize: AppFontSizes.body, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información', style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _readOnlyField('Tipo de Cuenta', _selectedType.displayName),
                    const SizedBox(height: 6),
                    _readOnlyField('Balance inicial', '\$ ${_balanceController.text}'),
                    const SizedBox(height: 6),
                    _readOnlyField('Balance actual', '\$ ${_actualBalanceController.text}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Editar cuenta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar cuenta'),
                        content: const Text('¿Estás seguro de que quieres eliminar esta cuenta?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _delete();
                            },
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Color', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showModalBottomSheet<AccountColor>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) => const ColorPicker(),
                        );
                        if (picked != null) {
                          setState(() => _selectedColor = picked);
                        }
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: _selectedColor.toColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Ícono', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showModalBottomSheet<AccountIcon>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) => const IconPicker(),
                        );
                        if (picked != null) {
                          setState(() => _selectedIcon = picked);
                        }
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        child: Icon(_selectedIcon.toIconData,
                            color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la cuenta',
                border: const OutlineInputBorder(),
                errorText: _nameError,
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                if (_nameError != null && value.isNotEmpty) {
                  setState(() {
                    _nameError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            if (_selectedType == AccountType.SAVINGS_ACCOUNT || _selectedType == AccountType.CURRENT_ACCOUNT) ...[
              TextField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Banco',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Cuenta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
