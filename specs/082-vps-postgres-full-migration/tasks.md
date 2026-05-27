# Tasks: VPS PostgreSQL Full Migration

**Input**: Design documents from `specs/082-vps-postgres-full-migration/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/openapi.yaml`, `quickstart.md`

**Tests**: Required for this migration because it changes identity, persistence, sync, and financial correctness.

## Format

Each task includes purpose, expected result, risk, and concrete modification target so the next worker understands why it exists.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the scaffolding and explicit runtime modes before touching app behavior.

- [X] T001 Create backend workspace files in `server/package.json`, `server/tsconfig.json`, `server/src/app.ts`, and `server/src/config/env.ts`. Why: the VPS API needs a separate deployable unit. Expected: a typed backend project starts locally. Risk: mixing backend code into Flutter folders makes deployment and secrets harder.
- [X] T002 Add backend lint, typecheck, test, migration, and dev scripts in `server/package.json`. Why: every backend change needs repeatable verification. Expected: `npm run typecheck`, `npm test`, and migration commands exist. Risk: unverified backend edits can break production data.
- [X] T003 [P] Add ignored backend environment template in `server/.env.example` and update `.gitignore`. Why: secrets must be documented without being committed. Expected: required env names are visible and real values stay local. Risk: leaking DB or Firebase Admin credentials.
- [X] T004 [P] Add app runtime mode definitions in `packages/expense_repository/lib/src/repository_runtime_mode.dart`. Why: the app needs legacy, VPS, and migration-comparison modes. Expected: mode selection is explicit. Risk: accidental production cutover without a flag.
- [X] T005 [P] Add migration documentation placeholder in `docs/backend/vps-postgres-runbook.md`. Why: VPS ops must be documented as work progresses. Expected: runbook has sections for deploy, backups, rollback, and incidents. Risk: self-hosting without operations notes.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish schema, auth, API validation, local DB, and repository factory boundaries. No user-story work should bypass this layer.

- [X] T006 Define PostgreSQL schema tables from `specs/082-vps-postgres-full-migration/data-model.md` in `server/src/db/schema/*.ts`. Why: all migrated entities need typed durable tables. Expected: users, devices, settings, expenses, categories, budgets, recurring, saving goals, wallets, transfers, AI logs, rates, and sync tables are represented. Risk: missing entity tables cause partial migration.
- [X] T007 Add Drizzle migration setup in `server/drizzle.config.ts` and `server/src/db/migrations/`. Why: schema changes must be reproducible on VPS and staging. Expected: migrations can create a fresh database. Risk: manual SQL drift between environments.
- [X] T008 Add database connection and transaction helper in `server/src/db/client.ts`. Why: sync pushes must write multiple rows safely. Expected: typed database access with transaction support. Risk: partial writes corrupt sync state.
- [X] T009 Add Firebase ID token auth middleware in `server/src/auth/firebaseAuth.ts`. Why: backend data access must trust only verified Firebase users. Expected: requests map to `firebaseUid` or return 401. Risk: accepting unverified tokens exposes user data.
- [X] T010 Add backend user upsert service in `server/src/users/userService.ts`. Why: Firebase users need backend rows. Expected: first authenticated request creates/updates backend user. Risk: orphan records without stable owner.
- [X] T011 Add request validation and error envelope utilities in `server/src/http/validation.ts` and `server/src/http/errors.ts`. Why: mobile clients need predictable failures. Expected: all endpoints return consistent `code/message/retryable`. Risk: unclear errors cause bad retry or data loss.
- [X] T012 Add server health/readiness endpoint in `server/src/observability/healthRoutes.ts`. Why: VPS monitoring and cutover need a fast signal. Expected: `/health` checks API, DB, and auth verifier readiness. Risk: hidden downtime until users report it.
- [X] T013 Add Flutter local database package files in `packages/expense_repository/lib/src/local/local_database.dart`. Why: local-first repositories need one schema boundary. Expected: local Drift database can be generated and opened. Risk: ad hoc caches create inconsistent state.
- [X] T014 Add local tables mirroring synced entities in `packages/expense_repository/lib/src/local/tables/*.dart`. Why: Flutter needs offline storage for every migrated repository. Expected: tables include sync columns and legacy ids. Risk: some screens still depend on network.
- [X] T015 Add sync metadata models in `packages/expense_repository/lib/src/sync/sync_change.dart` and `packages/expense_repository/lib/src/sync/sync_cursor.dart`. Why: local changes need durable pending state. Expected: creates/updates/deletes can be enqueued. Risk: offline edits disappear or duplicate.
- [X] T016 Add API client boundary in `packages/expense_repository/lib/src/api/vps_api_client.dart`. Why: repositories should not scatter HTTP details. Expected: token injection, JSON handling, retries, and error mapping are centralized. Risk: inconsistent auth and error behavior.
- [X] T017 Replace direct repository construction in `lib/screens/auth/views/auth_gate.dart` with a repository factory entry point. Why: app startup is currently hardwired to Firebase repositories. Expected: mode switch can choose Firebase legacy or local/VPS repositories. Risk: migration code cannot be safely toggled.

