# Implementation Plan: Financial Calculation Engine

**Branch**: `065-financial-calculation-engine` | **Date**: 2026-05-20 | **Spec**: `specs/065-financial-calculation-engine/spec.md`

## Summary

Introduce a shared calculation contract, likely a `FinancialCalculationService` or `MoneyEngine`, that wraps the existing `MoneyConversionService` and returns explainable metadata for every visible money total. The first implementation should audit all finance surfaces and migrate the highest-risk ones before adding advanced historical-rate storage.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `expense_repository`, existing `UserSettings`, `MoneyConversionService`, reports/home/budget/export/AI services  
**Storage**: Existing settings conversion rates; optional future transaction-rate snapshot fields if approved  
**Testing**: Unit tests for calculation fixtures plus widget/cubit tests for affected surfaces  
**Target Platform**: Flutter mobile app  
**Project Type**: Mobile finance app  
**Performance Goals**: O(n) in-memory calculation over loaded user expenses; no network call during rendering  
**Constraints**: No hardcoded rates; no silent mixed-currency addition; no Firebase imports in calculation services  
**Scale/Scope**: One user's loaded/date-scoped expenses

## Constitution Check

- Money conversion uses saved settings rates: PASS.
- No incompatible currency summing: PASS.
- Widgets receive prepared report/calculation data: PASS.
- Missing rates remain visible: PASS.

## Project Structure

```text
lib/screens/home/services/money_conversion_service.dart
lib/services/report_calculator.dart
lib/screens/home/services/home_summary_calculator.dart
lib/screens/budget/
lib/screens/category_budgets/
lib/screens/subscriptions/
lib/services/export/
lib/ai/
lib/engagement/
packages/expense_repository/lib/src/models/
test/home/
test/reports/
test/budget/
test/category_budgets/
test/subscriptions/
test/export/
test/ai/
test/engagement/
```

## Implementation Strategy

1. Create audit tests that demonstrate expected totals across all surfaces.
2. Add shared money breakdown models without changing storage first.
3. Refactor Home/Reports/AI/digest to use the shared contract where they already support conversion.
4. Audit Category Budgets and Subscriptions and decide whether to convert now or label same-currency behavior.
5. Update export metadata/copy so exported totals match visible surfaces.
6. Document historical-rate policy.

## Risks

- Broad blast radius across finance features. Mitigation: migrate one surface at a time with fixture tests.
- Historical rates add storage complexity. Mitigation: defer snapshots unless product explicitly requires immutable old reports.

## Deferred Items Considered

Relevant deferred items already mention historical rates, offline freshness indicators, and deciding whether category budgets/subscription monthly impact should convert mixed currencies.

