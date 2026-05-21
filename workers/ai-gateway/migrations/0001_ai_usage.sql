CREATE TABLE IF NOT EXISTS ai_usage_daily (
  date_key TEXT NOT NULL,
  uid TEXT NOT NULL,
  request_type TEXT NOT NULL,
  provider TEXT NOT NULL,
  model TEXT NOT NULL,
  used_count INTEGER NOT NULL DEFAULT 0,
  limit_count INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  PRIMARY KEY (date_key, uid, request_type, provider, model)
);

CREATE TABLE IF NOT EXISTS ai_usage_logs (
  id TEXT PRIMARY KEY,
  date_key TEXT NOT NULL,
  uid TEXT NOT NULL,
  request_type TEXT NOT NULL,
  status TEXT NOT NULL,
  provider TEXT NOT NULL,
  model TEXT NOT NULL,
  request_id TEXT NOT NULL,
  error_code TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_ai_usage_logs_lookup
ON ai_usage_logs (date_key, uid, request_type);