**Checkpoint**: Backend schema/auth skeleton exists, local DB boundary exists, and app has an explicit runtime switch.

---

## Phase 3: User Story 1 - Signed-in users keep the same account identity (Priority: P1) MVP

**Goal**: Firebase login remains unchanged while the VPS becomes an authenticated data service.

**Independent Test**: Sign in with Google and email/password, call `/v1/users/me`, and verify one user cannot access another user's data.

### Tests for User Story 1

- [X] T018 [P] [US1] Add backend auth middleware tests in `server/tests/unit/firebaseAuth.test.ts`. Why: token verification is the security gate. Expected: valid token accepted, missing/invalid token rejected. Risk: broken auth blocks all users or leaks data.
- [X] T019 [P] [US1] Add user route contract tests in `server/tests/contract/usersMe.test.ts`. Why: Flutter depends on stable auth/profile responses. Expected: response matches `contracts/openapi.yaml`. Risk: API drift breaks the app.
- [X] T020 [P] [US1] Add Flutter API auth client tests in `test/api/vps_api_client_test.dart`. Why: the app must send Firebase tokens correctly. Expected: Authorization header is set and auth failures map to recoverable states. Risk: session errors appear as generic connection failures.

### Implementation for User Story 1

- [X] T021 [US1] Implement `/v1/users/me` routes in `server/src/users/userRoutes.ts`. Why: app needs backend identity bootstrap. Expected: user row is returned/created. Risk: users cannot start sync.
- [X] T022 [US1] Implement backend row-level ownership helpers in `server/src/auth/ownership.ts`. Why: every query must scope to authenticated user. Expected: service methods require backend user id. Risk: cross-user data access.
- [X] T023 [US1] Implement Flutter token provider wiring in `packages/expense_repository/lib/src/api/firebase_token_provider.dart`. Why: API calls should reuse existing `AuthRepository.getIdToken()`. Expected: no widget imports Firebase plugins. Risk: duplicate auth logic.
- [X] T024 [US1] Add account/profile API mapping in `packages/expense_repository/lib/src/api/account_api.dart`. Why: app-local display name should move off Firestore. Expected: profile edits target backend in VPS mode. Risk: settings/profile UI keeps writing old store.

**Checkpoint**: Authenticated VPS identity works independently from finance sync.

---

## Phase 4: User Story 2 - Finance data works local-first and syncs safely (Priority: P1)

**Goal**: Local repositories support offline finance CRUD and sync through generic pull/push endpoints.

**Independent Test**: Create/edit/delete expenses offline, restart app, reconnect, and verify convergence on another device.

### Tests for User Story 2

