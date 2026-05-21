import 'package:equatable/equatable.dart';

class ConsentState extends Equatable {
  const ConsentState({
    required this.canRequestAds,
    required this.privacyOptionsRequired,
    required this.lastUpdatedAt,
    this.statusLabel = 'unknown',
    this.isDebugGeographyEnabled = false,
    this.errorMessage,
  });

  final bool canRequestAds;
  final bool privacyOptionsRequired;
  final DateTime lastUpdatedAt;
  final String statusLabel;
  final bool isDebugGeographyEnabled;
  final String? errorMessage;

  static ConsentState unavailable({String? errorMessage}) {
    return ConsentState(
      canRequestAds: false,
      privacyOptionsRequired: false,
      lastUpdatedAt: DateTime.now(),
      statusLabel: 'unavailable',
      errorMessage: errorMessage,
    );
  }

  static ConsentState allowed({DateTime? updatedAt}) {
    return ConsentState(
      canRequestAds: true,
      privacyOptionsRequired: false,
      lastUpdatedAt: updatedAt ?? DateTime.now(),
      statusLabel: 'allowed',
    );
  }

  @override
  List<Object?> get props => [
        canRequestAds,
        privacyOptionsRequired,
        lastUpdatedAt,
        statusLabel,
        isDebugGeographyEnabled,
        errorMessage,
      ];
}
