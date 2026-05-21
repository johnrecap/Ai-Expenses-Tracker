import { describe, expect, test } from "vitest";
import { parseStructuredResponse } from "../src/ai/structuredSchema";

describe("structured schema normalization", () => {
  test("infers required add expense fields from Arabic input", () => {
    const result = parseStructuredResponse(
      JSON.stringify({
        intent: "add_expense",
        amount: 100,
        confidence: 0.92,
        needsConfirmation: true,
      }),
      {
        input: "صرفت 100 جنيه امبارح علي المواصلات",
        now: "2026-05-17T03:14:00.000Z",
        locale: "ar-EG",
        defaultCurrency: "EGP",
        categories: [{ categoryId: "transport", name: "Transport" }],
      },
    );

    expect(result.intent).toBe("add_expense");
    expect(result.amount).toBe(100);
    expect(result.date).toBe("2026-05-16");
    expect(result.paymentMethod).toBe("Cash");
    expect(result.currency).toBe("EGP");
    expect(result.categoryId).toBe("transport");
    expect(result.category).toBe("Transport");
    expect(result.categoryConfidence).toBeGreaterThan(0.9);
    expect(result.categoryReason).toContain("Matched");
    expect(result.confidence).toBe(0.92);
    expect(result.needsConfirmation).toBe(true);
  });

  test("suggests missing subscription category without claiming creation", () => {
    const result = parseStructuredResponse(
      {
        intent: "add_expense",
        amount: 200,
        confidence: 0.9,
        needsConfirmation: true,
      },
      {
        input: "دفعت اشتراك نتفلكس 200 جنيه",
        now: "2026-05-17T03:14:00.000Z",
        locale: "ar-EG",
        defaultCurrency: "EGP",
        categories: [{ categoryId: "transport", name: "Transport" }],
      },
    );

    expect(result.categoryId).toBeUndefined();
    expect(result.category).toBe("Subscriptions");
    expect(result.suggestedCategoryName).toBe("Subscriptions");
    expect(result.suggestedCategoryIcon).toBe("subscriptions");
    expect(result.suggestedCategoryColor).toBe("#5C6BC0");
    expect(result.categoryConfidence).toBeLessThan(0.75);
    expect(result.categoryReason).not.toMatch(/created|saved/i);
    expect(result.needsConfirmation).toBe(true);
  });

  test("keeps draft editable when add expense category is not inferable", () => {
    const result = parseStructuredResponse(
      {
        intent: "add_expense",
        amount: 100,
        confidence: 0.91,
        needsConfirmation: true,
      },
      {
        input: "صرفت 100 جنيه",
        now: "2026-05-17T03:14:00.000Z",
        locale: "ar-EG",
        defaultCurrency: "EGP",
        categories: [],
      },
    );

    expect(result.confidence).toBe(0.91);
    expect(result.clarifyingQuestion).toBeUndefined();
    expect(result.paymentMethod).toBe("Cash");
    expect(result.date).toBe("2026-05-17");
  });

  test("infers reported English expense sentence with safe defaults", () => {
    const result = parseStructuredResponse(
      {
        intent: "add_expense",
        amount: 100,
        confidence: 0.92,
        needsConfirmation: true,
      },
      {
        input: "spent 100 dollar on food last night",
        now: "2026-05-19T12:00:00.000Z",
        locale: "en-US",
        defaultCurrency: "EGP",
        categories: [{ categoryId: "food", name: "Food" }],
      },
    );

    expect(result.intent).toBe("add_expense");
    expect(result.amount).toBe(100);
    expect(result.currency).toBe("USD");
    expect(result.date).toBe("2026-05-18");
    expect(result.paymentMethod).toBe("Cash");
    expect(result.categoryId).toBe("food");
    expect(result.category).toBe("Food");
    expect(result.clarifyingQuestion).toBeUndefined();
  });

  test("does not ask for omitted payment date or currency", () => {
    const result = parseStructuredResponse(
      {
        intent: "add_expense",
        amount: 100,
        category: "Food",
        confidence: 0.91,
        needsConfirmation: true,
      },
      {
        input: "spent 100 on food",
        now: "2026-05-19T12:00:00.000Z",
        locale: "en-US",
        defaultCurrency: "EGP",
        categories: [{ categoryId: "food", name: "Food" }],
      },
    );

    expect(result.confidence).toBe(0.91);
    expect(result.date).toBe("2026-05-19");
    expect(result.paymentMethod).toBe("Cash");
    expect(result.currency).toBe("EGP");
    expect(result.clarifyingQuestion).toBeUndefined();
  });

  test("does not ask when amount is missing from an editable draft", () => {
    const result = parseStructuredResponse(
      {
        intent: "add_expense",
        confidence: 0.91,
        needsConfirmation: true,
      },
      {
        input: "food last night",
        now: "2026-05-19T12:00:00.000Z",
        locale: "en-US",
        defaultCurrency: "EGP",
        categories: [{ categoryId: "food", name: "Food" }],
      },
    );

    expect(result.amount).toBeUndefined();
    expect(result.confidence).toBe(0.91);
    expect(result.clarifyingQuestion).toBeUndefined();
  });

  test("does not ask when category is missing from an editable draft", () => {
    const result = parseStructuredResponse(
      {
        intent: "add_expense",
        amount: 100,
        confidence: 0.91,
        needsConfirmation: true,
      },
      {
        input: "spent 100 last night",
        now: "2026-05-19T12:00:00.000Z",
        locale: "en-US",
        defaultCurrency: "EGP",
        categories: [],
      },
    );

    expect(result.category).toBeUndefined();
    expect(result.confidence).toBe(0.91);
    expect(result.clarifyingQuestion).toBeUndefined();
  });
});
