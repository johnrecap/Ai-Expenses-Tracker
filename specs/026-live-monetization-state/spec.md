# Feature Specification: Live Monetization State

**Feature Branch**: `026-live-monetization-state`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Review found that monetization UI exists but still uses local initial state in some screens instead of live entitlement, policy, quota, and ad state.

## User Scenarios & Testing

### User Story 1 - Settings Shows Real Plan State (Priority: P1)

A signed-in user opens Settings and sees their actual Free/Premium plan and usage state.

**Why this priority**: A Free/Premium screen is misleading if Settings renders a hardcoded initial state.

**Independent Test**: Inject Free and Premium entitlement fixtures and confirm Settings shows different states.

**Acceptance Scenarios**:

1. **Given** a Free user, **When** Settings opens, **Then** it shows Free plan, daily AI limits, and relevant upgrade/remove ads actions.
2. **Given** a Premium fixture, **When** Settings opens, **Then** it shows Premium plan and no ad-removal CTA.

---

### User Story 2 - Free/Premium Screen Uses Shared Cubit (Priority: P2)

A user opens the Free/Premium screen from Settings, quota prompts, or ad CTAs and sees consistent state everywhere.

**Why this priority**: Multiple local Cubits cause conflicting plan, usage, and ad display.

**Independent Test**: Navigate to the screen from different entry points and confirm the same state object/policy drives it.

**Acceptance Scenarios**:

1. **Given** AI quota has been used today, **When** the user opens Free/Premium from Settings, **Then** the usage card matches the latest quota state.
2. **Given** entitlement refresh fails, **When** the screen opens, **Then** cached Free-safe state renders with a non-blocking warning.

---

### User Story 3 - Plan State Survives App Restart (Priority: P3)

The app can display cached entitlement/policy quickly and refresh in the background.

**Why this priority**: Monetization UX should not flicker or block core expense tracking.

**Independent Test**: Start app offline after a cached entitlement exists and confirm Free-safe cached state appears.

**Acceptance Scenarios**:

1. **Given** cached entitlement exists, **When** the app starts offline, **Then** Settings displays cached state and keeps manual tracking usable.
2. **Given** no cached entitlement exists, **When** refresh fails, **Then** the app defaults to Free-safe behavior.

### Edge Cases

- Entitlement source may be local default, Firestore profile, future Worker verification, or test fixture.
- Premium must not be granted permanently from client-only state.
- Missing policy data must fall back to local defaults.

## Requirements

### Functional Requirements

- **FR-001**: Monetization state MUST be owned by a shared `MonetizationCubit` or equivalent app-level provider.
- **FR-002**: Settings MUST not instantiate `MonetizationState.initial()` as the user-visible truth.
- **FR-003**: Free/Premium screen MUST consume the shared state instead of creating conflicting local state where an app-level state exists.
- **FR-004**: Entitlement repository MUST default unknown users to Free-safe behavior.
- **FR-005**: Policy repository MUST validate remote policy before applying it.
- **FR-006**: Premium UI MUST never unlock permanent paid status directly from Flutter client-only controls.
- **FR-007**: Quota, ads, and purchase-unavailable messages MUST remain non-blocking for manual expense tracking.

### Key Entities

- **Entitlement Snapshot**: Current plan tier, source, expiry, and confidence.
- **Monetization Policy**: Free/Premium limits, ad eligibility, reward rules, and copy version.
- **Usage Snapshot**: Current AI usage and reset timing.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Settings and Free/Premium screen show the same plan state in 100% of fixture tests.
- **SC-002**: Unknown or failed entitlement refresh never shows Premium unless a trusted entitlement exists.
- **SC-003**: Manual add expense remains available when monetization state fails to load.
- **SC-004**: State refresh after an AI call updates visible quota within one app navigation cycle.

## Assumptions

- Plan 023 created initial monetization models, repositories, and Cubit.
- Real store subscriptions are still a future phase.
- Free plan daily limits are currently text parse 5/day, receipt 3/day, advice 3/day unless Worker policy changes.
