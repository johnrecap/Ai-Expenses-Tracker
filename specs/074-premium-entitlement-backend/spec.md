# Feature Specification: Premium Entitlement Backend

**Feature Branch**: `074-premium-entitlement-backend`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested a plan for turning Premium/Ads foundation into a real safe monetization system.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Premium Benefits Are Clear (Priority: P2)

As a user, I need to understand exactly what Premium unlocks before paying.

**Why this priority**: Vague "coming soon" Premium reduces trust.

**Independent Test**: Free/Premium screen lists concrete benefits and disabled purchase state is honest until backend verification exists.

**Acceptance Scenarios**:

1. **Given** purchases are not ready, **When** user opens Premium, **Then** the app clearly says purchases are unavailable and no payment is made.
2. **Given** Premium is ready, **When** user views benefits, **Then** they see no ads, higher AI quota, advanced reports, receipt limits, export templates, and smart budgets if approved.

---

### User Story 2 - Entitlements Are Server Verified (Priority: P1 for paid launch)

As the app owner, I need Premium unlocks to be verified by a trusted backend, not only by the Flutter client.

**Why this priority**: Client-only Premium can be spoofed.

**Independent Test**: Fake backend verifies purchase/restore outcomes and client responds to entitlement states.

**Acceptance Scenarios**:

1. **Given** valid purchase receipt, **When** backend verifies it, **Then** server-owned entitlement is stored/restored.
2. **Given** invalid receipt, **When** verification fails, **Then** client remains Free and shows clear error.

### User Story 3 - Core Tracking Stays Free (Priority: P1)

As a free user, I need manual expense tracking and local reports to keep working even when ads, purchases, or AI quota fail.

**Why this priority**: The app's core value must not break behind monetization.

**Independent Test**: Simulate ads unavailable, purchases unavailable, and quota exhausted; manual finance flows still work.

## Edge Cases

- Restore on a new device.
- Subscription expires.
- Refund/revocation.
- Backend temporarily unavailable.
- Consent unavailable.
- Premium user should see no ads.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Premium purchase/restore MUST not be enabled for real payments without trusted backend verification.
- **FR-002**: Premium benefits MUST be concrete and visible.
- **FR-003**: Entitlement state MUST be server-owned for paid launch.
- **FR-004**: Free manual tracking, local reports, and exports allowed by policy MUST remain usable when monetization fails.
- **FR-005**: Premium users MUST not see ads.
- **FR-006**: Purchase, restore, expiry, refund, and backend-unavailable states MUST be handled.

### Key Entities

- **PremiumBenefit**: Benefit, free limit, premium limit, and availability state.
- **VerifiedEntitlement**: User ID, product, status, expiry, source, and last verification.
- **PurchaseVerificationResult**: Receipt status, entitlement state, error, and recovery copy.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: No real purchase path is exposed before backend verification exists.
- **SC-002**: 100% of paid entitlement states are covered by fake tests.
- **SC-003**: Premium users see zero ad placements in entitlement fixtures.
- **SC-004**: Free manual expense creation works in all monetization failure fixtures.

## Assumptions

- Backend path may be Cloudflare Worker or another trusted backend, but not Flutter-only.
- First version may keep purchases disabled while clarifying benefits.

