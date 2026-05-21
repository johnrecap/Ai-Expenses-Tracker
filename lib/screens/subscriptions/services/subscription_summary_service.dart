import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/recurring_expense_scheduler.dart';

class SubscriptionSummary {
  final RecurringExpense recurringExpense;
  final DateTime nextDueDate;
  final double monthlyImpact;
  final List<SubscriptionCaveat> caveats;

  const SubscriptionSummary({
    required this.recurringExpense,
    required this.nextDueDate,
    required this.monthlyImpact,
    this.caveats = const [],
  });
}

enum SubscriptionCaveatType {
  estimatedDailyImpact,
  estimatedWeeklyImpact,
  mixedCurrencies,
}

class SubscriptionCaveat {
  final SubscriptionCaveatType type;
  final String? currency;

  const SubscriptionCaveat({
    required this.type,
    this.currency,
  });
}

class SubscriptionMonthlyImpact {
  final Map<String, double> totalsByCurrency;
  final List<SubscriptionCaveat> caveats;
  final String? baseCurrency;
  final List<String> convertedCurrencies;
  final List<String> unconvertedCurrencies;
  final int unconvertedRuleCount;
  final DateTime? rateUpdatedAt;

  const SubscriptionMonthlyImpact({
    required this.totalsByCurrency,
    required this.caveats,
    this.baseCurrency,
    this.convertedCurrencies = const [],
    this.unconvertedCurrencies = const [],
    this.unconvertedRuleCount = 0,
    this.rateUpdatedAt,
  });

  bool get hasMultipleCurrencies => totalsByCurrency.length > 1;
  bool get hasConvertedCurrencies => convertedCurrencies.isNotEmpty;
  bool get hasUnconvertedCurrencies => unconvertedRuleCount > 0;
}

class UpcomingRenewal {
  final RecurringExpense recurringExpense;
  final DateTime dueDate;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final RecurringFrequency frequency;

  const UpcomingRenewal({
    required this.recurringExpense,
    required this.dueDate,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.frequency,
  });
}

class SubscriptionPriceChangeCandidate {
  final RecurringExpense currentRule;
  final RecurringExpense previousRule;
  final double previousAmount;
  final double currentAmount;
  final double confidence;
  final String reason;

  const SubscriptionPriceChangeCandidate({
    required this.currentRule,
    required this.previousRule,
    required this.previousAmount,
    required this.currentAmount,
    required this.confidence,
    required this.reason,
  });
}

class SubscriptionSummaryService {
  const SubscriptionSummaryService();

