# Expense Tracker Feature Implementation Plans

Date: 2026-05-15

> Historical notice: this file is an early roadmap snapshot. Later Spec Kit
> plans implemented or superseded many items below. Use `specs/`,
> `.specify/memory/constitution.md`, and
> `docs/implementation_plans/deferred-and-advanced-work.md` for current state.

This document splits the requested Expense Tracker roadmap into independent, executable plans. Each plan is written so a developer or AI agent can pick it up, understand dependencies, know which files are likely to change, and execute the work without rebuilding the project from scratch.

## Execution Rules For All Plans

- Read `.specify/memory/constitution.md` before starting.
- Keep the current Flutter + Bloc + Repository style.
- Do not bypass repositories from UI code.
- Do not let AI actions mutate data without user confirmation.
- Prefer user-scoped Firestore paths under `users/{userId}/...`.
- Add tests with each feature where possible.
- Run `flutter pub get`, `flutter analyze`, and the relevant tests before marking work complete.
- Update this document only when scope changes; create Spec Kit `spec.md`, `plan.md`, and `tasks.md` for the specific feature before implementation.

## Recommended Execution Order

1. Plan 00: Stabilization and test baseline.
2. Plan 01: Authentication and user-scoped data.
3. Plan 02: Expense model upgrade.
4. Plan 03: Category management.
5. Plan 04: Payment methods and currency foundation.
6. Plan 05: Budget.
7. Plan 06: Search and filters.
8. Plan 07: Reports and stats.
9. Plan 08: AI Assistant phase 1: text-to-expense preview.
10. Plan 09: AI Assistant phase 2: search, summary, advice, update, delete.
11. Plan 10: Recurring expenses.
12. Plan 11: Export.
13. Plan 12: Notifications.
14. Plan 13: Saving goals.
15. Plan 14: Offline mode.
16. Plan 15: App protection.
17. Plan 16: AI Assistant phase 3: receipts, repeated expense detection, prediction.

---

## Plan 00: Stabilization And Baseline

**Goal:** Make the current app safe to extend before adding large features.

**Dependencies:** None.

**Main files:**

- `pubspec.yaml`
- `test/widget_test.dart`
- `lib/app_view.dart`
- `lib/screens/splash_screen.dart`
- `lib/screens/home/views/home_screen.dart`
- `lib/screens/home/views/main_screen.dart`
- `lib/screens/add_expense/views/add_expense.dart`
- `lib/screens/add_expense/views/category_creation.dart`

### Tasks

- [ ] T00-001: Replace the default counter widget test with a real smoke test that pumps `MyApp` and verifies the splash title `Expense Tracker`.
- [ ] T00-002: Add a fake or guarded Firebase initialization strategy for widget tests so tests do not fail because Firebase is not initialized in the test environment.
- [ ] T00-003: Fix `Color.value` usage in `category_creation.dart` using the current Flutter API, for example `toARGB32()` if supported by the installed SDK.
- [ ] T00-004: Add amount field validation in `AddExpense` before calling `int.parse`.
- [ ] T00-005: Prevent save when category is empty.
- [ ] T00-006: Change the date picker in `AddExpense` to allow past expenses. Suggested range: from `DateTime(DateTime.now().year - 5)` to `DateTime.now().add(Duration(days: 365))`.
- [ ] T00-007: Dispose `TextEditingController` instances in `AddExpense` and `category_creation.dart` where lifecycle allows.
- [ ] T00-008: Add empty state UI in `MainScreen` when there are no expenses.
- [ ] T00-009: Add failure state UI in `HomeScreen` when `GetExpensesFailure` occurs.
- [ ] T00-010: Replace direct mutation `state.expenses.insert(0, newExpense)` with either a bloc refresh or a copied list in local state.
- [ ] T00-011: Correct visible typos such as `Expense Teacker`, `Total Balacnce`, `Transiction`, and `Jonh Doe`.
- [ ] T00-012: Run `flutter analyze` and confirm there are no analyzer issues introduced by this plan.
- [ ] T00-013: Run `flutter test` and confirm the new test baseline passes.

### Acceptance Criteria

- The app still opens to splash then home.
- Add Expense no longer crashes on empty amount.
- Past dates can be selected.
- Analyzer is clean or only reports pre-existing unrelated issues.
- Test suite no longer contains the original Flutter starter widget assertion.

---

## Plan 01: Authentication And User-Scoped Data

**Goal:** Add Firebase Authentication and ensure each user only reads/writes their own data.

**Dependencies:** Plan 00.

**Main files to create:**

- `packages/expense_repository/lib/src/auth/auth_repository.dart`
- `packages/expense_repository/lib/src/auth/firebase_auth_repository.dart`
- `packages/expense_repository/lib/src/models/app_user.dart`
- `packages/expense_repository/lib/src/entities/app_user_entity.dart`
- `lib/screens/auth/blocs/auth_bloc/auth_bloc.dart`
- `lib/screens/auth/blocs/auth_bloc/auth_event.dart`
- `lib/screens/auth/blocs/auth_bloc/auth_state.dart`
- `lib/screens/auth/views/login_screen.dart`
- `lib/screens/auth/views/register_screen.dart`
- `lib/screens/auth/views/auth_gate.dart`
- `firestore.rules` if Firebase rules are managed in this repo.

