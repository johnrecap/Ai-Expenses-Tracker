import 'package:expenses_tracker/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

class FinanceCard extends StatelessWidget {
  const FinanceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.onTap,
    this.leadingAccent,
    this.semanticLabel,
    this.width,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.animate = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? leadingAccent;
  final String? semanticLabel;
  final double? width;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? borderColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final card = SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null
              ? backgroundColor ?? colorScheme.surface
              : null,
          gradient: gradient,
          borderRadius: AppRadii.card,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!.withValues(alpha: 0.55)),
          boxShadow: AppShadows.card(colorScheme.shadow),
        ),
        child: ClipRRect(
          borderRadius: AppRadii.card,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (leadingAccent != null)
                  SizedBox(
                    width: AppSpacing.xs,
                    child: ColoredBox(color: leadingAccent!),
                  ),
                Expanded(
                  child: Padding(padding: padding, child: child),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final content = Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: onTap == null
          ? card
          : InkWell(borderRadius: AppRadii.card, onTap: onTap, child: card),
    );

    final spaced = margin == null
        ? content
        : Padding(padding: margin!, child: content);
    if (!animate) return spaced;
    return _CardEntranceMotion(child: spaced);
  }
}

class _CardEntranceMotion extends StatefulWidget {
  const _CardEntranceMotion({required this.child});

  final Widget child;

  @override
  State<_CardEntranceMotion> createState() => _CardEntranceMotionState();
}

class _CardEntranceMotionState extends State<_CardEntranceMotion> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.035),
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
