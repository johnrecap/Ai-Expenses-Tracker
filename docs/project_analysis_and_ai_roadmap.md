# Expense Tracker Project Analysis and AI Roadmap

Date: 2026-05-15

> Historical notice: this document records the early project analysis and
> roadmap from 2026-05-15. It is useful for understanding project evolution, but
> several findings are no longer current. For authoritative current state, read
> `.specify/memory/constitution.md`, `specs/README.md`, and
> `docs/implementation_plans/deferred-and-advanced-work.md`.

## ملخص عربي سريع

المشروع الحالي مناسب للتطوير التدريجي وليس لإعادة البناء من الصفر. عنده أساس جيد: Flutter + Bloc + Firebase + Repository Package منفصل، لكن طبقة البيانات ما زالت بسيطة جدًا وتعتمد على collections عامة في Firestore بدون عزل للمستخدمين.

أهم قرار لازم يتاخد قبل التنفيذ هو شكل بيانات Firestore بعد إضافة Firebase Authentication. التوصية الأقوى هي نقل البيانات إلى:

```text
users/{userId}/expenses
users/{userId}/categories
users/{userId}/budgets
users/{userId}/recurring_expenses
users/{userId}/saving_goals
users/{userId}/ai_actions
```

الترتيب العملي المقترح:

1. إصلاحات استقرار صغيرة في المشروع الحالي.
2. إضافة تسجيل الدخول وعزل البيانات لكل مستخدم.
3. توسيع موديل المصروف ليشمل الوصف، طريقة الدفع، العملة، وتواريخ الإنشاء/التعديل.
4. إضافة الميزانية والتقارير والفلاتر.
5. إضافة AI Assistant كطبقة منفصلة تعرض Preview قبل أي إضافة/تعديل/حذف.

أصعب أجزاء المشروع ليست الواجهة، بل: ترحيل شكل البيانات، أوامر التعديل/الحذف بالـ AI، المصروفات المتكررة بشكل موثوق، الإشعارات الذكية في الخلفية، وتحويل العملات بمصدر أسعار حقيقي.

## Executive Summary

Historical note: this section describes the app before later Spec Kit plans
implemented authentication, user-scoped Firestore paths, budgets, recurring
expenses, reports, exports, settings, onboarding, guided tour, monetization
foundation, and AI preview/gateway flows. Treat the numbered list below as
completed roadmap history unless a current spec or deferred backlog item says
otherwise.

The current project is a small Flutter expense tracker with a clean but early-stage structure. It already uses Bloc, Firebase Core, Cloud Firestore through a local `expense_repository` package, `fl_chart`, `intl`, and `flutter_colorpicker`.

The app should not be rebuilt from scratch. The right approach is to evolve the existing architecture in phases:

1. Stabilize the current app and data model.
2. Add Firebase Authentication and user-scoped Firestore data.
3. Expand the domain model for payment methods, currency, budgets, recurring expenses, reports, saving goals, and filters.
4. Add offline-ready repository behavior.
5. Add the AI Assistant as a separate service layer with structured JSON outputs and a confirmation-first workflow.

The biggest risk is not Flutter UI complexity. The biggest risk is changing the data model safely while the current repository stores simple global collections without `userId`, ownership, filtering, update/delete methods, or migration support.

## Current Project Structure

Main app:

```text
lib/
  main.dart
  app.dart
  app_view.dart
  simple_bloc_observer.dart
  data/data.dart
  screens/
    splash_screen.dart
    home/
      views/home_screen.dart
      views/main_screen.dart
      blocs/get_expenses_bloc/
    add_expense/
      views/add_expense.dart
      views/category_creation.dart
      blocs/create_expense_bloc/
      blocs/get_categories_bloc/
      blocs/create_categorybloc/
    stats/
      stats.dart
      chart.dart
```

Local repository package:

```text
packages/expense_repository/
  lib/expense_repository.dart
  lib/src/expense_repo.dart
  lib/src/firebase_expense_repo.dart
  lib/src/models/category.dart
  lib/src/models/expense.dart
  lib/src/entities/category_entity.dart
  lib/src/entities/expense_entity.dart
```

Platform folders exist for Android, iOS, web, Windows, Linux, and macOS.

## Current Dependencies

