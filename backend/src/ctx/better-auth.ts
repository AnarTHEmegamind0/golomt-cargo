import { Elysia } from "elysia";
import { auth } from "~/lib/auth";
import type { AppRole } from "~/lib/constants/roles";
import { logAuthFailure } from "~/lib/runtime-logging";

export const betterAuth = new Elysia({ name: "@[better-auth]" })
  .mount(auth.handler)
  .macro({
    auth: (options?: { roles?: AppRole[] }) => {
      return {
        async resolve(ctx: any) {
          const {
            status,
            request: { headers },
          } = ctx;

          const session = await auth.api.getSession({
            headers,
          });

          if (!session) {
            logAuthFailure(ctx, {
              status: 401,
              reason: "missing_session",
              requiredRoles: options?.roles,
            });
            return status(401, "Unauthorized");
          }

          const role = session.user.role as AppRole | undefined;
          const requiredRoles = options?.roles;

          if (requiredRoles?.length && (!role || !requiredRoles.includes(role))) {
            logAuthFailure(ctx, {
              status: 403,
              reason: "insufficient_role",
              requiredRoles,
              resolvedRole: role ?? null,
              userId: session.user.id,
            });
            return status(403, "Forbidden");
          }

          return {
            user: session.user,
            session: session.session,
          };
        },
      };
    },
  });
