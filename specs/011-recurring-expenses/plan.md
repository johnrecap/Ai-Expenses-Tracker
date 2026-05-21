# Implementation Plan: Recurring Expenses

## Technical Context

Recurring expenses depend on upgraded expense model and source tracking.

## Architecture

Store recurrence rules in Firestore and materialize due expenses on app open with duplicate protection.

## Files

- Create: `packages/expense_repository/lib/src/models/recurring_expense.dart`
- Create: `packages/expense_repository/lib/src/entities/recurring_expense_entity.dart`
- Create: `packages/expense_repository/lib/src/recurring_expense_repo.dart`
- Create: `packages/expense_repository/lib/src/firebase_recurring_expense_repo.dart`
- Create: `lib/services/recurring_expense_scheduler.dart`
- Create: `lib/screens/recurring_expenses/blocs/recurring_expense_bloc/*`
- Create: `lib/screens/recurring_expenses/views/recurring_expenses_screen.dart`
- Create: `lib/screens/recurring_expenses/widgets/recurring_expense_form.dart`

## Data Model

`RecurringExpense`: frequency, amount, category, payment, currency, start, nextRun, optional end, active.

## Risks

- Client-side generation is not guaranteed if app is not opened.
- Duplicate prevention should be transactional.

## Verification

- Date calculation tests.
- Duplicate prevention tests.
- Manual app-open generation flow.

## Detailed Execution Guidance

- Build scheduler as pure Dart before connecting Firestore.
- Use deterministic generated ids to make duplicate prevention easier.
- Do not rely on background execution in the first version.
- Generated expenses must be normal expenses with source metadata.
- Pausing a recurring rule must not modify generated past expenses.
