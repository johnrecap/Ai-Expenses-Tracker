# Implementation Plan: Production Ads Readiness

**Branch**: `027-production-ads-readiness` | **Date**: 2026-05-17 | **Spec**: `specs/027-production-ads-readiness/spec.md`  
**Input**: Convert ad foundation into production-ready AdMob integration with consent, configuration, placements, caps, and tests.

## Summary

Add real AdMob SDK wiring behind the existing `AdService` abstraction, configure platform app IDs safely, implement approved banner/interstitial/rewarded placements, and verify Premium users never request ads. This plan does not implement real store purchases.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `google_mobile_ads`, existing monetization/ad abstractions  
**Storage**: Local frequency cap state; no secret storage in Flutter  
**Testing**: Unit tests with fake ad service, widget tests for slots, Android debug QA with test ads  
**Target Platform**: Android first, iOS prepared if platform files exist  
**Project Type**: Flutter mobile app  
**Performance Goals**: Ad slot layout remains stable; no blocking on ad load  
**Constraints**: No production ad IDs committed as secrets; no ads in critical flows; Premium skips SDK initialization  
**Scale/Scope**: Ads SDK dependency, platform config, banners, interstitial hooks, rewarded AI credit, consent diagnostics

## Constitution Check

- Ads must use `AdService` and `AdConsentService` abstractions.
- Production ad IDs and secrets must not be stored directly in source in a sensitive way.
- Free core finance features remain usable if ads fail.
- Monetization gates go through `FeatureGateService`.

## Project Structure

```text
lib/monetization/
|-- services/
|-- widgets/
|-- cubit/
`-- models/

android/app/src/main/AndroidManifest.xml
ios/Runner/Info.plist
lib/screens/home/
lib/screens/expenses/
lib/screens/stats/
lib/services/export/
```

**Structure Decision**: Keep plugin-specific code inside `lib/monetization/services`; screens only render ad slot widgets or call central interstitial gate hooks.

## Implementation Notes

- Use Google test ad unit IDs in debug.
- Read production IDs from build-time configuration or documented platform resources; do not hide unreviewable secrets in code.
- Reserve banner height before load to avoid layout shifts.
- Interstitial hooks must run only after successful user value, never before.

## Risks

- AdMob approval can delay real ad serving. Mitigation: test IDs and documentation.
- Consent SDK behavior varies by geography. Mitigation: debug geography QA.
- Extra package can affect Android build. Mitigation: add dependency in a small commit and verify build early.
