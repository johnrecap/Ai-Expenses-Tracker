# Tasks: Reports Currency Conversion

**Input**: Design documents from `specs/063-reports-currency-conversion/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Reproduce And Lock The Bug

- [X] T001 Add a regression test for the screenshot scenario in `test/reports/report_calculator_test.dart`.
  - **Reason**: The current bug is visible and easy to regress.
  - **Benefit**: Proves Reports include `50 USD` when `USD` has a saved EGP rate.
  - **Expected**: Weekly total equals base EGP total plus converted USD, `ignoredCurrencyCount == 0`, and `convertedCurrencies` includes `USD`.

- [X] T002 Add a missing-rate report test.
  - **Reason**: We still must not add mixed currencies without a rate.
  - **Benefit**: Keeps the app financially conservative when rates are unavailable.
  - **Expected**: USD is ignored only when no valid USD rate exists.

- [X] T003 Add previous-period conversion coverage.
  - **Reason**: Period comparison currently filters previous period by same currency too.
  - **Benefit**: Delta percent becomes consistent with converted totals.
  - **Expected**: `previousTotal` and `deltaPercent` include converted previous expenses.

## Phase 2: Shared Report Conversion Core

- [X] T004 Change `ReportCalculator.calculate` to accept `UserSettings settings`.
  - **Reason**: A currency string cannot provide conversion rates.
  - **Benefit**: Reports can calculate in base currency with saved daily rates.
  - **Expected**: Report currency comes from `settings.baseCurrency`.

- [X] T005 Reuse `MoneyConversionService` inside `ReportCalculator`.
  - **Reason**: Home already has the correct conversion behavior.
  - **Benefit**: Avoids two different currency algorithms.
  - **Expected**: Base-currency expenses pass through, convertible expenses are multiplied by saved rate, and missing-rate expenses are excluded.

- [X] T006 Aggregate report totals from converted rows.
  - **Reason**: Buckets/categories/top category must not use raw source-currency amounts.
  - **Benefit**: Weekly bars, monthly buckets, top category, and total all agree.
  - **Expected**: `total`, `buckets`, `categoryTotals`, and `topCategory` use converted amounts.

- [X] T007 Convert previous-period totals with the same logic.
  - **Reason**: Comparison must be apples-to-apples in base currency.
  - **Benefit**: Period delta stops undercounting mixed-currency history.
  - **Expected**: `previousTotal` includes convertible mixed-currency expenses.

## Phase 3: Report Metadata And UI

- [X] T008 Extend `ExpenseReport` with converted/unconverted currency metadata.
  - **Reason**: UI needs to distinguish "converted USD" from "ignored USD".
  - **Benefit**: Users understand why totals changed without seeing false warnings.
  - **Expected**: `convertedCurrencies` and `unconvertedCurrencies` are available with safe defaults.

- [X] T009 Update Reports summary card copy.
  - **Reason**: The current warning says the USD expense is ignored even when it should be converted.
  - **Benefit**: Reports match Home trust signals.
  - **Expected**: Converted currencies are shown as included; ignored warning appears only for missing-rate currencies.

- [X] T010 Add/adjust ARB keys if Reports needs new converted-currency copy.
  - **Reason**: Reports is localized.
  - **Benefit**: English and Arabic remain consistent.
  - **Expected**: New copy exists in `app_en.arb` and `app_ar.arb`, followed by `flutter gen-l10n`.
  - **Implementation note**: No new ARB keys were needed; Reports now reuses the existing converted/unconverted currency status keys.

## Phase 4: Wiring Settings Into Report Call Sites

- [X] T011 Update `ReportCubit` to receive `UserSettings`.
  - **Reason**: The Cubit currently only has `_currency`.
  - **Benefit**: It can pass base currency and rates into `ReportCalculator`.
  - **Expected**: Weekly/monthly loads use current settings.

- [X] T012 Update `ReportsScreen` and `StatScreen` wiring.
  - **Reason**: Reports is currently created with expenses only.
  - **Benefit**: Reports receives the same settings source as Home.
  - **Expected**: Reports rebuilds or reloads when settings/rates become available.

- [X] T013 Update AI summary/advice report call sites.
  - **Reason**: AI summaries use `ReportCalculator` and would otherwise keep the bug.
  - **Benefit**: AI report totals match Reports and Home.
  - **Expected**: `AiAssistantCubit`, `AiAdviceService`, and `FinancialAdviceAiService` pass settings.

- [X] T014 Update weekly digest calculation.
  - **Reason**: Weekly digest uses `ReportCalculator`.
  - **Benefit**: Digest top category and totals match Reports.
  - **Expected**: Weekly digest accepts settings or a conversion context.

## Phase 5: Tests

- [X] T015 Update `test/reports/report_cubit_test.dart`.
  - **Reason**: Cubit constructor changes from currency to settings.
  - **Benefit**: Verifies weekly/monthly loads with settings.
  - **Expected**: Cubit emits converted report totals.

- [X] T016 Update AI summary/advice tests.
  - **Reason**: AI report call sites must be covered.
  - **Benefit**: Prevents AI totals diverging again.
  - **Expected**: AI summary/advice include convertible mixed-currency expenses.

- [X] T017 Update weekly digest tests or add one if missing.
  - **Reason**: Digest currently inherits ReportCalculator behavior.
  - **Benefit**: Weekly check-in remains consistent.
  - **Expected**: Digest top category and total are conversion-aware.

- [X] T018 Run targeted tests.
  - **Reason**: Changed finance/report logic touches several surfaces.
  - **Benefit**: Confirms the fix without waiting on unrelated full-suite work.
  - **Expected**: `test/reports`, relevant AI tests, weekly digest tests, and Home conversion tests pass.

## Phase 6: Verification And Handoff

- [X] T019 Run `flutter gen-l10n` if ARB keys changed.
  - **Reason**: New localization keys require generated getters.
  - **Benefit**: Catches malformed ARB early.
  - **Expected**: Generated localization succeeds.
  - **Implementation note**: Skipped because ARB files did not change; existing generated getters were reused.

- [X] T020 Run `flutter analyze --no-pub`.
  - **Reason**: Constructor/signature changes can leave stale call sites.
  - **Benefit**: Confirms static correctness.
  - **Expected**: No analyzer issues.

- [ ] T021 Run focused manual check on release/debug install if requested.
  - **Reason**: User reported the bug from a real APK.
  - **Benefit**: Confirms screenshot scenario is fixed in UI.
  - **Expected**: Home and Reports both include converted USD; no false ignored-currency warning.

- [X] T022 Update deferred backlog if any related mixed-currency surfaces remain intentionally out of scope.
  - **Reason**: Category budgets/subscriptions still have separate mixed-currency behavior.
  - **Benefit**: Keeps future follow-up explicit.
  - **Expected**: Deferred file has concise non-duplicate follow-up notes.

## Dependencies And Execution Order

- T001-T003 before refactor.
- T004-T007 are the core calculator change.
- T008-T010 update user-visible report metadata/copy.
- T011-T014 wire all call sites.
- T015-T018 validate behavior.
- T019-T022 close the plan.
