# Quickstart: Trust Release Hardening

## Implementation Order

1. Start with failing tests for currency cache and account deletion ordering.
2. Fix settings currency invalidation and exchange-rate refresh target coverage.
3. Fix account deletion so reauthentication happens before user data deletion.
4. Audit readiness gates for incomplete paid/destructive features.
5. Clean docs and deferred references.
6. Run targeted verification.

## Targeted Verification

Run localization generation only if ARB files changed:

```sh
flutter gen-l10n
```

Run targeted tests:

```sh
flutter test --no-pub test/settings/settings_cubit_test.dart test/services/exchange_rate_refresh_service_test.dart test/services/financial_calculation_service_test.dart test/account test/monetization/free_premium_screen_test.dart test/settings/feature_readiness_settings_test.dart test/category_budgets test/subscriptions test/export test/home test/reports --reporter expanded --concurrency=1 --timeout 45s
```

Run analyzer:

```sh
flutter analyze --no-pub
```

Do not build a release artifact unless the user explicitly asks for one after tests pass.

## Manual Checks

- Change base currency from EGP to USD after rates have already refreshed today. Confirm totals do not use old `USD: 50` as if it converted into USD.
- Add a supported currency after same-day refresh. Confirm the app refreshes rates or clearly shows the new currency as missing.
- Delete account with a fake or real provider that requires recent login. Confirm no data deletion happens before reauthentication succeeds.
- Open Premium and privacy/data settings. Confirm disabled or coming-soon actions cannot start paid or destructive flows.
- Open README and the product/AI audit in a normal editor. Confirm license reference and Arabic text are readable.
