import { initializeApp } from "firebase-admin/app";
import { onRequest } from "firebase-functions/v2/https";
import { handleFinancialAdvice } from "./ai/financialAdvice.js";
import { handleParseExpense } from "./ai/parseExpense.js";
import { handleReceiptExtraction } from "./ai/receiptExtraction.js";

initializeApp();

export const aiParse = onRequest({ cors: true }, async (request, response) => {
  const result = await handleParseExpense(
    request.body,
    request.header("authorization"),
  );
  response.status(result.status).json(result.body);
});

export const aiReceipt = onRequest({ cors: true }, async (request, response) => {
  const result = await handleReceiptExtraction(
    request.body,
    request.header("authorization"),
  );
  response.status(result.status).json(result.body);
});

export const aiAdvice = onRequest({ cors: true }, async (request, response) => {
  const result = await handleFinancialAdvice(
    request.body,
    request.header("authorization"),
  );
  response.status(result.status).json(result.body);
});
