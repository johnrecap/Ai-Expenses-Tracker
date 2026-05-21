import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/categories/blocs/categories_bloc/categories_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCategoryRepository implements CategoryRepository {
  final List<Category> categories;
  bool failNext = false;
  Category? createdCategory;
  Category? updatedCategory;
  Category? archivedCategory;

  FakeCategoryRepository(this.categories);

  @override
  Future<void> archiveCategory(Category category) async {
    _throwIfNeeded();
    archivedCategory = category;
    final index = categories.indexWhere(
      (item) => item.categoryId == category.categoryId,
    );
    if (index != -1) {
      categories[index] = categories[index].copyWith(isArchived: true);
    }
  }

  @override
  Future<void> createCategory(Category category) async {
    _throwIfNeeded();
    createdCategory = category;
    categories.add(category);
  }

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async {
    _throwIfNeeded();
    return _filtered(includeArchived);
  }

  @override
  Future<void> updateCategory(Category category) async {
    _throwIfNeeded();
    updatedCategory = category;
    final index = categories.indexWhere(
      (item) => item.categoryId == category.categoryId,
    );
    if (index != -1) {
      categories[index] = category;
    }
  }

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    return Stream.value(_filtered(includeArchived));
  }

  List<Category> _filtered(bool includeArchived) {
    if (includeArchived) return List<Category>.from(categories);
    return categories.where((category) => !category.isArchived).toList();
  }

  void _throwIfNeeded() {
    if (!failNext) return;
    failNext = false;
    throw Exception('repository failure');
  }
}

Category _category({
  String id = 'food',
  String name = 'Food',
  bool isArchived = false,
}) {
  return Category(
    categoryId: id,
    userId: 'user-1',
    name: name,
    totalExpenses: 0,
    icon: 'food',
    color: 4280391411,
    isArchived: isArchived,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}

void main() {
  test('loads active categories only by default', () async {
    final repository = FakeCategoryRepository([
      _category(),
      _category(id: 'old', name: 'Old', isArchived: true),
    ]);
    final bloc = CategoriesBloc(repository);
    final loaded = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<CategoriesLoading>(),
        isA<CategoriesSuccess>().having(
          (state) => state.categories.length,
          'active category count',
          1,
        ),
      ]),
    );

    bloc.add(const CategoriesRequested());

    await loaded;
    await bloc.close();
  });

  test('creates a category through repository', () async {
    final repository = FakeCategoryRepository([]);
    final bloc = CategoriesBloc(repository);
    final category = _category();
    final created = expectLater(
      bloc.stream,
      emitsThrough(isA<CategoryActionSuccess>()),
    );

    bloc.add(CategoryCreateRequested(category));

    await created;
    expect(repository.createdCategory, category);

    await bloc.close();
  });

  test('archives a category instead of deleting it', () async {
    final category = _category();
    final repository = FakeCategoryRepository([category]);
    final bloc = CategoriesBloc(repository);
    final archived = expectLater(
      bloc.stream,
      emitsThrough(isA<CategoryActionSuccess>()),
    );

    bloc.add(CategoryArchiveRequested(category));

    await archived;
    expect(repository.archivedCategory, category);
    expect(repository.categories.single.isArchived, isTrue);

    await bloc.close();
  });

  test('emits failure when repository fails', () async {
    final repository = FakeCategoryRepository([]);
    final bloc = CategoriesBloc(repository);
    repository.failNext = true;
    final failure = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<CategoriesLoading>(),
        isA<CategoriesFailure>(),
      ]),
    );

    bloc.add(const CategoriesRequested());

    await failure;
    await bloc.close();
  });
}
