# Currency Policy

This app uses the user's base currency from `UserSettings.baseCurrency` for
dashboard, report, budget, AI summary, and weekly digest totals that are
conversion-aware.

## Current Rate Source

- Exchange rates are stored in `UserSettings.conversionRates`.
- Rates are keyed by source currency and convert from that source currency into
  the current base currency.
- `UserSettings.exchangeRatesUpdatedAt` records when the saved rates were last
  refreshed.
- Rendering financial totals must not make a network request. Screens use the
  saved rates already available in settings.

## Conversion Rules

- Same-currency expenses are added directly.
- Mixed-currency expenses are included only when a valid positive finite saved
  rate exists for the source currency.
- Missing, zero, negative, or non-finite rates are treated as unconverted.
- Unconverted currencies must remain visible through metadata instead of being
  silently added or hidden.

## Offline And Stale Rates

If the device is offline, the app keeps using the last saved valid rates. The
rate timestamp is retained in calculation metadata so UI or export surfaces can
explain that the total is based on cached rates.

## Historical Reports

Historical reports currently use the latest saved rate available in settings,
not a transaction-date exchange-rate snapshot. That means an older month can be
recalculated differently after rates change.

If immutable historical reporting becomes a product requirement, add
transaction-date rate snapshots to expenses or a dedicated historical rates
store, update Firestore rules, and migrate all calculation call sites to prefer
the stored snapshot for old transactions.
