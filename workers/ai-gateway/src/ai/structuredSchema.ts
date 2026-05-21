import {
  AiFinancialAdviceStructuredResponse,
  AiGatewayError,
  AiReceiptStructuredResponse,
  AiStructuredResponse,
  CategorySnapshot,
} from "./providerTypes";

export const supportedIntents = [
  "add_expense",
  "update_expense",
  "delete_expense",
  "search_expenses",
  "summarize_expenses",
  "financial_advice",
] as const;

export const paymentMethods = [
  "Cash",
  "Visa",
  "Wallet",
  "Bank Transfer",
] as const;

export const geminiResponseSchema = {
  type: "OBJECT",
  properties: {
    intent: { type: "STRING", enum: [...supportedIntents] },
    amount: { type: "NUMBER" },
    category: { type: "STRING" },
    categoryId: { type: "STRING" },
    date: { type: "STRING" },
    paymentMethod: { type: "STRING", enum: [...paymentMethods] },
    currency: { type: "STRING" },
    description: { type: "STRING" },
    categoryConfidence: { type: "NUMBER" },
    categoryReason: { type: "STRING" },
    suggestedCategoryName: { type: "STRING" },
    suggestedCategoryIcon: { type: "STRING" },
    suggestedCategoryColor: { type: "STRING" },
    query: { type: "STRING" },
    period: { type: "STRING", enum: ["weekly", "monthly", "custom"] },
    startDate: { type: "STRING" },
    endDate: { type: "STRING" },
    periodText: { type: "STRING" },
    focusCategory: { type: "STRING" },
    tone: { type: "STRING" },
    confidence: { type: "NUMBER" },
    needsConfirmation: { type: "BOOLEAN" },
    clarifyingQuestion: { type: "STRING" },
  },
  required: ["intent", "confidence", "needsConfirmation"],
};

export const geminiReceiptResponseSchema = {
  type: "OBJECT",
  properties: {
    intent: { type: "STRING", enum: ["add_expense"] },
    amount: { type: "NUMBER" },
    date: { type: "STRING" },
    merchant: { type: "STRING" },
    category: { type: "STRING" },
    categoryId: { type: "STRING" },
    currency: { type: "STRING" },
    description: { type: "STRING" },
    rawText: { type: "STRING" },
    confidence: { type: "NUMBER" },
    needsConfirmation: { type: "BOOLEAN" },
  },
  required: ["intent", "confidence", "needsConfirmation"],
};

export const geminiAdviceResponseSchema = {
  type: "OBJECT",
  properties: {
    period: { type: "STRING", enum: ["week", "month"] },
    groundedSummary: { type: "STRING" },
    advice: { type: "STRING" },
    categoryDrivers: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          category: { type: "STRING" },
          amount: { type: "NUMBER" },
          currency: { type: "STRING" },
          note: { type: "STRING" },
        },
        required: ["category", "amount"],
      },
    },
    qualityNote: { type: "STRING" },
    confidence: { type: "NUMBER" },
    needsConfirmation: { type: "BOOLEAN" },
  },
  required: [
    "period",
    "groundedSummary",
    "advice",
    "categoryDrivers",
    "confidence",
    "needsConfirmation",
  ],
};

export interface ExpenseResponseNormalizationContext {
  readonly input?: string | undefined;
  readonly now?: string | undefined;
  readonly locale?: string | undefined;
  readonly defaultCurrency?: string | undefined;
  readonly categories?: CategorySnapshot[] | undefined;
}

export function parseStructuredResponse(
  value: unknown,
  context: ExpenseResponseNormalizationContext = {},
): AiStructuredResponse {
  const candidate = parseProviderObject(value);
  if (!supportedIntents.includes(candidate.intent as never)) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output contains unsupported intent.",
      502,
    );
  }
  assertConfidence(candidate.confidence);
  const response = {
    ...candidate,
    intent: candidate.intent as string,
    confidence: candidate.confidence as number,
    needsConfirmation: true,
  } as AiStructuredResponse;
  if (response.intent !== "add_expense") return response;
  return normalizeAddExpenseResponse(response, context);
}

