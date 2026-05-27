import type { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { z } from "zod";

import { firebaseAuthGuard } from "../auth/firebaseAuth.js";
import { requireFirebaseUser } from "../auth/ownership.js";
import { internalError, sendApiError } from "../http/errors.js";
import { parseBody } from "../http/validation.js";
import { ensureBackendUser } from "./userService.js";

const updateProfileSchema = z.object({
  appDisplayName: z.string().trim().max(80).nullable().optional(),
});

export interface BackendUserDto {
  id: string;
  firebaseUid: string;
  email: string | null;
  appDisplayName: string | null;
}

export interface UserRoutesDependencies {
  authGuard?: (
    request: FastifyRequest,
    reply: FastifyReply,
  ) => Promise<unknown>;
  ensureUser?: (input: {
    firebaseUid: string;
    email?: string;
  }) => Promise<BackendUserDto>;
  updateUserProfile?: (input: {
    firebaseUid: string;
    appDisplayName?: string | null;
  }) => Promise<BackendUserDto>;
}

export function registerUserRoutes(
  app: FastifyInstance,
  dependencies: UserRoutesDependencies = {},
) {
  const authGuard = dependencies.authGuard ?? firebaseAuthGuard;
  const ensureUser =
    dependencies.ensureUser ??
    (async (input) => {
      const user = await ensureBackendUser(input);
      return toBackendUserDto(user);
    });
  const updateUserProfile =
    dependencies.updateUserProfile ??
    (async (input) => {
      const user = await ensureBackendUser({
        firebaseUid: input.firebaseUid,
      });
      return {
        ...toBackendUserDto(user),
        appDisplayName: input.appDisplayName ?? null,
      };
    });

  app.get("/v1/users/me", { preHandler: authGuard }, async (request, reply) => {
    try {
      const firebaseUser = requireFirebaseUser(request);
      return await ensureUser({
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email,
      });
    } catch (error) {
      request.log.error({ error }, "Failed to load backend user.");
      return sendApiError(reply, 500, internalError);
    }
  });

  app.patch(
    "/v1/users/me",
    { preHandler: authGuard },
    async (request, reply) => {
      const body = parseBody(updateProfileSchema, request.body, reply);
      if (!body) return;

      try {
        const firebaseUser = requireFirebaseUser(request);
        return await updateUserProfile({
          firebaseUid: firebaseUser.uid,
          appDisplayName: body.appDisplayName ?? null,
        });
      } catch (error) {
        request.log.error({ error }, "Failed to update backend user.");
        return sendApiError(reply, 500, internalError);
      }
    },
  );
}

function toBackendUserDto(user: {
  id: string;
  firebaseUid: string;
  email: string | null;
  appDisplayName: string | null;
}): BackendUserDto {
  return {
    id: user.id,
    firebaseUid: user.firebaseUid,
    email: user.email,
    appDisplayName: user.appDisplayName,
  };
}
