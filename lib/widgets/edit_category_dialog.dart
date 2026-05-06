import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/enums/enums.dart';
import 'color_picker.dart';
import 'icon_picker.dart';
import '../view_models/categories_view_model.dart';
import '../domain/models/category.dart';
import '../theme/app_theme.dart';

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  const EditCategoryDialog({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late AccountColor _selectedColor;
  late AccountIcon _selectedIcon;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(text: widget.category.description);
    _isIncome = widget.category.type == 'INCOME';

    try {
      _selectedColor = AccountColor.values.firstWhere((e) => e.name == widget.category.color);
    } catch (_) {
      _selectedColor = AccountColor.GREY;
    }
    
    try {
      _selectedIcon = AccountIcon.values.firstWhere((e) => e.name == widget.category.icon);
    } catch (_) {
      _selectedIcon = AccountIcon.OTHER;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    FocusManager.instance.primaryFocus?.unfocus();

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
              'Editar Categoría',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSizes.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

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

                      final updatedCategory = Category(
                        id: widget.category.id,
                        icon: _selectedIcon.name,
                        color: _selectedColor.name,
                        name: name,
                        description: _descriptionController.text.trim(),
                        type: _isIncome ? 'INCOME' : 'OUTCOME',
                        createdAt: widget.category.createdAt,
                        updatedAt: DateTime.now().toIso8601String(),
                      );

                      try {
                        await Provider.of<CategoriesViewModel>(context, listen: false)
                            .updateCategory(updatedCategory);
                        
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'))
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Actualizar',
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