**Main files to modify:**

- `packages/expense_repository/lib/expense_repository.dart`
- `packages/expense_repository/lib/src/firebase_expense_repo.dart`
- `packages/expense_repository/lib/src/expense_repo.dart`
- `packages/expense_repository/lib/src/models/expense.dart`
- `packages/expense_repository/lib/src/models/category.dart`
- `packages/expense_repository/lib/src/entities/expense_entity.dart`
- `packages/expense_repository/lib/src/entities/category_entity.dart`
- `lib/main.dart`
- `lib/app_view.dart`
- `lib/screens/splash_screen.dart`
- `lib/screens/home/views/home_screen.dart`

### Tasks

- [ ] T01-001: Add `AppUser` model with `userId`, `email`, `displayName`, `photoUrl`, `createdAt`.
- [ ] T01-002: Add `AuthRepository` interface with `user`, `currentUser`, `signIn`, `signUp`, `signOut`, and `resetPassword`.
- [ ] T01-003: Implement `FirebaseAuthRepository` using `FirebaseAuth.instance`.
- [ ] T01-004: Export auth repository and user model from `expense_repository.dart`.
- [ ] T01-005: Add `AuthBloc` that emits unauthenticated, authenticated, loading, and failure states.
- [ ] T01-006: Add `AuthGate` that routes authenticated users to `HomeScreen` and unauthenticated users to `LoginScreen`.
- [ ] T01-007: Replace splash screen's unconditional navigation with auth-aware navigation.
- [ ] T01-008: Create login UI with email, password, login action, register link, and reset password link.
- [ ] T01-009: Create register UI with display name, email, password, confirm password, and create account action.
- [ ] T01-010: Inject `AuthRepository` and `ExpenseRepository` at app level using `RepositoryProvider`.
- [ ] T01-011: Change Firestore paths from global `expenses` and `categories` to `users/{userId}/expenses` and `users/{userId}/categories`.
- [ ] T01-012: Add `userId` to `Expense` and `Category` models or infer it strictly from the Firestore path. Recommendation: include `userId` in model for local filtering and diagnostics.
- [ ] T01-013: Update `FirebaseExpenseRepo` constructor to require `userId` or an auth/user provider.
- [ ] T01-014: Update all bloc creation sites to use the authenticated user's repository instance.
- [ ] T01-015: Add Firestore security rules enforcing `request.auth.uid == userId`.
- [ ] T01-016: Decide migration behavior for existing global data. Recommended for this project: no automatic migration unless real production data exists.
- [ ] T01-017: Add auth bloc tests for sign-in success, sign-in failure, sign-out, and auth stream changes.
- [ ] T01-018: Add repository tests or fake repository tests to verify data path construction uses the authenticated user.

### Acceptance Criteria

- App starts at login when signed out.
- App starts at home when signed in.
- Sign up creates a Firebase Auth user.
- Sign in and sign out work.
- Firestore reads/writes are scoped to the current user.
- A signed-in user cannot read another user's subcollections according to rules.

---

## Plan 02: Expense Model Upgrade

**Goal:** Expand the expense domain model once so all future features share one stable data shape.

**Dependencies:** Plan 01.

**Main files to create:**

- `packages/expense_repository/lib/src/models/payment_method.dart`
- `packages/expense_repository/lib/src/models/expense_source.dart`
- `packages/expense_repository/lib/src/models/expense_filter.dart`

**Main files to modify:**

- `packages/expense_repository/lib/src/models/expense.dart`
- `packages/expense_repository/lib/src/entities/expense_entity.dart`
- `packages/expense_repository/lib/src/expense_repo.dart`
- `packages/expense_repository/lib/src/firebase_expense_repo.dart`
- `lib/screens/add_expense/views/add_expense.dart`
- `lib/screens/home/views/main_screen.dart`

### Tasks

- [ ] T02-001: Add fields to `Expense`: `userId`, `categoryId`, `description`, `paymentMethod`, `currency`, `createdAt`, `updatedAt`, `source`, `recurringExpenseId`, `aiActionId`.
- [ ] T02-002: Keep a category snapshot on the expense for list rendering: `categoryName`, `categoryIcon`, `categoryColor`.
- [ ] T02-003: Create `PaymentMethod` enum with `cash`, `visa`, `wallet`, `bankTransfer`.
- [ ] T02-004: Create `ExpenseSource` enum with `manual`, `ai`, `recurring`, `receipt`.
- [ ] T02-005: Update `ExpenseEntity.toDocument` to serialize all new fields with stable Firestore keys.
- [ ] T02-006: Update `ExpenseEntity.fromDocument` to read both new and old documents safely. Old fields should default to `cash`, `EGP` or configured base currency, empty description, and `manual`.
- [ ] T02-007: Add repository methods: `updateExpense`, `deleteExpense`, `getExpenseById`, `watchExpenses`, and `getExpensesByFilter`.
- [ ] T02-008: Update `CreateExpenseBloc` to use the upgraded model.
- [ ] T02-009: Update `MainScreen` to render description when present and category snapshot fields.
- [ ] T02-010: Update `AddExpense` form to include description, payment method, and currency.
- [ ] T02-011: Add serialization unit tests for old expense documents and new expense documents.
- [ ] T02-012: Add bloc tests for create/update/delete success and failure paths.

