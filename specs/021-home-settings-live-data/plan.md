# Implementation Plan: Home And Settings Live Data

**Branch**: `[021-home-settings-live-data]` | **Date**: 2026-05-17 | **Spec**: `specs/021-home-settings-live-data/spec.md`

## Summary

Replace hardcoded Home values with a computed `HomeSummary` based on authenticated user, expenses, budget, and settings. Expand Settings into durable sections that persist through `SettingsRepository` and directly affect app defaults.

## Technical Context

**Language/Version**: Dart 3.x, Flutter Bloc.  
**Primary Dependencies**: Existing `AuthBloc`, `GetExpensesBloc`, `BudgetBloc`, `SettingsCubit`, `SettingsRepository`, `BudgetCalculator`, `ReportCalculator`.  
**Storage**: Firestore `users/{userId}/settings/profile`; no new backend required for MVP.  
**Testing**: Calculator unit tests, SettingsCubit tests, Home widget tests, `flutter analyze`, `flutter test`.  
**Target Platform**: Flutter app.  
**Project Type**: App UI/data integration.  
**Performance Goals**: Home summary calculation should run synchronously under 100 ms for 1,000 expenses.  
**Constraints**: No currency conversion unless a future conversion plan exists; no fake income.  
**Scale/Scope**: Current authenticated user data.

## Constitution Check

- **Repository Pattern**: Pass. Settings and budgets stay behind repositories.
- **User Ownership**: Pass. Only authenticated user data is used.
- **Mixed Currency Rule**: Pass. Do not add incompatible currencies.
- **Change Scope**: Pass. This fixes Home and Settings without redesigning the full app.

## Project Structure

```text
lib/screens/home/
├── models/home_summary.dart             # new
├── services/home_summary_calculator.dart # new
├── views/home_screen.dart
└── views/main_screen.dart

lib/screens/settings/
├── blocs/settings_bloc/settings_cubit.dart
├── views/settings_screen.dart
└── widgets/
    ├── currency_settings_section.dart    # new
    ├── payment_settings_section.dart     # new
    ├── ai_settings_section.dart          # new
    ├── monetization_settings_section.dart # placeholder until Plan 023
    └── privacy_settings_section.dart     # new

packages/expense_repository/lib/src/
├── models/user_settings.dart
└── entities/user_settings_entity.dart

test/home/
└── home_summary_calculator_test.dart
test/settings/
└── settings_cubit_test.dart
```

**Structure Decision**: Add a calculator/model for Home rather than embedding calculations in `MainScreen`. Split settings widgets by section so future premium/ads/AI preferences do not make `SettingsScreen` too large.

## Research

### Decision: Replace "Total Balance" with defined metrics
**Rationale**: The app tracks expenses and budgets, not income/account balances. Calling the value "Total Balance" is misleading unless income/account support exists.  
**Chosen behavior**: Show "This Month Spending" and "Budget Remaining" when budget exists; otherwise show spending and "Set monthly budget".

### Decision: Settings are source of defaults
**Rationale**: Base currency and default payment method already exist in `UserSettings`; Add Expense and AI preview should consume them consistently.

### Decision: Keep monetization settings as placeholder here
**Rationale**: Real Free/Premium and ads require a separate entitlement/ad plan with store and consent considerations.

## Data Model

### HomeSummary
- `displayName`: from authenticated user display name/email fallback.
- `periodStart`, `periodEnd`.
- `spendingTotal`.
- `currency`.
- `hasMixedCurrencies`.
- `budgetAmount`, `budgetRemaining`, `budgetStatus`.
- `topCategoryName`.
- `pendingSyncCount`.

### UserSettings Existing/Extended
- Existing: `baseCurrency`, `supportedCurrencies`, `defaultPaymentMethod`, `notificationSettings`.
- Potential extension: `aiSettings`, `privacySettings`, `monetizationSettingsPlaceholder` only if needed for UI state.

## Verification

```text
flutter analyze
flutter test test/home/home_summary_calculator_test.dart test/settings/settings_cubit_test.dart
flutter test
```

Manual QA must change settings, restart app, and confirm Home/Add Expense/AI reflect the changes.
