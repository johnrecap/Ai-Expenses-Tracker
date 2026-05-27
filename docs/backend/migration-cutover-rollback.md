# Migration Cutover And Rollback

This runbook belongs to Spec Kit plan `082-vps-postgres-full-migration`.

## Cutover Preconditions

- `server` typecheck and tests pass.
- Flutter analyzer and targeted migration tests pass.
- PostgreSQL migrations ran successfully on staging and production.
- Daily encrypted backup exists and restore drill passed.
- Firestore backfill dry-run passed for representative users.
- `/health` reports `ok` on the VPS API.
- Cloudflare AI gateway remains unchanged and healthy.
- Mobile runtime flag can switch between `firebaseLegacy`, `migrationComparison`, and `vpsLocalFirst`.

## Staging Sequence

1. Back up Firestore export fixtures and PostgreSQL staging database.
2. Apply the sync persistence migration on the VPS/staging database.
3. Run Firestore backfill into staging.
4. Run migration verification: counts, ids, hashes, missing records, duplicates.
5. Start app in `migrationComparison` mode for seeded accounts.
6. Review mismatch logs. Do not proceed if financial totals, settings, categories, or AI action logs differ unexpectedly.
7. Run real-device QA for auth, onboarding, Home, Add Expense, Reports, Settings, Export, notifications, app lock, account deletion, and offline/reconnect.

## VPS Code Update And Sync Migration

After pulling this branch on the VPS, apply the durable sync SQL once. The SQL
is idempotent so rerunning it is safe.

```bash
cd /var/www/ai-expenses
git pull
cd /var/www/ai-expenses/server

unset NODE_ENV
npm ci --include=dev
npm run build

set -a
. ./.env.production
set +a

npm run db:apply:sync-migration
pm2 restart ai-expenses-api --update-env
curl http://127.0.0.1:8080/health
curl "https://api.saeeddev.com/health?nocache=$(date +%s)"
```

Do not rely on `npm run db:generate` on production for this corrective
migration. The branch ships the reviewed SQL and the apply script above.

## Single-User Staging Commands

Use one seeded Firebase UID first. Do not run broad imports until one-user
verification is clean.

```bash
cd /var/www/ai-expenses/server
set -a
. ./.env.production
set +a

export TEST_FIREBASE_UID="replace-with-seeded-test-uid"

npm run backfill:firestore -- --user "$TEST_FIREBASE_UID" \
  | tee "migration-backfill-$TEST_FIREBASE_UID.json"
```

The current backfill command reads one Firebase user and reports source/import
counts. Before pilot cutover, preserve the output and run verification against
the exported/migrated record sets:

```bash
npm run verify:migration -- \
  "source-records-$TEST_FIREBASE_UID.json" \
  "target-records-$TEST_FIREBASE_UID.json" \
  | tee "migration-verify-$TEST_FIREBASE_UID.json"
```

Verification must report no missing records, no unexpected target records, no
duplicate keys, no hash mismatches, and no warnings. If it fails, keep the app
in `firebaseLegacy` mode and fix the mapper/import issue in staging first.

## Production Cutover Sequence

1. Announce a migration window if users are already public.
2. Freeze or minimize Firestore writes for selected pilot users.
3. Take a fresh PostgreSQL backup and confirm restore-check database works.
4. Run final Firestore backfill for pilot users.
5. Run migration verification and store the report.
6. Enable `vpsLocalFirst` for pilot users only.
7. Monitor `/health`, `/metrics`, API logs, sync rejection counts, account errors, and user reports.
8. Expand rollout only after the pilot window shows no data correctness issues.

## Pilot App Commands

After durable sync, staging verification, and real-device prerequisites pass,
run a pilot build or device run with the VPS runtime flags:

```bash
flutter run \
  --dart-define=REPOSITORY_RUNTIME_MODE=vpsLocalFirst \
  --dart-define=VPS_API_BASE_URL=https://api.saeeddev.com \
  --dart-define=AI_GATEWAY_URL=<cloudflare-worker-url>/aiParse \
  --dart-define=AI_PROVIDER=gemini \
  --dart-define=AI_MODEL=gemini-2.5-flash
```

For migration comparison instead of direct pilot mode:

```bash
flutter run \
  --dart-define=REPOSITORY_RUNTIME_MODE=migrationComparison \
  --dart-define=VPS_API_BASE_URL=https://api.saeeddev.com \
  --dart-define=AI_GATEWAY_URL=<cloudflare-worker-url>/aiParse \
  --dart-define=AI_PROVIDER=gemini \
  --dart-define=AI_MODEL=gemini-2.5-flash
```

Rollback build/run flag:

```bash
flutter run --dart-define=REPOSITORY_RUNTIME_MODE=firebaseLegacy
```

Do not create a release artifact from VPS mode until staging migration,
real-device QA, backup/restore drill, and `/metrics` protection have passed.

## Rollback Triggers

- `/health` reports `degraded` for database or Firebase verifier.
- Sync push rejection rate spikes.
- Home/Reports/Budget totals disagree for migrated users.
- Backfill verification reports missing records or hash mismatches.
- Account deletion or profile update fails in a way that can orphan data.
- Restore drill fails during the migration window.

## Rollback Steps

1. Switch affected users back to `firebaseLegacy`.
2. Stop rollout and keep the current PostgreSQL state intact for investigation.
3. Revert the API process to the previous known-good release if the issue is backend code.
4. Keep Firestore rules/indexes active and do not delete legacy data.
5. Compare Firestore and PostgreSQL records for affected users using verification reports.
6. Fix forward in staging, then rerun backfill and verification before another pilot.

## What Must Not Happen

- Do not hard-delete Firestore data during the rollback window.
- Do not point restore drills at the production database.
- Do not expose PostgreSQL publicly.
- Do not move AI provider keys from Cloudflare to Flutter or the VPS API as part of this migration.
- Do not rely on counts only; field hashes and important metadata must be verified.
