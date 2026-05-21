import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final List<CategoryReportTotal> categories;
  final ValueChanged<CategoryReportTotal>? onCategoryTap;

  const CategoryBreakdownChart({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Text(context.l10n.noCategorySpendingYet);
    }

    final visibleCategories = categories.take(5).toList(growable: false);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: visibleCategories.map((category) {
                return PieChartSectionData(
                  value: category.total,
                  title: category.categoryName,
                  radius: 52,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  color: Color(category.categoryColor == 0
                      ? Colors.blue.toARGB32()
                      : category.categoryColor),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final category in visibleCategories)
          _CategoryBreakdownRow(
            category: category,
            onTap:
                onCategoryTap == null ? null : () => onCategoryTap!(category),
          ),
      ],
    );
  }
}

class _CategoryBreakdownRow extends StatelessWidget {
  const _CategoryBreakdownRow({
    required this.category,
    required this.onTap,
  });

  final CategoryReportTotal category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(
      category.categoryColor == 0
          ? Colors.blue.toARGB32()
          : category.categoryColor,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
