# Tasks: Free/Premium Monetization And Ads

**Input**: `specs/023-free-premium-ads/spec.md`, `plan.md`  
**Implementation Intent**: Build the monetization foundation, Free/Premium screen, safe ads architecture, and future purchase hooks without breaking the free core app.

## Phase 1: Audit Existing App And Decide Feature Boundaries

- [X] T001 Audit current AI quota, Worker limits, and app-side AI error states.

  **Why**: The Free/Premium screen must show real usage and not invent limits that differ from the Worker.
  **Steps**:
  1. Inspect `workers/ai-gateway` daily limit env names and response payloads.
  2. Inspect Flutter AI service/cubit models for quota fields and errors.
  3. Record current Free defaults: text parse 5/day, receipt 3/day, advice 3/day.
  4. Identify whether quota usage is returned to Flutter or needs a new endpoint/field.
  **Done when**: A developer knows exactly where quota is enforced and what UI can show today.

- [X] T002 Audit all screens that could contain ads.

  **Why**: Ads must be placed deliberately, not scattered randomly.
  **Steps**:
  1. Review Home, Expenses/transactions list, Stats/Reports, Export, Add Expense, AI Assistant, Auth, Settings, and App Lock screens.
  2. Mark each screen as allowed, blocked, or conditional for ads.
  3. Confirm blocked screens include Add Expense, AI preview/confirmation, Auth, App Lock, and purchase flow.
  4. Record natural completion moments where interstitials might be acceptable.
  **Done when**: There is a placement map matching `AdPlacementPolicy`.

- [X] T003 Define the first public Free and Premium benefit matrix.

  **Why**: Product copy drives code gates. If benefits are vague, implementation will become inconsistent.
  **Steps**:
  1. Define Free enabled features.
  2. Define Premium benefits without saying "unlimited AI".
  3. Decide which advanced features are Premium later versus Free now.
  4. Write the exact short labels that should appear in the comparison table.
  **Done when**: UI, gates, and future store products use the same benefit list.

## Phase 2: Monetization Models And Policy Layer

- [X] T004 Create monetization model folder under `lib/monetization/models`.

  **Why**: Plan, quota, ad, consent, and entitlement data should have typed models rather than loose maps.
  **Steps**:
  1. Add `monetization_plan.dart` with `PlanTier`.
  2. Add `entitlement_snapshot.dart`.
  3. Add `ai_quota_policy.dart`.
  4. Add `ad_placement_policy.dart`.
  5. Add `ad_frequency_cap.dart`.
  6. Add `rewarded_ad_credit.dart`.
  7. Add `consent_state.dart`.
  **Done when**: Models can express Free, Premium, pending, quota, ad placements, rewards, and consent.

- [X] T005 Create `FeatureGateService`.

  **Why**: Screens should ask one service whether a feature is allowed instead of duplicating plan logic.
  **Steps**:
  1. Add methods for AI parse, receipt AI, AI advice, ads visibility, interstitial eligibility, rewarded credit eligibility, export/report depth, and Premium CTA visibility.
  2. Make methods depend on `EntitlementSnapshot`, `AiQuotaPolicy`, usage, consent, and frequency cap state.
  3. Default unknown entitlement to Free-safe behavior, not Premium.
  4. Ensure Premium disables ad visibility.
  **Done when**: Unit tests can evaluate gates without Flutter widgets or ad SDK.

- [X] T006 Create `MonetizationPolicyRepository`.

  **Why**: Limits and placements will change over time, and code should not hardcode every policy inside widgets.
  **Steps**:
  1. Return a local default policy matching this spec.
  2. Allow future remote override from Firestore or Worker without changing widgets.
  3. Include version and `updatedAt` fields.
  4. Validate remote policy and fall back to local defaults if invalid.
  **Done when**: The app has one source for Free/Premium limits and ad policy.

- [X] T007 Create `EntitlementRepository`.

  **Why**: Premium status must be account-aware and eventually restorable.
  **Steps**:
  1. Load entitlement from user profile or local default Free snapshot.
  2. Cache last known entitlement locally for startup.
  3. Expose a stream/future for current entitlement.
  4. Add placeholders for trusted Worker verification result.
  5. Do not allow UI to write permanent Premium directly.
  **Done when**: The app can show Free/Premium state from a repository abstraction.

