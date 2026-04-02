export const paymentStatuses = [
  "PENDING",
  "PAID",
  "FAILED",
  "CANCELLED",
  "REFUNDED",
] as const;

export type PaymentStatus = (typeof paymentStatuses)[number];

export const paymentMethods = ["APP", "CASH_IN_PERSON"] as const;
export type PaymentMethod = (typeof paymentMethods)[number];
