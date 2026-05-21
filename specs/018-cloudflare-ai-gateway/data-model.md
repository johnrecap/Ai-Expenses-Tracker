# Data Model: Cloudflare AI Gateway

## Entity: WorkerEnvironment

Represents deployed gateway configuration.

**Fields**:

- `GEMINI_API_KEY`: Secret string stored in Cloudflare secrets only.
- `FIREBASE_PROJECT_ID`: Firebase project id, default `ai-expenses-tracker-studio`.
- `AI_PARSE_DAILY_USER_LIMIT`: Integer, default `5`.
- `AI_RECEIPT_DAILY_USER_LIMIT`: Integer, default `3`.
- `AI_ADVICE_DAILY_USER_LIMIT`: Integer, default `3`.
- `AI_MODEL`: Provider model id, default `gemini-2.5-flash`.
- `AI_PROVIDER`: Provider id, default `gemini`.
- `D1_DATABASE`: Cloudflare D1 binding for quota and usage logs.

**Validation rules**:

- Secrets must not be committed.
- Numeric limits must be positive integers.
- Missing optional limits fall back to free-plan defaults.
- Provider/model names are server-side config only; Flutter may pass provider/model hints but the worker owns final provider choice.

## Entity: FirebaseTokenValidationResult

Represents a verified app user.

**Fields**:

- `uid`: Firebase user id.
- `aud`: Must equal configured Firebase project id.
- `iss`: Must equal `https://securetoken.google.com/{projectId}`.
- `exp`: Expiry timestamp, must be in the future.
- `iat`: Issued-at timestamp, must not be unreasonable.
- `auth_time`: Optional Firebase auth time.
- `email`: Optional email claim for diagnostics only.

**Validation rules**:

- Signature must validate against Google Secure Token public keys.
- Token must be rejected before quota/provider calls when invalid.
- Worker logs may store uid and request metadata, but not the raw token.

## Entity: AiUsageCounter

Represents one user's daily usage for one request type.

**Fields**:

- `dateKey`: UTC date string `yyyy-MM-dd`.
- `uid`: Verified Firebase user id.
- `requestType`: One of `parse_text`, `receipt_extraction`, `financial_advice`.
- `provider`: Provider id, default `gemini`.
- `model`: Model id, default `gemini-2.5-flash`.
- `used`: Integer count.
- `limit`: Integer limit applied when count was last updated.
- `createdAt`: Server timestamp.
- `updatedAt`: Server timestamp.

**Suggested D1 table**:

```sql
CREATE TABLE IF NOT EXISTS ai_usage_daily (
  date_key TEXT NOT NULL,
  uid TEXT NOT NULL,
  request_type TEXT NOT NULL,
  provider TEXT NOT NULL,
  model TEXT NOT NULL,
  used INTEGER NOT NULL DEFAULT 0,
  applied_limit INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  PRIMARY KEY (date_key, uid, request_type, provider, model)
);
```

**Validation rules**:

- Counter must be checked before provider calls.
- Increment must not allow `used` to exceed the applied user limit.
- Global counters are not part of default free-plan behavior.

## Entity: AiUsageLog

Represents safe diagnostic history for gateway requests.

**Fields**:

- `id`: Generated request id.
- `dateKey`: UTC date string.
- `uid`: Verified Firebase user id or `unknown` for auth failures.
- `requestType`: Request type.
- `status`: `success`, `failure`, or `quota_blocked`.
- `provider`: Provider id.
- `model`: Model id.
- `errorCode`: Optional normalized error code.
- `inputTokens`: Optional provider usage count.
- `outputTokens`: Optional provider usage count.
- `createdAt`: Server timestamp.

**Suggested D1 table**:

```sql
CREATE TABLE IF NOT EXISTS ai_usage_logs (
  id TEXT PRIMARY KEY,
  date_key TEXT NOT NULL,
  uid TEXT NOT NULL,
  request_type TEXT NOT NULL,
  status TEXT NOT NULL,
  provider TEXT NOT NULL,
  model TEXT NOT NULL,
  error_code TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  created_at TEXT NOT NULL
);
```

**Validation rules**:

- Do not store raw prompts unless a later privacy-reviewed spec allows it.
- Do not store receipt image bytes/base64.
- Do not store `Authorization` headers or provider API keys.

## Entity: AiGatewayRequest

Represents a request from Flutter to the Worker.

**Common fields**:

- `now`: Client current time ISO string for prompt context only; quotas use server date.
- `locale`: Locale string, default `ar-EG`.
- `defaultCurrency`: Currency code, default `EGP`.
- `clientRequestId`: Optional client-generated id for dedupe diagnostics.
- `categories`: Minimal category snapshots.

**Text parse fields**:

- `input`: Natural-language command.
- `recentExpenses`: Up to a bounded number of recent expense snapshots.
- `budgetSummary`: Optional budget summary.

**Receipt fields**:

- `imageBase64`: Compressed receipt image data.
- `mimeType`: Image MIME type.
- `imageFingerprint`: Optional local fingerprint for dedupe.

**Advice fields**:

- `period`: `week` or `month`.
- `summary`: Spending summary object prepared locally by the app.

**Validation rules**:

- Reject empty input for text parse.
- Reject missing/oversized/unsupported receipt images.
- Reject advice without a structured summary.

## Entity: AiGatewayResponse

Represents the normalized response consumed by the existing Flutter gateway client.

**Success fields**:

- `ok`: `true`.
- `provider`: Provider id.
- `model`: Model id.
- `requestId`: Gateway request id.
- `usage`: Optional token usage.
- `quota`: Optional usage status with limit/used/remaining/resetAt.
- `structuredJson`: JSON object expected by Flutter parser.

**Failure fields**:

- `ok`: `false`.
- `provider`: Provider id.
- `model`: Model id.
- `requestId`: Gateway request id.
- `errorCode`: Normalized error code.
- `errorMessage`: User-safe message.

**Validation rules**:

- All failures must be JSON.
- Provider output must be validated or normalized before success response.
- Mutations are never performed by the gateway.
