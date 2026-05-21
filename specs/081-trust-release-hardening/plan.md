# Implementation Plan: Trust Release Hardening

**Branch**: `081-trust-release-hardening` | **Date**: 2026-05-21 | **Spec**: `specs/081-trust-release-hardening/spec.md`  
**Input**: Feature specification from `specs/081-trust-release-hardening/spec.md`

## Summary

Consolidate the highest-risk trust issues found in the recent review: stale exchange-rate reuse after base-currency changes, destructive account deletion before reauthentication, incomplete paid/destructive feature surfaces, and documentation mismatches. The implementation must preserve the current architecture while adding targeted tests and small hardening changes around finance calculations, account deletion, readiness gates, and docs.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing Bloc/Cubit, `expense_repository`, Firebase Auth/Firestore repository boundaries, generated l10n, existing finance services  
**Storage**: Existing `UserSettings` and Firestore user-scoped data. Avoid schema additions unless a task proves they are required.  
**Testing**: Flutter widget/unit tests under `test/settings`, `test/services`, `test/account`, `test/monetization`, `test/category_budgets`, `test/subscriptions`, `test/export`, `test/home`, `test/reports`, and analyzer.  
**Target Platform**: Android mobile first, with shared Flutter code kept platform-neutral.  
**Project Type**: Mobile app with Firebase-backed repositories and Cloudflare Worker AI gateway.  
**Performance Goals**: Exchange-rate checks remain local and O(number of supported currencies). Finance aggregation remains in-memory over loaded expenses.  
**Constraints**: No hardcoded rates, no provider calls during screen rendering, no production secrets, no purchase enablement without backend verification, no release build unless explicitly requested.  
**Scale/Scope**: One authenticated user's settings and loaded finance data, plus visible app entry points and docs.

## Constitution Check

- Spec Kit artifacts live under `specs/081-trust-release-hardening/`: PASS.
- Finance code must not hardcode exchange rates and must use saved-rate conversion semantics: PASS.
- Mixed currencies must not be silently added without a valid saved rate: PASS.
- Settings writes must use `SettingsRepository` and satisfy Firestore settings rules: PASS.
- Account/profile work must use `AccountProfileCubit` and account services, not direct widget plugin access: PASS.
- Deletion must require warning/confirmation, avoid orphaning user data, and validate Google/email-password paths: PASS.
- Monetization must stay behind `FeatureGateService`, repositories, and disabled purchase hooks until backend verification exists: PASS.
- New user-facing strings must use ARB and `flutter gen-l10n`: PASS.
- External production tasks remain in `docs/implementation_plans/deferred-and-advanced-work.md`: PASS.

## Project Structure

### Documentation

```text
specs/081-trust-release-hardening/
|-- spec.md
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- checklists/
|   `-- requirements.md
`-- tasks.md

docs/implementation_plans/deferred-and-advanced-work.md
docs/finance/currency-policy.md
docs/app-ai-context-and-improvement-audit.md
README.md
LICENSE
```

### Source Code

```text
lib/screens/settings/blocs/settings_bloc/settings_cubit.dart
lib/screens/settings/widgets/currency_settings_section.dart
lib/services/exchange_rates/exchange_rate_refresh_service.dart
lib/services/finance/financial_calculation_service.dart
lib/screens/account/cubit/account_profile_cubit.dart
lib/screens/account/services/account_deletion_service.dart
lib/screens/account/services/account_profile_service.dart
lib/screens/account/views/account_profile_screen.dart
lib/feature_flags/feature_readiness.dart
lib/screens/monetization/views/free_premium_screen.dart
lib/screens/monetization/widgets/premium_cta_panel.dart
lib/screens/settings/widgets/monetization_settings_section.dart
lib/screens/settings/widgets/privacy_settings_section.dart
lib/screens/category_budgets/services/category_budget_calculator.dart
lib/screens/subscriptions/services/subscription_summary_service.dart
lib/services/export/export_service.dart
lib/engagement/services/weekly_digest_calculator.dart
lib/ai/services/ai_advice_service.dart
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
```

### Tests

