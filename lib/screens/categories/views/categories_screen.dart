import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/categories/blocs/categories_bloc/categories_bloc.dart';
import 'package:expenses_tracker/screens/categories/widgets/category_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _showCreateDialog(BuildContext context) async {
    final category = await showDialog<Category>(
      context: context,
      builder: (_) => const CategoryFormDialog(),
    );
    if (category == null || !context.mounted) return;
    context.read<CategoriesBloc>().add(CategoryCreateRequested(category));
  }

  Future<void> _showEditDialog(
    BuildContext context,
    Category category,
  ) async {
    final updatedCategory = await showDialog<Category>(
      context: context,
      builder: (_) => CategoryFormDialog(initialCategory: category),
    );
    if (updatedCategory == null || !context.mounted) return;
    context
        .read<CategoriesBloc>()
        .add(CategoryUpdateRequested(updatedCategory));
  }

  Future<void> _confirmArchive(
    BuildContext context,
    Category category,
  ) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.archiveCategory),
          content: Text(
            context.l10n.archiveCategoryMessage(category.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.archive),
            ),
          ],
        );
      },
    );

    if (shouldArchive != true || !context.mounted) return;
    context.read<CategoriesBloc>().add(CategoryArchiveRequested(category));
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        if (state is CategoriesFailure) {
          _showMessage(
            context,
            _localizedCategoryMessage(context, state.message),
          );
        } else if (state is CategoryActionSuccess) {
          _showMessage(
            context,
            _localizedCategoryMessage(context, state.message),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(context.l10n.categories),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateDialog(context),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading || state is CategoriesSaving) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoriesFailure) {
              return _CategoriesError(
                message: _localizedCategoryMessage(context, state.message),
                onRetry: () {
                  context
                      .read<CategoriesBloc>()
                      .add(const CategoriesRequested());
                },
              );
            }

            final categories = state is CategoriesSuccess
                ? state.categories
                    .where((category) => !category.isArchived)
                    .toList()
                : <Category>[];

            if (categories.isEmpty) {
              return Center(
                child: Text(
                  context.l10n.noActiveCategoriesYet,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryTile(
                  category: category,
                  onEdit: () => _showEditDialog(context, category),
                  onArchive: () => _confirmArchive(context, category),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

String _localizedCategoryMessage(BuildContext context, String message) {
  final l10n = context.l10n;
  switch (message) {
    case 'Failed to load categories.':
      return l10n.failedToLoadCategories;
    case 'Enter category name, icon, and color.':
      return l10n.enterCategoryNameIconColor;
    case 'Category created.':
      return l10n.categoryCreated;
    case 'Failed to create category.':
      return l10n.failedToCreateCategory;
    case 'Category updated.':
      return l10n.categoryUpdated;
    case 'Failed to update category.':
      return l10n.failedToUpdateCategory;
    case 'Select a category to archive.':
      return l10n.selectCategoryToArchive;
    case 'Category archived.':
      return l10n.categoryArchived;
    case 'Failed to archive category.':
      return l10n.failedToArchiveCategory;
    default:
      return message;
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CategoryIconView(
          iconKey: category.icon,
          backgroundColor: Color(category.color),
          size: 44,
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          context.l10n.categoryExpenseCount(category.totalExpenses),
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: context.l10n.edit,
              onPressed: onEdit,
              icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 18),
            ),
            IconButton(
              tooltip: context.l10n.archive,
              onPressed: onArchive,
              icon: const FaIcon(FontAwesomeIcons.boxArchive, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CategoriesError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
