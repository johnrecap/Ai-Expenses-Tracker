# Tasks: Home And Settings Live Data

**Input**: `specs/021-home-settings-live-data/spec.md`, `plan.md`  
**Implementation Intent**: Remove fake Home values and make Settings persistent, organized, and connected to app behavior.

## Phase 1: Audit And Tests

- [x] T001 Audit hardcoded Home and Settings behavior.

  **Files**: `lib/screens/home/views/main_screen.dart`, `lib/screens/home/views/home_screen.dart`, `lib/screens/settings/views/settings_screen.dart`, `lib/screens/settings/blocs/settings_bloc/settings_cubit.dart`, `lib/screens/add_expense/views/add_expense.dart`, `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`.
  **Why**: The exact fake values and disconnected settings must be identified before refactoring.
  **Steps**:
  1. Find hardcoded `John Doe`, `Income`, `2500`, `Total Balance`, static currency defaults.
  2. Find Add Expense defaults for payment/currency.
  3. Find AI context default currency/payment behavior.
  4. Find settings fields that save but do not affect downstream screens.
  **Done when**: Implementation notes list each issue and target file.

  **Implementation notes**:
  - `lib/screens/home/views/main_screen.dart` had hardcoded `John Doe`, `Total Balance`, `Income`, and `2500 EGP`; replaced by `HomeSummary`.
  - `lib/screens/home/views/home_screen.dart` only passed expenses to Home; now passes authenticated user and watched settings.
  - `lib/screens/settings/views/settings_screen.dart` had inline base/payment fields only; now grouped into scalable settings sections.
  - `lib/screens/settings/blocs/settings_bloc/settings_cubit.dart` lacked supported-currency save/validation; added normalized persistence.
  - `lib/screens/add_expense/views/add_expense.dart` loaded settings defaults but dropdown initial state needed stable keys and base-currency inclusion.
  - `lib/screens/ai_assistant/views/ai_assistant_sheet.dart` and `lib/ai/models/ai_action_preview.dart` only carried default currency; now carry default payment method too.

- [x] T002 Create Home summary tests in `test/home/home_summary_calculator_test.dart`.

  **Why**: Home calculations must be deterministic and independent of widgets.
  **Steps**:
  1. Test monthly spending only counts current month.
  2. Test budget remaining equals budget minus same-currency spending.
  3. Test no budget returns no fake income.
  4. Test mixed currency sets `hasMixedCurrencies` and avoids adding totals.
  5. Test display name fallback from display name to email to generic user.
  **Done when**: Tests fail because calculator/model do not exist.

- [x] T003 Create SettingsCubit tests in `test/settings/settings_cubit_test.dart`.

  **Why**: Settings are user data and save failure must not corrupt state.
  **Steps**:
  1. Test load success.
  2. Test save base currency success.
  3. Test supported currencies update keeps base currency included.
  4. Test default payment method save success.
  5. Test repository failure restores previous state and emits failure.
  **Done when**: Tests describe desired behavior before changes.

## Phase 2: Home Summary

- [x] T004 Create `HomeSummary` in `lib/screens/home/models/home_summary.dart`.

  **Why**: Widgets need a simple view model instead of recalculating financial logic inline.
  **Steps**:
  1. Add spending fields, budget fields, currency state, display name, top category, pending sync count.
  2. Add boolean helpers like `hasBudget`, `isBudgetExceeded`, `canShowSingleCurrencyTotal`.
  3. Keep it UI-framework independent where possible.
  **Done when**: Calculator can return one object for Home UI.

- [x] T005 Create `HomeSummaryCalculator` in `lib/screens/home/services/home_summary_calculator.dart`.

  **Why**: Home and tests need a reusable deterministic calculation.
  **Steps**:
  1. Accept expenses, optional budget, settings, current user, and now.
  2. Filter expenses to current month.
  3. Use settings base currency as preferred currency.
  4. If expenses contain multiple currencies, avoid adding incompatible totals.
  5. Count pending sync expenses from existing sync metadata if available.
  6. Determine top category for the displayed period.
  **Done when**: Home summary tests pass.

- [x] T006 Refactor `MainScreen` in `lib/screens/home/views/main_screen.dart`.

  **Why**: The visible Home card currently mixes real expense total with fake income and static user name.
  **Steps**:
  1. Remove `_calculateTotalExpenses`, `_balanceCurrency`, `_totalExpensesLabel` if replaced by calculator.
  2. Replace `John Doe` with `HomeSummary.displayName`.
  3. Replace `Total Balance` card label with a defined metric such as `This Month Spending`.
  4. Replace fake `Income 2500 EGP` with budget remaining or "Set budget".
  5. Keep transaction list behavior but feed it modern icon renderer if Plan 020 is already done.
  **Done when**: No fake financial/user values remain in `MainScreen`.

