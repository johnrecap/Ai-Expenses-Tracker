import { describe, expect, it } from "vitest";

import { mapFirestoreUserExport } from "../../src/migration/firestoreMappers.js";

describe("Firestore backfill fixtures", () => {
  it("maps representative Firestore documents into sync migration records", () => {
    const records = mapFirestoreUserExport({
      userId: "user-a",
      documents: [
        {
          collection: "settings",
          id: "settings",
          data: { baseCurrency: "EGP", updatedAt: "2026-05-25T10:00:00.000Z" },
        },
        {
          collection: "expenses",
          id: "expense-1",
          data: {
            amount: 100,
            currency: "USD",
            expenseId: "expense-1",
            updatedAt: "2026-05-25T11:00:00.000Z",
          },
        },
        {
          collection: "category_budgets",
          id: "2026-05_food_EGP",
          data: { month: "2026-05", categoryId: "food", limitAmount: 5000 },
        },
      ],
    });

    expect(records.map((record) => record.entityType)).toEqual([
      "settings",
      "expense",
      "categoryBudget",
    ]);
    expect(records[0].entityId).toBe("user-a");
    expect(records[1].data.legacyFirestorePath).toBe(
      "users/user-a/expenses/expense-1",
    );
    expect(records.every((record) => record.fieldHash.length === 64)).toBe(true);
  });
});