### Acceptance Criteria

- Existing simple expense documents still render.
- New expense documents include description, payment method, currency, timestamps, and source.
- Update and delete operations are available through repository interfaces.
- No UI code writes directly to Firestore.

---

## Plan 03: Category Management

**Goal:** Convert categories from add-only dialog behavior into manageable user-owned data.

**Dependencies:** Plan 01.

**Main files to create:**

- `packages/expense_repository/lib/src/category_repo.dart`
- `packages/expense_repository/lib/src/firebase_category_repo.dart`
- `lib/screens/categories/blocs/categories_bloc/categories_bloc.dart`
- `lib/screens/categories/blocs/categories_bloc/categories_event.dart`
- `lib/screens/categories/blocs/categories_bloc/categories_state.dart`
- `lib/screens/categories/views/categories_screen.dart`
- `lib/screens/categories/widgets/category_form_dialog.dart`

**Main files to modify:**

- `packages/expense_repository/lib/src/models/category.dart`
- `packages/expense_repository/lib/src/entities/category_entity.dart`
- `lib/screens/add_expense/views/add_expense.dart`
- `lib/screens/add_expense/views/category_creation.dart`
- `lib/screens/home/views/home_screen.dart`

### Tasks

- [ ] T03-001: Split category repository methods out of `ExpenseRepository` into `CategoryRepository`.
- [ ] T03-002: Add category fields: `userId`, `createdAt`, `updatedAt`, `isArchived`.
- [ ] T03-003: Add repository methods: `createCategory`, `updateCategory`, `archiveCategory`, `watchCategories`, `getCategories`.
- [ ] T03-004: Replace `category_creation.dart` function with reusable `CategoryFormDialog`.
- [ ] T03-005: Add `CategoriesScreen` for listing, editing, and archiving categories.
- [ ] T03-006: Add a navigation entry to categories from settings or a simple icon/button on Home.
- [ ] T03-007: Prevent deletion of categories used by expenses; use archive instead.
- [ ] T03-008: Validate category name, icon, and color before save.
- [ ] T03-009: Keep Add Expense category selector working with active categories only.
- [ ] T03-010: Add tests for category serialization, archive behavior, and category list bloc states.

### Acceptance Criteria

- Users can create and edit categories.
- Archived categories do not appear in Add Expense.
- Existing expenses still show category snapshot even if the category is archived later.
- Category data is user-scoped.

---

## Plan 04: Payment Methods And Currency Foundation

**Goal:** Add payment method selection and base currency settings without live conversion yet.

**Dependencies:** Plan 02.

**Main files to create:**

- `packages/expense_repository/lib/src/models/user_settings.dart`
- `packages/expense_repository/lib/src/entities/user_settings_entity.dart`
- `packages/expense_repository/lib/src/settings_repo.dart`
- `packages/expense_repository/lib/src/firebase_settings_repo.dart`
- `lib/screens/settings/blocs/settings_bloc/settings_bloc.dart`
- `lib/screens/settings/views/settings_screen.dart`

**Main files to modify:**

- `lib/screens/add_expense/views/add_expense.dart`
- `lib/screens/home/views/main_screen.dart`
- `lib/screens/stats/stats.dart`

### Tasks

- [ ] T04-001: Add `UserSettings` with `baseCurrency`, `supportedCurrencies`, `defaultPaymentMethod`, and `updatedAt`.
- [ ] T04-002: Implement `SettingsRepository` for `users/{userId}/settings/profile`.
- [ ] T04-003: Add default settings creation after registration.
- [ ] T04-004: Add Settings screen with base currency dropdown.
- [ ] T04-005: Add payment method selector in Add Expense.
- [ ] T04-006: Render currency symbol/code from the expense currency instead of hardcoded `$`.
- [ ] T04-007: Add a utility `CurrencyFormatter` that uses `intl` for display.
- [ ] T04-008: Store only currency code at this phase. Do not implement exchange rates yet.
- [ ] T04-009: Add tests for settings serialization and currency formatting.

### Acceptance Criteria

- User can choose a base currency.
- New expenses store their own currency.
- UI no longer assumes `$`.
- Payment methods are visible on expenses and filters can use them later.

---

## Plan 05: Monthly Budget

**Goal:** Let users set a monthly budget and see spending progress with warnings.

**Dependencies:** Plans 01, 02, and 04.

**Main files to create:**

- `packages/expense_repository/lib/src/models/budget.dart`
- `packages/expense_repository/lib/src/entities/budget_entity.dart`
- `packages/expense_repository/lib/src/budget_repo.dart`
- `packages/expense_repository/lib/src/firebase_budget_repo.dart`
- `lib/screens/budget/blocs/budget_bloc/budget_bloc.dart`
- `lib/screens/budget/blocs/budget_bloc/budget_event.dart`
- `lib/screens/budget/blocs/budget_bloc/budget_state.dart`
- `lib/screens/budget/views/budget_screen.dart`
- `lib/screens/budget/widgets/budget_progress_card.dart`
- `lib/services/budget_calculator.dart`

