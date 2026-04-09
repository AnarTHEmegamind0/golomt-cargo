import { t } from "elysia";
import {
  createInsertSchema,
  createSelectSchema,
  createUpdateSchema,
} from "drizzle-typebox";
import { branch, cargo, cargoStatusEvent, payment } from "~/db/schema";
import {
  cargoPaymentStatuses,
  cargoStatuses,
  fulfillmentTypes,
} from "~/db/schema/constants/cargo";

export const cargoInsertSchema = createInsertSchema(cargo);
export const cargoSelectSchema = createSelectSchema(cargo);
export const cargoUpdateSchema = createUpdateSchema(cargo);

export const paymentInsertSchema = createInsertSchema(payment);
export const paymentSelectSchema = createSelectSchema(payment);

export const branchSelectSchema = createSelectSchema(branch);
export const cargoStatusEventSelectSchema = createSelectSchema(cargoStatusEvent);

export const createCargoSchema = t.Object({
  trackingNumber: t.String({ minLength: 3, maxLength: 128 }),
  description: t.Optional(t.String({ maxLength: 500 })),
});

export const cargoIdParamsSchema = t.Object({
  cargoId: t.String(),
});

export const paymentIdParamsSchema = t.Object({
  paymentId: t.String(),
});

export const receiveCargoSchema = t.Object({
  image: t.Optional(t.File({ type: "image", maxSize: "5m" })),
});

export const chooseFulfillmentSchema = t.Object({
  fulfillmentType: t.Union([t.Literal("PICKUP"), t.Literal("HOME_DELIVERY")]),
  deliveryAddress: t.Optional(t.Nullable(t.String({ minLength: 8, maxLength: 300 }))),
  deliveryPhone: t.Optional(t.Nullable(t.String({ minLength: 6, maxLength: 30 }))),
});

export const recordWeightSchema = t.Object({
  weightGrams: t.Integer({ minimum: 1 }),
  baseShippingFeeMnt: t.Integer({ minimum: 0 }),
});

export const createBatchPaymentSchema = t.Object({
  cargoIds: t.Array(t.String(), { minItems: 1 }),
  method: t.Union([t.Literal("APP"), t.Literal("CASH_IN_PERSON")]),
  note: t.Optional(t.String({ maxLength: 500 })),
});

export const cargoListQuerySchema = t.Object({
  page: t.Optional(t.Integer({ minimum: 1 })),
  limit: t.Optional(t.Integer({ minimum: 1, maximum: 100 })),
  status: t.Optional(
    t.Union(cargoStatuses.map((status) => t.Literal(status)) as [any, ...any[]])
  ),
  paymentStatus: t.Optional(
    t.Union(cargoPaymentStatuses.map((status) => t.Literal(status)) as [any, ...any[]])
  ),
  fulfillmentType: t.Optional(
    t.Union(fulfillmentTypes.map((type) => t.Literal(type)) as [any, ...any[]])
  ),
  trackingNumber: t.Optional(t.String({ minLength: 1, maxLength: 128 })),
});

export const cargoSearchQuerySchema = t.Object({
  q: t.String({ minLength: 1, maxLength: 128 }),
  page: t.Optional(t.Integer({ minimum: 1 })),
  limit: t.Optional(t.Integer({ minimum: 1, maximum: 100 })),
  trackingNumber: t.Optional(t.String({ minLength: 1, maxLength: 128 })),
  phone: t.Optional(t.String({ minLength: 1, maxLength: 30 })),
  customerName: t.Optional(t.String({ minLength: 1, maxLength: 120 })),
  customerEmail: t.Optional(t.String({ minLength: 3, maxLength: 255 })),
  status: t.Optional(
    t.Union(cargoStatuses.map((status) => t.Literal(status)) as [any, ...any[]])
  ),
  paymentStatus: t.Optional(
    t.Union(cargoPaymentStatuses.map((status) => t.Literal(status)) as [any, ...any[]])
  ),
  fulfillmentType: t.Optional(
    t.Union(fulfillmentTypes.map((type) => t.Literal(type)) as [any, ...any[]])
  ),
});

export const paymentSearchQuerySchema = t.Object({
  status: t.Optional(
    t.Union([
      t.Literal("PENDING"),
      t.Literal("PAID"),
      t.Literal("FAILED"),
      t.Literal("CANCELLED"),
      t.Literal("REFUNDED"),
    ])
  ),
  method: t.Optional(t.Union([t.Literal("APP"), t.Literal("CASH_IN_PERSON")])),
  paymentId: t.Optional(t.String({ minLength: 1, maxLength: 128 })),
  cargoId: t.Optional(t.String({ minLength: 1, maxLength: 128 })),
});

export const messageResponseSchema = t.Object({
  message: t.String(),
});

