import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:expenses_tracker/services/notifications/notification_service.dart';

class NotificationScheduler {
  NotificationScheduler({
    AppNotificationService? notificationService,
  }) : _notificationService =
            notificationService ?? NotificationService.instance;

  static final NotificationScheduler instance = NotificationScheduler();

  final AppNotificationService _notificationService;

  Future<void> syncDailyReminder({
    required UserSettings settings,
    required List<Expense> expenses,
    DateTime? now,
  }) async {
    await _syncDailyReminder(
      settings: settings,
      expenses: expenses,
      now: now,
    );
  }

  Future<void> syncWeeklyDigest({
    required UserSettings settings,
  }) async {
    await _syncWeeklyDigest(settings: settings);
  }

  Future<bool> syncOptionalReminders({
    required UserSettings settings,
    required List<Expense> expenses,
    DateTime? now,
  }) async {
    final dailySynced = await _syncDailyReminder(
      settings: settings,
      expenses: expenses,
      now: now,
    );
    final weeklySynced = await _syncWeeklyDigest(settings: settings);
    return dailySynced && weeklySynced;
  }

  Future<bool> _syncDailyReminder({
    required UserSettings settings,
    required List<Expense> expenses,
    DateTime? now,
  }) async {
    final notificationSettings = settings.notificationSettings;
    if (!notificationSettings.dailyReminderEnabled) {
      await _notificationService.cancel(
        NotificationService.reminderNotificationId,
      );
      return true;
    }

    final reference = now ?? DateTime.now();
    final hasExpenseToday = expenses.any((expense) => _isSameDay(
          expense.date,
          reference,
        ));
    if (hasExpenseToday) {
      await _notificationService.cancel(
        NotificationService.reminderNotificationId,
      );
      return true;
    }

    return _notificationService.scheduleDaily(
      id: NotificationService.reminderNotificationId,
      title: 'Daily spending check-in',
      body: 'Review today\'s spending and keep your tracking streak active.',
      hour: notificationSettings.reminderHour,
      minute: notificationSettings.reminderMinute,
    );
  }

  Future<bool> _syncWeeklyDigest({
    required UserSettings settings,
  }) async {
    final notificationSettings = settings.notificationSettings;
    if (!notificationSettings.weeklyDigestEnabled) {
      await _notificationService.cancel(
        NotificationService.weeklyDigestNotificationId,
      );
      return true;
    }

    return _notificationService.scheduleWeekly(
      id: NotificationService.weeklyDigestNotificationId,
      title: 'Weekly spending digest',
      body: 'Open your local weekly summary and spending health score.',
      weekday: DateTime.monday,
      hour: notificationSettings.weeklyDigestHour,
      minute: notificationSettings.weeklyDigestMinute,
    );
  }

  Future<void> handleExpenseCreated({
    required Expense expense,
    required ExpenseRepository expenseRepository,
    required BudgetRepository budgetRepository,
    required SettingsRepository settingsRepository,
  }) async {
    final settings = await settingsRepository.getSettings();
    await syncDailyReminder(
      settings: settings,
      expenses: await expenseRepository.getExpenses(),
    );
    await syncWeeklyDigest(settings: settings);

    if (!settings.notificationSettings.budgetAlertsEnabled) return;

    final budget = await budgetRepository.getCurrentMonthBudget(
      month: expense.date.month,
      year: expense.date.year,
    );
    if (budget == null) return;

    final expenses = await expenseRepository.getExpenses();
    final previousExpenses = expenses
        .where((candidate) => candidate.expenseId != expense.expenseId)
        .toList();
    final previousProgress = BudgetCalculator.calculate(
      budget: budget,
      expenses: previousExpenses,
    );
    final currentProgress = BudgetCalculator.calculate(
      budget: budget,
      expenses: expenses,
    );

    if (currentProgress.status == BudgetProgressStatus.exceeded) {
      await _showExceededAlertOnce(
        settings: settings,
        settingsRepository: settingsRepository,
        progress: currentProgress,
        budget: budget,
      );
      return;
    }

    if (currentProgress.status == BudgetProgressStatus.nearLimit &&
        previousProgress.status == BudgetProgressStatus.normal) {
      await _notificationService.showImmediate(
        id: NotificationService.budgetNotificationId,
        title: 'Budget warning',
        body: 'You have used '
            '${(currentProgress.percentUsed * 100).toStringAsFixed(0)}% of '
            'your ${budget.currency} budget.',
        channel: AppNotificationChannel.budget,
      );
    }
  }

  Future<void> _showExceededAlertOnce({
    required UserSettings settings,
    required SettingsRepository settingsRepository,
    required BudgetProgress progress,
    required Budget budget,
  }) async {
    final monthKey = NotificationSettings.monthKey(
      DateTime(budget.year, budget.month),
    );
    if (settings.notificationSettings.lastExceededAlertMonth == monthKey) {
      return;
    }

    final shown = await _notificationService.showImmediate(
      id: NotificationService.budgetNotificationId,
      title: 'Budget exceeded',
      body: 'You are over your ${budget.currency} budget by '
          '${(progress.spent - budget.amount).toStringAsFixed(0)}.',
      channel: AppNotificationChannel.budget,
    );
    if (!shown) return;

    await settingsRepository.saveSettings(
      settings.copyWith(
        notificationSettings: settings.notificationSettings.copyWith(
          lastExceededAlertMonth: monthKey,
        ),
        updatedAt: DateTime.now(),
      ),
    );
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
