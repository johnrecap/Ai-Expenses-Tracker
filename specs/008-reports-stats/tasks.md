# Tasks: Weekly And Monthly Reports

## Implementation Intent

Replace the static stats chart with real calculations built from user expenses. All calculations must be pure Dart services first, then rendered in UI.

---

## Phase 1: Report Model

### T001 - Create `ReportRange`

**Files:** Create or include in `packages/expense_repository/lib/src/models/expense_report.dart`.

**Steps:** Define `weekly`, `monthly`, `custom`; include start/end dates if needed.

**Done When:** UI can request a report period explicitly.

### T002 - Create `ExpenseReport`

**Steps:** Include total, currency, buckets by day/week, category totals, top category, previous period total, delta percent.

**Done When:** One object powers Stats screen.

### T003 - Define Bucket Structures

**Steps:** Add lightweight classes/maps for period bucket label, start date, end date, total.

**Done When:** Charts can render without recalculating.

---

## Phase 2: Report Calculator

### T004 - Create `ReportCalculator`

**Files:** Create `lib/services/report_calculator.dart`.

**Steps:** Accept expenses, range, and currency; return `ExpenseReport`.

**Done When:** Reports are testable without widgets.

### T005 - Implement Weekly Grouping

**Steps:** Group expenses by day for selected week; include zero-total days.

**Done When:** Weekly chart has consistent 7-day buckets.

### T006 - Implement Monthly Grouping

**Steps:** Group expenses by day or week for month; include empty buckets if chart needs them.

**Done When:** Monthly chart reflects current month.

### T007 - Implement Top Category

**Steps:** Sum by category id/snapshot; choose highest total; tie-break by name for stable output.

**Done When:** Top category card is deterministic.

### T008 - Implement Previous Period Comparison

**Steps:** Calculate previous week/month total and delta percent; handle previous total zero safely.

**Done When:** No division-by-zero crash.

---

## Phase 3: UI

### T009 - Create `ReportCubit`

**Files:** Create `lib/screens/reports/cubit/report_cubit.dart` and state.

**Steps:** Load expenses, select range, emit loading/loaded/empty/failure.

**Done When:** Stats screen state is not hardcoded.

### T010 - Replace Static Chart Data

**Files:** Modify or replace `lib/screens/stats/chart.dart`.

**Steps:** Accept bucket data from report; remove unconditional `.redacted(redact: true)`.

**Done When:** Chart uses real totals.

### T011 - Add Weekly/Monthly Switch

**Files:** Modify stats/reports screen.

**Steps:** Add segmented control or tabs for week/month; update cubit range.

**Done When:** User can switch report period.

### T012 - Add Category Breakdown Chart

**Files:** Create `lib/screens/reports/widgets/category_breakdown_chart.dart`.

**Steps:** Use `fl_chart` pie/bar chart; show category colors from snapshots.

**Done When:** User sees top spending categories.

### T013 - Add Month Comparison Card

**Files:** Create `lib/screens/reports/widgets/month_comparison_card.dart`.

**Steps:** Show current total, previous total, and up/down percent.

**Done When:** Monthly comparison is visible.

---

## Phase 4: Tests

### T014 - Grouping Tests

Test weekly and monthly bucket totals.

### T015 - Top Category Tests

Test top category and tie behavior.

### T016 - Delta Tests

Test previous period zero and non-zero delta.

---

## Completion Checklist

- [x] T001 - Created `ReportRange` with weekly, monthly, and custom ranges.
- [x] T002 - Created `ExpenseReport` with total, currency, buckets, category totals, top category, previous total, delta percent, and ignored-currency count.
- [x] T003 - Added `ReportBucket` and `CategoryReportTotal` structures.
- [x] T004 - Created pure `ReportCalculator`.
- [x] T005 - Implemented weekly grouping with seven day buckets and zero-total days.
- [x] T006 - Implemented monthly grouping into consistent week buckets.
- [x] T007 - Implemented deterministic top category calculation with name tie-break.
- [x] T008 - Implemented previous period comparison and safe zero-previous delta behavior.
- [x] T009 - Created `ReportCubit` and states for loading weekly/monthly report data from expenses.
- [x] T010 - Replaced static redacted chart with real bucket-driven chart widget.
- [x] T011 - Added weekly/monthly segmented switch.
- [x] T012 - Added category breakdown chart using `fl_chart`.
- [x] T013 - Added period comparison card.
- [x] T014 - Added weekly and monthly grouping tests.
- [x] T015 - Added top category and tie behavior tests.
- [x] T016 - Added delta tests for previous zero and non-zero totals.
