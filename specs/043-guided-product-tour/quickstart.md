# Quickstart: Guided Product Tour

## Manual Verification

1. Complete first-run setup with a new user.
2. Land on Home.
3. Verify the AI Assistant icon is spotlighted first with a darkened overlay and subtle animation.
4. Tap Next and verify the tour advances without opening AI or consuming quota.
5. Continue through manual expense, preview confirmation, budget, reports, categories, settings, and Free/Premium guidance.
6. Tap Skip and restart the app; verify the same tour version does not auto-show.
7. Open Settings and use Replay Tour; verify the tour starts again.
8. Switch app language to Arabic and replay; verify RTL layout and Arabic text.
9. Test on a small Android viewport and with keyboard open where possible.

## Expected Automated Verification

```text
flutter gen-l10n
flutter analyze
flutter test --reporter expanded --concurrency=1 --timeout 45s test/guided_tour test/home/home_navigation_test.dart test/settings/settings_screen_widget_test.dart
```

Run the full suite if shared app scaffolding changes:

```text
flutter test --reporter expanded --concurrency=1 --timeout 45s
```

