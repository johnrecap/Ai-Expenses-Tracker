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
- When the user changes the base currency, saved conversion rates and the rate
  timestamp are cleared because the app cannot prove that rates fetched for the
  old base still apply to the new base.

## Local-First And VPS Migration

- In `firebaseLegacy` mode, settings and saved rates continue to come from the
  user-scoped Firestore settings document.
- In `vpsLocalFirst` mode, screens read the same settings/rate fields through
  the local repository boundary first. Sync later uploads/downloads the setting
  document through the VPS API.
- PostgreSQL is the durable server store after cutover, but Flutter must still
  calculate from local settings and local expenses. Widgets must not call the
  VPS for rate conversion during rendering.
- Backfill/import must preserve `baseCurrency`, `supportedCurrencies`,
  `conversionRates`, and `exchangeRatesUpdatedAt` exactly enough for migrated
  Home, Reports, Budget, Export, AI history, and weekly digest totals to match
  legacy behavior.

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

Same-day freshness is valid only when every supported non-base currency has a
positive finite saved rate. If a user adds a currency after today's refresh, or
if a target rate is missing/invalid, the app should refresh again or keep that
currency visible as unconverted.

## Historical Reports

Historical reports currently use the latest saved rate available in settings,
not a transaction-date exchange-rate snapshot. That means an older month can be
recalculated differently after rates change.

If immutable historical reporting becomes a product requirement, add
transaction-date rate snapshots to expenses or a dedicated historical rates
store, update Firestore rules, and migrate all calculation call sites to prefer
the stored snapshot for old transactions.

## Future Snapshot Policy

The PostgreSQL schema should keep room for transaction-date rate snapshots, but
Plan 082 does not turn that on for user-facing reporting. Before enabling
immutable historical reports:

- Store the original amount/currency on the expense.
- Store the base currency used at transaction time.
- Store the source-to-base rate, rate provider, and rate timestamp used for the
  displayed converted amount.
- Prefer the expense snapshot for historical reporting and use latest settings
  rates only for records that do not have a snapshot.
- Surface missing snapshot/rate metadata instead of silently recalculating old
  reports with today's rate.
