import { t } from "elysia";
import {
  adminActivityActions,
  adminActivityTargetTypes,
  shipmentStatuses,
  vehicleTypes,
} from "~/db/schema/constants/operations";
import { cargoImportSources, cargoPricingMethods, cargoStatuses } from "~/db/schema/constants/cargo";
import { branchSchema, cargoSummarySchema, messageResponseSchema, paginationMetaSchema } from "~/lib/schemas/cargo.schemas";

const enumUnion = <T extends readonly string[]>(values: T) =>
  t.Union(values.map((value) => t.Literal(value)) as [any, ...any[]]);

export const vehicleSchema = t.Object({
  id: t.String(),
  plate_number: t.String(),
  name: t.String(),
  type: enumUnion(vehicleTypes),
  is_active: t.Boolean(),
  created_at: t.String(),
  updated_at: t.Union([t.String(), t.Null()]),
});

export const vehicleListResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: t.Array(vehicleSchema),
});

export const vehicleResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: vehicleSchema,
});

export const vehicleCreateSchema = t.Object({
  plate_number: t.String({ minLength: 2, maxLength: 64 }),
  name: t.String({ minLength: 1, maxLength: 120 }),
  type: enumUnion(vehicleTypes),
});

export const vehicleUpdateSchema = t.Object({
  plate_number: t.Optional(t.String({ minLength: 2, maxLength: 64 })),
  name: t.Optional(t.String({ minLength: 1, maxLength: 120 })),
  type: t.Optional(enumUnion(vehicleTypes)),
  is_active: t.Optional(t.Boolean()),
});

export const vehicleIdParamsSchema = t.Object({
  vehicleId: t.String(),
});

export const shipmentSchema = t.Object({
  id: t.String(),
  vehicle_id: t.String(),
  vehicle_plate_number: t.String(),
  status: enumUnion(shipmentStatuses),
  created_at: t.String(),
  departure_date: t.Union([t.String(), t.Null()]),
  arrival_date: t.Union([t.String(), t.Null()]),
  cargo_count: t.Integer(),
  note: t.Union([t.String(), t.Null()]),
  cargo_ids: t.Array(t.String()),
});

export const shipmentDetailSchema = t.Composite([
  shipmentSchema,
  t.Object({
    cargos: t.Optional(t.Array(cargoSummarySchema)),
  }),
]);

export const shipmentListResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: t.Array(shipmentSchema),
  meta: paginationMetaSchema,
});

export const shipmentResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: shipmentDetailSchema,
});

export const shipmentCreateSchema = t.Object({
  vehicle_id: t.String(),
  departure_date: t.Optional(t.String({ format: "date-time" })),
  note: t.Optional(t.String({ maxLength: 500 })),
});

export const shipmentStatusUpdateSchema = t.Object({
  status: enumUnion(shipmentStatuses),
});

export const shipmentCargoMutationSchema = t.Object({
  cargo_ids: t.Array(t.String(), { minItems: 1 }),
});

export const shipmentQuerySchema = t.Object({
  page: t.Optional(t.Integer({ minimum: 1 })),
  limit: t.Optional(t.Integer({ minimum: 1, maximum: 100 })),
  status: t.Optional(enumUnion(shipmentStatuses)),
  vehicleId: t.Optional(t.String()),
  dateFrom: t.Optional(t.String({ format: "date" })),
  dateTo: t.Optional(t.String({ format: "date" })),
});

export const shipmentIdParamsSchema = t.Object({
  shipmentId: t.String(),
});

export const importTrackCodesSchema = t.Object({
  source_type: t.Optional(enumUnion(cargoImportSources)),
  trackingNumbers: t.Array(t.String({ minLength: 1, maxLength: 128 }), { minItems: 1 }),
});

export const importTrackCodesResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: t.Array(cargoSummarySchema),
  meta: t.Object({
    total: t.Integer(),
    created: t.Integer(),
    existing: t.Integer(),
    failed: t.Integer(),
    errors: t.Array(t.String()),
  }),
});

