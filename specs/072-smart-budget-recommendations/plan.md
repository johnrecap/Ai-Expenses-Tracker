# Implementation Plan: Smart Budget Recommendations

**Branch**: `072-smart-budget-recommendations` | **Date**: 2026-05-20 | **Spec**: `specs/072-smart-budget-recommendations/spec.md`

## Summary

Add deterministic budget recommendations from recent spending history. Recommendations should explain the calculation, flag caveats, and open existing budget forms with editable values rather than saving automatically.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Budget repositories, category budgets, report/calculation services, settings  
**Storage**: Existing budget/category budget documents only after user confirms  
**Testing**: Recommendation service tests, budget/cubit/widget tests  
**Target Platform**: Flutter mobile  
**Project Type**: Finance insight and budget UX  
**Performance Goals**: Local recommendation from loaded history without network calls  
**Constraints**: No automatic budget save; must handle missing rates honestly  
**Scale/Scope**: Last 2-3 months of user expenses

## Constitution Check

- Budget progress from expenses, not counters: PASS.
- Shared conversion policy for mixed currencies: PASS.
- User confirmation before save: PASS.
- Local deterministic service first: PASS.

## Project Structure

```text
lib/screens/budget/
lib/screens/category_budgets/
lib/services/finance/
lib/services/report_calculator.dart
packages/expense_repository/
test/budget/
test/category_budgets/
test/services/
```

## Implementation Strategy

1. Add recommendation service and data models.
2. Build tests for spending patterns.
3. Add UI entry points from Monthly Budget and Category Budgets.
4. Open existing budget forms with suggested editable values.
5. Localize explanations and caveats.

## Risks

- Recommendations can feel judgmental. Mitigation: use neutral, editable suggestions.
- Sparse data can mislead. Mitigation: confidence labels and caveats.

## Deferred Items Considered

AI can later summarize or phrase recommendations, but this plan keeps calculation local to avoid quota and hallucination risk.

