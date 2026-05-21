import '../models/ai_response.dart';
import 'ai_response_parser.dart';
import 'ai_service.dart';

typedef RemoteAiStructuredRequest = Future<String> Function(
  String input,
  AiContext context,
);

class RemoteAiService implements AiService {
  const RemoteAiService({
    required RemoteAiStructuredRequest request,
  }) : _request = request;

  final RemoteAiStructuredRequest _request;

  @override
  Future<AiResponse> parseExpenseText(String input, AiContext context) async {
    final structuredJson = await _request(input, context);
    return AiResponseParser.parse(structuredJson, now: context.now);
  }

  Future<String> requestStructuredJson(String input, AiContext context) {
    return _request(input, context);
  }
}
