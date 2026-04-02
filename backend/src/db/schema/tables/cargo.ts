import { sql } from "drizzle-orm";
import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";
import {
  cargoPaymentStatuses,
  cargoStatuses,
  fulfillmentTypes,
  type CargoPaymentStatus,
  type CargoStatus,
  type FulfillmentType,
} from "~/db/schema/constants/cargo";
import { user } from "~/db/schema/tables/auth";
import { branch } from "~/db/schema/tables/branch";

export const cargo = sqliteTable(
  "cargo",
  {
    id: text("id").primaryKey(),
    customerId: text("customer_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    branchId: text("branch_id").references(() => branch.id, {
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
    baseShippingFeeMnt: integer("base_shipping_fee_mnt"),
    localDeliveryFeeMnt: integer("local_delivery_fee_mnt").notNull().default(0),
    totalFeeMnt: integer("total_fee_mnt"),
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
    index("cargo_status_idx").on(table.status),
    index("cargo_payment_status_idx").on(table.paymentStatus),
    index("cargo_tracking_number_idx").on(table.trackingNumber),
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