**Main files to modify:**

- `lib/screens/home/views/main_screen.dart`
- `lib/screens/home/views/home_screen.dart`

### Tasks

- [ ] T05-001: Add `Budget` model with `budgetId`, `userId`, `month`, `year`, `amount`, `currency`, `warningThresholdPercent`, `createdAt`, `updatedAt`.
- [ ] T05-002: Add `BudgetRepository` with create/update/get current month/watch current month.
- [ ] T05-003: Add `BudgetCalculator` that receives expenses, budget, and settings and returns spent, remaining, percent, nearLimit, exceeded.
- [ ] T05-004: Add `BudgetBloc` to load and save monthly budget.
- [ ] T05-005: Add Budget screen to create/update current month budget.
- [ ] T05-006: Add `BudgetProgressCard` to Home.
- [ ] T05-007: Add warning UI when spending is above threshold.
- [ ] T05-008: Add exceeded UI when spending is over budget.
- [ ] T05-009: Decide how to handle multi-currency expenses. Phase recommendation: only include expenses matching base currency and show a note if other currencies exist.
- [ ] T05-010: Add tests for calculator: no budget, zero spending, near limit, exceeded, wrong currency ignored.

### Acceptance Criteria

- User can set a budget for the current month.
- Home shows spending progress.
- Warning appears near threshold.
- Exceeded state is visible after crossing budget.

---

## Plan 06: Advanced Search And Filters

**Goal:** Add structured filtering by text, date, category, amount, and payment method.

**Dependencies:** Plans 02, 03, and 04.

**Main files to create:**

- `lib/screens/expenses/blocs/expense_filter_cubit/expense_filter_cubit.dart`
- `lib/screens/expenses/blocs/expense_filter_cubit/expense_filter_state.dart`
- `lib/screens/expenses/views/expenses_screen.dart`
- `lib/screens/expenses/widgets/expense_filter_sheet.dart`
- `lib/screens/expenses/widgets/expense_search_bar.dart`
- `lib/services/expense_filter_service.dart`

**Main files to modify:**

- `packages/expense_repository/lib/src/models/expense_filter.dart`
- `packages/expense_repository/lib/src/firebase_expense_repo.dart`
- `lib/screens/home/views/home_screen.dart`
- `lib/screens/home/views/main_screen.dart`

### Tasks

- [ ] T06-001: Define `ExpenseFilter` fields: `query`, `startDate`, `endDate`, `categoryIds`, `minAmount`, `maxAmount`, `paymentMethods`, `currency`.
- [ ] T06-002: Add pure Dart `ExpenseFilterService` for local filtering.
- [ ] T06-003: Add repository method for date-scoped queries first, then apply local filtering for text/amount/payment.
- [ ] T06-004: Create full Expenses screen with search bar and filter button.
- [ ] T06-005: Add filter sheet with date range picker, categories, amount min/max, payment method, and currency.
- [ ] T06-006: Add reset filters action.
- [ ] T06-007: Add result count and empty state.
- [ ] T06-008: Make Home `View All` open the full Expenses screen.
- [ ] T06-009: Add tests for filter service combinations.
- [ ] T06-010: Document Firestore composite indexes only when server-side filtering is added.

### Acceptance Criteria

- User can search by description/category text.
- User can filter by date, category, amount, payment method, and currency.
- Filters can be reset.
- Filtering logic has unit tests.

---

## Plan 07: Weekly And Monthly Reports

**Goal:** Replace the original placeholder stats screen with real weekly/monthly reports and charts.

**Dependencies:** Plans 02, 04, and 06.

**Main files to create:**

- `packages/expense_repository/lib/src/models/expense_report.dart`
- `lib/services/report_calculator.dart`
- `lib/screens/reports/cubit/report_cubit.dart`
- `lib/screens/reports/cubit/report_state.dart`
- `lib/screens/reports/views/reports_screen.dart`
- `lib/screens/reports/widgets/spending_bar_chart.dart`
- `lib/screens/reports/widgets/category_breakdown_chart.dart`
- `lib/screens/reports/widgets/month_comparison_card.dart`

**Main files to modify:**

- `lib/screens/stats/stats.dart`
- `lib/screens/stats/chart.dart`
- `lib/screens/home/views/home_screen.dart`

### Tasks

- [ ] T07-001: Create `ReportRange` enum with `weekly`, `monthly`, `custom`.
- [ ] T07-002: Create `ExpenseReport` model with total, byCategory, byDay, byWeek, topCategory, previousPeriodTotal, deltaPercent.
- [ ] T07-003: Implement `ReportCalculator` as pure Dart service.
- [ ] T07-004: Replace static `MyChart` data with values from `ReportCubit`.
- [ ] T07-005: Add weekly summary view.
- [ ] T07-006: Add monthly summary view.
- [ ] T07-007: Add top categories chart.
- [ ] T07-008: Add month-over-month comparison card.
- [ ] T07-009: Add loading, empty, and error states.
- [ ] T07-010: Add tests for weekly grouping, monthly grouping, top category, and delta calculation.

### Acceptance Criteria

