import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class MonthComparisonCard extends StatelessWidget {
  final ExpenseReport report;

  const MonthComparisonCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final isIncrease = report.deltaPercent > 0;
    final deltaColor =
        isIncrease ? Theme.of(context).colorScheme.error : Colors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.periodComparison,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.currentAmountLabel(
              formatAmountWithCurrency(report.total, report.currency),
            ),
          ),
          Text(
            context.l10n.previousAmountLabel(
              formatAmountWithCurrency(report.previousTotal, report.currency),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isIncrease ? '+' : ''}${report.deltaPercent.toStringAsFixed(0)}%',
            style: TextStyle(
              color: deltaColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
