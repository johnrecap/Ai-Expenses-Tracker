# Contract: Cloudflare Worker AI Gateway API

## Overview

The Cloudflare Worker must expose the same HTTP contract currently expected by Flutter's `AiGatewayClient`.

Base URL example:

```text
https://ai-expenses-gateway.<account>.workers.dev/aiParse
```

Flutter is built with:

```text
--dart-define=AI_GATEWAY_URL=https://ai-expenses-gateway.<account>.workers.dev/aiParse
```

Flutter replaces the final path segment for receipt and advice:

```text
aiParse   -> text parse endpoint
aiReceipt -> receipt extraction endpoint
aiAdvice  -> financial advice endpoint
```

## Common Request Headers

```http
Authorization: Bearer <Firebase ID token>
Content-Type: application/json
```

For web builds, preflight `OPTIONS` must return CORS headers. Protected `POST` requests still require authorization.

## Common Success Response

```json
{
  "ok": true,
  "provider": "gemini",
  "model": "gemini-2.5-flash",
  "requestId": "gateway-request-id",
  "usage": {
    "inputTokens": 100,
    "outputTokens": 60
  },
  "quota": {
    "requestType": "parse_text",
    "allowed": true,
    "limit": 5,
    "used": 1,
    "remaining": 4,
    "resetAt": "2026-05-17T00:00:00.000Z"
  },
  "structuredJson": {}
}
```

## Common Failure Response

```json
{
  "ok": false,
  "provider": "gemini",
  "model": "gemini-2.5-flash",
  "requestId": "gateway-request-id",
  "errorCode": "quota_exceeded",
  "errorMessage": "Daily user AI limit reached."
}
```

## Error Codes

- `unauthenticated`: Missing, malformed, expired, invalid, or wrong-project Firebase token.
- `quota_exceeded`: User exhausted the configured daily quota for this request type.
- `rate_limited`: Gemini/provider rate limit.
- `provider_timeout`: Gemini/provider did not respond before timeout.
- `provider_unavailable`: Provider returned an unavailable/server/network failure.
- `invalid_provider_output`: Provider response did not match expected structured JSON.
- `gateway_misconfigured`: Missing secret, D1 binding, Firebase project id, or model config.
- `invalid_request`: Request body is missing required fields or contains invalid values.

## Endpoint: POST /aiParse

### Request Body

```json
{
  "input": "صرفت 250 جنيه على أكل امبارح بالكاش",
  "now": "2026-05-16T12:00:00.000Z",
  "locale": "ar-EG",
  "defaultCurrency": "EGP",
  "clientRequestId": "client-id",
  "categories": [
    {
      "categoryId": "food",
      "name": "Food",
      "isArchived": false
    }
  ],
  "recentExpenses": [
    {
      "expenseId": "expense-1",
      "amount": 180,
      "currency": "EGP",
      "categoryName": "Transport",
      "description": "Uber",
      "date": "2026-05-15",
      "paymentMethod": "Cash"
    }
  ],
  "budgetSummary": {
    "month": "2026-05",
    "currency": "EGP",
    "limit": 5000,
    "warningThreshold": 0.8
  }
}
```

### Response `structuredJson`

```json
{
  "intent": "add_expense",
  "amount": 250,
  "category": "Food",
  "date": "2026-05-15",
  "paymentMethod": "Cash",
  "currency": "EGP",
  "description": "مصروف أكل",
  "confidence": 0.92,
  "needsConfirmation": true
}
```

### Rules

- Reject empty `input`.
- Send only bounded recent expenses.
- Never return prose or markdown.
- Always set `needsConfirmation` true for mutation intents.
- Do not create/update/delete data.

## Endpoint: POST /aiReceipt

### Request Body

```json
{
  "imageBase64": "<compressed-base64-image>",
  "mimeType": "image/jpeg",
  "imageFingerprint": "safe-local-fingerprint",
  "now": "2026-05-16T12:00:00.000Z",
  "locale": "ar-EG",
  "defaultCurrency": "EGP",
  "clientRequestId": "client-id",
  "categories": [
    {
      "categoryId": "food",
      "name": "Food",
      "isArchived": false
    }
  ]
}
```

### Response `structuredJson`

```json
{
  "amount": 250,
  "date": "2026-05-15",
  "merchant": "Restaurant",
  "category": "Food",
  "currency": "EGP",
  "confidence": 0.88,
  "needsConfirmation": true
}
```

### Rules

- Reject missing image.
- Reject non-image MIME types.
- Enforce a safe maximum request size.
- Do not store raw image bytes/base64.
- Low confidence must still return editable preview data instead of auto-save.

## Endpoint: POST /aiAdvice

### Request Body

```json
{
  "period": "month",
  "summary": {
    "currency": "EGP",
    "total": 4200,
    "budgetLimit": 5000,
    "topCategories": [
      {
        "category": "Restaurants",
        "amount": 1500
      }
    ]
  },
  "now": "2026-05-16T12:00:00.000Z",
  "locale": "ar-EG",
  "defaultCurrency": "EGP",
  "clientRequestId": "client-id"
}
```

### Response `structuredJson`

```json
{
  "period": "month",
  "groundedSummary": "You spent 4200 EGP this month, with restaurants as the top category.",
  "advice": "قلل طلبات المطاعم هذا الأسبوع وحط حد يومي بسيط للأكل خارج البيت.",
  "categoryDrivers": [
    {
      "category": "Restaurants",
      "amount": 1500,
      "currency": "EGP"
    }
  ],
  "confidence": 0.84,
  "qualityNote": "Advice is based only on the provided monthly summary."
}
```

### Rules

- Advice must be user-triggered.
- Advice must not invent expenses.
- Advice must be short and grounded in `summary`.
- Advice must not mutate any user data.

## CORS Contract

For `OPTIONS`:

```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type
Access-Control-Max-Age: 86400
```

For all JSON responses:

```http
Access-Control-Allow-Origin: *
Content-Type: application/json
```

## Security Contract

- No endpoint may call Gemini until auth and quota pass.
- Auth failures must not reveal token internals.
- Provider errors must not include secrets.
- Logs must include request id and safe error code.