- [X] T025 [P] [US2] Add local database migration tests in `test/local/local_database_migration_test.dart`. Why: local schema must survive upgrades. Expected: clean create and migration paths pass. Risk: users lose data on app update.
- [X] T026 [P] [US2] Add local expense repository tests in `test/local/local_expense_repository_test.dart`. Why: expenses are the MVP sync entity. Expected: CRUD, pending status, tombstone behavior pass. Risk: core tracking breaks offline.
- [X] T027 [P] [US2] Add backend sync contract tests in `server/tests/contract/syncRoutes.test.ts`. Why: sync API shape must remain stable. Expected: pull/push responses match contract. Risk: app/backend version mismatch.
- [X] T028 [P] [US2] Add sync conflict tests in `server/tests/integration/syncConflict.test.ts`. Why: multi-device edits are expected. Expected: documented conflict policy is enforced. Risk: newer data overwritten silently.

### Implementation for User Story 2

- [X] T029 [US2] Implement `/v1/sync/pull`, `/v1/sync/push`, and `/v1/bootstrap` in `server/src/sync/syncRoutes.ts`. Why: generic sync is the network boundary. Expected: incremental pull and batched push work. Risk: full-history network calls return.
- [X] T030 [US2] Implement server sync service in `server/src/sync/syncService.ts`. Why: revisions, tombstones, and ownership need one service. Expected: accepted/rejected changes are deterministic. Risk: entity-specific services diverge.
- [X] T031 [US2] Implement local sync queue in `packages/expense_repository/lib/src/sync/local_sync_queue.dart`. Why: offline writes need durable upload tracking. Expected: pending changes persist after restart. Risk: offline work is lost.
- [X] T032 [US2] Implement sync coordinator in `packages/expense_repository/lib/src/sync/sync_coordinator.dart`. Why: app needs controlled pull/push sequencing. Expected: bootstrap, push, pull, cursor save, and retry are centralized. Risk: race conditions and duplicates.
- [X] T033 [US2] Implement local settings repository in `packages/expense_repository/lib/src/local/local_settings_repository.dart`. Why: settings drive language, currency, AI defaults, and notifications. Expected: `SettingsRepository` works offline. Risk: startup blocks on backend.
- [X] T034 [US2] Implement local category and alias repositories in `packages/expense_repository/lib/src/local/local_category_repository.dart` and `local_category_alias_repository.dart`. Why: expense entry and AI category matching need local categories. Expected: categories/aliases sync and archive locally. Risk: AI/manual entry loses category context.
- [X] T035 [US2] Implement local expense repository in `packages/expense_repository/lib/src/local/local_expense_repository.dart`. Why: expense CRUD is the core value. Expected: existing `ExpenseRepository` consumers work from local DB. Risk: screens need rewrites.
- [X] T036 [US2] Add sync status UI mapping in `lib/widgets/sync_status_banner.dart`. Why: users must understand pending/offline/backend failures. Expected: local pending state replaces Firestore metadata assumptions in VPS mode. Risk: users think unsynced data is saved remotely.

**Checkpoint**: MVP local-first sync works for settings, categories, aliases, and expenses.

---

## Phase 5: User Story 3 - Existing Firestore users migrate without data loss (Priority: P1)

**Goal**: Existing Firestore accounts are backfilled to PostgreSQL with idempotent verification.

**Independent Test**: Import a seeded Firestore user twice and prove counts, ids, and field hashes match without duplicates.

### Tests for User Story 3

- [X] T037 [P] [US3] Add Firestore export fixture tests in `server/tests/integration/firestoreBackfillFixtures.test.ts`. Why: migration must handle current document shapes. Expected: representative fixtures parse correctly. Risk: old records fail import.
- [X] T038 [P] [US3] Add idempotency tests in `server/tests/integration/backfillIdempotency.test.ts`. Why: migration retries are inevitable. Expected: rerun creates no duplicates. Risk: duplicate expenses ruin trust.
- [X] T039 [P] [US3] Add migration verification tests in `server/tests/integration/verifyMigration.test.ts`. Why: counts alone are not enough. Expected: hashes and important fields compare. Risk: subtle field loss goes unnoticed.

