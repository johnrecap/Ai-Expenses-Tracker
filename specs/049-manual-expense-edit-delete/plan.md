# Implementation Plan: Manual Expense Edit And Delete

**Branch**: `049-manual-expense-edit-delete` | **Date**: 2026-05-18 | **Spec**: `specs/049-manual-expense-edit-delete/spec.md`  
**Input**: Manual expense list lacks edit/delete actions despite repository support.

## Summary

Add explicit manual edit and delete actions to expense rows, reuse existing expense form patterns and repository methods, localize all copy, and add tests for update/delete behavior.

## Technical Context

**Language/Version**: Dart 3.x, Flutter, Bloc/Cubit  
**Primary Dependencies**: Existing `ExpenseRepository`, category/settings repositories, l10n  
**Storage**: Existing Firestore expense documents through repository layer  
**Testing**: Widget tests and fake repository tests; analyzer  
**Target Platform**: Flutter mobile app, Android priority  
**Project Type**: Expense management UI feature  
**Performance Goals**: No list performance regression for normal expense counts  
**Constraints**: No direct Firestore in widgets; no AI service usage; delete requires confirmation  
**Scale/Scope**: Expenses screen, reusable expense form/edit flow, l10n, tests

## Constitution Check

- Repository access remains behind interfaces.
- AI mutation safety is not weakened.
- User-facing strings use l10n.
- Category deletion remains archival; this feature only deletes expense documents.

**Gate Status**: PASS.

## Project Structure

```text
lib/screens/expenses/views/expenses_screen.dart
lib/screens/expenses/widgets/
lib/screens/add_expense/views/add_expense.dart
lib/screens/add_expense/blocs/
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
test/expenses/
test/helpers/fake_repositories.dart
packages/expense_repository/lib/src/expense_repo.dart
```

**Structure Decision**: Prefer extracting a reusable expense form only if it avoids duplicating Add/Edit validation. Otherwise create a focused edit sheet/screen that follows existing Add Expense patterns.

## Implementation Notes

- Decide whether edit is a full screen or bottom sheet based on existing app navigation patterns.
- Use overflow menu or trailing icon buttons on `_ExpenseTile`; avoid cluttering amount/date display.
- For delete confirmation, include category, amount, date, and optional description context.
- On edit, preserve `expenseId`, `userId`, `createdAt`, `source`, `recurringExpenseId`, and `aiActionId`.
- Update `updatedAt` on edit.
- Refresh list through existing stream/bloc behavior.

## Verification

```text
flutter gen-l10n
flutter analyze --no-pub
flutter test --no-pub test/expenses --reporter expanded --concurrency=1 --timeout 45s
flutter test --no-pub test/repository/expense_repository_operations_test.dart --reporter expanded --concurrency=1 --timeout 45s
```

## Deferred Items To Keep In Mind

Pagination/limits for very large expense lists is handled by `specs/051-expense-list-scaling/` and should not be mixed into this edit/delete feature.

## Complexity Tracking

No constitution violations.
