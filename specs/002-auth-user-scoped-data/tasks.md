# Tasks: Authentication And User-Scoped Data

## Implementation Intent

Add Firebase Authentication and move all user data access from global Firestore collections to user-owned subcollections. This plan must be completed before budgets, reports, AI commands, recurring expenses, and export because all of them depend on user ownership.

---

## Phase 1: Authentication Repository

### T001 - Create `AppUser` Model

**Files:** Create `packages/expense_repository/lib/src/models/app_user.dart`; update `packages/expense_repository/lib/src/models/models.dart`.

**Steps:**
1. Define `AppUser` with `userId`, `email`, `displayName`, `photoUrl`, and `createdAt`.
2. Add `AppUser.empty` for unauthenticated/default states.
3. Add a factory that maps from Firebase Auth `User`.
4. Export it from `models.dart`.

**Verify:** Analyzer succeeds and the model can be imported from `expense_repository.dart`.

**Done When:** Auth state can carry a typed app user without depending on Firebase classes in UI code.

### T002 - Create `AuthRepository` Contract

**Files:** Create `packages/expense_repository/lib/src/auth/auth_repository.dart`.

**Steps:**
1. Define `Stream<AppUser?> get user`.
2. Define `AppUser? get currentUser`.
3. Define `Future<AppUser> signIn({required String email, required String password})`.
4. Define `Future<AppUser> signUp({required String email, required String password, String? displayName})`.
5. Define `Future<void> signOut()`.
6. Define `Future<void> resetPassword(String email)`.

**Verify:** Repository package exports compile.

**Done When:** UI/auth Bloc can depend on the interface, not FirebaseAuth directly.

### T003 - Implement `FirebaseAuthRepository`

**Files:** Create `packages/expense_repository/lib/src/auth/firebase_auth_repository.dart`.

**Steps:**
1. Inject or default to `FirebaseAuth.instance`.
2. Map `authStateChanges()` to `AppUser?`.
3. Implement email/password sign in.
4. Implement account creation and update display name when supplied.
5. Implement reset password and sign out.
6. Convert Firebase exceptions to rethrown exceptions for Bloc-level handling in this version.

**Verify:** Add a fake or mock-based unit test if test dependencies exist; otherwise run analyzer.

**Done When:** Auth operations are centralized in the repository package.

### T004 - Export Auth APIs

**Files:** Modify `packages/expense_repository/lib/expense_repository.dart`.

**Steps:**
1. Export `auth_repository.dart`.
2. Export `firebase_auth_repository.dart`.
3. Export `app_user.dart` through existing model barrel file.

**Verify:** Root app can import `AuthRepository` from `package:expense_repository/expense_repository.dart`.

**Done When:** No screen imports Firebase Auth directly.

---

## Phase 2: Auth Bloc And Screens

### T005 - Create `AuthBloc`

**Files:** Create `lib/screens/auth/blocs/auth_bloc/auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`.

**Steps:**
1. Add events: `AuthUserChanged`, `AuthSignInRequested`, `AuthSignUpRequested`, `AuthSignOutRequested`, `AuthPasswordResetRequested`.
2. Add states: initial, loading, authenticated, unauthenticated, failure.
3. Subscribe to `AuthRepository.user`.
4. Emit authenticated when stream returns a user and unauthenticated when null.
5. Surface failure message for UI.

**Verify:** Bloc test or manual state logging through `SimpleBlocObserver`.

**Done When:** Auth routing can rely on Bloc state.

### T006 - Build Login Screen

**Files:** Create `lib/screens/auth/views/login_screen.dart`.

**Steps:**
1. Add email and password controllers.
2. Validate email is not empty and password is not empty.
3. Dispatch `AuthSignInRequested`.
4. Show loading while sign-in is pending.
5. Show failure message on auth failure.
6. Add navigation link to register screen.
7. Add reset password action.

**Verify:** Manual login with valid/invalid credentials.

**Done When:** Signed-out user can attempt login without crashes.

### T007 - Build Register Screen

**Files:** Create `lib/screens/auth/views/register_screen.dart`.

**Steps:**
1. Add display name, email, password, and confirm password fields.
2. Validate email, password length, and password confirmation.
3. Dispatch `AuthSignUpRequested`.
4. Show loading and error states.
5. Return to auth gate after success through Bloc state, not manual forced home navigation.

**Verify:** Manual registration path.

**Done When:** A new Firebase Auth account can be created.

### T008 - Build Reset Password Flow

**Files:** Add widget or dialog in `login_screen.dart` or create `reset_password_view.dart`.

**Steps:**
1. Ask for email.
2. Validate non-empty email.
3. Dispatch reset password event.
4. Show success message after request.
5. Do not reveal whether the email exists beyond Firebase's safe response.

**Verify:** Manual reset password request.

**Done When:** User can initiate password reset from login.

### T009 - Create `AuthGate`

**Files:** Create `lib/screens/auth/views/auth_gate.dart`; modify `lib/app_view.dart`.

**Steps:**
1. Wrap app body with `BlocBuilder<AuthBloc, AuthState>`.
2. Show splash/loading for initial/loading.
3. Show login for unauthenticated.
4. Show home for authenticated.
5. Ensure Home receives user-scoped repositories.

**Verify:** Hot restart when signed in and signed out.

**Done When:** Auth state controls first app screen.

