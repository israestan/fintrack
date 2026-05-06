import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../domain/enums/enums.dart';
import '../view_models/goals_view_model.dart';
import '../theme/app_theme.dart';
import 'color_picker.dart';
import 'icon_picker.dart';

class CreateGoalSheet extends StatefulWidget {
  const CreateGoalSheet({super.key});

  @override
  State<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _targetAmountController = TextEditingController();

  AccountColor _selectedColor = AccountColor.TEAL;
  AccountIcon _selectedIcon = AccountIcon.SAVINGS;
  DateTime? _targetDate;

  @override
  void dispose() {
    _nameController.dispose();
    _objectiveController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    final picked = await showModalBottomSheet<AccountColor>(
      context: context,
      builder: (_) => const ColorPicker(),
    );
    if (picked != null) setState(() => _selectedColor = picked);
  }

  Future<void> _pickIcon() async {
    final picked = await showModalBottomSheet<AccountIcon>(
      context: context,
      builder: (_) => const IconPicker(),
    );
    if (picked != null) setState(() => _selectedIcon = picked);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha límite.')),
      );
      return;
    }

    final amountCents =
        (double.parse(_targetAmountController.text) * 100).round();

    try {
      await context.read<GoalsViewModel>().createGoal(
        name: _nameController.text.trim(),
        objective: _objectiveController.text.trim(),
        targetAmountCents: amountCents,
        targetDate: _targetDate!.toIso8601String().substring(0, 10),
        color: _selectedColor.name,
        icon: _selectedIcon.name,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _targetDate == null
        ? 'Seleccionar fecha límite'
        : '${_targetDate!.day.toString().padLeft(2, '0')}/'
            '${_targetDate!.month.toString().padLeft(2, '0')}/'
            '${_targetDate!.year}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  'Nueva meta de ahorro',
                  style: TextStyle(
                    fontSize: AppFontSizes.headline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Color',
                            style: TextStyle(fontSize: AppFontSizes.subtitle)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickColor,
                          customBorder: const CircleBorder(),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: _selectedColor.toColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Icono',
                            style: TextStyle(fontSize: AppFontSizes.subtitle)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickIcon,
                          customBorder: const CircleBorder(),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                _selectedColor.toColor.withValues(alpha: 0.2),
                            child: Icon(
                              _selectedIcon.toIconData,
                              color: _selectedColor.toColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la meta',
                    hintText: 'Ej. Vacaciones, Fondo de emergencia',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
                const SizedBox(height: 14),


                TextFormField(
                  controller: _objectiveController,
                  decoration: const InputDecoration(
                    labelText: 'Objetivo',
                    hintText: 'Describe para qué es esta meta',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Campo requerido'
                      : null,
                ),
                const SizedBox(height: 14),


                TextFormField(
                  controller: _targetAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto objetivo',
                    prefixText: '\$ ',
                    hintText: '0.00',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo requerido';
                    final parsed = double.tryParse(v);
                    if (parsed == null || parsed <= 0) {
                      return 'Ingresa un valor mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),


                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha límite',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 20),
                    ),
                    child: Text(
                      dateLabel,
                      style: TextStyle(
                        color: _targetDate == null
                            ? Colors.grey.shade500
                            : Colors.black87,
                        fontSize: AppFontSizes.subtitle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Guardar
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      fontSize: AppFontSizes.headline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
