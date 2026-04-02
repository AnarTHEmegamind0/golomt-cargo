export const cargoStatuses = [
  "CREATED",
  "RECEIVED_CHINA",
  "IN_TRANSIT_TO_MN",
  "ARRIVED_MN",
  "AWAITING_FULFILLMENT_CHOICE",
  "READY_FOR_PICKUP",
  "OUT_FOR_DELIVERY",
  "COMPLETED_PICKUP",
  "COMPLETED_DELIVERY",
] as const;

export type CargoStatus = (typeof cargoStatuses)[number];

export const fulfillmentTypes = ["PICKUP", "HOME_DELIVERY"] as const;
export type FulfillmentType = (typeof fulfillmentTypes)[number];

export const cargoPaymentStatuses = ["UNPAID", "PAID"] as const;
export type CargoPaymentStatus = (typeof cargoPaymentStatuses)[number];