Root `pubspec.yaml` includes:

- `flutter_bloc`, `bloc`, `equatable`
- `firebase_core`
- `fl_chart`
- `intl`
- `flutter_colorpicker`
- `font_awesome_flutter`
- `uuid`
- local package `expense_repository`

The local repository package includes:

- `cloud_firestore`
- `firebase_auth`

Important note: `firebase_auth` exists in `packages/expense_repository/pubspec.yaml`, but the app does not currently use authentication in the UI, routing, or repository queries.

## Current App Flow

1. `main.dart`
   - Initializes Flutter bindings.
   - Calls `Firebase.initializeApp()`.
   - Registers `SimpleBlocObserver`.
   - Runs `MyApp`.

2. `app_view.dart`
   - Creates `MaterialApp`.
   - Sets the theme.
   - Uses `SplashScreen` as the home screen.

3. `SplashScreen`
   - Waits 3 seconds.
   - Pushes `HomeScreen`.
   - Creates `GetExpensesBloc(FirebaseExpenseRepo())`.
   - Dispatches `GetExpenses()`.

4. `HomeScreen`
   - Reads `GetExpensesBloc`.
   - Shows bottom navigation with two tabs:
     - Home
     - Stats
   - Opens `AddExpense` through `Navigator.push`.
   - Creates separate repository instances for create expense, get categories, and create category.

5. `AddExpense`
   - Lets the user enter amount.
   - Lets the user select a category.
   - Lets the user create a new category through a dialog.
   - Lets the user select a date.
   - Saves the expense through `CreateExpenseBloc`.

6. `Stats`
   - Shows a static redacted chart.
   - It does not currently calculate real statistics from expenses.

## Current Architecture

The project uses a simple layered shape:

```text
Flutter Screens
  -> Bloc
    -> ExpenseRepository interface
      -> FirebaseExpenseRepo
        -> Firestore
```

This is a good starting point. The existing repository package is the right place to keep data models and Firebase access. Bloc usage is consistent enough to extend without changing the whole app.

Current limitations:

- Repository is focused only on create/list for expenses and categories.
- No update/delete operations.
- No filtering methods.
- No user ownership.
- No stream-based real-time updates.
- No pagination.
- No offline-local data source abstraction.
- UI creates repository instances directly instead of injecting a shared instance at app level.
- Models are mutable classes, which makes state changes harder to reason about as the app grows.

## Bloc Usage

Current blocs:

- `GetExpensesBloc`
  - Event: `GetExpenses`
  - States: initial/loading/success/failure
  - Calls `expenseRepository.getExpenses()`

- `CreateExpenseBloc`
  - Event: `CreateExpense`
  - States: initial/loading/success/failure
  - Calls `expenseRepository.createExpense(expense)`

- `GetCategoriesBloc`
  - Event: `GetCategories`
  - States: initial/loading/success/failure
  - Calls `expenseRepository.getCategory()`

- `CreateCategoryBloc`
  - Event: `CreateCategory`
  - States: initial/loading/success/failure
  - Calls `expenseRepository.createCategory(category)`

The pattern is simple and readable. It should be preserved, but feature growth needs more focused blocs/cubits:

- `AuthBloc`
- `BudgetBloc`
- `ExpenseFilterCubit`
- `ReportCubit`
- `RecurringExpenseBloc`
- `ExportCubit`
- `NotificationCubit`
- `SavingGoalBloc`
- `AiAssistantCubit` or `AiAssistantBloc`
- `AppLockCubit`

For the AI Assistant specifically, a `Cubit` may be enough for parsing/preview states, while actual confirmed commands should dispatch existing domain blocs or repository methods.

## Firebase Usage

Current Firestore collections:

```text
categories
expenses
```

Current Firestore behavior:

- `createCategory` writes to `categories/{categoryId}`.
- `getCategory` reads all documents from `categories`.
- `createExpense` writes to `expenses/{expenseId}`.
- `getExpenses` reads all documents from `expenses`.

This means all users would currently see the same expenses and categories if authentication is added without changing the data structure.

Recommended Firestore structure:

```text
users/{userId}
  profile/settings
  categories/{categoryId}
  expenses/{expenseId}
  budgets/{budgetId}
  recurring_expenses/{recurringExpenseId}
  saving_goals/{savingGoalId}
  exports/{exportId}
  ai_actions/{actionId}
```

