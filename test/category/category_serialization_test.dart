import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses legacy category docs with lifecycle defaults', () {
    final category = Category.fromEntity(
      CategoryEntity.fromDocument({
        'categoryId': 'food',
        'name': 'Food',
        'totalExpenses': 3,
        'icon': 'food',
        'color': 4294967295,
      }),
    );

    expect(category.categoryId, 'food');
    expect(category.userId, '');
    expect(category.isArchived, isFalse);
    expect(category.createdAt, isA<DateTime>());
    expect(category.updatedAt, isA<DateTime>());
  });

  test('round-trips category lifecycle fields', () {
    final createdAt = DateTime(2026, 5, 1);
    final updatedAt = DateTime(2026, 5, 15);
    final category = Category(
      categoryId: 'travel',
      userId: 'user-1',
      name: 'Travel',
      totalExpenses: 2,
      icon: 'travel',
      color: 4280391411,
      isArchived: true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final document = category.toEntity().toDocument();
    final parsed = Category.fromEntity(
      CategoryEntity.fromDocument(Map<String, dynamic>.from(document)),
    );

    expect(parsed.categoryId, category.categoryId);
    expect(parsed.userId, category.userId);
    expect(parsed.name, category.name);
    expect(parsed.totalExpenses, category.totalExpenses);
    expect(parsed.icon, category.icon);
    expect(parsed.color, category.color);
    expect(parsed.isArchived, isTrue);
    expect(parsed.createdAt, createdAt);
    expect(parsed.updatedAt, updatedAt);
  });
}
