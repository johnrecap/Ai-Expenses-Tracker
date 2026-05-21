# Feature Specification: Stabilization And Baseline

**Feature Branch**: `001-stabilization-baseline`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - App Has A Reliable Test Baseline (P1)
As a developer, I need the default counter test replaced with a real app smoke test so future changes can be verified.

**Acceptance Criteria**
- `flutter test` no longer expects counter text.
- The test verifies the app can render the splash entry point.

### User Story 2 - Add Expense Does Not Crash On Bad Input (P1)
As a user, I need validation before saving an expense so the app does not crash on empty or invalid values.

**Acceptance Criteria**
- Empty amount cannot be submitted.
- Missing category cannot be submitted.
- Invalid numbers show a user-visible validation error.

### User Story 3 - Current UI Issues Are Removed (P2)
As a user, I need existing typos and obvious UI state gaps fixed before new features are added.

**Acceptance Criteria**
- Visible typos are corrected.
- Empty expense list has an empty state.
- Expense loading failure has a visible error state.

## Functional Requirements

- Replace the default widget test.
- Fix deprecated `Color.value` usage.
- Add validation in Add Expense.
- Allow past dates in the date picker.
- Dispose controllers where lifecycle allows.
- Avoid mutating Bloc state lists directly.

## Out Of Scope

- Authentication.
- Data model migration.
- New product features.

## Success Metrics

- `flutter analyze` is clean or only reports known unrelated issues.
- `flutter test` passes with meaningful app tests.

## Detailed Requirements And Edge Cases

- The worker must not add new features while doing stabilization. Any UI text changes must be typo/clarity fixes only.
- Validation must fail before constructing or dispatching `CreateExpense`.
- Empty state must not hide the floating action button.
- Failure state must include a retry path that dispatches the same load event.
- Date picker changes must support yesterday and older dates because the AI roadmap depends on natural date parsing.
