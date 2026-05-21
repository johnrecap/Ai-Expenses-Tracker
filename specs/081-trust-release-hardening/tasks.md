# Tasks: Trust Release Hardening

**Input**: `specs/081-trust-release-hardening/spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`  
**Goal**: Fix the highest-risk trust issues without enabling incomplete production-only features.

## Phase 1: Setup And Regression Baseline

- [X] T001 [P] Create `specs/081-trust-release-hardening/implementation-notes.md` with the exact current behaviors found before code changes. **Why**: The worker needs a baseline so fixes do not drift into broad refactors. **Expected**: Notes list stale base-rate reuse, same-day missing-target skip, account deletion order, readiness gates, and docs mismatches. **Risk**: Skipping this can make later verification vague. **Modify**: New spec-local notes file only.
- [X] T002 [P] Add or update currency fixtures in `test/fixtures/finance_fixtures.dart` and `test/helpers/ui_fixture_data.dart`. **Why**: Conversion bugs need repeatable EGP/USD/EUR scenarios. **Expected**: Tests can represent old EGP-base rates, new USD-base settings, missing targets, and invalid rates. **Risk**: Fixture changes can affect unrelated tests if defaults change. **Modify**: Add named fixtures without changing broad defaults unless necessary.
- [X] T003 [P] Check fake settings repositories in `test/helpers/fake_repositories.dart`, `test/settings/settings_cubit_test.dart`, and `test/onboarding/onboarding_cubit_test.dart` for timestamp-clearing support. **Why**: Base-currency fixes need tests that prove `exchangeRatesUpdatedAt` can be cleared. **Expected**: Fakes mirror the real `UserSettings.copyWith(clearExchangeRatesUpdatedAt: true)` behavior. **Risk**: Inaccurate fakes can hide Firestore/settings bugs. **Modify**: Update fake methods only where tests need them.

## Phase 2: Foundational Failing Tests

- [X] T004 [P] Add failing stale-base regression tests in `test/settings/settings_cubit_test.dart`. **Why**: Current `saveBaseCurrency` preserves old conversion rates, which can create wrong totals. **Expected**: Tests fail until base change clears conversion rates and timestamp. **Risk**: Test may be too strict if it expects network refresh inside settings cubit. **Modify**: Assert local settings invalidation only, not provider calls.
- [X] T005 [P] Add failing missing-target freshness tests in `test/services/exchange_rate_refresh_service_test.dart`. **Why**: Same-day freshness should not skip refresh when a newly supported currency has no valid rate. **Expected**: Tests fail until refresh requires target coverage. **Risk**: Over-refreshing could break the once-daily rule. **Modify**: Cover both fresh-with-full-coverage and fresh-date-missing-target cases.
- [X] T006 [P] Add failing deletion ordering tests in `test/account/account_profile_cubit_test.dart` and `test/account/account_deletion_service_test.dart`. **Why**: Existing tests currently accept data deletion before recent-auth checks. **Expected**: Tests fail until data deletion is blocked before reauth succeeds. **Risk**: Tests must distinguish warning confirmation from recent-auth confirmation. **Modify**: Add fake service call ordering assertions.
- [X] T007 [P] Add readiness regression tests in `test/monetization/free_premium_screen_test.dart` and `test/settings/feature_readiness_settings_test.dart`. **Why**: Paid and destructive incomplete surfaces must not accidentally become clickable. **Expected**: Tests prove purchase, restore purchase, restore execution, and incomplete wallet/transfer actions are disabled or coming soon. **Risk**: Tests may become brittle if copy changes. **Modify**: Prefer semantic state/disabled assertions over full text matching where possible.

## Phase 3: User Story 1 - Currency Totals Stay Trustworthy (Priority: P1)

**Goal**: Prevent wrong mixed-currency totals after base/support currency changes.

**Independent Test**: T004 and T005 pass, then Home/Reports/Budget/export tests prove converted and missing currencies are handled consistently.

