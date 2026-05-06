import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../domain/models/budget.dart';
import '../domain/models/category.dart';
import '../view_models/budgets_view_model.dart';
import '../view_models/categories_view_model.dart';
import '../data/utils/uuid_util.dart';
import '../theme/app_theme.dart';

class CreateBudgetSheet extends StatefulWidget {
  const CreateBudgetSheet({super.key});

  @override
  State<CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends State<CreateBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();

  String _selectedPeriod = 'monthly';
  final List<String> _selectedCategoryIds = [];

  static const _periods = [
    ('daily', 'Diario'),
    ('weekly', 'Semanal'),
    ('monthly', 'Mensual'),
    ('yearly', 'Anual'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una categoría.')),
      );
      return;
    }

    final budgetsVm = context.read<BudgetsViewModel>();
    final limitCents = (double.parse(_limitController.text) * 100).round();
    final budget = Budget(
      id: generateUuidV4(),
      entity: _nameController.text.trim(),
      period: _selectedPeriod,
      limitCents: limitCents,
    );

    try {
      await budgetsVm.createBudget(budget);
      for (final catId in _selectedCategoryIds) {
        await budgetsVm.addCategoryToBudget(budget.id, catId);
      }
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
    final expenseCategories =
        context.watch<CategoriesViewModel>().expenseCategories;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título del sheet
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Nuevo presupuesto',
                  style: TextStyle(
                    fontSize: AppFontSizes.headline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),


                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej. Alimentación mensual',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),


                TextFormField(
                  controller: _limitController,
                  decoration: const InputDecoration(
                    labelText: 'Límite de gasto',
                    hintText: '0.00',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo requerido';
                    final parsed = double.tryParse(v);
                    if (parsed == null || parsed <= 0) return 'Ingresa un valor válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),


                const Text(
                  'Periodo',
                  style: TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _periods.map((p) {
                    final selected = _selectedPeriod == p.$1;
                    return ChoiceChip(
                      label: Text(p.$2),
                      selected: selected,
                      selectedColor:
                          AppTheme.primaryColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: selected
                            ? AppTheme.primaryColor
                            : Colors.grey.shade700,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedPeriod = p.$1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Categorías a monitorizar',
                  style: TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                expenseCategories.isEmpty
                    ? Text(
                        'No hay categorías de gasto. Crea una primero.',
                        style: TextStyle(
                          fontSize: AppFontSizes.subtitle,
                          color: Colors.grey.shade500,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: expenseCategories.map((Category cat) {
                          final selected =
                              _selectedCategoryIds.contains(cat.id);
                          return FilterChip(
                            label: Text(cat.name),
                            selected: selected,
                            selectedColor:
                                AppTheme.primaryColor.withValues(alpha: 0.15),
                            checkmarkColor: AppTheme.primaryColor,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade700,
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedCategoryIds.add(cat.id);
                                } else {
                                  _selectedCategoryIds.remove(cat.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