### Implementation for User Story 3

- [X] T040 [US3] Implement Firestore admin reader in `server/scripts/firestore-backfill.ts`. Why: migration should run server-side, not on user devices. Expected: script reads user-scoped collections safely. Risk: client-side migration depends on app adoption.
- [X] T041 [US3] Implement entity mappers in `server/src/migration/firestoreMappers.ts`. Why: Firestore shapes differ from relational rows. Expected: all current entities map with compatibility defaults. Risk: missing fields break reports/settings.
- [X] T042 [US3] Implement idempotent upsert/import service in `server/src/migration/importService.ts`. Why: interrupted migrations need retry. Expected: stable ids and conflict-safe upserts. Risk: duplicate or overwritten data.
- [X] T043 [US3] Implement migration verification CLI in `server/scripts/verify-migration.ts`. Why: operator needs proof before cutover. Expected: report includes counts, hashes, missing records, duplicate records, and warnings. Risk: cutover happens blind.
- [X] T044 [US3] Add migration comparison mode in `packages/expense_repository/lib/src/sync/migration_comparison_repository.dart`. Why: app can compare legacy Firebase data and VPS/local data for pilot users. Expected: discrepancies are logged without user-facing noise. Risk: hidden migration mismatch.

**Checkpoint**: Existing user data can be imported, verified, and safely retried.

---

## Phase 6: User Story 4 - Existing features keep working on migrated data (Priority: P2)

**Goal**: All app feature surfaces use local/VPS repositories and preserve current behavior.

**Independent Test**: Run core journeys for Home, Reports, Budget, Category Budgets, Subscriptions, Export, AI, Settings, notifications, premium gates, and account deletion on migrated data.

### Tests for User Story 4

- [X] T045 [P] [US4] Add finance consistency tests in `test/migration/migrated_finance_consistency_test.dart`. Why: Home/Reports/Budget must agree. Expected: same dataset yields consistent totals and missing-rate metadata. Risk: migrated app shows contradictory money.
- [X] T046 [P] [US4] Add AI history/context tests in `test/migration/migrated_ai_history_test.dart`. Why: AI features should use migrated data without changing gateway secrets. Expected: local/backend data powers AI context and Worker token flow remains. Risk: AI looks empty after migration.
- [X] T047 [P] [US4] Add account deletion integration tests in `server/tests/integration/accountDeletion.test.ts`. Why: deletion is destructive and provider-sensitive. Expected: recent-auth requirement and backend tombstone/delete sequence are enforced. Risk: orphaned data or deleted auth with retained data.
- [X] T048 [P] [US4] Add export/backup migrated-data tests in `test/migration/migrated_export_backup_test.dart`. Why: user portability must survive storage switch. Expected: exports contain the same filtered data. Risk: users cannot retrieve data.

### Implementation for User Story 4

