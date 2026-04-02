export const appRoles = [
  "customer",
  "china_staff",
  "mongolia_staff",
  "admin",
] as const;

export type AppRole = (typeof appRoles)[number];
