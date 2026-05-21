import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/history_question.dart';
import 'package:expenses_tracker/ai/services/ai_action_mapper.dart';
import 'package:expenses_tracker/services/expense_filter_service.dart';
import 'package:expenses_tracker/services/report_calculator.dart';
import 'package:intl/intl.dart';

class AiHistoryQueryResolver {
  const AiHistoryQueryResolver();

  HistoryAnswer resolve({
    required String input,
    required List<Expense> expenses,
    required UserSettings settings,
    required DateTime now,
    List<Category> categories = const [],
  }) {
    final trimmed = input.trim();
    final normalized = _normalize(trimmed);
    if (normalized.isEmpty) {
      return const HistoryAnswer(
        intent: HistoryQuestionIntent.unknown,
        message: '',
        confidence: 0,
      );
    }

    if (_isUnsafeMutation(normalized)) {
      return const HistoryAnswer(
        intent: HistoryQuestionIntent.unsupportedMutation,
        message:
            'History answers are read-only. Use the existing preview and confirmation flow for changes.',
        confidence: 0.96,
      );
    }

    if (!_looksLikeHistoryQuestion(normalized)) {
      return HistoryAnswer(
        intent: HistoryQuestionIntent.unknown,
        message: trimmed,
        confidence: 0,
      );
    }

    final range = AiActionMapper.rangeFromText(trimmed, now: now) ??
        ReportRange.monthly(anchorDate: now);
    final category = _categoryFromText(normalized, expenses, categories);
    final threshold = _thresholdFromText(normalized);
    final currency = _currencyFromText(normalized);
    final methods = AiActionMapper.paymentMethodsFromText(trimmed);
    final filter = ExpenseFilter(
      query: '',
      startDate: range.startDate,
      endDate: range.endDate,
      categoryIds: category == null ? const [] : [category.id],
      minAmount: threshold?.isMinimum == true ? threshold!.amount : null,
      maxAmount: threshold?.isMinimum == false ? threshold!.amount : null,
      paymentMethods: methods,
      currency: currency,
    );
    final matching = ExpenseFilterService.apply(expenses, filter);

    if (_asksForDrivers(normalized)) {
      final report = ReportCalculator.calculate(
        expenses: expenses,
        range: range,
        settings: settings,
      );
      final topCategory = report.topCategory;
      final message = topCategory == null
          ? 'No category spending found for this period.'
          : 'Top category is ${topCategory.categoryName} with '
              '${_formatAmountWithCurrency(topCategory.total, report.currency)}.';
      return HistoryAnswer(
        intent: HistoryQuestionIntent.categoryDriver,
        message: _withCurrencyStatus(message, report),
        confidence: 0.86,
        filter: filter,
        report: report,
        matchingExpenses: matching,
        navigationTarget: HistoryNavigationTarget.reports,
      );
    }

    if (_asksForComparison(normalized)) {
      return _comparisonAnswer(
        expenses: expenses,
        settings: settings,
        range: range,
      );
    }

    if (threshold != null || _asksToShowResults(normalized)) {
      return HistoryAnswer(
        intent: HistoryQuestionIntent.search,
        message: matching.isEmpty
            ? 'No loaded expenses match that history question.'
            : 'Found ${matching.length} matching expense(s).',
        confidence: 0.84,
        filter: filter,
        matchingExpenses: matching,
        navigationTarget: HistoryNavigationTarget.expenses,
      );
    }

    final report = ReportCalculator.calculate(
      expenses: expenses,
      range: range,
      settings: settings,
    );
    final scopedReport = category == null
        ? report
        : ReportCalculator.calculate(
            expenses: matching,
            range: range,
            settings: settings,
          );
    final categoryText = category == null ? '' : ' for ${category.name}';
    final message = 'Total spending$categoryText is '
        '${_formatAmountWithCurrency(scopedReport.total, scopedReport.currency)}.';
    return HistoryAnswer(
      intent: HistoryQuestionIntent.total,
      message: _withCurrencyStatus(message, scopedReport),
      confidence: category == null ? 0.82 : 0.88,
      filter: filter,
      report: scopedReport,
      matchingExpenses: matching,
      navigationTarget: HistoryNavigationTarget.reports,
    );
  }

