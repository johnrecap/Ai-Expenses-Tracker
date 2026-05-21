# Tasks: Google Sign-In Authentication

**Input**: `specs/025-google-sign-in-auth/spec.md`, `plan.md`  
**Implementation Intent**: Add Google Sign-In through existing auth architecture without weakening user-scoped data isolation.

## Phase 1: Audit Current Auth Flow

- [X] T001 Inspect current login/register UI and AuthBloc events.

  **Why**: The Google action must fit the existing flow instead of introducing a second auth architecture.
  **Steps**:
  1. Read `lib/screens/auth/views/login_screen.dart`.
  2. Read files under `lib/screens/auth/blocs/auth_bloc/`.
  3. Identify current loading/error states and how navigation reacts to `AuthAuthenticated`.
  4. Record where a Google event and button should be added.
  **Done when**: The exact UI and Bloc files to change are known.

- [X] T002 Inspect `AuthRepository` and `FirebaseAuthRepository`.

  **Why**: Widgets should call repository abstractions through Bloc, not Firebase directly.
  **Steps**:
  1. Read `packages/expense_repository/lib/src/auth/auth_repository.dart`.
  2. Read `packages/expense_repository/lib/src/auth/firebase_auth_repository.dart`.
  3. Check how errors are mapped today for email/password.
  4. Decide the method signature for Google sign-in and cancellation.
  **Done when**: The repository contract for Google sign-in is designed.

## Phase 2: Add Provider Dependency And Repository Method

- [X] T003 Add `google_sign_in` dependency to `pubspec.yaml`.

  **Why**: Firebase Auth needs a Google credential from the Google account selection flow.
  **Steps**:
  1. Add the package with a compatible version.
  2. Run `flutter pub get`.
  3. Inspect dependency resolution for conflicts.
  4. Avoid unrelated dependency upgrades.
  **Done when**: The dependency is resolved and lockfile changes are limited.
  **Worker note**: `google_sign_in` was added to the repository package
  manifest, but dependency resolution/lockfile updates require `flutter pub get`
  and are reserved for parent verification.

- [X] T004 [P] Add Google sign-in method to `AuthRepository`.

  **Why**: Bloc needs a provider-neutral contract.
  **Steps**:
  1. Add a method such as `Future<MyUser?> signInWithGoogle()`.
  2. Document that `null` means user cancellation if that style matches existing code.
  3. Keep returned user shape consistent with email/password methods.
  4. Do not expose plugin-specific types in the interface.
  **Done when**: Interface compiles conceptually and hides provider details.

- [X] T005 Implement Google sign-in in `FirebaseAuthRepository`.

  **Why**: Provider implementation belongs next to existing Firebase auth code.
  **Steps**:
  1. Start Google account selection using `GoogleSignIn`.
  2. Return cancellation without throwing user-facing unknown errors.
  3. Create Firebase credential from Google authentication tokens.
  4. Sign in with Firebase Auth and map to the existing user model.
  5. Map common Firebase/plugin failures to clear auth exceptions.
  **Done when**: Repository method returns the authenticated Firebase user or clear failure.

## Phase 3: Bloc And UI Integration

- [X] T006 Add AuthBloc Google sign-in event and handler.

  **Why**: UI should dispatch one event and rely on existing auth state transitions.
  **Steps**:
  1. Add an event such as `SignInWithGoogleRequested`.
  2. Emit the same loading state pattern used by email/password.
  3. Call the new repository method.
  4. On success, emit authenticated state with Firebase UID.
  5. On cancellation, return to unauthenticated state without an error toast.
  **Done when**: Bloc handles Google sign-in consistently with current auth.

- [X] T007 Add Google sign-in button to `login_screen.dart`.

  **Why**: Users need an obvious direct provider action.
  **Steps**:
  1. Place the button near email/password actions without hiding manual login.
  2. Use a clear label such as "Continue with Google".
  3. Disable duplicate taps while auth is loading.
  4. Dispatch the new AuthBloc event.
  5. Keep layout responsive and not clipped on small phones.
  **Done when**: The login screen exposes Google sign-in cleanly.

- [X] T008 Improve auth error presentation.

  **Why**: The current generic error makes Firebase setup problems hard to diagnose.
  **Steps**:
  1. Add user-friendly messages for cancellation, network, provider disabled, invalid credential, and setup errors.
  2. Keep detailed technical hints in debug logs only.
  3. Avoid showing secrets or raw tokens.
  4. Confirm email/password errors still render correctly.
  **Done when**: Common failures show useful messages without leaking sensitive details.

## Phase 4: Firebase Setup Documentation

- [X] T009 Document Google provider setup under project docs or the spec implementation notes.

  **Why**: Google sign-in will fail until Firebase console setup is complete.
  **Steps**:
  1. List package name `com.saeeddevstudio.ai_expenses_tracker`.
  2. Explain adding SHA-1 and SHA-256 fingerprints for the active keystore.
  3. Explain downloading updated `google-services.json`.
  4. Explain enabling Google provider and support email.
  5. Mention rebuilding/reinstalling after config changes.
  **Done when**: The user can configure Firebase without guessing.

## Phase 5: Tests And Verification

- [ ] T010 [P] Add AuthRepository fake tests for Google success, cancel, and failure.

  **Why**: Provider behavior must be deterministic without real Google UI.
  **Steps**:
  1. Use a fake implementation or mock around repository dependencies.
  2. Test success maps UID/display name/email.
  3. Test cancellation does not emit failure.
  4. Test setup/network failures map to expected errors.
  **Done when**: Provider result mapping is covered without live Firebase.
  **Worker note**: Left for parent or a follow-up harness because live
  `FirebaseAuthRepository` provider mapping needs dependency resolution and
  plugin/Firebase fakes. AuthBloc fake-path tests were added in T011.

- [X] T011 [P] Add AuthBloc tests for Google event state transitions.

  **Why**: Navigation depends on AuthBloc output.
  **Steps**:
  1. Test loading then authenticated state for success.
  2. Test loading then unauthenticated/no-error state for cancellation.
  3. Test loading then failure state for setup or network errors.
  4. Ensure Bloc closes cleanly.
  **Done when**: AuthBloc Google behavior is covered.

- [X] T012 [P] Add login widget test for Google button.

  **Why**: UI regressions can remove the provider action.
  **Steps**:
  1. Pump login screen with fake AuthBloc.
  2. Verify Google button text/icon appears.
  3. Tap the button and verify the Google event is dispatched.
  4. Verify loading disables duplicate taps.
  **Done when**: The provider entry point is widget-tested.

- [ ] T013 Run verification and Android smoke test.

  **Why**: Google Sign-In requires platform config and cannot be fully proven by unit tests.
  **Steps**:
  1. Run `flutter analyze`.
  2. Run relevant Flutter tests.
  3. Build/install on Android with configured Firebase.
  4. Sign in with a Google account and confirm Home loads user-scoped data.
  **Done when**: Automated checks pass and configured Android sign-in works.
  **Worker note**: Reserved for parent verification because this requires
  prohibited analyze/test/build/device smoke commands.
  **Parent verification note**: `flutter pub get`, `flutter analyze`,
  `flutter test --reporter expanded --concurrency=1`, and Android release APK
  build passed. Real Google account smoke sign-in on a physical Android device
  is still unchecked because it requires interactive Firebase/Google provider
  configuration and account selection.
