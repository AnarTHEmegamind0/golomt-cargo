import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { openAPI } from "better-auth/plugins";
import { admin as adminPlugin } from "better-auth/plugins";
import { bearer } from "better-auth/plugins";
import { db } from "~/db";
import * as schema from "~/db/schema";
import { authAccessControl } from "~/lib/auth/permissions";
import { customerBearerAuthScheme, staffBearerAuthScheme } from "~/lib/openapi";
import { env } from "~/lib/platform/env";

export const auth = betterAuth({
  basePath: "/auth",
  database: drizzleAdapter(db, {
    provider: "sqlite",
    schema,
  }),
  secondaryStorage: {
    get: async (key: string) => env.CACHE.get(key),
    set: async (key: string, value: string, ttl?: number) => {
      if (ttl && ttl > 0) {
        await env.CACHE.put(key, value, { expirationTtl: Math.ceil(ttl) });
        return;
      }

      await env.CACHE.put(key, value);
    },
    delete: async (key: string) => {
      await env.CACHE.delete(key);
    },
  },
  emailAndPassword: { enabled: true, minPasswordLength: 8 },
  trustedOrigins: ["http://localhost:3000"],
  plugins: [
    bearer(),
    adminPlugin({
      ac: authAccessControl.ac,
      roles: authAccessControl.roles,
      defaultRole: "customer",
      adminRoles: ["admin"],
    }),
    openAPI(),
  ],
});

let _schema: ReturnType<typeof auth.api.generateOpenAPISchema>;
const getSchema = async () => (_schema ??= auth.api.generateOpenAPISchema());

export const OpenAPI = {
  getPaths: (prefix = "/auth") =>
    getSchema().then(({ paths }) => {
      const reference: typeof paths = Object.create(null);

      for (const path of Object.keys(paths)) {
        const key = prefix + path;
        reference[key] = paths[path];

        for (const method of Object.keys(paths[path])) {
          const operation = (reference[key] as any)[method];
          const isAdminRoute = path.startsWith("/admin/");
          const hasBearerSecurity = Array.isArray(operation.security)
            && operation.security.some((entry: Record<string, unknown>) => "bearerAuth" in entry);

          operation.tags = [isAdminRoute ? "Staff/Admin Auth" : "Auth"];

          if (hasBearerSecurity) {
            operation.security = isAdminRoute
              ? [{ [staffBearerAuthScheme]: [] }]
              : [{ [customerBearerAuthScheme]: [] }, { [staffBearerAuthScheme]: [] }];
          }

          if (path === "/sign-in/email") {
            operation.description = [
              "Sign in with email and password.",
              "Customer accounts receive customer bearer tokens.",
              "Admin, china_staff, and mongolia_staff accounts receive staff/admin bearer tokens.",
            ].join(" ");
          }

          if (path === "/sign-up/email") {
            operation.description = [operation.description, "This flow creates customer accounts only."]
              .filter(Boolean)
              .join(" ");
          }
        }
      }

      return reference;
    }) as Promise<any>,
  components: getSchema().then(({ components }) => components) as Promise<any>,
} as const;
