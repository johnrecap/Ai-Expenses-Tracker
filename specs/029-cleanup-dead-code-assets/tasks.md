# Tasks: Cleanup Dead Code And Assets

**Input**: `specs/029-cleanup-dead-code-assets/spec.md`, `plan.md`  
**Implementation Intent**: Remove proven-unused Flutter artifacts and document retained legacy backend code.

## Phase 1: Reference Audit

- [X] T001 Search references for old category PNG assets.

  **Why**: Assets can only be deleted safely when no runtime path depends on them.
  **Steps**:
  1. Search the full repo for each asset basename: `food.png`, `shopping.png`, `travel.png`, `entertainment.png`, `home.png`, `pet.png`, `tech.png`.
  2. Search for old path-building patterns like `assets/${category.icon}.png`.
  3. Confirm category UI uses `CategoryIconRegistry` and `CategoryIconView`.
  4. Record results before deletion.
  **Done when**: Every old PNG asset is proven unused or marked retained with reason.

- [X] T002 Search references for `lib/data/data.dart` and `transactionsData`.

  **Why**: Demo data must not drive live app screens.
  **Steps**:
  1. Search for `transactionsData`.
  2. Search for imports of `lib/data/data.dart` or `package:.../data/data.dart`.
  3. Confirm Home/Expenses/Reports read repositories or calculated models.
  4. Record whether the file is safe to remove.
  **Done when**: Demo data usage status is clear.

- [X] T003 Search references for `lib/screens/stats/chart.dart` and `MyChart`.

  **Why**: Old chart wrappers can confuse report implementation.
  **Steps**:
  1. Search for `MyChart`.
  2. Search imports of `chart.dart`.
  3. Confirm current Stats/Reports widgets use live report components.
  4. Record safe removal or retention reason.
  **Done when**: Old chart wrapper status is known.

- [X] T004 Audit `redacted` dependency.

  **Why**: Unused dependencies increase build and maintenance risk.
  **Steps**:
  1. Search for `redacted` imports/usages in the full repo.
  2. Check whether it is referenced only in comments/specs.
  3. Decide remove or retain for a documented future plan.
  4. If removing, note lockfile update is required.
  **Done when**: Dependency decision is documented.

## Phase 2: Safe Removal

- [X] T005 Remove proven-unused old category PNG assets from `assets/`.

  **Why**: The modern icon registry made these assets obsolete.
  **Steps**:
  1. Delete only assets proven unused in T001.
  2. Update `pubspec.yaml` asset declarations if they list individual removed files.
  3. Do not remove `assets/logo.png`.
  4. Confirm category UI still references icon registry.
  **Done when**: Old PNG files are gone and app asset config is valid.

- [X] T006 Remove `lib/data/data.dart` if proven unused.

  **Why**: Demo transaction data conflicts with live repository-driven screens.
  **Steps**:
  1. Delete the file only after T002 confirms no imports.
  2. If any tests import it, replace with test fixtures under `test/helpers`.
  3. Do not create new demo data in production `lib`.
  **Done when**: Demo data no longer exists in production code.

- [X] T007 Remove `lib/screens/stats/chart.dart` if proven unused.

  **Why**: Stats should use the current report implementation.
  **Steps**:
  1. Delete the file after T003 confirms no imports.
  2. If any stale import exists, update it to the current report widget.
  3. Run analyzer to catch missed imports.
  **Done when**: Old chart wrapper is removed or explicitly retained.

- [X] T008 Remove unused `redacted` dependency if safe.

  **Why**: Keep dependency list honest.
  **Steps**:
  1. Remove `redacted` from `pubspec.yaml` if no usages remain.
  2. Run `flutter pub get`.
  3. Review lockfile changes.
  4. Restore only if analysis or build proves it is still required.
  **Done when**: Dependency list matches actual imports.

## Phase 3: Legacy Backend Documentation

- [X] T009 Document `functions/` as optional legacy/future backend code.

  **Why**: Current free AI path is Cloudflare Worker, not Firebase Functions.
  **Steps**:
  1. Add a short note to `specs/README.md` or a backend README.
  2. State that `workers/ai-gateway` is the current free AI gateway.
  3. State that `functions/` should be touched only by a plan targeting Firebase Functions.
  4. Do not delete `functions/` unless the user explicitly approves archival/removal.
  **Done when**: Backend folder roles are unambiguous.

## Phase 4: Verification

- [X] T010 Run asset and import verification.

  **Why**: Removal mistakes usually appear as asset or import errors.
  **Steps**:
  1. Run `flutter pub get` if `pubspec.yaml` changed.
  2. Run `flutter analyze`.
  3. Run category, stats, and smoke tests if available.
  4. Launch or build enough to verify assets load.
  **Done when**: Analyzer and relevant tests do not reference removed artifacts.

- [X] T011 Update implementation report with deleted and retained items.

  **Why**: Cleanup decisions need traceability.
  **Steps**:
  1. List every deleted file.
  2. List every retained candidate and why.
  3. List commands run.
  4. Mention any cleanup deferred to future plans.
  **Done when**: Future workers understand what changed and why.
