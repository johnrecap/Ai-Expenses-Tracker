# Implementation Plan: VPS PostgreSQL Full Migration

**Branch**: `082-vps-postgres-full-migration` | **Date**: 2026-05-26 | **Spec**: `specs/082-vps-postgres-full-migration/spec.md`  
**Input**: Feature specification from `specs/082-vps-postgres-full-migration/spec.md`

## Summary

Move all app-owned data from Firestore to a self-hosted VPS backend using PostgreSQL while preserving Firebase Authentication for Google/email-password sign-in and preserving the Cloudflare Worker as the AI provider gateway. The app should become local-first: Flutter reads and writes a local database, syncs incrementally with the VPS API, and uses Firestore only as a legacy migration/backfill source until cutover is complete.

## Short Analysis: What Will Happen

- Keep Firebase Auth as the identity provider and use Firebase ID tokens to authenticate VPS API requests.
- Add a new VPS backend project under `server/` with TypeScript, Fastify, Drizzle, Zod, Firebase Admin, PostgreSQL migrations, logging, health checks, and sync endpoints.
- Add PostgreSQL schema for users, devices, settings, expenses, categories, aliases, budgets, recurring expenses, saving goals, wallets, transfers, AI action logs, exchange rates, sync metadata, and tombstones.
- Add Flutter local storage with Drift/SQLite so Home, Reports, Add Expense, Settings, Export, notifications, and AI history can work from local data.
- Add repository implementations that satisfy the current `expense_repository` interfaces but read/write local storage and enqueue sync changes instead of directly calling Firestore.
- Add a repository factory/environment switch in `AuthGate` so the app can run legacy Firebase mode, VPS/local-first mode, and migration comparison mode during rollout.
- Build Firestore-to-PostgreSQL backfill scripts and idempotent import checks before switching production users.
- Keep Cloudflare AI gateway for AI provider calls; it continues to verify Firebase tokens and must not store provider keys in Flutter.
- Add account deletion orchestration through the backend so app data and Firebase Auth deletion are ordered and recoverable.
- Add backup, restore, monitoring, rollback, and production runbooks before public cutover.

## Technical Context

**Language/Version**: Dart 3.x and Flutter for mobile app; TypeScript on Node.js 20+ for VPS backend; existing TypeScript Cloudflare Worker remains for AI.  
**Primary Dependencies**: Existing Bloc/Cubit and `expense_repository`; new backend uses Fastify, Drizzle ORM, Zod, Firebase Admin SDK, PostgreSQL driver, pino logging, and OpenAPI tooling; Flutter local storage uses Drift/SQLite.  
**Storage**: PostgreSQL on VPS as primary server database; Drift/SQLite on device as local-first database; Firestore read-only/legacy only during migration window; Cloudflare D1 may remain for AI quota until a later entitlement unification plan.  
**Testing**: Flutter unit/widget/repository tests, backend unit/integration/contract tests, PostgreSQL migration tests, sync conflict tests, Firestore backfill dry-run tests, Worker `npm test`/`typecheck` when AI contract changes.  
**Target Platform**: Android first with existing Flutter platform folders preserved; VPS Linux behind aaPanel/Nginx; Cloudflare Worker unchanged for AI gateway.  
**Project Type**: Mobile app plus self-hosted web API plus existing edge AI gateway.  
**Performance Goals**: Local Home load under 1s after first sync for 5,000 expenses; incremental sync without full-history reads; backend p95 under 500ms for ordinary sync pages on VPS-class hardware.  
**Constraints**: No database credentials, service account JSON, or AI provider keys in Flutter; PostgreSQL port not exposed publicly; no hardcoded exchange rates; no silent mixed-currency summation; no direct UI plugin access for auth/account work; build only when explicitly requested.  
**Scale/Scope**: Single-user mobile finance data with multi-device sync; schema must support growth to tens of thousands of records per user and many users on a VPS.

