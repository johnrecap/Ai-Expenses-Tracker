# Feature Specification: Free/Premium Monetization And Ads

**Feature Branch**: `[023-free-premium-ads]`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User wants a deeper Free/Premium page plan, a clean ads strategy, and detailed tasks that explain what must be done and why.

## User Scenarios & Testing

### User Story 1 - Understand Free Versus Premium (Priority: P1)

As a user, I want a clear Free/Premium screen that explains what I can use for free and what Premium unlocks, so I do not feel surprised or blocked while tracking expenses.

**Why this priority**: Monetization must not damage trust. The app is a finance tool, so the user must know exactly what is free, what is limited, and what is paid.

**Independent Test**: Open the Free/Premium screen as a free user and verify that the screen shows current plan, daily AI usage, ad behavior, Premium benefits, and a non-blocking path back to the app.

**Acceptance Scenarios**:

1. **Given** the user is on the Free plan, **When** they open the Free/Premium screen, **Then** the screen shows Free as active and Premium as available.
2. **Given** the user is on the Free plan, **When** they read the plan comparison, **Then** the screen clearly says that manual expense tracking remains available.
3. **Given** the user is on the Premium plan, **When** they open the Free/Premium screen, **Then** ads are marked disabled and Premium entitlements are shown as active.
4. **Given** subscription setup is not production-ready yet, **When** the user taps Premium CTA in development, **Then** the app must show a clear "coming soon" or sandbox-only state instead of pretending a real purchase happened.

---

### User Story 2 - Free Plan With Fair AI Limits (Priority: P1)

As a free user, I want the app to keep working even when my AI quota is finished, so I can still add expenses manually and view reports.

**Why this priority**: AI is an enhancement, not the core app. If AI quota fails or ends, the app must not become unusable.

**Independent Test**: Set Free plan quota to zero and verify that manual expense creation, categories, local reports, budgets, and settings still work.

**Acceptance Scenarios**:

1. **Given** the user has remaining AI parse quota, **When** they use text AI parsing, **Then** usage decreases and the preview flow continues.
2. **Given** the user has no remaining AI parse quota, **When** they submit AI text, **Then** the app shows a quota message and keeps manual add expense available.
3. **Given** the user watches a rewarded ad, **When** the ad reward is completed, **Then** the user may receive a small extra AI action according to the configured reward policy.
4. **Given** the AI provider is down, **When** the user tries AI, **Then** quota must not be wasted on a failed provider response unless the request actually reaches and succeeds according to Worker policy.

---

### User Story 3 - Ads That Do Not Interrupt Expense Entry (Priority: P1)

As a free user, I can tolerate ads if they are placed at natural points and do not interrupt entering or confirming a transaction.

**Why this priority**: Aggressive ads will make the finance workflow feel unreliable. Expense entry and AI confirmation must stay focused.

**Independent Test**: Use the app as a free user for expense creation, AI preview, report viewing, and export. Verify banners appear only in reserved slots and interstitials appear only after allowed completion moments.

**Acceptance Scenarios**:

1. **Given** the user is creating or confirming an expense, **When** the flow is active, **Then** no interstitial ad appears.
2. **Given** a free user is on Home, Expenses, or Reports, **When** ads are allowed and consent permits requests, **Then** an adaptive banner may appear in a reserved layout slot.
3. **Given** the user completes a non-critical action such as export completion or after several saved expenses, **When** frequency cap allows, **Then** an interstitial may be shown.
4. **Given** the user is Premium, **When** they use any screen, **Then** the app must not request or render ads.

---

### User Story 4 - Consent And Privacy Controls (Priority: P1)

As a user in a region that requires consent, I want the app to ask for ad privacy choices correctly and let me manage them later.

**Why this priority**: Ads require privacy compliance. The app must not request ads before consent flow allows it.

**Independent Test**: Force EEA debug geography, launch the app as a free user, complete consent flow, and verify ads load only after consent state allows requests.

**Acceptance Scenarios**:

1. **Given** the app launches for a free user, **When** ads are enabled, **Then** the app requests updated consent information before requesting ads.
2. **Given** a privacy options entry point is required, **When** the user opens Settings, **Then** there is a visible privacy/ad choices entry.
3. **Given** consent cannot be obtained due to an error, **When** the app checks cached state, **Then** it follows official consent state behavior and does not invent consent locally.
4. **Given** the user is Premium, **When** the app launches, **Then** ad consent may be skipped unless required for another ad-related feature.

---

### User Story 5 - Future Premium Purchases (Priority: P2)

As a future paying user, I want Premium to be tied to my account and restorable on another device.

**Why this priority**: Premium cannot rely only on local client flags. A client-only unlock is easy to tamper with and will not restore reliably.

**Independent Test**: In sandbox purchase mode, complete a purchase, restart the app, and verify entitlement is restored from trusted entitlement state.

**Acceptance Scenarios**:

