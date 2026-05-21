part of 'categories_bloc.dart';

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class CategoriesRequested extends CategoriesEvent {
  final bool includeArchived;

  const CategoriesRequested({this.includeArchived = false});

  @override
  List<Object?> get props => [includeArchived];
}

class CategoriesWatchRequested extends CategoriesEvent {
  final bool includeArchived;

  const CategoriesWatchRequested({this.includeArchived = false});

  @override
  List<Object?> get props => [includeArchived];
}

class CategoriesUpdated extends CategoriesEvent {
  final List<Category> categories;
  final String? message;

  const CategoriesUpdated(this.categories, {this.message});

  @override
  List<Object?> get props => [categories, message];
}

class CategoryCreateRequested extends CategoriesEvent {
  final Category category;
  final bool includeArchived;

  const CategoryCreateRequested(
    this.category, {
    this.includeArchived = false,
  });

  @override
  List<Object?> get props => [category, includeArchived];
}

class CategoryUpdateRequested extends CategoriesEvent {
  final Category category;
  final bool includeArchived;

  const CategoryUpdateRequested(
    this.category, {
    this.includeArchived = false,
  });

  @override
  List<Object?> get props => [category, includeArchived];
}

class CategoryArchiveRequested extends CategoriesEvent {
  final Category category;
  final bool includeArchived;

  const CategoryArchiveRequested(
    this.category, {
    this.includeArchived = false,
  });

  @override
  List<Object?> get props => [category, includeArchived];
}
