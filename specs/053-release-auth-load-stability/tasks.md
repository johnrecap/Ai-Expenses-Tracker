# Tasks: Release Auth Load Stability

**Input**: Design documents from `specs/053-release-auth-load-stability/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

- [X] T001 Inspect user-provided deployed Firestore rules and compare with `firestore.rules` and `firestore.indexes.json`.
- [X] T002 [P] Inspect Home expense loading flow in `lib/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart` and `packages/expense_repository/lib/src/firebase_expense_repo.dart`.
- [X] T003 [P] Inspect onboarding reminder finish flow in `lib/screens/onboarding/blocs/onboarding_cubit.dart` and `lib/services/notifications/notification_scheduler.dart`.

---

## Phase 2: Foundational

- [X] T004 Create Spec Kit artifacts in `specs/053-release-auth-load-stability/`.
- [X] T005 Update `AGENTS.md` and `.specify/feature.json` to point at `specs/053-release-auth-load-stability/plan.md`.

---

## Phase 3: User Story 1 - Authenticated Home Loads Without Deployed Composite Index (Priority: P1)

**Goal**: Home does not fail solely because the new composite expense index is not deployed.

**Independent Test**: A repository/Bloc test simulates primary watch failure and verifies a successful fallback page.

- [X] T006 [US1] Add Firestore missing-index fallback helpers in `packages/expense_repository/lib/src/firebase_expense_repo.dart`.
- [X] T007 [US1] Use fallback for `watchRecentExpensePage()` in `packages/expense_repository/lib/src/firebase_expense_repo.dart`.
- [X] T008 [US1] Use fallback for `getExpensePage()` in `packages/expense_repository/lib/src/firebase_expense_repo.dart`.
- [X] T009 [P] [US1] Add or update targeted tests for fallback paging behavior in `test/home/get_expenses_bloc_test.dart`.

---

## Phase 4: User Story 2 - Onboarding Reminder Setup Cannot Spin Forever (Priority: P2)

**Goal**: Reminder opt-in cannot keep onboarding saving forever.

**Independent Test**: A fake notification scheduler that never completes still results in completed onboarding with disabled-reminder warning.

- [X] T010 [US2] Add bounded optional reminder sync timeout in `lib/screens/onboarding/blocs/onboarding_cubit.dart`.
- [X] T011 [P] [US2] Add onboarding timeout regression test in `test/onboarding/onboarding_cubit_test.dart`.

---

## Phase 5: User Story 3 - Production Setup Gap Remains Visible (Priority: P3)

**Goal**: Firebase deploy work remains tracked as production setup, not hidden by the runtime fallback.

- [X] T012 [US3] Confirm `docs/implementation_plans/deferred-and-advanced-work.md` still lists Firestore rules/index deployment and real-user Firebase smoke testing.

---

## Phase 6: Verification

- [X] T013 Run targeted onboarding tests.
- [X] T014 Run targeted home/repository tests.
- [X] T015 Run `flutter analyze --no-pub`.
- [X] T016 Build Android release APK for user testing.

## Dependencies & Execution Order

- Setup and foundational tasks precede code edits.
- US1 and US2 are independent after foundational tasks.
- Release build waits until targeted tests and analyze complete.

## Notes

- Do not deploy Firebase from this plan.
- Do not alter authentication, Google Sign-In, or production rules from app code.