  HistoryAnswer _comparisonAnswer({
    required List<Expense> expenses,
    required UserSettings settings,
    required ReportRange range,
  }) {
    final report = ReportCalculator.calculate(
      expenses: expenses,
      range: range,
      settings: settings,
    );
    final previousRange = _previousRange(range);
    final currentTotals = _categoryTotalsForRange(expenses, settings, range);
    final previousTotals =
        _categoryTotalsForRange(expenses, settings, previousRange);
    final allNames = {...currentTotals.keys, ...previousTotals.keys};
    HistoryComparisonDriver? driver;
    for (final name in allNames) {
      final current = currentTotals[name] ?? 0;
      final previous = previousTotals[name] ?? 0;
      final difference = current - previous;
      if (driver == null ||
          difference.abs() > driver.difference.abs() ||
          (difference.abs() == driver.difference.abs() &&
              name.toLowerCase().compareTo(
                    driver.categoryName.toLowerCase(),
                  ) <
                  0)) {
        driver = HistoryComparisonDriver(
          categoryName: name,
          currentTotal: current,
          previousTotal: previous,
          difference: difference,
        );
      }
    }

    final direction = report.total >= report.previousTotal ? 'up' : 'down';
    final driverText = driver == null
        ? 'No category driver is available.'
        : 'Largest category change is ${driver.categoryName}: '
            '${_formatAmountWithCurrency(driver.difference, report.currency)}.';
    final message = 'Spending is $direction by '
        '${_formatAmountWithCurrency(report.total - report.previousTotal, report.currency)}. '
        '$driverText';
    return HistoryAnswer(
      intent: HistoryQuestionIntent.comparison,
      message: _withCurrencyStatus(message, report),
      confidence: 0.87,
      report: report,
      navigationTarget: HistoryNavigationTarget.reports,
      driver: driver,
    );
  }

  Map<String, double> _categoryTotalsForRange(
    List<Expense> expenses,
    UserSettings settings,
    ReportRange range,
  ) {
    final report = ReportCalculator.calculate(
      expenses: expenses,
      range: range,
      settings: settings,
    );
    return {
      for (final total in report.categoryTotals)
        total.categoryName: total.total,
    };
  }

  ReportRange _previousRange(ReportRange range) {
    switch (range.type) {
      case ReportRangeType.weekly:
        return ReportRange.weekly(
          anchorDate: range.startDate.subtract(const Duration(days: 7)),
        );
      case ReportRangeType.monthly:
        return ReportRange.monthly(
          anchorDate: DateTime(range.startDate.year, range.startDate.month - 1),
        );
      case ReportRangeType.custom:
        final days = range.endDate.difference(range.startDate).inDays + 1;
        return ReportRange.custom(
          startDate: range.startDate.subtract(Duration(days: days)),
          endDate: range.endDate.subtract(Duration(days: days)),
        );
    }
  }

  _MatchedCategory? _categoryFromText(
    String normalized,
    List<Expense> expenses,
    List<Category> categories,
  ) {
    final candidates = <_MatchedCategory>[];
    for (final category in categories) {
      candidates.add(_MatchedCategory(category.categoryId, category.name));
    }
    for (final expense in expenses) {
      final id = expense.categoryId.isNotEmpty
          ? expense.categoryId
          : expense.categoryName;
      final name = expense.categoryName.isNotEmpty
          ? expense.categoryName
          : expense.category.name;
      if (id.trim().isEmpty || name.trim().isEmpty) continue;
      if (!candidates.any((item) => item.id == id)) {
        candidates.add(_MatchedCategory(id, name));
      }
    }
    candidates.addAll(const [
      _MatchedCategory('food', 'Food'),
      _MatchedCategory('transport', 'Transport'),
      _MatchedCategory('groceries', 'Groceries'),
      _MatchedCategory('shopping', 'Shopping'),
    ]);

    for (final candidate in candidates) {
      final name = _normalize(candidate.name);
      final id = _normalize(candidate.id);
      if (name.isNotEmpty && normalized.contains(name)) return candidate;
      if (id.isNotEmpty && normalized.contains(id)) return candidate;
    }
    if (_containsAny(normalized, const ['اكل', 'طعام', 'مطعم', 'food'])) {
      return const _MatchedCategory('food', 'Food');
    }
    if (_containsAny(normalized, const ['مواصلات', 'transport', 'uber'])) {
      return const _MatchedCategory('transport', 'Transport');
    }
    return null;
  }

