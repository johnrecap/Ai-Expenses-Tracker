# Tasks: Monthly Budget

## Implementation Intent

Allow each authenticated user to define a monthly budget and see current spending progress. This plan must use actual expense data and must not rely on hardcoded totals.

---

## Phase 1: Data Layer

### T001 - Create `Budget` Model

**Files:** Create `packages/expense_repository/lib/src/models/budget.dart`.

**Steps:** Add `budgetId`, `userId`, `month`, `year`, `amount`, `currency`, `warningThresholdPercent`, `createdAt`, `updatedAt`. Add `empty`/factory helpers if consistent with existing model style.

**Done When:** Budget can represent one user's monthly limit.

### T002 - Create `BudgetEntity`

**Files:** Create `packages/expense_repository/lib/src/entities/budget_entity.dart`.

**Steps:** Map budget fields to Firestore; validate month range 1-12; default threshold to 80 if missing.

**Done When:** Budget serializes safely.

### T003 - Create `BudgetRepository`

**Files:** Create `packages/expense_repository/lib/src/budget_repo.dart`.

**Steps:** Define create/update current month budget, get current month budget, watch current month budget.

**Done When:** UI has an interface for budget operations.

### T004 - Implement `FirebaseBudgetRepository`

**Files:** Create `packages/expense_repository/lib/src/firebase_budget_repo.dart`.

**Steps:** Store docs under `users/{userId}/budgets/{yyyy-MM}`; require userId; write timestamps.

**Done When:** Budgets are user-scoped and month-scoped.

---

## Phase 2: Budget Logic

### T005 - Create `BudgetCalculator`

**Files:** Create `lib/services/budget_calculator.dart`.

**Steps:** Accept budget and expense list; calculate spent amount for budget month/year and matching currency.

**Done When:** Budget math is testable without Flutter UI.

### T006 - Calculate Progress Values

**Steps:** Return spent, remaining, and percent used. Percent should be 0 if budget amount is 0 or missing.

**Done When:** UI can render progress card from one result object.

### T007 - Calculate Warnings

**Steps:** Return `nearLimit` when percent >= threshold and < 100; return `exceeded` when spent > budget amount.

**Done When:** Home can show warning/exceeded states.

### T008 - Define Mixed-Currency Behavior

**Steps:** Only include expenses matching budget currency in first version; expose ignored-currency count or note for UI.

**Done When:** The app does not add incompatible currencies together.

---

## Phase 3: Bloc And UI

### T009 - Create `BudgetBloc`

**Files:** Create `lib/screens/budget/blocs/budget_bloc/`.

**Steps:** Add load, save, update events; emit loading, loaded, saving, saved, failure.

**Done When:** Budget screen does not call repository directly.

### T010 - Create `BudgetScreen`

**Files:** Create `lib/screens/budget/views/budget_screen.dart`.

**Steps:** Form fields for amount, currency, warning threshold; validate amount > 0 and threshold between 1 and 100.

**Done When:** User can set and update current month budget.

### T011 - Create `BudgetProgressCard`

**Files:** Create `lib/screens/budget/widgets/budget_progress_card.dart`.

**Steps:** Show budget amount, spent, remaining, percent bar, and warning text.

**Done When:** Widget can render normal, near-limit, and exceeded states.

### T012 - Add Budget Card To Home

**Files:** Modify `lib/screens/home/views/main_screen.dart` or `home_screen.dart`.

**Steps:** Load budget and current expenses; pass calculated progress to card; keep layout consistent.

**Done When:** Home shows monthly budget progress.

### T013 - Add Warning And Exceeded UI

**Steps:** Use distinct colors/messages for near limit and exceeded; avoid intrusive dialogs in this plan.

**Done When:** User can recognize budget status at a glance.

---

## Phase 4: Tests

### T014 - Calculator Tests

Test no budget, zero spending, near limit, exceeded, exact limit, wrong currency ignored.

### T015 - Bloc Tests

Test load success, save success, repository failure.

### T016 - Manual QA

Create expenses in current month, set budget, confirm Home progress updates.

---

## Completion Checklist

- [x] T001 - Created `Budget` model with user/month/currency/threshold/timestamp fields.
- [x] T002 - Created `BudgetEntity` with Firestore mapping, month validation, and default warning threshold.
- [x] T003 - Created `BudgetRepository` abstraction.
- [x] T004 - Implemented `FirebaseBudgetRepository` under `users/{userId}/budgets/{yyyy-MM}`.
- [x] T005 - Created pure `BudgetCalculator`.
- [x] T006 - Added spent, remaining, percent used, and ignored-currency progress values.
- [x] T007 - Added normal, near-limit, exceeded, and none status calculation.
- [x] T008 - Implemented conservative mixed-currency behavior: only matching budget currency is included, ignored count is exposed.
- [x] T009 - Created `BudgetBloc` with load, watch, save, loaded, saved, and failure flows.
- [x] T010 - Created `BudgetScreen` with amount, currency, and threshold form validation.
- [x] T011 - Created `BudgetProgressCard`.
- [x] T012 - Added budget progress card to Home using current expenses and current month budget.
- [x] T013 - Added distinct near-limit and exceeded messages/colors in the progress card.
- [x] T014 - Added calculator tests for no budget, normal, near-limit, exact limit, exceeded, and wrong-currency ignored behavior.
- [x] T015 - Added BudgetBloc tests for load success, save success, and repository failure.
- [x] T016 - Automated verification passed. Manual Firebase QA still requires a configured Firebase project and authenticated test user.