Alternative structure:

```text
expenses/{expenseId} with userId
categories/{categoryId} with userId
budgets/{budgetId} with userId
```

Recommendation: use user subcollections for this app. It makes security rules simpler and naturally scopes reads/writes by user.

## Current Models

Current `Expense`:

```dart
class Expense {
  String expenseId;
  Category category;
  DateTime date;
  int amount;
}
```

Current `Category`:

```dart
class Category {
  String categoryId;
  String name;
  int totalExpenses;
  String icon;
  int color;
}
```

These models are not enough for the requested roadmap.

Recommended `Expense` fields:

```text
expenseId
userId
categoryId
categorySnapshot/name/icon/color
amount
currency
baseCurrencyAmount
description
date
paymentMethod
createdAt
updatedAt
source
recurringExpenseId?
aiActionId?
```

Recommended `Category` fields:

```text
categoryId
userId
name
icon
color
createdAt
updatedAt
isArchived
```

Do not keep `totalExpenses` as the source of truth unless there is a deliberate aggregation strategy. It can become inaccurate. Prefer calculating totals by query/report logic first, then add cached aggregate documents later if performance requires it.

## Current Screens

### Home

Files:

- `lib/screens/home/views/home_screen.dart`
- `lib/screens/home/views/main_screen.dart`

Current behavior:

- Shows welcome header with hardcoded name `Jonh Doe`.
- Shows total expenses as "Total Balacnce".
- Shows hardcoded income and expense values inside the card.
- Shows a list of expenses loaded from Firestore.
- Adds a newly created expense into the existing list using `state.expenses.insert(0, newExpense)`.

Issues:

- User name is hardcoded.
- Currency is hardcoded as `$`.
- Income/expense card values are partly static.
- List mutation inside a Bloc success state is not ideal.
- No empty state, error state details, search, filters, or pagination.

### Add Expense

File:

- `lib/screens/add_expense/views/add_expense.dart`

Current behavior:

- Amount field only.
- Category selector.
- Category creation button.
- Date picker.
- Save button.

Issues:

- No validation before parsing amount.
- `int.parse` can crash on empty or invalid input.
- Date picker only allows today and future dates, which is wrong for expense tracking and the AI example "yesterday".
- No description.
- No payment method.
- No currency.
- No recurring settings.
- No AI preview/autofill.

### Categories

File:

- `lib/screens/add_expense/views/category_creation.dart`

Current behavior:

- Category creation exists as a dialog, not a full screen.
- User can choose name, icon, and color.

Issues:

- No category management screen.
- No edit/delete/archive.
- No validation.
- Typo in folder name `create_categorybloc`.
- Uses `Color.value`, which is deprecated in the current Flutter SDK.

### Stats

Files:

- `lib/screens/stats/stats.dart`
- `lib/screens/stats/chart.dart`

Current behavior:

- Shows a static chart.
- Chart is always redacted.

Issues:

- It does not use actual expenses.
- No weekly/monthly reports.
- No top category calculation.
- No month-over-month comparison.

## Verification Results

Historical note: these results are from the 2026-05-15 baseline. Later Spec Kit
plans replaced the original starter widget test and repaired the analyzer/test
baseline. Use the constitution and active plan verification notes for current
commands and known failures.

Commands run:

```text
flutter pub get
flutter analyze
flutter test
```

Result:

- `flutter pub get` completed.
- `flutter analyze` found one issue:
  - `Color.value` is deprecated in `lib/screens/add_expense/views/category_creation.dart`.
- `flutter test` failed because `test/widget_test.dart` still contained the
  original Flutter starter assertion and did not match this app.

This means the app is close to analyzer-clean, but the test suite is not useful yet.

## Feature Feasibility Assessment

### 1. Firebase Authentication

Can be added.

Required work:

- Add `AuthRepository`.
- Add `AuthBloc`.
- Add login/register/reset password screens.
- Add authenticated routing.
- Change Firestore paths to user-scoped data.
- Add Firestore security rules.
- Migrate existing global data if needed.

Difficulty: Medium.

Risk: High if done after adding other features. This should be first.

