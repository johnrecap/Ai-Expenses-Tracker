# Firestore Schema And Query Inventory

This app stores production user data under `users/{userId}`. Firestore rules use
the path `userId` as authoritative ownership; any explicit `userId` field on a
document must match the path. Legacy global `expenses` and `categories`
collections are denied.

## Repository Paths

| Feature | Path | Document id |
| --- | --- | --- |
| Expenses | `users/{userId}/expenses/{expenseId}` | `expenseId` |
| Categories | `users/{userId}/categories/{categoryId}` | `categoryId` |
| Monthly budgets | `users/{userId}/budgets/{budgetId}` | `YYYY-MM` from `Budget.budgetIdFor` |
| Category budgets | `users/{userId}/category_budgets/{categoryBudgetId}` | `{month}_{categoryId}_{currency}` |
| Recurring expenses | `users/{userId}/recurring_expenses/{recurringExpenseId}` | `recurringExpenseId` |
| Saving goals | `users/{userId}/saving_goals/{goalId}` | `goalId` |
| Settings | `users/{userId}/settings/profile` | `profile` |
| AI action logs | `users/{userId}/ai_actions/{actionId}` | `actionId` |
| Category aliases | `users/{userId}/category_aliases/{aliasId}` | `aliasId` |

## Document Shapes

Rules validate writes. Reads only require authenticated ownership so older
documents that entity parsers can tolerate remain readable.

### Expenses

Required: `expenseId`, `userId`, `date`, `amount`, `paymentMethod`,
`currency`, `createdAt`, `updatedAt`, `source`.

Optional: `categoryId`, `categoryName`, `categoryIcon`, `categoryColor`,
`category`, `description`, `recurringExpenseId`, `aiActionId`.

Validation: positive numeric amount, timestamp dates, 3-letter uppercase
currency, payment method in `cash`, `visa`, `wallet`, `bank_transfer`, source
in `manual`, `ai`, `recurring`, `receipt`.

### Categories

Required: `categoryId`, `userId`, `name`, `totalExpenses`, `icon`, `color`,
`isArchived`, `createdAt`, `updatedAt`.

Validation: non-empty name, non-negative integer `totalExpenses`, integer color,
boolean archive flag, timestamp dates. Hard deletes are denied because the
repository uses archive/update behavior.

### Budgets

Required: `budgetId`, `userId`, `month`, `year`, `amount`, `currency`,
`warningThresholdPercent`, `createdAt`, `updatedAt`.

Validation: month number 1-12, year 2000-2100, positive amount, 3-letter
uppercase currency, warning threshold 0-100.

### Category Budgets

Required: `categoryBudgetId`, `userId`, `categoryId`, `categoryName`, `month`,
`currency`, `limitAmount`, `warningThresholdPercent`, `isArchived`,
`createdAt`, `updatedAt`.

Validation: `month` is `YYYY-MM`, positive `limitAmount`, 3-letter uppercase
currency, warning threshold 0-100, boolean archive flag.

### Recurring Expenses

Required: `recurringExpenseId`, `userId`, `amount`, `paymentMethod`,
`currency`, `startDate`, `nextRunDate`, `frequency`, `isActive`, `isArchived`,
`createdAt`, `updatedAt`.

Optional: `category`, `categoryId`, `categoryName`, `categoryIcon`,
`categoryColor`, `description`, `endDate`.

Validation: positive amount, valid payment/currency values, timestamp schedule
fields, `frequency` in `daily`, `weekly`, `monthly`, boolean state flags.

### Saving Goals

Required: `goalId`, `userId`, `name`, `targetAmount`, `currentAmount`,
`currency`, `isArchived`, `createdAt`, `updatedAt`.

Optional: `deadline`.

Validation: non-empty name, positive target amount, non-negative current amount,
3-letter uppercase currency, optional timestamp deadline.

### Settings

Path: `users/{userId}/settings/profile`.

