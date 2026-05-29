# Tasks: VPS Pilot Cutover Readiness

**Input**: `specs/083-vps-pilot-cutover-readiness/spec.md` and `plan.md`  
**Prerequisites**: Deployed API health at `https://api.saeeddev.com/health`, Firebase Auth project access, PostgreSQL database, aaPanel/Cloudflare access, real Android test device.

Each task states owner, purpose, expected result, risk, and concrete target.

## Phase 1: Codex - Durable PostgreSQL Sync (P0)

**Purpose**: Replace temporary in-memory sync with durable, user-scoped PostgreSQL persistence.

- [X] T001 [Codex] Inspect `server/src/sync/syncService.ts`, `server/src/db/schema/*.ts`, and migration output before editing. Why: current sync is in-memory and schema shape must be understood before persistence work. Expected: exact table/index changes are known. Risk: changing schema blindly can break migration or ownership.
- [X] T002 [Codex] Add or refine PostgreSQL schema/indexes for durable sync changes in `server/src/db/schema/*.ts`. Why: sync changes need durable revisions, cursor ordering, tombstone metadata, user scope, device IDs, and entity IDs. Expected: schema supports incremental pull/push and user isolation. Risk: missing indexes makes sync slow or cross-user access possible.
- [X] T003 [Codex] Commit a reviewed SQL migration plus apply script under `server/src/db/migrations/` and `server/scripts/`. Why: VPS database changes must be reproducible even though the deployed server already generated its initial local Drizzle baseline. Expected: staging/production can apply the same durable sync schema without rerunning production `db:generate`. Risk: manual SQL drift between local and VPS.
- [X] T004 [Codex] Implement a PostgreSQL-backed sync service replacing `InMemorySyncService` for runtime use. Why: accepted sync changes must survive process restarts. Expected: `push` writes accepted changes transactionally and `pull` reads by user/cursor. Risk: data loss after PM2 restart if not durable.
- [X] T005 [Codex] Preserve conflict/rejection behavior from existing contract tests. Why: mobile retry logic depends on stable accepted/rejected response shape. Expected: old sync contract tests still pass. Risk: app/backend version mismatch.
- [X] T006 [Codex] Add integration tests proving sync survives service recreation/process-like restart. Why: persistence must be proven, not assumed. Expected: push data, recreate service, pull data returns same revision. Risk: a green health endpoint hides volatile data.
- [X] T007 [Codex] Add user isolation tests for push/pull. Why: a finance app must never leak one user's data to another. Expected: user B cannot pull user A changes. Risk: severe privacy/security incident.
- [X] T008 [Codex] Add tombstone/delete tests. Why: deletes must propagate to other devices without hard-delete races. Expected: delete operations are stored and pulled with metadata. Risk: deleted records reappear or fail to disappear.
- [X] T009 [Codex] Run backend verification: `cd server; npm run typecheck; npm test`. Why: backend is production-critical. Expected: all backend tests pass. Risk: deploying a broken sync service.

## Phase 2: Codex - Flutter VPS API Wiring (P0)

**Purpose**: Make `vpsLocalFirst` actually talk to the VPS while preserving local-first behavior and Firebase rollback.

