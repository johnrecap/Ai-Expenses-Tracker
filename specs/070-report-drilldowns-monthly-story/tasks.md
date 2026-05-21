# Tasks: Report Drilldowns And Monthly Story

**Input**: `specs/070-report-drilldowns-monthly-story/spec.md`, `plan.md`

## Phase 1: Drilldown Model

- [X] T001 Add `ReportDrilldownTarget` model under `lib/screens/reports/models/`.
  - **Why**: Taps need a typed filter payload.
  - **Benefit**: Keeps navigation independent from chart widget internals.
  - **Expected**: Target stores period, bucket/category, and expense filter data.

- [X] T002 Add tests for report bucket/category drilldown targets.
  - **Why**: Date boundaries are easy to get wrong.
  - **Benefit**: Prevents off-by-one report filters.
  - **Expected**: Targets match expected expense IDs in fixtures.

## Phase 2: Navigation

- [X] T003 [US1] Add tap handling to report chart buckets.
  - **Why**: Chart bars should lead to source transactions.
  - **Benefit**: Reports become actionable.
  - **Expected**: Tap opens Expenses screen with date filter applied.

- [X] T004 [US1] Add tap handling to category breakdown rows.
  - **Why**: Users need to inspect why a category is high.
  - **Benefit**: Faster investigation.
  - **Expected**: Tap opens Expenses screen with category and period filters.

- [X] T005 [US1] Update Expenses screen to accept initial filters from navigation.
  - **Why**: Drilldown requires prefilled filters.
  - **Benefit**: Reuses existing filtering UI.
  - **Expected**: User sees active filters and can clear them.

## Phase 3: Monthly Story

- [X] T006 Add `MonthlyFinancialStoryService` under `lib/screens/reports/services/`.
  - **Why**: Story logic should not live in widgets.
  - **Benefit**: Testable insight generation.
  - **Expected**: Service returns summary, drivers, outliers, comparison, and caveats.

- [X] T007 [US2] Render monthly story on Reports screen.
  - **Why**: Users need plain-language insight.
  - **Benefit**: Makes reports useful to non-technical users.
  - **Expected**: Story appears for monthly view with deterministic facts.

- [X] T008 [US2] Add missing-rate caveat to monthly story.
  - **Why**: Story must not imply excluded currencies were included.
  - **Benefit**: Preserves trust in mixed-currency reports.
  - **Expected**: Caveat appears when report has unconverted currencies.

## Phase 4: Localization And Verification

- [X] T009 Add ARB keys for drilldown labels, active filter source, story headings, drivers, outliers, and caveats.
  - **Why**: New report copy is app-owned.
  - **Benefit**: Arabic/English consistency.
  - **Expected**: Matching keys in `app_en.arb` and `app_ar.arb`.

- [X] T010 Run `flutter gen-l10n`.
  - **Why**: New keys need generated getters.
  - **Benefit**: Catches localization errors.
  - **Expected**: Generation succeeds.

- [X] T011 Add report/expenses widget tests for drilldown navigation.
  - **Why**: Navigation/filter integration is the main risk.
  - **Benefit**: Prevents broken taps.
  - **Expected**: Tap opens filtered Expenses screen.

- [X] T012 Add monthly story service tests.
  - **Why**: Story must match deterministic numbers.
  - **Benefit**: Avoids misleading summaries.
  - **Expected**: Increased, decreased, no-data, outlier, and missing-rate fixtures pass.

- [X] T013 Run `flutter analyze --no-pub`.
  - **Why**: New models/navigation paths can leave stale code.
  - **Benefit**: Static safety.
  - **Expected**: No analyzer issues.