### T010 - Remove Unconditional Splash Navigation

**Files:** Modify `lib/screens/splash_screen.dart` or remove it from app entry if replaced by AuthGate.

**Steps:**
1. Stop using a `Timer` that always pushes Home.
2. Keep splash only as a visual loading state if needed.
3. Ensure no navigation happens after widget disposal.

**Verify:** Signed-out app no longer reaches Home after 3 seconds.

**Done When:** AuthGate is the only authority for signed-in/signed-out routing.

---

## Phase 3: User-Scoped Firestore

### T011 - Change Expense Collection Path

**Files:** Modify `packages/expense_repository/lib/src/firebase_expense_repo.dart`.

**Steps:**
1. Accept `userId` in `FirebaseExpenseRepo` constructor.
2. Replace `FirebaseFirestore.instance.collection('expenses')` with `users/{userId}/expenses`.
3. Ensure `createExpense`, `getExpenses`, and later methods all use this collection reference.
4. Add assertion or guard against empty userId.

**Verify:** Add debug/manual check that writes go under `users/{uid}/expenses`.

**Done When:** No expense read/write uses global `expenses`.

### T012 - Change Category Collection Path

**Files:** Modify `packages/expense_repository/lib/src/firebase_expense_repo.dart` initially, or category repo if Plan 03 is already complete.

**Steps:**
1. Accept same userId.
2. Replace `categories` global collection with `users/{userId}/categories`.
3. Update all category create/list calls.

**Verify:** Manual category creation under user path.

**Done When:** No category read/write uses global `categories`.

### T013 - Wire User-Scoped Repositories In UI

**Files:** Modify `lib/app_view.dart`, `lib/screens/home/views/home_screen.dart`, `lib/screens/splash_screen.dart` if still used.

**Steps:**
1. Provide `AuthRepository` at app level.
2. When authenticated state has user, create repositories with `user.userId`.
3. Pass same scoped repository to Home, Add Expense, and category blocs.
4. Avoid constructing `FirebaseExpenseRepo()` without a user id.

**Verify:** Search code for `FirebaseExpenseRepo()` with no arguments.

**Done When:** Repository creation is user-aware across app.

### T014 - Add Firestore Security Rules

**Files:** Create or modify `firestore.rules` if project tracks rules.

**Steps:**
1. Add match for `/users/{userId}/{document=**}`.
2. Allow read/write only when `request.auth != null && request.auth.uid == userId`.
3. Deny global `expenses` and `categories` for authenticated production access.
4. Document deployment command if Firebase CLI is used.

**Verify:** Rules syntax check if Firebase CLI is available; otherwise document manual deployment.

**Done When:** Rule file expresses user ownership.

### T015 - Decide Legacy Data Migration

**Files:** Update `docs/implementation_plans/expense_tracker_feature_plans.md` or create `docs/firebase_migration_notes.md`.

**Steps:**
1. Confirm whether global `expenses`/`categories` contain production data.
2. If no, document "no migration".
3. If yes, write migration approach: map old docs to a chosen user or ask user to re-import.
4. Do not silently copy global data to every user.

**Verify:** Migration decision is documented.

**Done When:** Future workers know how to handle old global collections.

---

## Phase 4: Tests And Verification

### T016 - Auth Bloc Tests

**Files:** Add tests under `test/auth/` or matching project test structure.

**Steps:**
1. Test unauthenticated initial stream.
2. Test authenticated stream emits user.
3. Test sign-in success.
4. Test sign-in failure.
5. Test sign-out.

**Done When:** Auth state changes are covered.

### T017 - Repository Path Tests

**Files:** Add repository tests if fake Firestore dependencies are available.

**Steps:**
1. Create repository with `userId = user-a`.
2. Create expense/category.
3. Verify path includes `users/user-a`.
4. Verify no call targets global collection.

**Done When:** User path behavior is enforced by tests or documented manual verification.

### T018 - Run Verification

**Commands:**
- `flutter pub get`
- `flutter analyze`
- `flutter test`

**Done When:** Results are reported with exact failures if any.

---

## Completion Checklist

- [x] T001 - Created `AppUser` model and exported it from the repository package.
- [x] T002 - Created `AuthRepository` contract.
- [x] T003 - Implemented `FirebaseAuthRepository`.
- [x] T004 - Exported Auth APIs from `expense_repository.dart`.
- [x] T005 - Created `AuthBloc` with auth state subscription and auth actions.
- [x] T006 - Built login screen with validation, loading state, and failure handling.
- [x] T007 - Built register screen with validation, loading state, and failure handling.
- [x] T008 - Added reset password dialog flow.
- [x] T009 - Created `AuthGate` and wired it into app entry.
- [x] T010 - Removed unconditional timer-based splash navigation.
- [x] T011 - Changed expense collection path to `users/{userId}/expenses`.
- [x] T012 - Changed category collection path to `users/{userId}/categories`.
- [x] T013 - Wired user-scoped repository creation from authenticated user state.
- [x] T014 - Added Firestore security rules and `firebase.json` rules mapping.
- [x] T015 - Documented legacy global data migration decision.
- [x] T016 - Added AuthBloc tests for authenticated and sign-out state flow.
- [x] T017 - Added repository path tests for user-scoped Firestore paths.
- [x] T018 - Ran verification commands and recorded results in the final report.
