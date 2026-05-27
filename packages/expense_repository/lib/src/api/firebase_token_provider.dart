import '../auth/auth_repository.dart';

class RepositoryFirebaseTokenProvider {
  final AuthRepository authRepository;

  const RepositoryFirebaseTokenProvider({
    required this.authRepository,
  });

  Future<String?> call() {
    return authRepository.getIdToken();
  }
}
