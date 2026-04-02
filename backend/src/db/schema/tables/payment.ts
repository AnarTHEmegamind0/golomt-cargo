import { sql } from "drizzle-orm";
import { index, integer, sqliteTable, text, uniqueIndex } from "drizzle-orm/sqlite-core";
import {
  paymentMethods,
  paymentStatuses,
  type PaymentMethod,
  type PaymentStatus,
} from "~/db/schema/constants/payment";
import { user } from "~/db/schema/tables/auth";
import { cargo } from "~/db/schema/tables/cargo";

export const payment = sqliteTable(
  "payment",
  {
    id: text("id").primaryKey(),
    customerId: text("customer_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    status: text("status", { enum: paymentStatuses })
      .$type<PaymentStatus>()
      .notNull()
      .default("PENDING"),
    method: text("method", { enum: paymentMethods })
      .$type<PaymentMethod>()
      .notNull(),
    provider: text("provider"),
    providerPaymentId: text("provider_payment_id"),
    totalAmountMnt: integer("total_amount_mnt").notNull(),
    currency: text("currency").notNull().default("MNT"),
    paidAt: integer("paid_at", { mode: "timestamp_ms" }),
    note: text("note"),
    createdAt: integer("created_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .notNull(),
    updatedAt: integer("updated_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    index("payment_customer_id_idx").on(table.customerId),
    index("payment_status_idx").on(table.status),
    index("payment_method_idx").on(table.method),
  ]
);

export const paymentCargo = sqliteTable(
  "payment_cargo",
  {
    id: text("id").primaryKey(),
    paymentId: text("payment_id")
      .notNull()
      .references(() => payment.id, { onDelete: "cascade" }),
    cargoId: text("cargo_id")
      .notNull()
      .references(() => cargo.id, { onDelete: "restrict" }),
    amountMnt: integer("amount_mnt").notNull(),
    createdAt: integer("created_at", { mode: "timestamp_ms" })
      .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
      .notNull(),
  },
  (table) => [
    index("payment_cargo_payment_id_idx").on(table.paymentId),
    index("payment_cargo_cargo_id_idx").on(table.cargoId),
    uniqueIndex("payment_cargo_payment_id_cargo_id_uidx").on(
      table.paymentId,
      table.cargoId
    ),
  ]
);
