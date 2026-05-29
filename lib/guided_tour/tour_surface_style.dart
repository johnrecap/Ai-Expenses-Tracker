import 'package:flutter/material.dart';

class TourSurfaceStyle {
  const TourSurfaceStyle({
    required this.overlayColor,
    required this.cardColor,
    required this.cardBorderColor,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.connectorColor,
    required this.connectorGlowColor,
    required this.textColor,
    required this.mutedTextColor,
    required this.cardRadius,
  });

  final Color overlayColor;
  final Color cardColor;
  final Color cardBorderColor;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color connectorColor;
  final Color connectorGlowColor;
  final Color textColor;
  final Color mutedTextColor;
  final BorderRadius cardRadius;

  factory TourSurfaceStyle.from(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primary = scheme.primary;
    final secondary = scheme.tertiary;

    return TourSurfaceStyle(
      overlayColor: Colors.black.withValues(alpha: isDark ? 0.72 : 0.68),
      cardColor: scheme.surface,
      cardBorderColor: primary.withValues(alpha: isDark ? 0.34 : 0.22),
      primaryAccent: primary,
      secondaryAccent: secondary,
      connectorColor: primary,
      connectorGlowColor: primary.withValues(alpha: 0.22),
      textColor: scheme.onSurface,
      mutedTextColor: scheme.onSurfaceVariant,
      cardRadius: BorderRadius.circular(18),
    );
  }
}
