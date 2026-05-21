# Privacy-safe observability events

This app may add Crashlytics, Analytics, or Remote Config later, but all calls
must pass through `lib/observability/` first.

## Never log

- Raw expense descriptions, merchant notes, category free text, or search text.
- Receipt images, OCR text, image paths, or extracted receipt line items.
- Auth tokens, refresh tokens, provider access tokens, API keys, AI provider keys,
  Firebase secrets, or Cloudflare Worker secrets.
- PIN values, biometric results, secure-storage payloads, or app-lock secrets.
- Raw AI prompts, voice transcripts, financial advice prompts, or provider
  metadata that could contain private user content.

## Allowed fields

- Event name from `ObservabilityEvent`.
- Feature area, route/screen group, build type, platform family, and app version.
- Error category, safe error code, and exception type.
- Anonymized counts and booleans, such as `expense_count`, `has_budget`,
  `is_premium`, or `ignored_currency_count`.
- Non-sensitive enum values, such as `area=home` or `source=settings`.

## Safe examples

```dart
observability.logEvent(
  ObservabilityEvent.homeViewed,
  parameters: {
    'expense_count': expenses.length,
    'has_budget': budget != null,
  },
);
```

```dart
observability.recordError(
  error,
  stackTrace,
  area: ObservabilityArea.export,
  code: 'csv_write_failed',
);
```

## Unsafe examples

```dart
// Unsafe: description can contain private financial details.
observability.logEvent(
  ObservabilityEvent.expenseCreated,
  parameters: {'description': expense.description},
);
```

```dart
// Unsafe: receipt OCR and provider keys must never leave the privacy boundary.
observability.recordError(
  error,
  stackTrace,
  area: ObservabilityArea.ai,
  parameters: {
    'receipt_text': receiptText,
    'provider_key': apiKey,
  },
);
```

## Deferred Firebase integration

`firebase_crashlytics`, `firebase_analytics`, and `firebase_remote_config` are
not wired in this worker change. Before enabling them:

1. Add packages and Android/iOS platform setup in a dedicated dependency change.
2. Implement adapters behind `ObservabilityService` and `FeatureFlagService`.
3. Confirm release builds initialize Firebase safely when those services fail.
4. Run analyzer, full tests, Android release build, and a production-device QA run.
