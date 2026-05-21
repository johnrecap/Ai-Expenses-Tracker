class AiProviderMetadata {
  const AiProviderMetadata({
    required this.provider,
    required this.model,
    this.requestId,
    this.inputTokens,
    this.outputTokens,
  });

  final String provider;
  final String model;
  final String? requestId;
  final int? inputTokens;
  final int? outputTokens;

  factory AiProviderMetadata.fromJson(Map<String, dynamic> json) {
    final usage = json['usage'];
    final usageMap = usage is Map ? Map<String, dynamic>.from(usage) : const {};
    return AiProviderMetadata(
      provider: _readString(json['provider']) ?? 'unknown',
      model: _readString(json['model']) ?? 'unknown',
      requestId: _readString(json['requestId']),
      inputTokens: _readInt(usageMap['inputTokens']),
      outputTokens: _readInt(usageMap['outputTokens']),
    );
  }

  Map<String, Object?> toLogFields() {
    return {
      'provider': provider,
      'model': model,
      'providerRequestId': requestId,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
    };
  }

  static String? _readString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
