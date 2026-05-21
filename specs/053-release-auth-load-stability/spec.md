# Feature Specification: Release Auth Load Stability

**Feature Branch**: `053-release-auth-load-stability`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: User report: Google sign-in reaches Home but shows "Failed to load expenses / Please check your connection and try again" for both old and new accounts; first-run onboarding can remain on an infinite loading spinner after accepting notification reminders.

## User Scenarios & Testing

### User Story 1 - Authenticated Home Loads Without Deployed Composite Index (Priority: P1)

After signing in with Google, a user must reach a usable Home screen even when production Firestore indexes are not yet deployed for the newest paginated expense query.

**Why this priority**: The current release build blocks both old and new Google accounts at the Home expense-loading state.

**Independent Test**: Simulate the primary recent-expenses watch failing and verify the Home expenses state falls back to a successful page instead of showing the connection failure.

**Acceptance Scenarios**:

1. **Given** a signed-in user and a missing expense composite index, **When** Home subscribes to recent expenses, **Then** the app falls back to a conservative date-ordered read and shows a usable expense page.
2. **Given** a signed-in user with no expenses, **When** the primary recent-expenses query fails, **Then** Home still shows an empty successful expense state rather than a connection error.

---

### User Story 2 - Onboarding Reminder Setup Cannot Spin Forever (Priority: P2)

When a new user finishes first-run setup and accepts reminder notifications, notification permission or scheduling problems must not block onboarding completion indefinitely.

**Why this priority**: New users can become stuck before reaching the app after accepting reminders.

**Independent Test**: Simulate reminder scheduling that never completes and verify onboarding completes with reminders disabled warning.

**Acceptance Scenarios**:

1. **Given** a new user enables daily or weekly reminders, **When** notification scheduling hangs, **Then** setup completes and reminders are disabled with a non-blocking warning.
2. **Given** a new user skips reminders, **When** finishing setup, **Then** no notification scheduling is attempted and setup completes normally.

---

### User Story 3 - Production Setup Gap Remains Visible (Priority: P3)

The project must still track that Firestore rules and indexes need deployment, even though the app gains a runtime fallback.

**Why this priority**: Runtime fallback is a safety net, not a replacement for production Firebase setup.

**Independent Test**: Review deferred work and Spec Kit plan notes for the deployment blocker.

**Acceptance Scenarios**:

1. **Given** this runtime repair is implemented, **When** production readiness is reviewed, **Then** deploying Firestore rules/indexes remains listed as a blocker.

### Edge Cases

- The fallback must not write or migrate user data.
- If both the primary query and fallback query fail, the UI may still show the existing load failure.
- If reminder scheduling is denied, fails, or times out, onboarding should complete and persist disabled reminder settings.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST avoid blocking Home when the recent-expenses composite query fails because the production index is missing.
- **FR-002**: The app MUST preserve the existing newest-first ordering as closely as possible when using the fallback read.
- **FR-003**: The app MUST keep expense data user-scoped and read-only during fallback.
- **FR-004**: Onboarding reminder scheduling MUST have a bounded wait time.
- **FR-005**: Onboarding MUST complete after reminder scheduling failure, denial, or timeout.
- **FR-006**: The Firebase deployment blocker MUST remain documented for later production setup.

### Key Entities

- **ExpensePage**: A bounded page of ordered expenses used by Home and Expenses list views.
- **OnboardingState**: The first-run setup state that controls progress, saving status, completion, and non-blocking warnings.
- **NotificationSetupChoice**: The user's optional daily and weekly reminder selections during onboarding.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Google sign-in users reach a non-failure Home expense state when the composite index is missing.
- **SC-002**: Onboarding finish returns from notification scheduling hangs within 6 seconds.
- **SC-003**: Existing successful notification and skipped-reminder onboarding flows continue to pass.
- **SC-004**: The repair requires no production data migration.

## Assumptions

- The Firestore rules currently deployed in the user's Firebase project allow `users/{uid}/...` access for the signed-in user.
- The release failure is consistent with an undeployed composite index because `firestore.indexes.json` contains the required expense index but the deployed Firebase configuration shown by the user is older.
- Deploying Firestore rules and indexes remains necessary before public release.