- Stats screen uses real expense data.
- User can switch weekly/monthly.
- Top categories and month comparison are visible.
- Chart still uses `fl_chart`.

---

## Plan 08: AI Assistant Phase 1 - Text To Expense Preview

**Goal:** Let the user type natural language and get a confirmed Add Expense preview.

**Dependencies:** Plans 02, 03, and 04.

**Main files to create:**

- `lib/ai/models/ai_intent.dart`
- `lib/ai/models/ai_response.dart`
- `lib/ai/models/ai_expense_payload.dart`
- `lib/ai/models/ai_action_preview.dart`
- `lib/ai/services/ai_service.dart`
- `lib/ai/services/mock_ai_service.dart`
- `lib/ai/services/remote_ai_service.dart`
- `lib/ai/services/ai_response_parser.dart`
- `lib/ai/cubit/ai_assistant_cubit.dart`
- `lib/ai/cubit/ai_assistant_state.dart`
- `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`
- `lib/screens/ai_assistant/widgets/ai_action_preview_card.dart`
- `lib/screens/ai_assistant/widgets/ai_text_input.dart`

**Main files to modify:**

- `pubspec.yaml`
- `lib/screens/add_expense/views/add_expense.dart`
- `lib/screens/home/views/home_screen.dart`

### Tasks

- [ ] T08-001: Add AI model classes for intent, response, expense payload, and preview action.
- [ ] T08-002: Define supported phase 1 intents: `addExpense`, `unknown`.
- [ ] T08-003: Add `AiService` interface with `Future<AiResponse> parseExpenseText(String text, AiContext context)`.
- [ ] T08-004: Add `MockAiService` with deterministic parsing for examples like `صرفت 250 جنيه على أكل امبارح بالكاش`.
- [ ] T08-005: Add `AiResponseParser` that accepts only structured JSON and rejects malformed output.
- [ ] T08-006: Add `AiAssistantCubit` states: initial, parsing, previewReady, needsClarification, failure, confirming, confirmed.
- [ ] T08-007: Add confidence threshold. Recommendation: below `0.75` asks for clarification.
- [ ] T08-008: Map category names from Arabic/English text to existing categories using category name similarity and fallback suggestions.
- [ ] T08-009: Map relative dates such as today, yesterday, this month to actual `DateTime`.
- [ ] T08-010: Map payment words such as cash, visa, wallet, bank transfer, كاش, فيزا, محفظة, تحويل.
- [ ] T08-011: Add AI assistant bottom sheet with text field and parse button.
- [ ] T08-012: Show preview card with amount, category, date, payment method, currency, and description.
- [ ] T08-013: Let user edit preview fields before confirm.
- [ ] T08-014: On confirm, call existing create expense flow through Bloc or repository. Do not write from `AiService`.
- [ ] T08-015: Store `source = ai` and `aiActionId` if action logging exists, otherwise leave `aiActionId` null until Plan 09.
- [ ] T08-016: Add parser tests for valid JSON, malformed JSON, low confidence, missing amount, missing category, Arabic payment words, and yesterday date.
- [ ] T08-017: Add cubit tests for parsing success, clarification, failure, and confirm.

### Acceptance Criteria

- User can type a natural language expense sentence.
- App shows a preview, not an immediate save.
- User can edit preview.
- Expense is saved only after confirmation.
- Malformed or unclear AI output shows a clear clarification state.

---

## Plan 09: AI Assistant Phase 2 - Commands Over Existing Data

**Goal:** Support AI search, summaries, advice, update, and delete with strict confirmation for mutations.

**Dependencies:** Plans 06, 07, and 08.

**Main files to create:**

- `lib/ai/models/ai_target_match.dart`
- `lib/ai/models/ai_search_payload.dart`
- `lib/ai/models/ai_summary_payload.dart`
- `lib/ai/models/ai_advice_payload.dart`
- `lib/ai/services/ai_action_matcher.dart`
- `lib/ai/services/ai_advice_service.dart`
- `packages/expense_repository/lib/src/models/ai_action_log.dart`
- `packages/expense_repository/lib/src/entities/ai_action_log_entity.dart`
- `packages/expense_repository/lib/src/ai_action_log_repo.dart`
- `packages/expense_repository/lib/src/firebase_ai_action_log_repo.dart`

**Main files to modify:**

- `lib/ai/models/ai_intent.dart`
- `lib/ai/models/ai_response.dart`
- `lib/ai/cubit/ai_assistant_cubit.dart`
- `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`
- `packages/expense_repository/lib/src/expense_repo.dart`

### Tasks

