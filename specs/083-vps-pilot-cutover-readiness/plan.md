# Implementation Plan: VPS Pilot Cutover Readiness

**Branch**: `codex/081-trust-release-hardening` | **Date**: 2026-05-27 | **Spec**: `specs/083-vps-pilot-cutover-readiness/spec.md`  
**Input**: Feature specification from `specs/083-vps-pilot-cutover-readiness/spec.md`

## Summary

Finish the remaining work required to connect the Flutter app to the deployed VPS backend safely. The plan separates code work owned by Codex from operational work owned by the user. Codex will implement durable PostgreSQL sync, app runtime configuration, Flutter sync wiring, migration verification improvements, and protective tests. The owner will provide secrets and external setup, run VPS commands, configure backups/PM2/Cloudflare/Firebase, and perform real-device QA.

## Short Analysis: What Will Happen

- Keep the current deployed API domain: `https://api.saeeddev.com`.
- Replace `server/src/sync/syncService.ts` in-memory state with PostgreSQL-backed persistence.
- Add server tests proving sync survives process restart and remains user-scoped.
- Add `VPS_API_BASE_URL` compile-time configuration to Flutter.
- Wire `VpsApiClient`, `FirebaseTokenProvider`, and `SyncCoordinator` into `AuthenticatedRepositoryFactory`/app startup for `vpsLocalFirst` and `migrationComparison`.
- Keep `firebaseLegacy` as default and emergency rollback mode.
- Add or tighten migration dry-run commands and reporting so owner can verify seeded Firebase-to-PostgreSQL migration.
- Harden deployed VPS operation: PM2 startup, `/metrics` protection, backups, restore drill, aaPanel/Nginx consistency.
- Run local verification by Codex where possible, then hand off external checks to owner.
- Build a release/internal artifact only after explicit request and after code plus external checks pass.

## Technical Context

**Language/Version**: Dart 3.x/Flutter for mobile; TypeScript/Node.js for VPS API.  
**Backend Framework**: Fastify 5 with Firebase Admin token verification, Drizzle ORM, PostgreSQL.  
**Mobile Architecture**: Existing repository interfaces and `AuthenticatedRepositoryFactory`; local-first storage under `packages/expense_repository/lib/src/local`; sync classes under `packages/expense_repository/lib/src/sync`.  
**Storage**: PostgreSQL on VPS for server persistence; local Drift/in-memory local migration store for device-side MVP; Firestore remains legacy and staging migration source.  
**External Services**: Firebase Auth, Cloudflare Worker AI gateway, Cloudflare DNS/proxy, aaPanel/Nginx, PM2.  
**Testing**: Backend typecheck/tests, Flutter repository/API/sync tests, targeted analyzer, staging migration dry-run, real-device QA.  
**Constraints**: No secrets in Git/chat; PostgreSQL not public; build only after explicit request; AI provider keys stay in Cloudflare Worker; production default remains `firebaseLegacy` until pilot is approved.  
**Known Current State**: API health is live at `https://api.saeeddev.com/health`; current server sync persistence is in-memory; Flutter `vpsLocalFirst` currently creates local repositories but does not yet push/pull to VPS.

## Constitution Check

- Spec Kit artifacts live under `specs/083-vps-pilot-cutover-readiness/`: PASS.
- Firebase Auth remains owned by auth/repository boundaries; widgets do not import provider credentials: PASS.
- User-owned repositories remain behind `packages/expense_repository`: PASS.
- No Firebase Admin, PostgreSQL, or AI provider secrets in Flutter: PASS.
- Cloudflare Worker remains AI provider-secret boundary: PASS.
- Money conversion and finance surfaces are not changed by this plan unless sync tests expose migration issues: PASS.
- External setup tasks are separated from Codex code tasks and tracked in `tasks.md`: PASS.
- Release build remains blocked until verification and explicit user request: PASS.

## Project Structure

```text
specs/083-vps-pilot-cutover-readiness/
|-- spec.md
|-- plan.md
`-- tasks.md

server/src/sync/
server/src/db/schema/
server/tests/contract/
server/tests/integration/

packages/expense_repository/lib/src/
|-- api/
|-- sync/
|-- local/
|-- repository_factory.dart
`-- repository_runtime_mode.dart

lib/screens/auth/views/auth_gate.dart
lib/widgets/sync_status_banner.dart
docs/backend/
docs/implementation_plans/deferred-and-advanced-work.md
```

## Root Causes Addressed

### 1. Backend health is not enough

`/health` proves API, database, and Firebase Admin are reachable. It does not prove that user data persists. Durable sync persistence must be completed before any pilot.

### 2. Flutter VPS mode is not yet networked

