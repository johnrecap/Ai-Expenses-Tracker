# Implementation Plan: Smart Notifications

## Technical Context

Notifications depend on budget and expense creation events.

## Architecture

Use local notifications for first version. Keep notification decision logic testable without platform APIs.

## Files

- Modify: `pubspec.yaml`
- Create: `lib/services/notifications/notification_service.dart`
- Create: `lib/services/notifications/notification_scheduler.dart`
- Create: `packages/expense_repository/lib/src/models/notification_settings.dart`
- Create: `lib/screens/settings/widgets/notification_settings_section.dart`

## Data Model

Notification settings: budget alerts, daily reminder enabled, reminder time, last budget alert period.

## Risks

- Platform notification permissions differ.
- Background scheduling reliability differs by platform.

## Verification

- Unit tests for notification decision logic.
- Manual permission and scheduled reminder test.

## Detailed Execution Guidance

- Separate notification decision logic from plugin calls.
- Add settings before scheduling notifications.
- Budget notifications depend on BudgetCalculator output.
- Respect permissions and disabled settings.
- Avoid server push or background ML in this plan.
