import { sql } from "drizzle-orm";
import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";
import { user } from "~/db/schema/tables/auth";
import {
  adminActivityActions,
  adminActivityTargetTypes,
  shipmentStatuses,
  vehicleTypes,
  type AdminActivityAction,
  type AdminActivityTargetType,
  type ShipmentStatus,
  type VehicleType,
} from "~/db/schema/constants/operations";
import {
  cargoImportSources,
  type CargoImportSource,
} from "~/db/schema/constants/cargo";
import { appRoles, type AppRole } from "~/lib/constants/roles";

export const vehicle = sqliteTable(
  "vehicle",
  {
    id: text("id").primaryKey(),
    plateNumber: text("plate_number").notNull().unique(),
    name: text("name").notNull(),
    type: text("type", { enum: vehicleTypes }).$type<VehicleType>().notNull(),
    isActive: integer("is_active", { mode: "boolean" }).default(true).notNull(),
    createdByUserId: text("created_by_user_id").references(() => user.id, {
      onDelete: "set null",
    }),
    createdAt: integer("created_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .notNull(),
    updatedAt: integer("updated_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [index("vehicle_created_by_user_id_idx").on(table.createdByUserId)]
);

export const shipment = sqliteTable(
  "shipment",
  {
    id: text("id").primaryKey(),
    vehicleId: text("vehicle_id")
      .notNull()
      .references(() => vehicle.id, { onDelete: "restrict" }),
    status: text("status", { enum: shipmentStatuses }).$type<ShipmentStatus>().notNull().default("DRAFT"),
    note: text("note"),
    departureDate: integer("departure_date", { mode: "timestamp_ms" }),
    arrivalDate: integer("arrival_date", { mode: "timestamp_ms" }),
    createdByUserId: text("created_by_user_id").references(() => user.id, {
      onDelete: "set null",
    }),
    createdAt: integer("created_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .notNull(),
    updatedAt: integer("updated_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    index("shipment_vehicle_id_idx").on(table.vehicleId),
    index("shipment_status_idx").on(table.status),
    index("shipment_created_by_user_id_idx").on(table.createdByUserId),
  ]
);

export const adminActivityLog = sqliteTable(
  "admin_activity_log",
  {
    id: text("id").primaryKey(),
    actorUserId: text("actor_user_id").references(() => user.id, {
      onDelete: "set null",
    }),
    actorRole: text("actor_role", { enum: appRoles }).$type<AppRole>(),
    action: text("action", { enum: adminActivityActions }).$type<AdminActivityAction>().notNull(),
    targetType: text("target_type", { enum: adminActivityTargetTypes })
      .$type<AdminActivityTargetType>()
      .notNull(),
    targetId: text("target_id"),
    description: text("description").notNull(),
    metadataJson: text("metadata_json"),
    createdAt: integer("created_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .notNull(),
  },
  (table) => [
    index("admin_activity_log_actor_user_id_idx").on(table.actorUserId),
    index("admin_activity_log_action_idx").on(table.action),
    index("admin_activity_log_target_type_idx").on(table.targetType),
    index("admin_activity_log_created_at_idx").on(table.createdAt),
  ]
);

export const importBatch = sqliteTable(
  "import_batch",
  {
    id: text("id").primaryKey(),
    sourceType: text("source_type", { enum: cargoImportSources })
      .$type<CargoImportSource>()
      .notNull(),
    uploadedFilename: text("uploaded_filename"),
    totalCount: integer("total_count").notNull().default(0),
    successCount: integer("success_count").notNull().default(0),
    failedCount: integer("failed_count").notNull().default(0),
    createdByUserId: text("created_by_user_id").references(() => user.id, {
      onDelete: "set null",
    }),
    createdAt: integer("created_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .notNull(),
  },
  (table) => [
    index("import_batch_source_type_idx").on(table.sourceType),
    index("import_batch_created_by_user_id_idx").on(table.createdByUserId),
  ]
);
