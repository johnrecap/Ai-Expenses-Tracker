import '../entities/category_alias_entity.dart';

class CategoryAlias {
  const CategoryAlias({
    required this.aliasId,
    required this.userId,
    required this.categoryId,
    required this.phrase,
    required this.locale,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUsedAt,
    required this.useCount,
  });

  final String aliasId;
  final String userId;
  final String categoryId;
  final String phrase;
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastUsedAt;
  final int useCount;

  CategoryAlias copyWith({
    String? aliasId,
    String? userId,
    String? categoryId,
    String? phrase,
    String? locale,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    int? useCount,
  }) {
    return CategoryAlias(
      aliasId: aliasId ?? this.aliasId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      phrase: phrase ?? this.phrase,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
    );
  }

  CategoryAliasEntity toEntity() {
    return CategoryAliasEntity(
      aliasId: aliasId,
      userId: userId,
      categoryId: categoryId,
      phrase: phrase,
      locale: locale,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastUsedAt: lastUsedAt,
      useCount: useCount,
    );
  }

  static CategoryAlias fromEntity(CategoryAliasEntity entity) {
    return CategoryAlias(
      aliasId: entity.aliasId,
      userId: entity.userId,
      categoryId: entity.categoryId,
      phrase: entity.phrase,
      locale: entity.locale,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastUsedAt: entity.lastUsedAt,
      useCount: entity.useCount,
    );
  }
}
