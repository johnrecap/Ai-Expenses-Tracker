# Implementation Plan: Observability Retention And Readiness

**Branch**: `039-observability-retention-readiness` | **Date**: 2026-05-18 | **Spec**: `specs/039-observability-retention-readiness/spec.md`  
**Input**: Production readiness audit: verbose Bloc logging, missing crash/analytics/remote config packages, missing Home navigation tests, open manual QA tasks, and need for retention improvements.

## Summary

Sanitize production logging, add safe observability and feature-flag readiness, create end-to-end QA documentation/tests, and expand local retention loops so users return without consuming AI quota.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing Bloc, Firebase Core/Auth/Firestore; optional Crashlytics/Analytics/Remote Config if approved  
**Storage**: Local settings and Firestore user data; telemetry must exclude private payloads  
**Testing**: Flutter tests, widget/navigation smoke tests, manual device QA  
**Target Platform**: Android priority  
**Project Type**: Multi-platform Flutter app  
**Performance Goals**: Telemetry and retention calculations must not block startup or expense creation  
**Constraints**: No raw financial details in logs; features fail open for core manual tracking  
**Scale/Scope**: Logging, observability adapters, QA docs/tests, retention prompts/feedback

## Constitution Check

- Free plan core finance features must remain usable when optional systems fail.
- Engagement calculators remain deterministic/local and free of AI provider calls.
- Notification scheduling must respect user settings and permissions.
- Widgets should not use plugin APIs directly when services exist.
- Verification must include `flutter analyze`, `flutter test`, and relevant device QA.

## Project Structure

```text
lib/simple_bloc_observer.dart
lib/observability/
lib/engagement/
lib/screens/home/
lib/screens/settings/
docs/qa/
docs/observability/
test/home/
test/engagement/
```

**Structure Decision**: Add a small observability layer instead of scattering crash/analytics calls through widgets and repositories.

## Implementation Notes

- First reduce unsafe logging even if Crashlytics is deferred.
- If adding Firebase Crashlytics/Analytics/Remote Config, keep wrappers injectable and optional.
- Home retention should reuse existing engagement calculators; avoid AI provider calls.
- QA docs should be executable by a non-developer app owner using a device.

## Risks

- Telemetry can violate privacy if too detailed. Mitigation: whitelist safe event fields only.
- Adding Firebase packages can require platform config. Mitigation: make package addition a clearly scoped task.
- Retention prompts can become annoying. Mitigation: user settings and conservative defaults.
