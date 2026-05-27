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
2. Run Firestore backfill into staging.
3. Run migration verification: counts, ids, hashes, missing records, duplicates.
4. Start app in `migrationComparison` mode for seeded accounts.
5. Review mismatch logs. Do not proceed if financial totals, settings, categories, or AI action logs differ unexpectedly.
6. Run real-device QA for auth, onboarding, Home, Add Expense, Reports, Settings, Export, notifications, app lock, account deletion, and offline/reconnect.

## Production Cutover Sequence

1. Announce a migration window if users are already public.
2. Freeze or minimize Firestore writes for selected pilot users.
3. Take a fresh PostgreSQL backup and confirm restore-check database works.
4. Run final Firestore backfill for pilot users.
5. Run migration verification and store the report.
6. Enable `vpsLocalFirst` for pilot users only.
7. Monitor `/health`, `/metrics`, API logs, sync rejection counts, account errors, and user reports.
8. Expand rollout only after the pilot window shows no data correctness issues.

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
