import 'dart:convert';

import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GatewayAiService serviceFor(Object structuredJson) {
    return GatewayAiService(
      client: AiGatewayClient(
        config: AiProviderConfig.gateway(gatewayUrl: 'https://example.test/ai'),
        tokenProvider: () async => 'token',
        sender: (uri, headers, body, timeout) async {
          return AiGatewayHttpResponse(
            statusCode: 200,
            body: jsonEncode({
              'ok': true,
              'provider': 'gemini',
              'model': 'gemini-2.5-flash',
              'requestId': 'request-1',
              'structuredJson': structuredJson,
            }),
          );
        },
      ),
    );
  }

  test('returns parsed AiResponse with provider metadata', () async {
    final response = await serviceFor({
      'intent': 'add_expense',
      'amount': 250,
      'category': 'Food',
      'date': 'yesterday',
      'paymentMethod': 'Cash',
      'currency': 'EGP',
      'description': 'Food',
      'confidence': 0.92,
      'needsConfirmation': true,
    }).parseExpenseText(
      'spent 250 yesterday',
      AiContext(now: DateTime(2026, 5, 16)),
    );

    expect(response.intent, AiIntent.addExpense);
    expect(response.expensePayload?.date, DateTime(2026, 5, 15));
    expect(response.providerMetadata?.provider, 'gemini');
  });

  test('rejects malformed structuredJson through parser', () async {
    expect(
      () => serviceFor('not-json').parseExpenseText(
        'bad',
        AiContext(now: DateTime(2026, 5, 16)),
      ),
      throwsA(isA<AiResponseParserException>()),
    );
  });

  test('surfaces quota gateway error', () async {
    final service = GatewayAiService(
      client: AiGatewayClient(
        config: AiProviderConfig.gateway(gatewayUrl: 'https://example.test/ai'),
        tokenProvider: () async => 'token',
        sender: (uri, headers, body, timeout) async {
          return AiGatewayHttpResponse(
            statusCode: 429,
            body: jsonEncode({
              'ok': false,
              'errorCode': 'quota_exceeded',
              'errorMessage': 'Daily limit reached.',
            }),
          );
        },
      ),
    );

    expect(
      () => service.parseExpenseText(
        'spent 250',
        AiContext(now: DateTime(2026, 5, 16)),
      ),
      throwsA(isA<AiGatewayException>().having(
        (error) => error.code,
        'code',
        AiGatewayErrorCode.quotaExceeded,
      )),
    );
  });
}
