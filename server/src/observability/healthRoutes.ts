import type { FastifyInstance } from "fastify";

import { checkFirebaseVerifier } from "../auth/firebaseAuth.js";
import { checkDatabaseConnection } from "../db/client.js";

export interface HealthRouteDependencies {
  checkDatabase?: () => Promise<boolean>;
  checkAuthVerifier?: () => Promise<boolean>;
}

export function registerHealthRoutes(
  app: FastifyInstance,
  dependencies: HealthRouteDependencies = {},
) {
  const checkDatabase = dependencies.checkDatabase ?? checkDatabaseConnection;
  const checkAuthVerifier =
    dependencies.checkAuthVerifier ?? checkFirebaseVerifier;

  app.get("/health", async () => {
    const [databaseOk, authVerifierOk] = await Promise.all([
      checkDatabase(),
      checkAuthVerifier(),
    ]);

    return {
      status: databaseOk && authVerifierOk ? "ok" : "degraded",
      database: databaseOk ? "ok" : "unavailable",
      authVerifier: authVerifierOk ? "ok" : "unavailable",
      version: "0.1.0",
    };
  });
}
