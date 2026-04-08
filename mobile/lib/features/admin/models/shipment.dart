import 'package:core/core/brand_palette.dart';
import 'package:flutter/material.dart';

/// Shipment status for tracking shipment progress
enum ShipmentStatus {
  draft('DRAFT', 'Бэлтгэж буй'),
  departed('DEPARTED', 'Хөдөлсөн'),
  inTransit('IN_TRANSIT', 'Замд яваа'),
  arrived('ARRIVED', 'Ирсэн'),
  completed('COMPLETED', 'Дууссан');

  const ShipmentStatus(this.value, this.label);

  final String value;
  final String label;

  static ShipmentStatus fromString(String value) {
    return ShipmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShipmentStatus.draft,
    );
  }

  Color get color {
    return switch (this) {
      ShipmentStatus.draft => const Color(0xFF94A3B8),
      ShipmentStatus.departed => const Color(0xFFFBBF24),
      ShipmentStatus.inTransit => BrandPalette.electricBlue,
      ShipmentStatus.arrived => const Color(0xFF8B5CF6),
      ShipmentStatus.completed => BrandPalette.successGreen,
    };
  }

  /// Get next possible status transitions
  List<ShipmentStatus> get nextStatuses {
    return switch (this) {
      ShipmentStatus.draft => [ShipmentStatus.departed],
      ShipmentStatus.departed => [ShipmentStatus.inTransit],
      ShipmentStatus.inTransit => [ShipmentStatus.arrived],
      ShipmentStatus.arrived => [ShipmentStatus.completed],
      ShipmentStatus.completed => [],
    };
  }
}

/// Shipment (ачилт) model for managing cargo batches
class Shipment {
  const Shipment({
    required this.id,
    required this.vehicleId,
    required this.vehiclePlateNumber,
    required this.status,
    required this.createdAt,
    this.departureDate,
    this.arrivalDate,
    this.cargoCount = 0,
    this.note,
    this.cargoIds = const [],
  });

  final String id;
  final String vehicleId;
  final String vehiclePlateNumber;
  final ShipmentStatus status;
  final DateTime createdAt;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final int cargoCount;
  final String? note;
  final List<String> cargoIds;

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      vehiclePlateNumber: json['vehicle_plate_number'] as String? ?? '',
      status: ShipmentStatus.fromString(json['status'] as String? ?? 'DRAFT'),
      createdAt: DateTime.parse(json['created_at'] as String),
      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'] as String)
          : null,
      arrivalDate: json['arrival_date'] != null
          ? DateTime.parse(json['arrival_date'] as String)
          : null,
      cargoCount: json['cargo_count'] as int? ?? 0,
      note: json['note'] as String?,
      cargoIds: (json['cargo_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'vehicle_plate_number': vehiclePlateNumber,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      if (departureDate != null)
        'departure_date': departureDate!.toIso8601String(),
      if (arrivalDate != null) 'arrival_date': arrivalDate!.toIso8601String(),
      'cargo_count': cargoCount,
      if (note != null) 'note': note,
      'cargo_ids': cargoIds,
    };
  }

  Shipment copyWith({
    String? id,
    String? vehicleId,
    String? vehiclePlateNumber,
    ShipmentStatus? status,
    DateTime? createdAt,
    DateTime? departureDate,
    DateTime? arrivalDate,
    int? cargoCount,
    String? note,
    List<String>? cargoIds,
  }) {
    return Shipment(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      departureDate: departureDate ?? this.departureDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      cargoCount: cargoCount ?? this.cargoCount,
      note: note ?? this.note,
      cargoIds: cargoIds ?? this.cargoIds,
    );
  }

  /// Display formatted date range
  String get dateRangeDisplay {
    if (departureDate == null) return 'Огноо тодорхойгүй';
    final dep = '${departureDate!.month}/${departureDate!.day}';
    if (arrivalDate == null) return '$dep -';
    final arr = '${arrivalDate!.month}/${arrivalDate!.day}';
    return '$dep - $arr';
  }

  @override
  String toString() => 'Shipment($id, $vehiclePlateNumber, ${status.label})';
}
