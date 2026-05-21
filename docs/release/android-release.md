# Android Release

This project keeps production signing and provider secrets outside source control. Real release artifacts must use `android/key.properties` locally and must pass the AI gateway URL through Flutter build defines.

## Local Signing Setup

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Set `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`.
3. Keep the keystore file outside the repository when possible, for example under a local secure keys directory.
4. Confirm `android/key.properties`, `*.jks`, and `*.keystore` are ignored before building.

The package id must stay `com.saeeddevstudio.ai_expenses_tracker`.

## Production Build Commands

Use a real Cloudflare Worker gateway URL. Do not put Gemini, OpenAI, or other provider API keys in Flutter, Android, iOS, Firebase, or Worker source files. Provider API keys belong only in Cloudflare Worker secrets.

Build an Android App Bundle for Play Store upload:

```powershell
flutter build appbundle --release --dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
```

Build an APK for direct device smoke testing:

```powershell
flutter build apk --release --dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
```

If `AI_GATEWAY_URL` is omitted, the app can fall back to non-production AI behavior. Treat any artifact built without that define as internal only.

## AdMob App Id

The Android manifest placeholder reads `admob.androidAppId` from local Gradle properties. Set it in `android/local.properties` or pass it to Gradle as a project property when building through Gradle directly:

```properties
admob.androidAppId=ca-app-pub-<publisher-id>~<app-id>
```

When this value is missing, the project defaults to Google test app id `ca-app-pub-3940256099942544~3347511713`. That default is allowed for internal QA only. A public Play Store release must use the production AdMob app id or intentionally disable ads before upload.

## Artifact Inspection

Before upload, inspect the generated artifact and installed app:

1. Confirm package id is `com.saeeddevstudio.ai_expenses_tracker`.
2. Confirm `versionCode` and `versionName` match the planned release.
3. Confirm the manifest does not contain the Google test AdMob app id for a public release.
4. Confirm the signing certificate fingerprint matches the expected upload/release certificate, not a debug certificate.
5. Install the artifact on a clean device, launch the app, sign in, and run a basic expense entry flow.
6. Confirm AI features call the Cloudflare gateway and do not expose provider API keys in app files or logs.

Useful checks:

```powershell
# Inspect an installed package after installing the release artifact.
adb shell dumpsys package com.saeeddevstudio.ai_expenses_tracker

# Show signing certificate details for an APK.
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk

# Inspect an AAB.
bundletool dump manifest --bundle build/app/outputs/bundle/release/app-release.aab
```

Record the final artifact path, size, package id, version, and signing fingerprint in the release notes before upload.