export const cargoSummarySchema = t.Object({
  id: t.String(),
  trackingNumber: t.String(),
  description: t.Nullable(t.String()),
  status: t.String(),
  paymentStatus: t.String(),
  receivedImageUrl: t.Nullable(t.String()),
  fulfillmentType: t.Optional(t.Union([t.String(), t.Null()])),
  deliveryAddress: t.Optional(t.Union([t.String(), t.Null()])),
  deliveryPhone: t.Optional(t.Union([t.String(), t.Null()])),
  weightGrams: t.Optional(t.Union([t.Number(), t.Null()])),
  baseShippingFeeMnt: t.Optional(t.Union([t.Number(), t.Null()])),
  totalFeeMnt: t.Optional(t.Union([t.Number(), t.Null()])),
  createdAt: t.Optional(t.Union([t.String(), t.Null()])),
  updatedAt: t.Optional(t.Union([t.String(), t.Null()])),
  customer: t.Nullable(
    t.Object({
      id: t.String(),
      name: t.String(),
      email: t.String(),
    })
  ),
  heightCm: t.Optional(t.Union([t.Number(), t.Null()])),
  widthCm: t.Optional(t.Union([t.Number(), t.Null()])),
  lengthCm: t.Optional(t.Union([t.Number(), t.Null()])),
  isFragile: t.Optional(t.Boolean()),
  calculatedFeeMnt: t.Optional(t.Union([t.Number(), t.Null()])),
  overrideFeeMnt: t.Optional(t.Union([t.Number(), t.Null()])),
  shipmentId: t.Optional(t.Union([t.String(), t.Null()])),
});

export const cargoSummaryListSchema = t.Array(cargoSummarySchema);

export const paginationMetaSchema = t.Object({
  page: t.Number(),
  limit: t.Number(),
  total: t.Number(),
  totalPages: t.Number(),
});

export const cargoEventSchema = t.Object({
  id: t.String(),
  fromStatus: t.Nullable(t.String()),
  toStatus: t.String(),
  note: t.Nullable(t.String()),
  createdAt: t.String(),
});

export const cargoEventListSchema = t.Array(cargoEventSchema);

export const branchSchema = t.Object({
  id: t.String(),
  code: t.String(),
  name: t.String(),
  address: t.Nullable(t.String()),
  phone: t.Nullable(t.String()),
  chinaAddress: t.Optional(t.Nullable(t.String())),
  isActive: t.Boolean(),
});

export const branchSummaryListSchema = t.Array(branchSchema);

export const paymentSummarySchema = t.Object({
  id: t.String(),
  customerId: t.String(),
  status: t.String(),
  method: t.String(),
  totalAmountMnt: t.Number(),
  currency: t.String(),
  paidAt: t.Union([t.String(), t.Null()]),
  createdAt: t.String(),
});

export const paymentSummaryListSchema = t.Array(paymentSummarySchema);

export const cargoStatusStatsSchema = t.Object({
  CREATED: t.Number(),
  RECEIVED_CHINA: t.Number(),
  IN_TRANSIT_TO_MN: t.Number(),
  ARRIVED_MN: t.Number(),
  AWAITING_FULFILLMENT_CHOICE: t.Number(),
  READY_FOR_PICKUP: t.Number(),
  OUT_FOR_DELIVERY: t.Number(),
  COMPLETED_PICKUP: t.Number(),
  COMPLETED_DELIVERY: t.Number(),
});

export const paymentStatusStatsSchema = t.Object({
  UNPAID: t.Number(),
  PAID: t.Number(),
});

export const cargoStatsSchema = t.Object({
  total: t.Number(),
  byStatus: cargoStatusStatsSchema,
  byPaymentStatus: paymentStatusStatsSchema,
});

export const successMessageResponseSchema = t.Object({
  message: t.String(),
});

export const cargoResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: cargoSummarySchema,
});

export const cargoListResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: cargoSummaryListSchema,
  meta: paginationMetaSchema,
});

export const cargoEventsResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: cargoEventListSchema,
});

export const branchListResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: branchSummaryListSchema,
});

export const paymentListResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: paymentSummaryListSchema,
});

export const cargoStatsResponseEnvelopeSchema = t.Object({
  message: t.String(),
  data: cargoStatsSchema,
});

export const createBatchPaymentResponseEnvelopeSchema = t.Object({
  message: t.String(),
  paymentId: t.String(),
  totalAmountMnt: t.Number(),
  cargoCount: t.Number(),
});

export const receivedImageResponseEnvelopeSchema = t.Object({
  message: t.String(),
  receivedImageUrl: t.Nullable(t.String()),
});

export const markWeightResponseEnvelopeSchema = t.Object({
  message: t.String(),
  totalFeeMnt: t.Number(),
});
