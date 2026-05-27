import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z
    .enum(["development", "test", "staging", "production"])
    .default("development"),
  HOST: z.string().default("127.0.0.1"),
  PORT: z.coerce.number().int().positive().default(8080),
  DATABASE_URL: z
    .string()
    .min(1)
    .default("postgres://localhost/ai_expenses_dev"),
  FIREBASE_PROJECT_ID: z.string().min(1).default("local-dev"),
  FIREBASE_CLIENT_EMAIL: z
    .string()
    .email()
    .default("firebase-adminsdk@example.iam.gserviceaccount.com"),
  FIREBASE_PRIVATE_KEY: z.string().min(1).default("local-dev-private-key"),
  LOG_LEVEL: z
    .enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"])
    .default("info"),
});

export type AppEnv = z.infer<typeof envSchema>;

export function loadEnv(source: NodeJS.ProcessEnv = process.env): AppEnv {
  const parsed = envSchema.safeParse(source);
  if (!parsed.success) {
    const details = parsed.error.issues
      .map((issue) => `${issue.path.join(".")}: ${issue.message}`)
      .join("; ");
    throw new Error(`Invalid server environment: ${details}`);
  }
  if (parsed.data.NODE_ENV === "production") {
    for (const key of [
      "DATABASE_URL",
      "FIREBASE_PROJECT_ID",
      "FIREBASE_CLIENT_EMAIL",
      "FIREBASE_PRIVATE_KEY",
    ] as const) {
      if (!source[key]) {
        throw new Error(`Invalid server environment: ${key} is required`);
      }
    }
  }
  return parsed.data;
}

export const env = loadEnv();
