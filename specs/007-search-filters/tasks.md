# Tasks: Advanced Search And Filters

## Implementation Intent

Provide a full expenses list that can be searched and filtered without turning Firestore queries into an unmaintainable index problem. First version should combine a reasonable Firestore date query with local filtering.

---

## Phase 1: Filter Model

### T001 - Define `ExpenseFilter`

**Files:** Modify `packages/expense_repository/lib/src/models/expense_filter.dart`.

**Steps:** Include `query`, `startDate`, `endDate`, `categoryIds`, `minAmount`, `maxAmount`, `paymentMethods`, `currency`. Add `empty`.

**Done When:** One object represents all filters.

### T002 - Add Copy/Equality Behavior

**Steps:** Add `copyWith`; use Equatable if consistent or manually compare fields.

**Done When:** Cubit can update individual filters safely.

### T003 - Add Date-Scoped Repository Query

**Files:** Modify `packages/expense_repository/lib/src/firebase_expense_repo.dart`.

**Steps:** Query current user's expenses by date range when start/end provided; order by date descending.

**Done When:** Large date-unbounded reads are avoidable.

---

## Phase 2: Filtering Service

### T004 - Create `ExpenseFilterService`

**Files:** Create `lib/services/expense_filter_service.dart`.

**Steps:** Expose `List<Expense> apply(List<Expense>, ExpenseFilter)`.

**Done When:** Filtering can be unit-tested without UI or Firestore.

### T005 - Implement Text Search

**Steps:** Match lowercased query against description, category name, payment method label if useful.

**Done When:** Searching "food" or Arabic category names filters list.

### T006 - Implement Date Range Filtering

**Steps:** Include dates from start at 00:00 to end at 23:59:59.

**Done When:** Same-day filters work correctly.

### T007 - Implement Category Filtering

**Steps:** Match by `categoryId`; fallback to category name only for old data if id missing.

**Done When:** Multi-category filters work.

### T008 - Implement Amount Filtering

**Steps:** Apply min and max inclusively; ignore null bounds.

**Done When:** Amount range behaves predictably.

### T009 - Implement Payment/Currency Filtering

**Steps:** Filter by selected payment methods and exact currency code.

**Done When:** Cash/visa and currency filters are supported.

---

## Phase 3: UI

### T010 - Create `ExpensesScreen`

**Files:** Create `lib/screens/expenses/views/expenses_screen.dart`.

**Steps:** Render full list, result count, loading state, empty state, and error state.

**Done When:** User can view all expenses outside Home.

### T011 - Create Search Bar

**Files:** Create `lib/screens/expenses/widgets/expense_search_bar.dart`.

**Steps:** Debounce optional; update filter cubit on text change; include clear button.

**Done When:** Search updates results.

### T012 - Create Filter Sheet

**Files:** Create `lib/screens/expenses/widgets/expense_filter_sheet.dart`.

**Steps:** Add date range, category multi-select, amount min/max, payment method, currency controls.

**Done When:** User can configure all filters.

### T013 - Add Reset Filters

**Steps:** Reset to `ExpenseFilter.empty`; clear search text and controls.

**Done When:** One action returns full list.

### T014 - Wire Home `View All`

**Files:** Modify `lib/screens/home/views/main_screen.dart` or parent `home_screen.dart`.

**Steps:** Navigate to Expenses screen with current loaded expenses or repository stream.

**Done When:** Existing `View All` is functional.

---

## Phase 4: Tests

### T015 - Filter Combination Tests

Cover query + category + date + amount + payment + currency combinations.

### T016 - Empty Result Test

Verify no-match returns empty list and UI displays empty state.

### T017 - Manual QA

Create sample expenses and verify each filter control individually and combined.

---

## Completion Checklist

- [x] T001 - Confirmed and completed `ExpenseFilter` fields: query, date range, category ids, amount range, payment methods, and currency.
- [x] T002 - Added `ExpenseFilter.copyWith`, `isEmpty`, equality, and hash behavior.
- [x] T003 - Updated Firebase expense filtering to use server-side date range query and date-desc ordering before local filtering.
- [x] T004 - Created pure `ExpenseFilterService`.
- [x] T005 - Implemented case-insensitive text search across description, category name, payment method labels/storage values, and currency.
- [x] T006 - Implemented inclusive date range filtering with full end-day coverage.
- [x] T007 - Implemented category filtering by `categoryId` with legacy category-name fallback.
- [x] T008 - Implemented inclusive min/max amount filtering.
- [x] T009 - Implemented payment method and exact normalized currency filtering.
- [x] T010 - Created `ExpensesScreen` with result count, list, empty state, and reset action.
- [x] T011 - Created reusable `ExpenseSearchBar` with clear action.
- [x] T012 - Created `ExpenseFilterSheet` with date range, category, amount, payment method, and currency controls.
- [x] T013 - Added reset filters behavior that clears search and filter state.
- [x] T014 - Wired Home `View All` to open the filterable expenses screen with currently loaded expenses.
- [x] T015 - Added filter combination tests covering query, category, date, amount, payment, and currency.
- [x] T016 - Added empty-result service test and Expenses screen empty-state widget test.
- [x] T017 - Automated verification passed. Manual QA still requires running the app with real/sample expense data.