## Constitution Check

- Spec Kit artifacts live under `specs/082-vps-postgres-full-migration/`: PASS.
- Firebase Auth remains owned by `AuthRepository`/`AuthBloc`; widgets must not import Firebase/Auth plugins directly: PASS.
- User-owned repositories remain behind interfaces in `packages/expense_repository`: PASS.
- User settings continue through `SettingsRepository`; no direct UI storage writes: PASS.
- Money conversion must not hardcode rates and must preserve missing-rate metadata: PASS.
- Cloudflare AI gateway remains the provider-secret boundary; Flutter stores no provider keys: PASS.
- Account deletion must require recent auth and avoid orphaning user data: PASS.
- Incomplete premium/payment flows remain gated until trusted backend receipt verification exists: PASS.
- New user-facing strings must use ARB and `flutter gen-l10n`: PASS.
- External production setup, backup, deployment, and credential tasks are tracked in deferred/runbook docs where appropriate: PASS.

## Project Structure

### Documentation

```text
specs/082-vps-postgres-full-migration/
|-- spec.md
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   `-- openapi.yaml
|-- checklists/
|   `-- requirements.md
`-- tasks.md

docs/implementation_plans/deferred-and-advanced-work.md
docs/qa/flutter-verification-runbook.md
docs/finance/currency-policy.md
```

### Source Code

```text
server/
|-- package.json
|-- tsconfig.json
|-- drizzle.config.ts
|-- src/
|   |-- app.ts
|   |-- config/
|   |-- db/
|   |   |-- schema/
|   |   `-- migrations/
|   |-- auth/
|   |-- sync/
|   |-- users/
|   |-- finance/
|   |-- exchange-rates/
|   |-- account/
|   |-- observability/
|   `-- jobs/
|-- scripts/
|   |-- firestore-backfill.ts
|   |-- verify-migration.ts
|   `-- backup-restore-check.ts
`-- tests/
    |-- contract/
    |-- integration/
    `-- unit/

packages/expense_repository/lib/src/
|-- local/
|-- sync/
|-- api/
|-- repository_factory.dart
|-- firebase_*                 # Legacy migration mode only
`-- *_repo.dart                # Existing interfaces remain stable