### 2. Monthly Budget

Can be added.

Required work:

- Add `Budget` model.
- Add budget repository methods.
- Add monthly spending query/report calculation.
- Add budget UI.
- Add warning states:
  - near limit
  - exceeded limit

Difficulty: Medium.

Dependency: Auth and expanded expense model.

### 3. Recurring Expenses

Can be added.

Required work:

- Add `RecurringExpense` model.
- Store recurrence frequency: daily/weekly/monthly.
- Add next run date.
- Add service to materialize due expenses.
- Decide whether recurring expenses are generated on app open, by scheduled backend function, or both.

Difficulty: Medium to High.

Hard part: reliable background generation. Pure client-side generation can miss runs if the user does not open the app.

### 4. Advanced Search and Filters

Can be added.

Required work:

- Add `ExpenseFilter` model.
- Add repository query methods.
- Add UI controls.
- Add client-side filtering first for small datasets.
- Add Firestore indexed queries later for scale.

Difficulty: Medium.

Hard part: Firestore compound queries and indexes for date/category/payment/amount combinations.

### 5. Weekly and Monthly Reports

Can be added.

Required work:

- Add report calculation service.
- Feed real data into `fl_chart`.
- Add top categories.
- Add month comparison.

Difficulty: Medium.

Dependency: consistent date/currency/payment fields.

### 6. Export PDF / Excel / CSV

Can be added.

Required packages may include:

- `csv`
- `pdf`
- `printing`
- `excel`
- `path_provider`
- `share_plus`

Difficulty: Medium.

Hard part: platform-specific file saving/sharing behavior.

### 7. Smart Notifications

Can be added partially.

Required packages may include:

- `flutter_local_notifications`
- `timezone`
- possibly `firebase_messaging` later

Difficulty: Medium to High.

What is easy:

- Local budget warnings.
- Reminder if no expense has been logged today.

What is harder:

- Truly smart notifications when the app is closed, especially across all platforms.

### 8. Payment Methods

Can be added easily.

Recommended enum:

```text
cash
visa
wallet
bankTransfer
```

Difficulty: Low.

Dependency: Expense model migration and Add Expense UI update.

### 9. Saving Goals

Can be added.

Required work:

- Add `SavingGoal` model.
- Add create/list/update repository methods.
- Add progress calculation.
- Add UI screen/card.

Difficulty: Medium.

### 10. Multi-Currency

Can be added as a foundation.

Recommended first step:

- Store `currency` on every expense.
- Store `baseCurrency` in user settings.
- Do not implement live conversion until a provider is chosen.

Difficulty: Low for storing currency, Medium/High for conversion.

Needs product decision:

- Which exchange-rate provider?
- Online-only conversion or cached rates?

### 11. Offline Mode

Partially available through Firestore offline persistence, but should not be treated as complete.

Can be added.

Recommended approach:

- Enable and rely on Firestore local persistence where supported.
- Add pending/synced state to local UI if needed.
- Avoid adding a full local database until requirements demand it.

Difficulty: Medium.

Hard part: conflict handling and user feedback for pending writes.

### 12. App Protection

Can be added.

Required packages may include:

- `local_auth`
- secure storage package for PIN hash/salt

Difficulty: Medium.

Hard part: platform support differences and fallback behavior.

## AI Assistant Scope

The AI Assistant is the most important feature and should be implemented as a separate vertical slice, not mixed into the current `AddExpense` widget directly.

Required principles:

- AI must not write to Firestore directly.
- AI must return structured data.
- AI output must always produce a preview before any create/update/delete action.
- User confirmation is required for mutations.
- Low-confidence or ambiguous results must ask the user to clarify.
- The app must keep a record of AI actions for debugging and user trust.

## Proposed AI Architecture

```text
AI Assistant UI
  -> AiAssistantCubit
    -> AiService interface
      -> OpenAI/LLM provider implementation
    -> AiActionMapper
    -> Existing repositories/blocs after user confirms
```

Recommended folders:

```text
lib/ai/
  models/
    ai_intent.dart
    ai_action_preview.dart
    ai_expense_payload.dart
    ai_response.dart
  services/
    ai_service.dart
    remote_ai_service.dart
    mock_ai_service.dart
  cubit/
    ai_assistant_cubit.dart
    ai_assistant_state.dart
  widgets/
    ai_assistant_sheet.dart
    ai_action_preview_card.dart
```

