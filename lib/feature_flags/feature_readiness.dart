import 'package:expenses_tracker/l10n/l10n.dart';

enum ReadinessState {
  available,
  disabled,
  comingSoon,
  sandboxOnly,
  hidden,
}

enum FeatureSurface {
  premiumPurchase,
  premiumRestore,
  walletManagement,
  transferManagement,
  backupExport,
  restorePreview,
  restoreExecution,
}

class FeatureReadiness {
  const FeatureReadiness({
    required this.surface,
    required this.state,
  });

  final FeatureSurface surface;
  final ReadinessState state;

  bool get isAvailable => state == ReadinessState.available;
  bool get isVisible => state != ReadinessState.hidden;

  static const premiumPurchase = FeatureReadiness(
    surface: FeatureSurface.premiumPurchase,
    state: ReadinessState.disabled,
  );

  static const premiumRestore = FeatureReadiness(
    surface: FeatureSurface.premiumRestore,
    state: ReadinessState.disabled,
  );

  static const walletManagement = FeatureReadiness(
    surface: FeatureSurface.walletManagement,
    state: ReadinessState.comingSoon,
  );

  static const transferManagement = FeatureReadiness(
    surface: FeatureSurface.transferManagement,
    state: ReadinessState.comingSoon,
  );

  static const backupExport = FeatureReadiness(
    surface: FeatureSurface.backupExport,
    state: ReadinessState.comingSoon,
  );

  static const restorePreview = FeatureReadiness(
    surface: FeatureSurface.restorePreview,
    state: ReadinessState.comingSoon,
  );

  static const restoreExecution = FeatureReadiness(
    surface: FeatureSurface.restoreExecution,
    state: ReadinessState.disabled,
  );
}

extension FeatureReadinessCopy on AppLocalizations {
  String readinessTitle(FeatureReadiness readiness) {
    switch (readiness.surface) {
      case FeatureSurface.premiumPurchase:
        return premiumComingSoon;
      case FeatureSurface.premiumRestore:
        return restorePurchases;
      case FeatureSurface.walletManagement:
        return wallets;
      case FeatureSurface.transferManagement:
        return transfers;
      case FeatureSurface.backupExport:
        return backupExportTitle;
      case FeatureSurface.restorePreview:
        return restorePreviewTitle;
      case FeatureSurface.restoreExecution:
        return restoreExecutionTitle;
    }
  }

  String readinessBody(FeatureReadiness readiness) {
    switch (readiness.surface) {
      case FeatureSurface.premiumPurchase:
        return premiumPurchasesDisabledBody;
      case FeatureSurface.premiumRestore:
        return premiumRestoreDisabledBody;
      case FeatureSurface.walletManagement:
        return walletsReadinessBody;
      case FeatureSurface.transferManagement:
        return transfersReadinessBody;
      case FeatureSurface.backupExport:
        return backupExportReadinessBody;
      case FeatureSurface.restorePreview:
        return restorePreviewReadinessBody;
      case FeatureSurface.restoreExecution:
        return restoreExecutionReadinessBody;
    }
  }
}
