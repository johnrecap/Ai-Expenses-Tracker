import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/reports/views/reports_screen.dart';
import 'package:flutter/material.dart';

class StatScreen extends StatelessWidget {
  final List<Expense> expenses;
  final UserSettings? settings;

  const StatScreen({
    super.key,
    required this.expenses,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return ReportsScreen(
      expenses: expenses,
      settings: settings,
    );
  }
}
