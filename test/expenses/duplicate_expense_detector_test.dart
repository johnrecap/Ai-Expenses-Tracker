import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/finance/duplicate_expense_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const detector = DuplicateExpenseDetector();

  test('flags exact same-day amount and category duplicate', () {
    final existing = _expense(id: 'existing');
    final draft = _expense(id: 'draft');

    final candidate = detector.bestCandidate(
      draft: draft,
      existingExpenses: [existing],
    );

    expect(candidate, isNotNull);
    expect(candidate!.isLikelyDuplicate, isTrue);
    expect(candidate.reasons, contains(DuplicateExpenseReason.sameAmount));
    expect(candidate.reasons, contains(DuplicateExpenseReason.sameCategory));
  });

  test('uses merchant as an extra duplicate signal', () {
    final existing = _expense(id: 'existing', merchant: 'Corner Market');
    final draft = _expense(id: 'draft', merchant: 'corner market');

    final candidate = detector.bestCandidate(
      draft: draft,
      existingExpenses: [existing],
    );

    expect(candidate, isNotNull);
    expect(candidate!.reasons, contains(DuplicateExpenseReason.sameMerchant));
  });

  test('flags near duplicate amount on same day and category', () {
    final existing = _expense(id: 'existing');
    final draft = _expense(id: 'draft', amount: 121);

    final candidate = detector.bestCandidate(
      draft: draft,
      existingExpenses: [existing],
    );

    expect(candidate, isNotNull);
    expect(candidate!.isLikelyDuplicate, isTrue);
  });

  test('does not flag same amount on a different day', () {
    final existing = _expense(id: 'existing');
    final draft = _expense(
      id: 'draft',
      date: DateTime(2026, 5, 19),
    );

    final candidate = detector.bestCandidate(
      draft: draft,
      existingExpenses: [existing],
    );

    expect(candidate, isNull);
  });

  test('does not flag same-day expense with different category', () {
    final existing = _expense(id: 'existing');
    final draft = _expense(
      id: 'draft',
      category: Category(
        categoryId: 'transport',
        name: 'Transport',
        totalExpenses: 0,
        icon: 'transport',
        color: 0xff3498db,
      ),
    );

    final candidate = detector.bestCandidate(
      draft: draft,
      existingExpenses: [existing],
    );

    expect(candidate, isNull);
  });

  test('does not treat missing categories as a category match', () {
    final missingCategory = Category.empty;
    final existing = _expense(id: 'existing', category: missingCategory);
    final draft = _expense(id: 'draft', category: missingCategory);

    final candidate = detector.bestCandidate(
      draft: draft,
      existingExpenses: [existing],
    );

    expect(candidate, isNull);
  });
}

Expense _expense({
  required String id,
  DateTime? date,
  Category? category,
  String? merchant,
  double amount = 120,
}) {
  final selectedCategory = category ??
      Category(
        categoryId: 'food',
        name: 'Food',
        totalExpenses: 0,
        icon: 'restaurant',
        color: 0xff00aa00,
      );
  return Expense(
    expenseId: id,
    userId: 'user-a',
    category: selectedCategory,
    date: date ?? DateTime(2026, 5, 18),
    amount: amount,
    merchant: merchant,
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
  );
}
