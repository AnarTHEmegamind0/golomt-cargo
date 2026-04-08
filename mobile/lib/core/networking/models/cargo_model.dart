/// Cargo status enum matching API
enum CargoStatus {
  created('CREATED'),
  receivedChina('RECEIVED_CHINA'),
  inTransitToMn('IN_TRANSIT_TO_MN'),
  arrivedMn('ARRIVED_MN'),
  awaitingFulfillmentChoice('AWAITING_FULFILLMENT_CHOICE'),
  readyForPickup('READY_FOR_PICKUP'),
  outForDelivery('OUT_FOR_DELIVERY'),
  completedPickup('COMPLETED_PICKUP'),
  completedDelivery('COMPLETED_DELIVERY');

  const CargoStatus(this.value);
  final String value;

  static CargoStatus fromString(String value) {
    return CargoStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CargoStatus.created,
    );
  }

  String get label {
    switch (this) {
      case CargoStatus.created:
        return 'Үүсгэгдсэн';
      case CargoStatus.receivedChina:
        return 'Хятадад хүлээн авсан';
      case CargoStatus.inTransitToMn:
        return 'Монгол руу явж байна';
      case CargoStatus.arrivedMn:
        return 'Монголд ирсэн';
      case CargoStatus.awaitingFulfillmentChoice:
        return 'Хүргэлтийн сонголт хүлээж байна';
      case CargoStatus.readyForPickup:
        return 'Авахад бэлэн';
      case CargoStatus.outForDelivery:
        return 'Хүргэлтэд гарсан';
      case CargoStatus.completedPickup:
        return 'Авсан';
      case CargoStatus.completedDelivery:
        return 'Хүргэгдсэн';
    }
  }

  int get stepIndex {
    switch (this) {
      case CargoStatus.created:
        return 0;
      case CargoStatus.receivedChina:
        return 1;
      case CargoStatus.inTransitToMn:
        return 2;
      case CargoStatus.arrivedMn:
        return 3;
      case CargoStatus.awaitingFulfillmentChoice:
        return 4;
      case CargoStatus.readyForPickup:
      case CargoStatus.outForDelivery:
        return 5;
      case CargoStatus.completedPickup:
      case CargoStatus.completedDelivery:
        return 6;
    }
  }
}

/// Payment status enum
enum PaymentStatus {
  unpaid('UNPAID'),
  paid('PAID');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }

  String get label {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Төлөгдөөгүй';
      case PaymentStatus.paid:
        return 'Төлөгдсөн';
    }
  }
}

/// Fulfillment type enum
enum FulfillmentType {
  pickup('PICKUP'),
  homeDelivery('HOME_DELIVERY');

  const FulfillmentType(this.value);
  final String value;

  static FulfillmentType? fromString(String? value) {
    if (value == null) return null;
    return FulfillmentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FulfillmentType.pickup,
    );
  }

  String get label {
    switch (this) {
      case FulfillmentType.pickup:
        return 'Өөрөө авах';
      case FulfillmentType.homeDelivery:
        return 'Гэрт хүргүүлэх';
    }
  }
}

