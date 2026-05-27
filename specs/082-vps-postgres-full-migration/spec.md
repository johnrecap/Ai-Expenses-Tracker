# Feature Specification: VPS PostgreSQL Full Migration

**Feature Branch**: `082-vps-postgres-full-migration`  
**Created**: 2026-05-26  
**Status**: Draft  
**Input**: User wants to move all app-owned data from Firestore to a VPS backend with PostgreSQL, while keeping Firebase for Google/email-password authentication and keeping the Cloudflare AI gateway.

## User Scenarios & Testing

### User Story 1 - Signed-in users keep the same account identity (Priority: P1)

A user signs in with the existing Google or email/password flow and reaches the app with the same account identity, but finance data is served by the new backend instead of Firestore.

**Why this priority**: Authentication is the bridge between the current app and the new server. If identity mapping is wrong, every migrated record can be exposed, duplicated, or lost.

**Independent Test**: Sign in with both providers, call the new server as the current user, and verify that only that user's records are accessible.

**Acceptance Scenarios**:

1. **Given** a signed-in Google user, **When** the app opens authenticated screens, **Then** the backend recognizes the Firebase user id and returns only that user's data.
2. **Given** a signed-in email/password user, **When** the app refreshes data, **Then** the backend accepts the same identity path without requiring a new account.
3. **Given** an expired or missing auth token, **When** the app calls the backend, **Then** the user sees a recoverable auth/session message and no data is returned.

---

### User Story 2 - Finance data works local-first and syncs safely (Priority: P1)

A user can create, edit, delete, and view expenses, settings, categories, budgets, recurring items, saving goals, wallets, transfers, and AI action history from local storage, then sync changes to the VPS when network is available.

**Why this priority**: A pure network API migration would keep the app dependent on connectivity and would not solve current full-history reads. Local-first behavior protects cost, speed, and user trust.

**Independent Test**: Put the device offline, create and edit records, reopen the app, then reconnect and verify that all changes sync once and stay consistent across another signed-in device.

**Acceptance Scenarios**:

1. **Given** the user is offline, **When** they add an expense, **Then** the expense appears immediately with pending-sync status.
2. **Given** the user reconnects, **When** sync runs, **Then** pending local changes are uploaded and server changes are downloaded without duplicates.
3. **Given** two devices edit the same record, **When** sync detects a conflict, **Then** the app applies a documented deterministic conflict policy and records the conflict outcome.

---

### User Story 3 - Existing Firestore users migrate without data loss (Priority: P1)

An existing user with Firestore data signs in after the migration and sees all previous records in the new local/server data path.

**Why this priority**: The user asked for a full migration. Existing data must survive the move, including mixed currencies, settings, recurring rules, wallets/transfers, and account profile fields.

**Independent Test**: Seed a Firestore account with representative data, run migration/backfill, sign into the migrated app, and compare counts and important field values against the original.

**Acceptance Scenarios**:

1. **Given** a user has Firestore expenses and settings, **When** migration completes, **Then** the backend contains equivalent records with stable ids and preserved timestamps.
2. **Given** a record was deleted or archived in Firestore, **When** migration runs, **Then** the new system preserves the correct archived/deleted state.
3. **Given** migration fails midway, **When** the operator reruns it, **Then** already-imported records are not duplicated.

---

### User Story 4 - Reports, AI, export, notifications, premium, and account deletion keep working (Priority: P2)

The user experiences the same app capabilities after the backend switch: finance calculations, AI drafts/advice, export, notifications, monetization gates, profile changes, and account deletion still work from the new source of truth.

**Why this priority**: Moving only expenses would create a broken app. Secondary surfaces must use the same migrated repositories and money semantics.

**Independent Test**: Run the main user journeys on migrated data and compare Home, Reports, Budget, Export, AI, Settings, and deletion behavior against known expected data.

**Acceptance Scenarios**:

1. **Given** migrated mixed-currency data, **When** Home and Reports render, **Then** both show consistent base-currency totals and missing-rate status.
2. **Given** the user asks the AI assistant about history, **When** the app prepares local/backend context, **Then** the Cloudflare gateway receives authenticated requests without any provider key in Flutter.
3. **Given** the user deletes their account, **When** recent authentication succeeds, **Then** backend data and Firebase Auth identity are removed or marked for removal in a safe order.

---

### User Story 5 - Operators can deploy, monitor, backup, and rollback safely (Priority: P3)

The owner can deploy the VPS backend, inspect health, restore from backup, and roll back the app/server cutover if production issues appear.

**Why this priority**: A self-hosted backend saves money only if it is operable. Without backups, logs, migrations, and rollback, the VPS becomes a single point of failure.

**Independent Test**: Deploy to staging/production VPS, run health checks, create backup, restore to a test database, and perform a documented rollback drill.

**Acceptance Scenarios**:

1. **Given** the backend is deployed, **When** health checks run, **Then** database connectivity, auth verification, and sync readiness are reported.
2. **Given** a bad deployment, **When** rollback is triggered, **Then** the previous backend version and data state can be restored within the documented recovery window.
3. **Given** scheduled backups run, **When** a restore drill is performed, **Then** the restored database contains recent user data and passes integrity checks.

### Edge Cases

