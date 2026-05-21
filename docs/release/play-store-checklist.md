# Play Store Checklist

Use this checklist before uploading a public Android release.

## Product And Store Listing

- [ ] App name, short description, full description, category, and contact email are final.
- [ ] App icon, feature graphic, phone screenshots, and tablet screenshots are current.
- [ ] Release notes match the version name and describe user-visible changes.
- [ ] Content rating questionnaire is complete and consistent with the app experience.

## Permissions And Data Safety

- [ ] Firebase Auth: disclose account identifiers used for sign-in and account management.
- [ ] Firestore expense data: disclose financial/user-generated expense records stored for sync and backup.
- [ ] Camera and receipt capture: explain that camera access supports receipt entry or attachment workflows.
- [ ] Microphone and speech: explain that speech input supports faster expense entry when enabled by the user.
- [ ] Notifications: explain reminders, alerts, or budget-related notifications.
- [ ] Local auth: explain device biometrics/PIN are used to protect local app access and are handled by the device.
- [ ] Ads: disclose AdMob usage and any associated advertising identifiers or diagnostics.
- [ ] AI gateway calls: disclose that selected expense text may be sent to the Cloudflare AI gateway for categorization or assistance; provider API keys must not be present in the client.

## Production Build Preflight

- [ ] Release signing is configured with local `android/key.properties`; the artifact is not debug-signed.
- [ ] Package id remains `com.saeeddevstudio.ai_expenses_tracker`.
- [ ] Version code increased from the previous Play Store upload.
- [ ] Version name matches the release notes.
- [ ] `AI_GATEWAY_URL` was passed with `--dart-define` and points to the production Cloudflare Worker.
- [ ] `AI_PROVIDER` and `AI_MODEL` values are intentional for the release.
- [ ] Production AdMob app id is configured, or ads are intentionally disabled for the release.
- [ ] Google test AdMob app id `ca-app-pub-3940256099942544~3347511713` is absent from public-release artifacts.
- [ ] Firebase Auth providers needed for production are enabled.
- [ ] Firebase Android SHA fingerprints include the release/upload signing certificate.
- [ ] Firestore rules and indexes have been deployed by the owner before release.
- [ ] Artifact inspection confirms package id, version code/name, manifest metadata, and signing fingerprint.

## Upload Readiness

- [ ] AAB is selected for Play Store upload.
- [ ] APK smoke test was installed on a clean device when direct testing was needed.
- [ ] Sign-in, expense creation, sync, AI-assisted flow, ads behavior, export, and local lock were checked on a production-like build.
- [ ] No real keystore, `key.properties`, Gemini/OpenAI/provider key, or `client_secret` is committed.
