# Implementation Plan: Stabilization And Baseline

## Technical Context

Flutter app using Bloc, Firebase initialization, and a local `expense_repository` package. Current tests are the default counter test and must be replaced.

## Architecture

Keep existing screens and blocs. Make narrow safety fixes in UI validation, controller lifecycle, typo cleanup, and test setup.

## Files

- Modify: `test/widget_test.dart`
- Modify: `lib/screens/add_expense/views/add_expense.dart`
- Modify: `lib/screens/add_expense/views/category_creation.dart`
- Modify: `lib/screens/home/views/home_screen.dart`
- Modify: `lib/screens/home/views/main_screen.dart`
- Modify: `lib/app_view.dart`

## Data Model

No data model change.

## Risks

- Widget tests may need Firebase mocking or guarded initialization.
- `Color.toARGB32()` availability depends on installed Flutter SDK.

## Verification

- Run `flutter pub get`
- Run `flutter analyze`
- Run `flutter test`

## Detailed Execution Guidance

- Start with tests before UI edits so the worker sees the current failure clearly.
- Keep fixes scoped to safety and baseline quality; do not add auth or new models here.
- Prefer small widget-level changes over architectural refactors.
- If Firebase blocks tests, solve the test bootstrap narrowly instead of changing production app startup broadly.
- Report the before/after analyzer and test results in the implementation summary.
