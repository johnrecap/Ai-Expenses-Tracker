# Data Model: Trust Release Hardening

## ExchangeRateCacheState

Represents whether saved exchange rates are safe for current conversion.

- `baseCurrency`: Current user base currency.
- `supportedCurrencies`: User-selected currencies that may appear in new expenses.
- `targetCurrencies`: Supported currencies excluding base currency.
- `conversionRates`: Saved positive finite rates keyed by source currency into the current base currency.
- `exchangeRatesUpdatedAt`: Local timestamp of last successful rate refresh.
- `isFreshForToday`: True only when timestamp is today.
- `hasTargetCoverage`: True only when every target currency has a valid rate.
- `isSafeForConversion`: True only when date freshness and target coverage both pass.

## ConvertedMoneyResult

Represents a finance aggregation result shown to users.

- `baseCurrency`: Currency used for totals.
- `total`: Sum of same-currency and converted rows.
- `convertedCurrencies`: Source currencies included through saved rates.
- `unconvertedCurrencies`: Source currencies excluded because no valid rate exists.
- `rateUpdatedAt`: Timestamp used to explain cached-rate freshness.
- `rows`: Optional converted row metadata for exports or drilldowns.

## AccountDeletionFlowState

Represents a safe account deletion attempt.

- `warningConfirmed`: User accepted destructive warning.
- `providerType`: Google, email/password, or unknown.
- `reauthenticationRequired`: True before destructive deletion for supported providers.
- `reauthenticationStatus`: pending, succeeded, cancelled, failed, or unavailable.
- `deletionStatus`: idle, deletingData, deletingAuth, deleted, failed.
- `failureCode`: User-facing failure mapping.

## FeatureReadinessSurface

Represents the availability of a visible or callable app feature.

- `surface`: Premium purchase, Premium restore, wallet management, transfer management, backup export, restore preview, or restore execution.
- `state`: available, disabled, comingSoon, sandboxOnly, or hidden.
- `localizedTitle`: User-facing title from l10n.
- `localizedBody`: User-facing status explanation from l10n.
- `canStartAction`: Derived from state; destructive or paid flows require `available`.

## ReleaseDocumentationEvidence

Represents documentation that must remain accurate for future implementation.

- `documentPath`: README, product audit, deferred backlog, currency policy, or Spec Kit artifact.
- `claim`: The release/product claim being made.
- `evidence`: Code, test, external setup, or explicit deferred item supporting the claim.
- `status`: verified, deferred, blocked, or obsolete.
