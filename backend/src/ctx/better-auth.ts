import { Elysia } from "elysia";
import { auth } from "~/lib/auth";
import type { AppRole } from "~/lib/constants/roles";

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

          if (!session) return status(401, "Unauthorized");

          const role = session.user.role as AppRole | undefined;
          const requiredRoles = options?.roles;

          if (requiredRoles?.length && (!role || !requiredRoles.includes(role))) {
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