Required: `userId`, `languagePreference`, `baseCurrency`,
`supportedCurrencies`, `defaultPaymentMethod`, `notificationSettings`,
`onboardingCompleted`, `onboardingVersion`, `guidedTourCompletedVersion`,
`guidedTourSkippedVersion`, `updatedAt`.

Optional: `guidedTourLastStepId`.

`notificationSettings` requires `budgetAlertsEnabled`, `dailyReminderEnabled`,
`reminderTime`, `weeklyDigestEnabled`, `weeklyDigestTime`; optional
`lastExceededAlertMonth`.

Validation: 3-letter uppercase base currency, supported currency list with
1-20 3-letter uppercase entries, language preference in `system`, `en`, `ar`,
valid payment method, boolean onboarding completion, non-negative onboarding and
guided tour versions, nullable/bounded guided tour last step id, and `HH:mm`
reminder times.

### AI Action Logs

Required: `actionId`, `userId`, `rawInput`, `parsedResponse`, `intent`,
`confidence`, `status`, `createdAt`.

Optional: `confirmedAt`, `targetExpenseId`, `errorMessage`, `provider`, `model`,
`providerRequestId`, `inputTokens`, `outputTokens`, `errorCode`.

Validation: confidence between 0 and 1, status in `previewed`, `confirmed`,
`canceled`, `failed`, optional token counts are non-negative integers. The rules
allow only known top-level fields, which rejects provider metadata maps such as
raw headers or secrets.

### Category Aliases

Required: `aliasId`, `userId`, `categoryId`, `phrase`, `locale`, `createdAt`,
`updatedAt`, `lastUsedAt`, `useCount`.

Validation: non-empty category id and phrase, locale up to 32 characters,
timestamp dates, non-negative use count. Deletes are allowed because the
repository exposes `deleteAlias`.

## Query Inventory

| Repository | Query | Composite index |
| --- | --- | --- |
| `FirebaseExpenseRepo.watchRecentExpensePage` | `orderBy date desc`, `orderBy expenseId desc`, `limit(defaultExpensePageSize + 1)` | Declared in `firestore.indexes.json` |
| `FirebaseExpenseRepo.getExpensePage` | optional `where date >=`, optional `where date <=`, then `orderBy date desc`, `orderBy expenseId desc`, `startAfter([date, expenseId])`, `limit(pageSize + 1)` | Declared in `firestore.indexes.json` |
| `FirebaseExpenseRepo.getExpenses/watchExpenses` | Legacy full-list compatibility path with `orderBy('date', descending: true)` | Built-in single-field index; Home no longer uses this for initial expense list rendering |
| `FirebaseExpenseRepo.getExpensesByFilter` | Legacy date-scoped compatibility path with optional `where date >=`, optional `where date <=`, then `orderBy date desc` before local filters | Same-field range/order uses single-field index |
| `FirebaseCategoryRepository` | `orderBy('name')` | Built-in single-field index |
| `FirebaseBudgetRepository` | direct `doc(...).get/snapshots` | None |
| `FirebaseCategoryBudgetRepository` | `where('month', isEqualTo: month)` | Built-in single-field index |
| `FirebaseRecurringExpenseRepository.getDueRecurringExpenses` | `where isActive == true`, `where isArchived == false`, `where nextRunDate <= now`, `orderBy nextRunDate` | Declared in `firestore.indexes.json` |
| `FirebaseRecurringExpenseRepository.watchRecurringExpenses` | `orderBy('nextRunDate')` | Built-in single-field index |
| `FirebaseSavingGoalRepository.watchSavingGoals` | `orderBy('createdAt', descending: true)` | Built-in single-field index |
| `FirebaseSettingsRepository` | direct `settings/profile` doc reads | None |
| `FirebaseAiActionLogRepository.getRecentActionLogs` | `orderBy('createdAt', descending: true).limit(...)` | Built-in single-field index |
| `FirebaseCategoryAliasRepository` | `orderBy('lastUsedAt', descending: true)` | Built-in single-field index |
