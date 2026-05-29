import type { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { z } from "zod";

import { firebaseAuthGuard } from "../auth/firebaseAuth.js";
import { requireFirebaseUser } from "../auth/ownership.js";
import { internalError, sendApiError } from "../http/errors.js";
import { parseBody } from "../http/validation.js";
import { defaultSyncService, type SyncService } from "./syncService.js";

const entityTypeSchema = z.enum([
  "settings",
  "expense",
  "category",
  "categoryAlias",
  "budget",
  "categoryBudget",
  "recurringExpense",
  "savingGoal",
  "walletAccount",
  "transfer",
  "aiActionLog",
]);

const syncEnvelopeSchema = z.object({
  entityType: entityTypeSchema,
  entityId: z.string().min(1),
  clientChangeId: z.string().min(1).optional(),
  operation: z.enum(["upsert", "delete"]),
  data: z.record(z.unknown()).default({}),
  clientUpdatedAt: z.string().datetime(),
  baseRevision: z.number().int().nullable().optional(),
});

const pushSchema = z.object({
  deviceId: z.string().min(1),
  changes: z.array(syncEnvelopeSchema).max(500),
});

export interface SyncRoutesDependencies {
  authGuard?: (
    request: FastifyRequest,
    reply: FastifyReply,
  ) => Promise<unknown>;
  syncService?: SyncService;
}

export function registerSyncRoutes(
  app: FastifyInstance,
  dependencies: SyncRoutesDependencies = {},
) {
  const authGuard = dependencies.authGuard ?? firebaseAuthGuard;
  const syncService = dependencies.syncService ?? defaultSyncService;

  app.get(
    "/v1/bootstrap",
    { preHandler: authGuard },
    async (request, reply) => {
      return pullForRequest(request, reply, syncService);
    },
  );

  app.get(
    "/v1/sync/pull",
    { preHandler: authGuard },
    async (request, reply) => {
      return pullForRequest(request, reply, syncService);
    },
  );

  app.post(
    "/v1/sync/push",
    { preHandler: authGuard },
    async (request, reply) => {
      const body = parseBody(pushSchema, request.body, reply);
      if (!body) return;

      try {
        const firebaseUser = requireFirebaseUser(request);
        return await syncService.push(firebaseUser.uid, {
          deviceId: body.deviceId,
          changes: body.changes.map((change) => ({
            ...change,
            data: change.data ?? {},
          })),
        });
      } catch (error) {
        request.log.error({ error }, "Failed to push sync changes.");
        return sendApiError(reply, 500, internalError);
      }
    },
  );
}

async function pullForRequest(
  request: FastifyRequest,
  reply: FastifyReply,
  syncService: SyncService,
) {
  try {
    const firebaseUser = requireFirebaseUser(request);
    const query = request.query as {
      cursor?: string;
      limit?: string;
    };
    return await syncService.pull(
      firebaseUser.uid,
      query.cursor,
      query.limit == null ? undefined : Number.parseInt(query.limit, 10),
    );
  } catch (error) {
    request.log.error({ error }, "Failed to pull sync changes.");
    return sendApiError(reply, 500, internalError);
  }
}
