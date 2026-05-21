# Quickstart: Cloudflare AI Gateway

This quickstart describes the intended free-plan AI gateway path. It does not deploy Firebase Functions and does not require Firebase Blaze.

## Prerequisites

- Firebase project exists: `ai-expenses-tracker-studio`.
- Firebase Auth works in the Flutter app.
- Firestore stays on Spark plan.
- Cloudflare account exists.
- Gemini API key exists.
- Node.js and npm are installed.
- `wrangler` can be installed through npm or run with `npx`.

## 1. Create Cloudflare Worker Workspace

Expected final path:

```text
workers/ai-gateway/
```

If starting from scratch:

```bat
cd /d "C:\Users\SOUQ\Downloads\apps\Expense-Tracker\Expense-Tracker-main"
mkdir workers\ai-gateway
cd workers\ai-gateway
npm init -y
npm install -D wrangler typescript vitest
npm install jose
```

The implemented Worker already contains `package.json`, `tsconfig.json`, `wrangler.toml`, tests, and migrations under `workers/ai-gateway`.

## 2. Create D1 Database

```bat
npx wrangler d1 create ai_expenses_gateway
```

Copy the returned `database_id` into `workers/ai-gateway/wrangler.toml`.

## 3. Configure `wrangler.toml`

Expected file:

```text
workers/ai-gateway/wrangler.toml
```

Minimum shape:

```toml
name = "ai-expenses-gateway"
main = "src/index.ts"
compatibility_date = "2026-05-16"
compatibility_flags = ["nodejs_compat"]

[vars]
FIREBASE_PROJECT_ID = "ai-expenses-tracker-studio"
AI_PROVIDER = "gemini"
AI_MODEL = "gemini-2.5-flash"
AI_PARSE_DAILY_USER_LIMIT = "5"
AI_RECEIPT_DAILY_USER_LIMIT = "3"
AI_ADVICE_DAILY_USER_LIMIT = "3"

[[d1_databases]]
binding = "AI_DB"
database_name = "ai_expenses_gateway"
database_id = "<paste-d1-database-id>"
migrations_dir = "migrations"
```

Do not add global limits unless temporarily needed for emergency abuse protection.

## 4. Add Gemini Secret

From `workers/ai-gateway`:

```bat
npx wrangler secret put GEMINI_API_KEY
```

Paste the Gemini API key when prompted.

## 5. Apply D1 Migration

Expected migrations directory:

```text
workers/ai-gateway/migrations/
```

Run:

```bat
npx wrangler d1 migrations apply ai_expenses_gateway --local
npx wrangler d1 migrations apply ai_expenses_gateway --remote
```

## 6. Run Worker Tests

```bat
npm test
npm run typecheck
```

Required test coverage:

- Missing token rejected.
- Wrong project token rejected.
- Valid token reaches quota path.
- Text quota blocks 6th request for same user.
- Another user is not blocked by first user's quota.
- Quota-exhausted request does not call Gemini.
- Provider malformed JSON returns `invalid_provider_output`.
- Worker returns API contract-compatible JSON.

## 7. Deploy Worker

```bat
npx wrangler deploy
```

Expected output includes a URL such as:

```text
https://ai-expenses-gateway.<subdomain>.workers.dev
```

## 8. Build Flutter APK With Worker URL

Use the deployed Worker URL plus `/aiParse`:

```bat
cd /d "C:\Users\SOUQ\Downloads\apps\Expense-Tracker\Expense-Tracker-main"

& "C:\flutter\bin\flutter.bat" build apk --release ^
  --dart-define=AI_GATEWAY_URL=https://ai-expenses-gateway.<subdomain>.workers.dev/aiParse ^
  --dart-define=AI_PROVIDER=gemini ^
  --dart-define=AI_MODEL=gemini-2.5-flash
```

The APK is expected at:

```text
build\app\outputs\flutter-apk\app-release.apk
```

## 9. Manual Verification

1. Install the APK.
2. Sign in with Firebase Auth.
3. Open AI Assistant.
4. Send:

   ```text
   صرفت 250 جنيه على أكل امبارح بالكاش
   ```

5. Confirm the app shows editable preview:

   - amount: 250
   - category: Food or matching local category
   - date: yesterday
   - payment method: Cash
   - confidence shown/handled
   - needs confirmation before save

6. Repeat text command until the 6th same-day request.
7. Confirm the app shows quota exhausted and manual entry still works.

## 10. Rollback

If Worker AI fails:

1. Rebuild the app without `AI_GATEWAY_URL` to return to mock/local AI path.
2. Or keep the same APK and disable the AI entry point only if a future remote config feature exists.
3. Do not delete Firestore user data.
4. Do not deploy Firebase Functions just to recover free-plan AI.

## 11. Troubleshooting

- `unauthenticated`: Check Firebase login, ID token forwarding, token expiry, project id, issuer, and audience.
- `gateway_misconfigured`: Check Worker secrets, D1 binding, and required variables.
- Invalid Gemini key: Test the key in Google AI Studio, then run `npx wrangler secret put GEMINI_API_KEY` again.
- `quota_exceeded`: User reached daily limit for that request type.
- `rate_limited`: Gemini free quota or provider rate limit hit.
- `invalid_provider_output`: Gemini returned malformed output; inspect schema/prompt without logging secrets.
- Network failure: Check Worker URL in `AI_GATEWAY_URL` and mobile internet.
