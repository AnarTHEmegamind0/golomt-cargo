export const appRoles = [
  "customer",
  "china_staff",
  "mongolia_staff",
  "admin",
] as const;

export type AppRole = (typeof appRoles)[number];

export const normalizeAppRole = (role?: string | null): AppRole | undefined => {
  switch ((role ?? "").trim()) {
    case "customer":
      return "customer";
    case "china_staff":
    case "chinaStaff":
      return "china_staff";
    case "mongolia_staff":
    case "mongoliaStaff":
      return "mongolia_staff";
    case "admin":
      return "admin";
    default:
      return undefined;
  }
};
