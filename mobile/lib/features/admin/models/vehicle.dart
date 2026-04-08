/// Vehicle type for cargo transportation
enum VehicleType {
  truck('TRUCK', 'Ачааны машин'),
  van('VAN', 'Фургон'),
  container('CONTAINER', 'Контейнер');

  const VehicleType(this.value, this.label);

  final String value;
  final String label;

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VehicleType.truck,
    );
  }
}

/// Vehicle/Truck model for shipment management
class Vehicle {
  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.name,
    required this.type,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String plateNumber;
  final String name;
  final VehicleType type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      plateNumber: json['plate_number'] as String,
      name: json['name'] as String,
      type: VehicleType.fromString(json['type'] as String? ?? 'TRUCK'),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'name': name,
      'type': type.value,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    String? name,
    VehicleType? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      name: name ?? this.name,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Vehicle($plateNumber - $name)';
}