- [X] T008 Create `MonetizationCubit` and state.

  **Why**: UI needs current plan, quota, ad readiness, consent state, and loading/errors in one predictable state.
  **Steps**:
  1. Add state fields for entitlement, policy, AI usage, consent state, ads initialized, and errors.
  2. Load policy and entitlement on app startup or when Settings opens.
  3. Refresh quota after AI actions.
  4. Expose actions for opening Premium screen, requesting rewarded credit, and refreshing entitlement.
  **Done when**: Free/Premium screen can render without directly calling repositories.

## Phase 3: Free/Premium Screen

- [X] T009 Add `FreePremiumScreen`.

  **Why**: Users need a single place to understand limits, ads, and Premium.
  **Steps**:
  1. Create `lib/screens/monetization/views/free_premium_screen.dart`.
  2. Show current plan badge.
  3. Show AI daily usage card.
  4. Show Free/Premium comparison.
  5. Show ad behavior for Free and no-ads for Premium.
  6. Show honest Premium CTA: "coming soon" or sandbox flow until real purchases are ready.
  7. Keep a visible back/close path.
  **Done when**: Free users understand limits and Premium without leaving the app.

- [X] T010 Add plan comparison widgets.

  **Why**: Reusable widgets keep the paywall readable and testable.
  **Steps**:
  1. Add `current_plan_badge.dart`.
  2. Add `plan_comparison_table.dart`.
  3. Add `plan_feature_row.dart`.
  4. Add `quota_usage_card.dart`.
  5. Add `premium_cta_panel.dart`.
  6. Keep UI dense, clear, and not styled like a marketing landing page.
  **Done when**: Widgets render independently in tests with Free and Premium fixtures.

- [ ] T011 Add navigation from Settings and quota prompts.

  **Why**: Users should find plan details when they hit limits or want to remove ads.
  **Steps**:
  1. Add a Monetization section to Settings.
  2. Link "Free/Premium" to `FreePremiumScreen`.
  3. Link AI quota exhausted messages to the same screen.
  4. Link ad removal CTA to the same screen.
  **Done when**: Users can reach plan details from natural app contexts.

- [ ] T012 Add quota messaging for Free users.

  **Why**: Quota errors should guide users without blocking manual tracking.
  **Steps**:
  1. Update AI error presentation to distinguish unclear input, provider failure, and quota exhausted.
  2. For quota exhausted, show remaining reset timing if available.
  3. Show manual add expense option.
  4. Show optional rewarded ad button only if policy allows.
  **Done when**: AI quota exhaustion is understandable and non-destructive.

## Phase 4: Ads SDK Abstraction

- [X] T013 Add `google_mobile_ads` dependency.

  **Why**: This is the official Flutter path for AdMob banner, interstitial, native, and rewarded ads.
  **Steps**:
  1. Add dependency to `pubspec.yaml`.
  2. Run `flutter pub get`.
  3. Check Android multidex/build impact.
  4. Do not wire real production ad IDs yet unless config exists.
  **Done when**: The project resolves the ad SDK without unrelated dependency churn.
  **Status note (Plan 040 cleanup)**: Completed by Plan 027 production ads readiness.

- [X] T014 Add platform ad app ID configuration.

  **Why**: Android and iOS require app IDs before the SDK can load ads safely.
  **Steps**:
  1. Add Android manifest metadata for `com.google.android.gms.ads.APPLICATION_ID`.
  2. Add iOS `GADApplicationIdentifier`.
  3. Use test app IDs for debug.
  4. Add documentation for release config values.
  5. Ensure missing production config fails clearly in release build or disables ads safely.
  **Done when**: Debug builds can initialize ads using test configuration.
  **Status note (Plan 040 cleanup)**: Completed by Plan 027 with test-ID-safe
  Android/iOS configuration and release documentation.

- [X] T015 Create `AdService` abstraction.

  **Why**: Tests and Premium users should not depend on real SDK calls.
  **Steps**:
  1. Define methods for initialize, loadBanner, disposeBanner, loadInterstitial, showInterstitial, loadRewarded, showRewarded, and shutdown.
  2. Add a fake implementation for tests.
  3. Add `GoogleMobileAdsService` wrapping the plugin.
  4. Ensure all disposals are explicit.
  **Done when**: Ad UI uses an interface, not plugin calls directly.

- [X] T016 Create `AdConsentService`.

  **Why**: Consent rules must be centralized and run before ad requests.
  **Steps**:
  1. Wrap UMP consent update.
  2. Expose `canRequestAds`.
  3. Expose `privacyOptionsRequired`.
  4. Expose `showPrivacyOptions`.
  5. Support debug geography/test identifiers only in debug configuration.
  **Done when**: Ads can be blocked until consent logic allows requests.

