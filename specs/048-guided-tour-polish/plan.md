# Implementation Plan: Guided Tour Polish

**Branch**: `048-guided-tour-polish` | **Date**: 2026-05-18 | **Spec**: `specs/048-guided-tour-polish/spec.md`  
**Input**: Guided tour implementation gaps found after Plan 043.

## Summary

Make guided tour target preparation real and testable, remove or implement unused model metadata, improve off-screen target behavior, and strengthen guided tour widget coverage.

## Technical Context

**Language/Version**: Dart 3.x, Flutter widgets, Flutter Bloc/Cubit  
**Primary Dependencies**: Existing `GuidedTourCubit`, `GuidedTourHost`, `SpotlightTarget`, generated l10n  
**Storage**: Existing `UserSettings` guided tour fields  
**Testing**: Guided tour widget tests, Home/Settings tests, analyzer  
**Target Platform**: Flutter mobile app, Android priority  
**Project Type**: UI onboarding feature  
**Performance Goals**: No heavy overlay work; target refresh remains lightweight  
**Constraints**: Tour cannot call AI, ads, purchases, permissions, camera, speech, or notification services  
**Scale/Scope**: `lib/guided_tour/`, Home/Settings target registration, tests

## Constitution Check

- Guided tour state persists through `UserSettings`.
- Feature widgets must not embed overlay logic.
- Tour steps must not trigger provider or monetization side effects.
- UI strings stay in l10n.
- Verification includes guided tour widget tests.

**Gate Status**: PASS.

## Project Structure

```text
lib/guided_tour/models/guided_tour_step.dart
lib/guided_tour/cubit/guided_tour_cubit.dart
lib/guided_tour/widgets/guided_tour_host.dart
lib/guided_tour/widgets/tour_overlay.dart
lib/guided_tour/guided_tour_steps.dart
lib/screens/home/
lib/screens/settings/
test/guided_tour/
test/home/
test/settings/
```

**Structure Decision**: Keep tour orchestration in `lib/guided_tour/`; feature screens only register targets or expose scroll/route preparation hooks through the host.

## Implementation Notes

- First decide whether `routeName` and `allowTargetTap` remain.
- If `routeName` remains, implement a route preparation callback in `GuidedTourHost` or cubit integration.
- If `allowTargetTap` remains, overlay hit testing must be selective and safe.
- Add a scroll preparation callback or target registry metadata so off-screen targets can be made visible before rect calculation.
- Ensure `_visibleRectFor` returning null does not leave the user without guidance for required steps.
- Use fake settings repository in tests to verify persistence.

## Verification

```text
flutter analyze --no-pub
flutter test --no-pub test/guided_tour --reporter expanded --concurrency=1 --timeout 45s
flutter test --no-pub test/home test/settings --reporter expanded --concurrency=1 --timeout 45s
```

## Deferred Items To Keep In Mind

Real-device guided tour QA on Android after clean install, Arabic RTL small-screen placement, and first real-user feedback remain deferred Product/Retention items if not completed locally.

## Complexity Tracking

No constitution violations.
