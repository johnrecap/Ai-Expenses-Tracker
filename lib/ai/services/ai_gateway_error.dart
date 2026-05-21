import '../models/ai_usage_status.dart';

enum AiGatewayErrorCode {
  unauthenticated('unauthenticated'),
  quotaExceeded('quota_exceeded'),
  rateLimited('rate_limited'),
  providerTimeout('provider_timeout'),
  providerUnavailable('provider_unavailable'),
  invalidProviderOutput('invalid_provider_output'),
  gatewayMisconfigured('gateway_misconfigured'),
  invalidRequest('invalid_request'),
  networkFailure('network_failure'),
  unknown('unknown');

  const AiGatewayErrorCode(this.value);

  final String value;

  static AiGatewayErrorCode fromValue(String? value) {
    for (final code in AiGatewayErrorCode.values) {
      if (code.value == value) return code;
    }
    return AiGatewayErrorCode.unknown;
  }
}

enum AiQuotaErrorCategory {
  unclearInput,
  missingFields,
  quotaExhausted,
  providerUnavailable,
  network,
  unauthorized,
  unsupported,
  unknown,
}

class AiGatewayException implements Exception {
  const AiGatewayException({
    required this.code,
    required this.message,
    this.provider,
    this.model,
    this.requestId,
    this.usageStatus,
  });

  final AiGatewayErrorCode code;
  final String message;
  final String? provider;
  final String? model;
  final String? requestId;
  final AiUsageStatus? usageStatus;

  AiQuotaError get quotaError => AiQuotaError.fromGatewayException(this);

  String get userMessage {
    switch (code) {
      case AiGatewayErrorCode.unauthenticated:
        return 'Please sign in again before using the AI Assistant.';
      case AiGatewayErrorCode.quotaExceeded:
        final reset = usageStatus?.resetAt;
        final resetText =
            reset == null ? '' : ' Resets around ${_formatLocalTime(reset)}.';
        return 'Daily AI limit reached. AI usage limit reached for this request.$resetText Manual expense entry is still available.';
      case AiGatewayErrorCode.rateLimited:
        return 'AI is temporarily unavailable. Try again shortly or add the expense manually.';
      case AiGatewayErrorCode.providerTimeout:
        return 'AI is temporarily unavailable. Try again or add the expense manually.';
      case AiGatewayErrorCode.providerUnavailable:
        return 'AI is temporarily unavailable. Add the expense manually or try later.';
      case AiGatewayErrorCode.networkFailure:
        return 'Network connection failed. Check your connection or add the expense manually.';
      case AiGatewayErrorCode.invalidProviderOutput:
        return 'The AI response was not clear enough. Please add more details or enter the expense manually.';
      case AiGatewayErrorCode.gatewayMisconfigured:
        return 'AI gateway is not configured. Use manual entry or enable the development gateway.';
      case AiGatewayErrorCode.invalidRequest:
        return 'The AI request was incomplete. Please add the missing details and try again.';
      case AiGatewayErrorCode.unknown:
        return message;
    }
  }

  @override
  String toString() => userMessage;
}

class AiQuotaError {
  const AiQuotaError({
    required this.category,
    required this.safeMessage,
    this.requestType,
    this.resetAt,
  });

  final AiQuotaErrorCategory category;
  final String safeMessage;
  final AiUsageRequestType? requestType;
  final DateTime? resetAt;

  factory AiQuotaError.fromGatewayException(AiGatewayException error) {
    return AiQuotaError(
      category: _categoryFor(error.code),
      safeMessage: error.userMessage,
      requestType: error.usageStatus?.requestType,
      resetAt: error.usageStatus?.resetAt,
    );
  }

  static AiQuotaErrorCategory _categoryFor(AiGatewayErrorCode code) {
    switch (code) {
      case AiGatewayErrorCode.unauthenticated:
        return AiQuotaErrorCategory.unauthorized;
      case AiGatewayErrorCode.quotaExceeded:
        return AiQuotaErrorCategory.quotaExhausted;
      case AiGatewayErrorCode.rateLimited:
      case AiGatewayErrorCode.providerTimeout:
      case AiGatewayErrorCode.providerUnavailable:
      case AiGatewayErrorCode.gatewayMisconfigured:
        return AiQuotaErrorCategory.providerUnavailable;
      case AiGatewayErrorCode.networkFailure:
        return AiQuotaErrorCategory.network;
      case AiGatewayErrorCode.invalidProviderOutput:
        return AiQuotaErrorCategory.unclearInput;
      case AiGatewayErrorCode.invalidRequest:
        return AiQuotaErrorCategory.missingFields;
      case AiGatewayErrorCode.unknown:
        return AiQuotaErrorCategory.unknown;
    }
  }
}

String _formatLocalTime(DateTime value) {
  final local = value.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
