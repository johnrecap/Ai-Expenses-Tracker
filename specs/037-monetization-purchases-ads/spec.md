# Feature Specification: Monetization Purchases And Ads Production

**Feature Branch**: `037-monetization-purchases-ads`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Finish the incomplete Free/Premium and advertising work so monetization is honest, consent-aware, and production safe.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See Honest Free And Premium State (Priority: P1)

As a free user, I need to know my daily AI limits and see ads only when consent allows. As a premium user, I need ads and AI limits removed only after a verified entitlement.

**Why this priority**: Premium is currently a placeholder, and free quota/ad state must not mislead users.

**Independent Test**: Free account sees limits and consent-aware ad surfaces; premium entitlement fixture hides ads and unlocks premium behavior without client-side cheating.

**Acceptance Scenarios**:

1. **Given** the user is Free, **When** they open Free/Premium, **Then** daily parse/advice/receipt limits are shown clearly.
2. **Given** consent is unavailable or denied, **When** ad slots render, **Then** ads do not load and the app remains usable.
3. **Given** Premium entitlement is verified, **When** the user returns to core screens, **Then** ads are hidden and premium labels are active.

---

### User Story 2 - Use Production Ad Placements Safely (Priority: P1)

As a user, I should only see non-intrusive ads in safe places that do not block expense entry, AI confirmation, login, or security flows.

**Why this priority**: Ads can hurt trust if placed aggressively in a finance app.

**Independent Test**: Test ad IDs load on device in safe slots with frequency caps and never interrupt critical routes.

**Acceptance Scenarios**:

1. **Given** user consent allows ads, **When** Home/Expenses/Reports are opened, **Then** banner slots reserve stable space and do not overlap content.
2. **Given** the user saves expenses repeatedly, **When** interstitial eligibility is checked, **Then** caps prevent frequent or critical-flow ads.
3. **Given** an ad load fails, **When** the slot renders, **Then** the app layout remains usable without crashes.

---

### User Story 3 - Prepare Real Purchases Without Client-Side Premium Unlock (Priority: P2)

As the app owner, I need a clean purchase integration path that never permanently grants Premium from the Flutter client alone.

**Why this priority**: Client-only premium unlocks are insecure. Purchase verification needs a backend or trusted entitlement source.

**Independent Test**: Purchase buttons clearly show unavailable/sandbox state until verification is wired; future backend contract is documented.

**Acceptance Scenarios**:

1. **Given** real purchase verification is not ready, **When** user taps Premium purchase, **Then** the app explains that purchases are coming soon or sandbox-only without charging.
2. **Given** a verified entitlement repository fixture is injected, **When** entitlement loads, **Then** Premium state is reflected consistently across app.

### Edge Cases

- Ads must not display before consent requirements are satisfied.
- Ads must not block login, AI confirmation, expense save confirmation, app lock, or payment-like purchase flows.
- Quota exhausted must not block manual expense tracking.
- Rewarded ads must only grant temporary AI credits after actual reward callback.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Free/Premium UI MUST accurately represent current entitlement and AI quota.
- **FR-002**: Ads MUST be consent-aware and hidden for Premium users.
- **FR-003**: Banner ads MUST use stable layout slots and never overlap app content.
- **FR-004**: Interstitial ads MUST be frequency capped and blocked on critical routes.
- **FR-005**: Rewarded AI credits MUST be granted only after a reward callback.
- **FR-006**: Production ad IDs MUST be configured outside source control.
- **FR-007**: Premium purchase flow MUST not grant permanent entitlement without verified backend/store validation.
- **FR-008**: Tests MUST cover Free, Premium, consent denied, ad failure, and reward callback behavior.

### Key Entities

- **EntitlementSnapshot**: Current Free/Premium state with source and freshness.
- **AdPlacement**: Named banner/interstitial/rewarded slot with frequency and route safety rules.
- **PurchaseAttempt**: User action to buy/restore premium with current status and message.
- **RewardedCredit**: Temporary AI usage credit granted after rewarded ad completion.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of ad placements are blocked for Premium users in tests.
- **SC-002**: Interstitial caps prevent more than the configured safe count per session.
- **SC-003**: Free users can complete manual expense entry even when ads fail, consent is denied, or AI quota is exhausted.
- **SC-004**: No production ad id or purchase secret is committed to source control.

## Assumptions

- Real billing verification may be implemented in a later backend plan.
- Current plan can keep purchase CTA unavailable if verification is not ready.
- AdMob is the first ad network.
