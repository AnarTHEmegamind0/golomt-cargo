export const vehicleTypes = ["TRUCK", "VAN", "CONTAINER"] as const;
export type VehicleType = (typeof vehicleTypes)[number];

export const shipmentStatuses = ["DRAFT", "DEPARTED", "IN_TRANSIT", "ARRIVED", "COMPLETED"] as const;
export type ShipmentStatus = (typeof shipmentStatuses)[number];

export const adminActivityActions = [
  "CREATE",
  "UPDATE",
  "DELETE",
  "STATUS_CHANGE",
  "RECEIVE",
  "SHIP",
  "ARRIVE",
  "BAN",
  "UNBAN",
  "ROLE_CHANGE",
  "PRICE_OVERRIDE",
  "WEIGHT_RECORD",
  "IMPORT",
  "EXPORT",
  "ASSIGN_SHIPMENT",
  "REMOVE_SHIPMENT_CARGO",
] as const;
export type AdminActivityAction = (typeof adminActivityActions)[number];

export const adminActivityTargetTypes = [
  "CARGO",
  "USER",
  "SHIPMENT",
  "VEHICLE",
  "BRANCH",
  "EXPORT_JOB",
] as const;
export type AdminActivityTargetType = (typeof adminActivityTargetTypes)[number];
