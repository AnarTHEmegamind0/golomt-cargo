import { createId } from "@paralleldrive/cuid2";
import { normalizeAppRole, type AppRole } from "~/lib/constants/roles";
import { auth } from "~/lib/auth";
import { cargoStatusEvent } from "~/db/schema";
import { logAuthFailure } from "~/lib/runtime-logging";

export const isCustomer = (role?: string | null) => role === "customer";

export const roleGuard = (roles: AppRole[]) => ({
  async beforeHandle(ctx: any) {
    const session = await auth.api.getSession({ headers: ctx.request.headers });

    if (!session) {
      logAuthFailure(ctx, {
        status: 401,
        reason: "missing_session",
        requiredRoles: roles,
      });
      return ctx.status(401, { message: "Unauthorized" });
    }

    const role = normalizeAppRole(session.user.role);
    if (!role || !roles.includes(role)) {
      logAuthFailure(ctx, {
        status: 403,
        reason: "insufficient_role",
        requiredRoles: roles,
        resolvedRole: session.user.role ?? null,
        userId: session.user.id,
      });
      return ctx.status(403, { message: "Forbidden" });
    }

    ctx.authUser = {
      ...session.user,
      role,
    };
  },
});

export const insertStatusEvent = async (input: {
  db: any;
  cargoId: string;
  fromStatus: string | null;
  toStatus: string;
  changedByUserId: string;
}) => {
  await input.db.insert(cargoStatusEvent).values({
    id: createId(),
    cargoId: input.cargoId,
    fromStatus: input.fromStatus,
    toStatus: input.toStatus,
    changedByUserId: input.changedByUserId,
  });
};
