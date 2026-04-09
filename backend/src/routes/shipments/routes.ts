import { createId } from "@paralleldrive/cuid2";
import { and, desc, eq, gte, inArray, lte, sql } from "drizzle-orm";
import { Elysia } from "elysia";
import { cargo, shipment, user, vehicle } from "~/db/schema";
import { insertAdminActivityLog } from "~/lib/operations/logging";
import { toCargoSummary, toShipmentSummary } from "~/lib/operations/serializers";
import { getCargoStatusForShipmentStatus, isValidShipmentTransition } from "~/lib/operations/shipments";
import {
  messageResponseSchema,
  shipmentCargoMutationSchema,
  shipmentCreateSchema,
  shipmentIdParamsSchema,
  shipmentListResponseEnvelopeSchema,
  shipmentQuerySchema,
  shipmentResponseEnvelopeSchema,
  shipmentStatusUpdateSchema,
} from "~/lib/schemas";
import { withAudience } from "~/lib/openapi";
import { insertStatusEvent, roleGuard } from "~/routes/_shared/auth";

const cargoSelection = {
  id: cargo.id,
  trackingNumber: cargo.trackingNumber,
  description: cargo.description,
  status: cargo.status,
  paymentStatus: cargo.paymentStatus,
  receivedImageUrl: cargo.receivedImageUrl,
  fulfillmentType: cargo.fulfillmentType,
  deliveryAddress: cargo.deliveryAddress,
  deliveryPhone: cargo.deliveryPhone,
  weightGrams: cargo.weightGrams,
  baseShippingFeeMnt: cargo.baseShippingFeeMnt,
  totalFeeMnt: cargo.totalFeeMnt,
  createdAt: cargo.createdAt,
  updatedAt: cargo.updatedAt,
  customerId: user.id,
  customerName: user.name,
  customerEmail: user.email,
  heightCm: cargo.heightCm,
  widthCm: cargo.widthCm,
  lengthCm: cargo.lengthCm,
  isFragile: cargo.isFragile,
  calculatedFeeMnt: cargo.calculatedFeeMnt,
  overrideFeeMnt: cargo.overrideFeeMnt,
  shipmentId: cargo.shipmentId,
};

const shipmentSelection = {
  id: shipment.id,
  vehicleId: shipment.vehicleId,
  vehiclePlateNumber: vehicle.plateNumber,
  status: shipment.status,
  createdAt: shipment.createdAt,
  departureDate: shipment.departureDate,
  arrivalDate: shipment.arrivalDate,
  note: shipment.note,
};

const toShipmentDetail = async (db: any, shipmentId: string) => {
  const [header] = await db
    .select(shipmentSelection)
    .from(shipment)
    .innerJoin(vehicle, eq(vehicle.id, shipment.vehicleId))
    .where(eq(shipment.id, shipmentId))
    .limit(1);

  if (!header) return null;

  const cargoRows = await db
    .select(cargoSelection)
    .from(cargo)
    .leftJoin(user, eq(user.id, cargo.customerId))
    .where(eq(cargo.shipmentId, shipmentId))
    .orderBy(desc(cargo.createdAt));

  return {
    ...toShipmentSummary(header, cargoRows.map((row: any) => row.id)),
    cargos: cargoRows.map(toCargoSummary),
  };
};

