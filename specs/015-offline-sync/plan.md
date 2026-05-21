# Implementation Plan: Offline Mode And Sync Feedback

## Technical Context

Firestore supports offline behavior on supported platforms, but UI needs sync feedback.

## Architecture

Use Firestore persistence and metadata first. Do not add a connectivity service
for the initial release; pending-write metadata is enough for sync feedback.

## Files

- Create: `packages/expense_repository/lib/src/models/sync_status.dart`
- Create: `lib/widgets/sync_status_banner.dart`
- Modify: `packages/expense_repository/lib/src/models/expense.dart`
- Modify: `lib/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart`
- Modify: `lib/screens/home/views/home_screen.dart`
- Modify: `lib/screens/home/views/main_screen.dart`
- Modify: `lib/screens/expenses/views/expenses_screen.dart`
- Modify: `packages/expense_repository/lib/src/firebase_expense_repo.dart`

## Data Model

Optional `syncStatus`: pending, synced, failed.

## Risks

- Web and mobile persistence behavior differs.
- Conflict policy should remain simple: last write wins.

## Verification

- Manual offline add and reconnect test.
- Unit tests for sync state mapping if metadata is abstracted.

## Detailed Execution Guidance

- Research Firestore platform behavior before coding UI.
- Prefer Firestore metadata over a custom sync table.
- Do not add `connectivity_plus` unless a later task requires reachability
  separate from sync metadata.
- Pending UI should be subtle but visible.
- Do not implement conflict merge UI unless a later spec requires it.
