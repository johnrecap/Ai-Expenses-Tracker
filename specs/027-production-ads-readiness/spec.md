# Feature Specification: Production Ads Readiness

**Feature Branch**: `027-production-ads-readiness`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Review found ads are currently foundation/placeholders only; real AdMob SDK/config/placements are not production-ready.

## User Scenarios & Testing

### User Story 1 - Free Users See Polite Ads (Priority: P1)

A Free user sees non-intrusive ads only in approved reading contexts.

**Why this priority**: Ads can monetize Free users, but aggressive placement will damage trust and app retention.

**Independent Test**: Run a debug build with test ad IDs and verify approved placements only.

**Acceptance Scenarios**:

1. **Given** a Free user with consent allowing ads, **When** they open Home, Expenses, or Reports, **Then** stable banner slots may appear without covering primary controls.
2. **Given** a Free user is adding or confirming an expense, **When** the form or AI preview is visible, **Then** no ad interrupts the flow.

---

### User Story 2 - Premium Users Have Zero Ads (Priority: P2)

A Premium user or Premium fixture never initializes or requests ads.

**Why this priority**: "No ads" is a core Premium promise and must be enforced centrally.

**Independent Test**: Inject Premium entitlement and assert the ad service receives no initialization/load/show calls.

**Acceptance Scenarios**:

1. **Given** Premium entitlement is active, **When** the app starts, **Then** ad SDK initialization is skipped.
2. **Given** Premium user visits all screens, **When** ad slots would normally render for Free users, **Then** no ad container or placeholder appears.

---

### User Story 3 - Consent And Configuration Are Safe (Priority: P3)

Ads only request after consent and only with valid configured IDs.

**Why this priority**: Ad policy/compliance issues can block account approval or create app crashes.

**Independent Test**: Use debug consent geography and test ad IDs; release config missing IDs disables ads safely.

**Acceptance Scenarios**:

1. **Given** consent is required and not granted, **When** app starts, **Then** no ad request is made.
2. **Given** production ad IDs are missing, **When** a release build starts, **Then** ads fail closed with a clear diagnostic instead of crashing.

### Edge Cases

- AdMob accounts may take time to approve and real ads may not serve immediately.
- Consent availability differs by region.
- Interstitials must not appear too often or before the user receives value.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST use an ad service abstraction; widgets must not call the ad plugin directly.
- **FR-002**: Free users MAY see banners only in approved placements: Home, Expenses, Reports, and non-critical reading surfaces.
- **FR-003**: Ads MUST be blocked from Auth, Add Expense, AI preview/confirmation, App Lock, payment/premium purchase, and error recovery flows.
- **FR-004**: Interstitial ads MUST only show after successful completion moments and must obey frequency caps.
- **FR-005**: Rewarded ads MUST grant extra AI credits only after the reward callback.
- **FR-006**: Premium users MUST not initialize, load, or show ads.
- **FR-007**: Consent MUST be requested/checked before ad requests where required.
- **FR-008**: Production ad IDs MUST be configurable outside source-controlled secrets; test IDs must be used in debug.

### Key Entities

- **Ad Placement Policy**: Allowed and blocked routes, ad type, and frequency.
- **Ad Consent State**: Whether ads can be requested and privacy options are available.
- **Frequency Cap**: Time/session/save thresholds that prevent excessive interstitials.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Premium fixture causes zero ad service calls in tests.
- **SC-002**: Free debug build displays test banners only in approved screens.
- **SC-003**: Interstitials cannot show more than once per 10 minutes or during critical flows.
- **SC-004**: Missing production ad config disables ads safely and leaves the app usable.

## Assumptions

- Plan 023 created initial ad abstractions and policy models.
- Real purchase verification is separate from ads readiness.
- The first production ad provider is Google AdMob via `google_mobile_ads`.
