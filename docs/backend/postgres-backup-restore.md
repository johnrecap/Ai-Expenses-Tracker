# PostgreSQL Backup And Restore

This procedure belongs to Spec Kit plan `082-vps-postgres-full-migration`.

## Goals

- Produce daily encrypted PostgreSQL backups.
- Store at least one copy off the VPS.
- Prove restore into a separate database before production cutover.
- Never test restore against the live production database.

## Daily Backup

Use `pg_dump` custom format so restore can be selective and verifiable:

```bash
export BACKUP_DIR=/var/backups/ai-expenses
export DATE=$(date +%Y-%m-%d)
mkdir -p "$BACKUP_DIR"
pg_dump --format=custom --no-owner --file "$BACKUP_DIR/ai-expenses-$DATE.dump" "$DATABASE_URL"
```

Encrypt before copying off-server:

```bash
gpg --symmetric --cipher-algo AES256 "$BACKUP_DIR/ai-expenses-$DATE.dump"
```

Move encrypted backups to an off-server location using a provider you control. Do not keep the only backup on the same VPS disk.

## Retention

- Daily backups: keep 14 days.
- Weekly backups: keep 8 weeks.
- Monthly backups: keep 12 months after public launch.

Adjust retention only after storage cost and privacy requirements are clear.

## Restore Drill

Create a disposable restore-check database:

```bash
createdb ai_expenses_restore_check
export RESTORE_DATABASE_URL=postgres://user:password@127.0.0.1:5432/ai_expenses_restore_check
cd /var/www/ai-expenses/server
npm run backup:restore-check
```

The script refuses to restore into `DATABASE_URL`. It runs `pg_dump`, restores into `RESTORE_DATABASE_URL`, and runs a basic SQL smoke query.

## Manual Restore

```bash
pg_restore --clean --if-exists --no-owner --dbname "$RESTORE_DATABASE_URL" /path/to/backup.dump
psql "$RESTORE_DATABASE_URL" -c "select count(*) from users;"
```

After restore, run migration verification against seeded user exports before using the restored data for any cutover decision.

## Failure Handling

- If backup creation fails, treat it as a production incident.
- If off-server copy fails, keep the local encrypted backup but fix the copy path within the same day.
- If restore drill fails, do not proceed with migration cutover.
- If a backup contains suspect data, keep it quarantined and create a fresh backup after correcting the source issue.
