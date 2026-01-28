import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/enums.dart'; // Reusing AccountColor, AccountIcon
import 'color_picker.dart';
import 'icon_picker.dart';
import '../view_models/categories_view_model.dart';
import '../domain/models/category.dart';

class CreateCategoryDialog extends StatefulWidget {
  final bool initialIsIncome;

  const CreateCategoryDialog({
    super.key,
    required this.initialIsIncome,
  });

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  var _selectedColor = AccountColor.GREY;
  var _selectedIcon = AccountIcon.OTHER;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _isIncome = widget.initialIsIncome;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    FocusManager.instance.primaryFocus?.unfocus();
    //await Future.delayed(const Duration(milliseconds: 50));
    
    if (!mounted) return;

    final picked = await showModalBottomSheet<AccountColor>(
      context: context,
      builder: (_) => const ColorPicker(),
    );
    if (picked != null) {
      setState(() => _selectedColor = picked);
    }
  }

  Future<void> _pickIcon() async {
    FocusManager.instance.primaryFocus?.unfocus();
    //await Future.delayed(const Duration(milliseconds: 50));

    if (!mounted) return;

    final picked = await showModalBottomSheet<AccountIcon>(
      context: context,
      builder: (_) => const IconPicker(),
    );
    if (picked != null) {
      setState(() => _selectedIcon = picked);
    }
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
              'Nueva Categoría',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

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
                          color: _isIncome ? Theme.of(context).primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _isIncome
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
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
                              color: _isIncome ? Colors.white : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ingreso',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _isIncome ? Colors.white : Colors.grey,
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
                          color: !_isIncome ? Theme.of(context).primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !_isIncome
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
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
                              color: !_isIncome ? Colors.white : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gasto',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: !_isIncome ? Colors.white : Colors.grey,
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
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción (Opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickIcon,
                    icon: Icon(_selectedIcon.toIconData, color: _selectedColor.toColor),
                    label: const Text('Icono'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickColor,
                    icon: Icon(Icons.circle, color: _selectedColor.toColor),
                    label: const Text('Color'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

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
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) return; 

                      final newCategory = Category(
                        id: '',
                        icon: _selectedIcon.name,
                        color: _selectedColor.name,
                        name: name,
                        description: _descriptionController.text.trim(),
                        type: _isIncome ? 'INCOME' : 'OUTCOME',
                      );

                      try {
                        await Provider.of<CategoriesViewModel>(context, listen: false)
                            .createCategory(newCategory);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                         // TODO: Handle error
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Guardar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
