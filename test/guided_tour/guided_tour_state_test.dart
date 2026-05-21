import 'dart:ui';

import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:flutter_test/flutter_test.dart';

GuidedTourStep _step(String id) {
  return GuidedTourStep(
    stepId: id,
    targetId: id,
    titleBuilder: (_) => id,
    bodyBuilder: (_) => '$id body',
  );
}

void main() {
  test('idle state has no active step', () {
    final state = GuidedTourState.idle(
      currentVersion: guidedTourVersion,
      steps: [_step('ai')],
    );

    expect(state.isActive, isFalse);
    expect(state.activeStep, isNull);
    expect(state.stepNumber, 0);
  });

  test('active state exposes step progress and completion flags', () {
    final steps = [_step('ai'), _step('manual')];
    final state = GuidedTourState.idle(
      currentVersion: guidedTourVersion,
      steps: steps,
    ).copyWith(
      status: GuidedTourStatus.active,
      activeIndex: 1,
      targetRect: const Rect.fromLTWH(10, 20, 30, 40),
      targetAvailable: true,
      targetShape: SpotlightShape.circle,
    );

    expect(state.isActive, isTrue);
    expect(state.hasPrevious, isTrue);
    expect(state.isLastStep, isTrue);
    expect(state.stepNumber, 2);
    expect(state.stepCount, 2);
    expect(state.activeStep?.stepId, 'manual');
    expect(state.targetRect, const Rect.fromLTWH(10, 20, 30, 40));
  });

  test('asIdle clears active presentation state', () {
    final active = GuidedTourState.idle(
      currentVersion: guidedTourVersion,
      steps: [_step('ai')],
    ).copyWith(
      status: GuidedTourStatus.active,
      activeIndex: 0,
      targetRect: const Rect.fromLTWH(1, 2, 3, 4),
      targetAvailable: true,
      replayMode: true,
    );

    final idle = active.asIdle();

    expect(idle.isActive, isFalse);
    expect(idle.targetRect, isNull);
    expect(idle.replayMode, isFalse);
  });
}
