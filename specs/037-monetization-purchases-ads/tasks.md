# Tasks: Monetization Purchases And Ads Production

**Input**: `specs/037-monetization-purchases-ads/spec.md`, `plan.md`  
**Implementation Intent**: Complete production-safe monetization behavior while preserving trust and core finance usability.

## Phase 1: Monetization State Truth

- [X] T001 Review current `lib/monetization/` policy, entitlement, consent, ad, and purchase services.

  **Why**: Several foundations exist, but open tasks indicate placements and purchase flow are incomplete.
  **Steps**:
  1. Map `MonetizationCubit` state fields to Free/Premium screen UI.
  2. Map `FeatureGateService` ad and quota decisions.
  3. Identify any widgets using direct `isPremium` or quota math outside the service layer.
  4. Document current fake/unavailable purchase behavior.
  **Done when**: A developer knows which existing services to extend and which shortcuts to avoid.

- [X] T002 Update Free/Premium screen copy and state handling.

  **Why**: Users must understand current limits and whether purchases are live.
  **Steps**:
  1. Show Free daily limits for parse/advice/receipt.
  2. Show quota reset information when available.
  3. Show Premium benefits without promising active payment if purchase verification is unavailable.
  4. Localize all new text through l10n if Plan 036 has run; otherwise add keys in this plan.
  **Done when**: The page is honest for Free, Premium, and purchase-unavailable states.

- [X] T003 Add tests for Free/Premium state rendering.

  **Why**: Monetization mistakes are easy to regress and can mislead users.
  **Steps**:
  1. Test Free plan shows limits and ads possible.
  2. Test Premium hides ads and quota limits.
  3. Test purchase unavailable message.
  4. Test quota exhausted CTA does not block manual tracking.
  **Done when**: Plan state behavior is covered by widget/Cubit tests.

## Phase 2: Banner Ad Placements

- [X] T004 Add Home banner placement through monetization widgets.

  **Why**: Home is a stable, high-visibility surface, but ads must not crowd finance summary.
  **Steps**:
  1. Place banner below primary summary/actions, not inside nested cards.
  2. Reserve stable height only when feature gate allows banner.
  3. Hide banner for Premium or no-consent states.
  4. Ensure scroll layout works on small screens.
  **Done when**: Home can show a banner without overlap or layout shift.

- [X] T005 Add Expenses list banner placement.

  **Why**: Expenses is a repeat-use list screen suitable for a non-intrusive banner.
  **Steps**:
  1. Add banner outside critical filter controls.
  2. Keep empty state readable when banner is hidden or fails.
  3. Confirm filter/reset actions stay accessible.
  **Done when**: Expenses banner is safe and consent-aware.

- [X] T006 Add Reports/Stats banner placement.

  **Why**: Reports are review surfaces and less risky than entry/confirmation screens.
  **Steps**:
  1. Place banner after key report summary or at bottom of scroll.
  2. Keep charts and legends unclipped.
  3. Hide for Premium/no-consent.
  **Done when**: Reports banner does not interfere with chart readability.

- [X] T007 Add banner widget tests.

  **Why**: Banner slots can cause layout issues or call ad service when they should not.
  **Steps**:
  1. Test Free/consent allowed reserves slot.
  2. Test Premium hides slot.
  3. Test consent denied/unavailable hides or safe-fails.
  4. Test failed ad load does not crash.
  **Done when**: Banner placement rules are automated.

## Phase 3: Interstitial And Rewarded Ads

- [X] T008 Add conservative post-export interstitial hook.

  **Why**: Export completion is a non-critical moment after user value is delivered.
  **Steps**:
  1. Trigger eligibility only after export succeeds or share completes.
  2. Use `InterstitialAdGate`/feature gate, not direct ad plugin calls.
  3. Respect frequency caps, Premium, consent, and critical route blocking.
  4. Never show before export starts.
  **Done when**: Interstitial can appear only after safe completion and only when eligible.

- [X] T009 Add rare post-save interstitial hook after repeated saves.

  **Why**: Save flow is sensitive; if used, interstitial must be rare and never block saving.
  **Steps**:
  1. Increment eligible counter after expense save succeeds.
  2. Show interstitial only after configured threshold and outside confirmation/AI preview.
  3. Reset/update counters through monetization state.
  4. Ensure ad failure has no effect on saved expense.
  **Done when**: Saving expenses never depends on ad success.

- [X] T010 Complete rewarded AI credit flow.

  **Why**: Rewarded ads can help Free users get extra AI actions without paying, but only after reward callback.
  **Steps**:
  1. Request rewarded ad only when consent and gate allow it.
  2. Grant temporary AI credit only inside reward callback.
  3. Show clear message when reward is unavailable.
  4. Refresh quota/monetization state after credit.
  **Done when**: Rewarded credit cannot be granted by tapping a button alone.

- [X] T011 Add interstitial and rewarded tests.

  **Why**: Frequency caps and reward callback rules are monetization-critical.
  **Steps**:
  1. Test critical routes block interstitial.
  2. Test session/time caps.
  3. Test export/save hooks do not show ads before value is delivered.
  4. Test rewarded credit only after callback.
  **Done when**: Ad gating behavior is covered.

