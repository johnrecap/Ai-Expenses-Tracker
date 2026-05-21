# Quickstart: Daily Exchange Rate Cache

## Manual QA

1. Sign in with a user whose base currency is `EGP`.
2. In Settings, keep `USD` enabled.
3. Add a USD expense.
4. Open Home with internet available.
5. Confirm the monthly spending and budget progress include the USD expense converted to EGP.
6. Reopen/rebuild Home the same day and confirm the total remains stable.
7. Turn off internet and reopen Home.
8. Confirm the same saved converted total still appears.
9. Remove any saved rate for a currency or use an unsupported provider currency, then simulate failed refresh.
10. Confirm Home reports the missing rate rather than using a made-up value.

## Automated Verification

```powershell
& 'C:\flutter\bin\flutter.bat' analyze --no-pub
& 'C:\flutter\bin\flutter.bat' test --no-pub test\services\exchange_rate_service_test.dart test\repository\user_settings_entity_test.dart test\home\home_summary_calculator_test.dart test\budget\budget_calculator_test.dart test\home\home_navigation_test.dart --reporter=expanded --concurrency=1 --timeout=60s
```

## Release Build

```powershell
& 'C:\flutter\bin\flutter.bat' build apk --release
```
