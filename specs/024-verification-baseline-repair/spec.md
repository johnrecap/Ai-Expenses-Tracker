# Feature Specification: Verification Baseline Repair

**Feature Branch**: `024-verification-baseline-repair`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Code review found that `flutter analyze` passes but targeted `flutter test` can hang without output.

## User Scenarios & Testing

### User Story 1 - Tests Finish Predictably (Priority: P1)

A developer runs the project's test command and gets a pass/fail result without indefinite waiting.

**Why this priority**: Every later feature depends on a trusted verification baseline. If tests hang, workers cannot safely prove that their changes did not break the app.

**Independent Test**: Run `flutter test --reporter expanded` and confirm it finishes with a clear result.

**Acceptance Scenarios**:

1. **Given** a clean checkout with dependencies installed, **When** the developer runs `flutter test --reporter expanded`, **Then** the command finishes with either passing tests or actionable failures.
2. **Given** a single targeted test file, **When** the developer runs that file directly, **Then** the test output identifies the suite and does not stall silently.

---

### User Story 2 - Hanging Cause Is Isolated (Priority: P2)

A developer can identify whether the hang comes from Firebase initialization, Bloc stream lifecycle, timers, platform plugins, Worker tests, or widget setup.

**Why this priority**: Fixing symptoms without knowing the blocking source will create recurring verification failures.

**Independent Test**: Run the documented isolation commands from this plan and confirm each one narrows the failure surface.

**Acceptance Scenarios**:

1. **Given** a hanging test run, **When** isolation commands are executed in order, **Then** the first blocking suite or setup path is identified.
2. **Given** a plugin-dependent test, **When** the test uses mocks or fakes, **Then** it completes without relying on real platform channels.

---

### User Story 3 - Future Workers Have A Verification Guide (Priority: P3)

A future worker knows exactly which verification commands to run after app, Worker, and Firebase-related changes.

**Why this priority**: The project has Flutter, repository package, Cloudflare Worker, optional Firebase Functions, and platform builds; each change type needs the right validation.

**Independent Test**: Read the quick verification section and choose the correct command set for a proposed change.

**Acceptance Scenarios**:

1. **Given** a Flutter-only UI change, **When** a worker checks the guide, **Then** they run Flutter analysis and tests only.
2. **Given** a Cloudflare Worker AI change, **When** a worker checks the guide, **Then** they run Worker typecheck/tests and avoid Firebase Functions unless touched.

### Edge Cases

- Tests may require Firebase mocks because production Firebase cannot be reached from normal unit tests.
- Tests using notifications, local auth, speech, image picker, ads, or Firestore must use fakes/mocks.
- A timeout caused by one suite must not hide failures in unrelated suites.

## Requirements

### Functional Requirements

- **FR-001**: The project MUST have a documented default Flutter verification command that completes predictably.
- **FR-002**: The test suite MUST avoid real network, Firebase, platform plugin, speech, auth, notification, ad, or local biometric calls in unit/widget tests.
- **FR-003**: Any long-running asynchronous code in tests MUST be closed, canceled, or awaited.
- **FR-004**: Tests that need Firebase or repositories MUST use fake implementations or emulator-specific setup documented separately.
- **FR-005**: The verification guide MUST list separate commands for Flutter app, Cloudflare Worker, optional Firebase Functions, and Android release build.
- **FR-006**: The known verification baseline in the constitution MUST be updated after the hang is fixed.

### Key Entities

- **Verification Baseline**: The current known status of analyze, tests, Worker tests, and builds.
- **Blocking Suite**: A test file or setup path that prevents the test process from exiting.
- **Mocked Platform Service**: A test-safe replacement for platform plugins.

## Success Criteria

### Measurable Outcomes

- **SC-001**: `flutter test --reporter expanded` completes in under 3 minutes on the local project after dependencies are available.
- **SC-002**: At least one targeted command exists for each major change area: Flutter, Worker, optional Functions, and Android build.
- **SC-003**: Future feature plans can reference the baseline without adding custom verification discovery tasks.
- **SC-004**: No unit or widget test depends on live Firebase, real ad SDK calls, real speech recognition, or physical biometric prompts.

## Assumptions

- The existing Flutter toolchain remains under `C:\flutter\bin\flutter.bat` for local verification.
- Current app architecture remains Bloc/Cubit plus repositories.
- Cloudflare Worker verification stays under `workers/ai-gateway`.
- Firebase Functions remain optional future backend code and are tested only when changed.
