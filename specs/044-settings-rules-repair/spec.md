# Feature Specification: Settings Rules Repair

**Feature Branch**: `044-settings-rules-repair`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Review finding that Firestore `validSettings` rejects the current `UserSettingsEntity.toDocument()` shape and rules tests still use the old settings schema.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Save Current Settings Shape (Priority: P1)

Authenticated users must be able to create and update their profile settings after onboarding, language selection, and guided tour progress without Firestore rules rejecting valid app-owned fields.

**Why this priority**: Settings persistence is a blocker for first-run setup, language preference, and guided tour completion.

**Independent Test**: A rules emulator test can create `users/user-a/settings/profile` with the same fields written by `UserSettingsEntity.toDocument()` and verify the write succeeds for the owner and fails for non-owners.

**Acceptance Scenarios**:

1. **Given** an authenticated owner and a valid current settings document, **When** the app writes `settings/profile`, **Then** Firestore rules allow the write.
2. **Given** a non-owner or unauthenticated user, **When** they read or write another user's settings profile, **Then** Firestore rules deny the operation.

---

### User Story 2 - Reject Malformed Settings Fields (Priority: P1)

The backend rules must reject malformed settings data, including invalid language values, negative onboarding/tour versions, invalid payment methods, invalid notification times, oversized lists, or wrong document id.

**Why this priority**: Expanding the allowed schema without validation would weaken user-owned data guarantees.

**Independent Test**: Mutating one invalid field at a time in rules tests must fail.

**Acceptance Scenarios**:

1. **Given** a settings document with `languagePreference` set to an unsupported value, **When** it is written, **Then** rules deny it.
2. **Given** a settings document with negative onboarding or guided tour versions, **When** it is written, **Then** rules deny it.
3. **Given** a settings document written to an id other than `profile`, **When** it is created, **Then** rules deny it.

---

### User Story 3 - Make Rules Verification Part Of The Baseline (Priority: P2)

Developers must have an obvious command that runs application unit tests and Firestore rules tests when rules or schema work changes.

**Why this priority**: The stale rules test allowed a production-breaking mismatch to survive.

**Independent Test**: Running the documented rules command executes `functions/test/firestoreRules.rules.ts`; the app test command remains available separately.

**Acceptance Scenarios**:

1. **Given** a developer changes `firestore.rules`, **When** they check the scripts, **Then** there is a clear rules-specific command and documentation for running it.
2. **Given** rules tests fail because the emulator is unavailable, **When** verification is reported, **Then** the failure is explicit and not hidden behind `npm test`.

## Edge Cases

- Existing settings documents may omit new fields; reads must remain safe because app entity parsing already supplies defaults.
- `guidedTourLastStepId` may be `null` after completion and a string after skip.
- `supportedCurrencies` must remain non-empty, bounded, and contain valid ISO-like currency codes.
- `updatedAt` must remain a Firestore timestamp.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The settings rules must allow all fields emitted by `UserSettingsEntity.toDocument()`.
- **FR-002**: The settings rules must allow only the `profile` settings document id.
- **FR-003**: The settings rules must require `userId` to match the authenticated path owner.
- **FR-004**: The settings rules must validate `languagePreference` as `system`, `en`, or `ar`.
- **FR-005**: The settings rules must validate onboarding and guided tour version fields as non-negative integers.
- **FR-006**: The settings rules must allow `guidedTourLastStepId` as either `null` or a bounded string.
- **FR-007**: The rules tests must include a valid current settings fixture matching the repository entity output.
- **FR-008**: The rules tests must include deny cases for invalid language, negative versions, bad notification times, cross-user access, and wrong settings document id.
- **FR-009**: The project must document or script the rules test command so it is not confused with `functions` unit tests only.

### Key Entities

- **User Settings Profile**: User-owned settings document stored at `users/{userId}/settings/profile`.
- **Guided Tour Progress**: Versioned completion, skip, and last-step fields stored inside settings profile.
- **Language Preference**: Explicit app language selection independent from currency.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A current app settings document is accepted by Firestore rules in emulator tests.
- **SC-002**: At least five malformed settings variants are denied in emulator tests.
- **SC-003**: Cross-user and unauthenticated settings access remains denied.
- **SC-004**: Verification instructions distinguish `functions` unit tests from Firestore rules tests.

## Assumptions

- Settings writes are performed only through `SettingsRepository`.
- The app will keep backward-compatible parsing for older settings documents.
- This plan does not deploy rules to production; deployment and real-user smoke tests remain deferred production setup work.