- [X] T017 Add ad initialization orchestration.

  **Why**: The app must not initialize/request ads for Premium users.
  **Steps**:
  1. In `MonetizationCubit` or startup coordinator, load entitlement first.
  2. If Free, request consent update.
  3. If consent allows, initialize Mobile Ads.
  4. If Premium, skip ad initialization and clear ad slots.
  5. Prevent duplicate initialization.
  **Done when**: Premium fixture causes zero ad SDK calls in tests.

## Phase 5: Banner, Interstitial, And Rewarded Ads

- [X] T018 Add `AdaptiveBannerAdSlot`.

  **Why**: Banner space must be stable and not shift content after loading.
  **Steps**:
  1. Create a widget under `lib/monetization/widgets`.
  2. Reserve height before ad loads.
  3. Render nothing or a small neutral placeholder when ads are unavailable.
  4. Dispose banner when removed.
  5. Hide completely for Premium users.
  **Done when**: Banner layout is stable in widget tests.

- [X] T019 Add Home banner placement.

  **Why**: Home has high visibility but must not interfere with primary expense data.
  **Steps**:
  1. Place banner in a bottom/reserved area.
  2. Do not cover Total Balance, Add Expense, or navigation controls.
  3. Confirm Premium hides the slot.
  4. Confirm failed ad load leaves the page usable.
  **Done when**: Home remains readable with and without the banner.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037.

- [X] T020 Add Expenses/transactions banner placement.

  **Why**: List screens can host passive ads without interrupting entry.
  **Steps**:
  1. Place banner after a stable list segment or at bottom.
  2. Avoid changing list item heights dynamically.
  3. Ensure empty state still looks correct.
  4. Hide for Premium.
  **Done when**: Expense list works in empty, short, and long states.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037.

- [X] T021 Add Reports/Stats banner placement.

  **Why**: Reports are reading-oriented and can support passive ads below content.
  **Steps**:
  1. Place banner below charts or in bottom reserved slot.
  2. Do not cover chart gestures/tooltips.
  3. Hide for Premium.
  4. Test on small screen height.
  **Done when**: Charts remain usable with ads enabled.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037.

- [X] T022 Add `InterstitialAdGate`.

  **Why**: Interstitials need central frequency and context checks.
  **Steps**:
  1. Create a controller/service that asks `FeatureGateService`.
  2. Track last shown time and session count.
  3. Block if route/context is critical.
  4. Load ahead only for allowed future moments.
  5. Show only after completion moments.
  **Done when**: Tests prove blocked contexts never show interstitials.

- [X] T023 Add post-export interstitial hook.

  **Why**: Export completion is a natural pause after user value is delivered.
  **Steps**:
  1. Hook after export file/result is successfully created.
  2. Never show before export begins.
  3. Respect frequency caps.
  4. Do nothing on export failure.
  **Done when**: Interstitial can only appear after successful export completion.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037 through the shared
  interstitial gate.

- [X] T024 Add post-save interstitial hook with conservative cap.

  **Why**: A save completion can be a natural pause, but it must be rare.
  **Steps**:
  1. Count successful expense saves.
  2. Consider showing only after at least 5 saves since last interstitial.
  3. Only show after user returns to Home/List, not while form is visible.
  4. Respect 10-minute and session caps.
  **Done when**: Frequent expense entry is not interrupted.
  **Status note (Plan 040 cleanup)**: Completed by Plan 037.

- [X] T025 Add rewarded ad flow for extra AI credit.

  **Why**: Free users can extend limited AI use without paying, while keeping quota controlled.
  **Steps**:
  1. Add `RewardedAiCreditButton`.
  2. Show it only when policy allows and quota is exhausted or low.
  3. Load rewarded ad only after user intent.
  4. Grant credit only from reward callback.
  5. Persist granted credit with expiration.
  6. Cap rewarded credits per day.
  **Done when**: A rewarded ad grants exactly one allowed credit and cannot be spammed.

## Phase 6: AI Quota Integration

- [X] T026 Connect Worker quota responses to monetization UI.

  **Why**: The Free/Premium screen must show real remaining usage where available.
  **Steps**:
  1. Extend AI response models if Worker returns usage/limit.
  2. Update `MonetizationCubit` after AI calls.
  3. Show stale/cache state if usage cannot be loaded.
  4. Avoid decrementing quota locally if Worker rejects request.
  **Done when**: AI usage card reflects Worker policy as closely as possible.
  **Status note (Plan 040 cleanup)**: Completed by Plans 028 and 038.