## Phase 4: Purchase Path

- [X] T012 Decide and document the first real purchase verification architecture in `docs/monetization/premium-verification.md`.

  **Why**: Flutter must not permanently unlock Premium from client-side purchase state alone.
  **Steps**:
  1. Document short-term state: purchases unavailable or sandbox-only.
  2. Document future verified entitlement source: Firebase/Cloudflare/backend/store server verification.
  3. Document what Flutter can store locally: temporary UI state only, not trusted entitlement.
  4. Document restore purchases expectations.
  **Done when**: Future purchase work has a safe architecture boundary.

- [X] T013 Keep purchase CTAs production-honest until verification exists.

  **Why**: Users should not think they can pay if real billing is not active.
  **Steps**:
  1. Ensure purchase buttons either hide, show "coming soon", or run sandbox flow clearly.
  2. Avoid fake "Premium active" state after unavailable purchase.
  3. Keep restore purchases honest.
  **Done when**: No button implies a real charge or permanent unlock unless verification is implemented.

## Phase 5: Android QA And Verification

- [ ] T014 Run Android debug/internal QA with AdMob test ads.

  **Why**: Ad behavior depends on device, consent region, and plugin integration.
  **Steps**:
  1. Build/run with test ad IDs.
  2. Verify consent flow.
  3. Open Home, Expenses, Reports, Export, AI quota/reward surfaces.
  4. Confirm no ads show on login, app lock, AI confirmation, or expense save before completion.
  **Done when**: Test ads work in safe places and fail safely elsewhere.

- [X] T015 Run `flutter analyze` and full Flutter tests.

  **Why**: Monetization touches shared state and UI.
  **Steps**:
  1. Run analyzer.
  2. Run full Flutter tests.
  3. Fix regressions introduced by this plan.
  **Done when**: Existing and new monetization tests pass.
  **Parent verification (2026-05-18)**: `flutter analyze` passed with no issues. Targeted monetization tests passed, and the full Flutter suite passed: 233 tests.

- [ ] T016 Build a release/internal APK with test ads or configured production ids.

  **Why**: Manifest placeholders and mobile ads integration must package correctly.
  **Steps**:
  1. Build APK with current safe config.
  2. Confirm manifest placeholder does not break launch.
  3. Record whether artifact is internal-test or production-ready.
  **Done when**: Android artifact builds and ad config state is documented.

## Dependencies & Execution Order

- T001 blocks all monetization edits.
- T002 and T003 can run before placements.
- T004 to T006 can run in parallel if files do not conflict.
- T008 to T010 depend on T001 and existing ad services.
- T012 should happen before any real purchase implementation.

## Suggested MVP

Complete T001 to T007 and T012 to T015 first. This gives honest Free/Premium state and safe banner monetization without risky purchase promises.

## Worker 037 Completion Notes

- T001: Reviewed monetization Cubit/state, feature gates, policy/entitlement repositories, consent/ad/purchase services, existing widgets, and monetization tests. Decisions remain centralized through `MonetizationCubit`, `FeatureGateService`, `AdService`, and `AdConsentService`.
- T002: Existing Free/Premium screen already shows Free/Premium state, quota usage/reset text when available, consent/ad behavior, Free-safe messaging, and purchase-unavailable CTA copy. No real purchase or permanent client unlock was added.
- T003: Existing Free/Premium/Cubit tests cover Free, Premium, quota, and purchase-unavailable rendering paths. Tests were not run by Worker 037 per instruction.
- T004-T006: Added shared `MonetizationBannerAdSlot` and placed banners on Home, Expenses, and Reports in passive scroll/list locations.
- T007: Added banner wrapper widget coverage for consent-allowed reservation and consent-unavailable hiding. Tests were not run by Worker 037 per instruction.
- T008: Added `MonetizationCubit.maybeShowInterstitial()` and called it only after `ExportSuccess` shows the generated file message.
- T009: Added `recordCompletedSaveAndMaybeShowInterstitial()` and called it only after `AddExpense` returns a saved expense and Home refresh is triggered.
- T010: Existing rewarded flow grants credit only after `showRewarded` invokes the reward callback; Worker 037 did not add any tap-only credit path.
- T011: Added Cubit tests for post-export and post-save interstitial hooks; existing tests cover critical-route blocking, frequency caps, and rewarded callback behavior. Tests were not run by Worker 037 per instruction.
- T012: Added `docs/monetization/premium-verification.md`.
- T013: Purchase CTAs remain unavailable/coming-soon through `DisabledPurchaseService` and `PremiumCtaPanel`; no billing implementation or fake Premium unlock was added.
- T014 blocker: Not run because Worker 037 was instructed not to run builds/tests. Added `docs/monetization/manual-qa.md` for Android internal/test-ad QA.
- T015 parent verification: `flutter analyze`, targeted monetization tests, and the full Flutter suite passed after parent review.
- T016 blocker: Not run because Worker 037 was instructed not to run builds. Production ad IDs remain external via dart-defines; no production IDs were committed.
