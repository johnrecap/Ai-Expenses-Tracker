import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/expenses/views/expenses_screen.dart';
import 'package:expenses_tracker/screens/reports/cubit/report_cubit.dart';
import 'package:expenses_tracker/screens/reports/models/monthly_financial_story.dart';
import 'package:expenses_tracker/screens/reports/models/report_drilldown_target.dart';
import 'package:expenses_tracker/screens/reports/services/monthly_financial_story_service.dart';
import 'package:expenses_tracker/screens/reports/widgets/category_breakdown_chart.dart';
import 'package:expenses_tracker/screens/reports/widgets/month_comparison_card.dart';
import 'package:expenses_tracker/screens/reports/widgets/spending_bar_chart.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsScreen extends StatelessWidget {
  final List<Expense> expenses;
  final UserSettings? settings;

  const ReportsScreen({
    super.key,
    required this.expenses,
    this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final providedSettings = settings;
    if (providedSettings != null) {
      return _ReportsScope(
        expenses: expenses,
        settings: providedSettings,
      );
    }

    try {
      final settingsRepository = context.read<SettingsRepository>();
      return StreamBuilder<UserSettings>(
        stream: settingsRepository.watchSettings(),
        initialData: UserSettings.defaults(userId: ''),
        builder: (context, snapshot) {
          return _ReportsScope(
            expenses: expenses,
            settings: snapshot.data ?? UserSettings.defaults(userId: ''),
          );
        },
      );
    } catch (_) {
      return _ReportsScope(
        expenses: expenses,
        settings: UserSettings.defaults(userId: ''),
      );
    }
  }
}

class _ReportsScope extends StatelessWidget {
  const _ReportsScope({
    required this.expenses,
    required this.settings,
  });

  final List<Expense> expenses;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportCubit(
        expenses: expenses,
        settings: settings,
      )..loadWeekly(),
      child: _ReportsView(
        expenses: expenses,
        settings: settings,
      ),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView({
    required this.expenses,
    required this.settings,
  });

  final List<Expense> expenses;
  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        child: BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            final selectedRange = state is ReportLoaded
                ? state.selectedRange
                : state is ReportEmpty
                    ? state.selectedRange
                    : ReportRangeType.weekly;

            return ListView(
              children: [
                Text(
                  context.l10n.reports,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<ReportRangeType>(
                  segments: [
                    ButtonSegment(
                      value: ReportRangeType.weekly,
                      label: Text(context.l10n.week),
                    ),
                    ButtonSegment(
                      value: ReportRangeType.monthly,
                      label: Text(context.l10n.month),
                    ),
                  ],
                  selected: {selectedRange},
                  onSelectionChanged: (selection) {
                    final selected = selection.first;
                    if (selected == ReportRangeType.weekly) {
                      context.read<ReportCubit>().loadWeekly();
                    } else {
                      context.read<ReportCubit>().loadMonthly();
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (state is ReportLoading || state is ReportInitial)
                  const Center(child: CircularProgressIndicator())
                else if (state is ReportFailure)
                  Center(child: Text(state.message))
                else if (state is ReportLoaded)
                  _ReportContent(
                    report: state.report,
                    expenses: expenses,
                    settings: settings,
                  )
                else if (state is ReportEmpty)
                  _ReportContent(
                    report: state.report,
                    expenses: expenses,
                    settings: settings,
                    isEmpty: true,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  final ExpenseReport report;
  final List<Expense> expenses;
  final UserSettings settings;
  final bool isEmpty;

  const _ReportContent({
    required this.report,
    required this.expenses,
    required this.settings,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(report: report),
        const SizedBox(height: 16),
        const MonetizationBannerAdSlot(
          placementKey: AdPlacementKey.reportsBanner,
        ),
        const SizedBox(height: 16),
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isEmpty
              ? Center(child: Text(context.l10n.noSpendingInThisPeriod))
              : SpendingBarChart(
                  buckets: report.buckets,
                  onBucketTap: (bucket) => _openDrilldown(
                    context,
                    ReportDrilldownTarget.bucket(
                      range: report.range,
                      bucket: bucket,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        MonthComparisonCard(report: report),
        if (report.range.type == ReportRangeType.monthly) ...[
          const SizedBox(height: 16),
          MonthlyStoryCard(
            story: const MonthlyFinancialStoryService().build(
              report: report,
              expenses: expenses,
              settings: settings,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
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
                context.l10n.categories,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CategoryBreakdownChart(
                categories: report.categoryTotals,
                onCategoryTap: (category) => _openDrilldown(
                  context,
                  ReportDrilldownTarget.category(
                    range: report.range,
                    category: category,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openDrilldown(
    BuildContext context,
    ReportDrilldownTarget target,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExpensesScreen(
          expenses: expenses,
          initialFilter: target.filter,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ExpenseReport report;

  const _SummaryCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final topCategory = report.topCategory?.categoryName ?? context.l10n.none;
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
            formatAmountWithCurrency(report.total, report.currency),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.topCategoryLabel(topCategory),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (report.ignoredCurrencyCount > 0)
            Text(
              context.l10n.unconvertedCurrenciesStatus(
                report.ignoredCurrencyCount,
                report.unconvertedCurrencies.join(', '),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          if (report.convertedCurrencies.isNotEmpty)
            Text(
              context.l10n.convertedCurrenciesStatus(
                report.convertedCurrencies.join(', '),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class MonthlyStoryCard extends StatelessWidget {
  const MonthlyStoryCard({
    super.key,
    required this.story,
  });

  final MonthlyFinancialStory story;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            l10n.monthlyStoryTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(_summaryText(context)),
          if (story.drivers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.monthlyStoryDriversHeading,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            for (final driver in story.drivers)
              Text(
                l10n.monthlyStoryDriver(
                  driver.category.categoryName,
                  formatAmountWithCurrency(driver.amount, story.currency),
                  driver.sharePercent.round(),
                ),
              ),
          ],
          if (story.outliers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.monthlyStoryOutliersHeading,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            for (final outlier in story.outliers)
              Text(
                l10n.monthlyStoryOutlier(
                  _expenseLabel(outlier.expense),
                  formatAmountWithCurrency(
                    outlier.convertedAmount,
                    story.currency,
                  ),
                ),
              ),
          ],
          if (story.hasMissingRateCaveat) ...[
            const SizedBox(height: 12),
            Text(
              l10n.monthlyStoryMissingRateCaveat(
                story.ignoredCurrencyCount,
                story.unconvertedCurrencies.join(', '),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _summaryText(BuildContext context) {
    final current = formatAmountWithCurrency(story.currentTotal, story.currency);
    final previous =
        formatAmountWithCurrency(story.previousTotal, story.currency);
    switch (story.trend) {
      case MonthlyStoryTrend.empty:
        return context.l10n.monthlyStoryEmpty;
      case MonthlyStoryTrend.newSpending:
        return context.l10n.monthlyStoryNewSpending(current);
      case MonthlyStoryTrend.increase:
        return context.l10n.monthlyStoryIncrease(
          current,
          previous,
          story.deltaPercent.round(),
        );
      case MonthlyStoryTrend.decrease:
        return context.l10n.monthlyStoryDecrease(
          current,
          previous,
          story.deltaPercent.abs().round(),
        );
      case MonthlyStoryTrend.flat:
        return context.l10n.monthlyStoryFlat(current, previous);
    }
  }

  String _expenseLabel(Expense expense) {
    if (expense.description.trim().isNotEmpty) {
      return expense.description.trim();
    }
    if (expense.categoryName.trim().isNotEmpty) {
      return expense.categoryName.trim();
    }
    return expense.category.name;
  }
}
