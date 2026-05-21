# Tasks: Category Budgets And Subscription Center

**Input**: `specs/033-category-budgets-subscriptions/spec.md`, `plan.md`  
**Implementation Intent**: Add category-level budgets and subscription visibility using existing Firebase/user-scoped architecture.

## Phase 1: Data Models And Repository Contracts

- [X] T001 Add `CategoryBudget` model and entity in `packages/expense_repository`.

  **Why**: Category limits need typed storage instead of loose maps.
  **Steps**:
  1. Define fields: id, userId, categoryId, categoryName snapshot, month, currency, limitAmount, warningThreshold, isArchived, createdAt, updatedAt.
  2. Add entity conversion methods matching repository package conventions.
  3. Preserve backward-compatible parsing for missing optional fields.
  4. Add validation for positive limit and month format.
  **Done when**: Category budgets can be serialized/deserialized safely.

- [X] T002 Add `CategoryBudgetRepository` interface.

  **Why**: Widgets and Cubits must not talk directly to Firestore.
  **Steps**:
  1. Add create/update/archive/listForMonth methods.
  2. Keep methods user-scoped.
  3. Return typed `CategoryBudget` values.
  4. Match existing repository naming/style.
  **Done when**: Feature can depend on an abstraction.

- [X] T003 Implement `FirebaseCategoryBudgetRepository`.

  **Why**: Budgets must persist per user.
  **Steps**:
  1. Store under `users/{userId}/category_budgets`.
  2. Use deterministic ids where appropriate.
  3. Exclude archived budgets from active list by default or expose both clearly.
  4. Add error handling consistent with other repositories.
  **Done when**: Category budgets persist under the correct user path.

- [X] T004 Update Firestore rules for category budgets.

  **Why**: New user-owned data path must be protected.
  **Steps**:
  1. Add rules for `users/{userId}/category_budgets/{budgetId}`.
  2. Allow read/write only when `request.auth.uid == userId`.
  3. Deny global category budget paths.
  4. Add emulator/rules tests if the project has them.
  **Done when**: Category budget data is user-isolated.

## Phase 2: Calculators And Cubits

- [X] T005 Implement `CategoryBudgetCalculator`.

  **Why**: Progress should be computed from expenses, not stored counters.
  **Steps**:
  1. Accept category budget, expense list, selected month, and base currency.
  2. Sum only matching category, month, and currency.
  3. Return spent, remaining, percentage, warning, exceeded, and mixed-currency flags.
  4. Ignore archived categories/budgets for active warnings.
  **Done when**: Progress is deterministic and testable.

- [X] T006 Add `CategoryBudgetCubit`.

  **Why**: UI needs load/create/edit/archive and progress state.
  **Steps**:
  1. Load active budgets for month.
  2. Combine with current expenses/categories.
  3. Create and update budgets through repository.
  4. Archive budgets without deleting expense history.
  5. Emit loading/error/ready states.
  **Done when**: UI can manage budgets without direct repository calls.

- [X] T007 Add category budget tests.

  **Why**: Budget math and user paths are easy to regress.
  **Steps**:
  1. Test same-currency progress.
  2. Test warning threshold.
  3. Test exceeded state.
  4. Test mixed-currency warning.
  5. Test archived budget ignored.
  **Done when**: Calculator and Cubit behavior is covered.

## Phase 3: Category Budget UI

- [X] T008 Add Category Budgets screen.

  **Why**: Users need a place to manage category limits.
  **Steps**:
  1. Create `lib/screens/category_budgets`.
  2. Show current month selector or use current month first.
  3. List category budgets with progress bars.
  4. Add create/edit/archive actions.
  5. Show no-budget empty state and mixed-currency warnings.
  **Done when**: User can manage category budgets end-to-end.

- [X] T009 Add entry points from Budget, Categories, Settings, or Home.

  **Why**: Feature must be discoverable.
  **Steps**:
  1. Add a row/card where it naturally belongs.
  2. Avoid crowding Home; use Settings/Budget if necessary.
  3. Add tooltip/label for icon entry if used.
  4. Verify navigation back path.
  **Done when**: User can reach category budgets without hidden routes.

## Phase 4: Subscription Center

- [X] T010 Implement `SubscriptionSummaryService`.

  **Why**: Subscription center should reuse recurring rules instead of guessing.
  **Steps**:
  1. Read active recurring expenses.
  2. Calculate next due date using existing scheduler/date logic.
  3. Estimate monthly impact for daily/weekly/monthly rules.
  4. Exclude paused/archived rules.
  **Done when**: Active recurring charges are summarized correctly.

- [X] T011 Add Subscription Center screen.

  **Why**: Users need one place to review recurring commitments.
  **Steps**:
  1. Create `lib/screens/subscriptions`.
  2. Show active subscriptions with amount, category, payment method, frequency, and next due date.
  3. Show total monthly impact by currency.
  4. Provide shortcut to edit recurring rule.
  5. Show empty state.
  **Done when**: Recurring subscriptions are visible and actionable.

- [X] T012 Add subscription center tests.

  **Why**: Next due date and active/paused behavior must be reliable.
  **Steps**:
  1. Test monthly next due date.
  2. Test weekly impact calculation.
  3. Test paused/archived exclusion.
  4. Test multi-currency grouping.
  **Done when**: Subscription summaries are deterministic.

## Phase 5: Alerts

- [ ] T013 Add optional category budget alert preferences.

  **Why**: Alerts should be user-controlled.
  **Steps**:
  1. Add enable flag and threshold settings if not covered by budget model.
  2. Persist through settings or budget document.
  3. Respect notification permission state.
  4. Default to conservative/non-spammy behavior.
  **Done when**: Alerts can be enabled/disabled.

- [ ] T014 Schedule category budget and subscription due notifications.

  **Why**: Timely alerts drive practical engagement.
  **Steps**:
  1. Trigger category alert when progress crosses threshold.
  2. Avoid duplicate alerts for the same category/month/threshold.
  3. Schedule subscription due reminder if enabled.
  4. Cancel alerts when budget/rule is archived or disabled.
  **Done when**: Notifications match active user preferences.

## Phase 6: Verification

- [X] T015 Run full relevant verification.

  **Why**: This touches repositories, rules, UI, and notifications.
  **Steps**:
  1. Run `flutter pub get` if dependencies/config changed.
  2. Run `flutter analyze`.
  3. Run category budget and subscription tests.
  4. Run Firestore rules tests if rules changed.
  5. Manually create a category budget and recurring subscription on device.
  **Done when**: Feature works and user-owned data stays isolated.

  **Parent review status**: Automated checks passed (`flutter analyze`, category budget/subscription tests, full `flutter test` with 214 tests, and release APK build). Plan 040 later passed `flutter analyze` and full Flutter tests with 240 tests. Manual device creation and Firestore rules emulator tests remain open.
