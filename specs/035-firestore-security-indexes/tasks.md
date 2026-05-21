# Tasks: Firestore Security And Indexes

**Input**: `specs/035-firestore-security-indexes/spec.md`, `plan.md`  
**Implementation Intent**: Make Firebase data access production-safe and query reliability explicit.

## Phase 1: Query And Schema Inventory

- [X] T001 Audit repository Firestore paths and queries in `packages/expense_repository/lib/src/`.

  **Why**: Rules and indexes must match actual repository behavior, not guessed collection names.
  **Steps**:
  1. List every collection path function used by repositories.
  2. List every `where`, `orderBy`, `snapshots`, and `get` query.
  3. Record required fields for each document type from entity `toDocument` and `fromDocument`.
  4. Note backward-compatible optional fields.
  **Done when**: The plan has a complete collection/query matrix for expenses, categories, budgets, settings, recurring, goals, AI logs, aliases, and category budgets.
  **Note**: Inventory recorded in `docs/firebase/firestore-schema.md`.

- [X] T002 Create `docs/firebase/firestore-schema.md`.

  **Why**: Future agents need to understand what rules validate before editing them.
  **Steps**:
  1. Document each user-scoped collection path.
  2. Document required fields and allowed optional fields.
  3. Document ownership rule: path `userId` is authoritative.
  4. Document legacy global collection denial.
  **Done when**: The schema doc can be used to update rules without opening every Dart entity file.

## Phase 2: Rules Hardening

- [X] T003 Add reusable validation helpers to `firestore.rules`.

  **Why**: Repeated inline expressions make rules hard to review and easy to weaken accidentally.
  **Steps**:
  1. Add helper for authenticated user path.
  2. Add helper for allowed keys.
  3. Add helpers for positive money values, currency codes, month ids, booleans, strings, timestamps, and nullable values.
  4. Keep helper names readable for future reviewers.
  **Done when**: Collection rules can call concise helper functions instead of duplicating checks.

- [X] T004 Harden `users/{userId}/expenses/{expenseId}` rules.

  **Why**: Expenses are the core financial records and should reject malformed or cross-owned writes.
  **Steps**:
  1. Allow read only for matching authenticated user.
  2. On create/update, require positive `amount`, valid `date`, valid `currency`, valid payment method/source strings, and safe category snapshot fields.
  3. Reject writes where any explicit `userId` field conflicts with path `userId`.
  4. Allow optional recurring/AI references only as strings or null.
  5. Preserve old document reads for authenticated owner.
  **Done when**: Valid app-created expenses write successfully and malformed/cross-user writes are denied.

- [X] T005 Harden category and category alias rules in `firestore.rules`.

  **Why**: AI category matching and UI category management depend on safe user-owned category data.
  **Steps**:
  1. Validate category name, color, icon key, archive flag, timestamps.
  2. Validate alias text, category id, last-used fields, and user ownership.
  3. Deny hard deletes unless the repository explicitly requires them; prefer archive/update behavior.
  **Done when**: Category creation/edit/archive and AI learned aliases remain allowed only for the owner.

- [X] T006 Harden budget, category budget, recurring, saving goal, settings, and AI action rules.

  **Why**: The current subtree rule lets any shape through under these paths.
  **Steps**:
  1. Validate monthly budget id/month/currency/limit/threshold fields.
  2. Validate category budget fields including category id, month, currency, limit, archive flag.
  3. Validate recurring rule amount, frequency, nextRunDate, archive/active flags.
  4. Validate saving goal target/current values and archive fields.
  5. Validate settings profile fields and notification settings object shape.
  6. Validate AI action log status, intent, timestamps, and provider metadata without secrets.
  **Done when**: All user-scoped feature collections have explicit rules.

## Phase 3: Indexes

- [X] T007 Add `firestore.indexes.json` for current repository query patterns.

  **Why**: Production Firestore can fail at runtime if composite indexes are missing.
  **Steps**:
  1. Add indexes for recurring due query: `isActive`, `isArchived`, `nextRunDate`.
  2. Add indexes for date-filtered expenses if emulator or Firestore requires them.
  3. Add indexes for sorted saving goals, AI actions, category aliases, and recurring list queries where needed.
  4. Keep indexes scoped to collection groups only if the repository path requires that strategy; otherwise use collection indexes.
  **Done when**: Every current repository query has a declared index or a note proving no composite index is needed.
  **Note**: The recurring due query is declared in `firestore.indexes.json`; single-field query proof is recorded in `docs/firebase/firestore-schema.md`.

