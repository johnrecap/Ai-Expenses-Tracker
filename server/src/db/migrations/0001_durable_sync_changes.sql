ALTER TABLE "sync_changes"
  ADD COLUMN IF NOT EXISTS "data" jsonb NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE "sync_changes"
  ADD COLUMN IF NOT EXISTS "client_updated_at" timestamp with time zone;

ALTER TABLE "sync_changes"
  ADD COLUMN IF NOT EXISTS "base_revision" integer;

ALTER TABLE "sync_changes"
  ALTER COLUMN "changed_by_device_id" TYPE text USING "changed_by_device_id"::text;

CREATE SEQUENCE IF NOT EXISTS "sync_changes_server_revision_seq";

SELECT setval(
  '"sync_changes_server_revision_seq"',
  GREATEST(COALESCE((SELECT MAX("server_revision") FROM "sync_changes"), 1), 1),
  COALESCE((SELECT MAX("server_revision") FROM "sync_changes"), 0) > 0
);

ALTER TABLE "sync_changes"
  ALTER COLUMN "server_revision" SET DEFAULT nextval('"sync_changes_server_revision_seq"');

ALTER SEQUENCE "sync_changes_server_revision_seq"
  OWNED BY "sync_changes"."server_revision";

CREATE INDEX IF NOT EXISTS "sync_changes_user_entity_idx"
  ON "sync_changes" ("user_id", "entity_type", "entity_id");
