import { Elysia } from "elysia";
import { eq } from "drizzle-orm";
import { cargo } from "~/db/schema";
import {
  cargoIdParamsSchema,
  messageResponseSchema,
  successMessageResponseSchema,
} from "~/lib/schemas";
import { withAudience } from "~/lib/openapi";
import { insertStatusEvent, roleGuard } from "~/routes/_shared/auth";

export const mongoliaCargoRoutes = new Elysia().guard(
  roleGuard(["mongolia_staff", "admin"]),
  (app) =>
    app.post("/cargos/:cargoId/arrive", async (ctx: any) => {
      const { params, db, status, authUser } = ctx;
      const [item] = await db.select().from(cargo).where(eq(cargo.id, params.cargoId)).limit(1);
      if (!item) return status(404, { message: "Cargo not found" });

      await db
        .update(cargo)
        .set({
          status: "AWAITING_FULFILLMENT_CHOICE",
          arrivedInMongoliaAt: new Date(),
        })
        .where(eq(cargo.id, params.cargoId));

      await insertStatusEvent({
        db,
        cargoId: params.cargoId,
        fromStatus: item.status,
        toStatus: "AWAITING_FULFILLMENT_CHOICE",
        changedByUserId: authUser.id,
      });

      return { message: "Cargo marked as arrived in Mongolia" };
    }, {
      detail: withAudience("staff", {
        tags: ["Cargos"],
        summary: "Mark cargo arrived in Mongolia",
        responses: {
          200: {
            description: "Marked as arrived",
          },
        },
      }),
      params: cargoIdParamsSchema,
      response: {
        200: successMessageResponseSchema,
        404: messageResponseSchema,
      },
    })
);
