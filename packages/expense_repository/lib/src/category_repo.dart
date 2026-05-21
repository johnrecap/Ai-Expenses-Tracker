import 'models/category.dart';

abstract class CategoryRepository {
  Future<void> createCategory(Category category);

  Future<void> updateCategory(Category category);

  Future<void> archiveCategory(Category category);

  Future<List<Category>> getCategories({bool includeArchived = false});

  Stream<List<Category>> watchCategories({bool includeArchived = false});
}
