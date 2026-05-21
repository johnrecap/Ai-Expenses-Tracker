# Tasks: AI-Assisted Add Expense Form

**Input**: `specs/059-ai-first-add-entrypoint/spec.md` and `plan.md`

## Phase 1: Current Flow Inspection

- [X] T001 Inspect Home floating action button manual add flow in `lib/screens/home/views/home_screen.dart`.
- [X] T002 Inspect existing AI Assistant parse flow and reusable cubit/model requirements in `lib/ai/` and `lib/screens/ai_assistant/`.
- [X] T003 Inspect `AddExpense` form controllers and selected state in `lib/screens/add_expense/views/add_expense.dart` to identify safe AI field-application points.
- [X] T004 Inspect guided tour targets/copy for manual expense and AI assistant targets under `lib/guided_tour/`.

## Phase 2: Tests First

- [X] T005 [P] Add Home navigation test verifying plus still opens `AddExpense` in `test/home/home_navigation_test.dart`.
- [X] T006 [P] Add Add Expense widget test verifying the AI widget appears above the manual amount field in `test/add_expense/`.
- [X] T007 [P] Add Add Expense widget/cubit test verifying an AI add-expense result auto-fills amount, description, category, payment method, currency, and date fields in `test/add_expense/` or `test/ai/`.
- [X] T008 [P] Add or update guided tour text test if tour copy changes in `test/guided_tour/`.

## Phase 3: AI Form-Fill Integration

- [X] T009 Keep the Home FAB route to `AddExpense` and only refactor provider wiring if needed in `lib/screens/home/views/home_screen.dart`.
- [X] T010 Create or extract a compact AI form-fill widget for Add Expense in `lib/screens/add_expense/widgets/` or an adjacent feature folder.
- [X] T011 Wire the AI widget to the existing AI parse service/cubit without writing expenses directly.
- [X] T012 Add an `applyAiPreviewToForm` path in `AddExpense` that updates controllers, selected category, selected payment method, selected currency, and date.
- [X] T013 Ensure missing amount/category/date/payment/currency values leave the corresponding manual fields editable and validatable by the existing Save logic.
- [X] T014 Ensure Save remains the only call to `CreateExpenseBloc.add(CreateExpense(...))`.

## Phase 4: Manual Form Preservation

- [X] T015 Keep all existing manual Add Expense fields and category creation behavior working in `lib/screens/add_expense/views/add_expense.dart`.
- [X] T016 Ensure AI failures, quota failures, settings load failures, and parser failures show non-blocking messages while the manual form remains usable.
- [X] T017 Ensure Home refresh/ad completion behavior after Save is unchanged.

## Phase 5: Copy, Localization, Tour

- [X] T018 Add English ARB keys for AI form-fill prompt, fill action, success, and failure helper text in `lib/l10n/app_en.arb`.
- [X] T019 Add Arabic ARB keys for the same labels in `lib/l10n/app_ar.arb`.
- [X] T020 Run `flutter gen-l10n`.
- [X] T021 Update guided tour copy/target descriptions to explain the plus button as AI-assisted manual form fill.

## Phase 6: Verification

- [X] T022 Run targeted Home, Add Expense, and AI tests.
- [X] T023 Run `flutter analyze --no-pub`.
- [ ] T024 Manually verify release/profile behavior on Android: plus opens Add Expense, AI fills form, user edits, Save persists, Home refreshes.

## Done Criteria

- Center plus opens the same Add Expense screen.
- AI widget sits above the manual form and fills it automatically.
- Manual form remains reliable and is the only save path.
- Home refreshes after the existing Save path.