1. **Given** store purchase integration is enabled, **When** a purchase is completed, **Then** the app sends purchase data to a trusted verification endpoint.
2. **Given** verification succeeds, **When** the user signs in on another device, **Then** Premium entitlement is loaded from account state.
3. **Given** verification fails or is unavailable, **When** the app cannot confirm Premium, **Then** the app shows a safe pending/error state and does not grant permanent Premium.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST include a Free/Premium screen reachable from Settings and optionally from AI quota/ad prompts.
- **FR-002**: The screen MUST show current plan, Free limits, Premium benefits, ad behavior, and current daily AI usage.
- **FR-003**: Free users MUST keep manual expense entry, categories, budgets, basic reports, settings, and offline queue behavior.
- **FR-004**: Free users SHOULD have conservative AI daily limits: text parse 5/day, receipt extraction 3/day, advice 3/day unless remote policy changes.
- **FR-005**: Premium users SHOULD have higher AI limits, but Premium MUST NOT be described as unlimited unless the backend has enforced paid capacity.
- **FR-006**: The app MUST use an entitlement model instead of scattered `isPremium` booleans.
- **FR-007**: The app MUST use a centralized feature gate service for plan checks such as AI quota, ad visibility, export depth, and report depth.
- **FR-008**: Ads MUST be disabled for Premium users after entitlement is confirmed.
- **FR-009**: Ads MUST never interrupt add expense input, AI preview, AI confirmation, authentication, app lock, or payment/purchase flows.
- **FR-010**: Free users MAY see adaptive banner ads in reserved slots on Home, Expenses, Reports, and selected non-critical screens.
- **FR-011**: Free users MAY see interstitial ads only at natural completion moments and only under strict frequency caps.
- **FR-012**: Rewarded ads MAY grant small extra AI credits, but rewards MUST be capped and optional.
- **FR-013**: The app MUST not require watching ads to manually add an expense.
- **FR-014**: The app MUST initialize mobile ads only after entitlement and consent logic says ads are allowed.
- **FR-015**: The app MUST support ad test IDs in debug and separate production ad unit IDs through configuration.
- **FR-016**: The app MUST include a consent service for User Messaging Platform behavior where required.
- **FR-017**: The app MUST include a Settings entry for privacy/ad choices when the consent SDK says it is required.
- **FR-018**: The app MUST reserve banner space to avoid layout jumps.
- **FR-019**: The app MUST log ad load failures in debug and fail silently/non-disruptively in production UI.
- **FR-020**: The app MUST track local ad frequency caps per session and per time window.
- **FR-021**: Premium purchase integration MUST be isolated behind a purchase/entitlement abstraction so the UI can ship before real store setup.
- **FR-022**: Real subscription support MUST verify purchase entitlement through a trusted endpoint before permanent unlock.
- **FR-023**: The app MUST not store API keys, production ad secrets, or purchase verification secrets in Flutter client code.
- **FR-024**: The Free/Premium copy MUST avoid dark patterns: no fake countdowns, no misleading "unlimited", no hiding close/back actions.

### Non-Functional Requirements

- **NFR-001**: Monetization code must be isolated under `lib/monetization` or an equivalent feature folder.
- **NFR-002**: Ads must not block first meaningful app render for Premium users.
- **NFR-003**: A failed ad load must not crash or cover content.
- **NFR-004**: Feature gates must be testable without Google Mobile Ads or store SDKs.
- **NFR-005**: The plan must remain compatible with a Firebase-only app plus optional Cloudflare Worker for AI and entitlement verification.

### Key Entities

- **PlanTier**: `free`, `premium`, `unknown`, `pending`.
- **EntitlementSnapshot**: current tier, source, expiry, updatedAt, verification status, grace period.
- **AiQuotaPolicy**: daily limits for text parse, receipt extraction, advice, and rewarded extra credits.
- **AiQuotaUsage**: per-user per-day usage counters returned by Worker or local cache.
- **AdPlacementPolicy**: placement IDs, screen names, allowed formats, disabled contexts.
- **AdFrequencyCap**: session count, minimum minutes between interstitials, daily max where needed.
- **RewardedAdCredit**: action type, grantedAt, expiresAt, consumedAt, source ad event ID.
- **ConsentState**: canRequestAds, privacyOptionsRequired, lastUpdatedAt, debug mode.
- **PremiumProduct**: store product ID, title, price, period, trial information, platform.

## Success Criteria

- **SC-001**: A free user can understand plan differences in under 30 seconds from the Free/Premium screen.
- **SC-002**: Manual expense creation still works when all AI quota is exhausted.
- **SC-003**: Premium users trigger zero ad requests after entitlement is confirmed.
- **SC-004**: No interstitial appears during add expense, AI preview, auth, app lock, or purchase flows.
- **SC-005**: Debug builds use only test ad unit IDs by default.
- **SC-006**: Consent flow can be tested with EEA debug geography before production.
- **SC-007**: Feature gate unit tests cover Free, Premium, quota exhausted, entitlement pending, and consent unavailable states.

## Assumptions

- The first implementation can ship a Free/Premium UI and ad framework before real store subscriptions are fully configured.
- Real Premium subscriptions need Google Play Console and Apple App Store Connect setup before production purchase testing.
- For a free-first stack, Cloudflare Worker can later verify purchases and store entitlement state without Firebase Functions.
- AdMob account approval and app readiness can delay real ads; test ads must be used until approval.
- The app is not intended for children. If that changes, ad request configuration and store declarations must be revisited.

## Out Of Scope

- Implementing real store subscriptions in the same task as initial Free/Premium UI if store products are not ready.
- Building a custom payment system outside Google Play Billing/App Store for digital Premium features.
- Guaranteeing ad revenue. This depends on AdMob approval, region, fill rate, traffic, and policy compliance.
- Selling "unlimited AI" without a backend cost policy and quota enforcement.
