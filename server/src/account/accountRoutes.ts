import type { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";

import { firebaseAuthGuard } from "../auth/firebaseAuth.js";
import { requireFirebaseUser } from "../auth/ownership.js";
import { sendApiError } from "../http/errors.js";
import {
  defaultAccountDeletionService,
  RecentAuthenticationRequiredError,
  type AccountDeletionService,
} from "./accountDeletionService.js";

export interface AccountRoutesDependencies {
  authGuard?: (
    request: FastifyRequest,
    reply: FastifyReply,
  ) => Promise<unknown>;
  deletionService?: AccountDeletionService;
}

export function registerAccountRoutes(
  app: FastifyInstance,
  dependencies: AccountRoutesDependencies = {},
) {
  const authGuard = dependencies.authGuard ?? firebaseAuthGuard;
  const deletionService =
    dependencies.deletionService ?? defaultAccountDeletionService;

  app.delete(
    "/v1/account",
    { preHandler: authGuard },
    async (request, reply) => {
      const firebaseUser = requireFirebaseUser(request);
      const recentAuthConfirmed =
        request.headers["x-recent-auth-confirmed"] === "true";

      try {
        return await deletionService.requestDeletion({
          firebaseUid: firebaseUser.uid,
          requestedAt: new Date().toISOString(),
          recentAuthConfirmed,
        });
      } catch (error) {
        if (error instanceof RecentAuthenticationRequiredError) {
          return sendApiError(reply, 409, {
            code: "auth/recent-login-required",
            message:
              "Recent authentication is required before deleting the account.",
            retryable: false,
          });
        }

        request.log.error({ error }, "Failed to request account deletion.");
        return sendApiError(reply, 500, {
          code: "account/delete-failed",
          message: "Account deletion could not be started.",
          retryable: true,
        });
      }
    },
  );
}
