import { relations } from "drizzle-orm";
import { account, session, user } from "~/db/schema/tables/auth";
import { branch } from "~/db/schema/tables/branch";
import { cargo, cargoStatusEvent } from "~/db/schema/tables/cargo";
import { payment, paymentCargo } from "~/db/schema/tables/payment";

export const userRelations = relations(user, ({ many }) => ({
  sessions: many(session),
  accounts: many(account),
  cargos: many(cargo),
  payments: many(payment),
  cargoStatusEvents: many(cargoStatusEvent),
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
