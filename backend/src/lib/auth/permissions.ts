import { createAccessControl } from "better-auth/plugins/access";
import { adminAc, defaultStatements } from "better-auth/plugins/admin/access";

const permissionStatements = {
  ...defaultStatements,
  cargo: [
    "create",
    "read",
    "update",
    "receive",
    "ship",
    "arrive",
    "fulfill",
    "deliver",
    "pay",
  ],
  branch: ["create", "read", "update", "delete"],
  payment: ["create", "read", "update", "refund"],
} as const;

const ac = createAccessControl(permissionStatements);

const customer = ac.newRole({
  cargo: ["create", "read", "pay", "fulfill"],
  branch: ["read"],
  payment: ["create", "read"],
});

const chinaStaff = ac.newRole({
  cargo: ["read", "update", "receive", "ship"],
  branch: ["read"],
  payment: ["read"],
});

const mongoliaStaff = ac.newRole({
  cargo: ["read", "update", "arrive", "fulfill", "deliver"],
  branch: ["read"],
  payment: ["read", "update"],
});

const admin = ac.newRole({
  ...adminAc.statements,
  cargo: [
    "create",
    "read",
    "update",
    "receive",
    "ship",
    "arrive",
    "fulfill",
    "deliver",
    "pay",
  ],
  branch: ["create", "read", "update", "delete"],
  payment: ["create", "read", "update", "refund"],
});

export const authAccessControl = {
  ac,
  roles: {
    customer,
    china_staff: chinaStaff,
    mongolia_staff: mongoliaStaff,
    admin,
  },
} as const;
