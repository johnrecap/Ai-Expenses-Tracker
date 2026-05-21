# Google Sign-In Firebase Setup

Google Sign-In is implemented through the existing `AuthRepository` and
`AuthBloc` flow, but it will only work on a device after Firebase and platform
configuration are complete.

## Android

1. Confirm the Android package name is:

   ```text
   com.saeeddevstudio.ai_expenses_tracker
   ```

2. In Firebase Console, open Authentication > Sign-in method and enable the
   Google provider.

3. Set the public-facing app name and support email in the Google provider
   settings.

4. In Firebase Console, open Project settings > Your apps > Android app and add
   SHA-1 and SHA-256 fingerprints for the keystore used by the installed build.
   Configure both debug and release fingerprints when testing both build types.

5. Download the updated `google-services.json` and place it at:

   ```text
   android/app/google-services.json
   ```

6. Rebuild and reinstall the app after changing Firebase or signing
   configuration.

## Platform Caveats

- iOS and web may require their own OAuth client IDs and Firebase platform
  configuration before provider sign-in works there.
- Do not store OAuth client secrets, provider secrets, or API keys in Flutter
  source files.
- If sign-in fails with setup-related errors, re-check the package name,
  current signing certificate fingerprints, enabled provider status, and support
  email configuration.
