import '../repository_runtime_mode.dart';

class VpsApiConfig {
  static const environmentKey = 'VPS_API_BASE_URL';

  final Uri? baseUri;

  const VpsApiConfig({
    required this.baseUri,
  });

  factory VpsApiConfig.fromEnvironment({
    String value = const String.fromEnvironment(environmentKey),
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const VpsApiConfig(baseUri: null);
    }
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      throw StateError(
        '$environmentKey must be an absolute URL when provided.',
      );
    }
    return VpsApiConfig(baseUri: _withTrailingSlash(parsed));
  }

  Uri requireForMode(RepositoryRuntimeMode mode) {
    if (baseUri != null) return baseUri!;
    if (mode == RepositoryRuntimeMode.firebaseLegacy) {
      throw StateError(
        '$environmentKey is not available in firebaseLegacy mode.',
      );
    }
    throw StateError(
      '$environmentKey is required when REPOSITORY_RUNTIME_MODE is ${mode.name}.',
    );
  }

  static Uri _withTrailingSlash(Uri uri) {
    final text = uri.toString();
    return text.endsWith('/') ? uri : Uri.parse('$text/');
  }
}
