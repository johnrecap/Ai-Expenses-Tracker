# Implementation Plan: Monetization Purchases And Ads Production

**Branch**: `037-monetization-purchases-ads` | **Date**: 2026-05-18 | **Spec**: `specs/037-monetization-purchases-ads/spec.md`  
**Input**: Open monetization tasks and audit findings: actual ad placements incomplete, Premium purchase service unavailable, test IDs/defaults need production-safe handling.

## Summary

Finish consent-aware ad placements, keep finance flows safe, clarify Free/Premium status, and prepare real purchase verification without granting Premium from the client alone.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing `lib/monetization`, `google_mobile_ads`, Bloc/Cubit, local policy repositories  
**Storage**: Existing entitlement/policy abstractions; future backend verification documented but not required  
**Testing**: Monetization Cubit/widget tests, fake ad service tests, Android test-ad QA  
**Target Platform**: Android priority  
**Project Type**: Multi-platform Flutter app  
**Performance Goals**: Ads load asynchronously; UI remains responsive and stable  
**Constraints**: No production ad ids or purchase secrets in source; core finance features always usable  
**Scale/Scope**: Ad slots, frequency caps, reward credits, purchase messaging, tests and QA docs

## Constitution Check

- Monetization decisions must go through `FeatureGateService`, policy repositories, and `MonetizationCubit`.
- Ads must use `AdService` and `AdConsentService` abstractions.
- Production ad IDs and purchase secrets must never be stored in Flutter source.
- Free plan core finance features must remain usable when AI quota, ads, consent, or purchases fail.
- Critical finance and security routes must not show interstitials.

## Project Structure

```text
lib/monetization/
lib/screens/monetization/
lib/screens/home/
lib/screens/expenses/
lib/screens/reports/
lib/screens/export/
test/monetization/
docs/monetization/
```

**Structure Decision**: Extend the existing monetization foundation instead of adding scattered ad logic to screens.

## Implementation Notes

- Keep real billing verification out of Flutter unless a trusted backend exists.
- Use test ad unit IDs in debug/internal builds only.
- Add banners where they are useful and low-risk: Home below summary/sections, Expenses list, Reports/Stats.
- Interstitials should be rare and only after non-critical completion such as export or repeated save, never before a save/confirmation.

## Risks

- Ads can harm UX in a finance app. Mitigation: conservative placements and caps.
- Client-side Premium can be abused. Mitigation: no permanent client-only unlock.
- Consent SDK differences by region/device. Mitigation: explicit unavailable/failure behavior and manual QA.
