import 'package:local_auth/local_auth.dart';

abstract class BiometricAuthenticator {
  Future<bool> isSupported();

  Future<bool> authenticate();
}

class BiometricService implements BiometricAuthenticator {
  final LocalAuthentication _localAuthentication;

  BiometricService({
    LocalAuthentication? localAuthentication,
  }) : _localAuthentication = localAuthentication ?? LocalAuthentication();

  @override
  Future<bool> isSupported() async {
    try {
      final deviceSupported = await _localAuthentication.isDeviceSupported();
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final availableBiometrics =
          await _localAuthentication.getAvailableBiometrics();
      return deviceSupported &&
          canCheckBiometrics &&
          availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate() async {
    if (!await isSupported()) return false;

    try {
      return _localAuthentication.authenticate(
        localizedReason: 'Unlock Expense Tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
