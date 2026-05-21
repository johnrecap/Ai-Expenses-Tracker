# Feature Specification: Trust Release Hardening

**Feature Branch**: `081-trust-release-hardening`  
**Created**: 2026-05-21  
**Status**: Draft  
**Input**: User asked for a Spec Kit plan that consolidates the recent review findings and explains each task's reason, expected result, risks, and required changes.

## User Scenarios & Testing

### User Story 1 - Currency Totals Stay Trustworthy After Settings Changes (Priority: P1)

A user can change base currency or supported currencies without the app reusing stale exchange rates from a previous base currency, and every converted total either uses a valid saved rate or clearly excludes the unconverted amount.

**Why this priority**: Wrong finance totals are the highest trust risk in the app. A single stale exchange rate can make Home, Reports, budgets, exports, AI summaries, and digest totals misleading.

**Independent Test**: Start with rates saved for one base currency, change the base currency on the same day, refresh rates, and verify that the app does not reuse old-direction rates. Then add a new supported currency on the same day and verify that missing target rates trigger refresh or are surfaced as missing, not silently ignored.

**Acceptance Scenarios**:

1. **Given** rates were saved today for base `EGP` with `USD: 50`, **When** the user changes the base currency to `USD`, **Then** the old `USD: 50` rate is cleared or invalidated before totals can treat it as `USD` base conversion data.
2. **Given** rates were refreshed today and the user adds `EUR` to supported currencies, **When** the refresh service evaluates the settings, **Then** it refreshes or reports missing `EUR` instead of skipping refresh only because the date is today.
3. **Given** an expense cannot be converted because the saved rate is missing, invalid, or stale after a base-currency change, **When** a finance surface calculates totals, **Then** that expense is excluded from converted totals and the missing currency is visible in metadata or UI copy.

---

### User Story 2 - Account Deletion Requires Fresh Auth Before Data Removal (Priority: P1)

A user deleting their account is asked to reauthenticate before any user-owned Firestore data is removed, so a `requires-recent-login` failure cannot delete data while leaving the Firebase Auth account active.

**Why this priority**: Account deletion is sensitive and destructive. The current flow can delete Firestore data before discovering that Firebase Auth requires recent login.

**Independent Test**: Configure account deletion to require recent login, confirm the delete warning, and verify that no data deletion call happens until the user successfully completes provider-specific reauthentication.

**Acceptance Scenarios**:

1. **Given** a Google account needs recent login, **When** the user confirms account deletion, **Then** the app opens Google reauthentication before calling user data deletion.
2. **Given** an email/password account needs recent login, **When** the user confirms account deletion, **Then** the app requests the password before calling user data deletion.
3. **Given** reauthentication is cancelled or fails, **When** the deletion flow returns to the profile screen, **Then** the account remains active and user data deletion has not been attempted.
4. **Given** reauthentication succeeds, **When** deletion continues, **Then** the app removes user-scoped data and then deletes the Firebase Auth account, surfacing any unexpected partial failure clearly.

---

### User Story 3 - Incomplete Premium, Ads, Wallet, and Restore Surfaces Stay Honest (Priority: P2)

A user does not see incomplete foundations presented as finished paid or destructive features. Premium purchase, restore purchase, wallet management, transfer management, backup export, and restore execution are either safely available, clearly disabled, or marked as coming soon with localized copy.

**Why this priority**: Incomplete monetization or restore flows can reduce trust, cause payment confusion, or risk data loss if enabled too early.

**Independent Test**: Open Settings, Free/Premium, privacy/data, and any related entry point with fake services. Verify that unavailable actions cannot start real purchase, restore, wallet, transfer, or restore-write flows.

**Acceptance Scenarios**:

1. **Given** trusted purchase verification is unavailable, **When** the user opens the Free/Premium screen, **Then** permanent Premium purchase and restore actions are disabled or explicitly labelled unavailable.
2. **Given** backup/restore execution is not complete, **When** the user opens privacy/data settings, **Then** restore writes cannot be launched.
3. **Given** wallet and transfer repositories exist but the full UI workflow is incomplete, **When** users browse the app, **Then** they only see honest coming-soon or disabled states, not a broken partial workflow.

---

### User Story 4 - Documentation Matches Current Product Reality (Priority: P3)

A developer or AI reviewer can read the repo docs and understand the current product scope, known release blockers, and intentionally deferred work without being misled by mojibake, missing license references, or stale release notes.

**Why this priority**: The project is now large enough that stale docs create implementation risk for future agents and reviewers.

**Independent Test**: Review README, the AI/product audit, deferred backlog, and the new Spec Kit artifacts. Verify that they match current code boundaries and do not claim external production readiness that has not been proven.

**Acceptance Scenarios**:

