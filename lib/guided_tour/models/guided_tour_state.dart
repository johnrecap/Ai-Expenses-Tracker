import 'dart:ui';

import 'package:equatable/equatable.dart';

import 'guided_tour_step.dart';

enum GuidedTourStatus {
  idle,
  active,
}

class GuidedTourState extends Equatable {
  static const noActiveStep = -1;

  const GuidedTourState({
    required this.status,
    required this.currentVersion,
    required this.steps,
    required this.activeIndex,
    required this.targetAvailable,
    required this.targetShape,
    required this.replayMode,
    required this.isPersisting,
    required this.skippedMissingStepIds,
    this.targetRect,
  });

  factory GuidedTourState.idle({
    required int currentVersion,
    required List<GuidedTourStep> steps,
  }) {
    return GuidedTourState(
      status: GuidedTourStatus.idle,
      currentVersion: currentVersion,
      steps: steps,
      activeIndex: noActiveStep,
      targetAvailable: false,
      targetShape: SpotlightShape.roundedRectangle,
      replayMode: false,
      isPersisting: false,
      skippedMissingStepIds: const {},
    );
  }

  final GuidedTourStatus status;
  final int currentVersion;
  final List<GuidedTourStep> steps;
  final int activeIndex;
  final Rect? targetRect;
  final bool targetAvailable;
  final SpotlightShape targetShape;
  final bool replayMode;
  final bool isPersisting;
  final Set<String> skippedMissingStepIds;

  bool get isActive => status == GuidedTourStatus.active && activeStep != null;

  bool get hasPrevious => isActive && activeIndex > 0;

  bool get isLastStep => isActive && activeIndex == steps.length - 1;

  int get stepNumber => isActive ? activeIndex + 1 : 0;

  int get stepCount => steps.length;

  GuidedTourStep? get activeStep {
    if (activeIndex < 0 || activeIndex >= steps.length) return null;
    return steps[activeIndex];
  }

  GuidedTourState copyWith({
    GuidedTourStatus? status,
    int? activeIndex,
    Rect? targetRect,
    bool clearTargetRect = false,
    bool? targetAvailable,
    SpotlightShape? targetShape,
    bool? replayMode,
    bool? isPersisting,
    Set<String>? skippedMissingStepIds,
  }) {
    return GuidedTourState(
      status: status ?? this.status,
      currentVersion: currentVersion,
      steps: steps,
      activeIndex: activeIndex ?? this.activeIndex,
      targetRect: clearTargetRect ? null : targetRect ?? this.targetRect,
      targetAvailable: targetAvailable ?? this.targetAvailable,
      targetShape: targetShape ?? this.targetShape,
      replayMode: replayMode ?? this.replayMode,
      isPersisting: isPersisting ?? this.isPersisting,
      skippedMissingStepIds:
          skippedMissingStepIds ?? this.skippedMissingStepIds,
    );
  }

  GuidedTourState asIdle() {
    return GuidedTourState.idle(
      currentVersion: currentVersion,
      steps: steps,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentVersion,
        activeIndex,
        targetRect,
        targetAvailable,
        targetShape,
        replayMode,
        isPersisting,
        skippedMissingStepIds,
      ];
}