- [X] T008 Update `firebase.json` to include Firestore indexes if missing.

  **Why**: `firebase deploy --only firestore` must deploy both rules and indexes.
  **Steps**:
  1. Confirm `firestore.rules` remains mapped.
  2. Add `indexes: firestore.indexes.json` if absent.
  3. Keep functions and other Firebase settings intact.
  **Done when**: Firebase CLI can deploy rules and indexes from the repo.

## Phase 4: Emulator Verification

- [X] T009 Add Firestore rules test setup.

  **Why**: Rules must be executable, not just manually inspected.
  **Steps**:
  1. Choose the existing project-appropriate test location.
  2. Add Firebase rules unit test dependencies only if needed.
  3. Provide test helpers for authenticated user A, authenticated user B, and unauthenticated context.
  4. Keep test data minimal and deterministic.
  **Done when**: A local command can run rules tests.
  **Parent completion (2026-05-18)**: Added `@firebase/rules-unit-testing`, `functions/test/firestoreRules.rules.ts`, and `npm run test:rules`. The emulator is pinned to `127.0.0.1:18080` in `firebase.json`.

- [X] T010 Add allow/deny tests for expenses and categories.

  **Why**: These are the most common user operations and highest data risk.
  **Steps**:
  1. Test owner can create valid expense/category.
  2. Test unauthenticated user is denied.
  3. Test cross-user read/write is denied.
  4. Test invalid amount, invalid currency, and invalid category fields are denied.
  **Done when**: Expense/category rule behavior is covered by emulator tests.
  **Parent completion (2026-05-18)**: Rules tests now cover owner valid expense/category writes, unauthenticated denial, cross-user denial, malformed amount/currency denial, and legacy global collection denial.

- [X] T011 Add allow/deny tests for budgets, recurring, goals, settings, AI logs, and aliases.

  **Why**: Newer feature collections need the same user isolation guarantee.
  **Steps**:
  1. Add one valid create/read case per collection.
  2. Add one cross-user deny case per collection.
  3. Add one malformed write deny case per collection.
  4. Include AI action metadata test proving secrets/raw auth headers are not accepted.
  **Done when**: Every current production collection has at least owner/cross-user/malformed coverage.
  **Parent completion (2026-05-18)**: Rules tests now cover valid owner writes for budgets, category budgets, recurring expenses, saving goals, settings, AI actions, and category aliases, plus malformed budget/settings/AI denial.

- [X] T012 Document rules and index deployment in `docs/firebase/firestore-deployment.md`.

  **Why**: The app owner needs safe deploy steps after editing rules.
  **Steps**:
  1. Add emulator test command.
  2. Add deploy command for rules and indexes.
  3. Add rollback notes.
  4. Add warning to deploy only after Flutter tests pass.
  **Done when**: Rules/index deploy can be repeated without guessing commands.

## Phase 5: Verification

- [X] T013 Run Firestore rules emulator tests.

  **Why**: This is the primary verification for security behavior.
  **Steps**:
  1. Run the documented rules test command.
  2. Fix failures caused by rules or tests.
  3. Record any environment setup issue separately.
  **Done when**: All rules tests pass.
  **Parent verification (2026-05-18)**: `npm --prefix functions run test:rules` passed after adding emulator port config.

- [X] T014 Run `flutter test --reporter expanded --concurrency=1 --timeout 45s`.

  **Why**: Rules/schema changes should match repository entity behavior.
  **Steps**:
  1. Run full Flutter tests.
  2. Pay attention to repository path/entity tests.
  3. Fix mismatches between rules schema and app writes.
  **Done when**: Existing app behavior remains green.
  **Parent verification (2026-05-18)**: Full Flutter test suite passed: 217 tests.

- [ ] T015 Run a manual Firebase device smoke test.

  **Why**: Emulator tests do not prove deployed project setup, auth, and indexes are live.
  **Steps**:
  1. Deploy rules/indexes to a test Firebase project.
  2. Sign in as a real test user on device.
  3. Create expense, category, budget, recurring rule, saving goal, and AI preview log.
  4. Confirm no permission-denied or missing-index error appears.
  **Done when**: Core flows write/read successfully against Firebase.
  **Parent verification note**: Not run by worker instruction.

## Dependencies & Execution Order

- T001 and T002 must be done before rules edits.
- T003 blocks T004 to T006.
- T007 and T008 can run in parallel with T004 to T006 after T001.
- T009 blocks T010 and T011.
- Verification starts after rules, indexes, and tests are in place.

## Suggested MVP

Complete T001 to T010 and T013 first. That protects the most sensitive data and gives immediate regression coverage.
