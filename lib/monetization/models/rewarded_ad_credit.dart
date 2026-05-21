import 'package:equatable/equatable.dart';
import 'package:expenses_tracker/ai/models/models.dart';

class RewardedAdCredit extends Equatable {
  const RewardedAdCredit({
    required this.id,
    required this.requestType,
    required this.grantedAt,
    required this.expiresAt,
    required this.sourceAdEventId,
    this.consumedAt,
  });

  final String id;
  final AiUsageRequestType requestType;
  final DateTime grantedAt;
  final DateTime expiresAt;
  final String sourceAdEventId;
  final DateTime? consumedAt;

  bool get isAvailable {
    final now = DateTime.now();
    return consumedAt == null && expiresAt.isAfter(now);
  }

  RewardedAdCredit markConsumed(DateTime consumedAt) {
    return RewardedAdCredit(
      id: id,
      requestType: requestType,
      grantedAt: grantedAt,
      expiresAt: expiresAt,
      sourceAdEventId: sourceAdEventId,
      consumedAt: consumedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requestType,
        grantedAt,
        expiresAt,
        sourceAdEventId,
        consumedAt,
      ];
}
