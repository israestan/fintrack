import 'package:flutter/material.dart';
import '../domain/enums.dart';
import '../domain/models/account.dart';
import 'color_picker.dart';
import 'icon_picker.dart';

class CreateAccountDialog extends StatefulWidget {
  const CreateAccountDialog({super.key});

  @override
  State<CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<CreateAccountDialog> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  // Estado local del formulario
  var _selectedColor = AccountColor.GREY;
  var _selectedIcon = AccountIcon.OTHER;
  var _selectedType = AccountType.CASH;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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

    final balanceText = _balanceController.text.trim();
    int cents = 0;
    try {
      if (balanceText.isNotEmpty) {
        final value = double.parse(balanceText.replaceAll(',', '.'));
        cents = (value * 100).round();
      }
    } catch (_) {
      cents = 0;
    }

    final newAccount = Account(
      id: '',
      name: name,
      color: _selectedColor.name,
      icon: _selectedIcon.name,
      initialBalanceCents: cents,
      actualBalanceCents: cents,
      active: 1,
      typeId: _selectedType.name,
    );

    // Preparar resultado
    final Map<String, dynamic> result = {
      'action': 'create',
      'account': newAccount,
    };

    if (_selectedType == AccountType.SAVINGS_ACCOUNT ||
        _selectedType == AccountType.CURRENT_ACCOUNT) {
      result['bank_name'] = _bankNameController.text.trim();
      result['number'] = _accountNumberController.text.trim();
    }

    Navigator.of(context).pop(result);
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Crear nueva cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
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
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
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
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
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
                        child: Icon(
                          _selectedIcon.toIconData,
                          color: Colors.black87,
                        ),
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
            DropdownButtonFormField<AccountType>(
              initialValue: _selectedType, 
              decoration: const InputDecoration(
                labelText: 'Tipo de Cuenta',
                border: OutlineInputBorder(),
              ),
              items: AccountType.values
                  .where(
                    (type) =>
                        type == AccountType.CASH ||
                        type == AccountType.SAVINGS_ACCOUNT ||
                        type == AccountType.CURRENT_ACCOUNT,
                  )
                  .map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  })
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedType = val);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_selectedType == AccountType.SAVINGS_ACCOUNT ||
                _selectedType == AccountType.CURRENT_ACCOUNT) ...[
              TextField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Banco',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Cuenta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Balance inicial',
                hintText: 'Ej: 500.00',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
