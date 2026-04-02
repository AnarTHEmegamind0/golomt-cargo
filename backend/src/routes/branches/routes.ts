import { Elysia } from "elysia";
import { eq } from "drizzle-orm";
import { branch } from "~/db/schema";
import { withAudience } from "~/lib/openapi";
import { branchListResponseEnvelopeSchema } from "~/lib/schemas";
import { roleGuard } from "~/routes/_shared/auth";

export const branchRoutes = new Elysia().guard(
  roleGuard(["customer", "china_staff", "mongolia_staff", "admin"]),
  (app) =>
    app.get("/branches", async (ctx: any) => {
      const { db } = ctx;
      const rows = await db.select().from(branch).where(eq(branch.isActive, true)).orderBy(branch.name);
      return {
        message: "Branches retrieved successfully",
        data: rows.map((row: any) => ({
        id: row.id,
        code: row.code,
        name: row.name,
        address: row.address ?? null,
        phone: row.phone ?? null,
        isActive: row.isActive,
        })),
      };
    }, {
      detail: withAudience("shared", {
        tags: ["Branches"],
        summary: "List active branches",
      }),
      response: {
        200: branchListResponseEnvelopeSchema,
      },
    })
);
