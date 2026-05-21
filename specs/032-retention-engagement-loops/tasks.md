# Tasks: Retention And Engagement Loops

**Input**: `specs/032-retention-engagement-loops/spec.md`, `plan.md`  
**Implementation Intent**: Add practical engagement features that work locally and do not consume AI quota.

## Phase 1: Foundation Calculators

- [X] T001 Create engagement model folder.

  **Why**: Streaks, digest, and health score should not be embedded in widgets.
  **Steps**:
  1. Add `lib/engagement/models` and `lib/engagement/services` or match existing feature style.
  2. Define `TrackingStreak`, `WeeklyDigest`, and `SpendingHealthScore`.
  3. Keep models plain Dart and testable.
  4. Avoid Firebase/plugin imports in calculators.
  **Done when**: Engagement data can be calculated outside UI.

- [X] T002 Implement tracking streak calculator.

  **Why**: Streak is the simplest habit loop.
  **Steps**:
  1. Accept a list of user expenses and current date.
  2. Count consecutive days with at least one expense.
  3. Handle today's no-expense state clearly.
  4. Respect local date boundaries.
  **Done when**: Streak output is deterministic from expense fixtures.

- [X] T003 Implement weekly digest calculator.

  **Why**: Weekly digest gives users a reason to review spending.
  **Steps**:
  1. Use current week and previous week date ranges.
  2. Calculate totals by base currency where valid.
  3. Identify top category.
  4. Calculate difference from previous week.
  5. Return empty state if no data.
  **Done when**: Digest matches report calculator totals.

- [X] T004 Implement spending health score service.

  **Why**: Users need a simple progress signal.
  **Steps**:
  1. Use budget usage ratio, category concentration, and tracking consistency.
  2. Return label/status plus reasons.
  3. Avoid medical/financial professional claims.
  4. Keep score explainable and local.
  **Done when**: Score changes predictably for under/near/over budget fixtures.

## Phase 2: Settings And Notifications

- [X] T005 Add daily check-in settings to user settings model if missing.

  **Why**: User must control reminders.
  **Steps**:
  1. Extend `UserSettings` notification settings or engagement preference.
  2. Include enabled flag and reminder time.
  3. Preserve backward compatibility for existing settings documents.
  4. Update serialization tests.
  **Done when**: Preference persists through `SettingsRepository`.

- [X] T006 Add Settings controls for daily check-in and weekly digest.

  **Why**: Engagement must be opt-in/controllable.
  **Steps**:
  1. Add toggle for daily check-in.
  2. Add time picker for reminder time.
  3. Add toggle for weekly digest notification if implemented.
  4. Show permission state and request path using existing notification service.
  **Done when**: User can configure engagement reminders.

- [X] T007 Schedule daily check-in notification.

  **Why**: Reminder must fire from existing notification infrastructure.
  **Steps**:
  1. Use `NotificationScheduler` or existing service abstraction.
  2. Schedule when enabled and permission granted.
  3. Cancel when disabled.
  4. Do not block settings save if permission is denied; show helpful message.
  **Done when**: Daily check-in schedule follows settings.

## Phase 3: User-Facing Surfaces

- [X] T008 Add compact streak widget to Home.

  **Why**: Streak should be visible where users start.
  **Steps**:
  1. Render current streak count or today's tracking status.
  2. Keep it compact and not a marketing hero.
  3. Handle zero streak kindly.
  4. Use local expense data only.
  **Done when**: Home shows tracking progress without crowding dashboard.

- [X] T009 Add weekly digest screen or panel.

  **Why**: Users need a readable place to review the digest.
  **Steps**:
  1. Add route/panel reachable from Home or Reports.
  2. Show week total, top category, comparison, and one local insight.
  3. Provide empty state.
  4. Avoid AI provider calls.
  **Done when**: Weekly digest can be opened and verified with local fixtures.

- [X] T010 Add spending health score widget.

  **Why**: The score encourages repeated review.
  **Steps**:
  1. Show status/score and short reason list.
  2. Link to Reports or Budget when relevant.
  3. Keep copy factual and non-judgmental.
  4. Hide or simplify when data is insufficient.
  **Done when**: User sees explainable progress from local data.

## Phase 4: Tests

- [X] T011 [P] Add streak calculator tests.

  **Why**: Date boundary bugs are common.
  **Steps**:
  1. Test consecutive days.
  2. Test missing yesterday breaks streak.
  3. Test no expenses.
  4. Test multiple expenses same day count once.
  **Done when**: Streak behavior is stable.

- [X] T012 [P] Add weekly digest tests.

  **Why**: Digest must match reports.
  **Steps**:
  1. Test current week total.
  2. Test previous week comparison.
  3. Test top category.
  4. Test empty state.
  **Done when**: Digest values are reliable.

- [X] T013 [P] Add health score tests.

  **Why**: Score must be explainable and deterministic.
  **Steps**:
  1. Test under budget positive state.
  2. Test near budget warning.
  3. Test over budget risk.
  4. Test high category concentration reason.
  **Done when**: Score reasons match input data.

- [X] T014 [P] Add settings notification tests.

  **Why**: Reminder toggles must persist and schedule correctly.
  **Steps**:
  1. Test enabling saves setting.
  2. Test disabling cancels schedule.
  3. Test permission denied message.
  4. Test time update reschedules.
  **Done when**: Reminder settings are covered.

## Phase 5: Verification

- [ ] T015 Run Flutter verification and manual reminder QA.

  **Why**: Notifications and Home widgets affect user trust.
  **Steps**:
  1. Run `flutter analyze`.
  2. Run engagement/service tests.
  3. Manually enable daily check-in on a device.
  4. Confirm notification scheduling behavior or debug scheduler output.
  **Done when**: Engagement features work without AI calls.

  **Parent review status**: Automated checks passed (`flutter analyze`, engagement/settings tests, full `flutter test` with 214 tests, and release APK build). Plan 040 later passed `flutter analyze` and full Flutter tests with 240 tests. Manual notification QA on device remains open, so this combined task intentionally stays unchecked.
