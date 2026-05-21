import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses_tracker/ai/models/models.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import '../widgets/interstitial_ad_gate.dart';

part 'monetization_state.dart';

class MonetizationCubit extends Cubit<MonetizationState> {
  MonetizationCubit({
    required EntitlementRepository entitlementRepository,
    required MonetizationPolicyRepository policyRepository,
    AdConsentService? consentService,
    AdService? adService,
    PurchaseService? purchaseService,
    FeatureGateService featureGateService = const FeatureGateService(),
  })  : _entitlementRepository = entitlementRepository,
        _policyRepository = policyRepository,
        _consentService = consentService ?? FakeAdConsentService(),
        _adService = adService ?? FakeAdService(),
        _purchaseService = purchaseService ?? const DisabledPurchaseService(),
        _featureGateService = featureGateService,
        super(MonetizationState.initial());

  final EntitlementRepository _entitlementRepository;
  final MonetizationPolicyRepository _policyRepository;
  final AdConsentService _consentService;
  final AdService _adService;
  final PurchaseService _purchaseService;
  final FeatureGateService _featureGateService;

  Future<void> load() async {
    emit(state.copyWith(status: MonetizationLoadStatus.loading));
    try {
      final policy = await _policyRepository.getPolicy();
      final entitlement = await _entitlementRepository.getEntitlement();
      final quotaPolicy = policy.quotaFor(
        entitlement.isPremiumActive ? PlanTier.premium : PlanTier.free,
      );
      final usage = _defaultUsage(quotaPolicy);
      var consent = state.consent;
      var adsInitialized = false;

      if (!entitlement.shouldDisableAds) {
        consent = await _consentService.requestConsentInfoUpdate();
        if (consent.canRequestAds) {
          await _adService.initialize();
          adsInitialized = _adService.isInitialized;
        }
      } else {
        await _adService.shutdown();
      }

      emit(
        state.copyWith(
          status: entitlement.status == EntitlementStatus.unavailable
              ? MonetizationLoadStatus.entitlementUnavailable
              : MonetizationLoadStatus.ready,
          entitlement: entitlement,
          policy: policy,
          quotaUsage: usage,
          consent: consent,
          adsInitialized: adsInitialized,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MonetizationLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refreshEntitlement() async {
    try {
      final entitlement = await _entitlementRepository.refreshEntitlement();
      emit(
        state.copyWith(
          entitlement: entitlement,
          status: entitlement.status == EntitlementStatus.unavailable
              ? MonetizationLoadStatus.entitlementUnavailable
              : state.status,
          clearError: true,
        ),
      );
      await load();
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<PurchaseVerificationResult> verifyPurchaseWithBackend(
    PurchaseVerificationRequest request,
  ) async {
    emit(state.copyWith(status: MonetizationLoadStatus.loading));
    try {
      final result = await _entitlementRepository.verifyPurchase(request);
      await _applyVerificationResult(result);
      return result;
    } catch (error) {
      emit(
        state.copyWith(
          status: MonetizationLoadStatus.entitlementUnavailable,
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<PurchaseVerificationResult> restoreEntitlementFromBackend(
    EntitlementRestoreRequest request,
  ) async {
    emit(state.copyWith(status: MonetizationLoadStatus.loading));
    try {
      final result = await _entitlementRepository.restoreEntitlement(request);
      await _applyVerificationResult(result);
      return result;
    } catch (error) {
      emit(
        state.copyWith(
          status: MonetizationLoadStatus.entitlementUnavailable,
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    }
  }

  void updateUsage(AiUsageStatus status) {
    final quotaPolicy = state.policy.quotaFor(
      state.entitlement.isPremiumActive ? PlanTier.premium : PlanTier.free,
    );
    final usage = Map<AiUsageRequestType, AiQuotaUsage>.from(state.quotaUsage);
    usage[status.requestType] = AiQuotaUsage.fromStatus(
      status,
      policy: quotaPolicy,
      rewardedCreditsAvailable:
          usage[status.requestType]?.rewardedCreditsAvailable ?? 0,
    );
    emit(state.copyWith(quotaUsage: usage));
  }

  void markUsageStale(AiUsageRequestType requestType) {
    final quotaPolicy = state.policy.quotaFor(
      state.entitlement.isPremiumActive ? PlanTier.premium : PlanTier.free,
    );
    final usage = Map<AiUsageRequestType, AiQuotaUsage>.from(state.quotaUsage);
    final current = usage[requestType] ??
        AiQuotaUsage.defaultFor(
          requestType: requestType,
          policy: quotaPolicy,
        );
    usage[requestType] = current.copyWith(isStale: true);
    emit(state.copyWith(quotaUsage: usage));
  }

  Future<PurchaseResult> buyPremium({String? productId}) async {
    final result = await _purchaseService.buyPremium(
      productId ?? DisabledPurchaseService.premiumMonthlyProductId,
    );
    emit(state.copyWith(purchaseMessage: result.message));
    return result;
  }

  Future<PurchaseResult> restorePurchases() async {
    final result = await _purchaseService.restorePurchases();
    emit(state.copyWith(purchaseMessage: result.message));
    return result;
  }

  Future<bool> showPrivacyOptions() async {
    try {
      await _consentService.showPrivacyOptions();
      return true;
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
      return false;
    }
  }

  bool shouldReserveBanner(AdPlacementKey placementKey) {
    return _featureGateService.shouldReserveBanner(
      entitlement: state.entitlement,
      consent: state.consent,
      policy: state.policy,
      placementKey: placementKey,
    );
  }

  bool canShowInterstitial(AdPlacementKey placementKey, {String? routeName}) {
    return _featureGateService.canShowInterstitial(
      entitlement: state.entitlement,
      consent: state.consent,
      policy: state.policy,
      placementKey: placementKey,
      frequencyState: state.frequencyState,
      now: DateTime.now(),
      routeName: routeName,
    );
  }

  Future<bool> maybeShowInterstitial(
    AdPlacementKey placementKey, {
    String? routeName,
  }) async {
    final now = DateTime.now();
    final nextFrequencyState = await InterstitialAdGate(
      adService: _adService,
      featureGateService: _featureGateService,
    ).maybeShow(
      entitlement: state.entitlement,
      consent: state.consent,
      policy: state.policy,
      frequencyState: state.frequencyState,
      placementKey: placementKey,
      now: now,
      routeName: routeName,
    );
    if (nextFrequencyState == state.frequencyState) return false;
    emit(state.copyWith(frequencyState: nextFrequencyState));
    return true;
  }

  Future<bool> recordCompletedSaveAndMaybeShowInterstitial({
    String? routeName,
  }) async {
    emit(
      state.copyWith(
        frequencyState: state.frequencyState.recordCompletedSave(),
      ),
    );
    return maybeShowInterstitial(
      AdPlacementKey.postSaveInterstitial,
      routeName: routeName,
    );
  }

  Future<RewardedAdCredit?> requestRewardedCredit(
    AiUsageRequestType requestType,
  ) async {
    final canGrant = _featureGateService.canGrantRewardedCredit(
      entitlement: state.entitlement,
      consent: state.consent,
      policy: state.policy,
      frequencyState: state.frequencyState,
      requestType: requestType,
    );
    if (!canGrant) return null;

    if (!_adService.isInitialized) {
      await _adService.initialize();
    }

    final loaded = await _adService.loadRewarded(AdPlacementKey.aiRewarded);
    if (!loaded) return null;

    String? adEventId;
    final shown = await _adService.showRewarded(
      placementKey: AdPlacementKey.aiRewarded,
      onRewardEarned: (eventId) => adEventId = eventId,
    );
    if (!shown || adEventId == null) return null;

    final now = DateTime.now();
    final credit = RewardedAdCredit(
      id: const Uuid().v1(),
      requestType: requestType,
      grantedAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
      sourceAdEventId: adEventId!,
    );
    final usage = Map<AiUsageRequestType, AiQuotaUsage>.from(state.quotaUsage);
    final current = usage[requestType] ??
        AiQuotaUsage.defaultFor(
          requestType: requestType,
          policy: state.policy.freeQuota,
        );
    usage[requestType] = current.copyWith(
      rewardedCreditsAvailable: current.rewardedCreditsAvailable + 1,
    );
    emit(
      state.copyWith(
        frequencyState: state.frequencyState.recordRewardedCredit(),
        rewardedCredits: [...state.rewardedCredits, credit],
        quotaUsage: usage,
      ),
    );
    return credit;
  }

  Map<AiUsageRequestType, AiQuotaUsage> _defaultUsage(
    AiQuotaPolicy quotaPolicy,
  ) {
    return {
      for (final type in AiUsageRequestType.values)
        type: AiQuotaUsage.defaultFor(requestType: type, policy: quotaPolicy),
    };
  }

  Future<void> _applyVerificationResult(
    PurchaseVerificationResult result,
  ) async {
    final entitlement = result.snapshot;
    emit(
      state.copyWith(
        status: entitlement.status == EntitlementStatus.unavailable
            ? MonetizationLoadStatus.entitlementUnavailable
            : MonetizationLoadStatus.ready,
        entitlement: entitlement,
        purchaseMessage: result.recoveryMessage,
        errorMessage: result.errorCode,
        clearError: result.errorCode == null,
      ),
    );
    await load();
  }
}