  List<SubscriptionSummary> summarize({
    required List<RecurringExpense> rules,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final summaries = rules
        .where((rule) => rule.isActive && !rule.isArchived)
        .map(
          (rule) => SubscriptionSummary(
            recurringExpense: rule,
            nextDueDate: _nextDueDate(rule, effectiveNow),
            monthlyImpact: _monthlyImpact(rule),
            caveats: _ruleCaveats(rule),
          ),
        )
        .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return summaries;
  }

  SubscriptionMonthlyImpact monthlyImpact(
    List<SubscriptionSummary> summaries, {
    UserSettings? settings,
  }) {
    final convertedImpact = settings == null
        ? null
        : _convertedMonthlyImpact(
            summaries: summaries,
            settings: settings,
          );
    final totals = convertedImpact?.totalsByCurrency ??
        monthlyImpactByCurrency(summaries);
    final caveats = _dedupeCaveats(<SubscriptionCaveat>[
      for (final summary in summaries) ...summary.caveats,
      if (settings == null && totals.length > 1)
        const SubscriptionCaveat(type: SubscriptionCaveatType.mixedCurrencies),
    ]);
    return SubscriptionMonthlyImpact(
      totalsByCurrency: totals,
      caveats: caveats,
      baseCurrency: convertedImpact?.baseCurrency,
      convertedCurrencies: convertedImpact?.convertedCurrencies ?? const [],
      unconvertedCurrencies: convertedImpact?.unconvertedCurrencies ?? const [],
      unconvertedRuleCount: convertedImpact?.unconvertedRuleCount ?? 0,
      rateUpdatedAt: convertedImpact?.rateUpdatedAt,
    );
  }

  Map<String, double> monthlyImpactByCurrency(
    List<SubscriptionSummary> summaries,
  ) {
    final totals = <String, double>{};
    for (final summary in summaries) {
      final currency = summary.recurringExpense.currency.toUpperCase();
      totals[currency] = (totals[currency] ?? 0) + summary.monthlyImpact;
    }
    return totals;
  }

  List<UpcomingRenewal> upcomingRenewals(
    List<SubscriptionSummary> summaries, {
    DateTime? now,
    int windowDays = 7,
  }) {
    final start = _startOfDay(now ?? DateTime.now());
    final end = start.add(Duration(days: windowDays));
    return summaries
        .where(
          (summary) =>
              !summary.nextDueDate.isBefore(start) &&
              !summary.nextDueDate.isAfter(end),
        )
        .map(
          (summary) => UpcomingRenewal(
            recurringExpense: summary.recurringExpense,
            dueDate: summary.nextDueDate,
            amount: summary.recurringExpense.amount,
            currency: summary.recurringExpense.currency,
            paymentMethod: summary.recurringExpense.paymentMethod,
            frequency: summary.recurringExpense.frequency,
          ),
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<SubscriptionPriceChangeCandidate> priceChangeCandidates({
    required List<RecurringExpense> rules,
  }) {
    final grouped = <String, List<RecurringExpense>>{};
    for (final rule in rules.where((rule) => !rule.isArchived)) {
      grouped.putIfAbsent(_priceChangeKey(rule), () => []).add(rule);
    }

    final candidates = <SubscriptionPriceChangeCandidate>[];
    for (final group in grouped.values.where((group) => group.length > 1)) {
      group.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final activeRules = group.where((rule) => rule.isActive).toList();
      if (activeRules.isEmpty) continue;
      final current = activeRules.first;
      RecurringExpense? previous;
      for (final rule in group) {
        if (rule.recurringExpenseId == current.recurringExpenseId) continue;
        previous = rule;
        break;
      }
      if (previous == null || current.amount <= previous.amount) continue;

      candidates.add(
        SubscriptionPriceChangeCandidate(
          currentRule: current,
          previousRule: previous,
          previousAmount: previous.amount,
          currentAmount: current.amount,
          confidence: 0.6,
          reason: 'Similar recurring rules with a higher latest amount.',
        ),
      );
    }

    return candidates
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  DateTime _nextDueDate(RecurringExpense rule, DateTime now) {
    var nextDueDate = rule.nextRunDate;
    while (nextDueDate.isBefore(_startOfDay(now))) {
      nextDueDate = RecurringExpenseScheduler.nextRunAfterOccurrence(
        rule,
        nextDueDate,
      );
    }
    return nextDueDate;
  }

  double _monthlyImpact(RecurringExpense rule) {
    switch (rule.frequency) {
      case RecurringFrequency.daily:
        return rule.amount * 30;
      case RecurringFrequency.weekly:
        return rule.amount * 52 / 12;
      case RecurringFrequency.monthly:
        return rule.amount.toDouble();
    }
  }

  SubscriptionMonthlyImpact _convertedMonthlyImpact({
    required List<SubscriptionSummary> summaries,
    required UserSettings settings,
  }) {
    final baseCurrency = settings.baseCurrency.trim().toUpperCase();
    final totals = <String, double>{baseCurrency: 0};
    final convertedCurrencies = <String>{};
    final unconvertedCurrencies = <String>{};
    var unconvertedRuleCount = 0;

    for (final summary in summaries) {
      final currency = summary.recurringExpense.currency.trim().toUpperCase();
      if (currency == baseCurrency) {
        totals[baseCurrency] = (totals[baseCurrency] ?? 0) +
            summary.monthlyImpact;
        continue;
      }

      final rate = settings.conversionRates[currency]?.toDouble();
      if (rate == null || rate <= 0 || !rate.isFinite) {
        totals[currency] = (totals[currency] ?? 0) + summary.monthlyImpact;
        unconvertedCurrencies.add(currency);
        unconvertedRuleCount++;
        continue;
      }

      totals[baseCurrency] = (totals[baseCurrency] ?? 0) +
          summary.monthlyImpact * rate;
      convertedCurrencies.add(currency);
    }

    if ((totals[baseCurrency] ?? 0) == 0) {
      totals.remove(baseCurrency);
    }

    return SubscriptionMonthlyImpact(
      totalsByCurrency: totals,
      caveats: const [],
      baseCurrency: baseCurrency,
      convertedCurrencies: _sorted(convertedCurrencies),
      unconvertedCurrencies: _sorted(unconvertedCurrencies),
      unconvertedRuleCount: unconvertedRuleCount,
      rateUpdatedAt: settings.exchangeRatesUpdatedAt,
    );
  }

  List<SubscriptionCaveat> _ruleCaveats(RecurringExpense rule) {
    switch (rule.frequency) {
      case RecurringFrequency.daily:
        return const [
          SubscriptionCaveat(type: SubscriptionCaveatType.estimatedDailyImpact),
        ];
      case RecurringFrequency.weekly:
        return const [
          SubscriptionCaveat(type: SubscriptionCaveatType.estimatedWeeklyImpact),
        ];
      case RecurringFrequency.monthly:
        return const [];
    }
  }

  String _priceChangeKey(RecurringExpense rule) {
    final description = rule.description.trim().toLowerCase();
    final name = description.isEmpty ? rule.categoryName : description;
    return [
      name.trim().toLowerCase(),
      rule.categoryId,
      rule.currency.toUpperCase(),
      rule.paymentMethod.name,
      rule.frequency.name,
    ].join('|');
  }

  List<SubscriptionCaveat> _dedupeCaveats(List<SubscriptionCaveat> caveats) {
    final seen = <String>{};
    final result = <SubscriptionCaveat>[];
    for (final caveat in caveats) {
      final key = '${caveat.type.name}|${caveat.currency ?? ''}';
      if (!seen.add(key)) continue;
      result.add(caveat);
    }
    return result;
  }

  List<String> _sorted(Set<String> currencies) {
    return List.unmodifiable(currencies.toList()..sort());
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
