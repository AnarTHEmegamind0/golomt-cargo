import { relations } from "drizzle-orm";
import { account, session, user } from "~/db/schema/tables/auth";
import { branch } from "~/db/schema/tables/branch";
import { cargo, cargoStatusEvent } from "~/db/schema/tables/cargo";
import { adminActivityLog, importBatch, shipment, vehicle } from "~/db/schema/tables/operations";
import { payment, paymentCargo } from "~/db/schema/tables/payment";

export const userRelations = relations(user, ({ many }) => ({
  sessions: many(session),
  accounts: many(account),
  cargos: many(cargo),
  payments: many(payment),
  cargoStatusEvents: many(cargoStatusEvent),
  createdVehicles: many(vehicle),
  createdShipments: many(shipment),
  activityLogs: many(adminActivityLog),
  importBatches: many(importBatch),
}));

export const sessionRelations = relations(session, ({ one }) => ({
  user: one(user, {
    fields: [session.userId],
    references: [user.id],
  }),
}));

export const accountRelations = relations(account, ({ one }) => ({
  user: one(user, {
    fields: [account.userId],
    references: [user.id],
  }),
}));

export const branchRelations = relations(branch, ({ many }) => ({
  cargos: many(cargo),
}));

export const cargoRelations = relations(cargo, ({ one, many }) => ({
  customer: one(user, {
    fields: [cargo.customerId],
    references: [user.id],
  }),
  branch: one(branch, {
    fields: [cargo.branchId],
    references: [branch.id],
  }),
  shipment: one(shipment, {
    fields: [cargo.shipmentId],
    references: [shipment.id],
  }),
  pricedBy: one(user, {
    fields: [cargo.pricedByUserId],
    references: [user.id],
  }),
  importBatch: one(importBatch, {
    fields: [cargo.importBatchId],
    references: [importBatch.id],
  }),
  statusEvents: many(cargoStatusEvent),
  paymentItems: many(paymentCargo),
}));

export const cargoStatusEventRelations = relations(cargoStatusEvent, ({ one }) => ({
  cargo: one(cargo, {
    fields: [cargoStatusEvent.cargoId],
    references: [cargo.id],
  }),
  changedBy: one(user, {
    fields: [cargoStatusEvent.changedByUserId],
    references: [user.id],
  }),
}));

export const paymentRelations = relations(payment, ({ one, many }) => ({
  customer: one(user, {
    fields: [payment.customerId],
    references: [user.id],
  }),
  cargoItems: many(paymentCargo),
}));

export const paymentCargoRelations = relations(paymentCargo, ({ one }) => ({
  payment: one(payment, {
    fields: [paymentCargo.paymentId],
    references: [payment.id],
  }),
  cargo: one(cargo, {
    fields: [paymentCargo.cargoId],
    references: [cargo.id],
  }),
}));

export const vehicleRelations = relations(vehicle, ({ one, many }) => ({
  createdBy: one(user, {
    fields: [vehicle.createdByUserId],
    references: [user.id],
  }),
  shipments: many(shipment),
}));

export const shipmentRelations = relations(shipment, ({ one, many }) => ({
  vehicle: one(vehicle, {
    fields: [shipment.vehicleId],
    references: [vehicle.id],
  }),
  createdBy: one(user, {
    fields: [shipment.createdByUserId],
    references: [user.id],
  }),
  cargos: many(cargo),
}));

export const adminActivityLogRelations = relations(adminActivityLog, ({ one }) => ({
  actor: one(user, {
    fields: [adminActivityLog.actorUserId],
    references: [user.id],
  }),
}));

export const importBatchRelations = relations(importBatch, ({ one, many }) => ({
  createdBy: one(user, {
    fields: [importBatch.createdByUserId],
    references: [user.id],
  }),
  cargos: many(cargo),
}));
