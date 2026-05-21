# Feature Specification: Saving Goals

**Feature Branch**: `014-saving-goals`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Creates Saving Goal (P1)
As a user, I set a saving target and deadline.

**Acceptance Criteria**
- Goal has name, target amount, current amount, currency, and optional deadline.
- Goal is user-scoped.

### User Story 2 - User Tracks Progress (P1)
As a user, I see progress percentage and remaining amount.

**Acceptance Criteria**
- Progress updates after manual contribution.
- Archived goals disappear from active list.

## Functional Requirements

- Add saving goal model and repository.
- Add Saving Goals screen.
- Add create/edit form.
- Add progress cards.

## Out Of Scope

- Automatic bank syncing.
- Investment tracking.

## Success Metrics

- Progress calculation tests pass.
- Create/update/archive flows are covered.

## Detailed Requirements And Edge Cases

- Saving goals are user-scoped.
- Target amount must be positive.
- Current amount cannot be negative.
- Progress may exceed 100 percent and should render cleanly.
- Archive hides goals from the active list but does not delete history.
