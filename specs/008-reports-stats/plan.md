# Implementation Plan: Weekly And Monthly Reports

## Technical Context

Current stats screen uses static redacted chart data. Reports need real expense aggregation.

## Architecture

Add pure report calculator and report Cubit. Keep `fl_chart` for rendering.

## Files

- Create: `packages/expense_repository/lib/src/models/expense_report.dart`
- Create: `lib/services/report_calculator.dart`
- Create: `lib/screens/reports/cubit/report_cubit.dart`
- Create: `lib/screens/reports/cubit/report_state.dart`
- Create: `lib/screens/reports/views/reports_screen.dart`
- Create: `lib/screens/reports/widgets/spending_bar_chart.dart`
- Create: `lib/screens/reports/widgets/category_breakdown_chart.dart`
- Create: `lib/screens/reports/widgets/month_comparison_card.dart`
- Modify: `lib/screens/stats/stats.dart`
- Modify: `lib/screens/stats/chart.dart`

## Data Model

`ExpenseReport`: totals, category breakdown, period buckets, top category, previous-period comparison.

## Risks

- Date boundaries must be consistent.
- Multi-currency reports should avoid invalid totals.

## Verification

- Unit tests for weekly/monthly grouping.
- Unit tests for top category and delta.
- Manual chart verification.

## Detailed Execution Guidance

- Replace static chart data only after report calculator tests pass.
- Keep charts as dumb widgets that receive prepared bucket data.
- Handle empty periods with empty states, not fake data.
- Use selected/base currency consistently.
- Keep report calculations separate from AI advice so both can reuse the same totals.
