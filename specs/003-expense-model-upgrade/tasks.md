# Tasks: Expense Model Upgrade

## Implementation Intent

Create the stable data model needed by payment methods, currency, budgets, filters, reports, recurring expenses, export, and AI. This is a schema-change plan; every task must preserve backward compatibility with the current simple Firestore documents.

---

## Phase 1: Domain Types

### T001 - Add `PaymentMethod`

**Files:** Create `packages/expense_repository/lib/src/models/payment_method.dart`; update `models.dart`.

**Steps:** Define enum values `cash`, `visa`, `wallet`, `bankTransfer`; add helpers for Firestore string conversion; add fallback to `cash` for unknown values.

**Test:** Unit test string mapping if test structure exists.

**Done When:** Expense can store payment method as stable lowercase string.

### T002 - Add `ExpenseSource`

**Files:** Create `packages/expense_repository/lib/src/models/expense_source.dart`; update `models.dart`.

**Steps:** Define enum values `manual`, `ai`, `recurring`, `receipt`; add string conversion helpers; default old docs to `manual`.

**Done When:** Later AI/recurring/receipt features can mark origin.

### T003 - Add `ExpenseFilter`

**Files:** Create `packages/expense_repository/lib/src/models/expense_filter.dart`.

**Steps:** Include `query`, `startDate`, `endDate`, `categoryIds`, `minAmount`, `maxAmount`, `paymentMethods`, and `currency`; add `empty` and `copyWith`.

**Done When:** Repository and UI can pass one object for filtering.

---

## Phase 2: Expense Schema

### T004 - Extend `Expense`

**Files:** Modify `packages/expense_repository/lib/src/models/expense.dart`.

**Steps:**
1. Add `userId`, `categoryId`, `categoryName`, `categoryIcon`, `categoryColor`.
2. Add `description`, `paymentMethod`, `currency`, `createdAt`, `updatedAt`, `source`.
3. Add nullable `recurringExpenseId` and `aiActionId`.
4. Keep `category` temporarily if needed for compatibility, but document that category snapshot fields are preferred.
5. Update `Expense.empty` with safe defaults.

**Done When:** Add Expense can construct a complete upgraded expense.

### T005 - Extend Serialization

**Files:** Modify `packages/expense_repository/lib/src/entities/expense_entity.dart`.

**Steps:**
1. Write all new fields in `toDocument`.
2. Store enum values as strings.
3. Store `DateTime` fields in Firestore-compatible format.
4. Include category snapshot fields.
5. Do not remove old `category` handling until old docs are supported.

**Done When:** New documents contain full schema.

### T006 - Add Backward-Compatible Deserialization

**Files:** Modify `packages/expense_repository/lib/src/entities/expense_entity.dart`.

**Steps:**
1. If `description` is missing, default to empty string.
2. If `paymentMethod` is missing, default to `cash`.
3. If `currency` is missing, default to `EGP` or current base currency if available.
4. If snapshot fields are missing, derive from old embedded `category`.
5. If timestamps are missing, use expense date as fallback for `createdAt`/`updatedAt`.

**Test:** Deserialize a fixture matching the current old document shape.

**Done When:** Old Firestore docs do not crash the app.

---

## Phase 3: Repository Methods

### T007 - Add `updateExpense`

**Files:** Modify `packages/expense_repository/lib/src/expense_repo.dart`; implement in Firebase repo.

**Steps:** Add method signature; write full document or update mapped fields; set `updatedAt` before saving.

**Done When:** Existing expenses can be corrected by later UI/AI flows.

### T008 - Add `deleteExpense`

**Files:** Same repository files.

**Steps:** Add delete by `expenseId`; scope delete to current user collection; do not delete categories.

**Done When:** Delete is available for UI and AI confirmation flow.

### T009 - Add `getExpenseById`

**Files:** Same repository files.

**Steps:** Fetch one document under user path; return null or throw a controlled failure when missing.

