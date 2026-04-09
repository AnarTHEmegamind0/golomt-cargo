import { sql } from "drizzle-orm";
import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";
import {
  cargoImportSources,
  cargoPaymentStatuses,
  cargoPlaceholderStatuses,
  cargoPricingMethods,
  cargoStatuses,
  fulfillmentTypes,
  type CargoImportSource,
  type CargoPaymentStatus,
  type CargoPlaceholderStatus,
  type CargoPricingMethod,
  type CargoStatus,
  type FulfillmentType,
} from "~/db/schema/constants/cargo";
import { user } from "~/db/schema/tables/auth";
import { branch } from "~/db/schema/tables/branch";
import { importBatch, shipment } from "~/db/schema/tables/operations";

export const cargo = sqliteTable(
  "cargo",
  {
    id: text("id").primaryKey(),
    customerId: text("customer_id").references(() => user.id, { onDelete: "set null" }),
    branchId: text("branch_id").references(() => branch.id, {
      onDelete: "set null",
    }),
    shipmentId: text("shipment_id").references(() => shipment.id, {
      onDelete: "set null",
    }),
    trackingNumber: text("tracking_number").notNull().unique(),
    description: text("description"),
    status: text("status", { enum: cargoStatuses })
      .$type<CargoStatus>()
      .notNull()
      .default("CREATED"),
    paymentStatus: text("payment_status", { enum: cargoPaymentStatuses })
      .$type<CargoPaymentStatus>()
      .notNull()
      .default("UNPAID"),
    fulfillmentType: text("fulfillment_type", { enum: fulfillmentTypes }).$type<
      FulfillmentType | null
    >(),
    weightGrams: integer("weight_grams"),
    heightCm: integer("height_cm"),
    widthCm: integer("width_cm"),
    lengthCm: integer("length_cm"),
    isFragile: integer("is_fragile", { mode: "boolean" }).notNull().default(false),
    baseShippingFeeMnt: integer("base_shipping_fee_mnt"),
    calculatedFeeMnt: integer("calculated_fee_mnt"),
    overrideFeeMnt: integer("override_fee_mnt"),
    pricingMethod: text("pricing_method", { enum: cargoPricingMethods }).$type<CargoPricingMethod>(),
    pricedAt: integer("priced_at", { mode: "timestamp_ms" }),
    pricedByUserId: text("priced_by_user_id").references(() => user.id, {
      onDelete: "set null",
    }),
    localDeliveryFeeMnt: integer("local_delivery_fee_mnt").notNull().default(0),
    totalFeeMnt: integer("total_fee_mnt"),
    importSource: text("import_source", { enum: cargoImportSources }).$type<CargoImportSource>(),
    importBatchId: text("import_batch_id").references(() => importBatch.id, {
      onDelete: "set null",
    }),
    placeholderStatus: text("placeholder_status", { enum: cargoPlaceholderStatuses })
      .$type<CargoPlaceholderStatus>()
      .default("LINKED"),
    deliveryAddress: text("delivery_address"),
    deliveryPhone: text("delivery_phone"),
    receivedImageUrl: text("received_image_url"),
    receivedImageObjectKey: text("received_image_object_key"),
    receivedInChinaAt: integer("received_in_china_at", { mode: "timestamp_ms" }),
    departedChinaAt: integer("departed_china_at", { mode: "timestamp_ms" }),
    arrivedInMongoliaAt: integer("arrived_in_mongolia_at", {
      mode: "timestamp_ms",
    }),
    fulfillmentSelectedAt: integer("fulfillment_selected_at", {
      mode: "timestamp_ms",
    }),
    completedAt: integer("completed_at", { mode: "timestamp_ms" }),
    createdAt: integer("created_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .notNull(),
    updatedAt: integer("updated_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    index("cargo_customer_id_idx").on(table.customerId),
    index("cargo_branch_id_idx").on(table.branchId),
    index("cargo_shipment_id_idx").on(table.shipmentId),
    index("cargo_status_idx").on(table.status),
    index("cargo_payment_status_idx").on(table.paymentStatus),
    index("cargo_tracking_number_idx").on(table.trackingNumber),
    index("cargo_import_batch_id_idx").on(table.importBatchId),
  ]
);

export const cargoStatusEvent = sqliteTable(
  "cargo_status_event",
  {
    id: text("id").primaryKey(),
    cargoId: text("cargo_id")
      .notNull()
      .references(() => cargo.id, { onDelete: "cascade" }),
    fromStatus: text("from_status", { enum: cargoStatuses }).$type<
      CargoStatus | null
    >(),
    toStatus: text("to_status", { enum: cargoStatuses })
      .$type<CargoStatus>()
      .notNull(),
    note: text("note"),
    changedByUserId: text("changed_by_user_id").references(() => user.id, {
      onDelete: "set null",
    }),
    createdAt: integer("created_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .notNull(),
  },
  (table) => [
    index("cargo_status_event_cargo_id_idx").on(table.cargoId),
    index("cargo_status_event_changed_by_user_id_idx").on(table.changedByUserId),
  ]
);
