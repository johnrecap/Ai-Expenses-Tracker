# Feature Specification: First-Run Setup Onboarding

**Feature Branch**: `042-first-run-setup-onboarding`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: User request to avoid silent defaults and guide new users through essential first setup before relying on language, currency, payment, AI, and notification defaults.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete Essential Setup After Sign-In (Priority: P1)

A first-time signed-in user is guided through mandatory setup for language, base currency, and default payment method before reaching the main app.

**Why this priority**: The app must not assume currency, language, or payment method "because of circumstances." The user must make intentional choices before financial data is created.

**Independent Test**: Create a new account with no settings profile, sign in, and verify the setup flow appears before Home. Complete language, currency, and payment choices, then verify Home opens with those choices saved.

**Acceptance Scenarios**:

1. **Given** a new user has no completed setup state, **When** they sign in, **Then** they see first-run setup before Home.
2. **Given** a new user chooses Arabic, USD, and Wallet, **When** they finish setup, **Then** settings are saved and Home/Add Expense/AI use Arabic, USD, and Wallet defaults.
3. **Given** a user exits setup before completion, **When** they reopen the app, **Then** setup resumes instead of using silent defaults.

---

### User Story 2 - Explain AI Safety And Limits (Priority: P2)

During setup, the user gets a short explanation that AI prepares previews only, requires confirmation before saving, has daily free limits, and manual entry always works.

**Why this priority**: Users need to trust AI without thinking it can silently change financial data. The product also needs transparent free-plan quota expectations.

**Independent Test**: Complete setup and verify the AI explanation appears once, contains preview/confirmation/free-limit/manual fallback messaging, and does not consume AI quota.

**Acceptance Scenarios**:

1. **Given** a first-time user reaches the AI intro step, **When** they read it, **Then** they understand AI does not save without confirmation.
2. **Given** the user skips AI intro details, **When** setup completes, **Then** AI remains available but the guided tour can still show the AI spotlight later.
3. **Given** AI gateway is unavailable, **When** the user completes setup, **Then** setup still completes because it does not call the provider.

---

### User Story 3 - Offer Optional Reminder Setup (Priority: P3)

The user can optionally enable daily reminders and weekly digest during onboarding, but declining them does not block app usage.

**Why this priority**: Notifications support retention, but permissions should be optional and clear.

**Independent Test**: Complete setup with reminders disabled, then enabled, and verify settings reflect the user's choice without blocking Home if permissions are denied.

**Acceptance Scenarios**:

1. **Given** a user declines reminders, **When** setup finishes, **Then** Home opens and notification settings remain disabled.
2. **Given** a user enables reminders, **When** permissions are granted, **Then** notification settings save and scheduling is attempted.
3. **Given** a user enables reminders but permissions are denied, **When** setup finishes, **Then** Home still opens and settings show reminders disabled or permission-needed state.

### Edge Cases

- Existing users with a settings profile should not be forced through first-run setup unless mandatory fields are missing.
- If settings save fails, setup should keep the user's selections visible and offer retry.
- Setup should not call AI provider, ads, purchases, camera, or speech services.
- Setup must be accessible on small screens and in Arabic RTL.
- Partial completion should be stored safely only after validation, not as a completed setup.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST track setup completion per user.
- **FR-002**: System MUST require language preference, base currency, and default payment method before marking setup complete.
- **FR-003**: System MUST route users with incomplete setup to onboarding before Home.
- **FR-004**: System MUST persist setup choices through `SettingsRepository`.
- **FR-005**: System MUST resume setup if the user exits before completion.
- **FR-006**: System MUST explain AI preview/confirmation behavior without making AI provider calls.
- **FR-007**: System MUST explain free daily AI limits and manual fallback without promising unlimited AI.
- **FR-008**: System MUST make notifications optional and handle permission denial without blocking setup completion.
- **FR-009**: System MUST avoid hardcoded user-facing strings by using localization resources.
- **FR-010**: Tests MUST cover new-user routing, completion persistence, retry on save failure, and existing-user bypass.

### Key Entities

- **OnboardingProgress**: Tracks current step, selected values, completion flag, version, and timestamp.
- **OnboardingStep**: One of essentials, AI intro, reminders, done.
- **UserSettings**: Stores final preferences after onboarding.
- **NotificationSetupChoice**: Optional reminder preferences selected during setup.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of new users choose language, base currency, and default payment method before reaching Home.
- **SC-002**: Existing users with valid settings reach Home with no extra setup interruption.
- **SC-003**: Setup completion takes under 90 seconds for a typical user.
- **SC-004**: Setup can complete successfully without network calls to AI, ads, camera, speech, or purchases.
- **SC-005**: Automated tests cover both new-user setup and existing-user bypass.

## Assumptions

- This plan depends on Plan 041 language/currency preference fields.
- Setup completion is user-scoped and should follow the signed-in account.
- Notification permission prompts can be deferred until the user chooses to enable reminders.
- Premium, ads, and purchase setup remain out of scope for first-run essentials.

