import { readFile, writeFile } from "node:fs/promises";
import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

import { env } from "../src/config/env.js";
import { closeDatabase } from "../src/db/client.js";
import {
  type FirestoreCollectionName,
  mapFirestoreUserExport,
  type FirestoreUserExport,
} from "../src/migration/firestoreMappers.js";
import {
  MigrationImportService,
  PostgresSyncMigrationTarget,
} from "../src/migration/importService.js";

async function main() {
  const args = process.argv.slice(2);
  const fixturePath = args[0];
  if (!fixturePath) {
    console.error(
      "Usage: npm run backfill:firestore -- <firestore-export.json> OR --user <firebaseUid>",
    );
    process.exitCode = 1;
    return;
  }

  const payload =
    fixturePath === "--user"
      ? await readFirestoreUserExport(args[1])
      : (JSON.parse(await readFile(fixturePath, "utf8")) as FirestoreUserExport);
  const records = mapFirestoreUserExport(payload);
  const target = new PostgresSyncMigrationTarget();
  const service = new MigrationImportService(target);
  const result = await service.importRecords(records);
  const targetRecords = await target.allRecords(payload.userId);
  const sourcePath = `source-records-${payload.userId}.json`;
  const targetPath = `target-records-${payload.userId}.json`;

  await writeFile(sourcePath, JSON.stringify(records, null, 2));
  await writeFile(targetPath, JSON.stringify(targetRecords, null, 2));

  console.log(
    JSON.stringify(
      {
        userId: payload.userId,
        sourceRecords: records.length,
        targetRecords: targetRecords.length,
        sourcePath,
        targetPath,
        result,
      },
      null,
      2,
    ),
  );
  await closeDatabase();
}

await main();

async function readFirestoreUserExport(
  userId: string | undefined,
): Promise<FirestoreUserExport> {
  if (!userId) {
    throw new Error("--user requires a Firebase uid.");
  }
  initializeFirebaseAdmin();
  const db = getFirestore();
  const collections: FirestoreCollectionName[] = [
    "settings",
    "expenses",
    "categories",
    "category_aliases",
    "budgets",
    "category_budgets",
    "recurring_expenses",
    "saving_goals",
    "wallets",
    "transfers",
    "ai_action_logs",
  ];
  const documents = [];
  for (const collection of collections) {
    const snapshot = await db.collection(`users/${userId}/${collection}`).get();
    for (const document of snapshot.docs) {
      documents.push({
        collection,
        id: document.id,
        path: document.ref.path,
        data: document.data(),
      });
    }
  }
  return { userId, documents };
}

function initializeFirebaseAdmin() {
  if (getApps().length > 0) return;
  initializeApp({
    credential: cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
    }),
  });
}