- [X] T008 [US1] Update `lib/screens/settings/blocs/settings_bloc/settings_cubit.dart` so `saveBaseCurrency` clears `conversionRates` and clears `exchangeRatesUpdatedAt`. **Why**: Rates do not store the base they were fetched against. **Expected**: Old-direction rates cannot be reused after base change. **Risk**: Users may briefly see missing-rate warnings until refresh succeeds. **Modify**: Use existing settings copy semantics and preserve `supportedCurrencies` including the new base.
- [X] T009 [US1] Update `lib/services/exchange_rates/exchange_rate_refresh_service.dart` so freshness requires today's timestamp plus valid target coverage. **Why**: Adding a new currency after today's refresh currently can leave it without a rate until tomorrow. **Expected**: Missing or invalid target rates trigger refresh or remain visibly unconverted. **Risk**: Bad target calculation can cause unnecessary network calls. **Modify**: Add a helper such as `_hasValidTargetCoverage(settings, targets)` and keep in-flight key behavior.
- [X] T010 [US1] Update `test/services/exchange_rate_refresh_service_test.dart` for provider failure after base change. **Why**: Offline fallback must not turn unknown rates into wrong totals. **Expected**: When refresh fails after rates are cleared, settings keep missing-rate metadata instead of fake converted totals. **Risk**: Test can over-specify UI behavior. **Modify**: Assert returned settings and repository state only.
- [X] T011 [US1] Audit `lib/services/finance/financial_calculation_service.dart`, `lib/screens/home/services/money_conversion_service.dart`, and `lib/services/report_calculator.dart` for consistent invalid-rate handling. **Why**: Shared conversion boundaries must agree on zero, negative, non-finite, missing, and same-currency behavior. **Expected**: Finance totals never silently add incompatible currencies. **Risk**: Changing shared behavior can shift many expected totals. **Modify**: Prefer one shared helper for positive finite rate validation if duplication is found.
- [X] T012 [US1] Audit secondary finance surfaces in `lib/screens/category_budgets/services/category_budget_calculator.dart`, `lib/screens/subscriptions/services/subscription_summary_service.dart`, `lib/services/export/export_service.dart`, `lib/engagement/services/weekly_digest_calculator.dart`, and `lib/ai/services/ai_advice_service.dart`. **Why**: The user sees trust breakage when Home and Reports agree but secondary screens disagree. **Expected**: Each surface either uses saved-rate conversion metadata or clearly keeps conservative same-currency behavior. **Risk**: Scope can expand into full feature rewrites. **Modify**: Make minimal consistency fixes and document intentionally conservative surfaces.
- [X] T013 [US1] Add or update tests in `test/services/financial_calculation_service_test.dart`, `test/category_budgets/`, `test/subscriptions/`, `test/export/`, `test/home/`, and `test/reports/`. **Why**: Currency correctness must be proven across visible finance screens. **Expected**: Converted totals, converted currency notes, and missing-rate warnings match the shared policy. **Risk**: Large test blast radius. **Modify**: Use small fixtures and focused assertions.
- [X] T014 [US1] Update `docs/finance/currency-policy.md` to describe base-currency invalidation, same-day target coverage, and current historical-rate limits. **Why**: Future workers need to know why old rates are cleared. **Expected**: Policy matches implementation and explains offline behavior. **Risk**: Docs may imply immutable historical reporting is fixed. **Modify**: Explicitly keep transaction-date snapshots deferred.

## Phase 4: User Story 2 - Safe Account Deletion (Priority: P1)

**Goal**: Reauthenticate before destructive data deletion.

**Independent Test**: Recent-login-required deletion scenarios make zero data deletion calls before successful reauthentication.

