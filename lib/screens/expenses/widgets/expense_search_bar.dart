import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class ExpenseSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ExpenseSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      hint: context.l10n.searchExpenses,
      prefixIcon: Icons.search,
      suffix: controller.text.isEmpty
          ? null
          : IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              tooltip: context.l10n.clearSearch,
            ),
    );
  }
}
