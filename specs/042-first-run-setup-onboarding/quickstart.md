# Quickstart: First-Run Setup Onboarding

## Manual Verification

1. Sign out.
2. Create a new test user.
3. Verify onboarding appears before Home.
4. Choose Arabic, USD, and Wallet.
5. Continue through AI intro without triggering a provider request.
6. Decline reminders and finish.
7. Verify Home opens Arabic/RTL and Add Expense defaults to USD/Wallet.
8. Sign out and sign in again.
9. Verify onboarding does not show again.
10. Delete or simulate missing completion state and verify onboarding resumes.
11. Repeat with reminder opt-in and permission denial; Home must still open.

## Expected Automated Verification

```text
flutter gen-l10n
flutter analyze
flutter test --reporter expanded --concurrency=1 --timeout 45s test/onboarding test/auth/auth_gate_test.dart test/settings/settings_cubit_test.dart
```

Run full tests if AuthGate or app-root providers change:

```text
flutter test --reporter expanded --concurrency=1 --timeout 45s
```

