import { describe, expect, it } from "vitest";

import { mapFirestoreUserExport } from "../../src/migration/firestoreMappers.js";
import {
  InMemoryMigrationTarget,
  MigrationImportService,
} from "../../src/migration/importService.js";

describe("backfill idempotency", () => {
  it("skips unchanged records when the same export is imported again", async () => {
    const records = mapFirestoreUserExport({
      userId: "user-a",
      documents: [
        {
          collection: "expenses",
          id: "expense-1",
          data: { amount: 100, currency: "EGP", updatedAt: "2026-05-25T10:00:00Z" },
        },
      ],
    });
    const service = new MigrationImportService(new InMemoryMigrationTarget());

    await expect(service.importRecords(records)).resolves.toEqual({
      inserted: 1,
      updated: 0,
      skipped: 0,
    });
    await expect(service.importRecords(records)).resolves.toEqual({
      inserted: 0,
      updated: 0,
      skipped: 1,
    });
  });
});