1. **Given** README references a license file, **When** a developer opens the repo, **Then** the referenced license exists or the README no longer references it.
2. **Given** the AI/product audit includes Arabic text, **When** the document is opened in a normal editor, **Then** the text is readable and not mojibake.
3. **Given** external setup remains blocked, **When** a developer checks deferred work, **Then** production Firebase, AdMob, purchase verification, release keystore, real-device QA, and historical-rate work are tracked in the persistent backlog.

### Edge Cases

- Existing users may already have rates saved from a previous app version after changing base currency. The fix must avoid making those rates look trustworthy and should force refresh or surface missing-rate status when target coverage is incomplete.
- Network/provider failures during rate refresh must keep the last known valid data only when it is known to match the current base currency and required target currencies.
- Account deletion cannot be made fully atomic from the client alone. The app must at least prevent known recent-login failures from happening after data deletion, and it must keep the trusted backend deletion path in deferred work for stronger guarantees later.
- Test AdMob IDs, local entitlement state, and disabled purchase services must not be interpreted as production monetization.
- Historical reports currently use latest saved rates, not transaction-date rate snapshots. This plan may improve transparency, but immutable historical reporting remains a later feature unless explicitly pulled into scope.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST invalidate or clear saved conversion rates when the base currency changes so rates from the previous base cannot be reused in the opposite direction.
- **FR-002**: The exchange-rate refresh decision MUST require both same-day freshness and valid coverage for every supported non-base target currency.
- **FR-003**: Finance surfaces MUST avoid silently adding mixed currencies without a valid saved rate and MUST expose converted and unconverted currency metadata.
- **FR-004**: Any secondary finance surface touched by this plan MUST either use the shared conversion boundary or explicitly present conservative missing-rate behavior.
- **FR-005**: Account deletion MUST not call user data deletion until the deletion warning is confirmed and a provider-appropriate recent-auth step has succeeded.
- **FR-006**: Account deletion cancellation, failed reauthentication, unavailable provider reauth, and unexpected delete failures MUST leave the user in an understandable, non-spinning UI state.
- **FR-007**: Premium purchase and restore actions MUST stay disabled unless trusted backend entitlement verification and restore are available.
- **FR-008**: Backup restore writes MUST stay disabled until preview, confirmation, conflict policy, repository writes, and round-trip tests are complete.
- **FR-009**: Wallet and transfer entry points MUST remain hidden, disabled, or coming-soon until the full user-facing workflow is implemented.
- **FR-010**: Documentation MUST be updated so license references, AI/product audit text, and deferred release blockers match the current product state.
- **FR-011**: New user-facing copy introduced by this plan MUST use the existing English and Arabic localization files.
- **FR-012**: Verification MUST include targeted tests for exchange-rate freshness, settings currency changes, account deletion ordering, feature readiness gates, and affected finance surfaces.

### Key Entities

- **Exchange Rate Cache State**: The user's base currency, supported currencies, saved conversion rates, and rate timestamp used to decide whether totals can be converted safely.
- **Converted Money Result**: A finance calculation outcome containing base currency total, original currency metadata, converted currencies, unconverted currencies, rate timestamp, and row-level conversion details when needed.
- **Account Deletion Flow State**: The user's provider type, warning confirmation, reauthentication status, deletion progress, and failure state.
- **Feature Readiness Surface**: A visible or callable feature entry point with a readiness state such as available, disabled, coming soon, sandbox only, or hidden.
- **Release Documentation Evidence**: Docs and checklists that explain what is verified, what remains external, and which future work is intentionally deferred.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Changing base currency on the same local day cannot produce a converted total using a rate saved for the previous base currency in targeted tests.
- **SC-002**: Adding a new supported non-base currency on the same local day triggers rate refresh behavior or visible missing-rate metadata in targeted tests.
- **SC-003**: Account deletion tests prove zero user-data deletion calls occur before successful reauthentication in recent-login scenarios.
- **SC-004**: All incomplete monetization, wallet, transfer, backup, and restore entry points covered by tests are non-destructive and cannot start production-only flows.
- **SC-005**: README and product audit docs contain no known broken license references or mojibake in the reviewed sections.
- **SC-006**: `flutter analyze --no-pub` and the targeted test set listed in quickstart pass after implementation.

## Assumptions

- The current implementation remains Flutter/Dart with Bloc/Cubit and the existing repository boundaries.
- No new exchange-rate provider is introduced in this plan; the app continues using the existing daily cached provider behavior.
- No production secrets, AdMob IDs, purchase verification credentials, keystore material, or provider keys are added to source.
- Historical transaction-date rate snapshots are out of scope for this hardening pass unless the implementation discovers that a small metadata-only change is required to prevent wrong current behavior.
- The implementation may update tests and docs aggressively, but release builds are only run when the user asks for an artifact.
