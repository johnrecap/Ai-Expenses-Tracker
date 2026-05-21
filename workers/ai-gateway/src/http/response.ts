import {
  AiGatewayError,
  AiGatewayFailure,
  AiGatewayResponse,
  AiGatewaySuccess,
  AiProviderUsage,
  AiQuotaStatus,
  GatewayStructuredJson,
  isAiGatewayError,
} from "../ai/providerTypes";
import { corsHeaders } from "./cors";

export function jsonResponse(body: AiGatewayResponse, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders(),
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

export function successResponse(input: {
  provider: string;
  model: string;
  requestId: string;
  structuredJson: GatewayStructuredJson;
  usage?: AiProviderUsage | undefined;
  quota?: AiQuotaStatus | undefined;
}): Response {
  const body: AiGatewaySuccess = {
    ok: true,
    provider: input.provider,
    model: input.model,
    requestId: input.requestId,
    structuredJson: input.structuredJson,
    ...(input.usage ? { usage: input.usage } : {}),
    ...(input.quota ? { quota: input.quota } : {}),
  };
  return jsonResponse(body, 200);
}

export function errorResponse(input: {
  error: unknown;
  provider?: string | undefined;
  model?: string | undefined;
  requestId: string;
  quota?: AiQuotaStatus | undefined;
}): Response {
  const gatewayError =
    isAiGatewayError(input.error)
      ? input.error
      : new AiGatewayError(
          "provider_unavailable",
          "AI gateway failed. Please try again later.",
          500,
        );
  const body: AiGatewayFailure = {
    ok: false,
    provider: input.provider,
    model: input.model,
    requestId: input.requestId,
    errorCode: gatewayError.code,
    errorMessage: gatewayError.message,
    ...(input.quota ? { quota: input.quota } : {}),
  };
  return jsonResponse(body, gatewayError.status);
}