- [ ] T09-001: Add intents: `searchExpenses`, `summarizeExpenses`, `financialAdvice`, `updateExpense`, `deleteExpense`.
- [ ] T09-002: Add `AiActionLog` model storing userId, rawInput, parsedResponse, actionType, confidence, status, createdAt.
- [ ] T09-003: Add repository for `users/{userId}/ai_actions`.
- [ ] T09-004: For search commands, convert AI filter payload into `ExpenseFilter` and open Expenses screen with filters applied.
- [ ] T09-005: For summary commands, use `ReportCalculator` and show summary in assistant UI.
- [ ] T09-006: For advice commands, generate advice from local aggregates first. Remote AI can rephrase, but must not invent totals.
- [ ] T09-007: Add target matching for update/delete commands. Match candidate expenses by description, category, amount, date, and recency.
- [ ] T09-008: If exactly one strong target match exists, show preview with that expense.
- [ ] T09-009: If multiple candidates exist, show selectable candidates and require user selection.
- [ ] T09-010: Confirm update commands before calling `updateExpense`.
- [ ] T09-011: Confirm delete commands before calling `deleteExpense`.
- [ ] T09-012: Log every AI command and final status: previewed, confirmed, canceled, failed.
- [ ] T09-013: Add tests for target matching and no-match behavior.
- [ ] T09-014: Add cubit tests for search, summary, advice, update preview, delete preview, cancel, and confirm.

### Acceptance Criteria

- AI can search using natural language.
- AI can summarize week/month using real local expense data.
- AI advice is based on actual aggregates.
- Update/delete never happen without explicit confirmation.
- Ambiguous target matching asks the user to choose.

---

## Plan 10: Recurring Expenses

**Goal:** Support daily, weekly, and monthly recurring expenses.

**Dependencies:** Plans 02 and 05.

**Main files to create:**

- `packages/expense_repository/lib/src/models/recurring_expense.dart`
- `packages/expense_repository/lib/src/entities/recurring_expense_entity.dart`
- `packages/expense_repository/lib/src/recurring_expense_repo.dart`
- `packages/expense_repository/lib/src/firebase_recurring_expense_repo.dart`
- `lib/services/recurring_expense_scheduler.dart`
- `lib/screens/recurring_expenses/blocs/recurring_expense_bloc/recurring_expense_bloc.dart`
- `lib/screens/recurring_expenses/views/recurring_expenses_screen.dart`
- `lib/screens/recurring_expenses/widgets/recurring_expense_form.dart`

### Tasks

- [ ] T10-001: Add `RecurringFrequency` enum with `daily`, `weekly`, `monthly`.
- [ ] T10-002: Add `RecurringExpense` model with amount, category, description, payment method, currency, startDate, nextRunDate, endDate, frequency, active.
- [ ] T10-003: Add repository create/update/archive/watch methods.
- [ ] T10-004: Add scheduler service that calculates due occurrences between `nextRunDate` and now.
- [ ] T10-005: Add app-start processor that materializes due recurring expenses when the app opens.
- [ ] T10-006: Prevent duplicate generation by updating `nextRunDate` transactionally after creating each generated expense.
- [ ] T10-007: Add recurring settings section to Add Expense or a separate Recurring Expenses screen.
- [ ] T10-008: Show generated expenses with `source = recurring` and `recurringExpenseId`.
- [ ] T10-009: Add tests for daily, weekly, monthly next date calculation.
- [ ] T10-010: Add tests for duplicate prevention.
- [ ] T10-011: Document backend scheduled generation as a future production enhancement if guaranteed generation is required.

### Acceptance Criteria

- User can create active recurring expenses.
- Due expenses are generated when app opens.
- Duplicate generated expenses are prevented.
- Generated expenses appear in reports and budget totals.

---

## Plan 11: Export PDF, Excel, CSV

**Goal:** Export expenses by selected date range in CSV, Excel, and PDF.

**Dependencies:** Plans 06 and 07.

**Main packages likely needed:**

- `csv`
- `pdf`
- `printing`
- `excel`
- `path_provider`
- `share_plus`

**Main files to create:**

- `lib/services/export/export_service.dart`
- `lib/services/export/csv_exporter.dart`
- `lib/services/export/excel_exporter.dart`
- `lib/services/export/pdf_exporter.dart`
- `lib/screens/export/cubit/export_cubit.dart`
- `lib/screens/export/views/export_screen.dart`

### Tasks

- [ ] T11-001: Add export packages to `pubspec.yaml`.
- [ ] T11-002: Create `ExportFormat` enum with `csv`, `excel`, `pdf`.
- [ ] T11-003: Create `ExportRequest` with date range, category filter, currency filter, and format.
- [ ] T11-004: Create `ExportService` interface.
- [ ] T11-005: Implement CSV exporter with headers: date, amount, currency, category, payment method, description.
- [ ] T11-006: Implement Excel exporter with one sheet named `Expenses`.
- [ ] T11-007: Implement PDF exporter with report title, period, total, and table.
- [ ] T11-008: Add export screen with period selector and format selector.
- [ ] T11-009: Use `share_plus` or platform save behavior to let the user share/save the generated file.
- [ ] T11-010: Add tests for CSV content and export date filtering.
- [ ] T11-011: Add golden or unit-level test for PDF metadata if practical.

### Acceptance Criteria

- User can export a selected date range.
- CSV, Excel, and PDF are generated.
- Exported rows match current filters.
- Export does not require AI or direct Firestore access from UI.

---

## Plan 12: Smart Notifications

**Goal:** Add local notifications for budget warnings and forgotten expense reminders.

**Dependencies:** Plans 05 and 07.

**Main packages likely needed:**

- `flutter_local_notifications`
- `timezone`

**Main files to create:**

- `lib/services/notifications/notification_service.dart`
- `lib/services/notifications/notification_scheduler.dart`
- `lib/screens/settings/widgets/notification_settings_section.dart`
- `packages/expense_repository/lib/src/models/notification_settings.dart`

