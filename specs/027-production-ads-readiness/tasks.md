# Tasks: Production Ads Readiness

**Input**: `specs/027-production-ads-readiness/spec.md`, `plan.md`  
**Implementation Intent**: Ship real, polite, consent-aware ads for Free users while guaranteeing Premium is ad-free.

## Phase 1: Confirm Existing Foundation

- [X] T001 Audit `lib/monetization/services/ad_service.dart` and related abstractions.

  **Why**: Real plugin code must wrap existing interfaces, not bypass them.
  **Steps**:
  1. Inspect `AdService`, fake implementations, and `AdConsentService`.
  2. Check whether method signatures cover banner, interstitial, rewarded, initialize, and dispose.
  3. Record missing methods before adding plugin-specific code.
  4. Confirm tests can use fakes without importing the plugin.
  **Done when**: The abstraction supports all required ad types.

- [X] T002 Audit ad placement policy and blocked routes.

  **Why**: Ads must be governed centrally.
  **Steps**:
  1. Inspect `AdPlacementPolicy` and `FeatureGateService`.
  2. List allowed screens: Home, Expenses, Reports, post-export, rare post-save.
  3. List blocked screens: Auth, Add Expense, AI preview/confirm, App Lock, purchase, recovery.
  4. Add missing route/context identifiers to the policy model.
  **Done when**: The policy can express every intended placement.

## Phase 2: SDK And Platform Configuration

- [X] T003 Add `google_mobile_ads` dependency to `pubspec.yaml`.

  **Why**: This is the official Flutter SDK for AdMob.
  **Steps**:
  1. Add the dependency with a compatible version.
  2. Run `flutter pub get`.
  3. Confirm generated lockfile changes are limited.
  4. Run `flutter analyze` after dependency resolution.
  **Done when**: The project resolves the SDK without unrelated upgrades.

- [X] T004 Configure Android AdMob app ID safely.

  **Why**: Android requires app ID metadata before ad SDK initialization.
  **Steps**:
  1. Add manifest metadata for AdMob app ID.
  2. Use the official test app ID for debug if production ID is not ready.
  3. Document where release ID must be supplied.
  4. Ensure missing release config disables ads or fails with clear developer diagnostic.
  **Done when**: Android debug can initialize with test config.

- [X] T005 [P] Prepare iOS AdMob app ID configuration if iOS release remains in scope.

  **Why**: Multi-platform project folders exist and iOS should not be left broken silently.
  **Steps**:
  1. Add or document `GADApplicationIdentifier` in `ios/Runner/Info.plist`.
  2. Use official test app ID for debug.
  3. Document production value replacement.
  4. If iOS is deferred, explicitly mark it deferred in docs.
  **Done when**: iOS status is explicit and not guessed by future workers.

## Phase 3: Real Ad Service

- [X] T006 Implement `GoogleMobileAdsService` behind `AdService`.

  **Why**: Plugin-specific calls must stay out of widgets and Cubits where possible.
  **Steps**:
  1. Wrap Mobile Ads initialization.
  2. Implement banner load/dispose.
  3. Implement interstitial load/show/dispose.
  4. Implement rewarded load/show/dispose.
  5. Normalize plugin errors into app-safe ad failures.
  **Done when**: Screens can use real ads through `AdService`.

- [X] T007 Wire consent-before-request behavior.

  **Why**: Ads cannot be requested before consent requirements are satisfied.
  **Steps**:
  1. Use `AdConsentService` during monetization/ad startup.
  2. Block ad load when `canRequestAds` is false.
  3. Expose privacy options row through Settings when required.
  4. Add debug consent controls only in debug builds.
  **Done when**: Ad requests are gated by consent state.

- [X] T008 Ensure Premium skips all ad initialization.

  **Why**: No-ads promise must be enforced before plugin calls.
  **Steps**:
  1. In startup orchestration, load entitlement before initializing ads.
  2. If Premium, do not initialize Mobile Ads.
  3. Clear/dispose any existing ad slots on upgrade or entitlement refresh.
  4. Add fake service assertions in tests.
  **Done when**: Premium fixture produces zero ad service calls.

## Phase 4: Placements

- [X] T009 Add Home banner placement.

  **Why**: Home is high visibility but primary finance data must remain clear.
  **Steps**:
  1. Add an adaptive banner slot in a reserved bottom or between-section area.
  2. Do not cover total balance, add expense, bottom navigation, or AI controls.
  3. Hide the slot for Premium or ad-unavailable state.
  4. Verify small phone layout.
  **Done when**: Home remains usable with and without test banner.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037; `MainScreen`
  now renders `MonetizationBannerAdSlot` for `AdPlacementKey.homeBanner`.

