ALTER TABLE "sync_changes"
  ADD COLUMN IF NOT EXISTS "client_change_id" text;

CREATE UNIQUE INDEX IF NOT EXISTS "sync_changes_user_client_change_unique"
  ON "sync_changes" ("user_id", "changed_by_device_id", "client_change_id")
  WHERE "client_change_id" IS NOT NULL;
