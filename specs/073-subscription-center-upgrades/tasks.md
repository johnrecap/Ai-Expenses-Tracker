# Tasks: Subscription Center Upgrades

**Input**: `specs/073-subscription-center-upgrades/spec.md`, `plan.md`

## Phase 1: Summary Model

- [X] T001 Extend subscription summary models with upcoming renewals, caveats, and monthly impact metadata.
  - **Why**: The UI needs more than a flat list.
  - **Benefit**: Users can see what is coming and what totals mean.
  - **Expected**: Model supports due dates, currency caveats, and active status.

- [X] T002 Add subscription fixture tests for daily, weekly, monthly, paused, archived, and day-31 rules.
  - **Why**: Recurrence math has edge cases.
  - **Benefit**: Prevents wrong renewal dates.
  - **Expected**: Each recurrence fixture has expected next due and monthly estimate.

## Phase 2: Currency And Impact

- [X] T003 [US1] Update `SubscriptionSummaryService` to use shared currency policy or explicit same-currency caveats.
  - **Why**: Subscription totals must not contradict Home/Reports.
  - **Benefit**: Restores trust in recurring totals.
  - **Expected**: Mixed currencies are converted or clearly caveated.

- [ ] T004 [US1] Add tests for subscription monthly impact with valid and missing rates.
  - **Why**: Currency bugs are high trust risk.
  - **Benefit**: Confirms caveats appear correctly.
  - **Expected**: Valid rates included; missing rates excluded and identified.

## Phase 3: Upcoming Renewals And Alerts

- [X] T005 [US1] Add upcoming renewals section to `SubscriptionCenterScreen`.
  - **Why**: Users need to know what renews soon.
  - **Benefit**: Makes recurring expenses actionable.
  - **Expected**: Next 7 days appear with amount, date, and rule.

- [ ] T006 [US1] Integrate optional renewal notification scheduling through notification service.
  - **Why**: Renewal reminders are useful but must respect settings.
  - **Benefit**: Users can avoid surprise charges.
  - **Expected**: Scheduling happens only when enabled and permissions allow it.

## Phase 4: Price Change Candidates

- [X] T007 [US2] Add conservative price-change detection service.
  - **Why**: Increased subscriptions are high-value insights.
  - **Benefit**: Helps users catch rising recurring costs.
  - **Expected**: Service returns candidates with old/new amount and confidence.

- [X] T008 [US2] Render price-change candidates with cautious copy.
  - **Why**: The app should not overclaim uncertain inference.
  - **Benefit**: Builds trust.
  - **Expected**: UI says "possible increase" unless exact history proves it.

## Phase 5: Localization And Verification

- [X] T009 Add ARB keys for monthly impact, upcoming renewals, price change, caveats, and reminder labels.
  - **Why**: New UI copy must be localized.
  - **Benefit**: Arabic/English consistency.
  - **Expected**: Matching keys exist.

- [X] T010 Run `flutter gen-l10n`.
  - **Why**: New keys require generated getters.
  - **Benefit**: Catches ARB errors.
  - **Expected**: Generation succeeds.

- [ ] T011 Add subscription center widget tests.
  - **Why**: UI now has sections and caveats.
  - **Benefit**: Prevents display regressions.
  - **Expected**: Active, empty, upcoming, mixed-currency, and price-change states render.

- [X] T012 Run targeted subscription/recurring/notification tests and `flutter analyze --no-pub`.
  - **Why**: Feature spans recurring logic and notifications.
  - **Benefit**: Confirms integration.
  - **Expected**: Targeted tests and analyzer pass.
