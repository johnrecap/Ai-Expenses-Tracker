# Tasks: Expense Editing And Adjustments

**Input**: Design documents from `specs/087-expense-editing-adjustments/`  
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Audit

- [X] T001 Audit existing edit/delete code in `lib/screens/expenses/widgets/expense_edit_sheet.dart` and Expenses screen. Why: avoid rebuilding existing work. Expected: field/entry-point gap list. Risk: duplicate edit implementations. Modification: reused the existing edit sheet and Expenses popup action.
- [X] T002 Audit Home transaction row widgets in `lib/screens/home/`. Why: user expects Home items to be editable. Expected: best edit affordance location. Risk: edit remains hidden. Modification: added a Home transaction popup edit action.
- [X] T003 Audit repository update behavior in `packages/expense_repository`. Why: edits must persist and sync. Expected: update supports all fields. Risk: UI edits disappear after reload. Modification: existing Firebase/local update paths already upsert all expense fields; Home now calls the repository update path.

## Phase 2: Foundational Edit Draft

- [X] T004 [P] Create or harden `ExpenseEditDraft` model near `lib/screens/expenses/`. Why: form state should be explicit. Expected: validation and conversion-relevant change detection. Risk: widget mutates original expense prematurely. Modification: added `lib/screens/expenses/models/expense_edit_draft.dart`.
- [X] T005 [P] Add localized edit/adjustment copy in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`. Why: edit errors/actions are user-facing. Expected: Arabic/English labels for edit, adjust, add amount, subtract amount, invalid result. Risk: hardcoded strings. Modification: ran `flutter gen-l10n`.
- [X] T006 Add tests for draft validation in `test/expenses/expense_edit_draft_test.dart`. Why: amount/currency/category validation must not depend on UI. Expected: invalid amount and missing category fail. Risk: bad edits reach repository. Modification: covers validation, positive/negative deltas, and money-change detection.

## Phase 3: User Story 1 - Edit From Transaction Lists (P1)

**Independent Test**: Edit an expense from Home and verify amount/totals update.

- [X] T007 Add edit action to Home transaction row/menu in `lib/screens/home/`. Why: Home is the most common place users notice mistakes. Expected: edit sheet opens with selected expense. Risk: user cannot discover editing. Modification: added Home transaction popup edit action.
- [X] T008 Ensure Expenses list edit action is available and consistent in `lib/screens/expenses/`. Why: list/detail flow should match Home. Expected: same edit sheet, same validation, same messages. Risk: two different edit experiences. Modification: Home and Expenses both reuse `showExpenseEditSheet`.
- [X] T009 Add Home edit widget test in `test/home/home_navigation_test.dart`. Why: entry point can regress easily. Expected: tap edit, update amount, repository update called. Risk: UI appears but does not save. Modification: extended existing Home navigation fixture with an edit test.
- [X] T010 Add Expenses edit widget test in `test/expenses/expenses_screen_test.dart`. Why: existing screen must remain stable. Expected: edit opens with current values and saves update. Risk: delete/edit conflict. Modification: existing edit tests now include a settings repository for snapshot-aware save.

## Phase 4: User Story 2 - Money Edits Preserve Correctness (P1)

**Independent Test**: Money edits recompute snapshot; non-money edits preserve snapshot.

- [X] T011 Integrate Plan 084 snapshot decision into edit save. Why: edited converted expenses must stay correct. Expected: money changes recompute, non-money changes preserve. Risk: totals become stale or mutate accidentally. Modification: edit save calls `MoneySnapshotService.preserveOrRefreshForEdit`.
- [ ] T012 Add converted edit tests in `test/expenses/expense_edit_snapshot_test.dart`. Why: this is a high-risk finance path. Expected: amount/currency/date cases covered. Risk: edit breaks immutable conversion. Modification: use fixed rates.
- [X] T013 Update calculators refresh behavior after edit. Why: UI totals should update after repository emits changed expense. Expected: Home/Reports show edited amount. Risk: stale cached summaries. Modification: Home update triggers repository update and refreshes `GetExpensesBloc` when available.

## Phase 5: User Story 3 - Quick Amount Adjustment (P2)

**Independent Test**: Add/subtract amount from existing expense and verify final value.

- [X] T014 Design quick adjustment UI in edit sheet. Why: user explicitly asked to add/remove money quickly. Expected: replace amount directly plus optional +/- adjustment controls. Risk: cluttered form. Modification: added a compact quick adjustment panel under the amount field.
- [X] T015 Implement adjustment validation. Why: final amount must stay positive. Expected: subtraction below/equal zero blocked. Risk: invalid financial data. Modification: invalid adjustments show localized error text.
- [X] T016 Add adjustment tests in `test/expenses/expense_edit_draft_test.dart`. Why: deltas are easy to get wrong. Expected: add, subtract, invalid subtract. Risk: wrong amount saved. Modification: covered delta math in the draft test file.

## Phase 6: Pending/Offline Edits

- [ ] T017 Define pending edit policy with Plan 086 sync queue. Why: editing unsynced creates can conflict. Expected: merge queued changes or show clear wait/retry message. Risk: duplicate or lost updates. Modification: add policy tests.
- [ ] T018 Add sync-safe update tests in `test/api/sync_coordinator_test.dart` if VPS mode is affected. Why: update after create must be ordered. Expected: create then update sync order. Risk: server stores stale first version. Modification: preserve client timestamps/revisions.

## Phase 7: Verification

- [X] T019 Run `flutter gen-l10n`. Why: new strings. Expected: generated files updated. Risk: stale localization.
- [ ] T020 Run targeted edit/Home/Expenses tests. Why: edit touches core transaction flow. Expected: all tests pass. Risk: broken save/delete. Modification: attempted `flutter test --no-pub test/expenses/expense_edit_draft_test.dart --reporter expanded`, but Flutter tool hung spawning stuck `git.exe` processes before returning results.
- [ ] T021 Run `flutter analyze --no-pub`. Why: catch type/UI mistakes. Expected: no analyzer errors. Risk: release build failure. Modification: direct Dart analyzer on changed Dart files reported "No issues found" before the known telemetry permission error; full Flutter analyzer remains pending because Flutter tool commands are hanging in this environment.

## Dependencies

- T004-T006 block edit implementation.
- T011 depends on Plan 084 snapshot helper or a compatible stub.
- T017 depends on Plan 086 queue policy.

## MVP Scope

Complete T001-T013 first for full edit correctness. Quick adjustment can follow as the second increment.
