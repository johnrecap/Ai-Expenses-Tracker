import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = AiCategoryResolver();

  final categories = [
    _category('food', 'Food'),
    _category('transport', 'Transport'),
    _category('bills', 'Bills'),
    _category('shopping', 'Shopping'),
    _category('entertainment', 'Entertainment'),
    _category('health', 'Health'),
    _category('travel', 'Travel'),
    _category('subscriptions', 'Subscriptions'),
    _category('rent', 'Rent'),
    _category('fuel', 'Fuel'),
  ];

  test('matches Arabic transport phrases to active Transport category', () {
    for (final phrase in [
      'صرفت 100 جنيه على المواصلات',
      'دفعت اوبر امبارح',
      'أوبر للكليه',
      'تاكسي للبيت',
      'مترو الشغل',
    ]) {
      final result = resolver.resolve(
        inputText: phrase,
        activeCategories: categories,
      );

      expect(result.categoryId, 'transport', reason: phrase);
      expect(result.source, AiCategoryResolutionSource.alias);
    }
  });

  test('matches Arabic food phrases to active Food category', () {
    for (final phrase in [
      'اشتريت اكل',
      'دفعت في مطعم',
      'طلبت دليفري',
      'سوبر ماركت للبيت',
    ]) {
      final result = resolver.resolve(
        inputText: phrase,
        activeCategories: categories,
      );

      expect(result.categoryId, 'food', reason: phrase);
    }
  });

  test('matches common category families', () {
    final cases = {
      'فاتورة الكهرباء': 'bills',
      'دفعت فاتورة النت': 'bills',
      'شحنة واي فاي البيت': 'bills',
      'اشتراك نتفلكس': 'subscriptions',
      'سبوتيفاي الشهر ده': 'subscriptions',
      'اشتريت لبس': 'shopping',
      'روحت سينما': 'entertainment',
      'صيدلية وعلاج': 'health',
      'حجز فندق للسفر': 'travel',
      'دفعت الايجار': 'rent',
      'بنزين العربيه': 'fuel',
    };

    for (final entry in cases.entries) {
      final result = resolver.resolve(
        inputText: entry.key,
        activeCategories: categories,
      );

      expect(result.categoryId, entry.value, reason: entry.key);
    }
  });

  test('uses parsed category id before aliases', () {
    final result = resolver.resolve(
      inputText: 'مطعم',
      parsedCategoryId: 'shopping',
      activeCategories: categories,
    );

    expect(result.categoryId, 'shopping');
    expect(result.source, AiCategoryResolutionSource.exactId);
  });

  test('ignores archived categories and suggests instead', () {
    final result = resolver.resolve(
      inputText: 'اشتراك نتفلكس',
      activeCategories: [
        _category('subscriptions', 'Subscriptions', isArchived: true),
      ],
    );

    expect(result.categoryId, isNull);
    expect(result.suggestedCategory?.name, 'Subscriptions');
  });

  test('returns low confidence no-match for ambiguous text', () {
    final result = resolver.resolve(
      inputText: 'دفعت حاجه امبارح',
      activeCategories: categories,
    );

    expect(result.hasExistingCategory, isFalse);
    expect(result.suggestedCategory, isNull);
    expect(result.isLowConfidence, isTrue);
  });

  test('does not auto-select archived parsed category id', () {
    final result = resolver.resolve(
      inputText: 'دفعت اشتراك نتفلكس',
      parsedCategoryId: 'subscriptions',
      parsedCategoryName: 'Subscriptions',
      activeCategories: [
        _category('subscriptions', 'Subscriptions', isArchived: true),
        _category('bills', 'Bills'),
      ],
    );

    expect(result.categoryId, isNull);
    expect(result.source, AiCategoryResolutionSource.aiSuggested);
    expect(result.suggestedCategory?.name, 'Subscriptions');
  });

  test('no active match keeps editable suggestion metadata', () {
    final result = resolver.resolve(
      inputText: 'اشتراك شاهد',
      activeCategories: [_category('food', 'Food')],
    );

    expect(result.hasExistingCategory, isFalse);
    expect(result.requiresUserCategoryConfirmation, isTrue);
    expect(result.suggestedCategory?.name, 'Subscriptions');
    expect(result.reason, contains('No existing category matched'));
  });
}

Category _category(String id, String name, {bool isArchived = false}) {
  return Category(
    categoryId: id,
    userId: 'user-1',
    name: name,
    totalExpenses: 0,
    icon: id,
    color: 0xFFFFFFFF,
    isArchived: isArchived,
  );
}
