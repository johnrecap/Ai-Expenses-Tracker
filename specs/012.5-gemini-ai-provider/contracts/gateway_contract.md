# Contract: AI Gateway

## Endpoint

`POST /ai/parse`

## Authentication

- Requires a valid Firebase Authentication token from the current user.
- Gateway must reject unauthenticated requests before calling any provider.

## Request Body

```json
{
  "input": "صرفت 250 جنيه على أكل امبارح بالكاش",
  "now": "2026-05-16T12:00:00+03:00",
  "locale": "ar-EG",
  "defaultCurrency": "EGP",
  "clientRequestId": "local-uuid",
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
      "amount": 160,
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
    "limit": 10000,
    "spent": 7200,
    "remaining": 2800,
    "warningThreshold": 0.8
  }
}
```

## Successful Response

```json
{
  "ok": true,
  "provider": "gemini",
  "model": "gemini-2.5-flash",
  "requestId": "gateway-request-id",
  "usage": {
    "inputTokens": 312,
    "outputTokens": 92
  },
  "structuredJson": {
    "intent": "add_expense",
    "amount": 250,
    "category": "Food",
    "categoryId": "food",
    "date": "2026-05-15",
    "paymentMethod": "Cash",
    "currency": "EGP",
    "description": "مصروف أكل",
    "confidence": 0.92,
    "needsConfirmation": true,
    "clarifyingQuestion": null
  }
}
```

## Error Response

```json
{
  "ok": false,
  "provider": "gemini",
  "model": "gemini-2.5-flash",
  "requestId": "gateway-request-id",
  "errorCode": "quota_exceeded",
  "errorMessage": "AI usage limit reached for today. Add the expense manually or try again later."
}
```

## Normalized Error Codes

- `unauthenticated`: Missing or invalid user token.
- `quota_exceeded`: User or project daily limit exceeded.
- `rate_limited`: Provider returned a temporary rate-limit response.
- `provider_timeout`: Provider did not respond before timeout.
- `provider_unavailable`: Provider outage or non-rate-limit availability failure.
- `invalid_provider_output`: Provider returned text that does not match the structured JSON contract.
- `gateway_misconfigured`: Gateway secret/model/config is missing or invalid.
- `invalid_request`: Request body is missing required client fields.

## Safety Rules

- Gateway never accepts a command to write directly to Firestore expenses.
- Gateway never returns provider API keys, secret names, or raw authorization headers.
- Gateway always sets `needsConfirmation` to true for supported intents.
- Gateway output must be accepted by `AiResponseParser` before UI preview.