export const recordDimensionsSchema = t.Object({
  heightCm: t.Integer({ minimum: 1 }),
  widthCm: t.Integer({ minimum: 1 }),
  lengthCm: t.Integer({ minimum: 1 }),
  isFragile: t.Boolean(),
  calculatedFeeMnt: t.Optional(t.Integer({ minimum: 0 })),
  overrideFeeMnt: t.Optional(t.Nullable(t.Integer({ minimum: 0 }))),
});

export const pricingCalculationResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: t.Object({
    weight_kg: t.Number(),
    volume_cbm: t.Number(),
    is_fragile: t.Boolean(),
    weight_based_fee_mnt: t.Integer(),
    volume_based_fee_mnt: t.Integer(),
    calculated_fee_mnt: t.Integer(),
    override_fee_mnt: t.Union([t.Integer(), t.Null()]),
    final_fee_mnt: t.Integer(),
    method: enumUnion(cargoPricingMethods),
  }),
});

export const adminLogSchema = t.Object({
  id: t.String(),
  admin_id: t.String(),
  admin_name: t.String(),
  action: enumUnion(adminActivityActions),
  target_type: enumUnion(adminActivityTargetTypes),
  target_id: t.Union([t.String(), t.Null()]),
  description: t.String(),
  created_at: t.String(),
  metadata: t.Union([t.Record(t.String(), t.Any()), t.Null()]),
});

export const adminLogListResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: t.Array(adminLogSchema),
  meta: t.Optional(paginationMetaSchema),
});

export const adminLogQuerySchema = t.Object({
  limit: t.Optional(t.Integer({ minimum: 1, maximum: 100 })),
  offset: t.Optional(t.Integer({ minimum: 0 })),
  action: t.Optional(enumUnion(adminActivityActions)),
  targetType: t.Optional(enumUnion(adminActivityTargetTypes)),
  targetId: t.Optional(t.String()),
  actorUserId: t.Optional(t.String()),
  dateFrom: t.Optional(t.String({ format: "date" })),
  dateTo: t.Optional(t.String({ format: "date" })),
});

export const financeSummarySchema = t.Object({
  total_revenue_mnt: t.Integer(),
  paid_amount_mnt: t.Integer(),
  unpaid_amount_mnt: t.Integer(),
  total_cargos: t.Integer(),
  paid_cargos: t.Integer(),
  unpaid_cargos: t.Integer(),
  avg_price_per_kg: t.Number(),
  avg_price_per_cbm: t.Number(),
  daily_revenues: t.Array(
    t.Object({
      date: t.String(),
      revenue: t.Integer(),
      cargo_count: t.Integer(),
    })
  ),
});

export const financeSummaryResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: financeSummarySchema,
});

export const financeSummaryQuerySchema = t.Object({
  startDate: t.Optional(t.String({ format: "date" })),
  endDate: t.Optional(t.String({ format: "date" })),
});

export const branchWriteSchema = t.Object({
  name: t.String({ minLength: 1, maxLength: 120 }),
  code: t.String({ minLength: 1, maxLength: 32 }),
  address: t.String({ minLength: 1, maxLength: 300 }),
  phone: t.Optional(t.String({ maxLength: 50 })),
  chinaAddress: t.Optional(t.String({ maxLength: 300 })),
});

export const branchUpdateSchema = t.Object({
  name: t.Optional(t.String({ minLength: 1, maxLength: 120 })),
  code: t.Optional(t.String({ minLength: 1, maxLength: 32 })),
  address: t.Optional(t.String({ minLength: 1, maxLength: 300 })),
  phone: t.Optional(t.String({ maxLength: 50 })),
  chinaAddress: t.Optional(t.String({ maxLength: 300 })),
  isActive: t.Optional(t.Boolean()),
});

export const branchResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: branchSchema,
});

export const branchIdParamsSchema = t.Object({
  branchId: t.String(),
});

export const exportQuerySchema = t.Object({
  targetType: t.Optional(enumUnion(adminActivityTargetTypes)),
});

export { messageResponseSchema };
