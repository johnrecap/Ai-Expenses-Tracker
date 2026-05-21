# Tasks: Expense List Scaling

**Input**: Design documents from `specs/051-expense-list-scaling/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Understand current read/query patterns.

- [X] T001 Inspect `packages/expense_repository/lib/src/expense_repo.dart` current expense read APIs.
- [X] T002 Inspect `packages/expense_repository/lib/src/firebase_expense_repo.dart` Firestore query ordering and metadata handling.
- [X] T003 Inspect `lib/screens/home/blocs/get_expenses_bloc/` for Home data loading assumptions.
- [X] T004 Inspect `lib/screens/expenses/blocs/expense_filter_cubit/` and `lib/services/expense_filter_service.dart` local filter assumptions.
- [X] T005 Inspect `firestore.indexes.json` for existing expense query indexes.

## Phase 2: Foundational

**Purpose**: Define paging contracts and tests.

- [X] T006 [P] Add repository tests for newest-first bounded expense reads.
- [X] T007 [P] Add repository tests for loading a second page without duplicate ids.
- [X] T008 [P] Add filter tests documenting behavior for bounded loaded data versus date-scoped reads.
- [ ] T009 [P] Add UI/bloc test for Expenses load-more states: idle, loading, exhausted, and error.

## Phase 3: User Story 1 - Load Recent Expenses Quickly (Priority: P1)

**Goal**: Initial Home/Expenses load is bounded and recent-first.

**Independent Test**: Repository and UI tests show bounded first page.

- [X] T010 [US1] Add an expense page/cursor model in `packages/expense_repository` if needed.
- [X] T011 [US1] Add bounded read API to `ExpenseRepository`.
- [X] T012 [US1] Implement bounded Firestore query in `FirebaseExpenseRepo` with stable date/id ordering.
- [X] T013 [US1] Update Home data loading to request recent expenses only.
- [X] T014 [US1] Update Expenses screen state to display the initial page.

## Phase 4: User Story 2 - Preserve Filtering Semantics With Bounded Reads (Priority: P2)

**Goal**: Filters remain understandable with paged data.

**Independent Test**: Filter tests specify loaded-scope behavior.

- [X] T015 [US2] Keep date range filtering as the primary Firestore scope where available.
- [X] T016 [US2] Update `ExpenseFilterCubit` to distinguish all loaded expenses from all historical expenses.
- [X] T017 [US2] Add localized UI copy when search/filter results are limited to loaded or date-scoped data.
- [X] T018 [US2] Ensure reset/filter changes refresh the correct page scope without duplicating rows.

## Phase 5: User Story 3 - Avoid Hidden Cost And Index Regressions (Priority: P3)

**Goal**: Firestore query patterns stay deployable and cost-aware.

**Independent Test**: Index review covers any new query pattern.

- [X] T019 [US3] Update `firestore.indexes.json` for new expense ordering/query patterns if required.
- [X] T020 [US3] Update `docs/firebase/` or README with pagination query/index notes.
- [X] T021 [US3] Verify pending-write sync badges still render for locally created expenses.

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T022 Run `flutter analyze --no-pub`.
- [X] T023 Run targeted repository, expenses, and home tests.
- [X] T024 Update `docs/implementation_plans/deferred-and-advanced-work.md` if full-history search remains a new later-stage item.
- [X] T025 Update `specs/051-expense-list-scaling/tasks.md` checkboxes as tasks complete.

## Dependencies & Execution Order

- T001-T005 before contract tests.
- T006-T009 before implementation.
- US1 is MVP.
- US2 should follow before public release so filtering copy is honest.
- US3 follows every query change.

## Implementation Strategy

Ship bounded recent-first reads first. Add load-more and filter copy next. Do not add global search infrastructure in this plan.