/// Cargo model from API
class CargoCustomerModel {
  const CargoCustomerModel({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory CargoCustomerModel.fromJson(Map<String, dynamic> json) {
    return CargoCustomerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class CargoModel {
  const CargoModel({
    required this.id,
    required this.trackingNumber,
    required this.status,
    required this.paymentStatus,
    this.description,
    this.receivedImageUrl,
    this.fulfillmentType,
    this.deliveryAddress,
    this.deliveryPhone,
    this.weightGrams,
    this.baseShippingFeeMnt,
    this.totalFeeMnt,
    this.createdAt,
    this.updatedAt,
    this.customer,
    // Dimension fields
    this.heightCm,
    this.widthCm,
    this.lengthCm,
    this.isFragile = false,
    // Pricing fields
    this.calculatedFeeMnt,
    this.overrideFeeMnt,
    // Shipment reference
    this.shipmentId,
  });

  final String id;
  final String trackingNumber;
  final CargoStatus status;
  final PaymentStatus paymentStatus;
  final String? description;
  final String? receivedImageUrl;
  final FulfillmentType? fulfillmentType;
  final String? deliveryAddress;
  final String? deliveryPhone;
  final int? weightGrams;
  final int? baseShippingFeeMnt;
  final int? totalFeeMnt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CargoCustomerModel? customer;
  // Dimension fields
  final int? heightCm;
  final int? widthCm;
  final int? lengthCm;
  final bool isFragile;
  // Pricing fields
  final int? calculatedFeeMnt;
  final int? overrideFeeMnt;
  // Shipment reference
  final String? shipmentId;

  /// Check if cargo has dimensions recorded
  bool get hasDimensions =>
      heightCm != null && widthCm != null && lengthCm != null;

  /// Calculate volume in cubic meters
  double get volumeCbm {
    if (!hasDimensions) return 0;
    return (heightCm! * widthCm! * lengthCm!) / 1000000.0;
  }

  /// Weight in kilograms
  double get weightKg => (weightGrams ?? 0) / 1000.0;

  /// Dimensions display string
  String get dimensionsDisplay {
    if (!hasDimensions) return '-';
    return '${lengthCm}x${widthCm}x${heightCm}см';
  }

  /// Final fee to display (override or calculated or base)
  int get finalFeeMnt =>
      overrideFeeMnt ?? calculatedFeeMnt ?? totalFeeMnt ?? baseShippingFeeMnt ?? 0;

  factory CargoModel.fromJson(Map<String, dynamic> json) {
    return CargoModel(
      id: json['id'] as String,
      trackingNumber: json['trackingNumber'] as String,
      status: CargoStatus.fromString(json['status'] as String? ?? 'CREATED'),
      paymentStatus: PaymentStatus.fromString(
        json['paymentStatus'] as String? ?? 'UNPAID',
      ),
      description: json['description'] as String?,
      receivedImageUrl: json['receivedImageUrl'] as String?,
      fulfillmentType: FulfillmentType.fromString(
        json['fulfillmentType'] as String?,
      ),
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryPhone: json['deliveryPhone'] as String?,
      weightGrams: _asInt(json['weightGrams']),
      baseShippingFeeMnt: _asInt(json['baseShippingFeeMnt']),
      totalFeeMnt: _asInt(json['totalFeeMnt']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      customer: json['customer'] is Map<String, dynamic>
          ? CargoCustomerModel.fromJson(
              json['customer'] as Map<String, dynamic>,
            )
          : null,
      // Dimension fields
      heightCm: _asInt(json['heightCm']),
      widthCm: _asInt(json['widthCm']),
      lengthCm: _asInt(json['lengthCm']),
      isFragile: json['isFragile'] as bool? ?? false,
      // Pricing fields
      calculatedFeeMnt: _asInt(json['calculatedFeeMnt']),
      overrideFeeMnt: _asInt(json['overrideFeeMnt']),
      // Shipment reference
      shipmentId: json['shipmentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'status': status.value,
      'paymentStatus': paymentStatus.value,
      if (description != null) 'description': description,
      if (receivedImageUrl != null) 'receivedImageUrl': receivedImageUrl,
      if (fulfillmentType != null) 'fulfillmentType': fulfillmentType!.value,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (deliveryPhone != null) 'deliveryPhone': deliveryPhone,
      if (weightGrams != null) 'weightGrams': weightGrams,
      if (baseShippingFeeMnt != null) 'baseShippingFeeMnt': baseShippingFeeMnt,
      if (totalFeeMnt != null) 'totalFeeMnt': totalFeeMnt,
      // Dimension fields
      if (heightCm != null) 'heightCm': heightCm,
      if (widthCm != null) 'widthCm': widthCm,
      if (lengthCm != null) 'lengthCm': lengthCm,
      'isFragile': isFragile,
      // Pricing fields
      if (calculatedFeeMnt != null) 'calculatedFeeMnt': calculatedFeeMnt,
      if (overrideFeeMnt != null) 'overrideFeeMnt': overrideFeeMnt,
      // Shipment reference
      if (shipmentId != null) 'shipmentId': shipmentId,
    };
  }

  CargoModel copyWith({
    String? id,
    String? trackingNumber,
    CargoStatus? status,
    PaymentStatus? paymentStatus,
    String? description,
    String? receivedImageUrl,
    FulfillmentType? fulfillmentType,
    String? deliveryAddress,
    String? deliveryPhone,
    int? weightGrams,
    int? baseShippingFeeMnt,
    int? totalFeeMnt,
    DateTime? createdAt,
    DateTime? updatedAt,
    CargoCustomerModel? customer,
    // Dimension fields
    int? heightCm,
    int? widthCm,
    int? lengthCm,
    bool? isFragile,
    // Pricing fields
    int? calculatedFeeMnt,
    int? overrideFeeMnt,
    // Shipment reference
    String? shipmentId,
  }) {
    return CargoModel(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      description: description ?? this.description,
      receivedImageUrl: receivedImageUrl ?? this.receivedImageUrl,
      fulfillmentType: fulfillmentType ?? this.fulfillmentType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryPhone: deliveryPhone ?? this.deliveryPhone,
      weightGrams: weightGrams ?? this.weightGrams,
      baseShippingFeeMnt: baseShippingFeeMnt ?? this.baseShippingFeeMnt,
      totalFeeMnt: totalFeeMnt ?? this.totalFeeMnt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      // Dimension fields
      heightCm: heightCm ?? this.heightCm,
      widthCm: widthCm ?? this.widthCm,
      lengthCm: lengthCm ?? this.lengthCm,
      isFragile: isFragile ?? this.isFragile,
      // Pricing fields
      calculatedFeeMnt: calculatedFeeMnt ?? this.calculatedFeeMnt,
      overrideFeeMnt: overrideFeeMnt ?? this.overrideFeeMnt,
      // Shipment reference
      shipmentId: shipmentId ?? this.shipmentId,
    );
  }
}

class CargoPaginationMeta {
  const CargoPaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory CargoPaginationMeta.fromJson(Map<String, dynamic> json) {
    return CargoPaginationMeta(
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 20,
      total: _asInt(json['total']) ?? 0,
      totalPages: _asInt(json['totalPages']) ?? 1,
    );
  }
}

/// Cargo event model (timeline)
class CargoEventModel {
  const CargoEventModel({
    required this.id,
    required this.toStatus,
    required this.createdAt,
    this.fromStatus,
    this.note,
  });

  final String id;
  final String toStatus;
  final DateTime createdAt;
  final String? fromStatus;
  final String? note;

  factory CargoEventModel.fromJson(Map<String, dynamic> json) {
    return CargoEventModel(
      id: json['id'] as String,
      toStatus: json['toStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fromStatus: json['fromStatus'] as String?,
      note: json['note'] as String?,
    );
  }
}

/// Cargo stats model
class CargoStatsModel {
  const CargoStatsModel({
    required this.total,
    required this.byStatus,
    required this.byPaymentStatus,
  });

  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byPaymentStatus;

  factory CargoStatsModel.fromJson(Map<String, dynamic> json) {
    return CargoStatsModel(
      total: _asInt(json['total']) ?? 0,
      byStatus: _asIntMap(json['byStatus']),
      byPaymentStatus: _asIntMap(json['byPaymentStatus']),
    );
  }
}

/// API response wrapper for cargo list
class CargoListResponse {
  const CargoListResponse({
    required this.message,
    required this.data,
    required this.meta,
  });

  final String message;
  final List<CargoModel> data;
  final CargoPaginationMeta meta;

  factory CargoListResponse.fromJson(Map<String, dynamic> json) {
    return CargoListResponse(
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => CargoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: CargoPaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

/// API response wrapper for single cargo
class CargoResponse {
  const CargoResponse({required this.message, required this.data});

  final String message;
  final CargoModel data;

  factory CargoResponse.fromJson(Map<String, dynamic> json) {
    return CargoResponse(
      message: json['message'] as String,
      data: CargoModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// API response wrapper for cargo stats
class CargoStatsResponse {
  const CargoStatsResponse({required this.message, required this.data});

  final String message;
  final CargoStatsModel data;

  factory CargoStatsResponse.fromJson(Map<String, dynamic> json) {
    return CargoStatsResponse(
      message: json['message'] as String,
      data: CargoStatsModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// API response wrapper for cargo events
class CargoEventsResponse {
  const CargoEventsResponse({required this.message, required this.data});

  final String message;
  final List<CargoEventModel> data;

  factory CargoEventsResponse.fromJson(Map<String, dynamic> json) {
    return CargoEventsResponse(
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => CargoEventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

Map<String, int> _asIntMap(dynamic value) {
  if (value is! Map) {
    return <String, int>{};
  }

  final result = <String, int>{};
  value.forEach((key, raw) {
    final parsed = _asInt(raw);
    if (parsed != null) {
      result[key.toString()] = parsed;
    }
  });
  return result;
}
