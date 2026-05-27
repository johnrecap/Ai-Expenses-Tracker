import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { closeDatabase, pool } from "../src/db/client.js";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const migrationPath = resolve(
  scriptDir,
  "../src/db/migrations/0001_durable_sync_changes.sql",
);

try {
  const sql = await readFile(migrationPath, "utf8");
  await pool.query(sql);
  console.log(
    JSON.stringify({
      status: "ok",
      migration: "0001_durable_sync_changes",
      path: migrationPath,
    }),
  );
} finally {
  await closeDatabase();
}
