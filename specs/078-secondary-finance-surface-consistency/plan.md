# Implementation Plan: Secondary Finance Surface Consistency

**Branch**: `078-secondary-finance-surface-consistency` | **Date**: 2026-05-20 | **Spec**: `specs/078-secondary-finance-surface-consistency/spec.md`  
**Input**: Finance consistency gaps from review and open tasks in Plan 065/073.

## Summary

Audit and align secondary finance surfaces with the shared conversion contract already used by Home and Reports. Category Budgets, Subscription Center, Export summaries, AI evidence, and Weekly Digest must stop showing stale same-currency assumptions where conversion data exists.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `FinancialCalculationService`, `MoneyConversionService`, `UserSettings`, existing export services  
**Storage**: No new persistence; uses saved `UserSettings.conversionRates` and `exchangeRatesUpdatedAt`  
**Testing**: Unit tests for calculators/export services plus selected widget tests  
**Target Platform**: Flutter mobile app  
**Project Type**: Mobile app  
**Performance Goals**: In-memory O(n) over loaded expenses/rules; no network call during rendering/export  
**Constraints**: Do not fetch live rates inside calculators; do not silently add raw different-currency amounts; preserve original export data  
**Scale/Scope**: One authenticated user's loaded expenses and recurring rules

## Constitution Check

- Spec Kit artifacts live under `specs/078-secondary-finance-surface-consistency/`: PASS.
- Financial math must be deterministic and local from saved settings/rates: PASS.
- UI/service layers must not add different currencies without metadata: PASS.
- User-visible warnings must be localized: PASS.
- Historical transaction-date rates remain deferred: PASS.

## Project Structure

```text
lib/screens/category_budgets/services/category_budget_calculator.dart
lib/screens/category_budgets/views/category_budgets_screen.dart
lib/screens/subscriptions/services/subscription_summary_service.dart
lib/screens/subscriptions/views/subscription_center_screen.dart
lib/services/export/csv_exporter.dart
lib/services/export/excel_exporter.dart
lib/services/export/pdf_exporter.dart
lib/engagement/services/weekly_digest_calculator.dart
lib/ai/services/ai_advice_service.dart
lib/services/finance/
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
```

## Design Decisions

### Decision 1: Reuse the shared calculation contract

All expense-based totals should go through `FinancialCalculationService` when base-currency conversion is needed.

### Decision 2: Export remains auditable

Exports must never replace original amounts. Conversion metadata is additive: original amount/currency remains, converted amount/rate/rate timestamp may be added.

### Decision 3: Recurring subscriptions need a recurring-aware conversion path

Recurring rules are not `Expense` objects, so Subscription Center can either create lightweight money rows or use a helper that mirrors the shared conversion rules without pretending rules are saved expenses.

## Implementation Strategy

1. Add failing tests for category budget conversion and subscription monthly impact.
2. Update calculators to use shared conversion rules where applicable.
3. Update UI warnings to say converted/missing rates accurately.
4. Add export metadata without changing original transaction columns.
5. Update AI/digest evidence wording if it still says ignored when conversion exists.
6. Verify with targeted tests, l10n generation if new copy is added, and analyzer.

## Risks

- Category budgets with non-base budget currency need a conservative rule to avoid wrong direction conversion.
- Subscription recurring rules may lack some metadata present on expenses.
- Export column changes can affect user expectations; preserve old columns and add new columns at the end where possible.

## Deferred Items Considered

Historical rates, provider selection, refresh cadence controls, and exact minor-unit accounting remain in the persistent backlog. This plan makes current saved-rate behavior consistent; it does not solve historical accounting.

