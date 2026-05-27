# VPS PostgreSQL Runbook

This runbook belongs to Spec Kit plan `082-vps-postgres-full-migration`.

## Purpose

Operate the self-hosted API that will replace Firestore for app-owned data while keeping Firebase Auth and the Cloudflare AI gateway.

## Deployment Checklist

- Keep PostgreSQL bound to localhost or a private network. Do not expose port 5432 publicly.
- Put the Node.js API behind aaPanel/Nginx with HTTPS.
- Store `DATABASE_URL` and Firebase Admin credentials in server environment files outside Git.
- Run database migrations before switching traffic.
- Run `/health` after every deploy.
- Keep Cloudflare Worker AI provider secrets out of the VPS app unless a later plan explicitly moves the AI gateway.

## VPS Baseline

1. Create a non-root Linux user for the API process.
2. Install Node.js 20 LTS, npm, PostgreSQL client tools, Git, and either PM2 or a systemd service.
3. In aaPanel, keep PostgreSQL local-only. If aaPanel creates a public database listener, disable external access at the firewall and PostgreSQL config.
4. Create a PostgreSQL database and app role with the minimum privileges required for the app schema.
5. Put the API behind aaPanel/Nginx with HTTPS. Proxy only HTTPS traffic to the local API port.
6. Do not store service account JSON in the repo. Use environment variables in an ignored `.env`/service file.

## Required Environment

```text
NODE_ENV=production
HOST=127.0.0.1
PORT=8080
DATABASE_URL=postgres://...
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n
LOG_LEVEL=info
```

## Deploy Steps

1. Pull the selected Git branch or upload the reviewed release bundle to the VPS.
2. Run `cd server && npm ci`.
3. Run `npm run typecheck` and `npm test` on the VPS or in CI before replacing the live process.
4. Run `npm run db:migrate` against the target database.
5. Restart the API through PM2/systemd.
6. Check `https://<api-domain>/health`; status must be `ok`.
7. Check `/metrics` from a trusted network path only. Do not expose metrics publicly unless Nginx protects it.

## PM2 Example

```bash
cd /var/www/ai-expenses/server
npm ci
npm run build
pm2 start dist/app.js --name ai-expenses-api --update-env
pm2 save
```

## Nginx Proxy Notes

On aaPanel servers with multiple HTTPS sites on the same public IP, keep every
public vhost on the same `listen` style. If one site uses the bound public IP
(`listen 212.47.65.222:443 ssl;`) and another uses wildcard
(`listen 443 ssl http2;`), Nginx can route Cloudflare HTTPS/SNI traffic to the
wrong vhost. Normalize API proxy vhosts to the bound IP form used by the other
sites:

```nginx
listen 212.47.65.222:80;
listen 212.47.65.222:443 ssl http2;
server_name api.saeeddev.com;
```

If aaPanel emits `listen 443 quic;` but the installed Nginx binary does not
support QUIC, disable that line before reload. Always run
`/www/server/nginx/sbin/nginx -t` before reloading aaPanel Nginx, not the
system `/etc/nginx` command path.

```nginx
location / {
  proxy_pass http://127.0.0.1:8080;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

Block or protect `/metrics` if the API domain is public.

Smoke-test both the local vhost and the Cloudflare route after every new proxy:

```bash
curl -H "Host: api.saeeddev.com" http://127.0.0.1/health
curl "https://api.saeeddev.com/health?nocache=$(date +%s)"
```

## AI Gateway Boundary

- The data migration changes the context source only: finance history comes from local/VPS repositories instead of Firestore-backed repositories.
- Flutter must continue calling the existing Cloudflare AI gateway. AI provider keys stay in Cloudflare and must not be copied into Flutter or the VPS API.
- AI action logs are migrated as app-owned audit data, but provider requests still flow through the Worker boundary.

## Backup Checklist

- Schedule daily encrypted `pg_dump` backups.
- Copy backups off the VPS.
- Run restore drills against a separate database before production cutover.
- Run `npm run backup:restore-check` with `RESTORE_DATABASE_URL` pointing to a disposable restore-check database after backup tooling changes.

## Rollback Checklist

- Keep the previous API build available.
- Keep Firestore legacy reads available during the migration window.
- Do not remove Firestore rules/indexes until the cutover rollback window has passed.
- Keep `REPOSITORY_RUNTIME_MODE=firebaseLegacy` as the emergency mobile rollback until the migration verification window closes.
- If `/health` becomes degraded after a deploy, roll back the API process first, then investigate database/auth verifier failures.

## Incident Notes

- Treat failed sync pushes, auth verification failures, and database connectivity failures as production incidents.
- Logs must not include raw expense descriptions, receipt text, auth tokens, database credentials, or AI provider keys.
- Preserve request ids from logs when investigating user reports.
- Check disk space, PostgreSQL connection count, Nginx errors, PM2/systemd restart loops, and Firebase Admin credential validity before changing application code during an incident.
