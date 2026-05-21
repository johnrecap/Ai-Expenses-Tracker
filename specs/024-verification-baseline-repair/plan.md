# Implementation Plan: Verification Baseline Repair

**Branch**: `024-verification-baseline-repair` | **Date**: 2026-05-17 | **Spec**: `specs/024-verification-baseline-repair/spec.md`  
**Input**: Repair the current verification baseline so tests do not hang silently and future workers know what to run.

## Summary

Find and fix the cause of the hanging Flutter test run, isolate platform/Firebase dependencies behind fakes, and document the exact verification commands for Flutter, Worker, optional Functions, and Android release builds. This plan changes tests and documentation first; app behavior changes only if the hang exposes a real lifecycle bug.

## Technical Context

**Language/Version**: Dart 3.x, Flutter current local SDK  
**Primary Dependencies**: `flutter_test`, `bloc_test`, Firebase repositories, local app service fakes  
**Storage**: No production storage changes; tests must use in-memory fakes  
**Testing**: `flutter analyze`, `flutter test --reporter expanded`, targeted test files  
**Target Platform**: Flutter app across Android/iOS/web/desktop, with local verification on Windows  
**Project Type**: Mobile/desktop/web Flutter application plus repository package  
**Performance Goals**: Full Flutter test command completes within 3 minutes locally  
**Constraints**: No real Firebase, provider AI, ads, speech, local auth, notification prompts, or network in Flutter unit/widget tests  
**Scale/Scope**: Entire Flutter test baseline and documentation

## Constitution Check

- Bloc/Cubit and repository patterns remain unchanged.
- No production Firebase paths are extended.
- No AI service writes directly to Firestore.
- Verification commands must be run before reporting implementation completion.
- Any package or verification baseline change must update `.specify/memory/constitution.md`.

## Project Structure

### Documentation

```text
specs/024-verification-baseline-repair/
|-- spec.md
|-- plan.md
`-- tasks.md
```

### Source Code

```text
test/
|-- home/
|-- ai/
|-- monetization/
|-- helpers/
`-- widget_test.dart

lib/
|-- services/
|-- screens/
`-- monetization/
```

**Structure Decision**: Keep verification fixes inside existing test folders and add helpers only when multiple suites need the same fake setup.

## Implementation Notes

- Start by running targeted tests with verbose output and a timeout to identify the first hang.
- Inspect `setUp`, `tearDown`, Cubit streams, timers, notification scheduling, speech controllers, and Firebase initialization in the hanging suite.
- Prefer replacing plugin calls with existing app abstractions or fake services in tests.
- Avoid increasing timeouts as the fix; the process must exit naturally.

## Risks

- A hang may be caused by a platform plugin initialized from app startup. Mitigation: isolate widget roots and inject fakes.
- Firebase initialization might be triggered by real repository construction. Mitigation: build tests around repository interfaces.
- Some tests may pass individually but hang as a suite due to static state. Mitigation: add teardown and reset helpers.
