# Feature Specification: Sync Pending Reliability

**Feature Branch**: `086-sync-pending-reliability`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: User saw "expense is waiting to sync" and a Pending chip after saving an AI expense while the app appeared online. The app must either sync immediately or clearly explain the real blocker.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Online Saves Sync Without Lingering Pending (Priority: P1)

As a user online, I want a saved expense to sync quickly without staying Pending, so I know my data is safe.

**Why this priority**: Pending on a financial transaction creates fear that the expense may disappear.

**Independent Test**: Save an expense while authenticated and online against the VPS endpoint and verify it reaches synced state after the server acknowledgement.

**Acceptance Scenarios**:

1. **Given** the app has a valid Firebase token and VPS endpoint is reachable, **When** the user saves an expense, **Then** the app pushes it and removes Pending after acknowledgement.
2. **Given** the app receives a transient server error, **When** save completes locally, **Then** the UI explains retrying rather than showing a vague permanent Pending.
3. **Given** sync succeeds after retry, **When** the server acknowledges, **Then** banners and row chips update automatically.

---

### User Story 2 - Pending Has a Reason and Action (Priority: P1)

As a user, I want any pending state to say why it is pending and what I can do, so the app does not look broken.

**Why this priority**: Offline-first is acceptable only when status is transparent.

**Independent Test**: Simulate offline, auth expired, and server down states and verify each shows a distinct localized message and retry behavior.

**Acceptance Scenarios**:

1. **Given** the phone is offline, **When** a save is queued, **Then** the UI says it will sync when internet returns.
2. **Given** the token is expired, **When** sync fails, **Then** the app refreshes auth or asks the user to sign in again.
3. **Given** the server is down, **When** sync fails, **Then** the UI offers retry and does not claim data is synced.

---

### User Story 3 - Sync State Does Not Pollute Normal Finance UI (Priority: P2)

As a user, I want the main transaction list to stay clean when there is no real sync problem, so the app feels stable.

**Why this priority**: A noisy banner makes the app look unfinished.

**Independent Test**: Save an expense under normal network conditions and verify no persistent pending banner remains after successful sync.

**Acceptance Scenarios**:

1. **Given** sync completes within the normal window, **When** the user returns to Home, **Then** no warning banner remains.
2. **Given** sync is genuinely blocked, **When** the user opens Home, **Then** a concise localized status appears with retry.

### Edge Cases

- App closes immediately after local save: pending queue must survive and retry after next launch.
- Duplicate pending pushes: server must accept idempotent retry or reject safely.
- Multi-device: pull must eventually reflect server acknowledgement without duplicate rows.
- AI-created expenses must use the same sync state as manual expenses.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Online saves MUST trigger immediate sync push after local commit.
- **FR-002**: Pending state MUST include a reason category: offline, auth, server, validation, unknown, or queued.
- **FR-003**: UI MUST localize pending/syncing/synced/failed messages.
- **FR-004**: Successful server acknowledgement MUST clear row Pending state and banners.
- **FR-005**: Pending queue MUST survive app restart.
- **FR-006**: Retry MUST be safe and not duplicate accepted expenses.
- **FR-007**: The app MUST not hide a real sync failure by labeling it synced.
- **FR-008**: Sync diagnostics MUST avoid exposing auth tokens or sensitive expense text in logs.

### Key Entities

- **SyncQueueItem**: Local pending change awaiting server acknowledgement.
- **SyncStatusReason**: User-safe reason for pending/failed/syncing state.
- **SyncCoordinatorState**: Current status across queue, last attempt, last error, and next retry.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Online create/update/delete transitions from pending to synced in under 10 seconds in the happy-path device smoke test.
- **SC-002**: Offline, auth, and server failures show distinct localized user messages in tests.
- **SC-003**: Retrying the same pending expense does not create duplicates in server sync tests.
- **SC-004**: No persistent pending banner remains after a successful sync acknowledgement.

## Assumptions

- Offline-first behavior remains valid; the goal is to make pending rare, explainable, and retryable.
- VPS pilot mode remains behind `REPOSITORY_RUNTIME_MODE=vpsLocalFirst`.
