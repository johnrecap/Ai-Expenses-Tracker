# AI Expenses Cloudflare Gateway

This Worker is the free-plan AI gateway for the Flutter Expense Tracker. Firebase stays on Spark for Auth and Firestore. Cloudflare Worker handles Firebase ID token verification, per-user AI quota, Gemini calls, and safe usage logs.

Firebase Functions are not required for this free path. The existing `functions/` folder can remain for a future paid backend, but this gateway must be deployed with Wrangler.

## Required Configuration

- Cloudflare D1 binding: `AI_DB`
- Cloudflare secret: `GEMINI_API_KEY`
- Vars in `wrangler.toml`:
  - `FIREBASE_PROJECT_ID`
  - `AI_PROVIDER=gemini`
  - `AI_MODEL=gemini-2.5-flash`
  - `AI_PARSE_DAILY_USER_LIMIT=5`
  - `AI_RECEIPT_DAILY_USER_LIMIT=3`
  - `AI_ADVICE_DAILY_USER_LIMIT=3`

Do not put Gemini keys in `wrangler.toml`, Flutter dart-defines, Firestore, Android/iOS files, or docs. If a key is ever exposed in a committed file, rotate it from Google AI Studio immediately, update the Cloudflare secret, and remove the leaked value from history before sharing builds.

## Local Setup

```bat
cd workers\ai-gateway
npm install
npm test
npm run typecheck
npm run migrate:local
npm run dev
```

Local secrets belong in `.dev.vars`:

```text
GEMINI_API_KEY=your-local-key
```

## Deploy Checklist

1. Confirm `npm test` and `npm run typecheck` pass.
2. Create D1: `npx wrangler d1 create ai_expenses_gateway`.
3. Replace `database_id` in `wrangler.toml` with the returned id.
4. Set the secret: `npx wrangler secret put GEMINI_API_KEY`.
5. Apply remote migration: `npm run migrate:remote`.
6. Deploy: `npm run deploy`.
7. Smoke-test `/aiParse`, `/aiReceipt`, and `/aiAdvice` with no token and expect JSON `unauthenticated` responses.

## Smoke Requests

Unauthenticated check:

```bat
curl -X POST https://<worker-url>/aiParse -H "Content-Type: application/json" -d "{\"input\":\"صرفت 50 جنيه أكل\",\"now\":\"2026-05-16T12:00:00.000Z\"}"
```

Authenticated check:

```bat
set FIREBASE_ID_TOKEN=<redacted-token>
curl -X POST https://<worker-url>/aiParse -H "Authorization: Bearer %FIREBASE_ID_TOKEN%" -H "Content-Type: application/json" -d "{\"input\":\"صرفت 50 جنيه أكل\",\"now\":\"2026-05-16T12:00:00.000Z\",\"locale\":\"ar-EG\",\"defaultCurrency\":\"EGP\"}"
```

To verify quota, repeat the authenticated parse request six times for the same user. The sixth request should return `quota_exceeded` while a different Firebase user still has their own quota.

## Fallback Behavior

If Gemini is rate-limited, unavailable, or the user has exhausted quota, the Worker returns a normalized error. The Flutter app should keep manual expense entry, local reports, local repeated-expense detection, and local spending prediction working without consuming AI requests.

## Quota response contract

Successful `/aiParse`, `/aiReceipt`, and `/aiAdvice` responses include `quota` when the D1 quota check succeeds:

```json
{
  "requestType": "parse_text",
  "allowed": true,
  "limit": 5,
  "used": 2,
  "remaining": 3,
  "resetAt": "2026-05-18T00:00:00.000Z"
}
```

Quota-exhausted errors include the same shape with `allowed: false`, `remaining: 0`, and the next UTC reset time. Flutter treats missing quota fields as unknown or stale display data and never uses them as authorization.

## Rollback

Use Wrangler versions:

```bat
npx wrangler versions list
npx wrangler rollback
```

Full plan and setup details: `specs/018-cloudflare-ai-gateway/quickstart.md`.