const getShipmentList = async (db: any, query: any) => {
  const page = query.page ?? 1;
  const limit = query.limit ?? 20;
  const offset = (page - 1) * limit;
  const conditions: any[] = [];

  if (query.status) conditions.push(eq(shipment.status, query.status));
  if (query.vehicleId) conditions.push(eq(shipment.vehicleId, query.vehicleId));
  if (query.dateFrom) conditions.push(gte(shipment.createdAt, new Date(`${query.dateFrom}T00:00:00.000Z`)));
  if (query.dateTo) conditions.push(lte(shipment.createdAt, new Date(`${query.dateTo}T23:59:59.999Z`)));

  const whereClause =
    conditions.length === 0 ? undefined : conditions.length === 1 ? conditions[0] : and(...conditions);

  const [totalRow] = whereClause
    ? await db.select({ count: sql<number>`count(*)` }).from(shipment).where(whereClause)
    : await db.select({ count: sql<number>`count(*)` }).from(shipment);

  const rows = whereClause
    ? await db
        .select(shipmentSelection)
        .from(shipment)
        .innerJoin(vehicle, eq(vehicle.id, shipment.vehicleId))
        .where(whereClause)
        .orderBy(desc(shipment.createdAt))
        .limit(limit)
        .offset(offset)
    : await db
        .select(shipmentSelection)
        .from(shipment)
        .innerJoin(vehicle, eq(vehicle.id, shipment.vehicleId))
        .orderBy(desc(shipment.createdAt))
        .limit(limit)
        .offset(offset);

  const shipmentIds = rows.map((row: any) => row.id);
  const cargoRows = shipmentIds.length
    ? await db
        .select({ shipmentId: cargo.shipmentId, cargoId: cargo.id })
        .from(cargo)
        .where(inArray(cargo.shipmentId, shipmentIds))
    : [];

  const cargoIdsByShipment = new Map<string, string[]>();
  for (const row of cargoRows) {
    if (!row.shipmentId) continue;
    const current = cargoIdsByShipment.get(row.shipmentId) ?? [];
    current.push(row.cargoId);
    cargoIdsByShipment.set(row.shipmentId, current);
  }

  return {
    message: "Shipments retrieved successfully",
    data: rows.map((row: any) => toShipmentSummary(row, cargoIdsByShipment.get(row.id) ?? [])),
    meta: {
      page,
      limit,
      total: Number(totalRow?.count ?? 0),
      totalPages: Number(totalRow?.count ?? 0) === 0 ? 0 : Math.ceil(Number(totalRow?.count ?? 0) / limit),
    },
  };
};