- [X] T015 [US2] Update `lib/screens/account/services/account_deletion_service.dart` to require a recent-auth confirmation flag before calling `deleteUserData`. **Why**: Service-level guard prevents any UI path from deleting data too early. **Expected**: Calling deletion without recent-auth confirmation returns a `requires-recent-login` style error and leaves data untouched. **Risk**: A careless flag can become a fake bypass. **Modify**: Name the parameter clearly, keep warning confirmation separate, and cover it with tests.
- [X] T016 [US2] Update `lib/screens/account/cubit/account_profile_cubit.dart` so warning confirmation creates a deletion reauth request before calling the destructive service. **Why**: The user should authenticate first, not after a failed auth delete. **Expected**: Google and email/password accounts go through provider-specific reauth before deletion. **Risk**: Unknown providers may get stuck. **Modify**: Map unknown/unavailable providers to a clear non-busy failure state.
- [X] T017 [US2] Update `lib/screens/account/models/account_capabilities.dart` and `lib/screens/account/models/reauth_request.dart` only if needed to model deletion pre-reauth explicitly. **Why**: The state model must distinguish update-email reauth from delete-account reauth. **Expected**: Delete flow is readable and testable. **Risk**: Overcomplicating capabilities can affect unrelated profile actions. **Modify**: Add the smallest field or reuse existing action enum if sufficient.
- [X] T018 [US2] Update `lib/screens/account/views/account_profile_screen.dart` and ARB files only if the new flow needs clearer copy. **Why**: Users need to understand why they are reauthenticating before deletion. **Expected**: English and Arabic copy explain the sensitive action without adding profile photos or support-contact scope. **Risk**: Hardcoded text or untranslated copy. **Modify**: Use `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`, then run `flutter gen-l10n`.
- [X] T019 [US2] Update `test/account/account_profile_cubit_test.dart` and `test/account/account_profile_screen_test.dart` for the new order. **Why**: Current tests encode unsafe `data` then `auth` order and must be corrected. **Expected**: Tests assert no data deletion before reauth and one deletion sequence after successful reauth. **Risk**: Old expectations can mask the fix if not removed. **Modify**: Replace the unsafe ordering test rather than adding a contradictory new one.
- [X] T020 [US2] Add failure-path tests for cancelled Google reauth, wrong password, unavailable provider, data-delete failure after reauth, and auth-delete failure after data deletion. **Why**: Destructive flows need clear recovery states. **Expected**: Every failure returns to a non-spinning state with a meaningful message. **Risk**: Client-side deletion cannot be fully atomic. **Modify**: Document partial-failure risk in service comments or docs without claiming backend-level guarantees.

## Phase 5: User Story 3 - Honest Incomplete Feature Surfaces (Priority: P2)

**Goal**: Keep incomplete paid, wallet, transfer, backup, and restore workflows safe.

**Independent Test**: Settings and Premium screens expose no real paid or destructive action while backends/workflows are incomplete.

- [X] T021 [US3] Audit `lib/feature_flags/feature_readiness.dart` and `specs/079-incomplete-feature-surface-readiness/readiness-matrix.md` for all incomplete surfaces. **Why**: The implementation needs one source of truth for availability. **Expected**: Premium purchase/restore, wallet management, transfer management, backup export, restore preview, and restore execution have explicit states. **Risk**: Duplicated readiness logic can drift. **Modify**: Centralize states or update the matrix to match code.
- [X] T022 [US3] Verify `lib/screens/monetization/views/free_premium_screen.dart` and `lib/screens/monetization/widgets/premium_cta_panel.dart` cannot trigger real purchase or restore when backend verification is disabled. **Why**: Paid entitlement must not be client-trusted. **Expected**: CTA is disabled, sandbox-labelled, or explanatory. **Risk**: Overly hidden monetization may confuse testers. **Modify**: Keep explanatory localized copy.
- [X] T023 [US3] Verify `lib/screens/settings/widgets/monetization_settings_section.dart` and `lib/screens/settings/widgets/privacy_settings_section.dart` show safe readiness states. **Why**: Settings is where users discover account, premium, backup, and privacy actions. **Expected**: Incomplete actions are disabled or coming soon, never silently clickable. **Risk**: Broken layout or stale text after localization. **Modify**: Use existing reusable settings rows and l10n.
- [X] T024 [US3] Verify `lib/services/backup/restore_preview.dart`, `lib/services/backup/backup_serializer.dart`, and any restore entry point do not perform repository writes. **Why**: Restore can overwrite user finance data if enabled early. **Expected**: Restore remains preview-only or disabled until conflict policy and write tests exist. **Risk**: A partial restore UI could look complete. **Modify**: Keep execution gated and update readiness copy if needed.
- [X] T025 [US3] Add tests in `test/backup/backup_serializer_test.dart`, `test/settings/feature_readiness_settings_test.dart`, and `test/monetization/free_premium_screen_test.dart` for disabled destructive/paid actions. **Why**: Gating must survive future UI edits. **Expected**: Tests fail if an unavailable action becomes tappable. **Risk**: Tests can become copy-sensitive. **Modify**: Prefer disabled callbacks, readiness state, or semantic assertions.

## Phase 6: User Story 4 - Documentation And Deferred Work Accuracy (Priority: P3)

**Goal**: Make repo docs reliable for future developers and AI reviewers.

**Independent Test**: Open docs and confirm the current product, release blockers, and deferred items match code.

