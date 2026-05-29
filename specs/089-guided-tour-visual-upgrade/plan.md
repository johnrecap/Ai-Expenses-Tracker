# Implementation Plan: Guided Tour Visual Upgrade

**Branch**: `089-guided-tour-visual-upgrade` | **Date**: 2026-05-27 | **Spec**: `specs/089-guided-tour-visual-upgrade/spec.md`  
**Input**: Feature specification from `specs/089-guided-tour-visual-upgrade/spec.md`

## Summary

Upgrade the existing guided tour overlay with a clearer target spotlight, connector, and optional liquid/glass accent while preserving current tour state, replay, skip, completion, and localization behavior. The implementation will first improve the custom overlay; package adoption is allowed only after license/performance review.

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.44  
**Primary Dependencies**: Existing `GuidedTourCubit`, `GuidedTourHost`, `SpotlightTarget`, `TourOverlay`, Flutter `CustomPainter`, `BackdropFilter` if safe  
**Storage**: Existing `UserSettings` guided tour fields  
**Testing**: Widget tests for target geometry and navigation; manual Android screenshots for visual polish  
**Target Platform**: Android-first Flutter app, Arabic/English  
**Project Type**: Mobile app UI overlay  
**Performance Goals**: Smooth enough interaction on mid-range Android; no heavy shader dependency unless proven safe  
**Constraints**: Tour must not call AI, ads, purchases, permissions, camera, speech, or notifications; localization required  
**Scale/Scope**: Existing guided tour steps

## Research References

- `save_points_showcaseview` demonstrates coach steps with target keys and configurable button text, useful as comparison but not automatically adopted: https://pub.dev/packages/save_points_showcaseview
- `liquid_glass_kit` offers glass UI components with quality controls and low-end fallback, useful as a design reference: https://pub.dev/packages/liquid_glass_kit
- `oc_liquid_glass` offers GPU shader liquid-glass effects but has platform limitations, so it is a reference/spike candidate rather than default: https://github.com/heyarny/oc_liquid_glass

## Constitution Check

- Guided tour targets remain registered with `SpotlightTarget`: PASS.
- Tour steps must not call AI/ads/purchases/permissions/camera/speech/notifications: PASS.
- Guided tour state persists in `UserSettings`: PASS.
- New copy uses localization: PASS.
- Visual changes must not block small-screen RTL usage: PASS.

## Project Structure

```text
lib/guided_tour/
lib/widgets/
lib/screens/home/
lib/screens/settings/
lib/l10n/
test/guided_tour/
```

**Structure Decision**: Keep existing tour architecture and replace/extend only the visual overlay and geometry logic.

## Implementation Strategy

1. Audit current overlay target/card geometry and screenshots.
2. Add a connector model and custom painter.
3. Add premium card styling with bounded glass/liquid accent and accessibility fallback.
4. Improve target placement/scroll handling.
5. Add widget tests for geometry and controls.
6. Run manual Android Arabic/English visual QA.

## Risks

- Overdesigned effects can hurt readability/performance. Mitigation: keep effect subtle and disable/reduce on low-end or accessibility mode.
- Third-party shader packages may be unstable. Mitigation: custom painter first; package only after spike.
- RTL connector direction can be wrong. Mitigation: geometry tests and device QA.

## Verification

```text
flutter test --no-pub test/guided_tour --reporter=expanded --timeout=45s
flutter analyze --no-pub
```

Manual QA:

```text
Clean install or reset tour, Arabic/English, small Android screen, replay from Settings, skip, back, complete.
```

## Deferred Items Considered

Existing deferred work tracks real-device guided tour QA. This plan pulls visual polish and replay/target stability into active work; broad onboarding copy experiments remain later.

## Implementation Audit Notes

- Current tour files are concentrated in `lib/guided_tour/`: `GuidedTourCubit`
  owns state, target registration, replay, persistence, target scrolling, and
  target measurement; `GuidedTourHost` owns the overlay placement; `TourOverlay`
  owns dimming, spotlight, copy, and buttons.
- Target registrations currently cover AI assistant, manual expense FAB,
  budget card, reports nav, categories menu, and settings shortcut. Steps that
  reuse the AI/settings targets should continue to share the same registered
  target rectangles.
- Package decision: no new dependency is adopted for the MVP. `save_points_showcaseview`
  would duplicate existing tour state, `liquid_glass_kit` is useful as a visual
  reference but unnecessary for one overlay, and `oc_liquid_glass` adds shader/GPU
  risk on older Android devices. The implementation uses a custom `CustomPainter`
  connector and a lightweight decorative accent instead.
