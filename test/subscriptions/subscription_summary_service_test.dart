import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/subscriptions/services/subscription_summary_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionSummaryService', () {
    test('advances monthly next due date when stored date is stale', () {
      final summaries = const SubscriptionSummaryService().summarize(
        now: DateTime(2026, 5, 17),
        rules: [
          _rule(
            frequency: RecurringFrequency.monthly,
            startDate: DateTime(2026, 1, 31),
            nextRunDate: DateTime(2026, 4, 30),
          ),
        ],
      );

      expect(summaries.single.nextDueDate, DateTime(2026, 5, 31));
      expect(summaries.single.monthlyImpact, 100);
    });

    test('estimates weekly monthly impact', () {
      final summaries = const SubscriptionSummaryService().summarize(
        now: DateTime(2026, 5, 17),
        rules: [
          _rule(
            amount: 120,
            frequency: RecurringFrequency.weekly,
            startDate: DateTime(2026, 5, 1),
            nextRunDate: DateTime(2026, 5, 22),
          ),
        ],
      );

      expect(summaries.single.monthlyImpact, 520);
      expect(
        summaries.single.caveats.single.type,
        SubscriptionCaveatType.estimatedWeeklyImpact,
      );
    });

    test('estimates daily monthly impact', () {
      final summaries = const SubscriptionSummaryService().summarize(
        now: DateTime(2026, 5, 17),
        rules: [
          _rule(
            amount: 5,
            frequency: RecurringFrequency.daily,
            startDate: DateTime(2026, 5, 1),
            nextRunDate: DateTime(2026, 5, 18),
          ),
        ],
      );

      expect(summaries.single.nextDueDate, DateTime(2026, 5, 18));
      expect(summaries.single.monthlyImpact, 150);
      expect(
        summaries.single.caveats.single.type,
        SubscriptionCaveatType.estimatedDailyImpact,
      );
    });

    test('excludes paused and archived rules', () {
      final summaries = const SubscriptionSummaryService().summarize(
        now: DateTime(2026, 5, 17),
        rules: [
          _rule(isActive: false),
          _rule(isArchived: true),
        ],
      );

      expect(summaries, isEmpty);
    });

    test('groups monthly impact by currency', () {
      const service = SubscriptionSummaryService();
      final summaries = service.summarize(
        now: DateTime(2026, 5, 17),
        rules: [
          _rule(amount: 100, currency: 'EGP'),
          _rule(amount: 10, currency: 'USD'),
        ],
      );

      expect(service.monthlyImpactByCurrency(summaries), {
        'EGP': 100,
        'USD': 10,
      });
      final impact = service.monthlyImpact(summaries);
      expect(impact.hasMultipleCurrencies, isTrue);
      expect(
        impact.caveats.map((caveat) => caveat.type),
        contains(SubscriptionCaveatType.mixedCurrencies),
      );
    });

    test('converts monthly impact to base currency when rates exist', () {
      const service = SubscriptionSummaryService();
      final summaries = service.summarize(
        now: DateTime(2026, 5, 17),
        rules: [
          _rule(amount: 100, currency: 'EGP'),
          _rule(amount: 10, currency: 'USD'),
        ],
      );

      final impact = service.monthlyImpact(
        summaries,
        settings: UserSettings.defaults(userId: 'user-1').copyWith(
          baseCurrency: 'EGP',
          supportedCurrencies: const ['EGP', 'USD'],
          conversionRates: const {'USD': 50},
          exchangeRatesUpdatedAt: DateTime(2026, 5, 17),
        ),
      );

      expect(impact.totalsByCurrency, {'EGP': 600});
      expect(impact.convertedCurrencies, ['USD']);
      expect(impact.unconvertedCurrencies, isEmpty);
      expect(impact.unconvertedRuleCount, 0);
    });

    test('keeps missing-rate subscription impact separate', () {
      const service = SubscriptionSummaryService();
      final summaries = service.summarize(
        now: DateTime(2026, 5, 17),
        rules: [
          _rule(amount: 100, currency: 'EGP'),
          _rule(amount: 10, currency: 'USD'),
        ],
      );

      final impact = service.monthlyImpact(
        summaries,
        settings: UserSettings.defaults(userId: 'user-1').copyWith(
          baseCurrency: 'EGP',
          supportedCurrencies: const ['EGP', 'USD'],
        ),
      );

      expect(impact.totalsByCurrency, {'EGP': 100, 'USD': 10});
      expect(impact.convertedCurrencies, isEmpty);
      expect(impact.unconvertedCurrencies, ['USD']);
      expect(impact.unconvertedRuleCount, 1);
    });

    test('identifies upcoming renewals within seven days', () {
      const service = SubscriptionSummaryService();
      final summaries = service.summarize(
        now: DateTime(2026, 5, 17),
        rules: [
          _rule(nextRunDate: DateTime(2026, 5, 18)),
          _rule(amount: 200, nextRunDate: DateTime(2026, 5, 24)),
          _rule(amount: 300, nextRunDate: DateTime(2026, 5, 25)),
        ],
      );

      final renewals = service.upcomingRenewals(
        summaries,
        now: DateTime(2026, 5, 17),
      );

      expect(renewals.map((renewal) => renewal.dueDate), [
        DateTime(2026, 5, 18),
        DateTime(2026, 5, 24),
      ]);
    });

    test('returns cautious price change candidates for similar rules', () {
      final previous = _rule(
        id: 'streaming-old',
        amount: 80,
        description: 'Streaming',
        updatedAt: DateTime(2026, 4, 1),
        isActive: false,
      );
      final current = _rule(
        id: 'streaming-current',
        amount: 100,
        description: 'Streaming',
        updatedAt: DateTime(2026, 5, 1),
      );

      final candidates = const SubscriptionSummaryService()
          .priceChangeCandidates(rules: [previous, current]);

      expect(candidates, hasLength(1));
      expect(candidates.single.previousAmount, 80);
      expect(candidates.single.currentAmount, 100);
      expect(candidates.single.confidence, lessThan(1));
    });
  });
}

RecurringExpense _rule({
  String? id,
  int amount = 100,
  String currency = 'EGP',
  String description = 'Subscription',
  RecurringFrequency frequency = RecurringFrequency.monthly,
  DateTime? startDate,
  DateTime? nextRunDate,
  DateTime? updatedAt,
  bool isActive = true,
  bool isArchived = false,
}) {
  final effectiveStartDate = startDate ?? DateTime(2026, 5, 1);
  final category = Category(
    categoryId: 'category-1',
    name: 'Bills',
    totalExpenses: 0,
    icon: 'home',
    color: 0xff0000ff,
  );
  return RecurringExpense(
    recurringExpenseId: id ?? 'rule-$amount-$currency',
    userId: 'user-1',
    amount: amount,
    category: category,
    description: description,
    paymentMethod: PaymentMethod.visa,
    currency: currency,
    startDate: effectiveStartDate,
    nextRunDate: nextRunDate ?? effectiveStartDate,
    frequency: frequency,
    isActive: isActive,
    isArchived: isArchived,
    createdAt: effectiveStartDate,
    updatedAt: updatedAt ?? effectiveStartDate,
  );
}
