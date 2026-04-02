import { Elysia } from "elysia";
import { eq } from "drizzle-orm";
import { cargo } from "~/db/schema";
import {
  cargoIdParamsSchema,
  markWeightResponseEnvelopeSchema,
  messageResponseSchema,
  receiveCargoSchema,
  receivedImageResponseEnvelopeSchema,
  recordWeightSchema,
  successMessageResponseSchema,
} from "~/lib/schemas";
import { withAudience } from "~/lib/openapi";
import { insertStatusEvent, roleGuard } from "~/routes/_shared/auth";

const extFromType = (contentType?: string | null) => {
  if (!contentType) return "bin";
  if (contentType === "image/jpeg") return "jpg";
  if (contentType === "image/png") return "png";
  if (contentType === "image/webp") return "webp";
  return "bin";
};

export const chinaCargoRoutes = new Elysia().guard(
  roleGuard(["china_staff", "admin"]),
  (app) =>
    app
      .post("/cargos/:cargoId/receive", async (ctx: any) => {
        const { params, body, db, status, authUser, cf } = ctx;
        const [item] = await db.select().from(cargo).where(eq(cargo.id, params.cargoId)).limit(1);
        if (!item) return status(404, { message: "Cargo not found" });

        let receivedImageObjectKey: string | null = null;
        let receivedImageUrl: string | null = null;

        const receiveInput = body;

        if (receiveInput.image) {
          const ext = extFromType(receiveInput.image.type);
          const objectKey = `cargo/${params.cargoId}/received-${Date.now()}.${ext}`;

          await cf.bindings.BUCKET.put(objectKey, await receiveInput.image.arrayBuffer(), {
            httpMetadata: {
              contentType: receiveInput.image.type || "application/octet-stream",
            },
          });

          receivedImageObjectKey = objectKey;
          receivedImageUrl = `/api/cargos/${params.cargoId}/received-image`;
        }

        await db
          .update(cargo)
          .set({
            status: "RECEIVED_CHINA",
            receivedInChinaAt: new Date(),
            receivedImageObjectKey,
            receivedImageUrl,
          })
          .where(eq(cargo.id, params.cargoId));

        await insertStatusEvent({
          db,
          cargoId: params.cargoId,
          fromStatus: item.status,
          toStatus: "RECEIVED_CHINA",
          changedByUserId: authUser.id,
        });

        return {
          message: "Cargo received successfully",
          receivedImageUrl,
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Cargos"],
          summary: "Mark cargo as received in China",
          description: "Optionally uploads a parcel image to R2 and stores a retrievable link",
          requestBody: {
            required: false,
            content: {
              "multipart/form-data": {
                schema: {
                  type: "object",
                  properties: {
                    image: {
                      type: "string",
                      format: "binary",
                    },
                  },
                },
              },
            },
          },
        }),
        params: cargoIdParamsSchema,
        body: receiveCargoSchema,
        response: {
          200: receivedImageResponseEnvelopeSchema,
          400: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
      .post("/cargos/:cargoId/ship", async (ctx: any) => {
        const { params, db, status, authUser } = ctx;
        const [item] = await db.select().from(cargo).where(eq(cargo.id, params.cargoId)).limit(1);
        if (!item) return status(404, { message: "Cargo not found" });

        await db
          .update(cargo)
          .set({ status: "IN_TRANSIT_TO_MN", departedChinaAt: new Date() })
          .where(eq(cargo.id, params.cargoId));

        await insertStatusEvent({
          db,
          cargoId: params.cargoId,
          fromStatus: item.status,
          toStatus: "IN_TRANSIT_TO_MN",
          changedByUserId: authUser.id,
        });

        return { message: "Cargo shipped successfully" };
      }, {
        detail: withAudience("staff", {
          tags: ["Cargos"],
          summary: "Mark cargo shipped to Mongolia",
          responses: {
            200: {
              description: "Marked as in transit",
            },
          },
        }),
        params: cargoIdParamsSchema,
        response: {
          200: successMessageResponseSchema,
          404: messageResponseSchema,
        },
      })
      .post("/cargos/:cargoId/record-weight", async (ctx: any) => {
        const { params, body, db, status } = ctx;
        const input = body;
        const [item] = await db.select().from(cargo).where(eq(cargo.id, params.cargoId)).limit(1);
        if (!item) return status(404, { message: "Cargo not found" });

        const totalFeeMnt = input.baseShippingFeeMnt + (item.localDeliveryFeeMnt ?? 0);

        await db
          .update(cargo)
          .set({
            weightGrams: input.weightGrams,
            baseShippingFeeMnt: input.baseShippingFeeMnt,
            totalFeeMnt,
          })
          .where(eq(cargo.id, params.cargoId));

        return {
          message: "Cargo weight recorded successfully",
          totalFeeMnt,
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Cargos"],
          summary: "Record cargo weight and fee",
        }),
        params: cargoIdParamsSchema,
        body: recordWeightSchema,
        response: {
          200: markWeightResponseEnvelopeSchema,
          400: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
);
