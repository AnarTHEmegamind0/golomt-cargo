export const toIsoString = (value?: Date | number | null) => {
  if (!value) return null;
  return new Date(value).toISOString();
};

export const parseMetadataJson = (value?: string | null) => {
  if (!value) return null;
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
};

export const toCargoSummary = (row: any) => ({
  id: row.id,
  trackingNumber: row.trackingNumber,
  description: row.description ?? null,
  status: row.status,
  paymentStatus: row.paymentStatus,
  receivedImageUrl: row.receivedImageUrl ?? null,
  fulfillmentType: row.fulfillmentType ?? null,
  deliveryAddress: row.deliveryAddress ?? null,
  deliveryPhone: row.deliveryPhone ?? null,
  weightGrams: row.weightGrams ?? null,
  baseShippingFeeMnt: row.baseShippingFeeMnt ?? null,
  totalFeeMnt: row.totalFeeMnt ?? null,
  createdAt: toIsoString(row.createdAt),
  updatedAt: toIsoString(row.updatedAt),
  customer: row.customerId
    ? {
        id: row.customerId,
        name: row.customerName,
        email: row.customerEmail,
      }
    : null,
  heightCm: row.heightCm ?? null,
  widthCm: row.widthCm ?? null,
  lengthCm: row.lengthCm ?? null,
  isFragile: Boolean(row.isFragile ?? false),
  calculatedFeeMnt: row.calculatedFeeMnt ?? null,
  overrideFeeMnt: row.overrideFeeMnt ?? null,
  shipmentId: row.shipmentId ?? null,
});

export const toVehicleSummary = (row: any) => ({
  id: row.id,
  plate_number: row.plateNumber,
  name: row.name,
  type: row.type,
  is_active: Boolean(row.isActive),
  created_at: toIsoString(row.createdAt),
  updated_at: toIsoString(row.updatedAt),
});

export const toShipmentSummary = (row: any, cargoIds: string[]) => ({
  id: row.id,
  vehicle_id: row.vehicleId,
  vehicle_plate_number: row.vehiclePlateNumber,
  status: row.status,
  created_at: toIsoString(row.createdAt),
  departure_date: toIsoString(row.departureDate),
  arrival_date: toIsoString(row.arrivalDate),
  cargo_count: cargoIds.length,
  note: row.note ?? null,
  cargo_ids: cargoIds,
});

export const toAdminLogSummary = (row: any) => ({
  id: row.id,
  admin_id: row.actorUserId ?? "",
  admin_name: row.actorName ?? "Unknown",
  action: row.action,
  target_type: row.targetType,
  target_id: row.targetId ?? null,
  description: row.description,
  created_at: toIsoString(row.createdAt),
  metadata: parseMetadataJson(row.metadataJson),
});
