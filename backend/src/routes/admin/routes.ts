import { createId } from "@paralleldrive/cuid2";
import { and, desc, eq, gte, inArray, lte, sql } from "drizzle-orm";
import { Elysia, t } from "elysia";
import { adminActivityLog, branch, cargo, importBatch, payment, shipment, user, vehicle } from "~/db/schema";
import { buildCsvBuffer, buildSimplePdfBuffer } from "~/lib/operations/export";
import { insertAdminActivityLog } from "~/lib/operations/logging";
import { calculateCargoPricing } from "~/lib/operations/pricing";
import { parseMetadataJson, toAdminLogSummary, toCargoSummary } from "~/lib/operations/serializers";
import {
  adminLogListResponseEnvelopeSchema,
  adminLogQuerySchema,
  branchIdParamsSchema,
  branchResponseEnvelopeSchema,
  branchUpdateSchema,
  branchWriteSchema,
  financeSummaryQuerySchema,
  financeSummaryResponseEnvelopeSchema,
  importTrackCodesResponseEnvelopeSchema,
  importTrackCodesSchema,
  messageResponseSchema,
  pricingCalculationResponseEnvelopeSchema,
  recordDimensionsSchema,
  shipmentIdParamsSchema,
} from "~/lib/schemas";
import { withAudience } from "~/lib/openapi";
import { roleGuard } from "~/routes/_shared/auth";

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

const toBranchResponse = (row: any) => ({
  id: row.id,
  code: row.code,
  name: row.name,
  address: row.address ?? null,
  phone: row.phone ?? null,
  chinaAddress: row.chinaAddress ?? null,
  isActive: Boolean(row.isActive),
});

const buildDateRangeCondition = (column: any, startDate?: string, endDate?: string) => {
  const conditions: any[] = [];
  if (startDate) conditions.push(gte(column, new Date(`${startDate}T00:00:00.000Z`)));
  if (endDate) conditions.push(lte(column, new Date(`${endDate}T23:59:59.999Z`)));
  return conditions;
};

const shipmentHeaderSelection = {
  id: shipment.id,
  vehicleId: shipment.vehicleId,
  vehiclePlateNumber: vehicle.plateNumber,
  status: shipment.status,
  createdAt: shipment.createdAt,
  departureDate: shipment.departureDate,
  arrivalDate: shipment.arrivalDate,
  note: shipment.note,
};

