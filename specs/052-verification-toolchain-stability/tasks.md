# Tasks: Verification Toolchain Stability

**Input**: Design documents from `specs/052-verification-toolchain-stability/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Capture the current failure mode before changing workflow.

- [x] T001 Confirm direct `dart.exe --version` works without Flutter batch.
- [x] T002 Confirm `flutter.bat`/`dart.bat` can hang when Flutter cache lock files are not writable.
- [x] T003 Confirm Dart CLI analytics/session writes fail against `%APPDATA%\.dart-tool` without suppression.
- [x] T004 Confirm `dart.exe --suppress-analytics format --version` succeeds.

## Phase 2: Foundational

**Purpose**: Add fail-fast diagnostics and safe Dart formatting entrypoint.

- [x] T005 Add `tools/verification/diagnose_toolchain.ps1`.
- [x] T006 Add `tools/verification/safe_dart_format.ps1`.
- [x] T007 Update `.gitignore` for any project-local verification scratch output.

## Phase 3: User Story 1 - Fail Fast On Toolchain Permission Problems (Priority: P1)

**Goal**: Detect known permission/lock hazards before long hangs.

**Independent Test**: Diagnostic script reports non-writable paths in under 10 seconds.

- [x] T008 [US1] Check Flutter SDK cache lock write access.
- [x] T009 [US1] Check Dart telemetry directory write access.
- [x] T010 [US1] Print exact remediation options without applying global ACL changes.

## Phase 4: User Story 2 - Provide Stable Verification Commands (Priority: P1)

**Goal**: Give developers one reliable command matrix for formatting/analyze/tests.

**Independent Test**: Safe Dart format command works with `--version` and normal file arguments.

- [x] T011 [US2] Implement safe Dart format wrapper with `--suppress-analytics`.
- [x] T012 [US2] Update `docs/qa/flutter-verification-runbook.md` with safe command matrix.
- [x] T013 [US2] Document when Flutter commands require approved/escalated execution or writable SDK cache.

## Phase 5: User Story 3 - Keep Verification Runtime Bounded (Priority: P2)

**Goal**: Split verification into small groups with clear timeout behavior.

**Independent Test**: Run each documented command separately and record results.

- [x] T014 [US3] Document repository/service test group.
- [x] T015 [US3] Document expenses/widget test group.
- [x] T016 [US3] Document home/guided-tour test group.
- [x] T017 [US3] Add timeout and hang triage steps for each group.

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T018 Run diagnostic script.
- [x] T019 Run safe Dart format wrapper with `-- --version`.
- [x] T020 Run `flutter analyze --no-pub` after diagnostics.
- [x] T021 Run one smallest targeted Flutter test group after diagnostics.
- [x] T022 Update `docs/implementation_plans/deferred-and-advanced-work.md` with any remaining machine-level setup blocker.
- [x] T023 Update `specs/052-verification-toolchain-stability/tasks.md` checkboxes as tasks complete.

## Dependencies & Execution Order

- T001-T004 before scripts.
- T005-T013 before any further broad verification runs.
- T014-T017 before full targeted test pass.
- T018-T021 are validation tasks and may remain blocked until environment permissions are resolved.

## Implementation Strategy

Prefer fail-fast checks and documented explicit approval over hidden environment mutation. Use direct Dart executable with `--suppress-analytics` for formatting, and keep Flutter commands behind a preflight that explains the SDK cache write requirement.