lib/screens/auth/views/auth_gate.dart
lib/services/finance/
lib/ai/services/
workers/ai-gateway/
```

**Structure Decision**: Add a dedicated `server/` workspace for the VPS API and keep Flutter repository boundaries intact. The app should not call PostgreSQL directly; it calls the backend through authenticated API clients and relies on local Drift repositories for day-to-day reads/writes.

## Root Causes Addressed

### Firestore cost and read scaling

Current repository methods can still read full user expense history for reminders, budget checks, exports, and some watch flows. A VPS migration without local-first storage would only move that cost from Firebase to the VPS. The plan fixes this by making local storage the app's primary read path and sync the network boundary.

### Missing server-owned workflows

Premium entitlement verification, account deletion orchestration, recursive data deletion, and migration audit need a trusted backend. A self-hosted API gives the project a permanent place for these workflows without adding provider secrets to Flutter.

### Financial consistency

Firestore document shapes use `double` amounts and settings-level rate maps. PostgreSQL should preserve current behavior for compatibility while preparing exact money fields and transaction-date rate snapshots so old reports do not change unexpectedly.

### Migration risk

The app has many feature surfaces beyond expenses. A safe migration must cover every repository and every secondary financial surface, not only the Home list.

## Design Decisions

### Decision 1: PostgreSQL is the primary server database

PostgreSQL is selected because the data is relational, financial, report-heavy, and benefits from migrations, constraints, indexes, transactions, numeric columns, JSONB metadata, and backup tooling. MongoDB/PocketBase are rejected for the primary store because they add less value for finance/reporting correctness.

### Decision 2: Fastify + Drizzle for the VPS backend

Use TypeScript to match existing Worker/Functions code. Fastify keeps the API lightweight and explicit. Drizzle keeps SQL visible and migration-friendly for financial queries. NestJS + Prisma remains an acceptable heavier alternative but is not the recommended default for this repo.

### Decision 3: Drift/SQLite for Flutter local-first storage

Use Drift because the app needs relational local queries, reactive streams, migrations, joins, and deterministic offline behavior. Local storage should be the default app read/write path after migration.

### Decision 4: Firebase Auth stays, Firestore becomes legacy

Firebase Auth remains the identity provider. Firestore is used only for backfill, verification, and emergency legacy fallback during the cutover window. New primary writes go to local storage and sync to the VPS.

### Decision 5: Sync uses server revisions, device cursors, and tombstones

Each synced record has server revision, updated timestamps, deleted/tombstoned state, and origin device metadata. Deletions are soft/tombstoned first so other devices learn about them.

### Decision 6: Cloudflare AI gateway remains separate

Keep `workers/ai-gateway` for AI calls and provider secrets. It can continue using Firebase token verification. Later, quota/entitlement can be unified with VPS through a separate plan.

## Implementation Strategy

1. Create backend foundation and PostgreSQL migrations without connecting Flutter yet.
2. Add auth middleware that verifies Firebase ID tokens and maps them to backend users.
3. Add local Drift schema and repository factory behind existing repository interfaces.
4. Implement sync API and local sync engine for one MVP slice first: settings, categories, expenses.
5. Expand sync to budgets, category budgets, recurring, saving goals, wallets, transfers, aliases, and AI action logs.
6. Build idempotent Firestore backfill and verification scripts.
7. Run migration comparison mode: legacy Firebase reads vs local/VPS sync for seeded users.
8. Switch app runtime to VPS/local-first mode behind env flag.
9. Run production cutover checklist, backup, rollback drill, and real-device QA.
10. After stability, retire Firestore primary paths and leave only documented emergency fallback or remove them in a later cleanup plan.

## Migration Strategy

- **Stage A - Schema and API dry run**: Create PostgreSQL schema, run migrations locally/staging, run contract tests.
- **Stage B - Backfill dry run**: Export/import representative Firestore users into staging PostgreSQL with count/hash comparisons.
- **Stage C - App dual mode**: Add app mode switch and compare read results without changing production default.
- **Stage D - Limited pilot**: Enable VPS/local-first for test accounts only.
- **Stage E - Production cutover**: Freeze Firestore writes for migrated users, run final backfill, switch app flag, monitor errors.
- **Stage F - Decommission**: Keep Firestore read-only fallback for a defined window, then remove or archive legacy code in a later Spec Kit plan.

## Risks

- Full migration touches every repository; missing one surface can create inconsistent UI or data loss.
- Local-first sync requires careful conflict policy and tombstones; hard deletes can break multi-device convergence.
- Existing `double` amount fields need compatibility handling before stricter minor-unit money storage can be enforced.
- VPS operations become the owner's responsibility: backups, patches, SSL, firewall, monitoring, disk space, and restore drills.
- Firebase Auth deletion and backend deletion are not naturally atomic; plan must use safe ordering, retry state, and operator visibility.
- Cloudflare AI quota and VPS user entitlements can diverge until a later entitlement-unification plan connects them.
- aaPanel simplifies hosting but can hide service/process details; backend deploy docs must state exact Nginx, PM2/systemd, env, and backup requirements.

## Deferred Items Considered

The persistent deferred file already tracks production keystore/build QA, Firebase provider setup, App Check, AI gateway QA, real purchase verification, production AdMob IDs, localization/RTL/PDF QA, observability, wallet/transfer UI completion, restore execution, historical exchange rates, and store readiness. This migration plan directly pulls in backend migration, trusted deletion, backup/restore, and sync architecture. It does not activate production purchases, production ads, or AI provider changes beyond preserving the Cloudflare gateway.
