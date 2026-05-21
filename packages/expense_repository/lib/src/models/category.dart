import '../entities/category_entity.dart';

class Category {
  String categoryId;
  String userId;
  String name;
  int totalExpenses;
  String icon;
  int color;
  bool isArchived;
  DateTime createdAt;
  DateTime updatedAt;

  Category({
    required this.categoryId,
    String? userId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : userId = userId ?? '',
        isArchived = isArchived ?? false,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  static final empty = Category(
    categoryId: '',
    userId: '',
    name: '',
    totalExpenses: 0,
    icon: '',
    color: 0,
    isArchived: false,
  );

  Category copyWith({
    String? categoryId,
    String? userId,
    String? name,
    int? totalExpenses,
    String? icon,
    int? color,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      userId: userId,
      name: name,
      totalExpenses: totalExpenses,
      icon: icon,
      color: color,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Category fromEntity(CategoryEntity entity) {
    return Category(
      categoryId: entity.categoryId,
      userId: entity.userId,
      name: entity.name,
      totalExpenses: entity.totalExpenses,
      icon: entity.icon,
      color: entity.color,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