- [X] T027 Add quota policy fallback when Worker is unavailable.

  **Why**: The app should explain unavailable AI without breaking manual expense entry.
  **Steps**:
  1. Detect Worker/network errors separately from quota exhaustion.
  2. Show "AI temporarily unavailable" copy.
  3. Keep manual expense form accessible.
  4. Do not show Premium upsell for provider outage as if it were user quota exhaustion.
  **Done when**: Provider outage and quota exhaustion have different UX.
  **Status note (Plan 040 cleanup)**: Completed by Plans 028 and 038.

## Phase 7: Future Premium Purchase Hooks

- [X] T028 Add `PurchaseService` abstraction without enabling real purchases yet.

  **Why**: The UI should not be rewritten when store products are ready.
  **Steps**:
  1. Define methods `loadProducts`, `buyPremium`, `restorePurchases`, and purchase status stream.
  2. Add a disabled/mock implementation for current phase.
  3. Return clear unavailable state when store setup is missing.
  4. Wire Free/Premium CTA to this service.
  **Done when**: Premium CTA can be tested without real store SDK.

- [X] T029 Prepare product ID constants and config.

  **Why**: Store product IDs must match Google Play/App Store setup exactly.
  **Steps**:
  1. Define candidate product IDs such as `premium_monthly` and `premium_yearly`.
  2. Keep them centralized.
  3. Document that final IDs must be created in store consoles before production.
  4. Do not hardcode prices; prices come from store product details.
  **Done when**: Future purchase implementation has a clean product contract.

- [X] T030 Plan trusted entitlement verification endpoint.

  **Why**: Permanent Premium should not be granted from client purchase callbacks alone.
  **Steps**:
  1. Define Worker endpoint contract: request fields, auth token, purchase token/receipt, platform, product ID.
  2. Define success/error response shape.
  3. Define Firestore or Worker storage for verified entitlement.
  4. Define restore flow.
  5. Keep Google/Apple verification secrets outside Flutter.
  **Done when**: A backend worker can implement purchase verification without guessing.

## Phase 8: Settings, Privacy, And Admin Controls

- [X] T031 Add Monetization Settings section.

  **Why**: Users need plan, ads, and privacy controls in a predictable place.
  **Steps**:
  1. Add current plan row.
  2. Add Free/Premium navigation row.
  3. Add "Remove ads" CTA for Free.
  4. Add "Restore purchases" only when purchase integration exists.
  5. Add privacy/ad choices row if required by consent state.
  **Done when**: Settings exposes monetization without broken buttons.

- [X] T032 Add privacy options action.

  **Why**: Some consent messages require users to change privacy choices later.
  **Steps**:
  1. Use `AdConsentService.showPrivacyOptions`.
  2. Show the row only when required.
  3. Handle errors with a non-blocking message.
  4. Do not expose debug reset in production.
  **Done when**: Privacy options are accessible when the consent SDK requires them.

- [ ] T033 Add debug-only monetization diagnostics.

  **Why**: Ads, consent, and entitlement are hard to debug on real devices.
  **Steps**:
  1. Show current tier, source, consent status, canRequestAds, ad SDK initialized, and frequency counters in debug builds only.
  2. Hide diagnostics in release.
  3. Never show secrets or API keys.
  **Done when**: Developers can diagnose state without exposing sensitive data to users.

## Phase 9: Tests

- [X] T034 Add `FeatureGateService` unit tests.

  **Why**: Monetization gates are easy to regress and must be deterministic.
  **Test cases**:
  1. Free user can use manual features.
  2. Free user sees ads when consent allows.
  3. Premium user sees no ads.
  4. Unknown entitlement defaults safely.
  5. Quota exhausted blocks only AI action.
  6. Rewarded credit adds one allowed AI action.
  7. Critical routes block interstitials.
  **Done when**: Gate behavior is covered without plugin dependencies.

- [X] T035 Add `AdFrequencyCap` tests.

  **Why**: Interstitial abuse is a product and policy risk.
  **Test cases**:
  1. First eligible interstitial can show.
  2. Second interstitial inside 10 minutes is blocked.
  3. Session max blocks further interstitials.
  4. Post-save count threshold works.
  5. Premium blocks regardless of counters.
  **Done when**: Frequency cap rules are stable.

- [X] T036 Add `MonetizationCubit` tests.

  **Why**: UI depends on combined entitlement, policy, consent, and usage state.
  **Test cases**:
  1. Loads Free defaults.
  2. Loads Premium entitlement and disables ads.
  3. Handles consent failure without crash.
  4. Refreshes usage after AI action.
  5. Handles purchase unavailable state.
  **Done when**: Cubit emits expected states.