- [X] T010 Add Expenses list banner placement.

  **Why**: Reading/list surfaces can host passive ads without interrupting entry.
  **Steps**:
  1. Place banner after a stable list segment or at the bottom.
  2. Keep item heights stable.
  3. Verify empty, short, and long list states.
  4. Hide for Premium.
  **Done when**: Expenses screen scroll behavior remains normal.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037; `ExpensesScreen`
  now renders `MonetizationBannerAdSlot` for `AdPlacementKey.expensesBanner`.

- [X] T011 Add Reports/Stats banner placement.

  **Why**: Reports are reading-oriented and can support passive ads below content.
  **Steps**:
  1. Place banner below chart content or in a reserved bottom area.
  2. Do not cover chart gestures or labels.
  3. Verify with weekly and monthly modes.
  4. Hide for Premium.
  **Done when**: Charts remain readable with test ads.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037; Reports now render
  the passive monetization banner below report content.

- [X] T012 Add conservative post-export interstitial hook.

  **Why**: Export success is a natural completion moment after value is delivered.
  **Steps**:
  1. Hook after export success only.
  2. Do not show before export begins or on export failure.
  3. Respect route blocklist, consent, Free/Premium, and frequency caps.
  4. Log debug-only reason when blocked.
  **Done when**: Interstitial appears only after successful export and only when eligible.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037 through the shared
  interstitial gate and export completion hook.

- [X] T013 Add rare post-save interstitial hook.

  **Why**: Expense save can be a completion moment, but frequent tracking must not be interrupted.
  **Steps**:
  1. Count successful saves since last interstitial.
  2. Consider showing only after at least five successful saves.
  3. Show after returning to Home/List, never while the form is visible.
  4. Respect 10-minute and session caps.
  **Done when**: Repeated expense entry remains smooth.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037; Home records a
  completed save only after Add Expense returns a saved expense.

- [X] T014 Complete rewarded ad credit flow for AI.

  **Why**: Free users can earn limited extra AI usage without payment.
  **Steps**:
  1. Show rewarded button only when policy allows and quota is low/exhausted.
  2. Load rewarded ad only after explicit tap.
  3. Grant credit only from reward callback.
  4. Persist credit with expiry and per-day cap.
  5. Refresh quota UI after credit grant.
  **Done when**: One rewarded view grants exactly one allowed credit.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037; rewarded AI credit
  goes through `MonetizationCubit.requestRewardedCredit` and the reward callback.

## Phase 5: Tests And QA

- [X] T015 [P] Add fake ad service tests for Premium zero-call behavior.

  **Why**: This is the most important monetization promise.
  **Steps**:
  1. Create a fake service that records calls.
  2. Start monetization with Premium fixture.
  3. Navigate/render ad-capable screens.
  4. Assert no initialize/load/show calls occurred.
  **Done when**: Premium no-ads guarantee is test-covered.
  **Status note (Plan 040 cleanup)**: Covered by monetization/ad tests added in
  Plans 027 and 037 with fake ad services.

- [X] T016 [P] Add ad slot widget tests.

  **Why**: Banner layout must stay stable.
  **Steps**:
  1. Test Free slot reserves expected height.
  2. Test Premium hides slot.
  3. Test failed load does not crash.
  4. Test screen remains scrollable.
  **Done when**: Banner UI behavior is deterministic.
  **Status note (Plan 040 cleanup)**: Covered by `test/monetization/ad_widgets_test.dart`.

- [X] T017 [P] Add interstitial gate tests.

  **Why**: Interstitial abuse is a retention and policy risk.
  **Steps**:
  1. Test blocked critical routes.
  2. Test 10-minute cap.
  3. Test session cap.
  4. Test post-save threshold.
  5. Test export success eligibility.
  **Done when**: Interstitials cannot appear outside policy.
  **Status note (Plan 040 cleanup)**: Covered by monetization frequency/gate tests.

- [ ] T018 Run Android debug QA with test ads.

  **Status note (Plan 040 cleanup)**: Still open. This requires a real Android
  debug/internal run with AdMob test ads and consent behavior, so it remains in
  `docs/implementation_plans/deferred-and-advanced-work.md`.

  **Why**: Plugin, manifest, and consent behavior require device validation.
  **Steps**:
  1. Build/install debug app with test IDs.
  2. Sign in as Free user.
  3. Visit Home, Expenses, Reports, Add Expense, AI Assistant, Settings.
  4. Confirm ads only appear where approved.
  5. Confirm Premium fixture disables ads.
  **Done when**: Device behavior matches policy.

- [X] T019 Document AdMob release checklist.

  **Why**: Real ad serving depends on external account setup.
  **Steps**:
  1. List AdMob account/app creation steps.
  2. List ad unit IDs required.
  3. List app-ads.txt/privacy message requirements.
  4. Explain test IDs must be used until approval.
  5. Explain expected delay before real ads serve.
  **Done when**: The user can finish external setup without code guessing.
