# Implementation Plan: Premium Entitlement Backend

**Branch**: `074-premium-entitlement-backend` | **Date**: 2026-05-20 | **Spec**: `specs/074-premium-entitlement-backend/spec.md`

## Summary

Move monetization from foundation to paid-launch readiness by clarifying Premium benefits, keeping purchases honestly disabled until backend verification exists, and designing a trusted entitlement verification/restore path.

## Technical Context

**Language/Version**: Dart 3.x, Flutter; backend TBD behind trusted service  
**Primary Dependencies**: Existing `MonetizationCubit`, `PurchaseService`, `EntitlementRepository`, `FeatureGateService`, Ad service abstractions  
**Storage**: Server-owned entitlement state; local cached entitlement snapshot  
**Testing**: Monetization unit/widget tests, fake backend verification tests, ad gating tests  
**Target Platform**: Android first  
**Project Type**: Monetization backend readiness  
**Performance Goals**: Entitlement check should not block core app startup indefinitely  
**Constraints**: No client-only permanent Premium unlock; production secrets outside Flutter  
**Scale/Scope**: One authenticated user's entitlement state

## Constitution Check

- No purchase verification secrets in Flutter: PASS.
- Free core tracking remains usable: PASS.
- Ads through abstractions only: PASS.
- Premium no-ad guarantee: PASS.

## Project Structure

```text
lib/monetization/
lib/screens/monetization/
workers/ai-gateway/ or future backend path
docs/monetization/premium-verification.md
docs/implementation_plans/deferred-and-advanced-work.md
test/monetization/
```

## Implementation Strategy

1. Finalize benefit matrix and UI copy.
2. Keep real purchases disabled until backend verification is implemented.
3. Add backend verification contract and fake client tests.
4. Wire entitlement refresh/restore states through existing monetization cubit.
5. Prove ad gates and free core behavior through tests.

## Risks

- Backend choice affects implementation. Mitigation: write contracts first and keep client behind service interface.
- Store policy details may change. Mitigation: keep release checklist updated.

## Deferred Items Considered

Relevant deferred items: real purchase verification, production AdMob IDs, consent-region QA, entitlement restore, Play Store readiness.

