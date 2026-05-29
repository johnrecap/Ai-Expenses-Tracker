import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationSettingsSection extends StatelessWidget {
  final NotificationSettings settings;
  final bool isSaving;
  final ValueChanged<NotificationSettings> onChanged;

  const NotificationSettingsSection({
    required this.settings,
    required this.isSaving,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationsSettingsTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.budgetAlerts),
              subtitle: Text(l10n.budgetAlertsDescription),
              value: settings.budgetAlertsEnabled,
              onChanged: isSaving
                  ? null
                  : (value) => onChanged(
                      settings.copyWith(budgetAlertsEnabled: value),
                    ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.dailyCheckIn),
              subtitle: Text(l10n.dailyCheckInDescription),
              value: settings.dailyReminderEnabled,
              onChanged: isSaving
                  ? null
                  : (value) => onChanged(
                      settings.copyWith(dailyReminderEnabled: value),
                    ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: !isSaving && settings.dailyReminderEnabled,
              title: Text(l10n.checkInTime),
              subtitle: Text(_formattedReminderTime(context)),
              trailing: const Icon(Icons.schedule),
              onTap: isSaving || !settings.dailyReminderEnabled
                  ? null
                  : () => _pickReminderTime(context),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.weeklyDigest),
              subtitle: Text(l10n.weeklyDigestDescription),
              value: settings.weeklyDigestEnabled,
              onChanged: isSaving
                  ? null
                  : (value) => onChanged(
                      settings.copyWith(weeklyDigestEnabled: value),
                    ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: !isSaving && settings.weeklyDigestEnabled,
              title: Text(l10n.digestTime),
              subtitle: Text(_formattedWeeklyDigestTime(context)),
              trailing: const Icon(Icons.event_note_outlined),
              onTap: isSaving || !settings.weeklyDigestEnabled
                  ? null
                  : () => _pickWeeklyDigestTime(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickWeeklyDigestTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.weeklyDigestHour,
        minute: settings.weeklyDigestMinute,
      ),
    );
    if (selected == null) return;
    onChanged(
      settings.copyWith(
        weeklyDigestTime: NotificationSettings.timeString(
          hour: selected.hour,
          minute: selected.minute,
        ),
      ),
    );
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
    );
    if (selected == null) return;
    onChanged(
      settings.copyWith(
        reminderTime: NotificationSettings.timeString(
          hour: selected.hour,
          minute: selected.minute,
        ),
      ),
    );
  }

  String _formattedReminderTime(BuildContext context) {
    final now = DateTime.now();
    final date = DateTime(
      now.year,
      now.month,
      now.day,
      settings.reminderHour,
      settings.reminderMinute,
    );
    return DateFormat.jm(
      Localizations.localeOf(context).toString(),
    ).format(date);
  }

  String _formattedWeeklyDigestTime(BuildContext context) {
    final now = DateTime.now();
    final date = DateTime(
      now.year,
      now.month,
      now.day,
      settings.weeklyDigestHour,
      settings.weeklyDigestMinute,
    );
    return '${context.l10n.monday}, ${DateFormat.jm(Localizations.localeOf(context).toString()).format(date)}';
  }
}
