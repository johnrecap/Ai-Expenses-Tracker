# Implementation Notes: Trust Release Hardening

## Baseline Before Code Changes

- `SettingsCubit.saveBaseCurrency` preserved existing `conversionRates` except the newly selected base currency key. Because rates are keyed only by source currency, this allowed rates fetched for the old base to be reused after the base changed.
- `ExchangeRateRefreshService.refreshIfNeeded` returned early when `exchangeRatesUpdatedAt` was today, even if the current supported non-base currency set had missing or invalid rates.
- `AccountDeletionService.deleteAccount` deleted user-scoped Firestore data before deleting the Firebase Auth user. If Auth deletion required recent login, data could already be gone.
- Existing account deletion cubit/widget tests encoded the unsafe `data` then `auth` call order.
- `FeatureReadiness` already gates Premium purchase/restore, wallet/transfer, backup, and restore execution as disabled or coming soon. This pass keeps those surfaces gated.
- README references `LICENSE`, but no `LICENSE` file exists.
- `docs/app-ai-context-and-improvement-audit.md` contains mojibake in the Arabic product summary section and needs cleanup.

## Implementation Boundaries

- No new exchange-rate provider.
- No production secrets, AdMob IDs, purchase verification, or keystore material.
- No release build unless explicitly requested after verification.
- Historical transaction-date exchange-rate snapshots remain deferred.
