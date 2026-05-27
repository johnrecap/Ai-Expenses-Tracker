import { integer, text, timestamp, uuid } from "drizzle-orm/pg-core";

export const syncColumns = {
  createdAt: timestamp("created_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true })
    .notNull()
    .defaultNow(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
  serverRevision: integer("server_revision").notNull().default(1),
  clientUpdatedAt: timestamp("client_updated_at", { withTimezone: true }),
  originDeviceId: uuid("origin_device_id"),
  legacyFirestorePath: text("legacy_firestore_path"),
};
