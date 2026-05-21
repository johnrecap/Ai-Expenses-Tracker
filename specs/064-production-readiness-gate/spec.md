# Feature Specification: Production Readiness Gate

**Feature Branch**: `064-production-readiness-gate`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested a Spec Kit plan for closing production trust blockers before adding more features.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Internal Build Can Be Trusted (Priority: P1)

As the app owner, I need one repeatable internal-release checklist that proves login, Firestore writes, AI gateway, ads configuration, export, app lock, notifications, and account deletion are safe to test on a clean device.

**Why this priority**: A financial app can pass local tests but fail in production because Firebase providers, rules, signing, AI URL, or AdMob IDs are misconfigured.

**Independent Test**: A tester follows the checklist on a signed internal APK/AAB and records pass/fail evidence for every critical journey.

**Acceptance Scenarios**:

1. **Given** a signed internal build, **When** the tester opens the checklist, **Then** every required environment value and test account is listed before testing starts.
2. **Given** a missing production value such as `AI_GATEWAY_URL` or AdMob ID, **When** the checklist is run, **Then** the release is blocked with a visible reason.

---

### User Story 2 - Firebase And Auth Smoke Pass (Priority: P1)

As a tester, I need to validate real Firebase Auth and Firestore rules with a real user so permission errors do not appear after release.

**Why this priority**: Google Sign-In SHA/provider setup and Firestore rules are external to local unit tests.

**Independent Test**: Google and email/password users sign in and perform the core write/read flows without permission-denied errors.

**Acceptance Scenarios**:

1. **Given** production-like Firebase config, **When** a Google user signs in, **Then** Home loads user-owned settings and expenses.
2. **Given** production-like Firestore rules, **When** the tester creates/edits/deletes an expense, **Then** only the authenticated user's data changes.

---

### User Story 3 - Release Config Is Safe (Priority: P2)

As the app owner, I need release checks that prevent test ad IDs, mock-only AI, or unsigned/debug artifacts from being mistaken for production.

**Why this priority**: Mislabelled builds damage trust and can violate store/ad policies.

**Independent Test**: A pre-release checklist blocks any artifact missing required production configuration.

**Acceptance Scenarios**:

1. **Given** a build with test AdMob IDs, **When** production readiness is checked, **Then** the release is blocked unless ads are intentionally disabled.
2. **Given** a build without real AI gateway URL, **When** AI readiness is checked, **Then** it is marked internal-only.

## Edge Cases

- Network unavailable during smoke test.
- Google provider enabled but SHA fingerprints missing.
- Firestore rules deployed but indexes missing.
- Ads intentionally disabled for first release.
- AI gateway down but manual tracking still works.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a single internal-release checklist covering Firebase, Auth, Firestore, AI gateway, AdMob, export, app lock, notifications, and account deletion.
- **FR-002**: Checklist MUST distinguish local/unit verification from real-device production smoke testing.
- **FR-003**: Checklist MUST block public release if `AI_GATEWAY_URL` is missing and AI is expected to work.
- **FR-004**: Checklist MUST block public release if test AdMob IDs are present unless ads are intentionally disabled.
- **FR-005**: Checklist MUST require Google Sign-In validation on the final package name and signing fingerprints.
- **FR-006**: Checklist MUST require Firestore rules/index deployment and real-user smoke evidence.
- **FR-007**: Checklist MUST keep manual expense tracking available even if AI, ads, or notifications fail.

### Key Entities

- **ReleaseReadinessItem**: A checklist item with owner, environment, evidence, pass/fail state, blocker flag, and notes.
- **SmokeTestResult**: A recorded result for a real-device journey.
- **ReleaseBlocker**: A production condition that prevents public release.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of P0 release checks have recorded pass/fail evidence before public release.
- **SC-002**: A tester can complete the internal-release smoke checklist in under 60 minutes.
- **SC-003**: No production artifact is approved while using mock-only AI or unintended test ad IDs.
- **SC-004**: Core finance flows pass on at least one clean Android device before release.

## Assumptions

- First production target is Android internal testing.
- Production secrets and keystores remain outside source control.
- Ads may be disabled for an early public release if production AdMob is not ready.