- [X] T010 [Codex] Add `VPS_API_BASE_URL` runtime configuration in the repository/API layer. Why: Flutter currently has no compile-time VPS API URL. Expected: `--dart-define=VPS_API_BASE_URL=https://api.saeeddev.com` is read safely. Risk: hardcoded URL or missing URL blocks staging/prod separation.
- [X] T011 [Codex] Add validation/fallback behavior for missing `VPS_API_BASE_URL` in VPS mode. Why: bad builds should fail clearly instead of silently using local-only mode. Expected: user/developer sees a clear sync configuration error. Risk: test builds appear to sync but never contact VPS.
- [X] T012 [Codex] Wire `FirebaseTokenProvider` and `VpsApiClient` into `AuthenticatedRepositoryFactory` or app startup. Why: every VPS request must include Firebase ID token authentication. Expected: signed-in users can call `/v1/users/me`, `/v1/bootstrap`, and sync endpoints. Risk: generic connection failures or unauthenticated requests.
- [X] T013 [Codex] Wire `SyncCoordinator` into VPS runtime mode. Why: local repositories need a single push/pull coordinator. Expected: bootstrap, pending push, pull cursor, and retry sequencing are centralized. Risk: duplicated ad hoc sync paths.
- [X] T014 [Codex] Trigger sync at safe lifecycle points: after sign-in bootstrap, after local writes, on app resume, and on reconnect where available. Why: users expect offline edits to sync without manual terminal work. Expected: data converges without blocking UI. Risk: excessive retry loops or stale local data.
- [ ] T015 [Codex] Ensure sync status banner reflects pending, syncing, synced, and failed states in VPS mode. Why: users must know whether data reached the backend. Expected: UI status is honest and actionable. Risk: users trust unsynced local-only data. Status: deferred after implementation review; pending/synced local expense status is wired, but explicit syncing/failed VPS retry UI still needs a focused UI pass.
- [X] T016 [Codex] Add tests for API base URL resolution and token header behavior. Why: config and auth are easy to break silently. Expected: headers and URL paths are deterministic. Risk: production app points at wrong endpoint.
- [X] T017 [Codex] Add tests for coordinator push/pull sequencing and retry-safe failure mapping. Why: sync bugs cause data loss or duplicates. Expected: failed push remains pending and successful push clears pending state. Risk: offline edits disappear.
- [X] T018 [Codex] Keep `firebaseLegacy` default in `RepositoryRuntimeMode`. Why: production rollback must remain one build flag away. Expected: no accidental cutover. Risk: unverified VPS path reaches all users.

## Phase 3: Codex - Migration Dry-Run Hardening (P0)

**Purpose**: Make Firebase-to-PostgreSQL staging migration verifiable before any real user cutover.

- [X] T019 [Codex] Review `server/scripts/firestore-backfill.ts`, `verify-migration.ts`, and migration mappers against current entities. Why: migrated schema must match current app data. Expected: gaps are identified and fixed or documented. Risk: hidden missing fields after import.
- [X] T020 [Codex] Ensure backfill can run for a single explicit Firebase UID first. Why: pilot migration should be narrow and reversible. Expected: owner can migrate one test account without touching all users. Risk: accidental broad migration.
- [X] T021 [Codex] Ensure verification reports counts, missing IDs, duplicate IDs, representative hashes, and warnings. Why: counts alone are insufficient for financial data. Expected: actionable pass/fail output. Risk: subtle corruption passes review.
- [X] T022 [Codex] Add or update tests for idempotent rerun behavior. Why: migration commands may be interrupted and retried. Expected: rerun does not duplicate data. Risk: duplicate expenses ruin trust.
- [X] T023 [Codex] Document exact owner-run staging commands in `docs/backend/migration-cutover-rollback.md` if missing. Why: the owner needs repeatable commands without guessing. Expected: command sequence is copyable with placeholders. Risk: live data is tested ad hoc.

## Phase 4: Owner - VPS Operations Hardening (P0/P1)

**Purpose**: Make the deployed VPS service recoverable, protected, and maintainable.

