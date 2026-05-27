import cors from "@fastify/cors";
import Fastify from "fastify";

import { registerAccountRoutes } from "./account/accountRoutes.js";
import { env } from "./config/env.js";
import { safeLogContext, safeRequestContext } from "./observability/logger.js";
import { metrics } from "./observability/metrics.js";
import { registerHealthRoutes } from "./observability/healthRoutes.js";
import { registerSyncRoutes } from "./sync/syncRoutes.js";
import { registerUserRoutes } from "./users/userRoutes.js";

export function buildApp() {
  const app = Fastify({
    logger: {
      level: env.LOG_LEVEL,
      redact: [
        "req.headers.authorization",
        "DATABASE_URL",
        "FIREBASE_PRIVATE_KEY",
      ],
    },
  });

  app.register(cors, {
    origin: false,
  });

  app.addHook("onResponse", async (request, reply) => {
    metrics.recordRequest(reply.statusCode);
    request.log.info(
      safeLogContext({
        ...safeRequestContext(request),
        statusCode: reply.statusCode,
      }),
      "request completed",
    );
  });

  registerHealthRoutes(app);
  app.get("/metrics", async () => metrics.snapshot());
  registerAccountRoutes(app);
  registerUserRoutes(app);
  registerSyncRoutes(app);

  return app;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const app = buildApp();
  await app.listen({ host: env.HOST, port: env.PORT });
}
