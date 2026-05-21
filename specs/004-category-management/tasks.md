# Tasks: Category Management

## Implementation Intent

Move categories from a one-off add dialog into a reusable user-owned management flow. The goal is to keep old expenses rendering while allowing users to edit or archive categories safely.

---

## Phase 1: Data Layer

### T001 - Create `CategoryRepository`

**Files:** Create `packages/expense_repository/lib/src/category_repo.dart`.

**Steps:** Define `createCategory`, `updateCategory`, `archiveCategory`, `getCategories`, and `watchCategories`.

**Done When:** Category operations are no longer forced into `ExpenseRepository`.

### T002 - Implement `FirebaseCategoryRepository`

**Files:** Create `packages/expense_repository/lib/src/firebase_category_repo.dart`.

**Steps:** Use `users/{userId}/categories`; require non-empty userId; order active categories by creation or name.

**Done When:** Category Firestore operations are user-scoped.

### T003 - Upgrade Category Model

**Files:** Modify `packages/expense_repository/lib/src/models/category.dart` and `entities/category_entity.dart`.

**Steps:** Add `userId`, `createdAt`, `updatedAt`, `isArchived`; default old docs to `isArchived = false`.

**Done When:** Old category docs still parse and new docs carry lifecycle fields.

### T004 - Export Category Repository

**Files:** Modify `packages/expense_repository/lib/expense_repository.dart`.

**Steps:** Export new repository interface and Firebase implementation.

**Done When:** UI can import category repository from the package barrel file.

---

## Phase 2: Bloc

### T005 - Create `CategoriesBloc`

**Files:** Create `lib/screens/categories/blocs/categories_bloc/categories_bloc.dart`, event, state files.

**Steps:** Support load/watch, create, update, archive; emit loading/success/failure states with messages.

**Done When:** UI does not call category repository directly.

### T006 - Implement Create Category Flow

**Files:** Same Bloc files.

**Steps:** Validate model, call repository, refresh or rely on stream update.

**Done When:** Category creation from new form works through Bloc.

### T007 - Implement Update Category Flow

**Steps:** Update name/icon/color and `updatedAt`; preserve `categoryId` and `userId`.

**Done When:** Existing category can be edited.

### T008 - Implement Archive Category Flow

**Steps:** Set `isArchived = true`; do not hard-delete Firestore document.

**Done When:** Used categories can be removed from active use without breaking old expenses.

### T009 - Implement Active Category Listing

**Steps:** Provide state/list for active categories only in Add Expense; category screen may show archived if needed.

**Done When:** Add Expense selector excludes archived categories.

---

## Phase 3: UI

### T010 - Create `CategoriesScreen`

**Files:** Create `lib/screens/categories/views/categories_screen.dart`.

**Steps:** Render active categories with icon, color, name, edit action, archive action, and empty state.

**Done When:** User can see all active categories outside Add Expense.

### T011 - Create Reusable `CategoryFormDialog`

**Files:** Create `lib/screens/categories/widgets/category_form_dialog.dart`.

**Steps:** Support create and edit modes; include name field, icon picker, color picker; validate before submit.

**Done When:** Same form handles both new and existing categories.

### T012 - Replace Old Dialog

**Files:** Modify `lib/screens/add_expense/views/category_creation.dart` or remove usage from `add_expense.dart`.

**Steps:** Route category creation to new reusable form and Bloc.

**Done When:** No duplicate category form logic remains in Add Expense.

### T013 - Hide Archived Categories In Add Expense

**Files:** Modify `lib/screens/add_expense/views/add_expense.dart`.

**Steps:** Filter categories by `!isArchived`; show empty state if none exist.

**Done When:** Archived category cannot be selected for new expenses.

### T014 - Add Navigation Entry

**Files:** Modify `lib/screens/home/views/main_screen.dart` or settings screen if available.

**Steps:** Add access point to Categories screen, preferably from settings icon or a simple management button.

**Done When:** User can reach category management.

---

## Phase 4: Tests

### T015 - Serialization Tests

Verify old category docs parse and new category docs round-trip.

### T016 - Bloc Tests

Test load/create/update/archive success and repository failure.

### T017 - Archive Rendering Test

Verify archived category disappears from Add Expense but old expense still renders from category snapshot.

---

## Completion Checklist

- [x] T001 - Created `CategoryRepository` with create, update, archive, list, and watch operations.
- [x] T002 - Created `FirebaseCategoryRepository` using `users/{userId}/categories`, requiring non-empty `userId`, ordering by category name, and filtering archived categories in repository results so legacy docs without `isArchived` still load as active.
- [x] T003 - Added `userId`, `createdAt`, `updatedAt`, and `isArchived` to category model/entity mapping with legacy parsing defaults.
- [x] T004 - Exported category repository interface and Firebase implementation from the package barrel file.
- [x] T005 - Created `CategoriesBloc` with load/watch, create, update, archive, success, loading, saving, and failure states.
- [x] T006 - Implemented create category flow through repository validation and Bloc dispatch.
- [x] T007 - Implemented update category flow preserving `categoryId`/`userId` through `Category.copyWith` and repository merge writes.
- [x] T008 - Implemented archive flow as `isArchived = true`; no hard-delete path was added.
- [x] T009 - Active category listing is provided through `CategoryRepository.getCategories()` and Add Expense performs an additional defensive `!isArchived` filter.
- [x] T010 - Created `CategoriesScreen` with active category list, empty state, edit action, archive action, and retry state.
- [x] T011 - Created reusable `CategoryFormDialog` for create/edit with name, icon, color, and validation.
- [x] T012 - Replaced old Add Expense category dialog body with wrapper usage of `CategoryFormDialog`; duplicate form logic was removed from Add Expense.
- [x] T013 - Add Expense hides archived categories and shows an empty state when no active categories exist.
- [x] T014 - Added a home app bar Categories entry that opens `CategoriesScreen` through `CategoriesBloc`.
- [x] T015 - Added category serialization tests for legacy docs and lifecycle round-trip behavior. Not run by Worker B per coordination instruction.
- [x] T016 - Added CategoriesBloc tests for load, create, archive, and failure behavior. Not run by Worker B per coordination instruction.
- [x] T017 - Added archive rendering widget tests covering Add Expense active filtering and old expense category snapshot rendering. Not run by Worker B per coordination instruction.

## Deferred Or Skipped

- No tasks were intentionally skipped.
- Verification commands were intentionally not run because the coordinator instructed Worker B not to run `flutter pub get`, `flutter analyze`, `flutter test`, Firebase CLI, or any verification command.
