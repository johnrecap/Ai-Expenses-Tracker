part of 'categories_bloc.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

final class CategoriesInitial extends CategoriesState {}

final class CategoriesLoading extends CategoriesState {}

final class CategoriesSaving extends CategoriesState {}

final class CategoriesSuccess extends CategoriesState {
  final List<Category> categories;

  const CategoriesSuccess(this.categories);

  @override
  List<Object?> get props => [categories];
}

final class CategoryActionSuccess extends CategoriesState {
  final String message;

  const CategoryActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class CategoriesFailure extends CategoriesState {
  final String message;

  const CategoriesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