### Tasks

- [ ] T12-001: Add notification packages.
- [ ] T12-002: Configure Android notification channel.
- [ ] T12-003: Configure iOS/macOS notification permissions where supported.
- [ ] T12-004: Add notification settings to user settings: budget alerts, daily reminder, reminder time.
- [ ] T12-005: Schedule daily reminder if no expense has been logged by the configured time.
- [ ] T12-006: Trigger local budget warning notification after expense creation if threshold is crossed.
- [ ] T12-007: Trigger local exceeded-budget notification once per budget period.
- [ ] T12-008: Add settings UI for enabling/disabling notifications.
- [ ] T12-009: Add tests for notification decision logic without requiring platform notification APIs.
- [ ] T12-010: Document that true server-side smart notifications need backend scheduling or Cloud Functions.

### Acceptance Criteria

- User can enable/disable notification categories.
- App asks for notification permission.
- Budget warning notification fires after threshold crossing.
- Daily reminder can be scheduled.

---

## Plan 13: Saving Goals

**Goal:** Let users create saving goals and track progress.

**Dependencies:** Plans 01 and 04.

**Main files to create:**

- `packages/expense_repository/lib/src/models/saving_goal.dart`
- `packages/expense_repository/lib/src/entities/saving_goal_entity.dart`
- `packages/expense_repository/lib/src/saving_goal_repo.dart`
- `packages/expense_repository/lib/src/firebase_saving_goal_repo.dart`
- `lib/screens/saving_goals/blocs/saving_goal_bloc/saving_goal_bloc.dart`
- `lib/screens/saving_goals/views/saving_goals_screen.dart`
- `lib/screens/saving_goals/widgets/saving_goal_card.dart`
- `lib/screens/saving_goals/widgets/saving_goal_form.dart`

### Tasks

- [ ] T13-001: Add `SavingGoal` model with name, targetAmount, currentAmount, currency, deadline, createdAt, updatedAt, archived.
- [ ] T13-002: Add repository create/update/archive/watch methods.
- [ ] T13-003: Add progress calculation as percent and remaining amount.
- [ ] T13-004: Add Saving Goals screen.
- [ ] T13-005: Add create/edit saving goal form.
- [ ] T13-006: Add progress cards with percent and deadline.
- [ ] T13-007: Add optional manual contribution action to increase currentAmount.
- [ ] T13-008: Add tests for progress calculation.
- [ ] T13-009: Add bloc tests for create/update/archive flows.

### Acceptance Criteria

- User can create a saving goal.
- User can update progress.
- Progress percent is shown correctly.
- Archived goals no longer show in active list.

---

## Plan 14: Offline Mode And Sync Feedback

**Goal:** Support adding expenses when offline and show sync status.

**Dependencies:** Plans 01 and 02.

**Main files to create:**

- `packages/expense_repository/lib/src/models/sync_status.dart`
- `lib/services/connectivity/connectivity_service.dart`
- `lib/widgets/sync_status_banner.dart`

**Main packages likely needed if explicit connectivity is required:**

- `connectivity_plus`

### Tasks

- [ ] T14-001: Confirm Firestore offline persistence behavior for Android, iOS, and web in the current Firebase version.
- [ ] T14-002: Add `syncStatus` to expense model if UI needs pending/synced indicators.
- [ ] T14-003: Add pending write detection using Firestore snapshot metadata where stream-based reads are used.
- [ ] T14-004: Add `ConnectivityService` only if the app needs explicit online/offline banners.
- [ ] T14-005: Show a sync banner when offline.
- [ ] T14-006: Show pending indicator on expenses created offline.
- [ ] T14-007: Update repository methods to avoid assuming immediate server success for offline writes.
- [ ] T14-008: Add tests for local sync state mapping where possible.
- [ ] T14-009: Document conflict policy: last write wins for normal expense edits unless future requirements demand merge resolution.

### Acceptance Criteria

- User can create an expense while offline if Firestore persistence supports the platform.
- UI indicates pending sync.
- App recovers when connection returns.
- No duplicate expenses are created by reconnecting.

---

## Plan 15: App Protection With PIN And Biometrics

**Goal:** Add optional app lock with PIN and biometric unlock.

**Dependencies:** Plan 01.

**Main packages likely needed:**

- `local_auth`
- `flutter_secure_storage`
- `crypto`

**Main files to create:**

- `lib/security/app_lock_service.dart`
- `lib/security/pin_service.dart`
- `lib/security/biometric_service.dart`
- `lib/screens/app_lock/cubit/app_lock_cubit.dart`
- `lib/screens/app_lock/views/create_pin_screen.dart`
- `lib/screens/app_lock/views/unlock_screen.dart`
- `lib/screens/settings/widgets/security_settings_section.dart`

### Tasks

