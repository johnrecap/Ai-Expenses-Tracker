import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class SimpleBlocObserver extends BlocObserver {
  static const _logName = 'SimpleBlocObserver';

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      log('onCreate -- bloc: ${bloc.runtimeType}', name: _logName);
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      log(
        'onEvent -- bloc: ${bloc.runtimeType}, event: ${event.runtimeType}',
        name: _logName,
      );
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      log(
        'onChange -- bloc: ${bloc.runtimeType}, '
        'currentState: ${change.currentState.runtimeType}, '
        'nextState: ${change.nextState.runtimeType}',
        name: _logName,
      );
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      log(
        'onTransition -- bloc: ${bloc.runtimeType}, '
        'event: ${transition.event.runtimeType}, '
        'currentState: ${transition.currentState.runtimeType}, '
        'nextState: ${transition.nextState.runtimeType}',
        name: _logName,
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      log(
        'onError -- bloc: ${bloc.runtimeType}, errorType: ${error.runtimeType}',
        name: _logName,
        stackTrace: stackTrace,
      );
    } else {
      log(
        'onError -- bloc: ${bloc.runtimeType}, errorType: ${error.runtimeType}',
        name: _logName,
      );
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      log('onClose -- bloc: ${bloc.runtimeType}', name: _logName);
    }
  }
}