- [X] T026 [US4] Fix mojibake or rewrite the affected Arabic/product context in `docs/app-ai-context-and-improvement-audit.md`. **Why**: Corrupted text lowers the quality of future analysis and planning. **Expected**: The affected section is readable in UTF-8. **Risk**: Rewriting can accidentally change product meaning. **Modify**: Preserve intent; if unclear, replace with a concise current English summary.
- [X] T027 [US4] Resolve the README license mismatch by adding `LICENSE` or changing the license section in `README.md`. **Why**: README currently points to a missing file. **Expected**: The repository has no broken license reference. **Risk**: Choosing a license is a legal/product decision. **Modify**: If the project already claims MIT, add a standard MIT `LICENSE`; otherwise remove the claim and mark license undecided.
- [X] T028 [US4] Update `docs/implementation_plans/deferred-and-advanced-work.md` after the code changes. **Why**: Deferred items are the persistent project memory. **Expected**: Historical rate snapshots, trusted backend deletion, production Firebase smoke, AdMob, purchase verification, wallet UI, and restore execution are present without duplicates. **Risk**: Duplicates make the backlog noisy. **Modify**: Merge with existing bullets instead of adding repeated entries.
- [X] T029 [US4] Update `.specify/memory/constitution.md` only if this implementation establishes a new convention. **Why**: The constitution should reflect architecture changes, not every small fix. **Expected**: If base-currency invalidation or deletion pre-reauth becomes a new rule, it is recorded. **Risk**: Over-updating the constitution makes it noisy. **Modify**: Add concise convention bullets only when behavior changed.

## Phase 7: Verification And Handoff

- [X] T030 Run `flutter gen-l10n` if ARB files changed. **Why**: Generated localization getters must match ARB changes. **Expected**: Generated l10n compiles. **Risk**: Skipping this causes analyzer errors. **Modify**: Generated l10n files only.
- [X] T031 Run targeted tests from `specs/081-trust-release-hardening/quickstart.md`. **Why**: The plan touches finance, account deletion, readiness gates, and docs-adjacent UI. **Expected**: Targeted tests pass. **Risk**: Broad command can be slow on Windows. **Modify**: If it hangs, split by directory while keeping command evidence.
- [X] T032 Run `flutter analyze --no-pub`. **Why**: Static analysis catches stale imports and l10n getter errors. **Expected**: No issues. **Risk**: Local Flutter toolchain can hang if SDK cache locks. **Modify**: Use the verification runbook if needed; do not leave hung processes.
- [X] T033 Build a non-debug artifact only if the user explicitly requests it after tests pass. **Why**: The user repeatedly asked to avoid unnecessary builds during planning/implementation. **Expected**: No build time is spent unless needed for device testing. **Risk**: Building too early wastes time and can hide test failures. **Modify**: Use the requested release/profile command only after verification.

## Dependencies

- Phase 1 and Phase 2 must finish before implementation.
- US1 and US2 are both P1 and can be worked in parallel by different developers if they do not touch the same tests.
- US3 can start after readiness baseline tests exist.
- US4 can run in parallel with code work except constitution updates should wait until implementation choices are known.
- Verification runs after all selected stories are complete.

## MVP Scope

MVP is US1 plus US2: currency totals must not be wrong, and account deletion must not delete data before reauthentication. US3 and US4 are important hardening but can follow after P1 behavior is safe.

## Implementation Notes

- **Completed**: Base-currency changes now clear saved rates and `exchangeRatesUpdatedAt`; same-day exchange-rate freshness now requires valid coverage for every supported non-base currency.
- **Completed**: Account deletion now requires provider-specific reauthentication before user-scoped data deletion. Data is deleted before Auth only after recent auth succeeds, preserving Firestore user-scope permissions.
- **Completed**: Readiness gates remained safe for Premium purchase/restore, wallet/transfer, backup, and restore execution. Existing tests cover disabled/non-actionable states.
- **Completed**: `docs/finance/currency-policy.md`, `docs/app-ai-context-and-improvement-audit.md`, deferred backlog, constitution, and `LICENSE` were updated.
- **Verification**: `flutter test --no-pub test/settings/settings_cubit_test.dart test/services/exchange_rate_refresh_service_test.dart test/services/financial_calculation_service_test.dart test/account test/monetization/free_premium_screen_test.dart test/settings/feature_readiness_settings_test.dart test/category_budgets test/subscriptions test/export test/home test/reports --reporter expanded --concurrency=1 --timeout 45s` passed with 98 tests.
- **Verification**: `flutter analyze --no-pub` passed with no issues.
- **Not run**: `flutter gen-l10n` was not needed because no ARB files changed. No build was run because the plan says to build only on explicit request.

