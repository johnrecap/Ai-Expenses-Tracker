import 'dart:math' as math;

import 'package:expenses_tracker/guided_tour/models/guided_tour_state.dart';
import 'package:expenses_tracker/guided_tour/models/guided_tour_step.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';

class TourOverlay extends StatefulWidget {
  const TourOverlay({
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onDone,
    super.key,
  });

  final GuidedTourState state;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onDone;

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant TourOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.state.activeStep;
    if (step == null) return const SizedBox.shrink();

    final l10n = context.l10n;
    final targetRect = widget.state.targetAvailable
        ? _visibleRectFor(context, widget.state.targetRect)
        : null;
    final title = step.title(l10n);
    final body = step.body(l10n);
    final stepCount = l10n.guidedTourStepCount(
      widget.state.stepNumber,
      widget.state.stepCount,
    );

    return Positioned.fill(
      child: Semantics(
        container: true,
        liveRegion: true,
        label: '$title. $body. $stepCount',
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final pulse =
                  _reducedMotion(context) ? 0.0 : _pulseController.value;
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SpotlightPainter(
                        targetRect: targetRect,
                        shape: widget.state.targetShape,
                        pulse: pulse,
                        overlayColor: Colors.black.withValues(alpha: 0.68),
                        borderColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                    ),
                  ),
                  _TourCard(
                    state: widget.state,
                    targetRect: targetRect,
                    title: title,
                    body: body,
                    stepCount: stepCount,
                    onNext: widget.onNext,
                    onBack: widget.onBack,
                    onSkip: widget.onSkip,
                    onDone: widget.onDone,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _syncAnimation() {
    if (_reducedMotion(context)) {
      _pulseController.stop();
      _pulseController.value = 0;
      return;
    }
    if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  bool _reducedMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  Rect? _visibleRectFor(BuildContext context, Rect? rect) {
    if (rect == null) return null;
    final size = MediaQuery.sizeOf(context);
    final visible = Offset.zero & size;
    if (!rect.overlaps(visible)) return null;
    return rect.intersect(visible);
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.state,
    required this.targetRect,
    required this.title,
    required this.body,
    required this.stepCount,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onDone,
  });

  final GuidedTourState state;
  final Rect? targetRect;
  final String title;
  final String body;
  final String stepCount;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = _topFor(context);
    final bottom = _bottomFor(context);
    return Positioned(
      left: 16,
      right: 16,
      top: top,
      bottom: bottom,
      child: SafeArea(
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    color: Colors.black.withValues(alpha: 0.22),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      stepCount,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      style: const TextStyle(
                        height: 1.35,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: state.isPersisting ? null : onSkip,
                          child: Text(l10n.guidedTourSkip),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed:
                                  state.hasPrevious && !state.isPersisting
                                      ? onBack
                                      : null,
                              child: Text(l10n.guidedTourBack),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: state.isPersisting
                                  ? null
                                  : state.isLastStep
                                      ? onDone
                                      : onNext,
                              child: Text(
                                state.isLastStep
                                    ? l10n.guidedTourDone
                                    : l10n.guidedTourNext,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double? _topFor(BuildContext context) {
    final rect = targetRect;
    if (rect == null) return MediaQuery.paddingOf(context).top + 24;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final belowTarget = rect.center.dy < screenHeight / 2 ||
        state.activeStep?.placement == GuidedTourPlacement.below;
    if (!belowTarget &&
        state.activeStep?.placement != GuidedTourPlacement.below) {
      return MediaQuery.paddingOf(context).top + 16;
    }
    return math.min(rect.bottom + 16, screenHeight * 0.58);
  }

  double? _bottomFor(BuildContext context) {
    final rect = targetRect;
    if (rect == null) return null;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final aboveTarget = rect.center.dy >= screenHeight / 2 ||
        state.activeStep?.placement == GuidedTourPlacement.above;
    if (!aboveTarget ||
        state.activeStep?.placement == GuidedTourPlacement.below) {
      return null;
    }
    return math.max(screenHeight - rect.top + 16, 16);
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.targetRect,
    required this.shape,
    required this.pulse,
    required this.overlayColor,
    required this.borderColor,
  });

  final Rect? targetRect;
  final SpotlightShape shape;
  final double pulse;
  final Color overlayColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = Path()..addRect(Offset.zero & size);
    final target = targetRect;
    if (target == null || target.isEmpty) {
      canvas.drawPath(fullPath, Paint()..color = overlayColor);
      return;
    }

    final hole = _targetPath(target);
    final dimPath = Path.combine(PathOperation.difference, fullPath, hole);
    canvas.drawPath(dimPath, Paint()..color = overlayColor);

    final strokeWidth = 2.0 + pulse;
    final glowWidth = 8.0 + (pulse * 8);
    canvas.drawPath(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = glowWidth
        ..color = borderColor.withValues(alpha: 0.18),
    );
    canvas.drawPath(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = borderColor,
    );
  }

  Path _targetPath(Rect rect) {
    switch (shape) {
      case SpotlightShape.circle:
        final diameter = math.max(rect.width, rect.height);
        final circleRect = Rect.fromCenter(
          center: rect.center,
          width: diameter,
          height: diameter,
        );
        return Path()..addOval(circleRect);
      case SpotlightShape.roundedRectangle:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(16)),
          );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.shape != shape ||
        oldDelegate.pulse != pulse ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor;
  }
}
