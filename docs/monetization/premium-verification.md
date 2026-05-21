# Premium Verification Architecture

## Current State

Premium purchases are intentionally unavailable in the Flutter client. The
current `DisabledPurchaseService` can show products and honest CTA messaging,
but it must not charge users, restore purchases, or grant a permanent Premium
entitlement.

The app may display Premium fixture state only when an injected
`EntitlementRepository` returns a verified Premium snapshot for tests or future
trusted sources. Flutter must treat local purchase state as untrusted until a
backend verifies it.

## Premium Benefit Matrix

These benefits are the approved paid-launch target for UI copy, policy
fixtures, and backend entitlement responses. The app should keep displaying
conservative "not available yet" purchase messaging until the verification
backend is deployed.

| Surface | Free | Premium | Launch requirement |
| --- | --- | --- | --- |
| Manual expense tracking | Included | Included | Must never depend on ads, AI quota, or purchases. |
| Categories and budgets | Included | Included | Core finance remains Free. |
| Basic reports | Included | Included | Local reports keep working when monetization fails. |
| Exports | Basic export flow | Larger ranges and export templates | Premium template/range enforcement must go through `FeatureGateService`. |
| Ads | Consent-aware passive ads | No ads | `EntitlementSnapshot.shouldDisableAds` must suppress all ad placements. |
| AI text parse | 5/day policy default | 100/day policy default | Worker quota remains authoritative. |
| Receipt extraction | 3/day policy default | 30/day policy default | Receipt images still follow local compression and no-storage rules. |
| Financial advice | 3/day policy default | 30/day policy default | Advice remains user-triggered and grounded in local summaries. |
| Smart budgets | Local baseline recommendations | Premium advanced budget insights | Advanced rules require a later product/backend policy pass before enforcement. |

Premium limits are finite by design. They are policy defaults until the trusted
backend returns live usage and entitlement metadata.

## Required Trusted Entitlement Source

A production purchase flow needs a trusted entitlement service before any real
Premium unlock ships. The selected first path is a Cloudflare Worker entitlement
endpoint because the project already uses a Worker for authenticated quota and
provider calls, keeps secrets out of Flutter, and can share operational
patterns for Firebase token verification. Firebase Functions remains a fallback
if store-verification SDK support or deployment ownership makes it preferable.

Acceptable implementation requirements:

- Firebase or Cloudflare endpoint that receives a store purchase token.
- Server-side verification with Google Play Billing or App Store Server APIs.
- Entitlement persistence keyed by authenticated Firebase user id.
- Flutter refresh through `EntitlementRepository.refreshEntitlement()` after
  backend verification completes.
- Verification, restore, and refresh contract under
  `specs/074-premium-entitlement-backend/contracts/entitlement-api.md`.

The backend response should return only entitlement state, source, freshness,
plan tier, and expiry/renewal metadata needed by the app. It must not expose
store API secrets or signing keys to Flutter.

## Flutter Storage Boundary

Flutter may store:

- Temporary UI state for a purchase attempt.
- The last trusted entitlement snapshot returned by the backend.
- Non-sensitive product display metadata from the store.

Flutter must not store:

- Purchase verification secrets.
- Google Play or App Store server credentials.
- A permanent Premium unlock based only on a client purchase callback.
- A manually editable local flag that disables ads or removes quotas.

## Purchase And Restore Expectations

`buyPremium()` should start a store purchase only after the backend contract is
available. After the store returns a token, Flutter sends it to the trusted
backend and waits for a verified entitlement before showing Premium active.

`restorePurchases()` should follow the same rule: restored store tokens are sent
to the backend, and Premium is shown only after the entitlement repository
refreshes from trusted verification.

Until that exists, purchase and restore CTAs should remain honest: coming soon,
sandbox-only, or unavailable. They must not imply that tapping the button makes a
real charge or unlocks Premium.

## Server-Owned States

The client-side `VerifiedEntitlement` and `PurchaseVerificationResult` models
mirror the backend contract but do not make trust decisions alone. Active and
grace-period Premium states are Premium only when returned by a trusted source.
Expired, refunded, revoked, unavailable, invalid, and not-found states resolve
to Free-safe behavior.

## External Paid-Launch Work

The following work remains blocked on production setup and must not be faked in
Flutter:

- Google Play Billing/App Store product setup.
- Store API credentials and webhook secrets.
- Server entitlement persistence and restore deployment.
- Production AdMob IDs and consent-region QA.
- Store refund, revocation, expiry, and new-device restore validation.
