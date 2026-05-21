import 'dart:typed_data';

import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps quota exhaustion to a non-blocking fallback status', () {
    final status = const AiUsageFallbackService().fromGatewayError(
      const AiGatewayException(
        code: AiGatewayErrorCode.quotaExceeded,
        message: 'Daily limit reached.',
      ),
      AiUsageRequestType.financialAdvice,
    );

    expect(status.allowed, false);
    expect(status.fallbackReason, AiFallbackReason.quotaExhausted);
    expect(status.message, contains('AI usage limit'));
  });

  test('financial advice falls back locally when gateway is disabled',
      () async {
    final service = GatewayFinancialAdviceAiService(
      client: AiGatewayClient(
        config: const AiProviderConfig.disabled(),
        tokenProvider: () async => 'token',
      ),
    );

    final advice = await service.requestAdvice(
      period: 'month',
      context: AiContext(now: DateTime(2026, 5, 16)),
    );

    expect(advice.usageStatus?.allowed, false);
    expect(advice.advice, isNotEmpty);
  });

  test('receipt extraction returns unavailable status without payload',
      () async {
    final service = GatewayReceiptAiService(
      client: AiGatewayClient(
        config: const AiProviderConfig.disabled(),
        tokenProvider: () async => 'token',
      ),
    );

    final result = await service.extractReceipt(
      imageBytes: Uint8List.fromList(List<int>.filled(32, 1)),
      mimeType: 'image/jpeg',
      context: AiContext(now: DateTime(2026, 5, 16)),
    );

    expect(result.payload, isNull);
    expect(result.usageStatus?.allowed, false);
  });
}
