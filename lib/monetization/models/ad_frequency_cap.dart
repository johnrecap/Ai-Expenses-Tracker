import 'package:equatable/equatable.dart';

class AdFrequencyCap extends Equatable {
  const AdFrequencyCap({
    this.minimumInterstitialInterval = const Duration(minutes: 10),
    this.maxInterstitialsPerSession = 3,
    this.postSaveExpenseThreshold = 5,
    this.maxRewardedCreditsPerDay = 3,
  });

  final Duration minimumInterstitialInterval;
  final int maxInterstitialsPerSession;
  final int postSaveExpenseThreshold;
  final int maxRewardedCreditsPerDay;

  static const defaults = AdFrequencyCap();

  @override
  List<Object?> get props => [
        minimumInterstitialInterval,
        maxInterstitialsPerSession,
        postSaveExpenseThreshold,
        maxRewardedCreditsPerDay,
      ];
}

class AdFrequencyState extends Equatable {
  const AdFrequencyState({
    this.interstitialsShownThisSession = 0,
    this.completedSavesSinceInterstitial = 0,
    this.rewardedCreditsGrantedToday = 0,
    this.lastInterstitialShownAt,
  });

  final int interstitialsShownThisSession;
  final int completedSavesSinceInterstitial;
  final int rewardedCreditsGrantedToday;
  final DateTime? lastInterstitialShownAt;

  bool canShowInterstitial({
    required DateTime now,
    required AdFrequencyCap cap,
    int requiredCompletedActions = 0,
  }) {
    if (interstitialsShownThisSession >= cap.maxInterstitialsPerSession) {
      return false;
    }
    if (completedSavesSinceInterstitial < requiredCompletedActions) {
      return false;
    }
    final last = lastInterstitialShownAt;
    if (last == null) return true;
    return now.difference(last) >= cap.minimumInterstitialInterval;
  }

  bool canGrantRewardedCredit(AdFrequencyCap cap) {
    return rewardedCreditsGrantedToday < cap.maxRewardedCreditsPerDay;
  }

  AdFrequencyState recordInterstitial(DateTime now) {
    return AdFrequencyState(
      interstitialsShownThisSession: interstitialsShownThisSession + 1,
      completedSavesSinceInterstitial: 0,
      rewardedCreditsGrantedToday: rewardedCreditsGrantedToday,
      lastInterstitialShownAt: now,
    );
  }

  AdFrequencyState recordCompletedSave() {
    return AdFrequencyState(
      interstitialsShownThisSession: interstitialsShownThisSession,
      completedSavesSinceInterstitial: completedSavesSinceInterstitial + 1,
      rewardedCreditsGrantedToday: rewardedCreditsGrantedToday,
      lastInterstitialShownAt: lastInterstitialShownAt,
    );
  }

  AdFrequencyState recordRewardedCredit() {
    return AdFrequencyState(
      interstitialsShownThisSession: interstitialsShownThisSession,
      completedSavesSinceInterstitial: completedSavesSinceInterstitial,
      rewardedCreditsGrantedToday: rewardedCreditsGrantedToday + 1,
      lastInterstitialShownAt: lastInterstitialShownAt,
    );
  }

  @override
  List<Object?> get props => [
        interstitialsShownThisSession,
        completedSavesSinceInterstitial,
        rewardedCreditsGrantedToday,
        lastInterstitialShownAt,
      ];
}
