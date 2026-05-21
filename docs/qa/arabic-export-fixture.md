# Arabic Mixed-Language Export Fixture

Date: 2026-05-20
Spec: `specs/066-localization-rtl-final-pass/`

## Purpose

Use this repeatable fixture for Arabic PDF/export QA after `flutter gen-l10n`
is run. It covers Arabic descriptions, English merchant-like text, dates,
amounts, payment methods, and mixed currencies.

## Locale And Settings

- App language: Arabic
- Base currency: EGP
- Default payment method: Wallet
- Export range: 2026-05-01 through 2026-05-31
- Export formats to inspect: PDF first, then CSV/Excel headers if needed

## Categories

| Name | Icon Type | Notes |
| --- | --- | --- |
| طعام | Food | Arabic category name |
| مواصلات | Transport | Arabic category name |
| Subscriptions | Subscription/media | English user-created category |

## Expenses

| Date | Amount | Currency | Category | Payment | Description |
| --- | ---: | --- | --- | --- | --- |
| 2026-05-03 | 125.50 | EGP | طعام | Wallet | غداء العائلة |
| 2026-05-05 | 18 | USD | مواصلات | Visa | Uber airport |
| 2026-05-09 | 65 | EGP | طعام | Cash | قهوة Starbucks |
| 2026-05-14 | 10 | USD | Subscriptions | Visa | Netflix شهري |
| 2026-05-19 | 230 | EGP | مواصلات | Bank Transfer | مواصلات القاهرة الجديدة |

## Expected PDF Checks

- PDF title, period label, total label, and table headers use Arabic labels.
- Arabic descriptions render with readable glyphs and correct direction.
- English merchant names such as `Uber airport`, `Starbucks`, and `Netflix`
  remain readable inside mixed Arabic rows.
- Amounts, ISO currency codes, and dates remain visually scannable.
- The table does not reverse columns in a way that makes category/payment/date
  unreadable.
- If the Arabic font asset is missing, the user-facing failure message is
  localized instead of exposing a raw service exception.

## Status

- Fixture documented only.
- PDF was not generated in this pass because the worker was explicitly
  instructed not to run Flutter/build/test/generation commands.
