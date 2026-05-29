import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:expenses_tracker/guided_tour/widgets/tour_connector_painter.dart';
import 'package:expenses_tracker/l10n/app_localizations_ar.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GuidedTourStep _step() {
  return GuidedTourStep(
    stepId: 'ai',
    targetId: 'ai',
    titleBuilder: (l10n) => l10n.guidedTourAiTitle,
    bodyBuilder: (l10n) => l10n.guidedTourAiBody,
    canSkipIfMissing: false,
  );
}

GuidedTourStep _manualStep() {
  return guidedTourSteps.firstWhere(
    (step) => step.stepId == GuidedTourStepIds.manualExpense,
  );
}

GuidedTourState _state({
  Rect? targetRect = const Rect.fromLTWH(24, 32, 48, 48),
}) {
  return GuidedTourState.idle(
    currentVersion: guidedTourVersion,
    steps: [_step()],
  ).copyWith(
    status: GuidedTourStatus.active,
    activeIndex: 0,
    targetRect: targetRect,
    targetAvailable: targetRect != null,
    targetShape: SpotlightShape.circle,
  );
}

void main() {
  testWidgets('renders dim overlay, highlighted target, and controls', (
    tester,
  ) async {
    var nextCalls = 0;
    var skipCalls = 0;
    await tester.pumpWidget(
      _OverlayHarness(
        state: _state(),
        onNext: () => nextCalls += 1,
        onSkip: () => skipCalls += 1,
      ),
    );

    expect(_spotlightPaintFinder(), findsOneWidget);
    expect(find.text('Meet the AI Assistant'), findsOneWidget);
    expect(find.text('Step 1 of 1'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    expect(skipCalls, 1);
    expect(nextCalls, 0);
  });

  testWidgets('renders without animation when reduced motion is requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      _OverlayHarness(state: _state(), disableAnimations: true),
    );

    expect(find.text('Meet the AI Assistant'), findsOneWidget);
    expect(find.byType(TourOverlay), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('manual expense tour copy explains AI form fill', (tester) async {
    await tester.pumpWidget(
      _OverlayHarness(
        state:
            GuidedTourState.idle(
              currentVersion: guidedTourVersion,
              steps: [_manualStep()],
            ).copyWith(
              status: GuidedTourStatus.active,
              activeIndex: 0,
              targetRect: const Rect.fromLTWH(160, 680, 56, 56),
              targetAvailable: true,
              targetShape: SpotlightShape.circle,
            ),
      ),
    );

    expect(find.text('Add expenses manually'), findsOneWidget);
    expect(
      find.text(
        'Use the plus button to open the normal expense form. AI can fill it at the top, and Save is still your final step.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('keeps card visible for RTL small screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _OverlayHarness(
        state: _state(targetRect: const Rect.fromLTWH(250, 24, 48, 48)),
        locale: const Locale('ar'),
        textDirection: TextDirection.rtl,
      ),
    );

    expect(find.text(AppLocalizationsAr().guidedTourAiTitle), findsOneWidget);
    expect(find.text(AppLocalizationsAr().guidedTourDone), findsOneWidget);
  });

  testWidgets('draws connector after card layout is measured', (tester) async {
    await tester.pumpWidget(
      _OverlayHarness(
        state: _state(targetRect: const Rect.fromLTWH(280, 32, 48, 48)),
      ),
    );
    await tester.pump();

    expect(_connectorPaintFinder(), findsOneWidget);
  });

  testWidgets('keeps action buttons visible on compact RTL viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _OverlayHarness(
        state: _state(targetRect: const Rect.fromLTWH(250, 24, 48, 48)),
        locale: const Locale('ar'),
        textDirection: TextDirection.rtl,
      ),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsAr().guidedTourSkip), findsOneWidget);
    expect(find.text(AppLocalizationsAr().guidedTourDone), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('absorbs target taps behind the overlay', (tester) async {
    var targetTaps = 0;
    await tester.pumpWidget(
      _OverlayHarness(
        state: _state(),
        background: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 96,
            height: 96,
            child: TextButton(
              onPressed: () => targetTaps += 1,
              child: const Text('Target action'),
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(24, 24));
    await tester.pump();

    expect(targetTaps, 0);
  });
}

Finder _spotlightPaintFinder() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CustomPaint &&
        widget.painter?.runtimeType.toString() == '_SpotlightPainter',
  );
}

Finder _connectorPaintFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter is TourConnectorPainter,
  );
}

class _OverlayHarness extends StatelessWidget {
  const _OverlayHarness({
    required this.state,
    this.disableAnimations = false,
    this.locale = const Locale('en'),
    this.textDirection = TextDirection.ltr,
    this.onNext,
    this.onSkip,
    this.background = const SizedBox.expand(),
  });

  final GuidedTourState state;
  final bool disableAnimations;
  final Locale locale;
  final TextDirection textDirection;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final Widget background;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 800),
            disableAnimations: disableAnimations,
          ),
          child: Scaffold(
            body: Stack(
              children: [
                background,
                TourOverlay(
                  state: state,
                  onNext: onNext ?? () {},
                  onBack: () {},
                  onSkip: onSkip ?? () {},
                  onDone: onNext ?? () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
