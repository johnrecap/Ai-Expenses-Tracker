# Feature Specification: Weekly And Monthly Reports

**Feature Branch**: `008-reports-stats`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Views Weekly Summary (P1)
As a user, I see my weekly spending total and daily breakdown.

**Acceptance Criteria**
- Weekly chart uses real expenses.
- Empty week shows an empty state.

### User Story 2 - User Views Monthly Summary (P1)
As a user, I see monthly total, top categories, and month comparison.

**Acceptance Criteria**
- Monthly chart uses real expenses.
- Top category is calculated.
- Month-over-month delta is visible.

## Functional Requirements

- Add report models.
- Add report calculator.
- Replace static chart data.
- Add report Cubit.
- Add weekly/monthly toggle.

## Out Of Scope

- Exporting reports.
- AI-generated advice.

## Success Metrics

- Report calculations have unit tests.
- Stats screen no longer shows static redacted data.

## Detailed Requirements And Edge Cases

- Reports must ignore or separately show currencies that do not match the selected/base currency.
- Weekly reports must produce seven buckets even when some days have no spending.
- Month comparison must handle previous total of zero without division errors.
- Top category selection must be deterministic when totals tie.
- `fl_chart` remains the charting library unless a later spec changes it.
