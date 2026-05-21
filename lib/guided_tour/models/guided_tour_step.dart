import 'package:expenses_tracker/l10n/l10n.dart';

typedef GuidedTourTextBuilder = String Function(AppLocalizations l10n);

enum GuidedTourPlacement {
  automatic,
  above,
  below,
}

enum SpotlightShape {
  circle,
  roundedRectangle,
}

class GuidedTourStep {
  const GuidedTourStep({
    required this.stepId,
    required this.targetId,
    required this.titleBuilder,
    required this.bodyBuilder,
    this.placement = GuidedTourPlacement.automatic,
    this.canSkipIfMissing = true,
  });

  final String stepId;
  final String targetId;
  final GuidedTourTextBuilder titleBuilder;
  final GuidedTourTextBuilder bodyBuilder;
  final GuidedTourPlacement placement;
  final bool canSkipIfMissing;

  String title(AppLocalizations l10n) => titleBuilder(l10n);

  String body(AppLocalizations l10n) => bodyBuilder(l10n);
}
