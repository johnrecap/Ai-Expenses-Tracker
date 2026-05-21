# Quickstart: Language And Currency Preferences

## Manual Verification

1. Sign in with an existing account that already has settings.
2. Open Settings and verify current base currency and payment method still show correctly.
3. Set language to Arabic and base currency to USD.
4. Restart the app.
5. Verify UI text is Arabic/RTL while Add Expense defaults to USD.
6. Open AI Assistant and enter: `صرفت 100 جنيه امبارح على المواصلات`.
7. Verify the preview uses EGP because the text explicitly said جنيه.
8. Set language to English and base currency to EGP.
9. Enter: `spent 20 dollars on food`.
10. Verify the preview uses USD because the text explicitly said dollars.
11. Simulate settings repository load failure in tests and verify no silent EGP/Cash save occurs.

## Expected Automated Verification

```text
flutter gen-l10n
flutter analyze
flutter test --reporter expanded --concurrency=1 --timeout 45s test/repository/user_settings_entity_test.dart test/settings/settings_screen_widget_test.dart test/ai/ai_gateway_client_test.dart
```

Run the full suite if app-root locale wiring changes provider structure:

```text
flutter test --reporter expanded --concurrency=1 --timeout 45s
```

