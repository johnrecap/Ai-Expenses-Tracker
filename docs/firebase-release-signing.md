# Firebase Android Release Fingerprints

This file records the Android release/upload certificate fingerprints used for
Firebase features that depend on app signing, especially Google Sign-In.

## Android App

- Firebase app nickname: Ai Expenses Tracker
- Android package name: `com.saeeddevstudio.ai_expenses_tracker`
- Keystore alias: `ai_expenses_upload`
- Local keystore path: `release-signing/ai-expenses-upload-keystore.jks`
- Local Gradle signing config: `android/key.properties`

The keystore and `android/key.properties` are intentionally ignored by Git.
Keep them backed up privately. Losing this keystore means release updates signed
with this upload key can be blocked or require Play Console key reset flows.

## Release Fingerprints

- SHA-1: `D0:C3:E1:B3:33:E0:D0:6E:EC:18:03:E4:F1:49:E6:6E:48:6D:A5:C6`
- SHA-256: `14:F6:B6:34:24:89:E6:1A:F9:C5:DB:D3:9B:BE:56:EB:41:A6:7E:0C:4F:E5:55:60:F4:DC:7E:2B:50:71:34:BE`

## Firebase Console Steps

1. Open Firebase Console > Project settings > Your apps > Android app.
2. Press **Add fingerprint**.
3. Add the SHA-1 value above.
4. Press **Add fingerprint** again.
5. Add the SHA-256 value above.
6. Download the updated `google-services.json`.
7. Replace `android/app/google-services.json`.
8. Rebuild and reinstall the app.

## Reprint Fingerprints

From the project root:

```powershell
& "C:\Program Files\Java\jdk-17\bin\keytool.exe" -list -v `
  -keystore "release-signing\ai-expenses-upload-keystore.jks" `
  -alias "ai_expenses_upload"
```

