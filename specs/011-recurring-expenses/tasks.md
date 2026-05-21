# Tasks: Recurring Expenses

## Implementation Intent

Support daily, weekly, and monthly recurring expenses with client-side materialization on app open. Server-side scheduling is explicitly future work.

---

## Phase 1: Data Layer

### T001 - Create `RecurringFrequency`

**Files:** Create `packages/expense_repository/lib/src/models/recurring_expense.dart`.

**Steps:** Define `daily`, `weekly`, `monthly`; add string mapping.

**Done When:** Recurrence can be serialized.

### T002 - Create `RecurringExpense`

**Steps:** Include id, userId, amount, category snapshot/id, description, payment, currency, startDate, nextRunDate, optional endDate, frequency, active, timestamps.

**Done When:** A recurring rule stores all data needed to generate expenses.

### T003 - Create Entity

**Files:** Create `packages/expense_repository/lib/src/entities/recurring_expense_entity.dart`.

**Steps:** Serialize every field; default old/missing active to true if needed.

**Done When:** Firestore document mapping is complete.

### T004 - Create Repository Interface

**Files:** Create `packages/expense_repository/lib/src/recurring_expense_repo.dart`.

**Steps:** Define create, update, archive/pause, watch active, get due.

**Done When:** UI and scheduler use interface.

### T005 - Implement Firebase Repository

**Files:** Create `packages/expense_repository/lib/src/firebase_recurring_expense_repo.dart`.

**Steps:** Use `users/{userId}/recurring_expenses`; query active items with `nextRunDate <= now`.

**Done When:** Due recurring rules can be loaded.

---

## Phase 2: Scheduler

### T006 - Create Scheduler

**Files:** Create `lib/services/recurring_expense_scheduler.dart`.

**Steps:** Accept due rules, generate expense instances, compute following nextRunDate.

**Done When:** Logic is pure/testable.

### T007 - Daily Logic

**Steps:** Add one day per occurrence until nextRunDate is after now or endDate.

**Done When:** Missed multiple daily occurrences are handled.

### T008 - Weekly Logic

**Steps:** Add seven days per occurrence; preserve original schedule day.

**Done When:** Weekly subscriptions generate correctly.

### T009 - Monthly Logic

**Steps:** Add one month; handle short months by clamping to valid last day.

**Done When:** Monthly rent on 31st does not crash in February.

### T010 - Duplicate Prevention

**Steps:** Use deterministic generated expense id or Firestore transaction: recurring id + scheduled date; update nextRunDate after write.

**Done When:** App restart does not duplicate generated expense.

---

## Phase 3: UI And Integration

### T011 - Create Bloc

**Files:** Create `lib/screens/recurring_expenses/blocs/recurring_expense_bloc/`.

**Steps:** Load, create, update, pause/archive; emit errors.

**Done When:** UI has state manager.

### T012 - Create Screen

**Files:** Create `lib/screens/recurring_expenses/views/recurring_expenses_screen.dart`.

**Steps:** List active recurring expenses, next run, frequency, amount, pause/edit actions.

**Done When:** User can manage recurring rules.

### T013 - Create Form

**Files:** Create `lib/screens/recurring_expenses/widgets/recurring_expense_form.dart`.

**Steps:** Select amount, category, payment, currency, start, frequency, optional end.

**Done When:** User can create recurring expense.

### T014 - Process Due Items On App Open

**Files:** App startup/home initialization.

**Steps:** After auth and repositories are ready, load due rules and generate due expenses.

**Done When:** Due expenses appear after app open.

### T015 - Mark Generated Expenses

**Steps:** Set `source = recurring` and `recurringExpenseId`.

**Done When:** Reports and AI can identify generated expenses.

---

## Phase 4: Tests

### T016 - Next Run Tests

Daily, weekly, monthly, month-end, endDate.

### T017 - Duplicate Tests

Same recurring id and scheduled date should not create duplicates.

### T018 - Manual QA

Create a due recurring rule, restart/open app, confirm one expense generated.

---

## Completion Checklist

- [x] T001 - Create `RecurringFrequency`
- [x] T002 - Create `RecurringExpense`
- [x] T003 - Create Entity
- [x] T004 - Create Repository Interface
- [x] T005 - Implement Firebase Repository
- [x] T006 - Create Scheduler
- [x] T007 - Daily Logic
- [x] T008 - Weekly Logic
- [x] T009 - Monthly Logic
- [x] T010 - Duplicate Prevention
- [x] T011 - Create Bloc
- [x] T012 - Create Screen
- [x] T013 - Create Form
- [x] T014 - Process Due Items On App Open
- [x] T015 - Mark Generated Expenses
- [x] T016 - Next Run Tests
- [x] T017 - Duplicate Tests
- [ ] T018 - Manual QA

## Verification Status

- Coordinator verification has run after worker integration: `flutter pub get`, `flutter analyze`, and `flutter test --reporter expanded`.
- Unit coverage includes recurring entity serialization, daily/weekly/monthly next-run logic, end-date stopping, deterministic generated ids, and generated expense metadata.
- T018 remains open because it requires a real app/Firebase runtime QA pass: create a due recurring rule, reopen the authenticated app, and confirm exactly one generated expense appears.
