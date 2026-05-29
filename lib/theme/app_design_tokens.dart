import 'package:flutter/material.dart';

class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  static const Radius sm = Radius.circular(10);
  static const Radius md = Radius.circular(16);
  static const Radius lg = Radius.circular(22);
  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius input = BorderRadius.all(lg);
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
}

class AppBreakpoints {
  static const double compactWidth = 380;
  static const double comfortableWidth = 600;
}

class AppShadows {
  static List<BoxShadow> card(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> soft(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.05),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

class AppToneColors {
  const AppToneColors({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}

enum AppStatusTone { info, success, warning, danger, muted }

class AppSemanticColors {
  static AppToneColors tone(ColorScheme colorScheme, AppStatusTone tone) {
    switch (tone) {
      case AppStatusTone.info:
        return AppToneColors(
          foreground: colorScheme.primary,
          background: colorScheme.primary.withValues(alpha: 0.10),
          border: colorScheme.primary.withValues(alpha: 0.22),
        );
      case AppStatusTone.success:
        return const AppToneColors(
          foreground: Color(0xFF16834A),
          background: Color(0xFFE8F7EF),
          border: Color(0xFFBFE8D1),
        );
      case AppStatusTone.warning:
        return const AppToneColors(
          foreground: Color(0xFF946200),
          background: Color(0xFFFFF5DB),
          border: Color(0xFFFFD98A),
        );
      case AppStatusTone.danger:
        return AppToneColors(
          foreground: colorScheme.error,
          background: colorScheme.error.withValues(alpha: 0.10),
          border: colorScheme.error.withValues(alpha: 0.22),
        );
      case AppStatusTone.muted:
        return AppToneColors(
          foreground: colorScheme.onSurfaceVariant,
          background: colorScheme.surfaceContainerHighest,
          border: colorScheme.outlineVariant,
        );
    }
  }
}

class AppTextStyles {
  static TextStyle? sectionTitle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle? rowTitle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle? amount(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    );
  }

  static TextStyle? caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
  }
}
