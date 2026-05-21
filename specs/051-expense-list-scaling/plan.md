# Implementation Plan: Expense List Scaling

**Branch**: `051-expense-list-scaling` | **Date**: 2026-05-18 | **Spec**: `specs/051-expense-list-scaling/spec.md`  
**Input**: Future UX/performance improvement for large expense histories.

## Summary

Introduce bounded/paginated expense reads for Home and Expenses while preserving existing filter semantics, offline sync feedback, and Firestore index safety.

## Technical Context

**Language/Version**: Dart 3.x, Flutter, Firestore  
**Primary Dependencies**: Existing `ExpenseRepository`, Firestore query cursors, `ExpenseFilterService`, `GetExpensesBloc`  
**Storage**: Existing `users/{userId}/expenses` documents and indexes  
**Testing**: Repository tests, bloc/widget tests, filter tests, rules/index review  
**Target Platform**: Flutter app with Firestore backend  
**Project Type**: Performance and UX scalability improvement  
**Performance Goals**: Initial list load is bounded and responsive for large histories  
**Constraints**: Preserve user ownership, offline pending-write feedback, and date-scoped filtering model  
**Scale/Scope**: Expense repository reads, Home/Expenses list loading, filters, indexes, tests

## Constitution Check

- Expense filtering keeps Firestore queries conservative: date-scoped reads first, local deterministic filtering after.
- Firestore data remains user-scoped.
- Offline sync feedback continues to use Firestore metadata.
- Mixed-currency totals remain conservative.

**Gate Status**: PASS.

## Project Structure

```text
packages/expense_repository/lib/src/expense_repo.dart
packages/expense_repository/lib/src/firebase_expense_repo.dart
packages/expense_repository/lib/src/models/expense_filter.dart
lib/screens/home/blocs/get_expenses_bloc/
lib/screens/expenses/blocs/expense_filter_cubit/
lib/screens/expenses/views/expenses_screen.dart
lib/screens/expenses/widgets/
lib/services/expense_filter_service.dart
firestore.indexes.json
test/repository/
test/expenses/
test/home/
```

**Structure Decision**: Add paging to repository/query boundaries first, then adapt Home and Expenses state. Keep local filter service deterministic and explicit about loaded scope.

## Implementation Notes

- Define an `ExpensePage` or similar model only if repository streams cannot express paging cleanly.
- Keep Home lightweight: recent expenses only, not all history.
- Expenses screen can own "load more" state.
- Date filters should continue to reduce Firestore reads before local filters.
- Search without date range should either use loaded pages only with clear copy or require a date range.
- Update indexes for `userId/path + date/order + cursor` patterns as needed.

## Verification

```text
flutter analyze --no-pub
flutter test --no-pub test/repository test/expenses test/home --reporter expanded --concurrency=1 --timeout 45s
```

Index changes should also be reviewed against `firebase.json` and `firestore.indexes.json`.

## Deferred Items To Keep In Mind

This plan is intentionally after correctness and localization fixes. A dedicated full-history search index remains future work if product needs global search beyond loaded/date-scoped data.

## Complexity Tracking

No constitution violations.