export const shipmentRoutes = new Elysia().guard(
  roleGuard(["china_staff", "admin"]),
  (app) =>
    app
      .get("/shipments", async ({ db, query }: any) => getShipmentList(db, query ?? {}), {
        detail: withAudience("staff", {
          tags: ["Shipments"],
          summary: "List shipments",
        }),
        query: shipmentQuerySchema,
        response: {
          200: shipmentListResponseEnvelopeSchema,
        },
      })
      .get("/shipments/:shipmentId", async ({ db, params, status }: any) => {
        const details = await toShipmentDetail(db, params.shipmentId);
        if (!details) return status(404, { message: "Shipment not found" });
        return {
          message: "Shipment retrieved successfully",
          data: details,
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Shipments"],
          summary: "Get shipment",
        }),
        params: shipmentIdParamsSchema,
        response: {
          200: shipmentResponseEnvelopeSchema,
          404: messageResponseSchema,
        },
      })
      .post("/shipments", async ({ db, body, authUser, status }: any) => {
        const [vehicleRow] = await db.select().from(vehicle).where(eq(vehicle.id, body.vehicle_id)).limit(1);
        if (!vehicleRow) return status(404, { message: "Vehicle not found" });

        const id = createId();
        await db.insert(shipment).values({
          id,
          vehicleId: body.vehicle_id,
          status: "DRAFT",
          note: body.note ?? null,
          departureDate: body.departure_date ? new Date(body.departure_date) : null,
          createdByUserId: authUser.id,
        });

        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "CREATE",
          targetType: "SHIPMENT",
          targetId: id,
          description: `Created shipment for vehicle ${vehicleRow.plateNumber}`,
          metadata: { vehicle_id: body.vehicle_id, departure_date: body.departure_date ?? null },
        });

        const details = await toShipmentDetail(db, id);
        return {
          message: "Shipment created successfully",
          data: details,
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Shipments"],
          summary: "Create shipment",
        }),
        body: shipmentCreateSchema,
        response: {
          200: shipmentResponseEnvelopeSchema,
          404: messageResponseSchema,
        },
      })
      .post("/shipments/:shipmentId/cargos", async ({ db, params, body, authUser, status }: any) => {
        const [shipmentRow] = await db.select().from(shipment).where(eq(shipment.id, params.shipmentId)).limit(1);
        if (!shipmentRow) return status(404, { message: "Shipment not found" });
        if (shipmentRow.status !== "DRAFT") return status(400, { message: "Only draft shipments can be modified" });

        const cargoRows = await db.select().from(cargo).where(inArray(cargo.id, body.cargo_ids));
        if (cargoRows.length !== body.cargo_ids.length) return status(404, { message: "Some cargos were not found" });

        for (const cargoRow of cargoRows) {
          if (cargoRow.shipmentId) return status(400, { message: "Some cargos are already assigned to a shipment" });
          if (!["CREATED", "RECEIVED_CHINA"].includes(cargoRow.status)) {
            return status(400, { message: "Only created or received cargos can be added to a shipment" });
          }
        }

        await db.update(cargo).set({ shipmentId: params.shipmentId }).where(inArray(cargo.id, body.cargo_ids));
        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "ASSIGN_SHIPMENT",
          targetType: "SHIPMENT",
          targetId: params.shipmentId,
          description: `Added ${body.cargo_ids.length} cargos to shipment`,
          metadata: { cargo_ids: body.cargo_ids },
        });

        return { message: "Cargos added to shipment successfully" };
      }, {
        detail: withAudience("staff", {
          tags: ["Shipments"],
          summary: "Add cargos to shipment",
        }),
        params: shipmentIdParamsSchema,
        body: shipmentCargoMutationSchema,
        response: {
          200: messageResponseSchema,
          400: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
      .delete("/shipments/:shipmentId/cargos", async ({ db, params, body, authUser, status }: any) => {
        const [shipmentRow] = await db.select().from(shipment).where(eq(shipment.id, params.shipmentId)).limit(1);
        if (!shipmentRow) return status(404, { message: "Shipment not found" });
        if (shipmentRow.status !== "DRAFT") return status(400, { message: "Only draft shipments can be modified" });

        await db
          .update(cargo)
          .set({ shipmentId: null })
          .where(and(eq(cargo.shipmentId, params.shipmentId), inArray(cargo.id, body.cargo_ids)));

        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "REMOVE_SHIPMENT_CARGO",
          targetType: "SHIPMENT",
          targetId: params.shipmentId,
          description: `Removed ${body.cargo_ids.length} cargos from shipment`,
          metadata: { cargo_ids: body.cargo_ids },
        });

        return { message: "Cargos removed from shipment successfully" };
      }, {
        detail: withAudience("staff", {
          tags: ["Shipments"],
          summary: "Remove cargos from shipment",
        }),
        params: shipmentIdParamsSchema,
        body: shipmentCargoMutationSchema,
        response: {
          200: messageResponseSchema,
          400: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
      .post("/shipments/:shipmentId/status", async ({ db, params, body, authUser, status }: any) => {
        const [shipmentRow] = await db.select().from(shipment).where(eq(shipment.id, params.shipmentId)).limit(1);
        if (!shipmentRow) return status(404, { message: "Shipment not found" });
        if (!isValidShipmentTransition(shipmentRow.status, body.status)) {
          return status(400, { message: "Invalid shipment status transition" });
        }

        const patch: Record<string, unknown> = { status: body.status };
        if (body.status === "DEPARTED" && !shipmentRow.departureDate) patch.departureDate = new Date();
        if (body.status === "ARRIVED") patch.arrivalDate = new Date();

        await db.update(shipment).set(patch).where(eq(shipment.id, params.shipmentId));

        const cargoRows = await db.select().from(cargo).where(eq(cargo.shipmentId, params.shipmentId));
        const cargoStatus = getCargoStatusForShipmentStatus(body.status);

        if (cargoStatus) {
          for (const cargoRow of cargoRows) {
            if (cargoRow.status !== cargoStatus) {
              const cargoPatch: Record<string, unknown> = { status: cargoStatus };
              if (body.status === "DEPARTED") cargoPatch.departedChinaAt = new Date();
              if (body.status === "ARRIVED") cargoPatch.arrivedInMongoliaAt = new Date();
              await db.update(cargo).set(cargoPatch).where(eq(cargo.id, cargoRow.id));
              await insertStatusEvent({
                db,
                cargoId: cargoRow.id,
                fromStatus: cargoRow.status,
                toStatus: cargoStatus,
                changedByUserId: authUser.id,
              });
            }
          }
        }

        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "STATUS_CHANGE",
          targetType: "SHIPMENT",
          targetId: params.shipmentId,
          description: `Shipment status changed from ${shipmentRow.status} to ${body.status}`,
          metadata: { from: shipmentRow.status, to: body.status },
        });

        const details = await toShipmentDetail(db, params.shipmentId);
        return {
          message: "Shipment status updated successfully",
          data: details,
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Shipments"],
          summary: "Update shipment status",
        }),
        params: shipmentIdParamsSchema,
        body: shipmentStatusUpdateSchema,
        response: {
          200: shipmentResponseEnvelopeSchema,
          400: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
);
