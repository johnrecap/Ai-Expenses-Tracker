import 'package:expense_repository/expense_repository.dart';

import 'ai_gateway_client.dart';
import 'ai_provider_config.dart';
import 'ai_service.dart';
import 'gateway_ai_service.dart';
import 'mock_ai_service.dart';

class AiServiceFactory {
  const AiServiceFactory._();

  static AiService create({
    required AiProviderConfig config,
    required AuthRepository authRepository,
  }) {
    if (!config.enabled) return const MockAiService();
    return GatewayAiService(
      client: AiGatewayClient(
        config: config,
        tokenProvider: authRepository.getIdToken,
      ),
    );
  }
}