export function parseReceiptResponse(value: unknown): AiReceiptStructuredResponse {
  const candidate = parseProviderObject(value);
  if (candidate.intent !== "add_expense") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Receipt output must use add_expense intent.",
      502,
    );
  }
  assertConfidence(candidate.confidence);
  return {
    ...candidate,
    intent: "add_expense",
    confidence: candidate.confidence as number,
    needsConfirmation: true,
  } as AiReceiptStructuredResponse;
}

export function parseAdviceResponse(
  value: unknown,
): AiFinancialAdviceStructuredResponse {
  const candidate = parseProviderObject(value);
  if (candidate.period !== "week" && candidate.period !== "month") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Advice output must include a supported period.",
      502,
    );
  }
  if (typeof candidate.advice !== "string" || candidate.advice.trim() === "") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Advice output is missing advice text.",
      502,
    );
  }
  assertConfidence(candidate.confidence);
  return {
    ...candidate,
    period: candidate.period,
    groundedSummary:
      typeof candidate.groundedSummary === "string"
        ? candidate.groundedSummary
        : "",
    advice: candidate.advice,
    categoryDrivers: normalizeCategoryDrivers(candidate.categoryDrivers),
    confidence: candidate.confidence as number,
    needsConfirmation: true,
  } as AiFinancialAdviceStructuredResponse;
}

function parseProviderObject(value: unknown): Record<string, unknown> {
  const object = typeof value === "string" ? parseJsonObject(value) : value;
  if (!object || typeof object !== "object" || Array.isArray(object)) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output must be one JSON object.",
      502,
    );
  }
  return object as Record<string, unknown>;
}

function parseJsonObject(text: string): Record<string, unknown> {
  const trimmed = text.trim();
  if (trimmed.startsWith("```") || !trimmed.startsWith("{")) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output must be raw JSON only.",
      502,
    );
  }
  try {
    const decoded = JSON.parse(trimmed);
    if (decoded && typeof decoded === "object" && !Array.isArray(decoded)) {
      return decoded as Record<string, unknown>;
    }
  } catch {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output was not valid JSON.",
      502,
    );
  }
  throw new AiGatewayError(
    "invalid_provider_output",
    "Provider output was not a JSON object.",
    502,
  );
}

function assertConfidence(value: unknown): asserts value is number {
  if (typeof value !== "number" || value < 0 || value > 1) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output confidence must be between 0 and 1.",
      502,
    );
  }
}

function normalizeCategoryDrivers(value: unknown) {
  if (!Array.isArray(value)) return [];
  return value
    .filter((item): item is Record<string, unknown> => {
      return Boolean(item) && typeof item === "object" && !Array.isArray(item);
    })
    .map((item) => ({
      category: typeof item.category === "string" ? item.category : "",
      amount: typeof item.amount === "number" ? item.amount : 0,
      currency: typeof item.currency === "string" ? item.currency : null,
      note: typeof item.note === "string" ? item.note : null,
    }));
}

function normalizeAddExpenseResponse(
  response: AiStructuredResponse,
  context: ExpenseResponseNormalizationContext,
): AiStructuredResponse {
  const normalized = { ...response };
  const input = context.input ?? "";

  normalized.amount = normalizeAmount(normalized.amount) ?? inferAmount(input);

  const normalizedDate =
    normalizeDate(normalized.date, context.now) ?? inferDate(input, context.now);
  if (normalizedDate) normalized.date = normalizedDate;

  normalized.paymentMethod =
    normalizePaymentMethod(normalized.paymentMethod) ??
    inferPaymentMethod(input) ??
    "Cash";

  normalized.currency =
    normalizeCurrency(normalized.currency) ??
    inferCurrency(input) ??
    normalizeCurrency(context.defaultCurrency) ??
    context.defaultCurrency;

  const category = resolveCategory(normalized, input, context.categories ?? []);
  if (category.categoryId) normalized.categoryId = category.categoryId;
  if (category.name) normalized.category = category.name;
  normalized.categoryConfidence = category.categoryId
    ? 0.95
    : category.name
      ? 0.68
      : 0.3;
  normalized.categoryReason =
    category.reason ??
    (category.categoryId
      ? "Matched an active user category."
      : category.name
        ? "Suggested a category because no active category id matched."
        : "No clear category match was found.");
  if (!category.categoryId && category.name) {
    normalized.suggestedCategoryName = category.name;
    normalized.suggestedCategoryIcon = categoryIcon(category.key);
    normalized.suggestedCategoryColor = categoryColor(category.key);
  }

  if (!normalized.description || normalized.description.trim() === "") {
    normalized.description = buildDescription(normalized.category, context.locale);
  }

  const missing = missingAddExpenseFields(normalized);
  if (missing.length > 0) {
    normalized.confidence = Math.min(normalized.confidence, 0.5);
    normalized.clarifyingQuestion =
      normalized.clarifyingQuestion ?? buildClarifyingQuestion(missing, context.locale);
  }

  return normalized;
}

