# Tasks: Verification Baseline Repair

**Input**: `specs/024-verification-baseline-repair/spec.md`, `plan.md`  
**Implementation Intent**: Fix the hanging test baseline and document predictable verification commands.

## Phase 1: Reproduce And Locate The Hang

- [X] T001 Run `flutter test --reporter expanded` from the repository root.

  **Why**: Start from the same symptom future workers see.
  **Steps**:
  1. Run the full Flutter test command with expanded reporter.
  2. Record whether output starts, which suite appears last, and whether the process exits.
  3. If it hangs, rerun with a local timeout so the terminal returns control.
  4. Save the failing/hanging suite name in the plan notes or implementation report.
  **Done when**: The hang is reproducible or the baseline is proven to finish.

- [X] T002 Run targeted test files one by one.

  **Why**: The full suite can hide which file blocks process exit.
  **Steps**:
  1. List test files with `rg --files test`.
  2. Run each high-risk test file directly: home, AI, monetization, app lock, notifications, and widget smoke tests.
  3. Identify the first file that hangs or takes unusually long.
  4. Record files that pass so later workers do not repeat the same search.
  **Done when**: The blocking test file or setup path is known.

- [X] T003 Inspect async lifecycle in the blocking suite.

  **Why**: Hanging Flutter tests usually come from open streams, timers, plugin channels, or unawaited futures.
  **Steps**:
  1. Review `setUp`, `setUpAll`, `tearDown`, and `tearDownAll`.
  2. Check every Cubit/Bloc is closed.
  3. Check every stream subscription, timer, fake repository controller, and animation pump is disposed.
  4. Check `pumpAndSettle` is not waiting forever on repeating animations.
  **Done when**: The specific lifecycle object or wait condition is identified.

## Phase 2: Replace Unsafe Test Dependencies

- [X] T004 [P] Add or update shared fake repository helpers in `test/helpers/`.

  **Why**: Tests should not construct real Firebase repositories or app startup services.
  **Steps**:
  1. Create helper fakes only for interfaces already used by app code.
  2. Provide deterministic in-memory data for expenses, categories, settings, budgets, and monetization state as needed.
  3. Add disposal methods when helpers expose streams.
  4. Keep helpers small and feature-specific.
  **Done when**: Blocking tests can use fakes instead of real Firebase-backed classes.
  **Status note (Plan 040 cleanup)**: Added shared fakes in
  `test/helpers/fake_repositories.dart` for Home/Settings widget coverage.

- [X] T005 [P] Mock platform plugin calls used by the blocking tests.

  **Why**: Notifications, speech, local auth, ads, image picker, and Firebase platform channels cannot run as real services in widget tests.
  **Steps**:
  1. Identify plugin APIs reached by the blocking test.
  2. Replace direct plugin usage with app service abstractions where they already exist.
  3. Add fake service implementations for tests.
  4. If a MethodChannel mock is unavoidable, keep it inside a test helper and reset it in teardown.
  **Done when**: The test no longer depends on a live platform channel.
  **Status note (Plan 040 cleanup)**: Home/Settings tests now inject fake
  repositories, fake app-lock services, fake monetization/ad state, and no-op
  observability instead of reaching Firebase or platform plugins.

- [X] T006 Fix open stream/timer/resource cleanup in the blocking suite.

  **Why**: A test can pass assertions but still keep the Dart process alive.
  **Steps**:
  1. Close every Cubit/Bloc created by the test.
  2. Cancel timers or periodic callbacks.
  3. Close `StreamController` instances in fake repositories.
  4. Avoid long `pumpAndSettle` waits when the widget has ongoing animation; use fixed `pump` durations instead.
  **Done when**: The targeted test file exits naturally.

## Phase 3: Rebuild The Baseline

- [X] T007 Run the previously blocking test file with `--reporter expanded`.

  **Why**: The local fix must be validated before the full suite.
  **Steps**:
  1. Run only the fixed test file.
  2. Confirm the command exits and reports pass/fail.
  3. If it fails, fix the failure rather than hiding the test.
  4. Record the final result.
  **Done when**: The targeted file finishes predictably.

- [X] T008 Run the full Flutter verification set.

  **Why**: A fix in one suite can expose another hanging suite.
  **Steps**:
  1. Run `flutter analyze`.
  2. Run `flutter test --reporter expanded`.
  3. If another suite hangs, repeat Phases 1 and 2 for that suite.
  4. Do not mark the plan complete until the full command exits.
  **Done when**: Analyze passes and tests finish with a clear result.

## Phase 4: Documentation And Governance

- [X] T009 Update `.specify/memory/constitution.md` known verification baseline.

  **Why**: The constitution is the source future workers read before implementation.
  **Steps**:
  1. Add the exact commands run.
  2. Add the final pass/fail counts if available.
  3. Mention any remaining unrelated failures clearly.
  4. Do not claim Android or Worker verification unless those commands were run.
  **Done when**: The constitution reflects the current truth.

- [X] T010 Update `specs/README.md` if verification command expectations change.

  **Why**: The index tells workers how to execute future folders.
  **Steps**:
  1. Add `024-verification-baseline-repair` to the execution order.
  2. Mention that later plans depend on a non-hanging Flutter test baseline.
  3. Keep the wording short and actionable.
  **Done when**: The roadmap points to this repair plan.

- [X] T011 Add a verification summary to the implementation report.

  **Why**: The user needs to know exactly what was fixed and what remains.
  **Steps**:
  1. List the original hanging command.
  2. List the root cause.
  3. List changed files.
  4. List final verification commands and results.
  **Done when**: Another worker can understand the baseline without reading terminal history.
