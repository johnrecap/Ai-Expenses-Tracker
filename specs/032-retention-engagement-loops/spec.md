# Feature Specification: Retention And Engagement Loops

**Feature Branch**: `032-retention-engagement-loops`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User asked what features would make users return often and interact with the app.

## User Scenarios & Testing

### User Story 1 - Daily Check-In Encourages Tracking (Priority: P1)

A user gets a gentle daily reminder/check-in to record missing expenses and keep a tracking streak.

**Why this priority**: Habit formation is the main reason users come back to expense trackers.

**Independent Test**: Enable daily check-in and confirm notification/settings/streak state update without blocking expense entry.

**Acceptance Scenarios**:

1. **Given** daily check-in is enabled, **When** the reminder time arrives, **Then** user receives a local reminder to review today's spending.
2. **Given** user records at least one expense today, **When** Home refreshes, **Then** the daily tracking streak updates.

---

### User Story 2 - Weekly Digest Gives Useful Feedback (Priority: P2)

A user receives or opens a weekly digest showing spending total, top category, change from previous week, and one local insight.

**Why this priority**: A digest gives a reason to reopen the app even if no new expense is being added.

**Independent Test**: Seed two weeks of expenses and verify digest values match local reports.

**Acceptance Scenarios**:

1. **Given** two weeks of expenses, **When** weekly digest is generated, **Then** it shows current week total and comparison to previous week.
2. **Given** no expenses exist, **When** digest opens, **Then** it shows an empty state and encourages starting tracking.

---

### User Story 3 - Spending Health Score Creates Progress (Priority: P3)

A user sees a simple score or status based on budget usage, category concentration, and tracking consistency.

**Why this priority**: A lightweight progress signal encourages repeated app visits without relying on AI API calls.

**Independent Test**: Use local fixtures for budget under/near/over limit and confirm score changes deterministically.

**Acceptance Scenarios**:

1. **Given** user is under budget and tracked expenses this week, **When** Home opens, **Then** score/status is positive.
2. **Given** user exceeded budget and has high restaurant spend, **When** Home opens, **Then** score/status highlights the risk with local advice.

### Edge Cases

- Notifications require permission and must fail gracefully if denied.
- Streak should not punish users who intentionally disable reminders.
- Health score must be explainable and not pretend to be financial advice from a certified advisor.

## Requirements

### Functional Requirements

- **FR-001**: App MUST offer an optional daily check-in reminder using existing notification services.
- **FR-002**: App MUST track daily expense logging streak locally/user-scoped.
- **FR-003**: App MUST generate a weekly digest from local expenses and reports without AI provider calls.
- **FR-004**: App MUST provide a simple explainable spending health score/status.
- **FR-005**: Engagement features MUST be disableable from Settings.
- **FR-006**: Notifications MUST respect permission state and not block app use when denied.
- **FR-007**: Any advice text generated locally MUST be short, factual, and based on visible data.

### Key Entities

- **CheckInPreference**: Enabled flag, reminder time, and quiet days if added.
- **TrackingStreak**: Consecutive days with at least one logged expense.
- **WeeklyDigest**: Week totals, top category, comparison, and local insight.
- **SpendingHealthScore**: Explainable score/status from budget usage, concentration, and consistency.

## Success Criteria

### Measurable Outcomes

- **SC-001**: User can enable or disable daily check-in in under 20 seconds.
- **SC-002**: Weekly digest values match report calculator output in tests.
- **SC-003**: Health score explanation names at least one data reason for the status.
- **SC-004**: Engagement features work without AI quota or provider availability.

## Assumptions

- Existing local notification foundation is available.
- Existing report calculators can supply weekly/monthly summaries.
- No backend beyond Firebase user data is required.