Alternative if following current feature-folder style:

```text
lib/screens/ai_assistant/
  cubit/
  models/
  services/
  views/
  widgets/
```

Recommendation: use `lib/ai` for the service/domain layer and add UI under `lib/screens/ai_assistant`. This keeps provider logic separate from screens.

## AI Response Model

The proposed JSON shape is good, but it should be expanded to support multiple actions and errors:

```json
{
  "intent": "add_expense",
  "expense": {
    "amount": 250,
    "categoryName": "Food",
    "date": "2026-05-14",
    "paymentMethod": "cash",
    "currency": "EGP",
    "description": "مصروف أكل"
  },
  "target": null,
  "filters": null,
  "summaryRange": null,
  "confidence": 0.92,
  "needsConfirmation": true,
  "clarifyingQuestion": null
}
```

For unclear text:

```json
{
  "intent": "unknown",
  "expense": null,
  "target": null,
  "filters": null,
  "summaryRange": null,
  "confidence": 0.32,
  "needsConfirmation": false,
  "clarifyingQuestion": "تقصد صرفت كام؟"
}
```

## AI Intents

Supported phase 1:

- `add_expense`
- `search_expenses`
- `summarize_expenses`
- `financial_advice`

Supported phase 2:

- `update_expense`
- `delete_expense`

Supported phase 3:

- receipt image extraction
- recurring expense detection
- spending prediction

Reasoning:

- Add/search/summary/advice are safer.
- Update/delete need target matching logic and stricter confirmation.
- Receipt image extraction needs camera/gallery, OCR/vision, permissions, and better error handling.

## AI Confirmation Flow

For add expense:

```text
User text
  -> AiAssistantCubit.parseText
  -> AiService returns structured JSON
  -> Cubit validates confidence and required fields
  -> App shows preview card
  -> User edits fields if needed
  -> User taps Confirm
  -> Existing CreateExpenseBloc/repository creates expense
```

For update/delete:

```text
User command
  -> AI extracts intent and target description
  -> App searches candidate expenses
  -> App shows matched expense(s)
  -> User confirms exact target
  -> Repository update/delete runs
```

## Suggested Implementation Phases

### Phase 0: Stabilization

Goal: make the current app safe to extend.

Tasks:

- Fix the default widget test.
- Add basic validation to Add Expense.
- Allow selecting past dates.
- Replace deprecated `Color.value`.
- Stop mutating Bloc state lists directly.
- Add empty/error states.
- Inject repository once at app level.

### Phase 1: Authentication and User-Scoped Data

Goal: every user sees only their own data.

Tasks:

- Add `AuthRepository`.
- Add `AuthBloc`.
- Add login/register screens.
- Add auth gate before `HomeScreen`.
- Change Firestore structure to `users/{userId}/...`.
- Add `userId` to models or infer it from path.
- Add Firestore security rules.

### Phase 2: Expense Model Upgrade

Goal: support the requested finance features without repeated migrations.

Tasks:

- Add `description`.
- Add `paymentMethod`.
- Add `currency`.
- Add `createdAt` and `updatedAt`.
- Replace embedded category object with `categoryId` plus optional category snapshot.
- Add update/delete repository methods.
- Add query/filter repository methods.

### Phase 3: Budget, Filters, Reports

Goal: deliver the highest-value non-AI product features.

Tasks:

- Monthly budget model and UI.
- Budget progress card on Home.
- Budget warning logic.
- Search and advanced filters.
- Real weekly/monthly reports.
- Top categories and month comparison.

### Phase 4: AI Assistant Phase 1

Goal: AI-assisted add expense with preview confirmation.

Tasks:

- Add AI models.
- Add AI service interface.
- Add mock AI service for local testing.
- Add real provider implementation behind an interface.
- Add `AiAssistantCubit`.
- Add AI bottom sheet or dedicated assistant screen.
- Add preview UI.
- Connect confirmed add action to existing expense creation flow.

### Phase 5: AI Assistant Phase 2

Goal: commands over existing data.

Tasks:

