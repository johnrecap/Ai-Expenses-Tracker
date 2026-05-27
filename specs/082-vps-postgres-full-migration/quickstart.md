# Quickstart: VPS PostgreSQL Full Migration

This quickstart is for implementing and validating the migration. It is not a production secret checklist.

## 1. Local backend setup

1. Create `server/.env` from an ignored example file.
2. Configure local PostgreSQL connection.
3. Configure Firebase Admin credentials outside source control.
4. Install backend dependencies.
5. Run database migrations.
6. Start the backend locally.
7. Verify `GET /health` reports database and auth verifier readiness.

## 2. Flutter local-first setup

1. Add Drift/SQLite dependencies to Flutter.
2. Generate Drift code.
3. Run repository tests for local settings, categories, and expenses.
4. Start the app in legacy Firebase mode and confirm no behavior changed.
5. Start the app in VPS/local-first mode against local backend and confirm bootstrap/sync.

## 3. Migration dry run

1. Seed a test Firebase user with expenses, settings, categories, budgets, recurring expenses, saving goals, wallets, transfers, aliases, and AI action logs.
2. Run the Firestore backfill script in dry-run mode.
3. Run the import against a staging PostgreSQL database.
4. Run verification script:
   - Compare record counts per entity.
   - Compare stable ids.
   - Compare important field hashes.
   - Confirm deleted/archived states.
5. Rerun the import and confirm no duplicates are created.

## 4. Sync validation

1. Sign in on device A and complete bootstrap.
2. Turn device A offline.
3. Create, edit, and delete sample records.
4. Restart the app while offline and verify local records remain.
5. Reconnect and run sync.
6. Sign in on device B and verify records converge.
7. Edit the same record on both devices and confirm documented conflict behavior.

## 5. Cutover readiness

1. Run backend contract/integration tests.
2. Run Flutter repository and core widget tests in both legacy and VPS modes where feasible.
3. Run Cloudflare Worker tests only if AI request contracts changed.
4. Create a PostgreSQL backup.
5. Restore the backup to a test database and run integrity checks.
6. Confirm rollback procedure before enabling production users.

## 6. Production VPS checklist

1. PostgreSQL is not publicly exposed.
2. Nginx/aaPanel reverse proxy uses HTTPS.
3. Backend runs under PM2 or systemd with restart policy.
4. Secrets are stored in server environment, not source code.
5. Firewall allows only required ports.
6. Logs rotate.
7. Backups are encrypted and copied off-server.
8. Health checks and alerts are configured.
