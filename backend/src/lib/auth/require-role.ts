import type { AppRole } from "~/lib/constants/roles";

export const requireRole = (...roles: AppRole[]) => ({
  auth: { roles },
});

export const requireAdmin = () => requireRole("admin");