- Search expenses by natural language.
- Summarize current week/month.
- Generate short financial advice from local aggregates.
- Add update/delete commands with strict target confirmation.
- Store AI action logs.

### Phase 6: Export, Notifications, Offline, Security

Goal: production-quality app features.

Tasks:

- CSV/PDF/Excel export by date range.
- Local notifications for budget and missing entries.
- Firestore offline sync behavior and pending-write UI.
- App lock using PIN and biometrics.

### Phase 7: Advanced AI

Goal: smart assistant features.

Tasks:

- Receipt image parsing.
- Recurring expense detection.
- Spending prediction.
- Personalized financial recommendations.

## What Should Not Be Done First

Do not start with:

- Receipt scanning.
- Prediction.
- Full offline database rewrite.
- PDF/Excel export.
- Update/delete AI commands.
- Multi-currency conversion provider.

These depend on a stronger model, authenticated user data, and reliable query/report logic.

## What Is Hard or Needs Decisions

### AI Provider

Needs a product/security decision:

- Which model/provider?
- Where is the API key stored?
- Should calls go directly from the app or through a backend?

Recommendation: do not call an LLM directly from the Flutter app with a secret API key. Use a backend proxy or Firebase Cloud Functions if production security matters.

### Firestore Migration

Existing data is in global collections. If real users already have data, migration is needed.

If this is a demo app with no important production data, the easiest path is to start new user-scoped collections and ignore old global collections.

### Offline Mode

Firestore supports offline persistence, but advanced offline UX still needs:

- pending write indicators
- conflict policy
- retry/error display

### Recurring Expenses

Client-side recurrence is easy but not fully reliable. Cloud Functions or scheduled backend jobs are better for production.

### Notifications

Local notifications can handle reminders. Server-driven smart notifications need backend logic.

### Multi-Currency Conversion

Storing currencies is simple. Conversion needs:

- exchange-rate source
- caching policy
- historical rates or current rates

## Recommended New Repository Interfaces

Keep the repository pattern and split responsibilities:

```text
AuthRepository
ExpenseRepository
CategoryRepository
BudgetRepository
ReportRepository
RecurringExpenseRepository
SavingGoalRepository
ExportRepository
AiRepository or AiService
```

Do not put all methods into the existing `ExpenseRepository`; it will become too large.

## Recommended State Management Shape

Keep Bloc/Cubit. Do not introduce another state management package.

Recommended:

- Bloc for event-heavy flows:
  - auth
  - create/update/delete expense
  - recurring expenses
- Cubit for local UI/filter/assistant state:
  - filters
  - reports
  - AI preview
  - app lock

## Security Rules Direction

Firestore rules should enforce user ownership.

Recommended shape:

```text
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

More granular rules can be added after the final document structure is confirmed.

## Testing Strategy

Historical note: the bullets below were recommendations from the initial audit.
Several are already implemented in later plans; use `specs/README.md` and the
current deferred backlog before treating any item here as open.

Current test state is weak. Before large features:

- Replace default counter widget test.
- Add repository unit tests with fake repositories.
- Add Bloc tests using `bloc_test`.
- Add model serialization tests.
- Add AI JSON parsing tests.
- Add filter/report calculation tests.

Recommended packages:

- `bloc_test`
- `mocktail`
- `fake_cloud_firestore` for repository tests if staying close to Firestore behavior

## Immediate Next Step

The next practical step is not implementing all features at once. The next step should be a focused design decision:

1. Confirm Firestore data structure.
2. Confirm auth screens required for phase 1.
3. Confirm AI provider/backend approach.
4. Confirm whether existing global Firestore data must be migrated.

After those decisions, the first implementation batch should be:

1. Stabilization fixes.
2. Auth and user-scoped repository.
3. Expense model upgrade.
4. AI-assisted add expense preview.

## Final Recommendation

Build this as a phased upgrade, not a big rewrite. The existing code style can be preserved, but the data layer needs to be split and strengthened before advanced features are added.

The best first milestone is:

```text
Authenticated user
  -> user-scoped expenses/categories
  -> upgraded expense model
  -> Add Expense with description/payment/currency
  -> AI text-to-expense preview with confirm
```

That milestone proves the most important architecture decisions and creates the foundation for budgets, reports, filters, recurring expenses, export, notifications, and app protection.