- [x] T007 Pass settings and authenticated user into Home summary from `HomeScreen`.

  **Why**: `MainScreen` currently receives only expenses and cannot know user/settings defaults.
  **Steps**:
  1. Read `AuthBloc` authenticated user.
  2. Load/watch settings through existing repository or a Bloc/Cubit provider.
  3. Pass settings/current user to `MainScreen` or a `HomeDashboard` widget.
  4. Show loading only for missing required settings, not for ordinary expense updates.
  **Done when**: Home uses real user and settings data.

## Phase 3: Settings Persistence And Sections

- [x] T008 Extend `SettingsCubit` with supported currencies management.

  **Why**: Settings model already has supported currencies but UI cannot fully manage them.
  **Steps**:
  1. Add `saveSupportedCurrencies(List<String>)`.
  2. Validate list is non-empty.
  3. Ensure base currency is included.
  4. Normalize currency codes to uppercase.
  5. On failure, restore previous `SettingsSuccess`.
  **Done when**: Cubit tests pass for supported currencies.

- [x] T009 Create `CurrencySettingsSection` in `lib/screens/settings/widgets/currency_settings_section.dart`.

  **Why**: Currency settings need more than one dropdown.
  **Steps**:
  1. Show base currency dropdown.
  2. Show supported currency chips/toggles.
  3. Prevent removing current base currency unless user chooses another base first.
  4. Call SettingsCubit methods; do not write repository directly.
  **Done when**: Currency settings are editable and persisted.

- [x] T010 Create `PaymentSettingsSection` in `lib/screens/settings/widgets/payment_settings_section.dart`.

  **Why**: Payment defaults should be visually separate and reusable.
  **Steps**:
  1. Show default payment method selector.
  2. Include helper copy explaining it is used when no payment method is specified.
  3. Call `saveDefaultPaymentMethod`.
  **Done when**: Payment setting persists and updates Add Expense defaults after reload.

- [x] T011 Refactor `SettingsScreen` into grouped sections.

  **Why**: The settings page must scale for notifications, security, AI, privacy, ads, and premium.
  **Steps**:
  1. Keep current loading/failure behavior.
  2. Replace inline base/payment dropdowns with new section widgets.
  3. Keep `NotificationSettingsSection`.
  4. Keep `SecuritySettingsSection`.
  5. Add placeholder AI usage and monetization sections that clearly say they are configuration/status areas, not active purchases yet.
  **Done when**: Settings screen is organized and existing sections still work.

- [x] T012 Connect default payment and currency to Add Expense.

  **Files**: `lib/screens/add_expense/views/add_expense.dart`, relevant add-expense blocs/state if defaults are loaded there.
  **Why**: Saved settings are only valuable if forms consume them.
  **Steps**:
  1. Load settings where Add Expense is created.
  2. Set initial payment method from settings.
  3. Set initial currency from settings base currency.
  4. Keep user's manual selections during the same form session.
  **Done when**: New manual expenses start with settings defaults.

- [x] T013 Connect default payment and currency to AI preview.

  **Files**: `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`, `lib/ai/models/ai_action_preview.dart`.
  **Why**: AI should not always default to Cash/EGP if user changed settings.
  **Steps**:
  1. Include default payment method in `AiContext` if not already present.
  2. Use settings default payment when payload lacks payment method.
  3. Use settings base currency when payload lacks currency.
  4. Keep explicit AI-parsed values higher priority than defaults.
  **Done when**: AI preview respects settings.

## Phase 4: Verification

- [X] T014 Run targeted tests.

  **Commands**:
  ```text
  flutter test test/home/home_summary_calculator_test.dart test/settings/settings_cubit_test.dart
  ```
  **Done when**: Home/settings behavior is covered.
  **Status note (Plan 040 cleanup)**: Superseded by later parent verification;
  Home summary and Settings Cubit tests are part of the passing suite.

- [X] T015 Run app verification.

  **Commands**:
  ```text
  flutter analyze
  flutter test
  ```
  **Done when**: Full app baseline passes.
  **Status note (Plan 040 cleanup)**: Superseded by later parent verification
  where `flutter analyze` and the full Flutter test suite passed.

- [ ] T016 Manual QA.

  **Status note (Plan 040 cleanup)**: Still open because it requires a real
  signed-in app session and settings persistence/device review.

  **Steps**:
  1. Create a user with display name.
  2. Add same-currency and mixed-currency expenses.
  3. Set/remove monthly budget.
  4. Change base currency and default payment method.
  5. Reopen app and confirm values persist.
  6. Open Home, Add Expense, AI Assistant, Settings.
  **Done when**: No hardcoded values appear and settings affect downstream flows.
