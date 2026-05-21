import '../models/models.dart';

abstract class AdConsentService {
  Future<ConsentState> requestConsentInfoUpdate();

  Future<void> showPrivacyOptions();
}

class FakeAdConsentService implements AdConsentService {
  FakeAdConsentService({
    ConsentState? consentState,
    this.showPrivacyOptionsFails = false,
  }) : _consentState = consentState ?? ConsentState.allowed();

  ConsentState _consentState;
  final bool showPrivacyOptionsFails;
  int privacyOptionsOpenCount = 0;

  @override
  Future<ConsentState> requestConsentInfoUpdate() async => _consentState;

  @override
  Future<void> showPrivacyOptions() async {
    if (showPrivacyOptionsFails) {
      throw StateError('Privacy options are unavailable.');
    }
    privacyOptionsOpenCount += 1;
  }

  void setConsentState(ConsentState state) {
    _consentState = state;
  }
}
