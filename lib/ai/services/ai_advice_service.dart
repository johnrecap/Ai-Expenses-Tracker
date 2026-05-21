import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_advice_payload.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:expenses_tracker/services/report_calculator.dart';
import 'package:flutter/widgets.dart' show Locale;

class AiFinancialAdvice {
  final String message;
  final ExpenseReport report;
  final BudgetProgress? budgetProgress;
  final List<String> evidence;

  const AiFinancialAdvice({
    required this.message,
    required this.report,
    required this.evidence,
    this.budgetProgress,
  });
}

class AiAdviceService {
  const AiAdviceService();

  AiFinancialAdvice generate({
    required List<Expense> expenses,
    required AiAdvicePayload payload,
    required UserSettings settings,
    Budget? budget,
    DateTime? now,
    String locale = 'en',
  }) {
    final l10n = _l10nForLocale(locale);
    final report = ReportCalculator.calculate(
      expenses: expenses,
      range: payload.toReportRange(now: now),
      settings: settings,
    );
    final budgetProgress = budget == null
        ? null
        : BudgetCalculator.calculate(
            budget: budget,
            expenses: expenses,
            settings: settings,
          );
    final evidence = <String>[
      l10n.aiAdviceEvidenceTotal(
        report.total.toStringAsFixed(0),
        report.currency,
      ),
      if (report.topCategory != null)
        l10n.aiAdviceEvidenceTopCategory(
          report.topCategory!.categoryName,
          report.topCategory!.total.toStringAsFixed(0),
          report.currency,
        ),
      if (budgetProgress != null)
        l10n.aiAdviceEvidenceBudgetUsed(
          (budgetProgress.percentUsed * 100).toStringAsFixed(0),
        ),
      if (report.convertedCurrencies.isNotEmpty)
        l10n.aiAdviceEvidenceConvertedCurrencies(
          report.convertedCurrencies.join(', '),
        ),
      if (report.ignoredCurrencyCount > 0)
        l10n.aiAdviceEvidenceMissingRates(
          report.unconvertedCurrencies.join(', '),
          report.ignoredCurrencyCount,
        ),
    ];

    return AiFinancialAdvice(
      message: _messageFor(l10n, report, budgetProgress, payload),
      report: report,
      budgetProgress: budgetProgress,
      evidence: evidence,
    );
  }

  String _messageFor(
    AppLocalizations l10n,
    ExpenseReport report,
    BudgetProgress? budgetProgress,
    AiAdvicePayload payload,
  ) {
    if (report.total == 0) {
      return l10n.aiAdviceNoSpending;
    }

    if (budgetProgress?.status == BudgetProgressStatus.exceeded) {
      final topCategory = report.topCategory?.categoryName;
      return topCategory == null
          ? l10n.aiAdviceOverBudgetFallback
          : l10n.aiAdviceOverBudget(topCategory);
    }

    if (budgetProgress?.status == BudgetProgressStatus.nearLimit) {
      final topCategory = report.topCategory?.categoryName;
      return topCategory == null
          ? l10n.aiAdviceNearLimitFallback
          : l10n.aiAdviceNearLimit(topCategory);
    }

    final focus = payload.focusCategory?.trim();
    if (focus != null && focus.isNotEmpty) {
      return l10n.aiAdviceFocusCategory(focus);
    }

    final topCategory = report.topCategory;
    if (topCategory != null) {
      return l10n.aiAdviceTopCategory(topCategory.categoryName);
    }

    return l10n.aiAdviceStable;
  }

  AppLocalizations _l10nForLocale(String locale) {
    final languageCode =
        locale.trim().toLowerCase().startsWith('ar') ? 'ar' : 'en';
    return lookupAppLocalizations(Locale(languageCode));
  }
}
