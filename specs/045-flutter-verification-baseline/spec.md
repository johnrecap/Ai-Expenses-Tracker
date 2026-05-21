# Feature Specification: Flutter Verification Baseline

**Feature Branch**: `045-flutter-verification-baseline`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Review finding that Flutter tests and even `flutter --version` can hang locally after test runs spawn stuck `git.exe` processes.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Restore A Reliable Flutter Command Baseline (Priority: P1)

Developers must be able to run basic Flutter commands without indefinite hangs so code changes can be verified honestly.

**Why this priority**: No Flutter app work can be safely completed while the primary verification toolchain is unreliable.

**Independent Test**: `flutter --version`, `flutter pub get`, and `flutter analyze --no-pub` complete within bounded time on the local machine.

**Acceptance Scenarios**:

1. **Given** a clean terminal and no active Flutter commands, **When** `flutter --version` runs, **Then** it returns version output instead of hanging.
2. **Given** the app workspace, **When** `flutter analyze --no-pub` runs, **Then** it completes and reports analyzer results.

---

### User Story 2 - Rebuild The Flutter Test Baseline Incrementally (Priority: P1)

The project must identify whether failures are toolchain hangs, test leaks, or real app regressions by running tests in controlled batches.

**Why this priority**: A full-suite timeout alone does not show which test or environment state is responsible.

**Independent Test**: A documented sequence runs one smoke test, then targeted high-risk suites, then the full suite with `--concurrency=1` and timeout.

**Acceptance Scenarios**:

1. **Given** Flutter commands complete, **When** a single smoke test is run, **Then** it completes and produces a clear pass/fail.
2. **Given** targeted suites complete, **When** the full suite is run, **Then** any failure is tied to a named test file or timeout point.

---

### User Story 3 - Document Toolchain Recovery Steps (Priority: P2)

Developers must know how to identify and clear stale local Flutter locks or stuck Git child processes without guessing.

**Why this priority**: The observed hang involved stuck `git.exe` processes and stale Flutter cache locks.

**Independent Test**: The recovery document lists exact diagnostic commands, safe cleanup boundaries, and when escalation/manual intervention is required.

**Acceptance Scenarios**:

1. **Given** Flutter hangs, **When** a developer follows the recovery document, **Then** they can collect process, lockfile, and version evidence before killing anything.
2. **Given** cleanup is needed, **When** the document is followed, **Then** only Flutter cache locks and known stuck Flutter/Git children are targeted.

## Edge Cases

- The local Flutter SDK may be outside the repo and require elevated cleanup.
- Existing tests may fail after the toolchain is repaired; those must be tracked separately from command hangs.
- Network-dependent `flutter pub get` may fail under sandboxing or offline conditions and must be reported separately.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The plan must collect evidence for Flutter hangs before proposing cleanup.
- **FR-002**: The plan must separate toolchain failures from app test failures.
- **FR-003**: The plan must define a bounded verification command sequence from smallest to full suite.
- **FR-004**: The plan must document safe Windows cleanup steps for stale Flutter cache locks and stuck Flutter/Git child processes.
- **FR-005**: The plan must not delete build outputs, Flutter SDK files, or user data without explicit evidence and approval.
- **FR-006**: The final baseline must record analyzer, targeted test, and full-suite outcomes with command names.

### Key Entities

- **Verification Baseline**: The current known pass/fail/hang state of Flutter commands.
- **Toolchain Recovery Runbook**: Local diagnostic and cleanup steps for Flutter/Git hangs.
- **Test Batch**: A named group of tests run to isolate failures.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `flutter --version` completes within a bounded timeout.
- **SC-002**: `flutter analyze --no-pub` completes and reports a concrete result.
- **SC-003**: At least one targeted Flutter test batch completes with a concrete result.
- **SC-004**: Any full-suite failure is reported with the responsible test file, timeout point, or environmental blocker.

## Assumptions

- This feature repairs local verification reliability, not application behavior.
- External sandbox/network failures are allowed outcomes if clearly reported.
- Real-device QA remains a separate production readiness task.