- [ ] T15-001: Add secure storage and local auth packages.
- [ ] T15-002: Add security settings fields to user settings: appLockEnabled, biometricEnabled.
- [ ] T15-003: Implement PIN setup flow with confirm PIN.
- [ ] T15-004: Store PIN as salted hash in secure storage, not plain text.
- [ ] T15-005: Implement unlock flow on app resume/start when lock is enabled.
- [ ] T15-006: Add biometric unlock when device supports it and user enabled it.
- [ ] T15-007: Add fallback to PIN if biometric fails or is unavailable.
- [ ] T15-008: Add lock timeout behavior. Recommendation: lock immediately after app background for first version.
- [ ] T15-009: Add tests for PIN hash verification and app lock state transitions.
- [ ] T15-010: Document platform limitations for Face ID and fingerprint.

### Acceptance Criteria

- User can enable app lock.
- User can unlock with PIN.
- User can enable biometrics when supported.
- PIN is not stored in plain text.

---

## Plan 16: AI Assistant Phase 3 - Receipts, Repeated Expense Detection, Prediction

**Goal:** Add advanced AI features after core app data and reports are stable.

**Dependencies:** Plans 08, 09, and 10.

**Main packages likely needed:**

- `image_picker` or camera package.
- A remote AI/vision service through a backend proxy.

**Main files to create:**

- `lib/ai/models/ai_receipt_payload.dart`
- `lib/ai/models/ai_prediction_payload.dart`
- `lib/ai/services/receipt_ai_service.dart`
- `lib/ai/services/repeated_expense_detector.dart`
- `lib/ai/services/spending_prediction_service.dart`
- `lib/screens/ai_assistant/widgets/receipt_capture_button.dart`

### Tasks

- [ ] T16-001: Add receipt image capture or image picker UI.
- [ ] T16-002: Add permission handling for camera/gallery.
- [ ] T16-003: Send receipt image to backend or AI vision service. Do not store API secrets in Flutter app.
- [ ] T16-004: Parse receipt AI response into amount, date, merchant, category, currency, and confidence.
- [ ] T16-005: Show receipt preview before saving.
- [ ] T16-006: Add repeated expense detector that groups similar expenses by category, amount range, merchant/description, and schedule.
- [ ] T16-007: Show suggestion to convert repeated expenses into recurring expenses.
- [ ] T16-008: Add spending prediction service using historical averages for the next week/month.
- [ ] T16-009: Keep prediction explainable: show which categories drive the prediction.
- [ ] T16-010: Add tests for repeated expense detection and simple prediction algorithm.
- [ ] T16-011: Add safeguards that predictions are advice only, not financial guarantees.

### Acceptance Criteria

- Receipt image produces an editable preview.
- Repeated expense suggestions are shown but not auto-created.
- Predictions are generated from user history.
- All advanced AI outputs are reviewable and explainable.

---

## Cross-Plan Backlog

These tasks support multiple plans and should be scheduled when they become blockers:

- [ ] B-001: Add `bloc_test`, `mocktail`, and optionally `fake_cloud_firestore` to dev dependencies.
- [ ] B-002: Decide whether this repo will track Firebase rules and indexes.
- [ ] B-003: Add a lightweight app-level dependency injection pattern with `RepositoryProvider`.
- [ ] B-004: Add a common error model or failure message mapper for repository errors.
- [ ] B-005: Add a shared loading/empty/error widget set.
- [ ] B-006: Add a shared date range picker widget.
- [ ] B-007: Add a shared amount/currency formatter.
- [ ] B-008: Add a migration note if existing production Firestore data needs to be preserved.
- [ ] B-009: Add a development seed data strategy for local/manual testing.
- [ ] B-010: Add screenshots or manual QA checklists after major UI plans.

## Suggested Milestones

### Milestone 1: Production-Ready Core

Includes Plans 00, 01, 02, 03, and 04.

Outcome: authenticated users can create scoped expenses/categories with payment method and currency.

### Milestone 2: Finance Intelligence Without AI

Includes Plans 05, 06, and 07.

Outcome: users can set budget, search/filter expenses, and read weekly/monthly reports.

### Milestone 3: AI Assistant MVP

Includes Plan 08.

Outcome: natural language text creates an editable expense preview and saves only after confirmation.

### Milestone 4: AI Assistant Commands

Includes Plan 09.

Outcome: natural language search, summaries, advice, update, and delete with confirmation.

### Milestone 5: Product Completion Features

Includes Plans 10, 11, 12, 13, 14, and 15.

Outcome: recurring expenses, export, notifications, saving goals, offline feedback, and app protection.

### Milestone 6: Advanced AI

Includes Plan 16.

Outcome: receipt scanning, repeated expense detection, and spending prediction.

## What Should Wait Until Later

- Live currency conversion should wait until a provider and caching policy are chosen.
- Server-side recurring expense generation should wait until Cloud Functions or another backend runtime is approved.
- Remote AI provider integration should wait until API key storage and backend proxy strategy are approved.
- Complex Firestore server-side compound filters should wait until the local filter UX is proven.

## Handoff Checklist For Any Worker

- [ ] Read constitution.
- [ ] Pick exactly one plan or one milestone.
- [ ] Create or update Spec Kit artifacts for the selected work.
- [ ] Confirm dependencies are completed.
- [ ] Implement only the selected scope.
- [ ] Add or update tests.
- [ ] Run verification.
- [ ] Update constitution if architecture or conventions changed.
- [ ] Report completed tasks and any blocked tasks.
