import { describe, expect, it } from "vitest";

import { mapFirestoreUserExport } from "../../src/migration/firestoreMappers.js";
import { verifyMigrationRecords } from "../../src/migration/verifyMigration.js";

describe("migration verification", () => {
  it("reports missing records and field hash mismatches", () => {
    const source = mapFirestoreUserExport({
      userId: "user-a",
      documents: [
        {
          collection: "expenses",
          id: "expense-1",
          data: { amount: 100, currency: "EGP" },
        },
        {
          collection: "expenses",
          id: "expense-2",
          data: { amount: 200, currency: "EGP" },
        },
      ],
    });
    const target = [
      { ...source[0], fieldHash: "different" },
    ];

    const report = verifyMigrationRecords(source, target);

    expect(report.passed).toBe(false);
    expect(report.missing).toContain("user-a:expense:expense-2");
    expect(report.unexpected).toEqual([]);
    expect(report.hashMismatches).toContain("user-a:expense:expense-1");
    expect(report.warnings).toEqual([
      "Record count differs: source=2, target=1.",
    ]);
  });

  it("reports unexpected target records", () => {
    const source = mapFirestoreUserExport({
      userId: "user-a",
      documents: [
        {
          collection: "expenses",
          id: "expense-1",
          data: { amount: 100, currency: "EGP" },
        },
      ],
    });
    const target = [
      source[0],
      { ...source[0], entityId: "expense-2" },
    ];

    const report = verifyMigrationRecords(source, target);

    expect(report.passed).toBe(false);
    expect(report.unexpected).toContain("user-a:expense:expense-2");
  });
});