  _AmountThreshold? _thresholdFromText(String normalized) {
    final amount = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(normalized)?.group(0);
    if (amount == null) return null;
    final parsed = double.tryParse(amount.replaceAll(',', '.'));
    if (parsed == null) return null;
    if (_containsAny(normalized, const [
      'over',
      'above',
      'more than',
      'greater than',
      'اكتر من',
      'اكثر من',
      'فوق',
      'اعلي من',
    ])) {
      return _AmountThreshold(parsed, true);
    }
    if (_containsAny(normalized, const [
      'under',
      'below',
      'less than',
      'اقل من',
      'تحت',
    ])) {
      return _AmountThreshold(parsed, false);
    }
    return null;
  }

  String? _currencyFromText(String normalized) {
    if (_containsAny(normalized, const ['egp', 'جنيه'])) return 'EGP';
    if (_containsAny(normalized, const ['usd', 'dollar', 'دولار'])) {
      return 'USD';
    }
    if (_containsAny(normalized, const ['eur', 'euro', 'يورو'])) return 'EUR';
    return null;
  }

  String _withCurrencyStatus(String message, ExpenseReport report) {
    if (report.ignoredCurrencyCount <= 0) return message;
    return '$message ${report.ignoredCurrencyCount} expense(s) were excluded because rates are missing.';
  }

  String _formatAmountWithCurrency(num amount, String currencyCode) {
    final formatter = NumberFormat.decimalPattern()
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 2;
    return '${formatter.format(amount.toDouble())} '
        '${currencyCode.trim().toUpperCase()}';
  }

  bool _looksLikeHistoryQuestion(String normalized) {
    return _containsAny(normalized, const [
      'how much',
      'total',
      'spending',
      'show',
      'find',
      'expenses',
      'why',
      'increase',
      'higher',
      'top category',
      'كم',
      'اجمالي',
      'مصروف',
      'مصروفات',
      'اعرض',
      'وريني',
      'ليه',
      'زاد',
      'اكتر',
    ]);
  }

  bool _asksToShowResults(String normalized) {
    return _containsAny(normalized, const [
      'show',
      'find',
      'list',
      'اعرض',
      'وريني',
      'هات',
    ]);
  }

  bool _asksForComparison(String normalized) {
    return _containsAny(normalized, const [
      'why',
      'increase',
      'higher',
      'more than last',
      'compared',
      'change',
      'ليه',
      'زاد',
      'مقارنة',
      'اتغير',
    ]);
  }

  bool _asksForDrivers(String normalized) {
    return _containsAny(normalized, const [
      'top category',
      'biggest category',
      'most category',
      'اكتر فئة',
      'اعلي فئة',
    ]);
  }

  bool _isUnsafeMutation(String normalized) {
    final hasMutationVerb = _containsAny(normalized, const [
      'delete',
      'remove',
      'update',
      'change',
      'edit',
      'create',
      'add',
      'احذف',
      'امسح',
      'عدل',
      'غير',
      'ضيف',
    ]);
    if (!hasMutationVerb) return false;
    return _containsAny(normalized, const [
      'over',
      'above',
      'more than',
      'expensive',
      'all',
      'كل',
      'اكتر من',
      'فوق',
    ]);
  }

  bool _containsAny(String text, List<String> values) {
    return values.any((value) => text.contains(_normalize(value)));
  }

  String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _MatchedCategory {
  const _MatchedCategory(this.id, this.name);

  final String id;
  final String name;
}

class _AmountThreshold {
  const _AmountThreshold(this.amount, this.isMinimum);

  final double amount;
  final bool isMinimum;
}
