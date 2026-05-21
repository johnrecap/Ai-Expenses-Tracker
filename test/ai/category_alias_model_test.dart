import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category alias model round-trips through entity document', () {
    final now = DateTime(2026, 5, 17, 12);
    final alias = CategoryAlias(
      aliasId: 'transport_1',
      userId: 'user-1',
      categoryId: 'transport',
      phrase: 'اوبر',
      locale: 'ar-EG',
      createdAt: now,
      updatedAt: now,
      lastUsedAt: now,
      useCount: 3,
    );

    final restored = CategoryAlias.fromEntity(
      CategoryAliasEntity.fromDocument(alias.toEntity().toDocument()),
    );

    expect(restored.aliasId, alias.aliasId);
    expect(restored.userId, alias.userId);
    expect(restored.categoryId, alias.categoryId);
    expect(restored.phrase, alias.phrase);
    expect(restored.locale, alias.locale);
    expect(restored.useCount, alias.useCount);
  });
}
