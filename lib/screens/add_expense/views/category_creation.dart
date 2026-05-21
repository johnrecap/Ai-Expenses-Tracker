import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/categories/widgets/category_form_dialog.dart';
import 'package:flutter/material.dart';

Future<Category?> getCategoryCreation(BuildContext context) async {
  return showDialog<Category>(
    context: context,
    builder: (_) => const CategoryFormDialog(),
  );
}
