# Implementation Plan: Saving Goals

## Technical Context

Saving goals are user-owned financial targets independent from expenses.

## Architecture

Add saving goal repository, Bloc, screen, form, and progress cards.

## Files

- Create: `packages/expense_repository/lib/src/models/saving_goal.dart`
- Create: `packages/expense_repository/lib/src/entities/saving_goal_entity.dart`
- Create: `packages/expense_repository/lib/src/saving_goal_repo.dart`
- Create: `packages/expense_repository/lib/src/firebase_saving_goal_repo.dart`
- Create: `lib/screens/saving_goals/blocs/saving_goal_bloc/*`
- Create: `lib/screens/saving_goals/views/saving_goals_screen.dart`
- Create: `lib/screens/saving_goals/widgets/saving_goal_card.dart`
- Create: `lib/screens/saving_goals/widgets/saving_goal_form.dart`

## Data Model

`SavingGoal`: name, targetAmount, currentAmount, currency, deadline, archived, timestamps.

## Risks

- Manual contributions need clear validation.
- Mixed-currency goals should use their own currency only.

## Verification

- Progress calculation tests.
- Bloc tests for create/update/archive.

## Detailed Execution Guidance

- Saving goals should not depend on expenses in the first version.
- Keep contribution manual and explicit.
- Store currency per goal.
- Use archive instead of hard delete.
- Progress calculation must handle over-target values gracefully.
