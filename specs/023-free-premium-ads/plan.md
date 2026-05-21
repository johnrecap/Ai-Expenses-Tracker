# Implementation Plan: Free/Premium Monetization And Ads

**Branch**: `[023-free-premium-ads]` | **Date**: 2026-05-17 | **Spec**: `specs/023-free-premium-ads/spec.md`

## Summary

Add a monetization foundation that keeps the core Expense Tracker free, introduces a clear Free/Premium screen, prepares safe ad placements for free users, and isolates future purchase verification behind a proper entitlement layer. Ads must be polite, consent-aware, frequency-capped, and disabled for Premium users.

## Technical Context

**Language/Version**: Dart 3.x, Flutter.  
**Primary Dependencies**: Existing Bloc/Cubit style; candidate `google_mobile_ads` for AdMob; candidate `in_app_purchase` for future store subscriptions.  
**Backend**: Firebase Auth/Firestore for user account data; Cloudflare Worker can be used for AI quota and future entitlement verification.  
**Storage**: Firestore user profile for entitlement snapshot; local cache for last entitlement and ad frequency state; Worker/D1 can own daily AI usage policy.  
**Testing**: Unit tests for gates/policies, widget tests for plan screen and ad placeholders, manual device QA for real ad SDK.  
**Target Platform**: Android first; iOS supported by configuration; web/desktop must gracefully hide mobile ads.  
**Project Type**: Flutter app feature and monetization architecture.  
**Performance Goals**: Premium users should not wait for ad SDK setup; ad loading must not block core UI.  
**Constraints**: No real ad unit IDs or purchase secrets in code; no direct mutation of Premium status from untrusted UI.  
**Scale/Scope**: One signed-in user account with future multi-device entitlement restore.

## Constitution Check

- **User Safety**: Pass. Core tracking remains available without ads or AI quota.
- **AI Cost Control**: Pass. Free and Premium both use explicit quota policies.
- **Privacy**: Pass. Ads are consent-aware and privacy options are exposed when required.
- **Architecture**: Pass. Monetization is isolated behind models, repositories, Cubit, and services.
- **No Backend Surprise**: Pass. Firebase remains primary backend; Cloudflare Worker is optional for free-tier AI and future entitlement verification.

## Recommended Product Policy

### Free Plan

Free must be a real usable plan, not a broken trial.

- Manual expense creation: enabled.
- Categories: enabled.
- Budgets: enabled.
- Basic reports: enabled.
- Basic export: enabled, with reasonable limits if needed.
- Offline add/sync: enabled.
- AI text parse: default 5 successful uses/day.
- AI receipt extraction: default 3 successful uses/day.
- AI advice: default 3 successful uses/day.
- Ads: enabled after consent, with frequency caps.
- Rewarded ad credits: optional, small, capped.

**Reason**: The app's value is expense tracking. If this is blocked, users will abandon the app before Premium is meaningful.

### Premium Plan

Premium should remove friction and increase power, not hold the core app hostage.

- No ads.
- Higher AI quota, but still finite unless paid backend capacity exists.
- More advanced reports and month comparisons.
- More export options or larger export ranges.
- More receipt extraction allowance.
- Optional premium-only AI insights after local summaries are already available.
- Priority feature access can be added later.

**Reason**: Premium is easier to defend when it saves time and removes limits rather than blocking necessary finance tracking.

### Rewarded Ads

Rewarded ads should grant small one-off benefits:

- +1 AI parse credit, or
- +1 AI advice credit, or
- +1 receipt extraction credit if policy allows.

They should not grant large quota packs and must not be required for manual tracking.

**Reason**: Rewarded ads can help free users without forcing monetization into critical flows.

## Ad Placement Policy

### Allowed Placements

- **Home bottom adaptive banner**: reserved height under main content or above bottom navigation if layout supports it.
- **Expenses list adaptive banner**: after a stable list segment or bottom reserved slot.
- **Reports/Stats adaptive banner**: bottom slot below charts, not covering chart interaction.
- **Export completion interstitial**: after export result is generated, not before user action.
- **Post-save interstitial**: only after N completed saves and only after the user returns to a stable screen.
- **Rewarded ad from quota screen**: user explicitly taps "watch ad for one extra AI action".

### Blocked Placements

- App launch.
- Authentication screens.
- App lock/PIN/biometric screens.
- Add Expense form while typing.
- AI Assistant sheet while typing.
- AI preview/confirmation.
- Delete/update confirmation.
- Purchase/restore flow.
- Any screen where an ad covers a primary action button.

