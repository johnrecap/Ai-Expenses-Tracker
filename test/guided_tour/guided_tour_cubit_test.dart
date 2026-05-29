import 'dart:io';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

GuidedTourStep _step(
  String id, {
  bool canSkipIfMissing = false,
  String? targetId,
}) {
  return GuidedTourStep(
    stepId: id,
    targetId: targetId ?? id,
    titleBuilder: (_) => id,
    bodyBuilder: (_) => '$id body',
    canSkipIfMissing: canSkipIfMissing,
  );
}

UserSettings _settings({
  bool onboardingCompleted = true,
  int completedVersion = 0,
  int skippedVersion = 0,
}) {
  return UserSettings.defaults(
    userId: 'user-1',
    onboardingCompleted: onboardingCompleted,
    onboardingVersion: UserSettings.currentOnboardingVersion,
    updatedAt: DateTime(2026, 5, 18),
  ).copyWith(
    guidedTourCompletedVersion: completedVersion,
    guidedTourSkippedVersion: skippedVersion,
  );
}

void main() {
  test('auto-start waits for onboarding completion', () async {
    final repository = FakeSettingsRepository(
      _settings(onboardingCompleted: false),
    );
    final cubit = GuidedTourCubit(
      settingsRepository: repository,
      steps: [_step('ai')],
    );

    await cubit.maybeStart();

    expect(cubit.state.isActive, isFalse);
    await cubit.close();
  });

  test('completed or skipped current version suppresses auto-start', () async {
    final completedRepository = FakeSettingsRepository(
      _settings(completedVersion: guidedTourVersion),
    );
    final completedCubit = GuidedTourCubit(
      settingsRepository: completedRepository,
      steps: [_step('ai')],
    );

    await completedCubit.maybeStart();

    expect(completedCubit.state.isActive, isFalse);
    await completedCubit.close();

    final skippedRepository = FakeSettingsRepository(
      _settings(skippedVersion: guidedTourVersion),
    );
    final skippedCubit = GuidedTourCubit(
      settingsRepository: skippedRepository,
      steps: [_step('ai')],
    );

    await skippedCubit.maybeStart();

    expect(skippedCubit.state.isActive, isFalse);
    await skippedCubit.close();
  });

  test('replay overrides completed and skipped suppression', () async {
    final repository = FakeSettingsRepository(
      _settings(completedVersion: guidedTourVersion),
    );
    final cubit = GuidedTourCubit(
      settingsRepository: repository,
      steps: [_step('ai')],
    );

    cubit.replay();

    expect(cubit.state.isActive, isTrue);
    expect(cubit.state.replayMode, isTrue);
    expect(cubit.state.activeStep?.stepId, 'ai');
    await cubit.close();
  });

  test('next and back follow configured step order', () async {
    final repository = FakeSettingsRepository(_settings());
    final cubit = GuidedTourCubit(
      settingsRepository: repository,
      steps: [_step('ai'), _step('manual'), _step('budget')],
    );

    cubit.replay();
    expect(cubit.state.activeStep?.stepId, 'ai');

    await cubit.next();
    expect(cubit.state.activeStep?.stepId, 'manual');

    cubit.back();
    expect(cubit.state.activeStep?.stepId, 'ai');
    await cubit.close();
  });

  test('missing skippable targets are skipped without crashing', () async {
    final repository = FakeSettingsRepository(_settings());
    final cubit = GuidedTourCubit(
      settingsRepository: repository,
      steps: [_step('missing', canSkipIfMissing: true), _step('fallback')],
    );

    cubit.replay();

    expect(cubit.state.activeStep?.stepId, 'fallback');
    expect(cubit.state.skippedMissingStepIds, contains('missing'));
    await cubit.close();
  });

  test('skip and completion persist current tour version', () async {
    final skippedRepository = FakeSettingsRepository(_settings());
    final skippedCubit = GuidedTourCubit(
      settingsRepository: skippedRepository,
      steps: [_step('ai')],
    );
    skippedCubit.replay();

    await skippedCubit.skip();

    expect(
      skippedRepository.settings.guidedTourSkippedVersion,
      guidedTourVersion,
    );
    expect(skippedRepository.settings.guidedTourLastStepId, 'ai');
    await skippedCubit.close();

    final completedRepository = FakeSettingsRepository(_settings());
    final completedCubit = GuidedTourCubit(
      settingsRepository: completedRepository,
      steps: [_step('ai')],
    );
    completedCubit.replay();

    await completedCubit.complete();

    expect(
      completedRepository.settings.guidedTourCompletedVersion,
      guidedTourVersion,
    );
    expect(completedRepository.settings.guidedTourLastStepId, isNull);
    await completedCubit.close();
  });

  test(
    'back button moves backward before skipping on the first step',
    () async {
      final repository = FakeSettingsRepository(_settings());
      final cubit = GuidedTourCubit(
        settingsRepository: repository,
        steps: [_step('ai'), _step('manual')],
      );
      cubit.replay();
      await cubit.next();

      await cubit.handleBackButton();

      expect(cubit.state.isActive, isTrue);
      expect(cubit.state.activeStep?.stepId, 'ai');
      expect(repository.settings.guidedTourSkippedVersion, 0);

      await cubit.handleBackButton();

      expect(cubit.state.isActive, isFalse);
      expect(repository.settings.guidedTourSkippedVersion, guidedTourVersion);
      expect(repository.settings.guidedTourLastStepId, 'ai');
      await cubit.close();
    },
  );

  test('remaining step metadata has runtime consumers', () {
    final step = _step('ai', canSkipIfMissing: true);
    final stepModelSource = File(
      'lib/guided_tour/models/guided_tour_step.dart',
    ).readAsStringSync();

    expect(step.placement, GuidedTourPlacement.automatic);
    expect(step.canSkipIfMissing, isTrue);
    expect(step.placement.name, 'automatic');
    expect(stepModelSource.contains('routeName'), isFalse);
    expect(stepModelSource.contains('allowTargetTap'), isFalse);
  });
}
