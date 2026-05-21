import 'dart:convert';
import 'dart:io';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extracts structured JSON and provider metadata from gateway response',
      () async {
    late Map<String, Object?> sentBody;
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(gatewayUrl: 'https://example.test/ai'),
      tokenProvider: () async => 'token',
      sender: (uri, headers, body, timeout) async {
        sentBody = body;
        expect(headers['Authorization'], 'Bearer token');
        expect(headers['Content-Type'], 'application/json; charset=utf-8');
        return AiGatewayHttpResponse(
          statusCode: 200,
          body: jsonEncode({
            'ok': true,
            'provider': 'gemini',
            'model': 'gemini-2.5-flash',
            'requestId': 'request-1',
            'usage': {'inputTokens': 12, 'outputTokens': 8},
            'structuredJson': {
              'intent': 'add_expense',
              'amount': 250,
              'category': 'Food',
              'date': '2026-05-15',
              'paymentMethod': 'Cash',
              'currency': 'EGP',
              'description': 'Food',
              'confidence': 0.92,
              'needsConfirmation': true,
            },
          }),
        );
      },
    );

    final result = await client.parse(
      'spent 250',
      AiContext(
        now: DateTime(2026, 5, 16),
        locale: 'ar-EG',
        categories: [
          Category(
            categoryId: 'food',
            name: 'Food',
            totalExpenses: 0,
            icon: 'food',
            color: 0,
          ),
        ],
      ),
    );

    expect(sentBody['input'], 'spent 250');
    expect(sentBody['locale'], 'ar-EG');
    expect(result.metadata.provider, 'gemini');
    expect(result.metadata.model, 'gemini-2.5-flash');
    expect(result.metadata.requestId, 'request-1');
    expect(result.metadata.inputTokens, 12);
    expect(result.structuredJson, contains('"intent":"add_expense"'));
  });

  test('throws normalized gateway error for failed response', () async {
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(gatewayUrl: 'https://example.test/ai'),
      tokenProvider: () async => 'token',
      sender: (uri, headers, body, timeout) async {
        return AiGatewayHttpResponse(
          statusCode: 429,
          body: jsonEncode({
            'ok': false,
            'provider': 'gemini',
            'model': 'gemini-2.5-flash',
            'requestId': 'request-2',
            'errorCode': 'quota_exceeded',
            'errorMessage': 'Daily limit reached.',
          }),
        );
      },
    );

    expect(
      () => client.parse('spent 250', AiContext(now: DateTime(2026, 5, 16))),
      throwsA(
        isA<AiGatewayException>()
            .having(
              (error) => error.code,
              'code',
              AiGatewayErrorCode.quotaExceeded,
            )
            .having((error) => error.requestId, 'requestId', 'request-2'),
      ),
    );
  });

  test('throws quota error with usage metadata from failed response', () async {
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(gatewayUrl: 'https://example.test/ai'),
      tokenProvider: () async => 'token',
      sender: (uri, headers, body, timeout) async {
        return AiGatewayHttpResponse(
          statusCode: 429,
          body: jsonEncode({
            'ok': false,
            'provider': 'gemini',
            'model': 'gemini-2.5-flash',
            'requestId': 'request-quota-error',
            'errorCode': 'quota_exceeded',
            'errorMessage': 'Daily limit reached.',
            'quota': {
              'requestType': 'parse_text',
              'allowed': false,
              'limit': 5,
              'used': 5,
              'remaining': 0,
              'resetAt': '2026-05-18T00:00:00.000Z',
            },
          }),
        );
      },
    );

    expect(
      () => client.parse('spent 250', AiContext(now: DateTime(2026, 5, 17))),
      throwsA(
        isA<AiGatewayException>()
            .having(
              (error) => error.code,
              'code',
              AiGatewayErrorCode.quotaExceeded,
            )
            .having(
              (error) => error.usageStatus?.remaining,
              'remaining',
              0,
            )
            .having(
              (error) => error.quotaError.category,
              'category',
              AiQuotaErrorCategory.quotaExhausted,
            ),
      ),
    );
  });

  test('throws unauthenticated before gateway call when token is missing',
      () async {
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(gatewayUrl: 'https://example.test/ai'),
      tokenProvider: () async => null,
      sender: (uri, headers, body, timeout) async {
        fail('Gateway must not be called without a token.');
      },
    );

    expect(
      () => client.parse('spent 250', AiContext(now: DateTime(2026, 5, 16))),
      throwsA(isA<AiGatewayException>().having(
        (error) => error.code,
        'code',
        AiGatewayErrorCode.unauthenticated,
      )),
    );
  });

  test('maps non-json auth response to authentication error', () async {
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(gatewayUrl: 'https://example.test/ai'),
      tokenProvider: () async => 'expired-token',
      sender: (uri, headers, body, timeout) async {
        return const AiGatewayHttpResponse(
          statusCode: 403,
          body: '<html>Forbidden</html>',
        );
      },
    );

    expect(
      () => client.parse('spent 250', AiContext(now: DateTime(2026, 5, 16))),
      throwsA(
        isA<AiGatewayException>()
            .having(
              (error) => error.code,
              'code',
              AiGatewayErrorCode.unauthenticated,
            )
            .having(
              (error) => error.userMessage,
              'userMessage',
              contains('sign in'),
            ),
      ),
    );
  });

  test('maps provider HTTP failure without quota metadata to unavailable',
      () async {
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(gatewayUrl: 'https://example.test/ai'),
      tokenProvider: () async => 'token',
      sender: (uri, headers, body, timeout) async {
        return const AiGatewayHttpResponse(
          statusCode: 503,
          body: 'provider unavailable',
        );
      },
    );

    expect(
      () => client.parse('spent 250', AiContext(now: DateTime(2026, 5, 16))),
      throwsA(
        isA<AiGatewayException>()
            .having(
              (error) => error.code,
              'code',
              AiGatewayErrorCode.providerUnavailable,
            )
            .having((error) => error.usageStatus, 'usageStatus', isNull),
      ),
    );
  });

  test('default sender posts Arabic JSON as UTF-8', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    try {
      final client = AiGatewayClient(
        config: AiProviderConfig.gateway(
          gatewayUrl: 'http://${server.address.host}:${server.port}/aiParse',
        ),
        tokenProvider: () async => 'token',
      );

      final parseFuture = client.parse(
        'صرفت 100 جنيه امبارح علي المواصلات',
        AiContext(now: DateTime(2026, 5, 17)),
      );
      final request = await server.first;
      final body = utf8.decode(await request.fold<List<int>>(
        <int>[],
        (buffer, chunk) => buffer..addAll(chunk),
      ));

      expect(request.headers.contentType?.charset, 'utf-8');
      expect(body, contains('صرفت 100 جنيه امبارح علي المواصلات'));

      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'ok': true,
          'provider': 'gemini',
          'model': 'gemini-2.5-flash',
          'requestId': 'request-utf8',
          'structuredJson': {
            'intent': 'add_expense',
            'amount': 100,
            'category': 'Transport',
            'date': '2026-05-16',
            'paymentMethod': 'Cash',
            'currency': 'EGP',
            'confidence': 0.9,
            'needsConfirmation': true,
          },
        }));
      await request.response.close();

      final result = await parseFuture;
      expect(result.metadata.requestId, 'request-utf8');
    } finally {
      await server.close(force: true);
    }
  });

  test('replaces aiParse path with receipt and advice endpoint names',
      () async {
    final calledUris = <Uri>[];
    final sentBodies = <Map<String, Object?>>[];
    final context = AiContext(now: DateTime(2026, 5, 16), locale: 'en-US');
    calledUris.clear();
    final localeClient = AiGatewayClient(
      config: AiProviderConfig.gateway(
        gatewayUrl: 'https://example.test/api/aiParse',
      ),
      tokenProvider: () async => 'token',
      sender: (uri, headers, body, timeout) async {
        calledUris.add(uri);
        sentBodies.add(body);
        return AiGatewayHttpResponse(
          statusCode: 200,
          body: jsonEncode({
            'ok': true,
            'provider': 'gemini',
            'model': 'gemini-2.5-flash',
            'requestId': 'request-${calledUris.length}',
            'structuredJson': calledUris.length == 1
                ? {
                    'intent': 'add_expense',
                    'amount': 120,
                    'date': '2026-05-16',
                    'category': 'Food',
                    'currency': 'EGP',
                    'confidence': 0.86,
                    'needsConfirmation': true,
                  }
                : {
                    'period': 'month',
                    'groundedSummary': 'Food is high.',
                    'advice': 'Set a lower restaurant budget.',
                    'categoryDrivers': [],
                    'confidence': 0.9,
                    'needsConfirmation': true,
                  },
          }),
        );
      },
    );
    await localeClient.extractReceipt(
      imageBase64: 'base64-receipt',
      mimeType: 'image/jpeg',
      imageFingerprint: 'receipt-1',
      context: context,
    );
    await localeClient.financialAdvice(
      period: 'month',
      summary: {'total': 500},
      context: context,
    );

    expect(calledUris[0].toString(), 'https://example.test/api/aiReceipt');
    expect(calledUris[1].toString(), 'https://example.test/api/aiAdvice');
    expect(sentBodies[0]['locale'], 'en-US');
    expect(sentBodies[1]['locale'], 'en-US');
  });

  test('uses aiParse endpoint when gateway URL is Worker root', () async {
    late Uri calledUri;
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(
        gatewayUrl: 'https://example.test',
      ),
      tokenProvider: () async => 'token',
      sender: (uri, headers, body, timeout) async {
        calledUri = uri;
        return AiGatewayHttpResponse(
          statusCode: 200,
          body: jsonEncode({
            'ok': true,
            'provider': 'gemini',
            'model': 'gemini-2.5-flash',
            'requestId': 'request-root-url',
            'structuredJson': {
              'intent': 'add_expense',
              'amount': 100,
              'date': '2026-05-16',
              'category': 'Transport',
              'paymentMethod': 'Cash',
              'currency': 'EGP',
              'confidence': 0.9,
              'needsConfirmation': true,
            },
          }),
        );
      },
    );

    await client.parse(
      'spent 100 on transport',
      AiContext(now: DateTime(2026, 5, 16)),
    );

    expect(calledUri.toString(), 'https://example.test/aiParse');
  });

  test('parses Worker quota response and provider metadata', () async {
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(
        gatewayUrl: 'https://example.test/aiParse',
      ),
      tokenProvider: () async => 'token',
      sender: (uri, headers, body, timeout) async {
        return AiGatewayHttpResponse(
          statusCode: 200,
          body: jsonEncode({
            'ok': true,
            'provider': 'gemini',
            'model': 'gemini-2.5-flash',
            'requestId': 'request-quota',
            'usage': {'inputTokens': 14, 'outputTokens': 6},
            'quota': {
              'requestType': 'receipt_extraction',
              'allowed': true,
              'limit': 3,
              'used': 1,
              'remaining': 2,
              'resetAt': '2026-05-17T00:00:00.000Z',
            },
            'structuredJson': {
              'intent': 'add_expense',
              'amount': 90,
              'date': '2026-05-16',
              'category': 'Food',
              'currency': 'EGP',
              'confidence': 0.85,
              'needsConfirmation': true,
            },
          }),
        );
      },
    );

    final result = await client.extractReceipt(
      imageBase64: 'base64-receipt',
      mimeType: 'image/jpeg',
      imageFingerprint: 'receipt-1',
      context: AiContext(now: DateTime(2026, 5, 16)),
    );

    expect(result.metadata.provider, 'gemini');
    expect(result.metadata.requestId, 'request-quota');
    expect(result.metadata.inputTokens, 14);
    expect(result.usageStatus?['remaining'], 2);
  });

  test('parses text quota into typed usage status', () async {
    final client = AiGatewayClient(
      config: AiProviderConfig.gateway(
        gatewayUrl: 'https://example.test/aiParse',
      ),
      tokenProvider: () async => 'token',
      sender: (uri, headers, body, timeout) async {
        return AiGatewayHttpResponse(
          statusCode: 200,
          body: jsonEncode({
            'ok': true,
            'provider': 'gemini',
            'model': 'gemini-2.5-flash',
            'requestId': 'request-text-quota',
            'quota': {
              'requestType': 'parse_text',
              'allowed': true,
              'limit': 5,
              'used': 2,
              'remaining': 3,
              'resetAt': '2026-05-18T00:00:00.000Z',
            },
            'structuredJson': {
              'intent': 'add_expense',
              'amount': 90,
              'date': '2026-05-16',
              'category': 'Food',
              'currency': 'EGP',
              'confidence': 0.85,
              'needsConfirmation': true,
            },
          }),
        );
      },
    );

    final result = await client.parse(
      'spent 90',
      AiContext(now: DateTime(2026, 5, 17)),
    );

    expect(result.usageStatus?.requestType, AiUsageRequestType.parseText);
    expect(result.usageStatus?.remaining, 3);
  });
}
