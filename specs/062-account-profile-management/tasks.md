# Tasks: Account Profile Management

**Input**: Design documents from `specs/062-account-profile-management/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Product Decisions And Risk Boundaries

- [X] T001 Confirm provider scope: Google-only, email/password, or both.
  - **Reason**: Available account actions depend on sign-in provider.
  - **Benefit**: Prevents showing actions that Firebase cannot perform for the current user.
  - **Expected**: Accounts support both Google and email/password; provider matrix covers display name, password reset, email update, reauth, and delete.

- [X] T002 Confirm avatar/photo scope: no photo, preset avatars, or Firebase Storage upload.
  - **Reason**: Uploading photos adds Storage rules, privacy, moderation, and deletion work.
  - **Benefit**: Keeps the implementation from adding unnecessary backend risk.
  - **Expected**: No photo/avatar work will be implemented in this plan.

- [X] T003 Confirm account deletion policy and wording.
  - **Reason**: Deleting finance data is destructive and may have legal/store implications.
  - **Benefit**: Users get truthful confirmation copy and support expectations.
  - **Expected**: Deletion is in-app with explicit warning/confirmation only; no support-contact flow.

- [X] T004 Confirm whether app-local display name may differ from Google profile name.
  - **Reason**: Google profile data can refresh from provider and overwrite expectations.
  - **Benefit**: Avoids user confusion about why a name changed.
  - **Expected**: Visible name is app-local and independent from Google profile name.

## Phase 2: Account Data Model And Repository Boundaries

- [X] T005 Extend `AppUser` or auth profile mapping with provider metadata needed by UI.
  - **Reason**: UI needs to know whether actions are Google-only or email/password-safe.
  - **Benefit**: Provider-specific behavior stays deterministic and testable.
  - **Expected**: `AppUser` exposes provider IDs or normalized account capabilities without widgets importing Firebase types.

- [X] T006 Add app-local profile display-name storage to the settings/profile data model.
  - **Reason**: User explicitly wants the visible name independent from Google profile.
  - **Benefit**: Google profile refreshes will not overwrite the app's chosen display name.
  - **Expected**: `UserSettings` or an app-owned profile model stores a local display name with entity serialization, Firestore rules support, and backward-compatible defaults.

- [X] T007 Add account action methods to `AuthRepository`.
  - **Reason**: Widgets must not call Firebase Auth directly.
  - **Benefit**: Keeps auth behavior mockable and consistent with project constitution.
  - **Expected**: Repository interface supports password reset, email update, reauth-needed mapping, and delete-account request methods.

- [X] T008 Implement Firebase Auth repository methods with safe error mapping.
  - **Reason**: Firebase returns provider-specific and reauth-specific failures.
  - **Benefit**: UI can show localized, user-safe messages instead of raw exceptions.
  - **Expected**: `FirebaseAuthRepository` maps success, unavailable action, network failure, and recent-login-required outcomes.

- [X] T009 Add fakes for all account/profile actions in `test/helpers/fake_repositories.dart`.
  - **Reason**: Account flows must be tested without real Firebase.
  - **Benefit**: Enables fast unit/widget coverage.
  - **Expected**: Tests can simulate success, failure, unavailable provider action, reauth-needed, and app-local profile save cases.

## Phase 3: Account/Profile Screen UX

- [X] T010 Create or refactor an Account/Profile screen under `lib/screens/account/`.
  - **Reason**: The Settings profile tile is too small for full account management.
  - **Benefit**: Keeps Settings scannable and gives account actions enough space.
  - **Expected**: Settings links to Account/Profile, while Account/Profile owns detailed identity/actions.

- [X] T011 Show readable identity, email, provider, and secondary account ID.
  - **Reason**: Users need human identity first and support ID second.
  - **Benefit**: Fixes the technical-looking profile experience without hiding support data.
  - **Expected**: App-local display name is primary; Firebase display name/email are fallback; UID is copyable secondary detail.

- [X] T012 Move display-name editing to app-local profile storage.
  - **Reason**: Firebase Auth display name is not independent from Google profile data.
  - **Benefit**: Users can personalize identity reliably.
  - **Expected**: Save updates through app-owned profile/settings state, refreshes Home/Profile immediately, and shows localized failure on Firestore/settings error.

- [X] T013 Update Home and Settings identity fallback order.
  - **Reason**: The app should show the same profile name everywhere.
  - **Benefit**: Prevents Home, Settings, and Account/Profile from disagreeing.
  - **Expected**: Fallback order is app-local display name, Firebase display name, email, localized generic user label.

- [X] T014 Add provider-aware action visibility.
  - **Reason**: Google and email/password accounts support different actions.
  - **Benefit**: Users do not see broken controls.
  - **Expected**: Password reset/email update appears only when supported, or shows a clear unavailable explanation.

## Phase 4: Email And Password Actions

- [X] T015 Implement password reset request for email/password accounts.
  - **Reason**: Account management is incomplete without recovery.
  - **Benefit**: Users can recover credentials without leaving the app.
  - **Expected**: User taps reset password, repository sends request, UI shows localized success/failure.

- [X] T016 Implement email update for email/password accounts if Firebase provider state allows it.
  - **Reason**: Email update often requires recent login and can break sign-in if mishandled.
  - **Benefit**: Gives users control while respecting Firebase security.
  - **Expected**: Email update flow handles validation, reauth-needed, success, and failure states.

- [ ] T017 Add reauthentication UX for sensitive actions.
  - **Reason**: Firebase requires recent sign-in for sensitive account changes.
  - **Benefit**: Avoids raw permission errors and failed destructive actions.
  - **Expected**: Reauth prompt is provider-aware and localized.

## Phase 5: No Avatar/Profile Photo Scope

- [X] T018 Ensure Account/Profile does not expose photo upload, camera, gallery, or avatar-selection UI.
  - **Reason**: Product owner explicitly rejected profile photos for this plan.
  - **Benefit**: Avoids unnecessary permissions, Storage rules, and privacy scope.
  - **Expected**: Account/Profile uses initials/icon fallback only and no photo-related dependencies or permissions are added.

## Phase 6: Account Deletion

- [X] T019 Define `UserDataDeletionPlan` for user-owned Firestore paths.
  - **Reason**: Deletion must be explicit and scoped.
  - **Benefit**: Prevents accidental deletion of shared or other-user data.
  - **Expected**: Plan lists expenses, categories, budgets, category budgets, recurring expenses, saving goals, settings, AI actions, aliases, and any future user-owned collections.

- [X] T020 Implement `AccountDeletionService` with fake-first tests.
  - **Reason**: Destructive flows must be tested before real Firebase calls.
  - **Benefit**: Confirms sequence and failure behavior safely.
  - **Expected**: Service deletes user-scoped data before auth deletion or reports partial failure clearly.

- [X] T021 Add explicit warning/confirmation UI for account deletion.
  - **Reason**: Account deletion is irreversible and destructive.
  - **Benefit**: Reduces accidental data loss.
  - **Expected**: User sees a localized warning and must confirm before any deletion request runs; no support-contact step is shown.

- [X] T022 Handle delete failure and reauth-needed states.
  - **Reason**: Firebase can reject deletion without recent login and Firestore deletion can fail.
  - **Benefit**: Users get honest status and data is not falsely reported as deleted.
  - **Expected**: UI distinguishes canceled, reauth-needed, data-delete failed, auth-delete failed, and completed states.

## Phase 7: Localization And Tests

- [X] T023 Add English and Arabic ARB keys for all Account/Profile copy.
  - **Reason**: Account actions are user-facing and must match app language.
  - **Benefit**: Keeps Account/Profile aligned with localization plan.
  - **Expected**: Labels, warnings, dialogs, provider names, errors, and success messages exist in `app_en.arb` and `app_ar.arb`.

- [X] T024 Run `flutter gen-l10n`.
  - **Reason**: New localization keys must generate typed getters.
  - **Benefit**: Catches malformed placeholders early.
  - **Expected**: Generated localization files update successfully.

- [X] T025 Add AuthBloc/account unit tests.
  - **Reason**: Account actions involve state transitions and failure handling.
  - **Benefit**: Prevents regressions in auth state.
  - **Expected**: Tests cover provider metadata, password reset, unavailable provider actions, reauth-needed, and deletion service outcomes.

- [X] T026 Add app-local profile/settings tests.
  - **Reason**: Display name now lives outside Google profile data.
  - **Benefit**: Prevents Google refresh or settings serialization from breaking the visible name.
  - **Expected**: Tests cover app-local display-name save/load, fallback order, entity serialization, and Firestore rules if rules change.

- [X] T027 Add Account/Profile widget tests.
  - **Reason**: Provider-specific UI must be verified without real Firebase.
  - **Benefit**: Ensures users see only valid actions for their account type.
  - **Expected**: Tests cover Google user, email/password user, UID copy, app-local name edit, delete confirmation, and localized text.

## Phase 8: Verification And Handoff

- [X] T028 Run `flutter analyze --no-pub`.
  - **Reason**: Auth/profile refactors can introduce stale imports or missing states.
  - **Benefit**: Confirms static correctness.
  - **Expected**: No analyzer issues introduced.

- [X] T029 Run targeted auth/account/settings/repository tests.
  - **Reason**: These are the touched behavioral areas.
  - **Benefit**: Confirms profile changes do not break login/settings/home identity.
  - **Expected**: Targeted tests pass or failures are documented as unrelated.

- [X] T030 Update `docs/implementation_plans/deferred-and-advanced-work.md` for any blocked deletion, privacy, Firestore rules, or store-readiness item.
  - **Reason**: Some account work depends on production setup and store/privacy requirements.
  - **Benefit**: Later blockers stay visible.
  - **Expected**: Deferred backlog has concise non-duplicate follow-up items.

## Dependencies And Execution Order

- T001-T004 are completed product decisions.
- T005-T009 establish boundaries before UI work.
- T010-T014 can start after repository/profile capabilities exist.
- T015-T017 depend on provider scope.
- T018 is a scope guard and must stay true through implementation.
- T019-T022 depend on deletion policy from T003.
- T023-T027 run with implementation.
- T028-T030 close the plan.