- [X] T024 [Owner] Run `pm2 startup` and follow the printed command. Why: API must restart after VPS reboot. Expected: `ai-expenses-api` comes online automatically. Risk: reboot causes silent outage.
- [X] T025 [Owner] Confirm `pm2 save` after final process state. Why: PM2 startup restores the saved process list. Expected: process list contains `ai-expenses-api`. Risk: startup restores an old or missing process.
- [X] T026 [Owner] Restrict `.env.production` permissions on the VPS. Why: database and Firebase Admin secrets must not be readable broadly. Expected: only the API owner/root can read the file. Risk: credential exposure.
- [X] T027 [Owner] Protect or block public `/metrics` in aaPanel/Nginx. Why: metrics can reveal operational internals. Expected: public requests to `/metrics` are denied or authenticated. Risk: public operational data exposure.
- [X] T028 [Owner] Configure daily PostgreSQL backup using `docs/backend/postgres-backup-restore.md`. Why: self-hosted data needs disaster recovery. Expected: encrypted dump is created daily. Risk: VPS disk loss means user data loss.
- [ ] T029 [Owner] Copy backups off the VPS. Why: a backup on the same disk does not protect against VPS loss. Expected: at least one off-server backup destination exists. Risk: disaster recovery fails.
- [X] T030 [Owner] Run one restore drill into a disposable database. Why: backups are only useful if restore works. Expected: restore-check succeeds and can query migrated tables. Risk: broken backups discovered too late. Status: restored into `ai_expenses_restore_check` and queried 15 tables; pg_restore reported one non-blocking default-privileges warning for an old role grant.
- [X] T031 [Owner] Keep Cloudflare DNS `api.saeeddev.com` proxied and verify `https://api.saeeddev.com/health` after Nginx changes. Why: app will depend on this stable URL. Expected: health returns JSON. Risk: app points to a broken endpoint.
- [X] T032 [Owner] Use `docs/backend/aapanel-cloudflare-subdomain-nginx-fix.md` for future subdomains. Why: aaPanel can generate conflicting `listen` styles. Expected: future subdomains do not route to wrong sites. Risk: repeated routing failures.

## Phase 5: Owner - Firebase, AI Gateway, And Secrets (P0/P1)

**Purpose**: Provide the external credentials/configuration needed for safe tests without exposing secrets.

- [X] T033 [Owner] Confirm Firebase Auth email/password and Google providers are enabled. Why: backend verifies Firebase tokens but Auth remains Firebase-owned. Expected: both login methods work. Risk: pilot accounts cannot sign in.
- [X] T034 [Owner] Confirm Android SHA-1/SHA-256 fingerprints for the build being tested. Why: Google Sign-In depends on correct fingerprints. Expected: signed/internal build can use Google login. Risk: Google sign-in fails only on device.
- [X] T035 [Owner] Keep Firebase Admin JSON private and only place required env values on VPS. Why: service account keys are high-impact secrets. Expected: no private key is pasted into chat or committed. Risk: credential compromise.
- [X] T036 [Owner] Provide the production Cloudflare Worker AI URL for build flags. Why: AI gateway is separate from VPS and still required for AI features. Expected: `AI_GATEWAY_URL` points to the real Worker endpoint. Risk: AI falls back to mock or fails on device. URL: `https://ai-expenses-gateway.mohamedsaied-m20.workers.dev`.
- [X] T037 [Owner] Confirm no provider keys are copied to Flutter or the VPS API. Why: Cloudflare Worker remains the only provider-secret boundary. Expected: secrets stay server-side/edge-side only. Risk: API key exposure in app binary or VPS logs.

## Phase 6: Joint - Staging Migration And Device QA (P0)

**Purpose**: Prove the full chain with one test account before any broader rollout.

