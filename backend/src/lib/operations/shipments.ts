import type { CargoStatus } from "~/db/schema/constants/cargo";
import type { ShipmentStatus } from "~/db/schema/constants/operations";

export const SHIPMENT_STATUS_FLOW: Record<ShipmentStatus, ShipmentStatus[]> = {
  DRAFT: ["DEPARTED"],
  DEPARTED: ["IN_TRANSIT"],
  IN_TRANSIT: ["ARRIVED"],
  ARRIVED: ["COMPLETED"],
  COMPLETED: [],
};

export const isValidShipmentTransition = (from: ShipmentStatus, to: ShipmentStatus) =>
  SHIPMENT_STATUS_FLOW[from].includes(to);

export const getCargoStatusForShipmentStatus = (status: ShipmentStatus): CargoStatus | null => {
  switch (status) {
    case "DEPARTED":
    case "IN_TRANSIT":
      return "IN_TRANSIT_TO_MN";
    case "ARRIVED":
      return "AWAITING_FULFILLMENT_CHOICE";
    default:
      return null;
  }
};
