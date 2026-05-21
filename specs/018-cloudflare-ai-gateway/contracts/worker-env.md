# Contract: Cloudflare Worker Environment

## Required Cloudflare Bindings

### D1 Database Binding

```toml
[[d1_databases]]
binding = "AI_DB"
database_name = "ai_expenses_gateway"
database_id = "<cloudflare-d1-database-id>"
```

The binding name `AI_DB` is used by the Worker to read/write daily usage counters and safe usage logs.

## Required Secrets

Set with `wrangler secret put`:

```text
GEMINI_API_KEY
```

## Required Variables

Set in `wrangler.toml` under `[vars]`:

```toml
FIREBASE_PROJECT_ID = "ai-expenses-tracker-studio"
AI_PROVIDER = "gemini"
AI_MODEL = "gemini-2.5-flash"
AI_PARSE_DAILY_USER_LIMIT = "5"
AI_RECEIPT_DAILY_USER_LIMIT = "3"
AI_ADVICE_DAILY_USER_LIMIT = "3"
```

## Optional Emergency Variables

These must NOT be set by default. They are only for temporary emergency protection if provider abuse or billing risk appears.

```toml
AI_PARSE_DAILY_GLOBAL_LIMIT = "10000"
AI_RECEIPT_DAILY_GLOBAL_LIMIT = "1000"
AI_ADVICE_DAILY_GLOBAL_LIMIT = "1000"
```

If absent, the Worker must not apply a project-wide global limit.

## Local Development Variables

Use `.dev.vars` for local Worker development only. This file must be ignored by git.

```text
GEMINI_API_KEY=<local-test-key>
```

## Generated URL Contract

After deploy, Wrangler returns a URL similar to:

```text
https://ai-expenses-gateway.<subdomain>.workers.dev
```

The app build must use:

```text
https://ai-expenses-gateway.<subdomain>.workers.dev/aiParse
```

## Non-Goals

- Do not store Gemini keys in Flutter.
- Do not store Cloudflare secrets in Firestore.
- Do not rely on Firebase Functions or Blaze.
- Do not commit `.dev.vars`.
