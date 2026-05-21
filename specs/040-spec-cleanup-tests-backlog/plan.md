# Implementation Plan: Spec Cleanup, Navigation Tests, And Deferred Backlog Alignment

**Branch**: `040-spec-cleanup-tests-backlog` | **Date**: 2026-05-18 | **Spec**: `specs/040-spec-cleanup-tests-backlog/spec.md`  
**Input**: Feature specification from `specs/040-spec-cleanup-tests-backlog/spec.md`

## Summary

Create a disciplined cleanup pass that makes historical Speckit task status trustworthy, adds missing Home/Settings widget safety coverage, and updates the persistent deferred backlog to match the latest project state. The plan is intentionally scoped to documentation/status cleanup plus tests and only fixes app code if those tests reveal a real wiring bug.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter test, Bloc/Flutter Bloc, existing repository interfaces, existing fake/test helpers  
**Storage**: No new runtime storage; documentation changes under `specs/` and `docs/implementation_plans/`  
**Testing**: `flutter analyze`, targeted Home/Settings widget tests, relevant existing tests, full Flutter suite if shared UI/provider code changes  
**Target Platform**: Flutter app with Android priority; tests must run without real device services  
**Project Type**: Multi-platform Flutter mobile app with local docs and Speckit artifacts  
**Performance Goals**: Added widget tests should complete quickly and avoid slow plugin initialization  
**Constraints**: Do not require live Firebase, Cloudflare, AdMob, camera, speech, notifications, local auth, keystore, or device QA for local verification  
**Scale/Scope**: Historical task files across `specs/`, Home navigation tests, Settings smoke tests, persistent deferred backlog updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Speckit workflow is used: spec, plan, and tasks are created before implementation.
- Existing architecture is preserved: Bloc/Cubit and repository interfaces remain the test boundary.
- No direct Firebase/plugin calls are introduced in widgets or tests.
- User-generated financial data is not logged or added to test fixtures unnecessarily.
- Localization rules apply if any new user-facing strings are introduced during implementation.
- Verification must include analyzer and relevant tests before marking implementation complete.

**Gate Status**: PASS. This plan is documentation/test-focused and does not require architecture changes.

## Project Structure

### Documentation (this feature)

```text
specs/040-spec-cleanup-tests-backlog/
|-- spec.md
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- checklists/
|   `-- requirements.md
`-- tasks.md
```

### Source Code And Documentation Targets

```text
docs/implementation_plans/deferred-and-advanced-work.md
specs/*/tasks.md
specs/README.md
test/home/
test/settings/
test/helpers/
lib/screens/home/
lib/screens/settings/
```

**Structure Decision**: Keep cleanup evidence in Speckit task files and `specs/README.md`; keep future work memory in `docs/implementation_plans/deferred-and-advanced-work.md`; keep tests near existing `test/home` and `test/settings` suites.

## Phase 0: Research

See `research.md`.

## Phase 1: Design

See `data-model.md` and `quickstart.md`.

## Risk Notes

- Updating historical task files can hide real work if done too aggressively. Mitigation: annotate superseded tasks instead of deleting or blindly checking them.
- Widget tests can accidentally instantiate real services. Mitigation: use fake repositories and provider wrappers.
- Settings and Home are provider-heavy surfaces. Mitigation: start with smoke tests around stable sections and routes, then expand gradually.
- Deferred backlog can become noisy. Mitigation: keep entries concise and avoid duplicates.

## Deferred Items To Keep In Mind

Relevant existing deferred items from `docs/implementation_plans/deferred-and-advanced-work.md`:

- Release keystore/build and production-device QA remain external blockers.
- Firebase deploy/smoke test remains external.
- AI real-device QA and AdMob QA remain external.
- Full localization/RTL visual QA remains open.
- Feature flag wiring, Home navigation tests, and Settings widget tests are current actionable local work.

## Complexity Tracking

No constitution violations.