- [X] T049 [US4] Implement local budget and category budget repositories in `packages/expense_repository/lib/src/local/local_budget_repository.dart` and `local_category_budget_repository.dart`. Why: budget screens must leave Firestore. Expected: existing budget blocs keep working. Risk: budget UI breaks after cutover.
- [X] T050 [US4] Implement local recurring expense repository in `packages/expense_repository/lib/src/local/local_recurring_expense_repository.dart`. Why: subscriptions and recurring generation depend on rules. Expected: recurring scheduler uses local rules. Risk: recurring expenses stop generating.
- [X] T051 [US4] Implement local saving goal repository in `packages/expense_repository/lib/src/local/local_saving_goal_repository.dart`. Why: saving goals are user-owned app data. Expected: goals work offline and sync. Risk: feature silently remains legacy-only.
- [X] T052 [US4] Implement local wallet and transfer repositories in `packages/expense_repository/lib/src/local/local_wallet_account_repository.dart` and `local_transfer_repository.dart`. Why: wallet/transfer foundations must migrate with expenses. Expected: wallet snapshots and transfer exclusion remain valid. Risk: financial totals include transfers incorrectly.
- [X] T053 [US4] Implement local AI action log repository in `packages/expense_repository/lib/src/local/local_ai_action_log_repository.dart`. Why: AI audit history should not stay in Firestore. Expected: previews/confirmations/cancellations log locally and sync. Risk: AI accountability is lost.
- [X] T054 [US4] Update finance services to read from migrated repositories where they currently request full Firestore history in `lib/screens/auth/views/auth_gate.dart`, `lib/services/notifications/notification_scheduler.dart`, and related callers. Why: full-history reads must not reappear after migration. Expected: loaded/local data powers calculations. Risk: sync/API still becomes expensive.
- [X] T055 [US4] Keep Cloudflare AI gateway path unchanged in `lib/ai/services/ai_service_factory.dart` and document only context-source changes. Why: data migration must not expose AI provider keys. Expected: Worker remains the provider boundary. Risk: mixing AI gateway migration with data migration increases blast radius.
- [X] T056 [US4] Implement backend account deletion route in `server/src/account/accountRoutes.ts` and service in `server/src/account/accountDeletionService.ts`. Why: backend-owned data deletion is safer than client recursive deletion. Expected: deletion status is retryable and auditable. Risk: destructive partial failures.

**Checkpoint**: All existing app-owned data surfaces run on local/VPS repositories.

---

## Phase 7: User Story 5 - Operators can deploy, monitor, backup, and rollback safely (Priority: P3)

**Goal**: VPS production operation is documented, testable, and recoverable.

**Independent Test**: Deploy staging, run health checks, backup, restore to test DB, and execute rollback drill.

### Tests for User Story 5

- [X] T057 [P] [US5] Add backup restore smoke script in `server/scripts/backup-restore-check.ts`. Why: backups are useless until restore is proven. Expected: restored DB passes integrity checks. Risk: false confidence in broken backups.
- [X] T058 [P] [US5] Add deployment health smoke tests in `server/tests/integration/healthSmoke.test.ts`. Why: monitoring should catch DB/auth failures. Expected: degraded states are visible. Risk: backend appears up while unusable.

### Implementation for User Story 5

- [X] T059 [US5] Write VPS deployment instructions in `docs/backend/vps-postgres-runbook.md`. Why: aaPanel/Nginx/PM2/systemd setup must be repeatable. Expected: deploy steps, env vars, SSL, and service restart are documented. Risk: production setup depends on memory.
- [X] T060 [US5] Write PostgreSQL backup and restore procedure in `docs/backend/postgres-backup-restore.md`. Why: self-hosting requires disaster recovery. Expected: daily encrypted off-server backup and restore drill steps exist. Risk: VPS disk loss means user data loss.
- [X] T061 [US5] Write migration cutover and rollback runbook in `docs/backend/migration-cutover-rollback.md`. Why: production switch needs a controlled sequence. Expected: freeze, backfill, verify, switch, monitor, rollback steps are explicit. Risk: no clean escape from bad cutover.
- [X] T062 [US5] Add backend observability hooks in `server/src/observability/logger.ts` and `server/src/observability/metrics.ts`. Why: failures need investigation without logging sensitive finance text. Expected: privacy-safe logs and request ids. Risk: hard-to-debug production issues or sensitive logging.

**Checkpoint**: VPS migration is deployable and recoverable.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Close docs, verification, and safety gaps before implementation is considered complete.

