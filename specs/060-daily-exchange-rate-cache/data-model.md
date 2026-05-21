# Data Model: Daily Exchange Rate Cache

## UserSettings

Existing user-scoped settings entity extended with:

- `conversionRates`: `Map<String, double>` where key is source currency code and value is one source unit in the current base currency.
- `exchangeRatesUpdatedAt`: nullable `DateTime` timestamp for the last successful automatic exchange-rate refresh.

### Validation Rules

- Currency codes are normalized to uppercase.
- Base currency is never stored in `conversionRates`.
- Rates must be positive finite numbers.
- Rates for unsupported currencies are removed.
- `exchangeRatesUpdatedAt` may be absent for existing users; absent means refresh is due.

### State Transitions

1. Existing settings with no timestamp -> stale.
2. Stale settings + provider success -> merge refreshed rates, set `exchangeRatesUpdatedAt` to now.
3. Stale settings + provider failure -> settings unchanged, existing rates still used.
4. Fresh settings for today -> no provider refresh.
5. Supported currencies change -> existing filtering removes rates for removed currencies; next stale refresh updates the remaining set.

## ExchangeRateRefreshResult

Runtime-only result used by refresh orchestration:

- `settings`: effective settings after refresh attempt.
- `refreshed`: whether settings were saved during this attempt.
- `failed`: whether provider refresh failed.

No separate persisted entity is needed.
