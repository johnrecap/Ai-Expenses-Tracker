import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurringExpenseEntity', () {
    test('serializes and parses recurrence rule fields', () {
      final category = Category(
        categoryId: 'food',
        userId: 'user-1',
        name: 'Food',
        totalExpenses: 0,
        icon: 'food',
        color: 0xff00ff00,
      );
      final rule = RecurringExpense(
        recurringExpenseId: 'recurring-1',
        userId: 'user-1',
        amount: 250.75,
        category: category,
        description: 'Internet subscription',
        paymentMethod: PaymentMethod.visa,
        currency: 'EGP',
        startDate: DateTime(2026, 5, 1),
        nextRunDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 12, 1),
        frequency: RecurringFrequency.monthly,
        isActive: true,
        isArchived: false,
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 2),
      );

      final parsed = RecurringExpense.fromEntity(
        RecurringExpenseEntity.fromDocument(rule.toEntity().toDocument()),
      );

      expect(parsed.recurringExpenseId, 'recurring-1');
      expect(parsed.userId, 'user-1');
      expect(parsed.amount, 250.75);
      expect(parsed.categoryId, 'food');
      expect(parsed.description, 'Internet subscription');
      expect(parsed.paymentMethod, PaymentMethod.visa);
      expect(parsed.currency, 'EGP');
      expect(parsed.frequency, RecurringFrequency.monthly);
      expect(parsed.nextRunDate, DateTime(2026, 6, 1));
      expect(parsed.endDate, DateTime(2026, 12, 1));
      expect(parsed.isActive, isTrue);
      expect(parsed.isArchived, isFalse);
    });

    test('defaults missing active flags to active and not archived', () {
      final parsed = RecurringExpenseEntity.fromDocument({
        'recurringExpenseId': 'legacy-rule',
        'amount': 100.50,
        'categoryName': 'Transport',
        'startDate': DateTime(2026, 5, 15),
        'nextRunDate': DateTime(2026, 5, 15),
        'frequency': 'daily',
      });

      expect(parsed.isActive, isTrue);
      expect(parsed.isArchived, isFalse);
      expect(parsed.frequency, RecurringFrequency.daily);
      expect(parsed.amount, 100.50);
    });
  });
}
