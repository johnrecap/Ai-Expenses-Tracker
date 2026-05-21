# Tasks: Incomplete Feature Surface Readiness

**Input**: `specs/079-incomplete-feature-surface-readiness/spec.md`, `plan.md`  
**Goal**: Prevent incomplete foundations from appearing as finished or risky user workflows.

## Phase 1: Entry Point Audit

- [X] T001 Audit visible feature entry points in `lib/screens/settings/`, `lib/screens/home/`, `lib/screens/monetization/`, and any menu/routes for Premium, Wallets, Transfers, Backup, and Restore. **Why**: Users can only be harmed by visible or callable paths. **Fixes**: Unknown incomplete entry points. **Expected**: Complete readiness map. **Done**: Found Premium CTA/settings surfaces, Privacy settings, backup serializer/restore preview foundation, and no complete Wallets/Transfers UI route.
- [X] T002 Add a readiness matrix document in `specs/079-incomplete-feature-surface-readiness/readiness-matrix.md`. **Why**: Keeps hide/disable/complete decisions explicit. **Fixes**: Ambiguous feature state. **Expected**: Each feature has owner, state, route, risk, and action.
- [X] T003 [P] Add widget tests for unavailable feature gates in `test/settings/feature_readiness_settings_test.dart`. **Why**: Settings is where incomplete features are likely exposed. **Fixes**: Accidental clickable incomplete rows. **Expected**: Disabled/hidden states are enforced. **Note**: Added but not run per user instruction.

## Phase 2: Shared Readiness Copy And Gates

