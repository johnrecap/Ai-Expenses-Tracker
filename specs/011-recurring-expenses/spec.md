# Feature Specification: Recurring Expenses

**Feature Branch**: `011-recurring-expenses`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Creates Recurring Expense (P1)
As a user, I create daily, weekly, or monthly expenses for rent, internet, subscriptions, or transport.

**Acceptance Criteria**
- Recurring expense stores frequency and next run date.
- Recurring expense can be paused/archived.

### User Story 2 - Due Expenses Are Generated (P1)
As a user, due recurring expenses appear as normal expenses.

**Acceptance Criteria**
- Due occurrences are materialized when app opens.
- Duplicate generation is prevented.

## Functional Requirements

- Add recurring expense model and repository.
- Add scheduler service.
- Add Recurring Expenses screen.
- Generate expenses with `source = recurring`.

## Out Of Scope

- Guaranteed server-side scheduled generation.
- Complex custom recurrence rules.

## Success Metrics

- Daily, weekly, monthly next-run calculations have tests.
- Generated expenses appear in reports and budget.

## Detailed Requirements And Edge Cases

- Client-side generation only runs when the app opens; guaranteed background generation is out of scope.
- Duplicate generated expenses must be prevented with deterministic ids or transactions.
- Monthly recurrence must handle months with fewer days.
- Generated expenses must set `source = recurring`.
- Pausing/archive must stop future generation without deleting generated expenses.
