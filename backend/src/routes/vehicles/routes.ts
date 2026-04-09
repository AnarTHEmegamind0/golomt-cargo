import { createId } from "@paralleldrive/cuid2";
import { desc, eq } from "drizzle-orm";
import { Elysia } from "elysia";
import { vehicle, shipment } from "~/db/schema";
import { insertAdminActivityLog } from "~/lib/operations/logging";
import { toVehicleSummary } from "~/lib/operations/serializers";
import {
  messageResponseSchema,
  vehicleCreateSchema,
  vehicleIdParamsSchema,
  vehicleListResponseEnvelopeSchema,
  vehicleResponseEnvelopeSchema,
  vehicleUpdateSchema,
} from "~/lib/schemas";
import { withAudience } from "~/lib/openapi";
import { roleGuard } from "~/routes/_shared/auth";

export const vehicleRoutes = new Elysia().guard(
  roleGuard(["china_staff", "admin"]),
  (app) =>
    app
      .get("/vehicles", async ({ db }: any) => {
        const rows = await db.select().from(vehicle).orderBy(desc(vehicle.createdAt));
        return {
          message: "Vehicles retrieved successfully",
          data: rows.map(toVehicleSummary),
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Vehicles"],
          summary: "List vehicles",
        }),
        response: {
          200: vehicleListResponseEnvelopeSchema,
        },
      })
      .post("/vehicles", async ({ db, body, authUser, status }: any) => {
        const duplicate = await db
          .select({ id: vehicle.id })
          .from(vehicle)
          .where(eq(vehicle.plateNumber, body.plate_number))
          .limit(1);
        if (duplicate.length) return status(409, { message: "Vehicle plate number already exists" });

        const id = createId();
        await db.insert(vehicle).values({
          id,
          plateNumber: body.plate_number,
          name: body.name,
          type: body.type,
          isActive: true,
          createdByUserId: authUser.id,
        });

        const [created] = await db.select().from(vehicle).where(eq(vehicle.id, id)).limit(1);
        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "CREATE",
          targetType: "VEHICLE",
          targetId: id,
          description: `Created vehicle ${body.plate_number}`,
          metadata: { plate_number: body.plate_number, type: body.type },
        });

        return {
          message: "Vehicle created successfully",
          data: toVehicleSummary(created),
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Vehicles"],
          summary: "Create vehicle",
        }),
        body: vehicleCreateSchema,
        response: {
          200: vehicleResponseEnvelopeSchema,
          409: messageResponseSchema,
        },
      })
      .put("/vehicles/:vehicleId", async ({ db, params, body, authUser, status }: any) => {
        const [existing] = await db.select().from(vehicle).where(eq(vehicle.id, params.vehicleId)).limit(1);
        if (!existing) return status(404, { message: "Vehicle not found" });

        if (body.plate_number && body.plate_number !== existing.plateNumber) {
          const duplicate = await db
            .select({ id: vehicle.id })
            .from(vehicle)
            .where(eq(vehicle.plateNumber, body.plate_number))
            .limit(1);
          if (duplicate.length) return status(409, { message: "Vehicle plate number already exists" });
        }

        await db
          .update(vehicle)
          .set({
            plateNumber: body.plate_number ?? existing.plateNumber,
            name: body.name ?? existing.name,
            type: body.type ?? existing.type,
            isActive: body.is_active ?? existing.isActive,
          })
          .where(eq(vehicle.id, params.vehicleId));

        const [updated] = await db.select().from(vehicle).where(eq(vehicle.id, params.vehicleId)).limit(1);
        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "UPDATE",
          targetType: "VEHICLE",
          targetId: params.vehicleId,
          description: `Updated vehicle ${updated.plateNumber}`,
          metadata: body,
        });

        return {
          message: "Vehicle updated successfully",
          data: toVehicleSummary(updated),
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Vehicles"],
          summary: "Update vehicle",
        }),
        params: vehicleIdParamsSchema,
        body: vehicleUpdateSchema,
        response: {
          200: vehicleResponseEnvelopeSchema,
          404: messageResponseSchema,
          409: messageResponseSchema,
        },
      })
      .delete("/vehicles/:vehicleId", async ({ db, params, authUser, status }: any) => {
        const [existing] = await db.select().from(vehicle).where(eq(vehicle.id, params.vehicleId)).limit(1);
        if (!existing) return status(404, { message: "Vehicle not found" });

        const activeShipment = await db
          .select({ id: shipment.id })
          .from(shipment)
          .where(eq(shipment.vehicleId, params.vehicleId))
          .limit(1);
        if (activeShipment.length) {
          return status(409, { message: "Vehicle cannot be deleted while linked shipments exist" });
        }

        await db.delete(vehicle).where(eq(vehicle.id, params.vehicleId));
        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "DELETE",
          targetType: "VEHICLE",
          targetId: params.vehicleId,
          description: `Deleted vehicle ${existing.plateNumber}`,
          metadata: { plate_number: existing.plateNumber },
        });

        return { message: "Vehicle deleted successfully" };
      }, {
        detail: withAudience("staff", {
          tags: ["Vehicles"],
          summary: "Delete vehicle",
        }),
        params: vehicleIdParamsSchema,
        response: {
          200: messageResponseSchema,
          404: messageResponseSchema,
          409: messageResponseSchema,
        },
      })
);
