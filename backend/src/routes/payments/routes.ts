import { Elysia } from "elysia";
import { and, desc, eq, inArray, like } from "drizzle-orm";
import { createId } from "@paralleldrive/cuid2";
import { cargo, payment, paymentCargo } from "~/db/schema";
import {
  createBatchPaymentResponseEnvelopeSchema,
  createBatchPaymentSchema,
  messageResponseSchema,
  paymentListResponseEnvelopeSchema,
  paymentSearchQuerySchema,
  paymentIdParamsSchema,
  successMessageResponseSchema,
} from "~/lib/schemas";
import { withAudience } from "~/lib/openapi";
import { isCustomer, roleGuard } from "~/routes/_shared/auth";

const toPaymentSummary = (row: any) => ({
  id: row.id,
  customerId: row.customerId,
  status: row.status,
  method: row.method,
  totalAmountMnt: row.totalAmountMnt,
  currency: row.currency,
  paidAt: row.paidAt ? new Date(row.paidAt).toISOString() : null,
  createdAt: new Date(row.createdAt).toISOString(),
});

export const paymentRoutes = new Elysia()
  .guard(roleGuard(["customer", "admin"]), (app) =>
    app.post(
      "/payments",
      async (ctx: any) => {
        const { body, db, status, authUser } = ctx;

        const input = body;
        let whereClause = and(inArray(cargo.id, input.cargoIds), eq(cargo.paymentStatus, "UNPAID"));

        if (isCustomer(authUser.role)) {
          whereClause = and(whereClause, eq(cargo.customerId, authUser.id));
        }

        const cargoRows = await db.select().from(cargo).where(whereClause);
        if (!cargoRows.length) return status(400, { message: "No payable cargo found" });
        if (cargoRows.length !== input.cargoIds.length) {
          return status(400, { message: "Some cargo items are not payable" });
        }

        const totalAmountMnt = cargoRows.reduce(
          (sum: number, row: any) => sum + (row.totalFeeMnt ?? row.baseShippingFeeMnt ?? 0),
          0
        );

        const paymentId = createId();
        await db.insert(payment).values({
          id: paymentId,
          customerId: cargoRows[0].customerId,
          status: "PENDING",
          method: input.method,
          totalAmountMnt,
          note: input.note ?? null,
        });

        await db.insert(paymentCargo).values(
          cargoRows.map((row: any) => ({
            id: createId(),
            paymentId,
            cargoId: row.id,
            amountMnt: row.totalFeeMnt ?? row.baseShippingFeeMnt ?? 0,
          }))
        );

        return {
          message: "Batch payment created successfully",
          paymentId,
          totalAmountMnt,
          cargoCount: cargoRows.length,
        };
      },
      {
        detail: withAudience("customer", {
          tags: ["Payments"],
          summary: "Create batch payment",
        }),
        body: createBatchPaymentSchema,
        response: {
          200: createBatchPaymentResponseEnvelopeSchema,
          400: messageResponseSchema,
        },
      }
    )
  )
  .guard(roleGuard(["customer", "china_staff", "mongolia_staff", "admin"]), (app) =>
    app.get(
      "/payments/search",
      async (ctx: any) => {
        const { db, query, authUser } = ctx;
        const filters = query;

        let paymentIdsByCargo: string[] | null = null;
        if (filters.cargoId) {
          const links = await db
            .select({ paymentId: paymentCargo.paymentId })
            .from(paymentCargo)
            .where(eq(paymentCargo.cargoId, filters.cargoId));

          const ids = links.map((x: any) => x.paymentId);
          if (ids.length === 0) {
            return { message: "Payments retrieved successfully", data: [] };
          }

          paymentIdsByCargo = ids;
        }

        const conditions: any[] = [];
        if (isCustomer(authUser.role)) {
          conditions.push(eq(payment.customerId, authUser.id));
        }
        if (filters.status) conditions.push(eq(payment.status, filters.status));
        if (filters.method) conditions.push(eq(payment.method, filters.method));
        if (filters.paymentId) {
          conditions.push(like(payment.id, `%${filters.paymentId}%`));
        }
        if (paymentIdsByCargo) {
          conditions.push(inArray(payment.id, paymentIdsByCargo as string[]));
        }

        const whereClause =
          conditions.length === 0
            ? undefined
            : conditions.length === 1
              ? conditions[0]
              : and(...conditions);

        const queryBuilder = whereClause
          ? db.select().from(payment).where(whereClause)
          : db.select().from(payment);

        const rows = await queryBuilder.orderBy(desc(payment.createdAt));

        return {
          message: "Payments retrieved successfully",
          data: rows.map(toPaymentSummary),
        };
      },
      {
        detail: withAudience("shared", {
          tags: ["Payments"],
          summary: "Search payments",
          description: "Search payments by status, method, payment id, and cargo id",
        }),
        query: paymentSearchQuerySchema,
        response: {
          200: paymentListResponseEnvelopeSchema,
        },
      }
    )
  )
  .guard(roleGuard(["mongolia_staff", "admin"]), (app) =>
    app.post(
      "/payments/:paymentId/mark-paid",
      async (ctx: any) => {
        const { params, db, status } = ctx;
        const [paymentRow] = await db
          .select()
          .from(payment)
          .where(eq(payment.id, params.paymentId))
          .limit(1);

        if (!paymentRow) return status(404, { message: "Payment not found" });

        await db
          .update(payment)
          .set({ status: "PAID", paidAt: new Date() })
          .where(eq(payment.id, params.paymentId));

        const links = await db
          .select({ cargoId: paymentCargo.cargoId })
          .from(paymentCargo)
          .where(eq(paymentCargo.paymentId, params.paymentId));

        if (links.length) {
          await db
            .update(cargo)
            .set({ paymentStatus: "PAID" })
            .where(inArray(cargo.id, links.map((x: any) => x.cargoId)));
        }

        return { message: "Payment marked as paid" };
      },
      {
        detail: withAudience("staff", {
          tags: ["Payments"],
          summary: "Mark payment paid",
          responses: {
            200: {
              description: "Marked as paid",
            },
          },
        }),
        params: paymentIdParamsSchema,
        response: {
          200: successMessageResponseSchema,
          404: messageResponseSchema,
        },
      }
    )
  );
