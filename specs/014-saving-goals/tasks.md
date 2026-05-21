# Tasks: Saving Goals

## Implementation Intent

Add user-owned saving goals with target, progress, and optional deadline. Goals are independent from expenses in the first version; automatic contribution rules are out of scope.

---

## Phase 1: Data Layer

### [x] T001 - Create `SavingGoal`

**Files:** Create `packages/expense_repository/lib/src/models/saving_goal.dart`.

**Steps:** Include `goalId`, `userId`, `name`, `targetAmount`, `currentAmount`, `currency`, `deadline`, `isArchived`, `createdAt`, `updatedAt`.

**Done When:** A saving target can be represented fully.

### [x] T002 - Create `SavingGoalEntity`

**Files:** Create `packages/expense_repository/lib/src/entities/saving_goal_entity.dart`.

**Steps:** Serialize all fields; default `currentAmount` to 0 and `isArchived` to false.

**Done When:** Firestore mapping works for old/missing fields.

### [x] T003 - Create Repository Interface

**Files:** Create `packages/expense_repository/lib/src/saving_goal_repo.dart`.

**Steps:** Define create, update, archive, watch active goals.

**Done When:** UI depends on abstraction.

### [x] T004 - Implement Firebase Repository

**Files:** Create `packages/expense_repository/lib/src/firebase_saving_goal_repo.dart`.

**Steps:** Store under `users/{userId}/saving_goals`; update timestamps.

**Done When:** Goals are user-scoped.

---

## Phase 2: Logic And State

### [x] T005 - Progress Calculation

**Files:** Create helper in saving goal model or service.

**Steps:** Calculate percent = current/target clamped 0-100+; remaining = target-current.

**Done When:** UI can show progress.

### [x] T006 - Create Saving Goal Bloc

**Files:** Create `lib/screens/saving_goals/blocs/saving_goal_bloc/`.

**Steps:** Load/watch, create, update, archive, contribute.

**Done When:** Screen has state manager.

### [x] T007 - Events For Create/Update/Archive

**Steps:** Validate name and positive target; archive instead of delete.

**Done When:** All core actions exist.

### [x] T008 - Contribution Action

**Steps:** Add manual contribution amount; reject zero/negative; update currentAmount and updatedAt.

**Done When:** User can increase progress.

---

## Phase 3: UI

### [x] T009 - Saving Goals Screen

**Files:** Create `lib/screens/saving_goals/views/saving_goals_screen.dart`.

**Steps:** List active goals, empty state, add button.

**Done When:** User can view goals.

### [x] T010 - Saving Goal Form

**Files:** Create `lib/screens/saving_goals/widgets/saving_goal_form.dart`.

**Steps:** Fields: name, target amount, currency, optional deadline.

**Done When:** User can create/edit a goal.

### [x] T011 - Saving Goal Card

**Files:** Create `lib/screens/saving_goals/widgets/saving_goal_card.dart`.

**Steps:** Show name, progress bar, current/target, remaining, deadline.

**Done When:** Progress is visible.

### [x] T012 - Active/Archived Behavior

**Steps:** Hide archived goals from active list; optionally add archived view later.

**Done When:** Archive removes goal from primary screen.

---

## Phase 4: Tests

### T013 - Progress Tests

Test zero current, half, complete, over target, zero target guard.

### T014 - Bloc Tests

Create/update/archive/contribute success and failure.

### T015 - Manual QA

Create goal, contribute, archive, confirm UI changes.
