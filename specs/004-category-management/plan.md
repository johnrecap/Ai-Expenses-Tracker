# Implementation Plan: Category Management

## Technical Context

Categories are currently created from a dialog inside Add Expense and are stored globally.

## Architecture

Split category operations into their own repository and screen. Use archive instead of hard delete to preserve old expense display.

## Files

- Create: `packages/expense_repository/lib/src/category_repo.dart`
- Create: `packages/expense_repository/lib/src/firebase_category_repo.dart`
- Create: `lib/screens/categories/blocs/categories_bloc/*`
- Create: `lib/screens/categories/views/categories_screen.dart`
- Create: `lib/screens/categories/widgets/category_form_dialog.dart`
- Modify: `packages/expense_repository/lib/src/models/category.dart`
- Modify: `packages/expense_repository/lib/src/entities/category_entity.dart`
- Modify: `lib/screens/add_expense/views/add_expense.dart`

## Data Model

Add `userId`, `createdAt`, `updatedAt`, `isArchived` to Category.

## Risks

- Existing Add Expense category selector must continue working.
- Categories already used by expenses should not be deleted.

## Verification

- Category serialization tests.
- Categories bloc tests.
- Manual create/edit/archive flow.

## Detailed Execution Guidance

- Split category repository first to prevent `ExpenseRepository` becoming a catch-all.
- Preserve the current icon asset approach; do not redesign the asset system.
- Archive must be the default destructive action.
- Add Expense should consume active categories from the new repository/Bloc.
- Old category creation helper can remain only as a wrapper while migrating to the reusable form.