**Reason**: Finance apps need predictable workflows. Ads must appear at completion moments or in reserved passive slots.

## Frequency Cap Policy

Initial recommended defaults:

- Banner: normal refresh handled by SDK; app only controls visibility and reserved slot.
- Interstitial: no more than 1 every 10 minutes.
- Interstitial: no more than 3 per app session.
- Post-save interstitial: only after at least 5 successful expense saves since last interstitial.
- Rewarded ad: max 3 rewarded AI credits/day for Free users, configurable separately from base AI quota.

**Reason**: Frequency caps protect retention and prevent accidental policy issues from excessive interruption.

## Consent And Privacy Policy

- Request updated consent info on every app launch when ads are enabled for the current user.
- Show required consent forms before requesting ads.
- Check `canRequestAds()` before loading ads.
- Add a Settings entry for privacy options when required.
- Use debug geography and test device IDs during development.
- Do not call consent reset in production UI.

**Reason**: Consent state can expire or change. Relying on local cached consent strings is fragile and can create compliance problems.

## Project Structure

```text
lib/monetization/
├── cubit/
│   ├── monetization_cubit.dart
│   └── monetization_state.dart
├── models/
│   ├── ai_quota_policy.dart
│   ├── ad_frequency_cap.dart
│   ├── ad_placement_policy.dart
│   ├── consent_state.dart
│   ├── entitlement_snapshot.dart
│   ├── monetization_plan.dart
│   └── rewarded_ad_credit.dart
├── repositories/
│   ├── entitlement_repository.dart
│   └── monetization_policy_repository.dart
├── services/
│   ├── ad_consent_service.dart
│   ├── ad_service.dart
│   ├── feature_gate_service.dart
│   └── purchase_service.dart
└── widgets/
    ├── adaptive_banner_ad_slot.dart
    ├── interstitial_ad_gate.dart
    └── rewarded_ai_credit_button.dart

lib/screens/monetization/
├── views/
│   └── free_premium_screen.dart
└── widgets/
    ├── current_plan_badge.dart
    ├── plan_comparison_table.dart
    ├── plan_feature_row.dart
    ├── quota_usage_card.dart
    └── premium_cta_panel.dart

lib/screens/settings/widgets/
└── monetization_settings_section.dart

test/monetization/
├── feature_gate_service_test.dart
├── monetization_cubit_test.dart
├── ad_frequency_cap_test.dart
└── free_premium_screen_test.dart
```

**Structure Decision**: Keep all monetization logic away from expense repositories and AI parsing code. Expense features ask `FeatureGateService`; they should not know how ads, Premium, or purchases work.

## Data Model

### EntitlementSnapshot

- `tier`: free, premium, unknown, pending.
- `source`: localDefault, firestore, worker, storeSandbox, storeVerified.
- `expiresAt`: nullable for active subscription expiry.
- `graceUntil`: nullable for temporary access during restore/verification delay.
- `isVerified`: true only when trusted backend/store verification succeeded.
- `updatedAt`.
- `reason`: optional debug string for UI/dev logs.

### AiQuotaPolicy

- `textParseDailyLimit`.
- `receiptDailyLimit`.
- `adviceDailyLimit`.
- `rewardedParseDailyLimit`.
- `rewardedReceiptDailyLimit`.
- `rewardedAdviceDailyLimit`.
- `tier`.
- `effectiveFrom`.

### AdPlacementPolicy

- `placementKey`: homeBanner, expensesBanner, reportsBanner, exportInterstitial, postSaveInterstitial, aiRewarded.
- `format`: banner, interstitial, rewarded, native.
- `enabledForFree`.
- `enabledForPremium`.
- `minimumIntervalMinutes`.
- `requiredCompletedActions`.
- `blockedRoutes`.

### ConsentState

- `canRequestAds`.
- `privacyOptionsRequired`.
- `statusLabel`.
- `lastUpdatedAt`.
- `isDebugGeographyEnabled`.
- `errorMessage`.

## Feature Gate Rules

`FeatureGateService` should answer questions like:

- Can this user request AI parse?
- Should this screen reserve banner space?
- Can an interstitial be shown now?
- Can rewarded ad grant another credit today?
- Should Premium CTA be shown?
- Is a Premium-only feature allowed or should the app show upgrade UI?

**Reason**: Centralized gates prevent random screens from duplicating fragile plan logic.

## Purchase Strategy

### Phase A - No Real Purchase Yet