- User signs in on a new device with no local database and large historical data.
- User uses the app offline for several days, then syncs many changes.
- Same record is edited on two devices before either device syncs.
- Exchange rates are refreshed while old expenses need transaction-date rate snapshots.
- Backend is reachable but PostgreSQL is unavailable.
- Firebase Auth succeeds but backend token verification fails due to clock, project, or service account misconfiguration.
- Cloudflare AI gateway is available while VPS is down, or VPS is available while Cloudflare AI gateway is down.
- Migration imports a partial user, is interrupted, and is run again.
- Account deletion fails after backend deletion but before Firebase Auth deletion, or the reverse.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST keep Firebase Authentication as the only sign-in identity provider for Google and email/password accounts.
- **FR-002**: The new backend MUST verify the signed-in user's Firebase identity before serving any user-owned data.
- **FR-003**: The app MUST stop using Firestore as the primary source of truth for app-owned finance/profile data after cutover.
- **FR-004**: The app MUST store finance records locally first so core screens can load without waiting for the network.
- **FR-005**: The sync system MUST upload local changes and download server changes incrementally.
- **FR-006**: The sync system MUST support create, update, archive/delete, and conflict handling for all migrated entities.
- **FR-007**: The migration MUST preserve stable identifiers where possible so old references, recurring links, AI action links, wallet links, and category snapshots remain meaningful.
- **FR-008**: The migration MUST preserve user settings including app-local display name, language, base currency, supported currencies, conversion rates, default payment method, notifications, onboarding, guided tour, and exchange-rate freshness metadata.
- **FR-009**: The migration MUST preserve all finance entities currently owned by repositories: expenses, categories, aliases, budgets, category budgets, recurring expenses, saving goals, wallets, transfers, AI action logs, and settings.
- **FR-010**: Money records MUST preserve original currency, original amount, base currency at calculation time when available, conversion rate metadata when available, and missing-rate status when unavailable.
- **FR-011**: Home, Reports, Budget, Category Budgets, Subscriptions, Export, Weekly Digest, AI summaries, and notifications MUST use the same migrated finance data semantics.
- **FR-012**: The Cloudflare AI gateway MUST remain the AI provider boundary and MUST continue to receive authenticated requests without provider secrets in Flutter.
- **FR-013**: Account deletion MUST remove or tombstone app-owned backend data and then complete Firebase Auth deletion through a documented, recoverable sequence.
- **FR-014**: The backend MUST expose health and readiness checks suitable for VPS monitoring.
- **FR-015**: The deployment MUST include backup, restore, migration, rollback, and incident-response documentation before production cutover.
- **FR-016**: The app MUST include a feature flag or environment switch so development can compare Firebase legacy data and VPS-backed data during migration.
- **FR-017**: The migration MUST be idempotent so retrying the same user's import cannot duplicate records.
- **FR-018**: The app MUST surface sync/auth/backend failures in a user-friendly way without losing local changes.

### Key Entities

- **Backend User**: Server-side account mapped to a Firebase user id and app-local profile metadata.
- **Device**: An installed app instance used for sync cursors, conflict visibility, and last-seen metadata.
- **Expense**: User-owned spending record with amount, currency, category snapshot, wallet/source references, AI/recurring references, and sync metadata.
- **Category / Category Alias**: User-owned classification metadata and learned AI aliases.
- **Budget / Category Budget**: Monthly spending limits and category-specific limits.
- **Recurring Expense / Subscription Summary Source**: Rule for materializing due expenses and subscription center summaries.
- **Saving Goal**: User-owned target amount with manual contributions and archive state.
- **Wallet Account / Transfer**: User-owned account metadata and transfer records that remain separate from spending totals.
- **User Settings**: Profile, localization, currency, payment, notification, onboarding, guided tour, and rate-cache settings.
- **AI Action Log**: Audit record for AI previews, confirmations, cancellations, and failures.
- **Exchange Rate Snapshot**: Current and historical rate metadata used for consistent financial reporting.
- **Sync Change / Tombstone**: Record metadata used to synchronize updates and deletions across devices.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A migrated existing user sees 100% of representative Firestore records in the new app path with no duplicate ids after one migration run and one retry.
- **SC-002**: Core Home data loads from local storage in under 1 second after the first successful sync for a user with at least 5,000 expenses.
- **SC-003**: Creating an expense offline keeps it visible after app restart and syncs after reconnection without user re-entry.
- **SC-004**: Cross-device sync converges to the same record counts and updated field values within one successful pull/push cycle.
- **SC-005**: Backend authorization tests prove one user cannot read, write, or delete another user's data.
- **SC-006**: Migration and cutover runbooks allow rollback to the previous production mode within the documented recovery window.
- **SC-007**: Home and Reports totals match for the same dataset and base currency, including converted and unconverted currency metadata.
- **SC-008**: No Flutter source, mobile platform file, or repository artifact contains database credentials, Firebase service account JSON, or AI provider keys.

## Assumptions

- The VPS already has aaPanel and PostgreSQL available.
- Firebase Auth remains active for both Google and email/password providers.
- Firestore remains readable during the migration/backfill window but is not the long-term primary store.
- Cloudflare Worker remains the AI gateway for provider calls and quota until a later plan explicitly changes that boundary.
- The first production migration prioritizes correctness and rollback over aggressive real-time sync features.
- Manual finance tracking must remain usable even if the VPS, Cloudflare AI gateway, ads, or purchase verification are temporarily unavailable.