**Done When:** AI target preview can load exact expense.

### T010 - Add `watchExpenses`

**Files:** Same repository files.

**Steps:** Return stream ordered by date descending; map snapshot docs through backward-compatible parser.

**Done When:** Home/reports can move from one-time fetch to live updates later.

### T011 - Add `getExpensesByFilter`

**Files:** Same repository files.

**Steps:** Accept `ExpenseFilter`; first implementation can query date range and then local-filter remaining fields; document index needs later.

**Done When:** Search/filter plan has repository support.

---

## Phase 4: UI Integration

### T012 - Add Description Field

**Files:** Modify `lib/screens/add_expense/views/add_expense.dart`.

**Steps:** Add optional text field; trim value; map to `Expense.description`.

**Done When:** New expenses can include description.

### T013 - Add Payment Method Field

**Files:** Same Add Expense file.

**Steps:** Add selector for Cash, Visa, Wallet, Bank Transfer; default to Cash until user settings exist.

**Done When:** Saved expense includes payment method.

### T014 - Add Currency Field

**Files:** Same Add Expense file.

**Steps:** Add simple dropdown with at least `EGP` and `USD`; default to `EGP` until settings plan.

**Done When:** Saved expense includes currency code.

### T015 - Render New Fields

**Files:** Modify `lib/screens/home/views/main_screen.dart`.

**Steps:** Show amount with currency; show description if not empty; keep category icon/color from snapshot or old category fallback.

**Done When:** Existing and new expenses render correctly.

---

## Phase 5: Tests

### T016 - Old Document Serialization Test

Create a test fixture matching current Firestore shape: `expenseId`, embedded `category`, `date`, `amount`. Verify parser defaults all new fields.

### T017 - New Document Serialization Test

Create upgraded expense and verify `toDocument`/`fromDocument` round trip preserves all fields.

### T018 - Bloc/Repository Operation Tests

Test create/update/delete success and failure using fake repository where possible.

---

## Completion Checklist

- [x] T001 - Added `PaymentMethod` enum with Firestore string mapping and `cash` fallback.
- [x] T002 - Added `ExpenseSource` enum with Firestore string mapping and `manual` fallback.
- [x] T003 - Added `ExpenseFilter` with query, date, category, amount, payment, and currency fields.
- [x] T004 - Extended `Expense` with user, category snapshot, description, payment, currency, timestamp, source, recurring, and AI fields.
- [x] T005 - Extended `ExpenseEntity.toDocument()` to write the upgraded schema.
- [x] T006 - Added backward-compatible `ExpenseEntity.fromDocument()` defaults for old documents.
- [x] T007 - Added and implemented `updateExpense`, including `updatedAt` refresh.
- [x] T008 - Added and implemented user-scoped `deleteExpense`.
- [x] T009 - Added and implemented user-scoped `getExpenseById`.
- [x] T010 - Added and implemented `watchExpenses` ordered by date descending.
- [x] T011 - Added and implemented first-pass `getExpensesByFilter`; date range is queried, remaining fields are locally filtered.
- [x] T012 - Added optional description entry in Add Expense.
- [x] T013 - Added payment method selector in Add Expense with `Cash` default.
- [x] T014 - Added currency selector in Add Expense with `EGP` default.
- [x] T015 - Updated Home transaction rendering to show currency, description, and category snapshot fallbacks.
- [x] T016 - Added old document deserialization test fixture.
- [x] T017 - Added upgraded document serialization/deserialization test fixture.
- [x] T018 - Added fake repository operation test for create, update, get, and delete.

## Deferred Or Skipped

- No Plan 003 tasks were intentionally deferred.
- Verification commands were intentionally not run because the coordinator requested that workers do not run `flutter pub get`, `flutter analyze`, `flutter test`, Firebase CLI, or any verification command. The coordinator will run verification after Plans 003, 004, and 005 finish.
