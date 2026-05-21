# Tasks: Decimal Amounts Support

**Input**: Design documents from `specs/050-decimal-amounts-support/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Audit every amount path before changing types.

- [x] T001 Search for `int amount`, `_intFromValue`, and `int.tryParse` amount usage in `lib/` and `packages/expense_repository/`.
- [x] T002 List amount consumers: Add Expense, Expenses filters, Reports, Export, AI preview, Recurring, Home summary, budgets, saving goals, and rules tests.
- [x] T003 Identify tests that currently assume integer expense amounts.
- [x] T004 Confirm Firestore rules `positiveMoney` accepts int and float.

## Phase 2: Foundational

**Purpose**: Add failing decimal tests before type changes.

- [x] T005 [P] Add repository entity test for loading integer `amount: 120` and decimal `amount: 120.75`.
- [x] T006 [P] Add Add Expense widget/form test for accepting `12.50` and rejecting invalid values.
- [x] T007 [P] Add filter service or filter sheet test for decimal min/max values.
- [x] T008 [P] Add report/export test fixture with decimal expenses.
- [x] T009 [P] Add rules test in `functions/test/firestoreRules.rules.ts` for valid decimal amount and invalid negative decimal amount.

## Phase 3: User Story 1 - Enter And Save Decimal Expenses (Priority: P1)

**Goal**: Users can save decimal expense amounts.

**Independent Test**: Add Expense decimal test passes.

- [x] T010 [US1] Change `Expense.amount` in `packages/expense_repository/lib/src/models/expense.dart` from `int` to decimal-capable numeric type.
- [x] T011 [US1] Change `ExpenseEntity.amount` in `packages/expense_repository/lib/src/entities/expense_entity.dart` to the same decimal-capable type.
- [x] T012 [US1] Replace entity amount parsing with a helper that accepts int, float, num, and numeric string values.
- [x] T013 [US1] Update Add Expense amount parsing in `lib/screens/add_expense/views/add_expense.dart` to accept decimal values.
- [x] T014 [US1] Update currency formatting in `lib/screens/settings/utils/currency_formatter.dart` to avoid noisy decimal artifacts.

## Phase 4: User Story 2 - Existing Integer Data Remains Compatible (Priority: P1)

**Goal**: Old documents and fixtures still work.

**Independent Test**: Integer fixture repository tests pass unchanged or with expected type updates.

- [x] T015 [US2] Update repository tests to assert old integer documents map to whole decimal amounts.
- [x] T016 [US2] Update existing expense test fixtures to compile with the new amount type without changing expected user-visible values.
- [x] T017 [US2] Verify Firestore rules still deny zero, negative, and non-numeric amounts.

## Phase 5: User Story 3 - Calculations And Exports Handle Decimals (Priority: P2)

**Goal**: All downstream amount consumers preserve decimals.

**Independent Test**: Reports, filters, exports, AI preview, and recurring tests include decimal cases.

- [x] T018 [US3] Update expense filter models/services/widgets to use decimal min/max parsing.
- [x] T019 [US3] Update report calculators and Home summary calculators if they currently assume integer expense amounts.
- [x] T020 [US3] Update CSV/Excel/PDF export row formatting to preserve decimal values.
- [x] T021 [US3] Update `AiActionPreview.amount` and AI preview edit parsing to accept decimals.
- [x] T022 [US3] Update recurring expense model/entity/form amount handling to accept decimals or document a deliberate exclusion.
- [x] T023 [US3] Update any affected l10n validation messages if wording currently says whole numbers.

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T024 Run `flutter analyze --no-pub`.
- [ ] T025 Run targeted repository/service/UI tests for decimal amount coverage.
- [ ] T026 Run `cd functions; npm run test:rules`.
- [x] T027 Search for remaining expense-related `int.tryParse` amount usage and document any intentional survivors.
- [x] T028 Update `specs/050-decimal-amounts-support/tasks.md` checkboxes as tasks complete.

## Dependencies & Execution Order

- T001-T004 before tests.
- T005-T009 before implementation.
- US1 and US2 must be implemented together to preserve data compatibility.
- US3 can be staged after core save/load behavior works.

## Implementation Strategy

Treat the model/entity type change as the central migration. Keep commits small by updating one consumer group at a time after the core model compiles.
