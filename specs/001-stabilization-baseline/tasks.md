# Tasks: Stabilization And Baseline

## Implementation Intent

This feature is the first mandatory pass before product work. It does not add new business features. It removes fragile behavior that would make later plans harder to verify.

## Task Format

Each task includes the exact purpose, affected files, implementation steps, test expectations, and completion criteria.

## Completion Checklist

- [x] T001 Replace the default counter widget test.
- [x] T002 Make widget tests Firebase-safe.
- [x] T003 Fix deprecated color serialization.
- [x] T004 Validate amount before parsing.
- [x] T005 Validate category before saving.
- [x] T006 Allow past expense dates.
- [x] T007 Dispose Add Expense text controllers.
- [x] T008 Add empty expense state.
- [x] T009 Add expense load failure state.
- [x] T010 Stop mutating Bloc state expense list directly.
- [x] T011 Fix visible typographical errors.
- [x] T012 Run analyzer.
- [x] T013 Run tests.

---

## Phase 1: Test Baseline

### T001 - Replace The Default Counter Widget Test

**Purpose:** The current `test/widget_test.dart` is still Flutter's counter template and fails because this app is not a counter app.

**Files:**
- Modify: `test/widget_test.dart`

**Implementation Steps:**
1. Remove expectations for text `0` and `1`.
2. Pump `const MyApp()` as the current test already does.
3. Use `tester.pump()` and enough elapsed time to render the splash screen.
4. Assert that `Expense Tracker` is present.
5. Do not assert navigation to Home in this first test because Splash has a timer and Firebase-backed navigation.

**Tests:**
- Run `flutter test test/widget_test.dart`.

**Done When:**
- The test describes the app behavior, not the Flutter template.
- The test no longer taps an add icon from the old counter template.

### T002 - Make Widget Tests Firebase-Safe

**Purpose:** `MyApp` can indirectly depend on Firebase initialization. Tests should not randomly fail because Firebase is unavailable in the test environment.

**Files:**
- Modify: `test/widget_test.dart`
- Modify if needed: `lib/main.dart` or app bootstrap files only if testability requires it.

**Implementation Steps:**
1. Try running the updated widget test.
2. If it fails because Firebase is not initialized, add a test bootstrap approach.
3. Preferred solution: keep `Firebase.initializeApp()` in `main.dart` and test `MyApp` without calling `main()`.
4. If widget construction still requires Firebase, inject a fake repository or guard navigation until Firebase-backed blocs are created outside the test path.
5. Avoid introducing a new dependency unless necessary.

**Tests:**
- Run `flutter test`.

**Done When:**
- Test failures are about real app behavior, not missing Firebase bootstrap.

---

## Phase 2: Add Expense Safety

### T003 - Fix Deprecated Color Serialization

**Purpose:** `Color.value` is deprecated in the current Flutter SDK and triggers analyzer warnings.

**Files:**
- Modify: `lib/screens/add_expense/views/category_creation.dart`

**Implementation Steps:**
1. Locate `categoryColor.value`.
2. Replace with `categoryColor.toARGB32()` if available in the installed Flutter SDK.
3. If `toARGB32()` is unavailable, use a compatible non-deprecated conversion available in the SDK.
4. Keep stored Firestore value as an integer because the current category model expects `int color`.

**Tests:**
- Run `flutter analyze`.

**Done When:**
- Analyzer no longer reports deprecated `Color.value` usage.

### T004 - Validate Amount Before Parsing

**Purpose:** `int.parse(expenseController.text)` can throw when the field is empty or invalid.

**Files:**
- Modify: `lib/screens/add_expense/views/add_expense.dart`

**Implementation Steps:**
1. Add validation before save button dispatch.
2. Trim the amount text.
3. Use `int.tryParse`.
4. Reject null or values less than or equal to zero.
5. Show a visible error using `SnackBar`, field error text, or the app's closest existing pattern.
6. Do not dispatch `CreateExpense` if validation fails.

**Tests:**
- Add or update widget test if practical.
- Manual check: open Add Expense, leave amount empty, press Save.

**Done When:**
- Empty and invalid amount do not crash the app.

### T005 - Validate Category Before Saving

**Purpose:** An expense without a category breaks expected app behavior and later reports.

**Files:**
- Modify: `lib/screens/add_expense/views/add_expense.dart`

**Implementation Steps:**
1. Before dispatching `CreateExpense`, check whether `expense.category == Category.empty` or category id/name is empty.
2. Show an error if no category is selected.
3. Keep the user on Add Expense.
4. Do not create a placeholder category automatically.

