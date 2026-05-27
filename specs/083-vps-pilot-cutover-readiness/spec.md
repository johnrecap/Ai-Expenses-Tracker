# Feature Specification: VPS Pilot Cutover Readiness

**Feature Branch**: `codex/081-trust-release-hardening`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: Owner asked for a split plan covering the fixes Codex will implement and the setup/verification steps the owner must perform before the Flutter app is safely connected to the deployed VPS backend.

## User Scenarios & Testing

### User Story 1 - App sync persists through VPS restarts (Priority: P0)

As a signed-in user, I can create or edit app-owned data on one device, sync it to the VPS, restart the backend, and still retrieve the same data.

**Why this priority**: The current sync service is in-memory. It proves the API contract but is not safe for pilot users because accepted changes can disappear after a process restart.

**Independent Test**: Push a change through `/v1/sync/push`, restart PM2, pull from `/v1/sync/pull`, and verify the change remains present with its revision and ownership.

**Acceptance Scenarios**:

1. **Given** a valid Firebase ID token and a running PostgreSQL database, **When** a user pushes expense/settings/category changes, **Then** rows are stored durably in PostgreSQL with user ownership and server revisions.
2. **Given** the API process restarts, **When** the same user pulls with an earlier cursor, **Then** previously accepted changes are returned.
3. **Given** a second authenticated user calls pull, **When** data belongs to the first user, **Then** no cross-user records are returned.

---

### User Story 2 - Flutter can run in real VPS local-first mode (Priority: P0)

As a pilot user, I can sign in with Firebase Auth while the app reads/writes local data and syncs with `https://api.saeeddev.com`.

**Why this priority**: `vpsLocalFirst` currently creates local repositories only. `VpsApiClient`, token provider, and `SyncCoordinator` exist but are not wired into app startup or lifecycle.

**Independent Test**: Build/run the app with `REPOSITORY_RUNTIME_MODE=vpsLocalFirst` and `VPS_API_BASE_URL=https://api.saeeddev.com`, create an expense, force sync, restart the app, and confirm the data is present locally and on the VPS.

**Acceptance Scenarios**:

1. **Given** `VPS_API_BASE_URL` is configured, **When** the user signs in, **Then** the app creates a `VpsApiClient` with Firebase ID token authentication.
2. **Given** the device is offline, **When** the user creates or edits expenses, **Then** changes remain local and visible with pending sync status.
3. **Given** connectivity returns, **When** sync runs, **Then** pending changes are pushed and new server changes are pulled without blocking normal app use.

---

### User Story 3 - Existing Firebase data can be migrated safely (Priority: P0)

As the owner, I can migrate a seeded Firebase user to PostgreSQL, verify the imported data, and stop before production cutover if mismatches appear.

**Why this priority**: A financial app cannot risk missing, duplicated, or altered records during migration.

**Independent Test**: Run a staging backfill for a test Firebase user and compare counts, stable IDs, and representative field hashes across Firebase and PostgreSQL.

**Acceptance Scenarios**:

1. **Given** staging Firebase data, **When** the backfill runs twice, **Then** no duplicate rows are created.
2. **Given** migrated data, **When** verification runs, **Then** counts and hashes match or mismatches are reported in a saved artifact.
3. **Given** verification fails, **When** the owner reviews the report, **Then** production runtime mode remains `firebaseLegacy`.

---

### User Story 4 - VPS operations are safe enough for pilot use (Priority: P1)

As the owner, I can reboot the VPS, restore a database backup, and inspect health without exposing secrets or operational endpoints.

**Why this priority**: Moving from Firebase to a VPS saves cost only if backups, restarts, SSL, and monitoring are handled deliberately.

**Independent Test**: Reboot or restart PM2, confirm API auto-starts, create an encrypted database backup, restore it into a disposable database, and verify `/metrics` is not publicly exposed.

**Acceptance Scenarios**:

1. **Given** the VPS reboots, **When** PM2 startup runs, **Then** `ai-expenses-api` comes back online.
2. **Given** daily backup configuration exists, **When** the backup job runs, **Then** a restorable encrypted dump is created and copied off-server.
3. **Given** a public user requests `/metrics`, **When** the API domain is public, **Then** metrics are blocked or protected.

---

### User Story 5 - Release/pilot build is controlled and reversible (Priority: P1)

