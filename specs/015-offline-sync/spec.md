# Feature Specification: Offline Mode And Sync Feedback

**Feature Branch**: `015-offline-sync`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Adds Expense Offline (P1)
As a user, I can add an expense without internet and it syncs later.

**Acceptance Criteria**
- Offline write is accepted where Firestore supports persistence.
- Pending sync state is visible.

### User Story 2 - User Understands Connectivity State (P2)
As a user, I see whether changes are pending or synced.

**Acceptance Criteria**
- Offline banner appears when needed.
- Pending expense indicator disappears after sync.

## Functional Requirements

- Confirm Firestore offline persistence per platform.
- Add sync status UI.
- Use snapshot metadata for pending writes where possible.
- Add connectivity service only if needed.

## Out Of Scope

- Full custom local database.
- Complex conflict resolution.

## Success Metrics

- Offline write behavior is documented and manually verified.
- Sync state mapping has tests where possible.

## Detailed Requirements And Edge Cases

- Firestore persistence is preferred over a custom local database.
- Offline behavior must be documented per platform.
- Pending writes should be visible when metadata allows it.
- Reconnect must not create duplicate expenses.
- Conflict policy for first version is last-write-wins unless a later spec changes it.
