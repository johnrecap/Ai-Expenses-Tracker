# Implementation Plan: Reports Currency Conversion

**Branch**: `063-reports-currency-conversion` | **Date**: 2026-05-20 | **Spec**: `specs/063-reports-currency-conversion/spec.md`  
**Input**: Feature specification from `specs/063-reports-currency-conversion/spec.md`

## Summary

Fix the reports/statistics inconsistency by moving Reports from same-currency filtering to the same conversion path used by Home. `ReportCalculator` will calculate all totals in `UserSettings.baseCurrency`, using `MoneyConversionService` and `UserSettings.conversionRates`. Convertible mixed-currency expenses will be included in totals, buckets, categories, top category, previous-period comparison, AI summaries/advice, and weekly digest. Only expenses with missing/invalid rates remain ignored.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `expense_repository`, existing `UserSettings`, existing `MoneyConversionService`, Flutter Bloc  
**Storage**: No new persistence. Uses existing `UserSettings.conversionRates`, `baseCurrency`, and `supportedCurrencies`.  
**Testing**: `test/reports`, AI summary/advice tests, weekly digest tests, selected Home regression tests  
**Target Platform**: Flutter mobile app, primarily Android  
**Project Type**: Mobile app  
**Performance Goals**: Report calculation remains in-memory O(n) over the loaded expense list. No network call during report rendering.  
**Constraints**: No live rate fetch in Reports; no silent raw addition of different currencies; no Firebase imports in widgets/calculators; Reports must stay deterministic/offline from saved settings.  
**Scale/Scope**: One authenticated user's loaded expenses for weekly/monthly report periods.

## Root Cause

`lib/services/report_calculator.dart` currently accepts `currency` only and executes:

```dart
if (expense.currency.toUpperCase() != normalizedCurrency) {
  ignoredCurrencyCount++;
  continue;
}
```

That is correct for the old conservative mixed-currency behavior, but it is now stale because Plan 060/Home uses saved rates. `ReportCubit` also stores only `_currency`, and `ReportsScreen` creates `ReportCubit(expenses: expenses)` without reading `SettingsRepository` or `UserSettings`.

## Constitution Check

- Spec Kit artifacts live under `specs/063-reports-currency-conversion/`: PASS.
- Currency math must be deterministic and local, using stored settings/rates: PASS.
- No new network/provider call from UI report rendering: PASS.
- User-scoped data boundaries remain unchanged: PASS.
- UI strings should use ARB if new copy is added: PASS.
- Existing Home conversion logic should be reused rather than duplicated: PASS.

## Project Structure

### Documentation

```text
specs/063-reports-currency-conversion/
|-- spec.md
|-- plan.md
`-- tasks.md

docs/implementation_plans/deferred-and-advanced-work.md
```

### Source Code

```text
lib/services/report_calculator.dart
lib/screens/home/services/money_conversion_service.dart
lib/screens/reports/cubit/report_cubit.dart
lib/screens/reports/views/reports_screen.dart
lib/screens/stats/stats.dart
lib/ai/cubit/ai_assistant_cubit.dart
lib/ai/services/ai_advice_service.dart
lib/ai/services/financial_advice_ai_service.dart
lib/engagement/services/weekly_digest_calculator.dart
packages/expense_repository/lib/src/models/expense_report.dart
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
```

### Tests

```text
test/reports/report_calculator_test.dart
test/reports/report_cubit_test.dart
test/ai/ai_assistant_cubit_test.dart
test/ai/ai_advice_service_test.dart
test/engagement/weekly_digest_calculator_test.dart
test/home/home_summary_calculator_test.dart
```

## Design Decisions

### Decision 1: Reuse MoneyConversionService

Use `MoneyConversionService.convertExpense(expense, settings)` inside `ReportCalculator`. This keeps Home, Reports, Budget, and future finance features aligned on one conversion rule: source amount multiplied by `settings.conversionRates[sourceCurrency]` into `settings.baseCurrency`.

### Decision 2: ReportCalculator Takes UserSettings

Change `ReportCalculator.calculate` to require `UserSettings settings` instead of `String currency`. This avoids passing a base currency without rates and makes missing-rate behavior explicit.

Backward compatibility can be handled in one of two ways during implementation:

- Preferred: update all call sites in the same plan and remove the old parameter.
- Transitional: add a named `calculateLegacySameCurrency` only for tests if needed, then remove before completion.

### Decision 3: Convert To Lightweight Internal Rows

Inside the calculator, build internal converted rows:

```text
expense + convertedAmount + sourceCurrency + wasConverted
```

Buckets, category totals, top category, total, and previous total should all aggregate `convertedAmount`.

### Decision 4: Track Converted And Unconverted Currencies Separately

Extend `ExpenseReport` with optional metadata:

- `convertedCurrencies: List<String>`
- `unconvertedCurrencies: List<String>`

Keep `ignoredCurrencyCount` for existing UI compatibility. Reports can show converted notes and missing-rate warnings without guessing.

## Implementation Strategy

1. Add failing tests first for the screenshot scenario in `report_calculator_test.dart`.
2. Refactor `ReportCalculator` to convert expenses through `MoneyConversionService`.
3. Extend `ExpenseReport` metadata and update constructor call sites.
4. Update `ReportCubit` to hold `UserSettings`, not just a currency string.
5. Update `ReportsScreen`/`StatScreen` to read settings from `SettingsRepository` or accept settings from the existing parent state if available.
6. Update AI summary/advice and weekly digest call sites to pass settings.
7. Update UI copy so successfully converted currencies do not appear as ignored.
8. Run targeted tests, analyze, and build only if requested after implementation.

## Risks

- AI and weekly digest may not currently have settings available in every call path. If a path only has a currency string, it must be upgraded to receive settings from the same app state/provider used by Home.
- Extending `ExpenseReport` touches several tests and widgets. Defaults should keep manually constructed test fixtures simple.
- Current rates are daily cached rates, not historical transaction-date rates. This is acceptable for this plan and already matches the current Home behavior.

## Deferred Items Considered

Relevant deferred items already exist for daily exchange-rate provider selection, historical rates, offline freshness indicators, and broader category-budget/subscription conversion. This plan intentionally fixes Reports/statistics only; category budgets and subscription center can be addressed in a later Spec Kit plan if needed.