- [X] T037 Add `FreePremiumScreen` widget tests.

  **Why**: The screen is the user-facing contract for monetization.
  **Test cases**:
  1. Free state shows Free active.
  2. Premium state shows ads disabled.
  3. Quota usage card renders limits.
  4. Premium CTA is honest when purchases are unavailable.
  5. Back/close action exists.
  **Done when**: Screen copy and states do not regress.

- [X] T038 Add ad widget tests with fake service.

  **Why**: Real ad SDK cannot be used in normal widget tests.
  **Test cases**:
  1. Banner reserves height for Free.
  2. Banner hides for Premium.
  3. Failed load does not crash.
  4. Interstitial gate blocks critical route.
  5. Rewarded button grants only from reward callback.
  **Done when**: Ad UI behavior is testable without network.

## Phase 10: Manual QA

- [ ] T039 Run Android debug QA with test ads.

  **Status note (Plan 040 cleanup)**: Still open and deferred because it requires
  a real Android debug/internal run with AdMob test ads.

  **Why**: Ad SDK and consent behavior need device verification.
  **Steps**:
  1. Build debug or internal test APK with test ad IDs.
  2. Sign in as Free user.
  3. Verify Home banner slot.
  4. Verify Expenses banner slot.
  5. Verify Reports banner slot.
  6. Verify no ad during Add Expense and AI preview.
  7. Verify rewarded ad grants one credit.
  8. Verify interstitial frequency cap.
  **Done when**: Device behavior matches the placement policy.

- [ ] T040 Run consent QA with debug geography.

  **Status note (Plan 040 cleanup)**: Still open and deferred because it requires
  UMP/device geography QA outside local widget tests.

  **Why**: Consent errors may only appear in specific regions.
  **Steps**:
  1. Configure UMP debug test device.
  2. Force EEA debug geography.
  3. Launch app as Free user.
  4. Complete consent flow.
  5. Verify `canRequestAds` before ad requests.
  6. Verify privacy options row when required.
  **Done when**: Consent flow works without relying on production geography.

- [ ] T041 Run Premium fixture QA.

  **Status note (Plan 040 cleanup)**: Still open for device/manual QA; automated
  fake-service Premium coverage exists, but this manual fixture pass remains deferred.

  **Why**: Premium must remove ads completely.
  **Steps**:
  1. Use fake Premium entitlement.
  2. Launch app.
  3. Visit Home, Expenses, Reports, AI, Settings.
  4. Confirm ad service is not initialized or requested.
  5. Confirm Free/Premium screen shows Premium active.
  **Done when**: Premium path is clean and ad-free.

## Phase 11: Documentation And Release Safety

- [X] T042 Document release configuration.

  **Why**: Real ads require exact setup and wrong IDs can crash or show no ads.
  **Steps**:
  1. Document Android AdMob app ID.
  2. Document iOS AdMob app ID.
  3. Document banner/interstitial/rewarded ad unit IDs.
  4. Document debug test IDs.
  5. Document where to set values for release builds.
  **Done when**: Release config can be completed without searching code.
  **Status note (Plan 040 cleanup)**: Covered by `docs/monetization/`.

- [X] T043 Document AdMob readiness checklist.

  **Why**: Real ad serving depends on account and app approval outside code.
  **Steps**:
  1. Create AdMob account.
  2. Add Android/iOS apps.
  3. Add app-ads.txt if required.
  4. Create ad units.
  5. Confirm privacy messages.
  6. Wait for app/account readiness.
  7. Use test ads until approved.
  **Done when**: The user knows why real ads may not show immediately.
  **Status note (Plan 040 cleanup)**: Covered by `docs/monetization/`.

- [X] T044 Document Premium store readiness checklist.

  **Why**: Store subscriptions cannot be finished only in Flutter.
  **Steps**:
  1. Create Google Play subscription products.
  2. Create App Store subscription products.
  3. Match product IDs.
  4. Add pricing and trial rules.
  5. Add restore purchase policy.
  6. Add privacy policy and terms links if stores require them.
  7. Plan Worker verification secrets.
  **Done when**: Future Premium purchase work has external setup steps listed.
  **Status note (Plan 040 cleanup)**: Covered by `docs/monetization/premium-verification.md`.

- [X] T045 Update `specs/README.md`.

  **Why**: Future workers need to know where this plan belongs in roadmap order.
  **Steps**:
  1. Add `023-free-premium-ads`.
  2. Keep `018` through `022` listed as previous plans.
  3. Mention `023` depends on AI quota and Settings foundations.
  **Done when**: Spec index reflects the current roadmap.
