# Implementation Plan: Advanced Search And Filters

## Technical Context

Filtering depends on upgraded expense fields and category/payment/currency data.

## Architecture

Use date-scoped Firestore queries first, then local filtering through a pure service. Add a full Expenses screen.

## Files

- Create: `lib/services/expense_filter_service.dart`
- Create: `lib/screens/expenses/blocs/expense_filter_cubit/*`
- Create: `lib/screens/expenses/views/expenses_screen.dart`
- Create: `lib/screens/expenses/widgets/expense_filter_sheet.dart`
- Create: `lib/screens/expenses/widgets/expense_search_bar.dart`
- Modify: `packages/expense_repository/lib/src/models/expense_filter.dart`
- Modify: `packages/expense_repository/lib/src/firebase_expense_repo.dart`
- Modify: `lib/screens/home/views/main_screen.dart`

## Data Model

`ExpenseFilter`: query, date range, category ids, amount range, payment methods, currency.

## Risks

- Firestore compound indexes can grow quickly if all filters move server-side.
- Local filtering is acceptable for first version.

## Verification

- Unit tests for filter combinations.
- Manual search/filter/reset flow.

## Detailed Execution Guidance

- Implement pure filtering before UI to simplify tests.
- Use server-side date range only for the first Firestore optimization.
- Avoid adding many Firestore composite indexes until product usage proves the need.
- Filter state should be resettable from one action.
- Search should include description and category labels for old and new expense shapes.
