import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

GuidedTourStep _step() {
  return GuidedTourStep(
    stepId: 'late_target',
    targetId: 'late_target',
    titleBuilder: (_) => 'Late target',
    bodyBuilder: (_) => 'Prepared before spotlighting.',
    canSkipIfMissing: false,
  );
}

UserSettings _settings() {
  return UserSettings.defaults(
    userId: 'user-1',
    onboardingCompleted: true,
    onboardingVersion: UserSettings.currentOnboardingVersion,
    updatedAt: DateTime(2026, 5, 18),
  );
}

void main() {
  testWidgets('scrolls an off-screen target into view before spotlighting', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cubit = GuidedTourCubit(
      settingsRepository: FakeSettingsRepository(_settings()),
      steps: [_step()],
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<GuidedTourCubit>.value(
        value: cubit,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GuidedTourHost(
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 900),
                    SpotlightTarget(
                      targetId: 'late_target',
                      child: SizedBox(
                        key: ValueKey('late-target-child'),
                        height: 48,
                        width: 120,
                        child: Text('Prepared target'),
                      ),
                    ),
                    SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('late-target-child'))).dy,
      greaterThan(520),
    );

    cubit.replay();
    await tester.pump();
    await tester.pump();

    final targetTop = tester
        .getTopLeft(find.byKey(const ValueKey('late-target-child')))
        .dy;
    expect(targetTop, inInclusiveRange(0, 520));
    expect(cubit.state.targetAvailable, isTrue);
    expect(
      cubit.state.targetRect?.overlaps(const Rect.fromLTWH(0, 0, 400, 520)),
      isTrue,
    );
  });
}