The app can select `vpsLocalFirst`, but the current factory returns local repositories only. It needs API URL configuration, token injection, sync scheduling, and visible sync state.

### 3. Migration risk is still external

Backfill scripts and verification scaffolds exist, but production-like seeded migration has not run. This remains owner-blocked until credentials and staging/test accounts are provided.

### 4. Self-hosting adds operations work

The owner must now manage PM2 startup, backups, restore drills, Nginx/Cloudflare config, disk space, and endpoint protection. This plan converts those into explicit tasks rather than hidden assumptions.

## Implementation Strategy

### Stage A - Codex: Durable Sync

1. Add PostgreSQL-backed sync change persistence.
2. Add indexes and migration file.
3. Update sync service to use transactions and authenticated user scope.
4. Add tests for accepted changes, cursors, restarts, tombstones, and cross-user isolation.

### Stage B - Codex: Flutter VPS Wiring

1. Add `VPS_API_BASE_URL` environment config.
2. Wire Firebase token provider and `VpsApiClient`.
3. Instantiate `SyncCoordinator` in VPS/migration modes.
4. Trigger bootstrap/sync at safe app lifecycle points.
5. Preserve offline-first local writes and sync status UI.

### Stage C - Codex: Migration/Verification Hardening

1. Improve migration dry-run scripts or docs if gaps appear during review.
2. Ensure verification output is actionable: counts, hashes, duplicates, missing records, warnings.
3. Add tests for migration command safety where feasible.

### Stage D - Owner: VPS Operations

1. Configure PM2 startup.
2. Lock down `.env.production` permissions.
3. Protect `/metrics`.
4. Configure off-server encrypted backups.
5. Run restore drill.
6. Keep aaPanel Nginx configs consistent for API domain.

### Stage E - Joint: Device Pilot

1. Codex builds/runs only when requested and after code verification.
2. Owner installs on real Android device.
3. Owner performs manual QA checklist and sends screenshots/logs.
4. Codex fixes app/backend issues discovered during QA.

## Owner Responsibilities

- Keep Firebase Admin JSON and database password private.
- Run VPS commands that require server access.
- Provide command output/screenshots when asked.
- Confirm Cloudflare SSL/DNS mode and aaPanel Nginx state.
- Provide real Android device testing.
- Decide when a pilot account is allowed to use VPS mode.
- Decide when release artifact creation is allowed.

## Codex Responsibilities

- Implement code and tests inside the repo.
- Avoid touching unrelated files.
- Keep Spec Kit tasks updated.
- Push committed changes to the current branch when useful for VPS pull.
- Provide exact VPS or Flutter commands for owner-run steps.
- Refuse production cutover if durable sync, migration verification, backups, or real-device QA are incomplete.

## Verification Plan

Codex-run verification:

```bash
cd server
npm run typecheck
npm test
```

Targeted Flutter verification after app wiring:

```bash
flutter pub get
flutter gen-l10n
flutter analyze --no-pub
flutter test test/api test/local test/migration --no-pub
```

Owner-run VPS smoke:

```bash
curl https://api.saeeddev.com/health
pm2 status
/www/server/nginx/sbin/nginx -t
```

Owner-run pilot build/run command will be finalized after `VPS_API_BASE_URL` is implemented. Expected shape:

```bash
flutter run --dart-define=REPOSITORY_RUNTIME_MODE=vpsLocalFirst --dart-define=VPS_API_BASE_URL=https://api.saeeddev.com --dart-define=AI_GATEWAY_URL=<worker-url>/aiParse
```

## Risks

- Implementing durable sync incorrectly can overwrite user data or duplicate records.
- Flutter lifecycle sync can become noisy if it retries too aggressively.
- Existing local repository MVP may need generated Drift persistence hardening before multi-session use.
- Backfill needs real staging data; mocks cannot prove production migration safety.
- Owner-operated VPS changes can drift from repo docs if aaPanel rewrites config.
- Release build before T068/T069 equivalents pass would create false confidence.

## Rollback

- Mobile default remains `firebaseLegacy`.
- If VPS pilot fails, rebuild/run with:

```bash
--dart-define=REPOSITORY_RUNTIME_MODE=firebaseLegacy
```

- Keep Firestore rules/indexes and legacy repositories active during the migration window.
- On server incidents, stop or roll back PM2 API first, then keep mobile users on Firebase legacy until data integrity is proven.

## Deferred Items Considered

This plan pulls in deferred blockers for durable PostgreSQL sync, Flutter VPS client wiring, staging migration dry-run, real-device VPS QA, `/metrics` protection, backups, and aaPanel Nginx consistency. It intentionally leaves production purchases, AdMob, App Check, full Play Store readiness, broad RTL/PDF QA, attachment storage, and historical exchange-rate expansion outside the immediate VPS pilot cutover.