- [X] T004 Add localized readiness copy in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`. **Why**: Disabled states must be understandable. **Fixes**: Generic or English-only unavailable messages. **Expected**: Clear Arabic/English explanations. **Done**: Added English/Arabic readiness strings and manually updated generated localization files because `flutter gen-l10n` was explicitly not run.
- [X] T005 Create or extend a feature readiness helper in `lib/feature_flags/` or the existing monetization/settings pattern. **Why**: Entry point logic should be consistent. **Fixes**: Ad hoc hiding in many widgets. **Expected**: Central readiness states for premium backend, wallet UI, restore execution.
- [X] T006 Run `flutter gen-l10n`. **Why**: New readiness copy must generate getters. **Fixes**: Missing generated localization. **Expected**: l10n files updated.

## Phase 3: Premium Safety

- [X] T007 [US4] Update `lib/screens/monetization/views/free_premium_screen.dart` so real purchase CTA is disabled or sandbox-labelled when trusted backend verification is unavailable. **Why**: Users must not be asked to pay for unverified entitlement. **Fixes**: Premature purchase flow risk. **Expected**: Premium page is honest and safe. **Done**: CTA panel no longer calls `buyPremium` or `restorePurchases` from disabled buttons.
- [X] T008 [US4] Update `lib/screens/settings/widgets/monetization_settings_section.dart` to show premium readiness accurately. **Why**: Settings is a common discovery point. **Fixes**: Misleading premium status. **Expected**: Free/Premium state is clear.
- [X] T009 [US4] Add monetization readiness tests in `test/monetization/free_premium_screen_test.dart`. **Why**: Prevents accidental production enablement. **Fixes**: CTA regression. **Expected**: Tests prove no real purchase without backend verification. **Note**: Added assertions but not run per user instruction.

## Phase 4: Wallets And Transfers Minimum Slice

- [ ] T010 [US2] Add Wallets route and screen shell in `lib/screens/wallets/`. **Why**: Domain/repository exists but no user flow. **Fixes**: Invisible/incomplete wallet feature. **Expected**: User can view wallets or see an honest empty state. **Deferred**: Safe gating was implemented instead of full Wallet UI.
- [ ] T011 [US2] Add create/edit/archive wallet UI in `lib/screens/wallets/`. **Why**: A wallet list without management is not useful. **Fixes**: Half-complete wallet surface. **Expected**: User can maintain wallet accounts. **Deferred**: Requires full wallet management slice.
- [ ] T012 [US2] Add optional wallet selector to `lib/screens/add_expense/views/add_expense.dart`. **Why**: Expenses need wallet assignment to make wallets valuable. **Fixes**: Wallets disconnected from transactions. **Expected**: New expenses can reference a wallet. **Deferred**: Requires wallet list UI/repository wiring.
- [ ] T013 [US2] Add wallet selector to `lib/screens/expenses/widgets/expense_edit_sheet.dart`. **Why**: Existing expenses must be correctable. **Fixes**: Wallet assignment cannot be edited. **Expected**: Edited expenses preserve/update wallet snapshot. **Deferred**: Requires wallet selector policy.
- [ ] T014 [US2] Add transfer form in `lib/screens/wallets/` using `TransferRepository`. **Why**: Transfers are a core wallet operation. **Fixes**: Transfer model exists without workflow. **Expected**: User can create a transfer separate from spending. **Deferred**: Requires transfer UI and currency policy.
- [ ] T015 [US2] Add report/budget regression tests proving transfers are excluded from spending totals. **Why**: Transfers are movement, not consumption. **Fixes**: Inflated spending if transfers leak into expense totals. **Expected**: Reports and budgets ignore transfers. **Deferred**: Keep with full transfer UI slice.

## Phase 5: Backup And Restore Safety

- [X] T016 [US3] Add backup export entry point in `lib/screens/settings/widgets/privacy_settings_section.dart`. **Why**: Backup exists only as service foundation. **Fixes**: No user-accessible export. **Expected**: User can start a safe backup export. **Done**: Added disabled Backup export readiness row; no export execution is wired until safe data collection exists.
- [ ] T017 [US3] Add restore preview UI in `lib/screens/settings/` or `lib/screens/backup/`. **Why**: Restore must show adds/updates/conflicts/skips before writing. **Fixes**: High-risk restore without visibility. **Expected**: User sees exact restore impact. **Deferred**: Added disabled readiness row only; full preview UI remains later work.
- [ ] T018 [US3] Implement restore confirmation state but keep repository writes disabled until T019-T020 pass. **Why**: Prevents destructive behavior during UI work. **Fixes**: Accidental writes. **Expected**: Confirmation UI exists without unsafe execution. **Deferred**: No confirmation UI because restore preview UI is not yet exposed.
- [ ] T019 [US3] Implement repository-backed restore execution with conservative conflict policy in `lib/services/backup/`. **Why**: Restore is incomplete without writes. **Fixes**: Preview-only feature. **Expected**: Confirmed restore writes only allowed adds/updates.
- [ ] T020 [US3] Add backup/restore round-trip and conflict tests in `test/backup/`. **Why**: Restore can damage data if untested. **Fixes**: Missing safety verification. **Expected**: Round-trip restore and conflict policy are proven.

## Phase 6: Verification

- [ ] T021 Run targeted tests: `flutter test --no-pub test/settings test/monetization test/backup test/repository test/reports --reporter expanded --concurrency=1 --timeout 45s`. **Why**: Feature gates touch multiple high-risk surfaces. **Fixes**: Cross-feature regressions. **Expected**: Targeted tests pass. **Not run**: User explicitly instructed this worker not to run tests.
- [X] T022 Run `flutter analyze --no-pub`. **Why**: New routes/helpers can introduce static errors. **Fixes**: Compile issues. **Expected**: Analyzer reports no issues.

## Implementation Notes From This Pass

- Files changed: `lib/feature_flags/feature_readiness.dart`, `lib/screens/monetization/widgets/premium_cta_panel.dart`, `lib/screens/monetization/views/free_premium_screen.dart`, `lib/screens/settings/widgets/monetization_settings_section.dart`, `lib/screens/settings/widgets/privacy_settings_section.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`, `test/monetization/free_premium_screen_test.dart`, `test/settings/feature_readiness_settings_test.dart`, and `specs/079-incomplete-feature-surface-readiness/readiness-matrix.md`.
- Risks: Parent integration pass regenerated localization and ran analyzer clean. Full 079 targeted suite remains broader than the integration subset; incomplete wallet/transfer and restore execution surfaces stay deferred.
- Deferred items already tracked in `docs/implementation_plans/deferred-and-advanced-work.md`: production Premium backend/restore entitlement, complete wallet/transfer UI and currency policy, and backup/restore write execution with tests.

## Dependencies

T001-T002 before all implementation. Premium safety can run independently from Wallets and Backup. Restore execution T019 must not start before preview/confirmation T017-T018 and tests T020 are planned.

## MVP Scope

Minimum safe MVP is T001-T009 plus T016-T018 with restore writes still disabled. Full feature completion adds wallet/transfer and restore execution.
