# Implementation Plan: Report Drilldowns And Monthly Story

**Branch**: `070-report-drilldowns-monthly-story` | **Date**: 2026-05-20 | **Spec**: `specs/070-report-drilldowns-monthly-story/spec.md`

## Summary

Make reports actionable by linking report buckets/categories to filtered expense lists and adding a deterministic monthly story summary. AI wording can be layered later, but the first version should use local report data.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `ReportCubit`, `ReportCalculator`, `ExpenseFilter`, Expenses screen, l10n  
**Storage**: No new storage  
**Testing**: Report drilldown model tests, Expenses navigation/widget tests, story service tests  
**Target Platform**: Flutter mobile  
**Project Type**: Report UX improvement  
**Performance Goals**: Drilldown navigation should be immediate from loaded data/filter state  
**Constraints**: Report totals must remain from shared calculation service  
**Scale/Scope**: One selected report period

## Constitution Check

- Reports calculated outside widgets: PASS.
- Filters reuse `ExpenseFilterService` semantics: PASS.
- New app-owned strings use ARB: PASS.

## Project Structure

```text
lib/screens/reports/
lib/screens/expenses/
lib/services/report_calculator.dart
lib/services/expense_filter_service.dart
lib/l10n/
test/reports/
test/expenses/
```

## Implementation Strategy

1. Add drilldown target model from report data.
2. Wire chart/category taps to Expenses screen filters.
3. Add monthly story service using current and previous reports.
4. Localize story and empty/caveat states.
5. Test navigation and calculations.

## Risks

- Drilldown filters may not match chart bucket boundaries. Mitigation: share date boundary helpers.
- Story can overstate causality. Mitigation: use conservative deterministic language.

## Deferred Items Considered

Related future work: AI History Assistant may reuse monthly story facts for natural-language answers.