- [X] T038 [Owner] Create or select a seeded Firebase test account with representative expenses, categories, settings, budgets, recurring items, saving goals, AI logs, wallets, and transfers. Why: migration must cover real shapes, not empty data. Expected: test account exercises important surfaces. Risk: production-only shape breaks later. Selected UID: `N8gZqOPSb1Xs0WY0RZvxKIcBxuY2`.
- [X] T039 [Codex] Provide exact staging backfill and verify commands using the selected UID. Why: owner should run commands without guessing. Expected: migration report is created. Risk: wrong account or broad migration.
- [X] T040 [Owner] Run staging backfill against the selected account and send sanitized output. Why: credentials and server access are owner-controlled. Expected: import completes or clear errors appear. Risk: hidden migration failure. Status: PostgreSQL-backed backfill for UID `N8gZqOPSb1Xs0WY0RZvxKIcBxuY2` reported 7 source records, 7 target records, 7 inserted, 0 updated, 0 skipped.
- [X] T041 [Owner] Run verification and preserve the report. Why: financial migration needs proof. Expected: no missing/duplicate/hash mismatch, or blockers are listed. Risk: unverified cutover. Status: sourceCount=7, targetCount=7, no missing/unexpected/hash mismatches/duplicates/warnings, passed=true.
- [X] T042 [Codex] Fix any migration mapper or sync issue revealed by the staging report. Why: real data often exposes fields tests missed. Expected: rerun passes. Risk: known mismatch reaches pilot. Status: fixed the discovered in-memory backfill target before verification; rerun passed cleanly.
- [X] T043 [Codex] Prepare the exact Flutter run/build command once code wiring is done. Why: owner needs one reliable command with `REPOSITORY_RUNTIME_MODE`, `VPS_API_BASE_URL`, and `AI_GATEWAY_URL`. Expected: no wrong-mode build. Risk: testing Firebase mode while thinking it is VPS mode.
- [ ] T044 [Owner] Install/run on a real Android device in `vpsLocalFirst` mode. Why: simulator/backend tests cannot validate device plugins and real network behavior. Expected: app starts and signs in. Risk: device-only crash.
- [ ] T045 [Owner] Test core journeys: auth, onboarding, Home, Add Expense, Reports, Settings, AI parse/receipt/advice, Export, notifications, app lock, account deletion warning, offline create, reconnect sync, Arabic/English switch. Why: migration changes data flow across the app. Expected: each journey passes or has a screenshot/log. Risk: backend works but user UX fails.
- [ ] T046 [Codex] Fix code issues found in real-device QA. Why: QA findings need repo changes, not manual workarounds. Expected: rerun checklist passes. Risk: release carries known pilot bugs.

## Phase 7: Release Gate And Rollback (P1)

**Purpose**: Keep pilot/release controlled and reversible.

- [X] T047 [Codex] Update runbook with final pilot command and rollback command. Why: operator needs one source of truth. Expected: commands are documented. Risk: wrong flag used during incident.
- [ ] T048 [Owner] Confirm whether pilot is limited to test accounts or broader internal users. Why: rollout size controls risk. Expected: clear scope. Risk: too many users hit an unproven backend.
- [X] T049 [Codex] Build release/internal artifact only after explicit owner request and after P0 tasks pass. Why: user previously requested no builds unless needed. Expected: artifact comes from verified state. Risk: premature build hides blockers. Status: owner explicitly requested an APK for device testing; built `build/app/outputs/flutter-apk/app-release.apk` with `vpsLocalFirst`, `https://api.saeeddev.com`, and the production Cloudflare Worker AI URL. Real-device QA remains tracked by T044-T046 before release approval.
- [ ] T050 [Owner] Keep rollback path ready by preserving Firebase rules/indexes and not deleting legacy data. Why: VPS pilot must have an escape route. Expected: `firebaseLegacy` remains viable. Risk: no recovery from cutover issue.

## Dependencies

- T001-T009 block any real VPS pilot.
- T010-T018 block app-level VPS testing.
- T019-T023 block production-like data migration.
- T024-T032 block reliable VPS operation.
- T033-T037 block real auth/AI build validation.
- T038-T046 block pilot approval.
- T047-T050 block release/internal distribution.

## Definition Of Done

- Backend uses PostgreSQL-backed sync persistence.
- Flutter `vpsLocalFirst` can sync with `https://api.saeeddev.com`.
- Staging migration dry-run passes for seeded account.
- PM2 startup, backups, restore drill, and `/metrics` protection are confirmed.
- Real-device QA passes or all blockers are documented in a new Spec Kit fix plan.
- Release build is created only after owner explicitly asks.
