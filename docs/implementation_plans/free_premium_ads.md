# Free/Premium And Ads Implementation Notes

Plan: `specs/023-free-premium-ads`

## What Was Implemented In The Foundation

- `lib/monetization/models` contains typed plan, entitlement, quota, ad placement, consent, reward, and frequency-cap models.
- `FeatureGateService` is the single place for plan decisions:
  - manual tracking remains enabled;
  - Premium disables ads;
  - AI quota exhaustion blocks only the relevant AI action;
  - critical routes block interstitials;
  - rewarded credits are capped.
- `MonetizationPolicyRepository` returns local defaults:
  - text parse: 5/day for Free;
  - receipt extraction: 3/day for Free;
  - advice: 3/day for Free;
  - rewarded credits: small and capped.
- `EntitlementRepository` currently has a local default implementation. Real Premium must later come from a trusted backend/store verification path.
- `AdService`, `AdConsentService`, and `PurchaseService` are abstractions with fake/disabled implementations so UI and tests can be built before adding SDKs.
- `FreePremiumScreen` explains the active plan, AI usage, ad behavior, Premium benefits, and the current honest "coming soon" purchase state.
- `MonetizationSettingsSection` is ready to be inserted into Settings after Plan 021 finishes its settings changes.

## Deliberately Deferred

- No `google_mobile_ads` dependency was added in this phase because the agent was instructed not to run `pub get`.
- No `in_app_purchase` dependency was added in this phase for the same reason.
- No Android/iOS AdMob app IDs were added. Use test IDs only when the SDK phase starts.
- No production ad unit IDs or purchase secrets were added to Flutter code.
- No real store purchase flow was enabled. The current purchase service always returns an unavailable/coming-soon state.
- No direct edits were made to `settings_screen.dart` to avoid conflicts with Plan 021.
- No ad placements were inserted into Home, Expenses, or Reports yet because those screens are likely touched by Plans 021 and 022. Use `AdaptiveBannerAdSlot` after those plans are merged.

## Worker Entitlement Verification Contract Draft

Future endpoint: `POST /v1/entitlements/verifyPurchase`

Request:

```json
{
  "platform": "android | ios",
  "productId": "premium_monthly",
  "purchaseToken": "store_token_or_receipt",
  "packageName": "com.saeeddevstudio.ai_expenses_tracker"
}
```

Headers:

- `Authorization: Bearer <Firebase ID token>`

Success:

```json
{
  "tier": "premium",
  "source": "storeVerified",
  "isVerified": true,
  "expiresAt": "2026-06-17T00:00:00.000Z",
  "updatedAt": "2026-05-17T00:00:00.000Z"
}
```

Failure:

```json
{
  "tier": "free",
  "source": "worker",
  "isVerified": false,
  "errorCode": "purchase_verification_failed",
  "message": "Purchase could not be verified."
}
```

## Release Setup Checklist

1. Create AdMob apps for Android and iOS.
2. Create banner, interstitial, and rewarded ad units.
3. Keep test ad unit IDs in debug builds until account/app approval is complete.
4. Add Android `com.google.android.gms.ads.APPLICATION_ID` and iOS `GADApplicationIdentifier` only when the SDK is installed.
5. Configure UMP privacy messages and test EEA debug geography.
6. Create Google Play and App Store subscription products matching `premium_monthly` and `premium_yearly`, or update the constants before release.
7. Implement Worker purchase verification with Google/Apple secrets stored only in Worker environment.
8. Store verified entitlement under the user account or return it from the Worker with Firebase-authenticated access.

## Merge Note

When Plan 021 completes Settings work, insert `MonetizationSettingsSection` into the Settings list and provide it with `MonetizationCubit` state. Do not duplicate plan logic inside Settings widgets.
