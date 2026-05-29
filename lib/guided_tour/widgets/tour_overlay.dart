import 'dart:math' as math;

import 'package:expenses_tracker/guided_tour/models/guided_tour_state.dart';
import 'package:expenses_tracker/guided_tour/models/guided_tour_step.dart';
import 'package:expenses_tracker/guided_tour/tour_surface_style.dart';
import 'package:expenses_tracker/guided_tour/widgets/tour_connector_painter.dart';
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
  final _cardKey = GlobalKey();
  Rect? _cardRect;

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
    if (oldWidget.state.activeStep?.stepId != widget.state.activeStep?.stepId) {
      _cardRect = null;
    }
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
    final style = TourSurfaceStyle.from(context);
    _scheduleCardRectUpdate();

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
              final pulse = _reducedMotion(context)
                  ? 0.0
                  : _pulseController.value;
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SpotlightPainter(
                        targetRect: targetRect,
                        shape: widget.state.targetShape,
                        pulse: pulse,
                        overlayColor: style.overlayColor,
                        borderColor: style.primaryAccent,
                      ),
                    ),
                  ),
                  if (targetRect != null && _cardRect != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: TourConnectorPainter(
                            cardRect: _cardRect!,
                            targetRect: targetRect,
                            textDirection: Directionality.of(context),
                            style: style,
                            pulse: pulse,
                          ),
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
                    key: _cardKey,
                    state: widget.state,
                    targetRect: targetRect,
                    style: style,
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

  void _scheduleCardRectUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _cardKey.currentContext;
      final renderObject = context?.findRenderObject();
      if (renderObject is! RenderBox ||
          !renderObject.attached ||
          !renderObject.hasSize) {
        return;
      }
      final topLeft = renderObject.localToGlobal(Offset.zero);
      final nextRect = topLeft & renderObject.size;
      if (_cardRect == nextRect) return;
      setState(() {
        _cardRect = nextRect;
      });
    });
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
    super.key,
    required this.state,
    required this.targetRect,
    required this.style,
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
  final TourSurfaceStyle style;
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
            child: ClipRRect(
              borderRadius: style.cardRadius,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: style.cardColor,
                  borderRadius: style.cardRadius,
                  border: Border.all(color: style.cardBorderColor),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      color: Colors.black.withValues(alpha: 0.24),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    PositionedDirectional(
                      top: -34,
                      end: -24,
                      child: _LiquidAccent(style: style),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            stepCount,
                            style: TextStyle(
                              color: style.mutedTextColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: TextStyle(
                              color: style.textColor,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            body,
                            style: TextStyle(
                              color: style.textColor,
                              height: 1.38,
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
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                ),
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
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 40),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    child: Text(l10n.guidedTourBack),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    onPressed: state.isPersisting
                                        ? null
                                        : state.isLastStep
                                        ? onDone
                                        : onNext,
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(0, 40),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                    ),
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
    final belowTarget =
        rect.center.dy < screenHeight / 2 ||
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
    final aboveTarget =
        rect.center.dy >= screenHeight / 2 ||
        state.activeStep?.placement == GuidedTourPlacement.above;
    if (!aboveTarget ||
        state.activeStep?.placement == GuidedTourPlacement.below) {
      return null;
    }
    return math.max(screenHeight - rect.top + 16, 16);
  }
}

class _LiquidAccent extends StatelessWidget {
  const _LiquidAccent({required this.style});

  final TourSurfaceStyle style;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(118, 86),
        painter: _LiquidAccentPainter(style),
      ),
    );
  }
}

class _LiquidAccentPainter extends CustomPainter {
  const _LiquidAccentPainter(this.style);

  final TourSurfaceStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          style.primaryAccent.withValues(alpha: 0.20),
          style.secondaryAccent.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.08),
        ],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.44)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.02,
        size.width * 0.73,
        -size.height * 0.10,
        size.width * 0.86,
        size.height * 0.24,
      )
      ..cubicTo(
        size.width * 1.08,
        size.height * 0.82,
        size.width * 0.44,
        size.height * 1.03,
        size.width * 0.22,
        size.height * 0.78,
      )
      ..cubicTo(
        -size.width * 0.08,
        size.height * 0.46,
        size.width * 0.08,
        size.height * 0.40,
        size.width * 0.18,
        size.height * 0.44,
      )
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(size.width * 0.24, size.height * 0.70),
      8,
      Paint()..color = style.primaryAccent.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidAccentPainter oldDelegate) {
    return oldDelegate.style != style;
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
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
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
