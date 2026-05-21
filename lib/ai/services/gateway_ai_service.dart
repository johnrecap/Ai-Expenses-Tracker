import 'dart:convert';

import '../models/ai_response.dart';
import 'ai_gateway_client.dart';
import 'ai_response_parser.dart';
import 'ai_service.dart';

class GatewayAiService implements AiService {
  const GatewayAiService({
    required AiGatewayClient client,
  }) : _client = client;

  final AiGatewayClient _client;

  @override
  Future<AiResponse> parseExpenseText(String input, AiContext context) async {
    final result = await _client.parse(input, context);
    final response = AiResponseParser.parse(
      result.structuredJson,
      now: context.now,
    );
    return response.copyWith(
      providerMetadata: result.metadata,
      usageStatus: result.usageStatus,
      rawJson: result.structuredJson,
    );
  }

  String normalizeStructuredJson(Object value) {
    return value is String ? value : jsonEncode(value);
  }
}
