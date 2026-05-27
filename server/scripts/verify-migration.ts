import { readFile } from "node:fs/promises";

import type { MigrationRecord } from "../src/migration/firestoreMappers.js";
import {
  formatMigrationVerificationReport,
  verifyMigrationRecords,
} from "../src/migration/verifyMigration.js";

async function main() {
  const [sourcePath, targetPath] = process.argv.slice(2);
  if (!sourcePath || !targetPath) {
    console.error("Usage: tsx server/scripts/verify-migration.ts <source.json> <target.json>");
    process.exitCode = 1;
    return;
  }

  const source = JSON.parse(await readFile(sourcePath, "utf8")) as MigrationRecord[];
  const target = JSON.parse(await readFile(targetPath, "utf8")) as MigrationRecord[];
  const report = verifyMigrationRecords(source, target);
  console.log(formatMigrationVerificationReport(report));
  if (!report.passed) process.exitCode = 2;
}

await main();