export const adminRoutes = new Elysia()
  .guard(roleGuard(["china_staff", "admin"]), (app) =>
    app
      .post("/cargos/import", async ({ db, body, authUser }: any) => {
        const trackingNumbers = (body.trackingNumbers as string[]) ?? [];
        const trimmed = trackingNumbers.map((value) => value.trim()).filter(Boolean);
        const deduped: string[] = [...new Set(trimmed)];

        const batchId = createId();
        await db.insert(importBatch).values({
          id: batchId,
          sourceType: body.source_type ?? "TEXT",
          totalCount: deduped.length,
          successCount: 0,
          failedCount: 0,
          createdByUserId: authUser.id,
        });

        const errors: string[] = [];
        let createdCount = 0;
        let existingCount = 0;

        for (const trackingNumber of deduped) {
          const [existing] = await db
            .select({ id: cargo.id })
            .from(cargo)
            .where(eq(cargo.trackingNumber, trackingNumber))
            .limit(1);

          if (existing) {
            existingCount += 1;
            continue;
          }

          try {
            await db.insert(cargo).values({
              id: createId(),
              customerId: null,
              trackingNumber,
              status: "CREATED",
              placeholderStatus: "UNASSIGNED",
              importSource: body.source_type ?? "TEXT",
              importBatchId: batchId,
            });
            createdCount += 1;
          } catch {
            errors.push(`Failed to import ${trackingNumber}`);
          }
        }

        await db
          .update(importBatch)
          .set({
            successCount: createdCount + existingCount,
            failedCount: errors.length,
          })
          .where(eq(importBatch.id, batchId));

        const rows = deduped.length
          ? await db
              .select(cargoSelection)
              .from(cargo)
              .leftJoin(user, eq(user.id, cargo.customerId))
              .where(inArray(cargo.trackingNumber, deduped))
              .orderBy(desc(cargo.createdAt))
          : [];

        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "IMPORT",
          targetType: "CARGO",
          targetId: batchId,
          description: `Imported ${deduped.length} tracking numbers`,
          metadata: {
            source_type: body.source_type ?? "TEXT",
            created: createdCount,
            existing: existingCount,
            failed: errors.length,
          },
        });

        return {
          message: "Track codes imported successfully",
          data: rows.map(toCargoSummary),
          meta: {
            total: deduped.length,
            created: createdCount,
            existing: existingCount,
            failed: errors.length,
            errors,
          },
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Cargos"],
          summary: "Import track codes",
        }),
        body: importTrackCodesSchema,
        response: {
          200: importTrackCodesResponseEnvelopeSchema,
        },
      })
      .get("/shipments/:shipmentId/export.xlsx", async ({ db, params, authUser, status }: any) => {
        const [shipmentRow] = await db
          .select(shipmentHeaderSelection)
          .from(shipment)
          .innerJoin(vehicle, eq(vehicle.id, shipment.vehicleId))
          .where(eq(shipment.id, params.shipmentId))
          .limit(1);
        if (!shipmentRow) return status(404, { message: "Shipment not found" });

        const cargoRows = await db
          .select(cargoSelection)
          .from(cargo)
          .leftJoin(user, eq(user.id, cargo.customerId))
          .where(eq(cargo.shipmentId, params.shipmentId))
          .orderBy(desc(cargo.createdAt));

        const csv = buildCsvBuffer([
          ["Shipment ID", shipmentRow.id],
          ["Vehicle", shipmentRow.vehiclePlateNumber],
          ["Status", shipmentRow.status],
          ["Departure", shipmentRow.departureDate ? new Date(shipmentRow.departureDate).toISOString() : ""],
          ["Arrival", shipmentRow.arrivalDate ? new Date(shipmentRow.arrivalDate).toISOString() : ""],
          [],
          [
            "Tracking Number",
            "Status",
            "Customer Name",
            "Customer Email",
            "Weight Grams",
            "Dimensions",
            "Calculated Fee",
            "Override Fee",
            "Final Fee",
          ],
          ...cargoRows.map((row: any) => [
            row.trackingNumber,
            row.status,
            row.customerName ?? "",
            row.customerEmail ?? "",
            row.weightGrams ?? "",
            [row.lengthCm, row.widthCm, row.heightCm].filter(Boolean).join("x"),
            row.calculatedFeeMnt ?? "",
            row.overrideFeeMnt ?? "",
            row.totalFeeMnt ?? "",
          ]),
        ]);

        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "EXPORT",
          targetType: "SHIPMENT",
          targetId: params.shipmentId,
          description: `Exported shipment ${params.shipmentId} as spreadsheet`,
          metadata: { format: "xlsx" },
        });

        return new Response(csv, {
          headers: {
            "content-type": "application/vnd.ms-excel; charset=utf-8",
            "content-disposition": `attachment; filename="shipment-${params.shipmentId}.xlsx"`,
          },
        });
      }, {
        detail: withAudience("staff", {
          tags: ["Exports"],
          summary: "Export shipment as spreadsheet",
        }),
        params: shipmentIdParamsSchema,
        response: {
          404: messageResponseSchema,
        },
      })
      .get("/shipments/:shipmentId/export.pdf", async ({ db, params, authUser, status }: any) => {
        const [shipmentRow] = await db
          .select(shipmentHeaderSelection)
          .from(shipment)
          .innerJoin(vehicle, eq(vehicle.id, shipment.vehicleId))
          .where(eq(shipment.id, params.shipmentId))
          .limit(1);
        if (!shipmentRow) return status(404, { message: "Shipment not found" });

        const cargoRows = await db
          .select(cargoSelection)
          .from(cargo)
          .leftJoin(user, eq(user.id, cargo.customerId))
          .where(eq(cargo.shipmentId, params.shipmentId))
          .orderBy(desc(cargo.createdAt));

        const pdf = await buildSimplePdfBuffer([
          `Shipment ${shipmentRow.id}`,
          `Vehicle: ${shipmentRow.vehiclePlateNumber}`,
          `Status: ${shipmentRow.status}`,
          `Departure: ${shipmentRow.departureDate ? new Date(shipmentRow.departureDate).toISOString() : "-"}`,
          `Arrival: ${shipmentRow.arrivalDate ? new Date(shipmentRow.arrivalDate).toISOString() : "-"}`,
          `Cargo Count: ${cargoRows.length}`,
          "",
          ...cargoRows.slice(0, 25).map((row: any) => {
            const customerName = row.customerName ?? "Unassigned";
            return `${row.trackingNumber} | ${row.status} | ${customerName} | ${row.totalFeeMnt ?? 0} MNT`;
          }),
        ]);
        const pdfBytes = Uint8Array.from(pdf);

        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "EXPORT",
          targetType: "SHIPMENT",
          targetId: params.shipmentId,
          description: `Exported shipment ${params.shipmentId} as PDF`,
          metadata: { format: "pdf" },
        });

        return new Response(new Blob([pdfBytes], { type: "application/pdf" }), {
          headers: {
            "content-type": "application/pdf",
            "content-disposition": `attachment; filename="shipment-${params.shipmentId}.pdf"`,
          },
        });
      }, {
        detail: withAudience("staff", {
          tags: ["Exports"],
          summary: "Export shipment as PDF",
        }),
        params: shipmentIdParamsSchema,
        response: {
          404: messageResponseSchema,
        },
      })
  )
  .guard(roleGuard(["admin"]), (app) =>
    app
      .post("/cargos/:cargoId/record-dimensions", async ({ db, params, body, authUser, status }: any) => {
        const [cargoRow] = await db.select().from(cargo).where(eq(cargo.id, params.cargoId)).limit(1);
        if (!cargoRow) return status(404, { message: "Cargo not found" });
        if (!cargoRow.weightGrams || cargoRow.weightGrams <= 0) {
          return status(400, { message: "Weight must be recorded before dimensions" });
        }

        const pricing = calculateCargoPricing({
          weightGrams: cargoRow.weightGrams,
          heightCm: body.heightCm,
          widthCm: body.widthCm,
          lengthCm: body.lengthCm,
          isFragile: body.isFragile,
          overrideFeeMnt: body.overrideFeeMnt ?? null,
        });

        await db
          .update(cargo)
          .set({
            heightCm: body.heightCm,
            widthCm: body.widthCm,
            lengthCm: body.lengthCm,
            isFragile: body.isFragile,
            baseShippingFeeMnt: pricing.weightBasedFeeMnt,
            calculatedFeeMnt: pricing.calculatedFeeMnt,
            overrideFeeMnt: body.overrideFeeMnt ?? null,
            pricingMethod: pricing.method,
            pricedAt: new Date(),
            pricedByUserId: authUser.id,
            totalFeeMnt: pricing.finalFeeMnt,
          })
          .where(eq(cargo.id, params.cargoId));

        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: body.overrideFeeMnt != null ? "PRICE_OVERRIDE" : "WEIGHT_RECORD",
          targetType: "CARGO",
          targetId: params.cargoId,
          description:
            body.overrideFeeMnt != null
              ? `Overrode cargo price for ${cargoRow.trackingNumber}`
              : `Recorded dimensions for ${cargoRow.trackingNumber}`,
          metadata: {
            heightCm: body.heightCm,
            widthCm: body.widthCm,
            lengthCm: body.lengthCm,
            isFragile: body.isFragile,
            ...pricing,
            overrideFeeMnt: body.overrideFeeMnt ?? null,
          },
        });

        return {
          message: "Cargo dimensions recorded successfully",
          data: {
            weight_kg: pricing.weightKg,
            volume_cbm: pricing.volumeCbm,
            is_fragile: body.isFragile,
            weight_based_fee_mnt: pricing.weightBasedFeeMnt,
            volume_based_fee_mnt: pricing.volumeBasedFeeMnt,
            calculated_fee_mnt: pricing.calculatedFeeMnt,
            override_fee_mnt: body.overrideFeeMnt ?? null,
            final_fee_mnt: pricing.finalFeeMnt,
            method: pricing.method,
          },
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Cargos"],
          summary: "Record cargo dimensions and price",
        }),
        params: t.Object({ cargoId: t.String() }),
        body: recordDimensionsSchema,
        response: {
          200: pricingCalculationResponseEnvelopeSchema,
          400: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
      .get("/admin/logs", async ({ db, query }: any) => {
        const filters = query ?? {};
        const limit = filters.limit ?? 50;
        const offset = filters.offset ?? 0;
        const conditions: any[] = [];
        if (filters.action) conditions.push(eq(adminActivityLog.action, filters.action));
        if (filters.targetType) conditions.push(eq(adminActivityLog.targetType, filters.targetType));
        if (filters.targetId) conditions.push(eq(adminActivityLog.targetId, filters.targetId));
        if (filters.actorUserId) conditions.push(eq(adminActivityLog.actorUserId, filters.actorUserId));
        conditions.push(...buildDateRangeCondition(adminActivityLog.createdAt, filters.dateFrom, filters.dateTo));

        const whereClause =
          conditions.length === 0 ? undefined : conditions.length === 1 ? conditions[0] : and(...conditions);

        const [totalRow] = whereClause
          ? await db.select({ count: sql<number>`count(*)` }).from(adminActivityLog).where(whereClause)
          : await db.select({ count: sql<number>`count(*)` }).from(adminActivityLog);

        const rows = whereClause
          ? await db
              .select({ ...adminActivityLog, actorName: user.name })
              .from(adminActivityLog)
              .leftJoin(user, eq(user.id, adminActivityLog.actorUserId))
              .where(whereClause)
              .orderBy(desc(adminActivityLog.createdAt))
              .limit(limit)
              .offset(offset)
          : await db
              .select({ ...adminActivityLog, actorName: user.name })
              .from(adminActivityLog)
              .leftJoin(user, eq(user.id, adminActivityLog.actorUserId))
              .orderBy(desc(adminActivityLog.createdAt))
              .limit(limit)
              .offset(offset);

        return {
          message: "Activity logs retrieved successfully",
          data: rows.map(toAdminLogSummary),
          meta: {
            page: Math.floor(offset / limit) + 1,
            limit,
            total: Number(totalRow?.count ?? 0),
            totalPages: Number(totalRow?.count ?? 0) === 0 ? 0 : Math.ceil(Number(totalRow?.count ?? 0) / limit),
          },
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Admin"],
          summary: "List activity logs",
        }),
        query: adminLogQuerySchema,
        response: {
          200: adminLogListResponseEnvelopeSchema,
        },
      })
      .get("/admin/finance/summary", async ({ db, query }: any) => {
        const filters = query ?? {};
        const cargoConditions = buildDateRangeCondition(cargo.createdAt, filters.startDate, filters.endDate);
        const paymentConditions = buildDateRangeCondition(payment.createdAt, filters.startDate, filters.endDate);
        const cargoWhere =
          cargoConditions.length === 0 ? undefined : cargoConditions.length === 1 ? cargoConditions[0] : and(...cargoConditions);
        const paymentWhere =
          paymentConditions.length === 0 ? undefined : paymentConditions.length === 1 ? paymentConditions[0] : and(...paymentConditions);

        const cargoRows = cargoWhere ? await db.select().from(cargo).where(cargoWhere) : await db.select().from(cargo);
        const paymentRows = paymentWhere
          ? await db.select().from(payment).where(and(paymentWhere, eq(payment.status, "PAID")))
          : await db.select().from(payment).where(eq(payment.status, "PAID"));

        const totalRevenueMnt = cargoRows.reduce((sum: number, row: any) => sum + Number(row.totalFeeMnt ?? 0), 0);
        const paidAmountMnt = paymentRows.reduce((sum: number, row: any) => sum + Number(row.totalAmountMnt ?? 0), 0);
        const unpaidAmountMnt = Math.max(totalRevenueMnt - paidAmountMnt, 0);
        const paidCargos = cargoRows.filter((row: any) => row.paymentStatus === "PAID").length;
        const unpaidCargos = cargoRows.filter((row: any) => row.paymentStatus !== "PAID").length;

        const weighed = cargoRows.filter((row: any) => row.weightGrams && row.totalFeeMnt);
        const volumed = cargoRows.filter((row: any) => row.heightCm && row.widthCm && row.lengthCm && row.totalFeeMnt);
        const avgPricePerKg =
          weighed.length === 0
            ? 0
            : weighed.reduce((sum: number, row: any) => sum + Number(row.totalFeeMnt ?? 0) / (Number(row.weightGrams) / 1000), 0) /
              weighed.length;
        const avgPricePerCbm =
          volumed.length === 0
            ? 0
            : volumed.reduce((sum: number, row: any) => {
                const volume = (Number(row.heightCm) * Number(row.widthCm) * Number(row.lengthCm)) / 1_000_000;
                return sum + Number(row.totalFeeMnt ?? 0) / volume;
              }, 0) / volumed.length;

        const dailyRevenueMap = new Map<string, { revenue: number; cargo_count: number }>();
        for (const paymentRow of paymentRows) {
          const date = new Date(paymentRow.createdAt).toISOString().split("T")[0];
          const current = dailyRevenueMap.get(date) ?? { revenue: 0, cargo_count: 0 };
          current.revenue += Number(paymentRow.totalAmountMnt ?? 0);
          current.cargo_count += 1;
          dailyRevenueMap.set(date, current);
        }

        return {
          message: "Finance summary retrieved successfully",
          data: {
            total_revenue_mnt: totalRevenueMnt,
            paid_amount_mnt: paidAmountMnt,
            unpaid_amount_mnt: unpaidAmountMnt,
            total_cargos: cargoRows.length,
            paid_cargos: paidCargos,
            unpaid_cargos: unpaidCargos,
            avg_price_per_kg: Number.isFinite(avgPricePerKg) ? avgPricePerKg : 0,
            avg_price_per_cbm: Number.isFinite(avgPricePerCbm) ? avgPricePerCbm : 0,
            daily_revenues: Array.from(dailyRevenueMap.entries()).map(([date, value]) => ({
              date,
              revenue: value.revenue,
              cargo_count: value.cargo_count,
            })),
          },
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Admin"],
          summary: "Get finance summary",
        }),
        query: financeSummaryQuerySchema,
        response: {
          200: financeSummaryResponseEnvelopeSchema,
        },
      })
      .post("/branches", async ({ db, body, authUser, status }: any) => {
        const [existing] = await db.select({ id: branch.id }).from(branch).where(eq(branch.code, body.code)).limit(1);
        if (existing) return status(409, { message: "Branch code already exists" });

        const id = createId();
        await db.insert(branch).values({
          id,
          name: body.name,
          code: body.code,
          address: body.address,
          phone: body.phone ?? null,
          chinaAddress: body.chinaAddress ?? null,
          isActive: true,
        });

        const [created] = await db.select().from(branch).where(eq(branch.id, id)).limit(1);
        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "CREATE",
          targetType: "BRANCH",
          targetId: id,
          description: `Created branch ${body.name}`,
          metadata: body,
        });

        return {
          message: "Branch created successfully",
          data: toBranchResponse(created),
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Branches"],
          summary: "Create branch",
        }),
        body: branchWriteSchema,
        response: {
          200: branchResponseEnvelopeSchema,
          409: messageResponseSchema,
        },
      })
      .put("/branches/:branchId", async ({ db, params, body, authUser, status }: any) => {
        const [existing] = await db.select().from(branch).where(eq(branch.id, params.branchId)).limit(1);
        if (!existing) return status(404, { message: "Branch not found" });

        if (body.code && body.code !== existing.code) {
          const [duplicate] = await db.select({ id: branch.id }).from(branch).where(eq(branch.code, body.code)).limit(1);
          if (duplicate) return status(409, { message: "Branch code already exists" });
        }

        await db
          .update(branch)
          .set({
            name: body.name ?? existing.name,
            code: body.code ?? existing.code,
            address: body.address ?? existing.address,
            phone: body.phone ?? existing.phone,
            chinaAddress: body.chinaAddress ?? existing.chinaAddress,
            isActive: body.isActive ?? existing.isActive,
          })
          .where(eq(branch.id, params.branchId));

        const [updated] = await db.select().from(branch).where(eq(branch.id, params.branchId)).limit(1);
        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "UPDATE",
          targetType: "BRANCH",
          targetId: params.branchId,
          description: `Updated branch ${updated.name}`,
          metadata: body,
        });

        return {
          message: "Branch updated successfully",
          data: toBranchResponse(updated),
        };
      }, {
        detail: withAudience("staff", {
          tags: ["Branches"],
          summary: "Update branch",
        }),
        params: branchIdParamsSchema,
        body: branchUpdateSchema,
        response: {
          200: branchResponseEnvelopeSchema,
          404: messageResponseSchema,
          409: messageResponseSchema,
        },
      })
      .delete("/branches/:branchId", async ({ db, params, authUser, status }: any) => {
        const [existing] = await db.select().from(branch).where(eq(branch.id, params.branchId)).limit(1);
        if (!existing) return status(404, { message: "Branch not found" });

        await db.delete(branch).where(eq(branch.id, params.branchId));
        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "DELETE",
          targetType: "BRANCH",
          targetId: params.branchId,
          description: `Deleted branch ${existing.name}`,
          metadata: { code: existing.code },
        });

        return { message: "Branch deleted successfully" };
      }, {
        detail: withAudience("staff", {
          tags: ["Branches"],
          summary: "Delete branch",
        }),
        params: branchIdParamsSchema,
        response: {
          200: messageResponseSchema,
          404: messageResponseSchema,
        },
      })
      .get("/admin/logs/export.xlsx", async ({ db, authUser }: any) => {
        const rows = await db
          .select({ ...adminActivityLog, actorName: user.name })
          .from(adminActivityLog)
          .leftJoin(user, eq(user.id, adminActivityLog.actorUserId))
          .orderBy(desc(adminActivityLog.createdAt))
          .limit(1000);

        const csv = buildCsvBuffer([
          ["Actor", "Action", "Target Type", "Target ID", "Description", "Created At", "Metadata"],
          ...rows.map((row: any) => [
            row.actorName ?? "Unknown",
            row.action,
            row.targetType,
            row.targetId ?? "",
            row.description,
            new Date(row.createdAt).toISOString(),
            JSON.stringify(parseMetadataJson(row.metadataJson) ?? {}),
          ]),
        ]);

        await insertAdminActivityLog({
          db,
          actorUserId: authUser.id,
          actorRole: authUser.role,
          action: "EXPORT",
          targetType: "EXPORT_JOB",
          description: "Exported admin logs",
          metadata: { format: "xlsx" },
        });

        return new Response(csv, {
          headers: {
            "content-type": "application/vnd.ms-excel; charset=utf-8",
            "content-disposition": 'attachment; filename="admin-logs.xlsx"',
          },
        });
      }, {
        detail: withAudience("staff", {
          tags: ["Exports"],
          summary: "Export admin logs",
        }),
      })
  );