function normalizeAmount(value: unknown): number | undefined {
  if (typeof value === "number" && Number.isFinite(value) && value > 0) {
    return value;
  }
  if (typeof value !== "string") return undefined;
  const parsed = Number(normalizeDigits(value).replace(/[^0-9.]/g, ""));
  return Number.isFinite(parsed) && parsed > 0 ? parsed : undefined;
}

function inferAmount(input: string): number | undefined {
  const normalized = normalizeDigits(input);
  const match = normalized.match(/(?:^|[^\d])(\d+(?:[.,]\d+)?)(?:[^\d]|$)/);
  if (!match?.[1]) return undefined;
  const parsed = Number(match[1].replace(",", "."));
  return Number.isFinite(parsed) && parsed > 0 ? parsed : undefined;
}

function normalizeDigits(value: string): string {
  const arabicDigits = "٠١٢٣٤٥٦٧٨٩";
  const persianDigits = "۰۱۲۳۴۵۶۷۸۹";
  return [...value]
    .map((char) => {
      const arabicIndex = arabicDigits.indexOf(char);
      if (arabicIndex >= 0) return arabicIndex.toString();
      const persianIndex = persianDigits.indexOf(char);
      if (persianIndex >= 0) return persianIndex.toString();
      return char;
    })
    .join("");
}

