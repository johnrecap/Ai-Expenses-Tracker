import { WorkerEnv } from "./config";
import { handleFinancialAdvice } from "./handlers/financialAdvice";
import { handleParseExpense } from "./handlers/parseExpense";
import { handleReceiptExtraction } from "./handlers/receiptExtraction";
import { handleOptions } from "./http/cors";
import { jsonResponse } from "./http/response";

export default {
  async fetch(
    request: Request,
    env: WorkerEnv,
    ctx: ExecutionContext,
  ): Promise<Response> {
    if (request.method === "OPTIONS") {
      return handleOptions();
    }

    const path = new URL(request.url).pathname.replace(/\/+$/, "");
    if (path.endsWith("/aiParse")) {
      return handleParseExpense(request, env, ctx);
    }
    if (path.endsWith("/aiReceipt")) {
      return handleReceiptExtraction(request, env, ctx);
    }
    if (path.endsWith("/aiAdvice")) {
      return handleFinancialAdvice(request, env, ctx);
    }

    return jsonResponse(
      {
        ok: false,
        provider: "gemini",
        model: "gemini-2.5-flash",
        requestId: crypto.randomUUID(),
        errorCode: "invalid_request",
        errorMessage: "Unknown AI gateway endpoint.",
      },
      404,
    );
  },
};
