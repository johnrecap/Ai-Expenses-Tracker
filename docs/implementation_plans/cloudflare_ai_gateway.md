# Cloudflare AI Gateway Implementation Plan

## Purpose

The free AI backend path uses Cloudflare Worker instead of Firebase Functions so Firebase can remain on Spark. Firebase still owns Auth and Firestore user data. Cloudflare owns only AI provider calls, per-user quota counters, and safe operational usage logs.

Spec Kit plan: `specs/018-cloudflare-ai-gateway/plan.md`.

## Runtime Split

- Flutter sends authenticated AI requests to `AI_GATEWAY_URL=https://<worker-url>/aiParse`.
- The Worker verifies Firebase ID tokens with Google Secure Token public keys.
- The Worker enforces per-user daily limits before Gemini calls.
- Gemini API key is stored as Cloudflare secret `GEMINI_API_KEY`.
- Firestore continues to store expenses, categories, budgets, settings, saving goals, and AI action logs under `users/{userId}`.
- Firebase Functions are not deployed for this free-plan route.

## Endpoints

- `POST /aiParse`: natural-language command parsing.
- `POST /aiReceipt`: receipt image extraction.
- `POST /aiAdvice`: short financial advice from supplied summary only.

All endpoints return the existing Flutter-compatible contract:

- Success: `ok`, `provider`, `model`, `requestId`, `usage`, `quota`, `structuredJson`.
- Failure: `ok`, `provider`, `model`, `requestId`, `errorCode`, `errorMessage`.

## Free Limits

- Text parse: 5 requests per user per UTC day.
- Receipt extraction: 3 requests per user per UTC day.
- Financial advice: 3 requests per user per UTC day.
- Global limits are not configured by default. They exist only as emergency controls through optional env vars.

Gemini free quota is external to this app and can still be exhausted. When that happens, the Worker returns `rate_limited`, and Flutter keeps manual expense entry and deterministic local features available.

## Security Notes

- Open proxy abuse: mitigated by Firebase ID token verification on all provider-backed routes.
- Token spoofing: mitigated by issuer, audience, expiry, subject, signature, and Google key checks.
- Key leak: mitigated by Cloudflare secret storage; Flutter never receives provider keys.
- Quota bypass: mitigated by D1 counters consumed before provider calls.
- Prompt injection: mitigated by schema-only prompts and strict JSON parsing.
- Receipt privacy: raw images are sent only to Gemini for the active request and are not written to D1 usage logs.

Residual risks:

- Provider free quota and pricing can change outside the app.
- Provider outage can temporarily disable AI, while manual and local deterministic features remain available.
- Cloudflare account configuration is required for remote deployment.

## Verification Commands

Worker:

```bat
cd workers\ai-gateway
npm install
npm run typecheck
npm test
npx wrangler d1 migrations apply ai_expenses_gateway --local
```

Flutter:

```bat
cd /d "C:\Users\SOUQ\Downloads\apps\Expense-Tracker\Expense-Tracker-main"
& "C:\flutter\bin\flutter.bat" analyze
& "C:\flutter\bin\flutter.bat" test
& "C:\flutter\bin\flutter.bat" build apk --release --dart-define=AI_GATEWAY_URL=https://<worker-url>/aiParse --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
```

## Deployment Notes

Deployed Worker URL field:

```text
AI_GATEWAY_URL=https://ai-expenses-gateway.mohamedsaied-m20.workers.dev/aiParse
```

Cloudflare resources created:

- D1 database: `ai_expenses_gateway`
- D1 database id: `89d0a767-f2ec-48fd-83ff-2975c9e25f85`
- Worker: `ai-expenses-gateway`
- Worker URL: `https://ai-expenses-gateway.mohamedsaied-m20.workers.dev`
- Secret configured: `GEMINI_API_KEY`

## Verification Results

- `npm install`: passed and created `workers/ai-gateway/package-lock.json`.
- `npm run typecheck`: passed.
- `npm test`: passed, 7 files and 42 Worker tests.
- Local D1 migration: passed for `0001_ai_usage.sql`.
- Remote D1 migration: passed for `0001_ai_usage.sql`.
- Remote D1 table check: `ai_usage_daily` and `ai_usage_logs` exist.
- `npx wrangler deploy --minify`: passed, current Worker version `110ee41b-db8a-4bc1-bf5a-ca8b80606caf`.
- Deployed unauthenticated smoke checks: `/aiParse`, `/aiReceipt`, and `/aiAdvice` returned HTTP 401.
- Authenticated remote smoke check: passed after uploading a valid Gemini key and wrapping Cloudflare `fetch` instead of storing the raw function reference. Temporary Firebase user was created and deleted successfully; `/aiParse` returned Gemini structured JSON with `intent=add_expense`, `amount=50`, and remaining quota.
- `flutter analyze`: passed with no issues.
- `flutter test`: passed with 110 tests.
- Flutter release APK build: passed at `build\app\outputs\flutter-apk\app-release.apk` with size 64.2 MB.
- Secret scan: local Gemini key was not found in source/docs/config files outside ignored local env files.

## Known Limitations

- Full on-device authenticated AI test was not run here because `adb` is not available on PATH in this shell.
- The Gemini key used during validation was exposed during manual setup. Rotate it before a public release, then run `npx wrangler secret put GEMINI_API_KEY` and `npx wrangler deploy --minify` again.
- Gemini free quota remains controlled by Google and may rate-limit independently from the app's per-user quota.

## Release Note

Added a Cloudflare Worker AI gateway under `workers/ai-gateway` with Firebase Auth token verification, D1-backed per-user AI quota, Gemini 2.5 Flash provider adapter, structured JSON response validation, receipt/advice endpoints, and Flutter gateway compatibility tests. Firebase Functions remain untouched and are not part of the free-plan AI path. The release APK was rebuilt against the deployed Worker URL.
