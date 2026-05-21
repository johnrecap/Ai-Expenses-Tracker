import 'dart:developer';

import 'package:flutter/foundation.dart';

enum ObservabilityEvent {
  appStarted('app_started'),
  homeViewed('home_viewed'),
  settingsViewed('settings_viewed'),
  expenseCreated('expense_created'),
  reportViewed('report_viewed'),
  exportStarted('export_started'),
  aiActionStarted('ai_action_started'),
  aiActionUnavailable('ai_action_unavailable'),
  monetizationViewed('monetization_viewed'),
  retentionCardViewed('retention_card_viewed'),
  feedbackOpened('feedback_opened');

  const ObservabilityEvent(this.name);

  final String name;
}

enum ObservabilityArea {
  app,
  auth,
  home,
  settings,
  expenses,
  reports,
  export,
  ai,
  monetization,
  engagement,
}

typedef SafeEventParameters = Map<String, Object?>;

abstract class ObservabilityService {
  const ObservabilityService();

  Future<void> logEvent(
    ObservabilityEvent event, {
    SafeEventParameters parameters = const {},
  });

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required ObservabilityArea area,
    String? code,
    SafeEventParameters parameters = const {},
  });

  Future<void> setUserContext({String? userId});
}

class NoopObservabilityService extends ObservabilityService {
  const NoopObservabilityService();

  @override
  Future<void> logEvent(
    ObservabilityEvent event, {
    SafeEventParameters parameters = const {},
  }) async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required ObservabilityArea area,
    String? code,
    SafeEventParameters parameters = const {},
  }) async {}

  @override
  Future<void> setUserContext({String? userId}) async {}
}

class DebugObservabilityService extends ObservabilityService {
  const DebugObservabilityService();

  static const _logName = 'Observability';

  @override
  Future<void> logEvent(
    ObservabilityEvent event, {
    SafeEventParameters parameters = const {},
  }) async {
    if (!kDebugMode) return;
    log(
      'event=${event.name} parameters=${sanitizeEventParameters(parameters)}',
      name: _logName,
    );
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required ObservabilityArea area,
    String? code,
    SafeEventParameters parameters = const {},
  }) async {
    if (!kDebugMode) return;
    log(
      'error area=${area.name} code=$code type=${error.runtimeType} '
      'parameters=${sanitizeEventParameters(parameters)}',
      name: _logName,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<void> setUserContext({String? userId}) async {
    if (!kDebugMode) return;
    log('setUserContext hasUser=${userId != null}', name: _logName);
  }
}

Map<String, Object> sanitizeEventParameters(SafeEventParameters parameters) {
  final sanitized = <String, Object>{};

  for (final entry in parameters.entries) {
    final key = entry.key.trim();
    final value = entry.value;
    if (key.isEmpty || !_isSafeParameterKey(key) || value == null) continue;

    if (value is String) {
      sanitized[key] = value.length > 64 ? value.substring(0, 64) : value;
    } else if (value is num || value is bool) {
      sanitized[key] = value;
    }
  }

  return sanitized;
}

bool _isSafeParameterKey(String key) {
  final normalized = key.toLowerCase();
  const forbiddenFragments = [
    'description',
    'receipt',
    'token',
    'secret',
    'key',
    'pin',
    'biometric',
    'prompt',
    'image',
    'text',
    'password',
  ];

  return forbiddenFragments.every((fragment) => !normalized.contains(fragment));
}
