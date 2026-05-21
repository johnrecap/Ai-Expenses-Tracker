import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> get user => const Stream.empty();

  @override
  Future<String?> getIdToken() async => 'token';

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AuthActionResult> requestPasswordReset(String email) async {
    return const AuthActionResult.success();
  }

  @override
  Future<AuthActionResult> updateEmail(String newEmail) async {
    return const AuthActionResult.unavailable();
  }

  @override
  Future<AuthActionResult> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    return const AuthActionResult.unavailable();
  }

  @override
  Future<AuthActionResult> reauthenticateWithGoogle() async {
    return const AuthActionResult.unavailable();
  }

  @override
  Future<AuthActionResult> deleteCurrentUser() async {
    return const AuthActionResult.unavailable();
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> updateDisplayName(String displayName) {
    throw UnimplementedError();
  }
}

void main() {
  test('disabled config uses mock service path', () {
    final service = AiServiceFactory.create(
      config: const AiProviderConfig.disabled(),
      authRepository: FakeAuthRepository(),
    );

    expect(service, isA<MockAiService>());
  });

  test('enabled config rejects empty gateway endpoint', () {
    expect(
      () => AiProviderConfig.gateway(gatewayUrl: ' '),
      throwsArgumentError,
    );
  });

  test('gateway config defaults to Gemini 2.5 Flash', () {
    final config = AiProviderConfig.gateway(gatewayUrl: 'https://example.test');

    expect(config.provider, 'gemini');
    expect(config.model, 'gemini-2.5-flash');
    expect(config.enabled, isTrue);
  });

  test('provider config exposes no secret or api key fields', () {
    final config = AiProviderConfig.gateway(gatewayUrl: 'https://example.test');
    final fieldText = config.toString().toLowerCase();

    expect(fieldText.contains('api_key'), isFalse);
    expect(fieldText.contains('secret'), isFalse);
  });
}
