# Tasks: Manual Expense Edit And Delete

**Input**: Design documents from `specs/049-manual-expense-edit-delete/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Understand existing add/list/repository patterns.

- [X] T001 Inspect `lib/screens/expenses/views/expenses_screen.dart` `_ExpenseTile` layout and dependencies.
- [X] T002 Inspect `lib/screens/add_expense/views/add_expense.dart` validation and save flow.
- [X] T003 Inspect `packages/expense_repository/lib/src/expense_repo.dart` update/delete contracts.
- [X] T004 Inspect `test/helpers/fake_repositories.dart` existing fake update/delete support.
- [X] T005 Inspect existing `test/expenses/` coverage.

## Phase 2: Foundational

**Purpose**: Add l10n and test scaffolding before UI changes.

- [X] T006 Add edit/delete action labels, dialog copy, validation messages, success messages, and failure messages to `lib/l10n/app_en.arb`.
- [X] T007 Add matching Arabic strings to `lib/l10n/app_ar.arb`.
- [X] T008 Run `flutter gen-l10n`.
- [X] T009 Add or update fake repository methods in `test/helpers/fake_repositories.dart` to capture updated/deleted expenses.

## Phase 3: User Story 1 - Edit An Existing Expense Manually (Priority: P1)

**Goal**: Existing expenses can be corrected without AI.

**Independent Test**: Editing an expense calls `updateExpense` with preserved ids and changed fields.

- [X] T010 [P] [US1] Add a failing widget test in `test/expenses/` for opening edit from an expense row with prefilled values.
- [X] T011 [P] [US1] Add a failing widget/bloc test in `test/expenses/` for saving a changed valid expense.
- [X] T012 [US1] Add edit action UI to `_ExpenseTile` or a new `ExpenseTileActions` widget.
- [X] T013 [US1] Create an edit expense form/sheet/screen that prefills amount, category, date, description, payment method, and currency.
- [X] T014 [US1] Reuse or extract validation from Add Expense so invalid edit input is blocked with localized errors.
- [X] T015 [US1] Wire save to `ExpenseRepository.updateExpense` through the existing Bloc/Cubit pattern.
- [X] T016 [US1] Preserve `expenseId`, `userId`, `createdAt`, `source`, `recurringExpenseId`, and `aiActionId` during edit.

## Phase 4: User Story 2 - Delete An Expense Manually With Confirmation (Priority: P1)

**Goal**: Expenses can be deleted manually only after explicit confirmation.

**Independent Test**: Cancel does nothing; confirm calls `deleteExpense(expenseId)`.

- [X] T017 [P] [US2] Add a failing widget test for delete cancel not calling repository delete.
- [X] T018 [P] [US2] Add a failing widget test for delete confirm calling repository delete exactly once.
- [X] T019 [US2] Add delete action UI to the expense row action menu.
- [X] T020 [US2] Implement localized confirmation dialog with category, amount, and date context.
- [X] T021 [US2] Wire confirm to `ExpenseRepository.deleteExpense`.
- [X] T022 [US2] Show localized success/failure SnackBar or equivalent feedback.

## Phase 5: User Story 3 - Keep Manual And AI Mutation Paths Consistent (Priority: P2)

**Goal**: Manual mutations stay behind the same repository boundary as AI confirmation.

**Independent Test**: Static review and tests show widgets do not use Firestore or AI services directly.

- [X] T023 [US3] Verify no new widget imports `cloud_firestore`, Firebase auth, or AI service classes for edit/delete.
- [X] T024 [US3] Add a regression test or assertion preserving `source`, `recurringExpenseId`, and `aiActionId` on edit.
- [X] T025 [US3] Confirm deleting an expense does not touch category, recurring rule, or AI action repositories.

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T026 Run `flutter gen-l10n`.
- [X] T027 Run `flutter analyze --no-pub`.
- [X] T028 Run `flutter test --no-pub test/expenses --reporter expanded --concurrency=1 --timeout 45s`.
- [X] T029 Update `specs/049-manual-expense-edit-delete/tasks.md` checkboxes as tasks complete.

## Dependencies & Execution Order

- T001-T005 before l10n/test edits.
- T006-T009 before UI copy usage.
- US1 and US2 are both MVP and may be implemented in parallel only if they avoid the same widget file conflicts.
- US3 follows after both mutation paths exist.

## Implementation Strategy

Ship edit and delete together as the manual mutation MVP. Keep undo and advanced audit history out unless a separate spec defines them.
