class AiProviderConfig {
  const AiProviderConfig({
    required this.enabled,
    required this.gatewayUrl,
    this.provider = 'gemini',
    this.model = 'gemini-2.5-flash',
    this.timeout = const Duration(seconds: 10),
    this.useMockFallback = true,
  });

  final bool enabled;
  final String gatewayUrl;
  final String provider;
  final String model;
  final Duration timeout;
  final bool useMockFallback;

  const AiProviderConfig.disabled()
      : enabled = false,
        gatewayUrl = '',
        provider = 'mock',
        model = 'local-mock',
        timeout = const Duration(seconds: 1),
        useMockFallback = true;

  factory AiProviderConfig.gateway({
    required String gatewayUrl,
    String provider = 'gemini',
    String model = 'gemini-2.5-flash',
    Duration timeout = const Duration(seconds: 10),
    bool useMockFallback = false,
  }) {
    final normalizedUrl = gatewayUrl.trim();
    if (normalizedUrl.isEmpty) {
      throw ArgumentError.value(
        gatewayUrl,
        'gatewayUrl',
        'Enabled AI gateway config requires a non-empty endpoint.',
      );
    }
    return AiProviderConfig(
      enabled: true,
      gatewayUrl: normalizedUrl,
      provider: provider,
      model: model,
      timeout: timeout,
      useMockFallback: useMockFallback,
    );
  }

  factory AiProviderConfig.fromEnvironment() {
    const gatewayUrl = String.fromEnvironment('AI_GATEWAY_URL');
    const provider = String.fromEnvironment(
      'AI_PROVIDER',
      defaultValue: 'gemini',
    );
    const model = String.fromEnvironment(
      'AI_MODEL',
      defaultValue: 'gemini-2.5-flash',
    );
    const timeoutSeconds = int.fromEnvironment(
      'AI_TIMEOUT_SECONDS',
      defaultValue: 10,
    );
    const useMockFallback = bool.fromEnvironment(
      'AI_USE_MOCK_FALLBACK',
      defaultValue: true,
    );

    if (gatewayUrl.trim().isEmpty) {
      return const AiProviderConfig.disabled();
    }
    return AiProviderConfig.gateway(
      gatewayUrl: gatewayUrl,
      provider: provider,
      model: model,
      timeout: const Duration(seconds: timeoutSeconds),
      useMockFallback: useMockFallback,
    );
  }
}
