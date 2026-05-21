# Tasks: Payment Methods And Currency Foundation

## Implementation Intent

Add the basic user settings and UI needed for payment methods and currency storage. This plan stores currency codes only; it must not pretend to perform exchange-rate conversion.

---

## Phase 1: Settings Data

### T001 - Create `UserSettings`

**Files:** Create `packages/expense_repository/lib/src/models/user_settings.dart`.

**Steps:** Include `userId`, `baseCurrency`, `supportedCurrencies`, `defaultPaymentMethod`, `updatedAt`.

**Done When:** Settings can represent default user finance preferences.

### T002 - Create `UserSettingsEntity`

**Files:** Create `packages/expense_repository/lib/src/entities/user_settings_entity.dart`.

**Steps:** Serialize to Firestore document; default missing base currency to `EGP`; default payment method to `cash`.

**Done When:** Settings can round-trip through Firestore.

### T003 - Create `SettingsRepository`

**Files:** Create `packages/expense_repository/lib/src/settings_repo.dart`.

**Steps:** Define get, watch, save/update settings methods.

**Done When:** UI does not use Firestore directly for settings.

### T004 - Implement `FirebaseSettingsRepository`

**Files:** Create `packages/expense_repository/lib/src/firebase_settings_repo.dart`.

**Steps:** Store settings at `users/{userId}/settings/profile`; create defaults if missing.

**Done When:** New users can get default settings.

---

## Phase 2: Settings UI

### T005 - Create Settings State Manager

**Files:** Create `lib/screens/settings/blocs/settings_bloc/` or Cubit equivalent.

**Steps:** Load settings, save base currency, save default payment method, emit loading/success/failure.

**Done When:** Settings screen can react to repository state.

### T006 - Create `SettingsScreen`

**Files:** Create `lib/screens/settings/views/settings_screen.dart`.

**Steps:** Render sections for currency and payment method; include loading/error states.

**Done When:** User can open settings and view current defaults.

### T007 - Add Base Currency Selector

**Steps:** Provide initial list such as `EGP`, `USD`, `EUR`, `SAR`, `AED`; save selected code.

**Done When:** Selection persists after restart.

### T008 - Add Default Payment Method Selector

**Steps:** Render Cash, Visa, Wallet, Bank Transfer; save enum string.

**Done When:** New expenses can default to selected method.

---

## Phase 3: Expense Integration

### T009 - Add Payment Method To Add Expense

**Files:** Modify `lib/screens/add_expense/views/add_expense.dart`.

**Steps:** Add selector; default from settings if available, otherwise Cash; save to `Expense.paymentMethod`.

**Done When:** New expense document has payment method.

### T010 - Add Currency To Add Expense

**Steps:** Add currency dropdown; default from settings base currency; save to `Expense.currency`.

**Done When:** New expense stores currency.

### T011 - Replace Hardcoded Currency Display

**Files:** Modify `lib/screens/home/views/main_screen.dart`.

**Steps:** Use expense currency code or formatter; remove hardcoded `$` for expense rows and totals where possible.

**Done When:** UI displays stored currency code/symbol consistently.

### T012 - Create Defaults On Registration

**Files:** Modify auth registration flow or post-auth setup.

**Steps:** After sign-up, create settings profile with base currency `EGP` and default method `cash`.

**Done When:** New users have settings without manual setup.

---

## Phase 4: Tests

### T013 - Settings Serialization Tests

Test default/missing fields and full settings round-trip.

### T014 - Currency Formatting Tests

Test amount formatting for at least `EGP` and `USD`.

### T015 - Expense Persistence Test

Verify created expenses include payment method and currency fields.

---

## Worker C Completion Checklist

- [x] T001 - Created `UserSettings` with `userId`, `baseCurrency`, `supportedCurrencies`, `defaultPaymentMethod`, and `updatedAt`.
- [x] T002 - Created `UserSettingsEntity` with Firestore document mapping and safe defaults for missing `baseCurrency`, `supportedCurrencies`, and `defaultPaymentMethod`.
- [x] T003 - Created `SettingsRepository` abstraction for loading, watching, saving, and updating settings.
- [x] T004 - Created `FirebaseSettingsRepository` using `users/{userId}/settings/profile`, including default settings creation.
- [x] T005 - Created `SettingsCubit` and states for load, save, success, and failure flows.
- [x] T006 - Created `SettingsScreen` and added a Settings navigation entry from Home with a scoped `SettingsRepository`.
- [x] T007 - Added base currency selector for `EGP`, `USD`, `EUR`, `SAR`, and `AED`; selection is saved through `SettingsRepository`.
- [x] T008 - Added default payment method selector for Cash, Visa, Wallet, and Bank Transfer; selection is saved as stable enum storage values. Add Expense default usage is intentionally left to T009 because Worker A owns Add Expense integration.
- [x] T009 - Completed after Plan 003 integration. Add Expense now defaults payment method from `SettingsRepository` when available and falls back to Cash.
- [x] T010 - Completed after Plan 003 integration. Add Expense now defaults currency from user settings and falls back to `EGP`.
- [x] T011 - Completed after Plan 003 integration. Home expense rows and total display now use stored currency codes through `formatAmountWithCurrency`; mixed-currency totals do not pretend to be converted.
- [x] T012 - Integrated default settings creation after Firebase sign-up in `FirebaseAuthRepository`.
- [x] T013 - Added settings serialization tests in `test/repository/user_settings_entity_test.dart`.
- [x] T014 - Added currency formatting tests in `test/settings/currency_formatter_test.dart`.
- [x] T015 - Completed after Plan 003 integration. Added repository contract test verifying created expenses retain payment method and currency.

## Worker C Verification Note

No verification commands were run by Worker C by instruction. The coordinator must run `flutter pub get`, `flutter analyze`, and `flutter test` after Workers A, B, and C finish and their changes are reconciled.
