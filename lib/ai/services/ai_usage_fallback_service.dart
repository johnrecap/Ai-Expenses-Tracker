import '../models/models.dart';
import 'ai_gateway_error.dart';

class AiUsageFallbackService {
  const AiUsageFallbackService();

  AiUsageStatus fromGatewayError(
    AiGatewayException error,
    AiUsageRequestType requestType,
  ) {
    return AiUsageStatus(
      requestType: requestType,
      allowed: false,
      limit: error.usageStatus?.limit,
      used: error.usageStatus?.used,
      remaining: error.usageStatus?.remaining,
      resetAt: error.usageStatus?.resetAt,
      fallbackReason: _reason(error.code),
      message: error.userMessage,
    );
  }

  AiUsageStatus disabled(AiUsageRequestType requestType) {
    return AiUsageStatus(
      requestType: requestType,
      allowed: false,
      fallbackReason: AiFallbackReason.aiDisabled,
      message:
          'AI gateway is not configured. Manual entry and local insights are still available.',
    );
  }

  AiUsageStatus lowConfidence(AiUsageRequestType requestType) {
    return AiUsageStatus(
      requestType: requestType,
      allowed: true,
      fallbackReason: AiFallbackReason.lowConfidence,
      message: 'Review and complete the fields before saving.',
    );
  }

  AiFallbackReason _reason(AiGatewayErrorCode code) {
    switch (code) {
      case AiGatewayErrorCode.quotaExceeded:
        return AiFallbackReason.quotaExhausted;
      case AiGatewayErrorCode.gatewayMisconfigured:
        return AiFallbackReason.aiDisabled;
      case AiGatewayErrorCode.invalidRequest:
        return AiFallbackReason.invalidInput;
      case AiGatewayErrorCode.providerTimeout:
      case AiGatewayErrorCode.providerUnavailable:
      case AiGatewayErrorCode.rateLimited:
      case AiGatewayErrorCode.invalidProviderOutput:
        return AiFallbackReason.providerFailed;
      case AiGatewayErrorCode.networkFailure:
        return AiFallbackReason.functionsUnavailable;
      case AiGatewayErrorCode.unauthenticated:
      case AiGatewayErrorCode.unknown:
        return AiFallbackReason.functionsUnavailable;
    }
  }
}
