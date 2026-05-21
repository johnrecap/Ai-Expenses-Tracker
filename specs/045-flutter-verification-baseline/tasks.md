# Tasks: Flutter Verification Baseline

**Input**: Design documents from `specs/045-flutter-verification-baseline/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

**Purpose**: Capture evidence before cleanup.

- [ ] T001 Inspect current Flutter/Dart/Git process state with `Get-Process flutter,dart,git -ErrorAction SilentlyContinue`.
- [ ] T002 Inspect Flutter cache lockfile state under `C:\flutter\bin\cache` without deleting files.
- [ ] T003 Run direct Dart version check with `C:\flutter\bin\cache\dart-sdk\bin\dart.exe --version`.
- [ ] T004 Run `git -C C:\flutter status --short` to confirm SDK Git can respond.
- [ ] T005 Record findings in a new or existing `docs/qa/flutter-verification-runbook.md`.

## Phase 2: Foundational

**Purpose**: Define safe recovery before executing broad test commands.

- [X] T006 Create `docs/qa/flutter-verification-runbook.md` with diagnostic commands, expected evidence, and cleanup decision rules.
- [X] T007 Document that stale lock removal is allowed only for verified stale Flutter cache lockfiles.
- [X] T008 Document that process termination must target only stuck Flutter/Dart/Git child processes from the verification attempt.
- [X] T009 Document when to stop and ask for manual approval instead of continuing cleanup.

## Phase 3: User Story 1 - Restore A Reliable Flutter Command Baseline (Priority: P1)

**Goal**: Basic Flutter commands complete or fail with evidence.

**Independent Test**: `flutter --version`, `flutter pub get`, and `flutter analyze --no-pub` return results.

- [ ] T010 [US1] Run `flutter --version` with a bounded timeout and record result in `docs/qa/flutter-verification-runbook.md`.
- [ ] T011 [US1] If T010 hangs, apply only the documented safe recovery steps from T006-T009.
- [ ] T012 [US1] Run `flutter pub get` and record whether it succeeds, fails due to network/sandbox, or hangs.
- [ ] T013 [US1] Run `flutter analyze --no-pub` and record the analyzer result.

## Phase 4: User Story 2 - Rebuild The Flutter Test Baseline Incrementally (Priority: P1)

**Goal**: Identify whether test failures are command hangs or named app test failures.

**Independent Test**: At least one targeted test batch completes with a concrete result.

- [ ] T014 [US2] Run `flutter test --no-pub test/widget_test.dart --reporter expanded --concurrency=1 --timeout 45s`.
- [ ] T015 [US2] Run targeted settings/onboarding tests that cover current settings persistence surfaces.
- [ ] T016 [US2] Run targeted guided tour/home tests that previously appeared in verification notes.
- [ ] T017 [US2] Run `flutter test --no-pub --reporter expanded --concurrency=1 --timeout 45s`.
- [ ] T018 [US2] Classify any failure from T014-T017 as pass, assertion failure, timeout, toolchain hang, or external dependency issue in `docs/qa/flutter-verification-runbook.md`.

## Phase 5: User Story 3 - Document Toolchain Recovery Steps (Priority: P2)

**Goal**: Make future recovery repeatable.

**Independent Test**: A new developer can follow the runbook without touching unrelated files.

- [X] T019 [US3] Add a "Known Windows Flutter Hang Recovery" section to `docs/qa/flutter-verification-runbook.md`.
- [X] T020 [US3] Include the exact commands that were safe and effective during this run.
- [X] T021 [US3] Include a "Do Not Do" section covering broad SDK deletion, broad process killing, and unverified cleanup.
- [ ] T022 [US3] Update `.specify/memory/constitution.md` verification baseline only after fresh command evidence exists.

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T023 Update `docs/implementation_plans/deferred-and-advanced-work.md` only if a new external blocker is discovered.
- [X] T024 Update `specs/045-flutter-verification-baseline/tasks.md` checkboxes as tasks complete.

## Dependencies & Execution Order

- Diagnostics T001-T005 must happen before cleanup.
- T006-T009 must exist before any cleanup is performed.
- US1 blocks US2.
- US3 documents what actually happened and should be finalized after US1/US2 evidence.

## Implementation Strategy

MVP is restoring bounded `flutter --version` and `flutter analyze --no-pub`. Full success is a documented, repeatable test baseline with a classified full-suite outcome.