```text
test/settings/settings_cubit_test.dart
test/services/exchange_rate_refresh_service_test.dart
test/services/financial_calculation_service_test.dart
test/account/account_profile_cubit_test.dart
test/account/account_profile_screen_test.dart
test/monetization/free_premium_screen_test.dart
test/settings/feature_readiness_settings_test.dart
test/category_budgets/
test/subscriptions/
test/export/
test/home/
test/reports/
```

## Root Causes

### Currency cache

`SettingsCubit.saveBaseCurrency` currently keeps existing `conversionRates` except the new base key. `ExchangeRateRefreshService.refreshIfNeeded` returns early when `exchangeRatesUpdatedAt` is today, regardless of whether those rates were fetched for the current base currency or whether all current target currencies have rates. This can reuse an old-direction rate after a base-currency change.

### Account deletion

`AccountDeletionService.deleteAccount` deletes user data before deleting the Firebase Auth account. If Auth deletion fails with `requires-recent-login`, the current user data may already be removed. Existing tests encode that unsafe order, so tests must be updated first.

### Feature readiness

Premium, ads, wallets, transfers, backup, and restore have foundations or readiness gates, but the implementation must keep proving that incomplete surfaces do not start real paid or destructive workflows.

### Documentation

The README references `LICENSE`, but the file is absent. The product/AI audit contains mojibake in an Arabic section. Deferred work already tracks most external blockers, but this plan must re-check that newly found risks are not lost.

## Design Decisions

### Decision 1: Clear rates on base-currency change

When the base currency changes, clear conversion rates and clear the exchange-rate timestamp before saving settings. This is the least risky fix because rates are keyed only by source currency and do not store the base currency they were fetched against.

**Alternative considered**: Add `exchangeRateBaseCurrency` to `UserSettings`. This would make provenance explicit, but it requires schema/rules/entity changes. Keep this as a future option if clearing and target coverage are not enough.

### Decision 2: Fresh means date plus target coverage

Daily freshness should be true only when the timestamp is today and every supported non-base currency has a positive finite saved rate. Missing or invalid target rates must refresh or remain visible as missing.

### Decision 3: Reauthentication is a precondition for deletion

The deletion UI/cubit should request reauthentication before destructive data deletion. `AccountDeletionService` should not delete user data unless the caller has passed through the recent-auth gate for the current deletion attempt.

### Decision 4: Incomplete foundations stay gated

Do not turn Premium, wallets, transfers, backup restore, or purchase restore into user-facing complete features in this plan. Tighten readiness tests and copy instead.

### Decision 5: Historical immutable reporting remains deferred

This plan fixes current wrong-rate reuse and transparency. Immutable transaction-date reporting needs rate snapshots or a historical rate store and remains deferred unless the implementation discovers a minimal non-schema guard is required.

## Implementation Strategy

1. Add failing tests for stale base-currency rates, missing target rates, and account deletion reauth ordering.
2. Fix settings and exchange-rate refresh behavior.
3. Harden the account deletion state machine so recent auth happens before data removal.
4. Audit secondary finance surfaces and align them with shared conversion metadata or explicit conservative behavior.
5. Verify incomplete feature readiness gates remain safe and localized.
6. Clean docs and update deferred backlog references where necessary.
7. Run targeted verification and analyzer. Build only if the user explicitly asks for an artifact.

## Risks

- Clearing rates after base-currency change can temporarily show missing-rate warnings until refresh succeeds. This is preferable to showing wrong totals.
- Existing users with stale pre-fix rates may still need one successful refresh or a base-currency resave to repair local settings. The implementation should document this in the currency policy.
- Client-side account deletion cannot guarantee perfect atomicity if a network failure happens after data deletion but before Auth deletion. A trusted backend recursive deletion path remains the stronger future solution.
- Broad finance-surface auditing can expand scope. If a surface is intentionally conservative, document the behavior rather than rewriting every feature in this plan.
- Gating Premium/restore too aggressively can hide future work, so readiness copy must explain the state without promising production readiness.

## Deferred Items Considered

The persistent backlog already tracks production Firebase smoke tests, release keystore, production-device QA, real AI gateway QA, production AdMob IDs, purchase verification backend, restore write execution, wallet/transfer UI completion, historical exchange rates, and Arabic PDF visual inspection. This plan directly addresses current code/documentation hardening and keeps those external or larger product items deferred unless the user explicitly pulls them into scope.
