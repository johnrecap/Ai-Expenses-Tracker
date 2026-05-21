# Tasks: Smart Notifications

## Implementation Intent

Add local notifications for budget warnings and forgotten expense reminders. This is not server push notification work.

---

## Phase 1: Dependencies And Settings

### [x] T001 - Add Notification Packages

**Files:** Modify `pubspec.yaml`.

**Steps:** Add `flutter_local_notifications` and `timezone`; run `flutter pub get`.

**Done When:** Packages resolve.

### [x] T002 - Create Notification Settings Model

**Files:** Create `packages/expense_repository/lib/src/models/notification_settings.dart`.

**Steps:** Include budgetAlertsEnabled, dailyReminderEnabled, reminderTime, lastExceededAlertMonth.

**Done When:** User preferences can be stored.

### [x] T003 - Add Settings Repository Fields

**Files:** Modify user settings model/entity/repository.

**Steps:** Embed notification settings or store under settings profile.

**Done When:** Settings persist.

### [x] T004 - Add Settings UI Controls

**Files:** Create `lib/screens/settings/widgets/notification_settings_section.dart`.

**Steps:** Toggles for budget alerts and reminders; time picker for reminder time.

**Done When:** User controls notifications.

---

## Phase 2: Platform Setup

### [x] T005 - Android Channel

**Files:** Notification service and Android manifest if needed.

**Steps:** Create channel for budget/reminder notifications.

**Done When:** Android notifications have a channel.

### [x] T006 - iOS/macOS Permissions

**Steps:** Request permissions through plugin; handle denied state gracefully.

**Done When:** App does not assume permission granted.

### [x] T007 - Create `NotificationService`

**Files:** Create `lib/services/notifications/notification_service.dart`.

**Steps:** Initialize plugin, request permissions, show immediate notification.

**Done When:** Service can display a local notification.

### [x] T008 - Create `NotificationScheduler`

**Files:** Create `lib/services/notifications/notification_scheduler.dart`.

**Steps:** Schedule daily reminders with timezone support.

**Done When:** Reminder scheduling is centralized.

---

## Phase 3: Rules

### [x] T009 - Near-Budget Warning

**Steps:** After expense creation, calculate budget status; if near limit and enabled, show warning.

**Done When:** Warning triggers once when crossing threshold.

### [x] T010 - Exceeded Warning

**Steps:** Track current month/year alert to avoid repeated spam.

**Done When:** Exceeded notification is not repeated on every app rebuild.

### [x] T011 - Forgotten Expense Reminder

**Steps:** Schedule reminder at configured time; message says user has not logged expenses today if true.

**Done When:** Reminder respects setting.

### [x] T012 - Respect Settings

**Steps:** If notification type disabled, do not schedule or show it.

**Done When:** User preference is authoritative.

---

## Phase 4: Tests

### T013 - Decision Tests

Test near limit, exceeded, disabled settings, already-alerted month.

### T014 - Permission QA

Manual test on Android/iOS where available.

### T015 - Reminder QA

Schedule near-future reminder and verify delivery.