function normalizeDate(
  value: string | null | undefined,
  nowValue: string | undefined,
): string | undefined {
  if (!value || value.trim() === "") return undefined;
  const text = normalizeText(value);
  const now = parseNow(nowValue);
  if (text === "tonight") {
    return formatDate(now);
  }
  if (text === "last night") {
    const date = new Date(now);
    date.setUTCDate(date.getUTCDate() - 1);
    return formatDate(date);
  }
  if (["today", "اليوم", "النهارده", "النهاردة"].includes(text)) {
    return formatDate(now);
  }
  if (["yesterday", "امبارح", "امس", "أمس"].map(normalizeText).includes(text)) {
    const date = new Date(now);
    date.setUTCDate(date.getUTCDate() - 1);
    return formatDate(date);
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return undefined;
  return formatDate(parsed);
}

function inferDate(input: string, nowValue: string | undefined): string {
  const text = normalizeText(input);
  const now = parseNow(nowValue);
  if (containsAny(text, ["امبارح", "امس", "أمس", "yesterday"])) {
    const date = new Date(now);
    date.setUTCDate(date.getUTCDate() - 1);
    return formatDate(date);
  }
  if (containsAny(text, ["last night"])) {
    const date = new Date(now);
    date.setUTCDate(date.getUTCDate() - 1);
    return formatDate(date);
  }
  const isoMatch = normalizeDigits(input).match(/\b\d{4}-\d{2}-\d{2}\b/);
  if (isoMatch?.[0]) return isoMatch[0];
  return formatDate(now);
}

function parseNow(value: string | undefined): Date {
  const parsed = value ? new Date(value) : new Date();
  if (!Number.isNaN(parsed.getTime())) return parsed;
  return new Date();
}

function formatDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function normalizePaymentMethod(
  value: string | null | undefined,
): AiStructuredResponse["paymentMethod"] {
  if (!value || value.trim() === "") return undefined;
  const text = normalizeText(value).replaceAll("_", " ");
  if (containsAny(text, ["cash", "كاش", "نقدي", "نقدا", "نقداً"])) return "Cash";
  if (containsAny(text, ["visa", "card", "credit card", "فيزا", "كارت"])) {
    return "Visa";
  }
  if (containsAny(text, ["wallet", "wallets", "محفظة"])) return "Wallet";
  if (containsAny(text, ["bank transfer", "transfer", "تحويل بنكي"])) {
    return "Bank Transfer";
  }
  return undefined;
}

function inferPaymentMethod(
  input: string,
): AiStructuredResponse["paymentMethod"] {
  return normalizePaymentMethod(input);
}

function normalizeCurrency(value: string | null | undefined): string | undefined {
  if (!value || value.trim() === "") return undefined;
  const text = normalizeText(value);
  if (containsAny(text, ["egp", "جنيه", "جنيه مصري"])) return "EGP";
  if (containsAny(text, ["usd", "dollar", "دولار"])) return "USD";
  return value.trim().toUpperCase();
}

function inferCurrency(input: string): string | undefined {
  const text = normalizeText(input);
  if (containsAny(text, ["egp", "جنيه", "جنيه مصري"])) return "EGP";
  if (containsAny(text, ["usd", "dollar", "دولار"])) return "USD";
  return undefined;
}

function resolveCategory(
  response: AiStructuredResponse,
  input: string,
  categories: CategorySnapshot[],
): { categoryId?: string; name?: string; key?: string; reason?: string } {
  const byId = matchCategoryById(response.categoryId, categories);
  if (byId) {
    const key = categoryKeyFromText(byId.name);
    return {
      ...snapshotToResolvedCategory(byId),
      ...(key ? { key } : {}),
      reason: "Matched provider categoryId to an active user category.",
    };
  }

  const byResponseName = matchCategoryByName(response.category, categories);
  if (byResponseName) {
    const key = categoryKeyFromText(byResponseName.name);
    return {
      ...snapshotToResolvedCategory(byResponseName),
      ...(key ? { key } : {}),
      reason: "Matched provider category name to an active user category.",
    };
  }

  const inferredKey =
    categoryKeyFromText(response.category) ?? categoryKeyFromInput(input);
  if (!inferredKey) {
    const categoryName = safeString(response.category);
    return categoryName
      ? {
          name: categoryName,
          reason: "Provider returned a category name without an active match.",
        }
      : {};
  }

  const byInferredKey = matchCategoryByKey(inferredKey, categories);
  if (byInferredKey) {
    return {
      ...snapshotToResolvedCategory(byInferredKey),
      key: inferredKey,
      reason: "Matched source words to an active user category.",
    };
  }

  return {
    name: categoryDisplayName(inferredKey),
    key: inferredKey,
    reason: "Suggested category from source words because no active category matched.",
  };
}

function snapshotToResolvedCategory(
  category: CategorySnapshot,
): { categoryId?: string; name?: string } {
  const categoryId = safeString(category.categoryId);
  const name = safeString(category.name);
  return {
    ...(categoryId ? { categoryId } : {}),
    ...(name ? { name } : {}),
  };
}

function matchCategoryById(
  categoryId: string | null | undefined,
  categories: CategorySnapshot[],
): CategorySnapshot | undefined {
  const id = safeString(categoryId);
  if (!id) return undefined;
  return activeCategories(categories).find((category) => category.categoryId === id);
}

function matchCategoryByName(
  value: string | null | undefined,
  categories: CategorySnapshot[],
): CategorySnapshot | undefined {
  const key = categoryKeyFromText(value);
  if (!key) return undefined;
  return matchCategoryByKey(key, categories);
}

function matchCategoryByKey(
  key: string,
  categories: CategorySnapshot[],
): CategorySnapshot | undefined {
  return activeCategories(categories).find((category) => {
    return categoryKeyFromText(category.name) === key;
  });
}

function activeCategories(categories: CategorySnapshot[]): CategorySnapshot[] {
  return categories.filter((category) => !category.isArchived);
}

function categoryKeyFromInput(input: string): string | undefined {
  const text = normalizeText(input);
  return Object.entries(categoryAliases).find(([, aliases]) =>
    aliases.some((alias) => text.includes(normalizeText(alias))),
  )?.[0];
}

function categoryKeyFromText(value: string | null | undefined): string | undefined {
  const text = normalizeText(value ?? "");
  if (!text) return undefined;
  const direct = Object.entries(categoryAliases).find(([, aliases]) =>
    aliases.some((alias) => normalizeText(alias) === text),
  )?.[0];
  if (direct) return direct;
  return text;
}

const categoryAliases: Record<string, string[]> = {
  food: ["food", "اكل", "أكل", "طعام", "مطعم", "مطاعم"],
  transport: [
    "transport",
    "transportation",
    "مواصلات",
    "المواصلات",
    "اوبر",
    "أوبر",
    "uber",
    "taxi",
    "تاكسي",
    "مترو",
    "بنزين",
  ],
  shopping: ["shopping", "تسوق", "مشتريات"],
  bills: ["bills", "bill", "فواتير", "فاتورة", "كهرباء", "مياه", "انترنت"],
  entertainment: ["entertainment", "ترفيه", "سينما", "العاب"],
  health: ["health", "صحة", "علاج", "صيدلية", "دكتور"],
  travel: ["travel", "سفر", "رحلة", "طيارة", "طيران"],
  subscriptions: ["subscriptions", "subscription", "netflix", "spotify", "اشتراك", "نتفلكس"],
  rent: ["rent", "ايجار", "إيجار"],
  fuel: ["fuel", "gas", "بنزين", "وقود"],
};

function categoryDisplayName(key: string): string {
  const names: Record<string, string> = {
    food: "Food",
    transport: "Transport",
    shopping: "Shopping",
    bills: "Bills",
    entertainment: "Entertainment",
    health: "Health",
    travel: "Travel",
    subscriptions: "Subscriptions",
    rent: "Rent",
    fuel: "Fuel",
  };
  return names[key] ?? key;
}

function categoryIcon(key: string | undefined): string {
  const icons: Record<string, string> = {
    food: "restaurant",
    transport: "directions_car",
    shopping: "shopping_bag",
    bills: "receipt_long",
    entertainment: "theaters",
    health: "local_hospital",
    travel: "flight",
    subscriptions: "subscriptions",
    rent: "home_work",
    fuel: "local_gas_station",
  };
  return icons[key ?? ""] ?? "category";
}

function categoryColor(key: string | undefined): string {
  const colors: Record<string, string> = {
    food: "#FF7043",
    transport: "#42A5F5",
    shopping: "#AB47BC",
    bills: "#FFCA28",
    entertainment: "#EC407A",
    health: "#66BB6A",
    travel: "#26A69A",
    subscriptions: "#5C6BC0",
    rent: "#78909C",
    fuel: "#26A69A",
  };
  return colors[key ?? ""] ?? "#607D8B";
}

function missingAddExpenseFields(response: AiStructuredResponse): string[] {
  void response;
  return [];
}

function buildDescription(
  category: string | null | undefined,
  locale: string | undefined,
): string {
  const categoryName = safeString(category);
  if (locale?.toLowerCase().startsWith("ar")) {
    return categoryName ? `مصروف ${categoryName}` : "مصروف";
  }
  return categoryName ? `${categoryName} expense` : "AI expense";
}

function buildClarifyingQuestion(
  missing: string[],
  locale: string | undefined,
): string {
  if (locale?.toLowerCase().startsWith("ar")) {
    const labels: Record<string, string> = {
      amount: "المبلغ",
      date: "التاريخ",
      category: "التصنيف",
      "payment method": "طريقة الدفع",
    };
    return `أحتاج توضيح ${missing.map((field) => labels[field] ?? field).join(" و ")} قبل تجهيز المعاينة.`;
  }
  return `Please clarify ${missing.join(", ")} before I prepare the preview.`;
}

function containsAny(text: string, terms: string[]): boolean {
  return terms.some((term) => text.includes(normalizeText(term)));
}

function normalizeText(value: string): string {
  return normalizeDigits(value)
    .trim()
    .toLowerCase()
    .replace(/[ـًٌٍَُِّْ]/g, "")
    .replace(/[إأآ]/g, "ا")
    .replace(/ة/g, "ه")
    .replace(/\s+/g, " ");
}

function safeString(value: string | null | undefined): string | undefined {
  const text = value?.trim();
  return text ? text : undefined;
}
