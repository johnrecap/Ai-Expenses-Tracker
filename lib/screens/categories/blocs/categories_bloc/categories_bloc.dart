import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository _categoryRepository;
  StreamSubscription<List<Category>>? _categoriesSubscription;

  CategoriesBloc(this._categoryRepository) : super(CategoriesInitial()) {
    on<CategoriesRequested>(_onRequested);
    on<CategoriesWatchRequested>(_onWatchRequested);
    on<CategoriesUpdated>(_onUpdated);
    on<CategoryCreateRequested>(_onCreateRequested);
    on<CategoryUpdateRequested>(_onUpdateRequested);
    on<CategoryArchiveRequested>(_onArchiveRequested);
  }

  Future<void> _onRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final categories = await _categoryRepository.getCategories(
        includeArchived: event.includeArchived,
      );
      emit(CategoriesSuccess(categories));
    } catch (_) {
      emit(const CategoriesFailure('Failed to load categories.'));
    }
  }

  Future<void> _onWatchRequested(
    CategoriesWatchRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    await _categoriesSubscription?.cancel();
    _categoriesSubscription = _categoryRepository
        .watchCategories(includeArchived: event.includeArchived)
        .listen(
          (categories) => add(CategoriesUpdated(categories)),
          onError: (_) => add(
            const CategoriesUpdated(
              [],
              message: 'Failed to load categories.',
            ),
          ),
        );
  }

  void _onUpdated(
    CategoriesUpdated event,
    Emitter<CategoriesState> emit,
  ) {
    if (event.message != null) {
      emit(CategoriesFailure(event.message!));
      return;
    }
    emit(CategoriesSuccess(event.categories));
  }

  Future<void> _onCreateRequested(
    CategoryCreateRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    if (!_isValid(event.category)) {
      emit(const CategoriesFailure('Enter category name, icon, and color.'));
      return;
    }

    emit(CategoriesSaving());
    try {
      await _categoryRepository.createCategory(event.category);
      emit(const CategoryActionSuccess('Category created.'));
      add(CategoriesRequested(includeArchived: event.includeArchived));
    } catch (_) {
      emit(const CategoriesFailure('Failed to create category.'));
    }
  }

  Future<void> _onUpdateRequested(
    CategoryUpdateRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    if (event.category.categoryId.isEmpty || !_isValid(event.category)) {
      emit(const CategoriesFailure('Enter category name, icon, and color.'));
      return;
    }

    emit(CategoriesSaving());
    try {
      await _categoryRepository.updateCategory(event.category);
      emit(const CategoryActionSuccess('Category updated.'));
      add(CategoriesRequested(includeArchived: event.includeArchived));
    } catch (_) {
      emit(const CategoriesFailure('Failed to update category.'));
    }
  }

  Future<void> _onArchiveRequested(
    CategoryArchiveRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    if (event.category.categoryId.isEmpty) {
      emit(const CategoriesFailure('Select a category to archive.'));
      return;
    }

    emit(CategoriesSaving());
    try {
      await _categoryRepository.archiveCategory(event.category);
      emit(const CategoryActionSuccess('Category archived.'));
      add(CategoriesRequested(includeArchived: event.includeArchived));
    } catch (_) {
      emit(const CategoriesFailure('Failed to archive category.'));
    }
  }

  bool _isValid(Category category) {
    return category.name.trim().isNotEmpty &&
        category.icon.trim().isNotEmpty &&
        category.color != 0;
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}
