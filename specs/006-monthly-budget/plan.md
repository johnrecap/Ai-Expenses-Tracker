# Implementation Plan: Monthly Budget

## Technical Context

Budget depends on user-scoped expenses and stable currency fields.

## Architecture

Add budget repository and pure calculator service. UI uses Bloc state and renders progress on Home.

## Files

- Create: `packages/expense_repository/lib/src/models/budget.dart`
- Create: `packages/expense_repository/lib/src/entities/budget_entity.dart`
- Create: `packages/expense_repository/lib/src/budget_repo.dart`
- Create: `packages/expense_repository/lib/src/firebase_budget_repo.dart`
- Create: `lib/services/budget_calculator.dart`
- Create: `lib/screens/budget/blocs/budget_bloc/*`
- Create: `lib/screens/budget/views/budget_screen.dart`
- Create: `lib/screens/budget/widgets/budget_progress_card.dart`
- Modify: `lib/screens/home/views/main_screen.dart`

## Data Model

`Budget`: `budgetId`, `userId`, `month`, `year`, `amount`, `currency`, `warningThresholdPercent`, timestamps.

## Risks

- Mixed currencies need explicit behavior.
- Budget warning should not spam notifications until notification plan.

## Verification

- Budget calculator tests.
- Budget bloc tests.
- Manual budget create/update flow.

## Detailed Execution Guidance

- Make `BudgetCalculator` independent from Flutter and Firebase.
- Use deterministic budget document id per month to avoid duplicates.
- Keep notifications out of this feature; only show in-app warnings.
- Budget progress should update from expenses, not from a stored counter.
- Multi-currency handling should be explicit and conservative.
