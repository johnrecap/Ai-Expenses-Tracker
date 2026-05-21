# Tasks: Production Release Hardening

**Input**: `specs/034-production-release-hardening/spec.md`, `plan.md`  
**Implementation Intent**: Make Android release artifacts production-ready without exposing secrets or changing the app architecture.

## Phase 1: Release Signing Foundation

- [X] T001 Update `.gitignore` to ignore Android signing secrets and generated keystore files.

  **Why**: A production signing key is sensitive. It must never be committed.
  **Steps**:
  1. Add ignore entries for `android/key.properties`, `*.jks`, `*.keystore`, and any local signing export path if missing.
  2. Keep existing Flutter, Firebase, Worker, and functions ignore rules intact.
  3. Run a local secret/path scan after edits.
  **Done when**: Real signing config files are ignored and existing ignored files are not removed.

- [X] T002 Add `android/key.properties.example` with safe placeholder fields.

  **Why**: New workers need to know exactly which fields are required without seeing real secrets.
  **Steps**:
  1. Add placeholder keys: `storeFile`, `storePassword`, `keyAlias`, `keyPassword`.
  2. Use comments explaining Windows path escaping.
  3. State that the real file must be named `key.properties` and stay local.
  **Done when**: A developer can create the real file from the example without guessing field names.

- [X] T003 Replace debug signing in `android/app/build.gradle` with conditional release signing.

  **Why**: Current release builds use `signingConfigs.debug`, which is not production-safe.
  **Steps**:
  1. Load `android/key.properties` if it exists.
  2. Define a `release` signing config from those values.
  3. For `buildTypes.release`, use release signing when all required values exist.
  4. Fail with a clear Gradle message for production release builds if signing config is missing.
  5. Keep debug builds and internal testing builds usable.
  **Done when**: Production release cannot silently use debug signing.

## Phase 2: Production Build Configuration

- [X] T004 Document the official production-like build command in `docs/release/android-release.md`.

  **Why**: The AI gateway is disabled unless `AI_GATEWAY_URL` is passed at build time.
  **Steps**:
  1. Add APK and AAB command examples.
  2. Include `--dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev`.
  3. Include optional `--dart-define=AI_PROVIDER=gemini` and `--dart-define=AI_MODEL=gemini-2.5-flash`.
  4. Warn that Gemini API keys must be set only as Cloudflare Worker secrets.
  **Done when**: A release builder can produce an artifact with real AI gateway enabled.

- [X] T005 Add AdMob production ID setup notes to `docs/release/android-release.md`.

  **Why**: The project defaults to Google test app id when `admob.androidAppId` is missing.
  **Steps**:
  1. Explain how to set `admob.androidAppId` in local Gradle properties.
  2. Document that test ids are allowed only for internal QA.
  3. Add a pre-release check that `ca-app-pub-3940256099942544~3347511713` is not used for public release.
  **Done when**: Production ad app id setup is explicit and test ids are clearly blocked for public release.

- [X] T006 Add release artifact inspection steps to `docs/release/android-release.md`.

  **Why**: Builders need to verify package id, version, signing, and manifest metadata before upload.
  **Steps**:
  1. Document how to inspect package id with Android tooling or `adb shell dumpsys package`.
  2. Document how to check version code/name.
  3. Document how to confirm release signing certificate fingerprint.
  4. Document how to install on a clean device and sign in.
  **Done when**: The release checklist catches wrong package, wrong version, or debug signing.

## Phase 3: Store Readiness Checklist

- [X] T007 Create `docs/release/play-store-checklist.md`.

  **Why**: Store review needs privacy, permission, and data safety answers beyond code passing tests.
  **Steps**:
  1. List permissions/features: Firebase Auth, Firestore data, camera/receipt, microphone/speech, notifications, local auth, ads.
  2. For each item, explain the user-facing purpose.
  3. Add privacy/data safety notes for expense data and AI gateway calls.
  4. Add release notes, screenshots, app icon, and content rating reminders.
  **Done when**: The app owner has a single checklist for Play Store submission.

- [X] T008 Add a production build preflight section to `docs/release/play-store-checklist.md`.

  **Why**: A final preflight prevents shipping mock AI, test ads, or debug signing.
  **Steps**:
  1. Check real signing.
  2. Check real AdMob id or intentionally disabled ads.
  3. Check `AI_GATEWAY_URL` build define.
  4. Check Firebase Auth providers and SHA fingerprints.
  5. Check Firestore rules deployment.
  **Done when**: The checklist directly maps to the top production blockers.

## Phase 4: Verification

- [X] T009 Run `flutter analyze`.

  **Parent verification note**: Not run in this worker by instruction.

  **Why**: Build configuration edits can still break generated Android/Flutter integration.
  **Steps**:
  1. Execute `flutter analyze`.
  2. Fix only issues caused by this plan.
  3. Record any pre-existing unrelated issue separately.
  **Done when**: Analyzer passes or the remaining issue is documented as unrelated.

  **Parent verification (2026-05-18)**: `flutter analyze` passed with no issues after reviewing the plan 034/035/036 integration.

- [X] T010 Run `flutter test --reporter expanded --concurrency=1 --timeout 45s`.

  **Parent verification note**: Not run in this worker by instruction.

  **Why**: Release hardening must not alter runtime behavior.
  **Steps**:
  1. Run the full Flutter test suite.
  2. Verify no tests changed from passing to failing.
  3. If failures occur, identify whether Gradle/config edits caused them.
  **Done when**: Full tests pass.

  **Parent verification (2026-05-18)**: Full Flutter test suite passed: 217 tests.

- [ ] T011 Build a production-like Android release artifact.

  **Parent verification note**: Not run in this worker by instruction.
  **Parent blocker (2026-05-18)**: Not run because the repo intentionally does not contain a production keystore or `android/key.properties`. Build after the owner creates local signing files from `android/key.properties.example`.

  **Why**: The plan is only complete when the artifact actually builds.
  **Steps**:
  1. Build APK or AAB with release signing configured.
  2. Include the AI gateway `--dart-define`.
  3. Use production AdMob app id or explicitly document internal-test mode.
  4. Record artifact path and size.
  **Done when**: Artifact builds and is not debug-signed.

- [X] T012 Run a secret scan before handoff.

  **Parent verification note**: Not run in this worker by instruction.

  **Why**: This plan introduces release secrets locally, so leakage must be checked.
  **Steps**:
  1. Search for `AIza`, `GEMINI_API_KEY`, keystore passwords, and `client_secret`.
  2. Confirm only safe Firebase client config or documented placeholders appear.
  3. Rotate any secret that was accidentally exposed.
  **Done when**: No production secret exists in committed files.

  **Parent verification (2026-05-18)**: Secret scan found only expected placeholders, documented environment variable names, AdMob test ids, and the normal Firebase client key in `android/app/google-services.json`. No real keystore file, `android/key.properties`, Gemini provider key, or client secret was present.

## Dependencies & Execution Order

- T001 and T002 can run first.
- T003 depends on T001 and T002.
- T004 to T008 can run in parallel after T003 starts because they are documentation-focused.
- T009 to T012 run after implementation/docs are complete.

## Suggested MVP

Complete T001 to T006 and T009 to T011 first. That turns the current APK build into a controlled production-like artifact path before store metadata polish.
