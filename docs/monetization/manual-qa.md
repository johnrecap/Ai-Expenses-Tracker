# Monetization Manual QA

These checks are intentionally manual because ads, consent, billing, and store
verification depend on device and build configuration.

## Android Internal Debug With Test Ads

1. Build and run an internal/debug Android install with AdMob test IDs only.
2. Open Home and verify the banner appears below the monthly summary without
   covering budget, engagement, or transaction content.
3. Open Expenses and verify search, filters, reset, empty state, and list
   scrolling remain usable with and without the banner.
4. Open Reports and verify charts, legends, range controls, and empty reports
   remain readable with and without the banner.
5. Deny or make consent unavailable and confirm all banner slots collapse safely.
6. Use a Premium entitlement fixture and confirm banners, interstitials, and
   rewarded ads are not requested.

## Interstitial Safety Checks

1. Complete an export and verify any interstitial eligibility happens only after
   the file is generated and the success message is shown.
2. Save expenses repeatedly and verify any post-save interstitial happens only
   after the saved expense returns to Home and the configured threshold is met.
3. Confirm interstitials never appear on login, registration, app lock, add
   expense entry, AI preview/confirmation, or purchase/restore flows.
4. Force ad load failures and verify export/save results are unchanged.

## Rewarded AI Credit Checks

1. Exhaust a Free AI quota and request a rewarded credit.
2. Confirm no credit is added if the rewarded ad fails, is unavailable, or no
   reward callback fires.
3. Confirm one temporary AI credit is added only after the reward callback.

## Purchase Checks

1. Open Free / Premium and verify purchase CTAs say purchases are coming soon or
   unavailable.
2. Tap upgrade and restore and confirm no real charge is started.
3. Confirm Premium active appears only from an injected or future verified
   entitlement source.
