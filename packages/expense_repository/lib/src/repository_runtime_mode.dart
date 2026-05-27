enum RepositoryRuntimeMode {
  firebaseLegacy,
  vpsLocalFirst,
  migrationComparison;

  static const environmentKey = 'REPOSITORY_RUNTIME_MODE';

  static RepositoryRuntimeMode fromEnvironment({
    String value = const String.fromEnvironment(
      environmentKey,
      defaultValue: 'firebaseLegacy',
    ),
  }) {
    switch (value.trim()) {
      case 'vpsLocalFirst':
      case 'vps':
        return RepositoryRuntimeMode.vpsLocalFirst;
      case 'migrationComparison':
      case 'comparison':
        return RepositoryRuntimeMode.migrationComparison;
      case 'firebaseLegacy':
      case 'firebase':
      case '':
        return RepositoryRuntimeMode.firebaseLegacy;
      default:
        throw UnsupportedError('Unknown repository runtime mode: $value');
    }
  }

  bool get usesFirebasePrimary => this == RepositoryRuntimeMode.firebaseLegacy;
}