**Tests:**
- Manual check: enter amount without category, press Save.

**Done When:**
- Save is blocked until a category is selected.

### T006 - Allow Past Expense Dates

**Purpose:** Expense tracking needs past dates. The AI example includes "yesterday", but the current date picker starts at today.

**Files:**
- Modify: `lib/screens/add_expense/views/add_expense.dart`

**Implementation Steps:**
1. Change `firstDate` from `DateTime.now()` to a past date.
2. Recommended first implementation: `DateTime(DateTime.now().year - 5)`.
3. Keep `lastDate` as today or today plus a short future range if future planned expenses are allowed.
4. Preserve existing date formatting with `DateFormat('dd/MM/yyyy')`.

**Tests:**
- Manual check: select yesterday and save expense.

**Done When:**
- Yesterday and older dates are selectable.

### T007 - Dispose Text Controllers

**Purpose:** The Add Expense screen owns controllers and should dispose them.

**Files:**
- Modify: `lib/screens/add_expense/views/add_expense.dart`
- Modify if practical: `lib/screens/add_expense/views/category_creation.dart`

**Implementation Steps:**
1. Add `@override void dispose()` in `_AddExpenseState`.
2. Dispose `expenseController`, `categoryController`, and `dateController`.
3. For dialog-local controllers inside `StatefulBuilder`, only refactor if it can be done safely without changing dialog behavior.

**Tests:**
- Run `flutter analyze`.

**Done When:**
- Add Expense controllers are disposed and analyzer stays clean.

---

## Phase 3: Home Screen State

### T008 - Add Empty Expense State

**Purpose:** A new user with no expenses should see a clear empty state instead of a blank list.

**Files:**
- Modify: `lib/screens/home/views/main_screen.dart`

**Implementation Steps:**
1. In the transactions list area, check `expenses.isEmpty`.
2. Render a centered message such as `No expenses yet`.
3. Keep the current layout and visual style.
4. Do not introduce new navigation in this task.

**Tests:**
- Widget test if fake data setup is easy.
- Manual check with empty expenses list.

**Done When:**
- Empty list shows useful UI.

### T009 - Add Expense Load Failure State

**Purpose:** `HomeScreen` currently shows a loading spinner for all non-success states, including failure.

**Files:**
- Modify: `lib/screens/home/views/home_screen.dart`

**Implementation Steps:**
1. In `BlocBuilder<GetExpensesBloc, GetExpensesState>`, add explicit branch for `GetExpensesFailure`.
2. Show a message and retry action.
3. Retry should dispatch `GetExpenses()`.
4. Keep loading spinner only for loading/initial.

**Tests:**
- Bloc/widget test if practical.

**Done When:**
- Failure is distinguishable from loading.

### T010 - Stop Mutating Bloc State List Directly

**Purpose:** `state.expenses.insert(0, newExpense)` mutates a list owned by Bloc state.

**Files:**
- Modify: `lib/screens/home/views/home_screen.dart`

**Implementation Steps:**
1. After Add Expense returns a new expense, choose one of two safe behaviors:
   - Preferred: dispatch `GetExpenses()` to reload from repository.
   - Acceptable: create a new local copied list before rendering.
2. Do not mutate `state.expenses` directly.
3. Preserve current UI behavior where the new expense appears after save.

**Tests:**
- Manual check: add an expense and confirm Home updates.

**Done When:**
- No code mutates the Bloc state's list directly.

### T011 - Fix Visible Typographical Errors

**Purpose:** Current labels contain obvious typos that should be fixed before UI expansion.

**Files:**
- Modify: `lib/app_view.dart`
- Modify: `lib/screens/home/views/main_screen.dart`

**Implementation Steps:**
1. Change app title `Expense Teacker` to `Expense Tracker`.
2. Change `Total Balacnce` to `Total Balance`.
3. Change `Transiction` comments/text if visible.
4. Change hardcoded `Jonh Doe` to `John Doe` as a temporary placeholder until Auth adds real display name.

**Tests:**
- Run `flutter analyze`.

**Done When:**
- Visible typos are corrected.

---

## Phase 4: Verification

### T012 - Run Analyzer

**Command:** `flutter analyze`

**Expected Result:**
- No analyzer issues from this work.
- If unrelated pre-existing issues remain, document exact lines.

### T013 - Run Tests

**Command:** `flutter test`

**Expected Result:**
- The replacement widget test passes.
- Any failure is documented with file and line number.
