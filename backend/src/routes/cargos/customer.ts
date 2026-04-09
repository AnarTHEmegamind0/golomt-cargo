import { Elysia } from "elysia";
import { createId } from "@paralleldrive/cuid2";
import { and, desc, eq, inArray, like, or, sql } from "drizzle-orm";
import { cargo, cargoStatusEvent, user } from "~/db/schema";
import {
  cargoSearchQuerySchema,
  cargoStatsResponseEnvelopeSchema,
  cargoIdParamsSchema,
  cargoListQuerySchema,
  cargoEventsResponseEnvelopeSchema,
  cargoListResponseEnvelopeSchema,
  cargoResponseEnvelopeSchema,
  chooseFulfillmentSchema,
  createCargoSchema,
  messageResponseSchema,
} from "~/lib/schemas";
import { withAudience } from "~/lib/openapi";
import { insertStatusEvent, isCustomer, roleGuard } from "~/routes/_shared/auth";

const cargoSummarySelection = {
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

const toCargoSummary = (row: any) => ({
  id: row.id,
  trackingNumber: row.trackingNumber,
  description: row.description ?? null,
  status: row.status,
  paymentStatus: row.paymentStatus,
  receivedImageUrl: row.receivedImageUrl ?? null,
  fulfillmentType: row.fulfillmentType ?? null,
  deliveryAddress: row.deliveryAddress ?? null,
  deliveryPhone: row.deliveryPhone ?? null,
  weightGrams: row.weightGrams ?? null,
  baseShippingFeeMnt: row.baseShippingFeeMnt ?? null,
  totalFeeMnt: row.totalFeeMnt ?? null,
  createdAt: row.createdAt ? new Date(row.createdAt).toISOString() : null,
  updatedAt: row.updatedAt ? new Date(row.updatedAt).toISOString() : null,
  customer: row.customerId
    ? {
        id: row.customerId,
        name: row.customerName,
        email: row.customerEmail,
      }
    : null,
  heightCm: row.heightCm ?? null,
  widthCm: row.widthCm ?? null,
  lengthCm: row.lengthCm ?? null,
  isFragile: Boolean(row.isFragile ?? false),
  calculatedFeeMnt: row.calculatedFeeMnt ?? null,
  overrideFeeMnt: row.overrideFeeMnt ?? null,
  shipmentId: row.shipmentId ?? null,
});

const toCargoEvent = (row: any) => ({
  id: row.id,
  fromStatus: row.fromStatus ?? null,
  toStatus: row.toStatus,
  note: row.note ?? null,
  createdAt: new Date(row.createdAt).toISOString(),
});

const getPagination = (query: Record<string, any>) => {
  const page = query.page ?? 1;
  const limit = query.limit ?? 20;
  return {
    page,
    limit,
    offset: (page - 1) * limit,
  };
};

const toPaginationMeta = (page: number, limit: number, total: number) => ({
  page,
  limit,
  total,
  totalPages: total === 0 ? 0 : Math.ceil(total / limit),
});

const normalizedDeliveryPhone = sql<string>`replace(replace(replace(replace(replace(coalesce(${cargo.deliveryPhone}, ''), ' ', ''), '-', ''), '+', ''), '(', ''), ')', '')`;

const normalizePhoneTerm = (value?: string | null) => value?.replace(/[^\d]/g, "") ?? "";

export const customerCargoRoutes = new Elysia()
  .guard(roleGuard(["customer", "admin"]), (app) =>
    app
      .post("/cargos", async (ctx: any) => {
        const { body, db, status, authUser } = ctx;
        const input = body;
        const [duplicate] = await db
          .select({ id: cargo.id })
          .from(cargo)
          .where(eq(cargo.trackingNumber, input.trackingNumber))
          .limit(1);

        if (duplicate) return status(409, { message: "Tracking number already exists" });

        const cargoId = createId();
        await db.insert(cargo).values({
          id: cargoId,
          customerId: authUser.id,
          trackingNumber: input.trackingNumber,
          description: input.description ?? null,
          status: "CREATED",
        });

        await insertStatusEvent({
          db,
          cargoId,
          fromStatus: null,
          toStatus: "CREATED",
          changedByUserId: authUser.id,
        });

        const [created] = await db
          .select(cargoSummarySelection)
          .from(cargo)
          .leftJoin(user, eq(user.id, cargo.customerId))
          .where(eq(cargo.id, cargoId))
          .limit(1);
        return {
          message: "Cargo created successfully",
          data: toCargoSummary(created),
        };
      }, {
        detail: withAudience("customer", {
          tags: ["Cargos"],
          summary: "Create cargo",
          description: "Create a cargo by tracking number with optional description",
        }),
        body: createCargoSchema,
        response: {
          200: cargoResponseEnvelopeSchema,
          409: messageResponseSchema,
        },
      })
      .post("/cargos/:cargoId/fulfillment-choice", async (ctx: any) => {
        const { params, body, db, status, authUser } = ctx;
        const input = body;
        if (
          input.fulfillmentType === "HOME_DELIVERY" &&
          (!input.deliveryAddress || !input.deliveryPhone)
        ) {
          return status(400, {
            message: "deliveryAddress and deliveryPhone are required for HOME_DELIVERY",
          });
        }

        const [item] = await db
          .select()
          .from(cargo)
          .where(eq(cargo.id, params.cargoId))
          .limit(1);
        if (!item) return status(404, { message: "Cargo not found" });
        if (isCustomer(authUser.role) && item.customerId !== authUser.id) {
          return status(403, { message: "Forbidden" });
        }
        if (!item.arrivedInMongoliaAt) {
          return status(400, { message: "Choose fulfillment after arrival in Mongolia" });
        }

        const nextStatus =
          input.fulfillmentType === "PICKUP" ? "READY_FOR_PICKUP" : "OUT_FOR_DELIVERY";

        await db
          .update(cargo)
          .set({
            fulfillmentType: input.fulfillmentType,
            deliveryAddress: input.deliveryAddress ?? null,
            deliveryPhone: input.deliveryPhone ?? null,
            fulfillmentSelectedAt: new Date(),
            status: nextStatus,
          })
          .where(eq(cargo.id, params.cargoId));

        await insertStatusEvent({
          db,
          cargoId: params.cargoId,
          fromStatus: item.status,
          toStatus: nextStatus,
          changedByUserId: authUser.id,
        });

        return { message: "Fulfillment updated successfully" };
      }, {
        params: cargoIdParamsSchema,
        body: chooseFulfillmentSchema,
        detail: withAudience("customer", {
          tags: ["Cargos"],
          summary: "Choose fulfillment",
          description: "Set pickup or home delivery after the cargo has arrived in Mongolia",
          responses: {
            200: {
              description: "Fulfillment updated",
            },
          },
        }),
        response: {
          200: messageResponseSchema,
          400: messageResponseSchema,
          403: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
  )
  .guard(roleGuard(["customer", "china_staff", "mongolia_staff", "admin"]), (app) =>
    app
      .get("/cargos", async (ctx: any) => {
        const { db, authUser, query } = ctx;
        const filters = query ?? {};
        const { page, limit, offset } = getPagination(filters);

        const conditions: any[] = [];

        if (isCustomer(authUser.role)) {
          conditions.push(eq(cargo.customerId, authUser.id));
        }

        if (filters.status) conditions.push(eq(cargo.status, filters.status));
        if (filters.paymentStatus) {
          conditions.push(eq(cargo.paymentStatus, filters.paymentStatus));
        }
        if (filters.fulfillmentType) {
          conditions.push(eq(cargo.fulfillmentType, filters.fulfillmentType));
        }
        if (filters.trackingNumber) {
          conditions.push(like(cargo.trackingNumber, `%${filters.trackingNumber}%`));
        }

        const whereClause =
          conditions.length === 0
            ? undefined
            : conditions.length === 1
              ? conditions[0]
              : and(...conditions);

        const [totalRow] = whereClause
          ? await db
              .select({ count: sql<number>`count(*)` })
              .from(cargo)
              .where(whereClause)
          : await db.select({ count: sql<number>`count(*)` }).from(cargo);

        const queryBuilder = whereClause
          ? db
              .select(cargoSummarySelection)
              .from(cargo)
              .leftJoin(user, eq(user.id, cargo.customerId))
              .where(whereClause)
          : db.select(cargoSummarySelection).from(cargo).leftJoin(user, eq(user.id, cargo.customerId));

        return queryBuilder
          .orderBy(desc(cargo.createdAt))
          .limit(limit)
          .offset(offset)
          .then((rows: any[]) => ({
            message: "Cargos retrieved successfully",
            data: rows.map(toCargoSummary),
            meta: toPaginationMeta(page, limit, Number(totalRow?.count ?? 0)),
          }));
      }, {
        detail: withAudience("shared", {
          tags: ["Cargos"],
          summary: "List cargos",
          description: "List cargos with optional filters by status, payment status, fulfillment type, or tracking number",
        }),
        query: cargoListQuerySchema,
        response: {
          200: cargoListResponseEnvelopeSchema,
        },
      })
      .get("/cargos/search", async (ctx: any) => {
        const { db, authUser, query, status } = ctx;
        const filters = query;
        const isAdmin = authUser.role === "admin";
        const { page, limit, offset } = getPagination(filters);
        const phoneQuery = normalizePhoneTerm(filters.q);
        const phoneFilter = normalizePhoneTerm(filters.phone);

        if (!isAdmin && (filters.customerName || filters.customerEmail)) {
          return status(403, {
            message: "Only admin can filter by customer fields",
          });
        }

        const conditions: any[] = [];
        if (isCustomer(authUser.role)) {
          conditions.push(eq(cargo.customerId, authUser.id));
        }

        conditions.push(
          or(
            like(cargo.trackingNumber, `%${filters.q}%`),
            like(sql`coalesce(${cargo.description}, '')`, `%${filters.q}%`),
            like(sql`coalesce(${cargo.deliveryPhone}, '')`, `%${filters.q}%`),
            ...(phoneQuery ? [like(normalizedDeliveryPhone, `%${phoneQuery}%`)] : [])
          )
        );

        if (filters.trackingNumber) {
          conditions.push(like(cargo.trackingNumber, `%${filters.trackingNumber}%`));
        }

        if (filters.phone) {
          conditions.push(
            or(
              like(sql`coalesce(${cargo.deliveryPhone}, '')`, `%${filters.phone}%`),
              ...(phoneFilter ? [like(normalizedDeliveryPhone, `%${phoneFilter}%`)] : [])
            )
          );
        }

        if (filters.status) conditions.push(eq(cargo.status, filters.status));
        if (filters.paymentStatus) {
          conditions.push(eq(cargo.paymentStatus, filters.paymentStatus));
        }
        if (filters.fulfillmentType) {
          conditions.push(eq(cargo.fulfillmentType, filters.fulfillmentType));
        }

        if (isAdmin && (filters.customerName || filters.customerEmail)) {
          const userConditions: any[] = [];
          if (filters.customerName) {
            userConditions.push(like(user.name, `%${filters.customerName}%`));
          }
          if (filters.customerEmail) {
            userConditions.push(like(user.email, `%${filters.customerEmail}%`));
          }

          const userWhere =
            userConditions.length === 1 ? userConditions[0] : and(...userConditions);

          const matchedUsers = await db
            .select({ id: user.id })
            .from(user)
            .where(userWhere);

          if (!matchedUsers.length) {
            return {
              message: "Cargo search completed successfully",
              data: [],
              meta: toPaginationMeta(page, limit, 0),
            };
          }

          conditions.push(inArray(cargo.customerId, matchedUsers.map((u: any) => u.id)));
        }

        const whereClause = conditions.length === 1 ? conditions[0] : and(...conditions);

        const [totalRow] = await db
          .select({ count: sql<number>`count(*)` })
          .from(cargo)
          .leftJoin(user, eq(user.id, cargo.customerId))
          .where(whereClause);

        const rows = await db
          .select(cargoSummarySelection)
          .from(cargo)
          .leftJoin(user, eq(user.id, cargo.customerId))
          .where(whereClause)
          .orderBy(desc(cargo.createdAt))
          .limit(limit)
          .offset(offset);

        return {
          message: "Cargo search completed successfully",
          data: rows.map(toCargoSummary),
          meta: toPaginationMeta(page, limit, Number(totalRow?.count ?? 0)),
        };
      }, {
        detail: withAudience("shared", {
          tags: ["Cargos"],
          summary: "Search cargos",
          description:
            "Search by tracking number, phone, description, and optional status filters. Admin can also filter by customer name/email.",
        }),
        query: cargoSearchQuerySchema,
        response: {
          200: cargoListResponseEnvelopeSchema,
          403: messageResponseSchema,
        },
      })
      .get("/cargos/stats", async (ctx: any) => {
        const { db, authUser } = ctx;

        const scopeCondition = isCustomer(authUser.role)
          ? eq(cargo.customerId, authUser.id)
          : undefined;

        const totalRows = scopeCondition
          ? await db.select({ count: sql<number>`count(*)` }).from(cargo).where(scopeCondition)
          : await db.select({ count: sql<number>`count(*)` }).from(cargo);

        const statusRows = scopeCondition
          ? await db
              .select({ status: cargo.status, count: sql<number>`count(*)` })
              .from(cargo)
              .where(scopeCondition)
              .groupBy(cargo.status)
          : await db
              .select({ status: cargo.status, count: sql<number>`count(*)` })
              .from(cargo)
              .groupBy(cargo.status);

        const paymentRows = scopeCondition
          ? await db
              .select({ paymentStatus: cargo.paymentStatus, count: sql<number>`count(*)` })
              .from(cargo)
              .where(scopeCondition)
              .groupBy(cargo.paymentStatus)
          : await db
              .select({ paymentStatus: cargo.paymentStatus, count: sql<number>`count(*)` })
              .from(cargo)
              .groupBy(cargo.paymentStatus);

        const byStatus = {
          CREATED: 0,
          RECEIVED_CHINA: 0,
          IN_TRANSIT_TO_MN: 0,
          ARRIVED_MN: 0,
          AWAITING_FULFILLMENT_CHOICE: 0,
          READY_FOR_PICKUP: 0,
          OUT_FOR_DELIVERY: 0,
          COMPLETED_PICKUP: 0,
          COMPLETED_DELIVERY: 0,
        };

        for (const row of statusRows) {
          if (row.status) (byStatus as any)[row.status] = Number(row.count ?? 0);
        }

        const byPaymentStatus = {
          UNPAID: 0,
          PAID: 0,
        };

        for (const row of paymentRows) {
          if (row.paymentStatus) {
            (byPaymentStatus as any)[row.paymentStatus] = Number(row.count ?? 0);
          }
        }

        return {
          message: "Cargo stats retrieved successfully",
          data: {
            total: Number(totalRows[0]?.count ?? 0),
            byStatus,
            byPaymentStatus,
          },
        };
      }, {
        detail: withAudience("shared", {
          tags: ["Cargos"],
          summary: "Cargo statistics",
          description: "Get counts by cargo status and payment status",
        }),
        response: {
          200: cargoStatsResponseEnvelopeSchema,
        },
      })
      .get("/cargos/:cargoId", async (ctx: any) => {
        const { params, db, authUser, status } = ctx;
        const [item] = await db
          .select(cargoSummarySelection)
          .from(cargo)
          .leftJoin(user, eq(user.id, cargo.customerId))
          .where(eq(cargo.id, params.cargoId))
          .limit(1);
        if (!item) return status(404, { message: "Cargo not found" });

        if (isCustomer(authUser.role) && item.customerId !== authUser.id) {
          return status(403, { message: "Forbidden" });
        }

        return {
          message: "Cargo retrieved successfully",
          data: toCargoSummary(item),
        };
      }, {
        detail: withAudience("shared", {
          tags: ["Cargos"],
          summary: "Get cargo by id",
        }),
        params: cargoIdParamsSchema,
        response: {
          200: cargoResponseEnvelopeSchema,
          403: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
      .get("/cargos/:cargoId/events", async (ctx: any) => {
        const { params, db, authUser, status } = ctx;
        const [item] = await db
          .select({ customerId: cargo.customerId })
          .from(cargo)
          .where(eq(cargo.id, params.cargoId))
          .limit(1);
        if (!item) return status(404, { message: "Cargo not found" });

        if (isCustomer(authUser.role) && item.customerId !== authUser.id) {
          return status(403, { message: "Forbidden" });
        }

        return db
          .select()
          .from(cargoStatusEvent)
          .where(eq(cargoStatusEvent.cargoId, params.cargoId))
          .orderBy(desc(cargoStatusEvent.createdAt))
          .then((rows: any[]) => ({
            message: "Cargo events retrieved successfully",
            data: rows.map(toCargoEvent),
          }));
      }, {
        detail: withAudience("shared", {
          tags: ["Cargos"],
          summary: "Get cargo status timeline",
        }),
        params: cargoIdParamsSchema,
        response: {
          200: cargoEventsResponseEnvelopeSchema,
          403: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
      .get("/cargos/:cargoId/received-image", async (ctx: any) => {
        const { params, db, authUser, status, cf } = ctx;
        const [item] = await db.select().from(cargo).where(eq(cargo.id, params.cargoId)).limit(1);
        if (!item) return status(404, { message: "Cargo not found" });

        if (isCustomer(authUser.role) && item.customerId !== authUser.id) {
          return status(403, { message: "Forbidden" });
        }

        if (!item.receivedImageObjectKey) {
          return status(404, { message: "No image uploaded" });
        }

        const object = await cf.bindings.BUCKET.get(item.receivedImageObjectKey);
        if (!object) return status(404, { message: "Image not found" });

        return new Response(object.body, {
          headers: {
            "content-type": object.httpMetadata?.contentType ?? "application/octet-stream",
            "cache-control": "private, max-age=3600",
          },
        });
      }, {
        detail: withAudience("shared", {
          tags: ["Cargos"],
          summary: "Get received image",
          description: "Returns the uploaded parcel image from China warehouse",
          responses: {
            200: {
              description: "Image file",
              content: {
                "image/*": {
                  schema: {
                    type: "string",
                    format: "binary",
                  },
                },
              },
            },
          },
        }),
        params: cargoIdParamsSchema,
        response: {
          403: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
  );
