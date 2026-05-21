import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_color_presets.dart';
import 'package:expenses_tracker/categories/category_icon_registry.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';

class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({
    super.key,
    this.initialCategory,
    this.isSaving = false,
  });

  final Category? initialCategory;
  final bool isSaving;

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  bool _isIconPickerExpanded = false;
  String _selectedIcon = CategoryIconRegistry.fallback.key;
  Color _selectedColor = CategoryColorPresets.values.first.color;
  bool _hasSelectedColor = false;
  String _iconQuery = '';
  String? _error;

  bool get _isEditMode => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    final category = widget.initialCategory;
    if (category != null) {
      final definition = CategoryIconRegistry.resolve(category.icon);
      _nameController.text = category.name;
      _selectedIcon = definition.key;
      _iconController.text = definition.label;
      _selectedColor = Color(category.color);
      _hasSelectedColor = true;
    } else {
      _iconController.text = CategoryIconRegistry.fallback.label;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedIcon.isEmpty || !_hasSelectedColor) {
      setState(() {
        _error = context.l10n.enterCategoryNameIconColor;
      });
      return;
    }

    final now = DateTime.now();
    final initial = widget.initialCategory;
    Navigator.of(context).pop(
      Category(
        categoryId: initial?.categoryId ?? const Uuid().v1(),
        userId: initial?.userId,
        name: name,
        totalExpenses: initial?.totalExpenses ?? 0,
        icon: _selectedIcon,
        color: _selectedColor.toARGB32(),
        isArchived: initial?.isArchived ?? false,
        createdAt: initial?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        _isEditMode ? context.l10n.editCategory : context.l10n.createCategory,
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  CategoryIconView(
                    iconKey: _selectedIcon,
                    backgroundColor: _selectedColor,
                    size: 48,
                    semanticLabel: context.l10n.selectedCategoryIcon,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        labelText: context.l10n.categoryName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _iconController,
                onTap: () {
                  setState(() {
                    _isIconPickerExpanded = !_isIconPickerExpanded;
                  });
                },
                readOnly: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  labelText: context.l10n.categoryIcon,
                  border: const OutlineInputBorder(),
                  suffixIcon: Icon(
                    _isIconPickerExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
              ),
              if (_isIconPickerExpanded) ...[
                const SizedBox(height: 8),
                _IconPicker(
                  selectedIcon: _selectedIcon,
                  selectedColor: _selectedColor,
                  query: _iconQuery,
                  onQueryChanged: (value) {
                    setState(() => _iconQuery = value);
                  },
                  onSelected: (definition) {
                    setState(() {
                      _selectedIcon = definition.key;
                      _iconController.text = definition.label;
                      _isIconPickerExpanded = false;
                    });
                  },
                ),
              ],
              const SizedBox(height: 16),
              Text(
                context.l10n.categoryColor,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              _ColorPresetGrid(
                selectedColor: _selectedColor,
                onSelected: (color) {
                  setState(() {
                    _selectedColor = color;
                    _hasSelectedColor = true;
                  });
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _showColorPicker,
                icon: const Icon(Icons.palette_outlined),
                label: Text(context.l10n.customColor),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: widget.isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton(
                        onPressed: _submit,
                        child: Text(context.l10n.save),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var draftColor = _selectedColor;
        return AlertDialog(
          title: Text(context.l10n.customColor),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (value) {
                draftColor = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _selectedColor = draftColor;
                  _hasSelectedColor = true;
                });
                Navigator.pop(dialogContext);
              },
              child: Text(context.l10n.saveColor),
            ),
          ],
        );
      },
    );
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selectedIcon,
    required this.selectedColor,
    required this.query,
    required this.onQueryChanged,
    required this.onSelected,
  });

  final String selectedIcon;
  final Color selectedColor;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<CategoryIconDefinition> onSelected;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final definitions = CategoryIconRegistry.definitions.where((definition) {
      if (normalizedQuery.isEmpty) return true;
      return definition.label.toLowerCase().contains(normalizedQuery) ||
          definition.group.toLowerCase().contains(normalizedQuery) ||
          definition.key.toLowerCase().contains(normalizedQuery);
    }).toList();
    final groups = normalizedQuery.isEmpty
        ? CategoryIconRegistry.groups
        : definitions.map((definition) => definition.group).toSet().toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                labelText: context.l10n.searchIcons,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            for (final group in groups) ...[
              Text(
                group,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: definitions
                    .where((definition) => definition.group == group)
                    .map(
                      (definition) => _IconChoice(
                        definition: definition,
                        selected: definition.key == selectedIcon,
                        color: selectedColor,
                        onTap: () => onSelected(definition),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.definition,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final CategoryIconDefinition definition;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: definition.label,
      child: Semantics(
        label: context.l10n.categoryIconSemantics(definition.label),
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExcludeSemantics(
              child: CategoryIconView(
                iconKey: definition.key,
                backgroundColor: color,
                size: 42,
                semanticLabel: definition.label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPresetGrid extends StatelessWidget {
  const _ColorPresetGrid({
    required this.selectedColor,
    required this.onSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CategoryColorPresets.values.map((preset) {
        final selected = preset.color.toARGB32() == selectedColor.toARGB32();
        return Tooltip(
          message: preset.label,
          child: Semantics(
            label: context.l10n.categoryColorSemantics(preset.label),
            button: true,
            selected: selected,
            child: InkWell(
              onTap: () => onSelected(preset.color),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: preset.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: selected ? 3 : 1,
                    color: selected
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check, color: preset.foreground, size: 18)
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
