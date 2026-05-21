# Tasks: Account Deletion Reauth Hardening

**Input**: `specs/067-account-deletion-reauth-hardening/spec.md`, `plan.md`

## Phase 1: Current Flow Audit

- [X] T001 Inspect `lib/screens/account/`, `lib/screens/settings/widgets/profile_identity_section.dart`, and auth repository methods.
  - **Why**: Plan 062 already added account/profile pieces.
  - **Benefit**: Avoids duplicating or bypassing existing boundaries.
  - **Expected**: Clear map of current supported actions and missing reauth states.

- [X] T002 Audit Firestore deletion strategy for all `users/{userId}` subcollections.
  - **Why**: Account deletion must not orphan finance data.
  - **Benefit**: Identifies whether client deletion is enough or backend deletion is needed.
  - **Expected**: Deletion order and limitations documented.

## Phase 2: Reauth Contract And Tests

- [X] T003 Add fake tests for email/password reauth success, wrong password, cancel, network failure, and recent-login-required.
  - **Why**: Email/password has credential input edge cases.
  - **Benefit**: Keeps sensitive flow predictable.
  - **Expected**: AccountProfileCubit or service tests cover each state.

- [X] T004 Add fake tests for Google reauth success, cancel, provider unavailable, network failure, and recent-login-required.
  - **Why**: Google reauth behavior differs from password reauth.
  - **Benefit**: Prevents provider-specific regressions.
  - **Expected**: Provider-aware states are covered.

- [X] T005 Add `ReauthRequest`/state models in the account feature or auth repository layer.
  - **Why**: UI needs a provider-neutral way to ask for reauth.
  - **Benefit**: Keeps Firebase/plugin details out of widgets.
  - **Expected**: Model describes provider, required user input, progress, and result.

## Phase 3: Deletion Flow

- [X] T006 [US2] Add destructive warning and typed/explicit confirmation UI in `lib/screens/account/`.
  - **Why**: Deletion is irreversible and high trust.
  - **Benefit**: Prevents accidental account loss.
  - **Expected**: User cannot start deletion without explicit confirmation.

- [X] T007 [US1] Wire recent-login-required to provider-specific reauth UI.
  - **Why**: Firebase may reject stale auth sessions.
  - **Benefit**: User can recover without restarting the app.
  - **Expected**: Delete/update retries after successful reauth.

- [X] T008 [US2] Implement safe deletion sequencing in `AccountDeletionService`.
  - **Why**: App data and Auth account deletion must not drift.
  - **Benefit**: Reduces orphaned data/privacy risk.
  - **Expected**: Failures stop with clear state and do not falsely report completion.

- [X] T009 [US3] Hide or explain provider-specific unsupported actions.
  - **Why**: Google-only and password users have different account actions.
  - **Benefit**: Reduces confusion.
  - **Expected**: UI shows only valid actions or localized unavailable copy.

## Phase 4: Localization And QA

- [X] T010 Add/update ARB keys for reauth, deletion warning, cancel, partial failure, and success states.
  - **Why**: Sensitive flows need clear localized copy.
  - **Benefit**: Arabic and English users understand consequences.
  - **Expected**: `app_en.arb` and `app_ar.arb` include all new messages.

- [X] T011 Run `flutter gen-l10n`.
  - **Why**: New ARB keys need generated getters.
  - **Benefit**: Catches malformed localization.
  - **Expected**: Generated l10n succeeds.

- [X] T012 Add/update Account/Profile widget tests for provider-specific actions.
  - **Why**: UI must stay honest for both account types.
  - **Benefit**: Prevents unsupported actions reappearing.
  - **Expected**: Google and email/password fixtures pass.

- [X] T013 Update `docs/qa/production-device-qa.md` with real Firebase deletion smoke steps.
  - **Why**: Fake tests cannot prove real Firebase deletion behavior.
  - **Benefit**: Makes final release validation explicit.
  - **Expected**: QA checklist covers Google and email/password deletion.

## Phase 5: Verification

- [X] T014 Run targeted account/auth/settings tests.
  - **Why**: Reauth touches several account surfaces.
  - **Benefit**: Confirms fake flows.
  - **Expected**: Targeted tests pass.

- [X] T015 Run `flutter analyze --no-pub`.
  - **Why**: New states and localization can leave stale references.
  - **Benefit**: Static safety.
  - **Expected**: No analyzer issues.
