# Implementation Report: Category Budgets And Subscription Center

**Date**: 2026-05-17

## Completed

- Added `CategoryBudget` model/entity exports and `CategoryBudgetRepository`.
- Implemented `FirebaseCategoryBudgetRepository` under `users/{userId}/category_budgets`.
- Added explicit Firestore rules for `users/{userId}/category_budgets/{budgetId}`.
- Added `CategoryBudgetCalculator` and `CategoryBudgetCubit`.
- Added Category Budgets UI with current-month navigation, create/edit/archive, progress bars, threshold/exceeded states, and mixed-currency warnings.
- Added Home overflow menu entry for Category Budgets.
- Added `SubscriptionSummaryService` for active recurring rules, next due dates, monthly impact estimates, and currency grouping.
- Added Subscription Center UI with active recurring expenses, monthly impact totals, next due date, amount, payment method, frequency, and shortcut to recurring expense management.
- Added Home overflow menu entry for Subscription Center.
- Added focused tests for category budget entity serialization, calculator behavior, Cubit validation/load behavior, and subscription summaries.

## Changed Files

- `packages/expense_repository/lib/expense_repository.dart`
- `packages/expense_repository/lib/src/category_budget_repo.dart`
- `packages/expense_repository/lib/src/firebase_category_budget_repo.dart`
- `packages/expense_repository/lib/src/entities/category_budget_entity.dart`
- `packages/expense_repository/lib/src/entities/entities.dart`
- `packages/expense_repository/lib/src/models/category_budget.dart`
- `packages/expense_repository/lib/src/models/models.dart`
- `lib/screens/auth/views/auth_gate.dart`
- `lib/screens/home/views/home_screen.dart`
- `lib/screens/category_budgets/cubit/category_budget_cubit.dart`
- `lib/screens/category_budgets/cubit/category_budget_state.dart`
- `lib/screens/category_budgets/services/category_budget_calculator.dart`
- `lib/screens/category_budgets/views/category_budgets_screen.dart`
- `lib/screens/subscriptions/services/subscription_summary_service.dart`
- `lib/screens/subscriptions/views/subscription_center_screen.dart`
- `firestore.rules`
- `.specify/memory/constitution.md`
- `test/category_budgets/category_budget_calculator_test.dart`
- `test/category_budgets/category_budget_cubit_test.dart`
- `test/repository/category_budget_entity_test.dart`
- `test/subscriptions/subscription_summary_service_test.dart`
- `specs/033-category-budgets-subscriptions/tasks.md`
- `specs/033-category-budgets-subscriptions/implementation-report.md`

## Decisions

- Category budget document ids use `{yyyy-MM}_{categoryId}_{currency}` to keep one active budget per category/currency/month.
- Category budget deletion is archival through `isArchived`, matching the existing category and recurring expense patterns.
- Category budget progress sums only same-category, same-month, same-currency expenses and reports ignored mixed-currency expenses instead of converting.
- Subscription Center reads existing recurring rules only; it does not infer subscriptions from historical spending.
- Subscription monthly impact estimates use 30x daily, 52/12x weekly, and 1x monthly amounts.
- Alert tasks were left open because adding duplicate-safe local alert scheduling would require broader notification preference and scheduling changes than fit the current scoped implementation.

## Remaining Tasks

- T013 Add optional category budget alert preferences.
- T014 Schedule category budget and subscription due notifications.
- T015 remains open for manual device creation and Firestore rules emulator tests. Automated Flutter verification was completed by the parent review.

## Parent Verification

- `dart format` completed over the changed Dart areas.
- `flutter analyze` passed with no issues after one category budget entity lint fix and one subscription test const fix.
- Focused category budget/subscription tests passed.
- Full `flutter test --reporter expanded --concurrency=1 --timeout 45s` passed with 214 tests.
- `flutter build apk --release --no-tree-shake-icons` passed and produced `build/app/outputs/flutter-apk/app-release.apk`.

## Commands Not Run

Per user instruction, no verification/build commands were run:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build`
- `npm test`
- `npm build`

## Risks And Notes

- New UI strings are currently hardcoded, consistent with several nearby screens, but they should be localized in a later l10n pass.
- The Category Budgets screen calculates from the expense list already loaded in Home; newly added expenses after opening the screen require reopening or reloading from Home to refresh that in-memory list.
- Firestore rules are explicit for category budgets but not emulator-tested in this turn.