- Build Free/Premium UI.
- Show current plan as Free.
- Add "Premium coming soon" or disabled sandbox CTA.
- Ads and quotas work for Free.
- Feature gates are ready for Premium state.

### Phase B - Store Products Ready

- Add `in_app_purchase`.
- Configure Google Play and App Store products with matching product IDs.
- Listen to purchase stream at app startup.
- Add restore purchases.
- Send purchase token/receipt to trusted endpoint for verification.
- Store verified entitlement under user account.

### Phase C - Entitlement Verification

- Add Cloudflare Worker endpoint for purchase verification if avoiding Firebase Functions.
- Worker verifies with Google/Apple APIs using secrets stored in Worker environment.
- Worker writes or returns verified entitlement.
- Flutter trusts only verified entitlement, not raw local purchase success.

**Reason**: Client-only Premium flags are not reliable and cannot handle refunds, cancellations, restore, or multi-device use safely.

## Ads Strategy

### Initial SDK Choice

Use `google_mobile_ads` because it is the official Google Mobile Ads Flutter plugin and supports AdMob formats needed here.

### Debug And Production IDs

- Debug builds use Google test ad unit IDs.
- Production app ID and ad unit IDs are passed through environment/config.
- Do not commit real production IDs if the project policy prefers private config.
- App IDs are not true secrets, but keeping config centralized prevents mistakes.

### Initialization Flow

1. Load signed-in user.
2. Load entitlement snapshot.
3. If Premium: do not initialize or request ads.
4. If Free: run consent info update.
5. If consent allows ad requests: initialize Mobile Ads SDK and load allowed placements.
6. If consent blocks ads: leave reserved slots empty or show no-ad fallback.

## UI/UX Guidance

### Free/Premium Screen

The screen should be useful, not a marketing landing page:

- Current plan badge at top.
- AI usage card with today limits.
- Two-column comparison table or segmented comparison.
- "Free keeps working" note near Free plan.
- Premium CTA that is honest about current availability.
- Restore purchases button only when purchase integration exists.
- Privacy/ad choices link if required.

### Ads UI

- Reserve exact banner height to prevent layout jump.
- Use subtle loading skeleton or empty space; do not show fake ad content.
- Never put ad cards inside other cards.
- Keep ads outside primary form controls.

## Risks And Mitigations

- **Risk**: AdMob account is not approved or app is not store-listed.  
  **Mitigation**: Use test ads until readiness is complete and do not block app behavior on real ads.

- **Risk**: Premium implementation becomes insecure if only local flags are used.  
  **Mitigation**: Ship UI with local free state first; require trusted verification before real Premium unlock.

- **Risk**: Ads annoy users during expense entry.  
  **Mitigation**: Block ads in critical contexts and enforce frequency caps.

- **Risk**: Consent flow is implemented incorrectly.  
  **Mitigation**: Follow official UMP flow and add debug geography QA steps.

- **Risk**: Premium says "unlimited AI" but API quota/cost cannot support it.  
  **Mitigation**: Use higher but finite limits and reserve "unlimited" for a future backend-backed plan.

## Verification

```text
flutter pub get
flutter analyze
flutter test test/monetization
flutter test
```

Manual QA:

1. Free user sees Free/Premium screen and plan comparison.
2. Free user sees banner slot only on allowed screens.
3. Free user never sees interstitial during add expense or AI preview.
4. Free user reaches AI quota limit and gets manual fallback.
5. Rewarded ad grants at most allowed extra credit.
6. Premium entitlement fixture disables all ad requests.
7. UMP debug EEA flow shows privacy message and settings entry.
8. Offline mode keeps core expense entry available.

## Research Notes

- Flutter's ads overview states the Google Mobile Ads SDK for Flutter supports AdMob/Ad Manager and formats including banner, interstitial, native, rewarded, and rewarded interstitial.
- Flutter's Google Mobile Ads cookbook shows app ID setup, `google_mobile_ads`, SDK initialization, and ad unit configuration.
- Google AdMob Flutter setup documents that Android needs `com.google.android.gms.ads.APPLICATION_ID`, iOS needs `GADApplicationIdentifier`, and the SDK should be initialized before loading ads.
- Google UMP docs require requesting updated consent information, showing required forms, exposing privacy options when required, and checking `canRequestAds()` before ad requests.
- `in_app_purchase` provides a store-independent Flutter API for App Store/Google Play purchases, but store setup and entitlement verification still need product and backend policy work.
