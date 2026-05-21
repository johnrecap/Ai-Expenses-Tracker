# Feature Specification: Monthly Budget

**Feature Branch**: `006-monthly-budget`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Sets Monthly Budget (P1)
As a user, I set a budget for the current month so I can track spending.

**Acceptance Criteria**
- User can create/update current month budget.
- Budget is user-scoped.

### User Story 2 - User Sees Budget Progress (P1)
As a user, I see spent amount, remaining amount, and progress percent.

**Acceptance Criteria**
- Home shows a budget progress card.
- Near-limit and exceeded states are visible.

## Functional Requirements

- Add `Budget` model and repository.
- Add budget calculator service.
- Add budget Bloc.
- Add Budget screen and Home card.
- Calculate current month spending.

## Out Of Scope

- Category-specific budgets.
- Currency conversion between mixed-currency expenses.

## Success Metrics

- Budget threshold logic has unit tests.
- Budget UI updates when expenses change.

## Detailed Requirements And Edge Cases

- Budget is per user, per month, per currency.
- Budget document id should be deterministic, such as `2026-05`, to avoid duplicate budgets.
- Near-limit warning is calculated from `warningThresholdPercent`.
- Exceeded state must be separate from near-limit state.
- First version should only include expenses matching the budget currency.
