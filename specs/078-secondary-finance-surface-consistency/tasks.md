# Tasks: Secondary Finance Surface Consistency

**Input**: `specs/078-secondary-finance-surface-consistency/spec.md`, `plan.md`  
**Goal**: Make secondary finance surfaces follow the same conversion and missing-rate behavior as Home and Reports.

## Phase 1: Tests First

- [X] T001 Add category budget conversion tests in `test/category_budgets/category_budget_calculator_test.dart`. **Why**: Current tests still assert mixed currencies are ignored. **Fixes**: Stale same-currency expectation. **Expected**: Valid USD rate is included in EGP category budget progress; missing rate is excluded with warning count.
- [X] T002 Add subscription monthly impact conversion tests in `test/subscriptions/subscription_summary_service_test.dart`. **Why**: Recurring obligations must not underestimate commitments. **Fixes**: Subscription totals grouped or ignored incorrectly. **Expected**: Valid rates are included or clearly grouped by conversion metadata.
- [X] T003 [P] Add export metadata tests in `test/export/expense_export_service_test.dart` or the existing export test file. **Why**: Exported finance data must be auditable. **Fixes**: Silent converted totals without rate context. **Expected**: Original and converted values are both present where summaries exist.
- [X] T004 [P] Add AI/digest evidence regression tests in `test/ai/ai_advice_service_test.dart` and `test/engagement/weekly_digest_calculator_test.dart`. **Why**: Text can still say "ignored" after totals convert. **Fixes**: Misleading user-facing evidence. **Expected**: Evidence matches converted/unconverted metadata.

## Phase 2: Category Budgets

- [X] T005 [US1] Update `lib/screens/category_budgets/services/category_budget_calculator.dart` to use `FinancialCalculationService` for base-currency budgets. **Why**: Category budget totals should match Home/Reports. **Fixes**: Convertible expenses being ignored. **Expected**: Spent, remaining, and percent used include converted expenses when rates exist.
- [X] T006 [US1] Update category budget warning copy in `lib/screens/category_budgets/views/category_budgets_screen.dart`. **Why**: Users need to know whether rates converted or were missing. **Fixes**: Generic mixed-currency warnings. **Expected**: UI shows precise converted/missing-rate status.
- [ ] T007 [US1] Add or update ARB keys in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` for category budget conversion caveats. **Why**: Warnings are user-visible. **Fixes**: Hardcoded or unclear copy. **Expected**: Arabic and English caveats are available.

## Phase 3: Subscription Center

- [X] T008 [US2] Update `lib/screens/subscriptions/services/subscription_summary_service.dart` to calculate recurring monthly impact with saved-rate metadata. **Why**: Monthly recurring impact should be comparable to base-currency budgets. **Fixes**: Under-counting mixed-currency subscriptions. **Expected**: Summary includes converted totals plus missing-rate currencies.
- [X] T009 [US2] Update `lib/screens/subscriptions/views/subscription_center_screen.dart` to display converted and unconverted subscription caveats. **Why**: UI must explain why a total is complete or incomplete. **Fixes**: Confusing grouped totals or old caveats. **Expected**: Users can trust the monthly impact number.
- [ ] T010 [US2] Add ARB keys for subscription conversion caveats in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`. **Why**: Subscription Center supports Arabic/English. **Fixes**: Hardcoded warning strings. **Expected**: Localized caveats.

## Phase 4: Export And Evidence

- [X] T011 [US3] Extend CSV export in `lib/services/export/csv_exporter.dart` to preserve original fields and append conversion metadata when settings are available. **Why**: Users may reconcile exports externally. **Fixes**: Ambiguous totals or missing rate context. **Expected**: CSV rows remain backward-friendly and auditable.
- [X] T012 [US3] Extend Excel export in `lib/services/export/excel_exporter.dart` with the same metadata columns. **Why**: Excel is likely used for analysis. **Fixes**: Loss of conversion context. **Expected**: Original and converted values are visible.
- [X] T013 [US3] Extend PDF export in `lib/services/export/pdf_exporter.dart` with concise conversion summary/warnings. **Why**: PDF is a human-readable report. **Fixes**: Readers cannot tell what was converted. **Expected**: PDF totals are explained without clutter.
- [X] T014 [US3] Update `lib/services/export/expense_export_service.dart` and export request models if settings must be passed into exporters. **Why**: Exporters need rates to calculate metadata. **Fixes**: No access to conversion settings. **Expected**: Export callers pass settings explicitly or receive conservative no-conversion output.
- [X] T015 [US2] Update AI advice and weekly digest evidence in `lib/ai/services/ai_advice_service.dart` and `lib/engagement/services/weekly_digest_calculator.dart`. **Why**: User-facing explanations should not contradict totals. **Fixes**: Stale ignored-currency wording. **Expected**: Evidence references converted and missing-rate currencies correctly.

## Phase 5: Verification

- [X] T016 Run `flutter gen-l10n` if ARB keys changed. **Why**: Required for generated getters. **Fixes**: Missing localization accessors. **Expected**: Generated localization files are updated.
- [X] T017 Run targeted tests: `flutter test --no-pub test/category_budgets test/subscriptions test/export test/ai/ai_advice_service_test.dart test/engagement/weekly_digest_calculator_test.dart --reporter expanded --concurrency=1 --timeout 45s`. **Why**: Confirms all finance surfaces agree. **Fixes**: Calculator/export regressions. **Expected**: Targeted tests pass.
- [X] T018 Run `flutter analyze --no-pub`. **Why**: Catch interface changes after export/settings updates. **Fixes**: Static errors. **Expected**: Analyzer reports no issues.

## Dependencies

Tests T001-T004 should be written before implementation. Category Budget work can run in parallel with Subscription Center and Export after shared assumptions are confirmed.

## MVP Scope

Finish Category Budgets and Subscription Center first; export metadata can follow as P2 if time is limited.

## Implementation Notes

- Parent integration pass ran `flutter gen-l10n`, targeted finance/export/localization tests, and `flutter analyze --no-pub`; all passed.
- No ARB files were changed. Category Budget and Subscription Center reused existing localized `convertedCurrenciesStatus` and `unconvertedCurrenciesStatus` strings, so T007/T010 remain unchecked as no new keys were necessary in this pass.
- Files changed: `lib/screens/category_budgets/services/category_budget_calculator.dart`, `lib/screens/category_budgets/views/category_budgets_screen.dart`, `lib/screens/subscriptions/services/subscription_summary_service.dart`, `lib/screens/subscriptions/views/subscription_center_screen.dart`, `lib/services/export/export_service.dart`, `lib/services/export/csv_exporter.dart`, `lib/services/export/excel_exporter.dart`, `lib/services/export/pdf_exporter.dart`, `lib/screens/export/views/export_screen.dart`, `lib/ai/services/ai_advice_service.dart`, `lib/engagement/models/weekly_digest.dart`, related tests under `test/category_budgets/`, `test/subscriptions/`, `test/export/`, `test/ai/`, and `test/engagement/`.
- Remaining risk: historical transaction-date rates remain deferred per the spec.
