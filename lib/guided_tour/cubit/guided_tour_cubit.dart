import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/guided_tour/guided_tour_steps.dart';
import 'package:expenses_tracker/guided_tour/models/guided_tour_state.dart';
import 'package:expenses_tracker/guided_tour/models/guided_tour_step.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GuidedTourCubit extends Cubit<GuidedTourState> {
  GuidedTourCubit({
    required SettingsRepository settingsRepository,
    List<GuidedTourStep>? steps,
    int currentVersion = guidedTourVersion,
  })  : _settingsRepository = settingsRepository,
        _steps = steps ?? guidedTourSteps,
        super(
          GuidedTourState.idle(
            currentVersion: currentVersion,
            steps: steps ?? guidedTourSteps,
          ),
        );

  final SettingsRepository _settingsRepository;
  final List<GuidedTourStep> _steps;
  final Map<String, _RegisteredSpotlightTarget> _targets = {};
  bool _checkingAutoStart = false;

  Future<void> maybeStart() async {
    if (isClosed) return;
    if (_checkingAutoStart || state.isActive) return;
    _checkingAutoStart = true;
    try {
      final settings = await _settingsRepository.getSettings();
      if (isClosed) return;
      if (!settings.shouldShowGuidedTourVersion(state.currentVersion)) return;
      _start(replayMode: false);
    } catch (_) {
      // Tour startup must not block Home if settings are temporarily unavailable.
    } finally {
      _checkingAutoStart = false;
    }
  }

  void replay() {
    if (isClosed) return;
    _start(replayMode: true);
  }

  void registerTarget({
    required String targetId,
    required GlobalKey key,
    required SpotlightShape shape,
    required EdgeInsets padding,
  }) {
    if (isClosed) return;
    _targets[targetId] = _RegisteredSpotlightTarget(
      key: key,
      shape: shape,
      padding: padding,
    );
    if (state.activeStep?.targetId == targetId) {
      _prepareAndRefreshActiveTarget();
    }
  }

  void unregisterTarget(String targetId, GlobalKey key) {
    if (isClosed) return;
    final current = _targets[targetId];
    if (current == null || current.key != key) return;
    _targets.remove(targetId);
    if (state.activeStep?.targetId == targetId) {
      _refreshActiveTarget();
    }
  }

  void refreshActiveTarget() {
    if (isClosed) return;
    _refreshActiveTarget();
  }

  Future<void> next() async {
    if (isClosed) return;
    if (!state.isActive) return;
    if (state.isLastStep) {
      await complete();
      return;
    }
    _activateFromIndex(from: state.activeIndex + 1, direction: 1);
  }

  void back() {
    if (isClosed) return;
    if (!state.isActive) return;
    if (!state.hasPrevious) return;
    _activateFromIndex(from: state.activeIndex - 1, direction: -1);
  }

  Future<void> skip() async {
    if (isClosed) return;
    if (!state.isActive) return;
    await _persistProgress(completed: false);
    if (isClosed) return;
    emit(state.asIdle());
  }

  Future<void> complete() async {
    if (isClosed) return;
    if (!state.isActive) return;
    await _persistProgress(completed: true);
    if (isClosed) return;
    emit(state.asIdle());
  }

  Future<void> handleBackButton() async {
    if (isClosed) return;
    if (!state.isActive) return;
    if (state.hasPrevious) {
      back();
      return;
    }
    await skip();
  }

  void _start({required bool replayMode}) {
    if (isClosed) return;
    if (_steps.isEmpty) return;
    final skipped = <String>{};
    final startIndex = _nextAvailableIndex(
      from: 0,
      direction: 1,
      skipped: skipped,
    );
    if (startIndex == null) return;
    emit(
      state.copyWith(
        status: GuidedTourStatus.active,
        activeIndex: startIndex,
        replayMode: replayMode,
        isPersisting: false,
        clearTargetRect: true,
        targetAvailable: false,
        skippedMissingStepIds: skipped,
      ),
    );
    _prepareAndRefreshActiveTarget();
  }

  void _activateFromIndex({
    required int from,
    required int direction,
  }) {
    if (isClosed) return;
    final skipped = Set<String>.from(state.skippedMissingStepIds);
    final nextIndex = _nextAvailableIndex(
      from: from,
      direction: direction,
      skipped: skipped,
    );
    if (nextIndex == null) {
      complete();
      return;
    }
    emit(
      state.copyWith(
        status: GuidedTourStatus.active,
        activeIndex: nextIndex,
        clearTargetRect: true,
        targetAvailable: false,
        skippedMissingStepIds: skipped,
      ),
    );
    _prepareAndRefreshActiveTarget();
  }

  int? _nextAvailableIndex({
    required int from,
    required int direction,
    required Set<String> skipped,
  }) {
    var index = from;
    while (index >= 0 && index < _steps.length) {
      final step = _steps[index];
      if (_targets.containsKey(step.targetId) || !step.canSkipIfMissing) {
        return index;
      }
      skipped.add(step.stepId);
      index += direction;
    }
    return null;
  }

  void _refreshActiveTarget() {
    if (isClosed) return;
    if (!state.isActive) return;
    final step = state.activeStep;
    if (step == null) return;
    final target = _targets[step.targetId];
    if (target == null) {
      if (!state.targetAvailable && state.targetRect == null) return;
      emit(
        state.copyWith(
          clearTargetRect: true,
          targetAvailable: false,
        ),
      );
      return;
    }

    final context = target.key.currentContext;
    final renderObject = context?.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.attached ||
        !renderObject.hasSize) {
      if (!state.targetAvailable &&
          state.targetRect == null &&
          state.targetShape == target.shape) {
        return;
      }
      emit(
        state.copyWith(
          clearTargetRect: true,
          targetAvailable: false,
          targetShape: target.shape,
        ),
      );
      return;
    }

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final rect = target.padding.inflateRect(topLeft & renderObject.size);
    if (state.targetAvailable &&
        state.targetRect == rect &&
        state.targetShape == target.shape) {
      return;
    }
    emit(
      state.copyWith(
        targetRect: rect,
        targetAvailable: true,
        targetShape: target.shape,
      ),
    );
  }

  void _prepareAndRefreshActiveTarget() {
    if (isClosed) return;
    if (!state.isActive) return;
    final step = state.activeStep;
    if (step == null) return;
    final target = _targets[step.targetId];
    if (target == null) {
      _refreshActiveTarget();
      return;
    }

    final context = target.key.currentContext;
    if (context == null) {
      _refreshActiveTarget();
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: Duration.zero,
      alignment: 0.5,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
    _refreshActiveTarget();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      _refreshActiveTarget();
    });
  }

  Future<void> _persistProgress({required bool completed}) async {
    if (isClosed) return;
    emit(state.copyWith(isPersisting: true));
    try {
      final settings = await _settingsRepository.getSettings();
      if (isClosed) return;
      final activeStepId = state.activeStep?.stepId;
      final updated = completed
          ? settings.copyWith(
              guidedTourCompletedVersion: max(
                settings.guidedTourCompletedVersion,
                state.currentVersion,
              ),
              clearGuidedTourLastStepId: true,
              updatedAt: DateTime.now(),
            )
          : settings.copyWith(
              guidedTourSkippedVersion: max(
                settings.guidedTourSkippedVersion,
                state.currentVersion,
              ),
              guidedTourLastStepId: activeStepId,
              updatedAt: DateTime.now(),
            );
      await _settingsRepository.saveSettings(updated);
    } catch (_) {
      // Dismissal should still close the overlay; settings sync can retry later.
    }
  }
}

class _RegisteredSpotlightTarget {
  const _RegisteredSpotlightTarget({
    required this.key,
    required this.shape,
    required this.padding,
  });

  final GlobalKey key;
  final SpotlightShape shape;
  final EdgeInsets padding;
}