- [X] T063 [P] Update `docs/finance/currency-policy.md` with PostgreSQL/local-first rate snapshot policy. Why: reports must not change unexpectedly due to new daily rates. Expected: current and historical rate behavior is documented. Risk: future workers reintroduce mutable old reports.
- [X] T064 [P] Update `README.md` with new architecture summary and local dev commands. Why: onboarding must match the migrated system. Expected: Firebase Auth, VPS API, local DB, Cloudflare AI roles are clear. Risk: contributors run the wrong backend.
- [X] T065 [P] Update `.specify/memory/constitution.md` after implementation to reflect PostgreSQL, VPS backend, Drift, repository factory, and Firestore legacy status. Why: project rules must track architecture changes. Expected: future agents follow new boundaries. Risk: old Firestore assumptions return.
- [X] T066 Run backend verification: `cd server; npm run typecheck; npm test`. Why: backend is now production-critical. Expected: typecheck and tests pass. Risk: server deploys broken.
- [X] T067 Run Flutter generation and verification: `flutter pub get`, `flutter gen-l10n`, Drift generation, targeted repository tests, and `flutter analyze --no-pub`. Why: Flutter app must compile against new repository mode. Expected: generated code and analyzer are clean. Risk: local DB code breaks build.
- [ ] T068 Run migration dry-run and verification against seeded staging Firebase/PostgreSQL data. Why: the migration is the highest data-loss risk. Expected: no duplicates, no missing records, no field hash mismatches. Risk: bad import reaches production. Blocked: requires seeded staging Firebase and PostgreSQL environments with real credentials.
- [ ] T069 Run real-device QA in VPS mode for auth, onboarding, Home, Add Expense, Reports, Settings, AI, Export, notifications, app lock, account deletion, offline/reconnect sync, and Arabic/English switching. Why: migration changes app startup and data flow. Expected: user journeys work before release. Risk: backend works but mobile UX fails. Blocked: requires a real device and configured VPS/staging endpoint.
- [ ] T070 Build release artifact only after explicit user request and after T066-T069 pass. Why: user asked not to build except when needed. Expected: final artifact is created from verified migration state. Risk: premature build wastes time and hides failures. Blocked: T068 and T069 are not complete, and no release build was requested for this phase.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 Setup**: starts immediately.
- **Phase 2 Foundation**: depends on setup and blocks all stories.
- **US1 Identity**: starts after auth/db foundation.
- **US2 Local-first sync**: starts after local DB, API client, and sync schema.
- **US3 Migration**: can start after schema exists and can run in parallel with US2 after foundational contracts stabilize.
- **US4 Feature parity**: depends on MVP local repositories from US2 and entity coverage from US3.
- **US5 Operations**: can start after backend shape is known, then must finish before production cutover.
- **Polish/Verification**: depends on selected implementation scope.

### Parallel Opportunities

- Backend schema files can be split by entity after T006 conventions are set.
- Local repository implementations can be split by entity after T013-T016.
- Migration scripts and sync tests can run in parallel after schema/mappers exist.
- Operations docs can run in parallel once endpoint/env decisions are stable.

## Implementation Strategy

### MVP First

1. Complete Phase 1 and Phase 2.
2. Complete US1 identity.
3. Complete US2 only for settings, categories, aliases, and expenses.
4. Run local/offline/sync tests.
5. Demo with a test user before migrating all secondary surfaces.

### Full Cutover

1. Add all remaining repositories and migration mappers.
2. Backfill and verify staging users.
3. Enable pilot accounts in VPS mode.
4. Run real-device QA.
5. Switch production users only after backup and rollback drill.

### What Must Not Happen

- Do not put PostgreSQL credentials or Firebase Admin service account JSON in Flutter.
- Do not remove Firebase Auth.
- Do not move AI provider keys out of Cloudflare Worker into Flutter.
- Do not hard-delete synced records before tombstones propagate.
- Do not switch production users before migration verification and rollback are proven.
- Do not build a release artifact until the user explicitly asks or cutover verification requires it.