As the owner, I can install a test build that points to the VPS, verify core journeys on device, and roll back to Firebase legacy mode if anything fails.

**Why this priority**: A backend health check is not enough. The app's real user flows must be validated before public rollout.

**Independent Test**: Install a non-debug internal build with VPS flags, run the manual QA checklist, then build/run again with `firebaseLegacy` to prove rollback remains available.

**Acceptance Scenarios**:

1. **Given** a real Android device, **When** the pilot APK runs in `vpsLocalFirst`, **Then** auth, onboarding, Home, Add Expense, Reports, Settings, AI, Export, offline/reconnect, and account deletion flows are tested.
2. **Given** a blocker appears, **When** the owner switches runtime to `firebaseLegacy`, **Then** the app can still use the existing Firebase-backed path.
3. **Given** pilot QA passes, **When** release build is requested, **Then** it includes real VPS API URL and real AI gateway URL while excluding local/mock-only configuration.

## Requirements

### Functional Requirements

- **FR-001**: The backend MUST replace the in-memory sync service with PostgreSQL-backed sync persistence before any pilot user is enabled.
- **FR-002**: The backend MUST scope all sync rows and pulls by authenticated backend user.
- **FR-003**: The backend MUST preserve revision ordering, cursors, tombstones, operations, entity type, entity ID, and client timestamps.
- **FR-004**: The Flutter app MUST accept a compile-time `VPS_API_BASE_URL` configuration for VPS mode.
- **FR-005**: The Flutter app MUST keep `firebaseLegacy` as the default runtime mode until pilot/cutover is explicitly requested.
- **FR-006**: The Flutter app MUST create `VpsApiClient`, Firebase token provider, and `SyncCoordinator` only in VPS/migration modes.
- **FR-007**: The Flutter app MUST surface sync pending/error states without losing offline user edits.
- **FR-008**: The migration process MUST run against seeded staging data before production user migration.
- **FR-009**: The owner MUST provide Firebase Admin credentials, database credentials, Android test device access, and Cloudflare/aaPanel access outside Git and outside chat.
- **FR-010**: The deployment MUST keep PostgreSQL bound to localhost/private access only.
- **FR-011**: The deployment MUST protect or block `/metrics` before public pilot.
- **FR-012**: The deployment MUST configure PM2 startup or an equivalent service manager for reboot recovery.
- **FR-013**: The owner MUST create and verify at least one PostgreSQL restore drill before public cutover.
- **FR-014**: Release builds MUST include real `AI_GATEWAY_URL` and must not move AI provider keys from Cloudflare to Flutter or the VPS.
- **FR-015**: Any failed migration, sync, or real-device QA check MUST keep production users on `firebaseLegacy`.

### Non-Functional Requirements

- **NFR-001**: No Firebase Admin private keys, database passwords, provider keys, auth tokens, expense descriptions, receipt text, or raw sensitive prompts may be logged or committed.
- **NFR-002**: Backend health must remain checkable through `https://api.saeeddev.com/health`.
- **NFR-003**: Manual finance tracking must remain usable if the VPS or AI gateway is temporarily unavailable.
- **NFR-004**: Verification artifacts must be saved or summarized before declaring pilot readiness.

## Out of Scope

- Moving Firebase Auth off Firebase.
- Moving AI provider secrets out of Cloudflare Worker.
- Enabling real purchases or production AdMob.
- Public Play Store release.
- Removing Firebase legacy repositories.
- Solving all localization/RTL/PDF QA items not directly required for VPS pilot.

## Assumptions

- The deployed VPS API remains reachable at `https://api.saeeddev.com`.
- Firebase Auth remains the identity provider for Google and email/password accounts.
- The owner can run commands on aaPanel/VPS and provide screenshots/output when needed.
- The owner can test on a real Android device.

## Deferred Items Considered

The persistent deferred file directly affects this plan: PostgreSQL-backed sync must replace in-memory sync, Flutter VPS client/sync wiring must be added, staging migration dry-run is still required, `/metrics` must be protected, real-device VPS QA is blocked on device access, backups need off-server storage, and aaPanel/Nginx subdomain consistency has a new runbook. Broader deferred work such as production purchases, AdMob, App Check, historical exchange-rate policy, localization/RTL/PDF visual QA, wallet UI completion, and Play Store assets remains outside this cutover readiness plan unless explicitly requested.
