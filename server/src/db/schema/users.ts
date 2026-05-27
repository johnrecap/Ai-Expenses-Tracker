import {
  index,
  jsonb,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
  uuid,
} from "drizzle-orm/pg-core";

export const users = pgTable(
  "users",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    firebaseUid: text("firebase_uid").notNull(),
    email: text("email"),
    providerSummary: jsonb("provider_summary").$type<string[]>(),
    appDisplayName: text("app_display_name"),
    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    deletedAt: timestamp("deleted_at", { withTimezone: true }),
  },
  (table) => ({
    firebaseUidUnique: uniqueIndex("users_firebase_uid_unique").on(
      table.firebaseUid,
    ),
    deletedAtIdx: index("users_deleted_at_idx").on(table.deletedAt),
  }),
);

export const devices = pgTable(
  "devices",
  {
    id: uuid("id").primaryKey(),
    userId: uuid("user_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    deviceLabel: text("device_label"),
    platform: text("platform").notNull(),
    appVersion: text("app_version").notNull(),
    lastSeenAt: timestamp("last_seen_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    lastPullCursor: text("last_pull_cursor"),
  },
  (table) => ({
    userIdIdx: index("devices_user_id_idx").on(table.userId),
  }),
);
