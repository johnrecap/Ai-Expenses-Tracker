# Implementation Plan: Live Monetization State

**Branch**: `026-live-monetization-state` | **Date**: 2026-05-17 | **Spec**: `specs/026-live-monetization-state/spec.md`  
**Input**: Replace local placeholder monetization state with shared, live state across Settings, Free/Premium, quota prompts, and ad gates.

## Summary

Wire `MonetizationCubit`, entitlement repository, policy repository, and usage updates at app scope. Settings and Free/Premium consume the same state, quota refreshes after AI actions, and failures default to Free-safe non-blocking behavior.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `flutter_bloc`, existing `lib/monetization`, Firestore settings/profile repository if entitlement is user-backed  
**Storage**: Cached local entitlement/policy where available; future trusted entitlement under user-scoped data or Worker  
**Testing**: Cubit unit tests, Settings widget tests, Free/Premium widget tests  
**Target Platform**: Flutter app all targets  
**Project Type**: Mobile/desktop/web app  
**Performance Goals**: Settings renders cached/default state immediately and refreshes without blocking UI  
**Constraints**: No client-side permanent Premium grant; no ads initialized for Premium; manual app features never blocked by monetization load failures  
**Scale/Scope**: App provider setup, Settings, Free/Premium screen, AI quota refresh hooks

## Constitution Check

- Monetization checks go through `FeatureGateService`, repositories, and `MonetizationCubit`.
- Widgets must not scatter `isPremium` booleans or quota math inline.
- Free core finance features remain usable when quotas, ads, consent, or purchase state fail.
- No provider secrets or purchase verification secrets in Flutter source.

## Project Structure

```text
lib/
|-- app.dart or main.dart
|-- monetization/
|   |-- cubit/
|   |-- repositories/
|   |-- services/
|   `-- widgets/
|-- screens/settings/
`-- screens/monetization/
```

**Structure Decision**: Keep all monetization state under `lib/monetization`; screens consume Cubit state and do not own plan rules.

## Implementation Notes

- Locate the highest practical widget where authenticated repositories are created and provide the Cubit there.
- If app-level creation is blocked by auth timing, create the Cubit after `AuthAuthenticated` and dispose it on logout.
- Convert any local `MonetizationState.initial()` usage in screens into Bloc consumers/selectors.
- Keep test fixtures for Free, Premium, loading, error, quota-exhausted, and purchase-unavailable.

## Risks

- Providing the Cubit too high may not have user ID yet. Mitigation: create after auth state is known.
- Refreshing quota too often can create extra Worker calls. Mitigation: update from AI responses first and refresh only on screen open/user action.
- Premium state may flicker if no cached entitlement exists. Mitigation: render Free-safe default with loading indicator.
