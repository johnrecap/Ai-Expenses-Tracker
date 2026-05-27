import { eq } from "drizzle-orm";

import { db } from "../db/client.js";
import { users } from "../db/schema/index.js";

export interface EnsureBackendUserInput {
  firebaseUid: string;
  email?: string;
}

export async function ensureBackendUser(input: EnsureBackendUserInput) {
  const existing = await db.query.users.findFirst({
    where: eq(users.firebaseUid, input.firebaseUid),
  });

  if (existing) {
    const [updated] = await db
      .update(users)
      .set({
        email: input.email ?? existing.email,
        updatedAt: new Date(),
      })
      .where(eq(users.id, existing.id))
      .returning();
    return updated;
  }

  const [created] = await db
    .insert(users)
    .values({
      firebaseUid: input.firebaseUid,
      email: input.email,
    })
    .returning();

  return created;
}
