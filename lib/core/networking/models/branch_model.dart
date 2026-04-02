/// Branch model from API
class BranchModel {
  const BranchModel({
    required this.id,
    required this.code,
    required this.name,
    this.address,
    this.phone,
    this.isActive = true,
    this.chinaAddress,
    this.latitude,
    this.longitude,
    this.workingHours,
  });

  final String id;
  final String code;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;
  final String? chinaAddress;
  final double? latitude;
  final double? longitude;
  final String? workingHours;

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      chinaAddress: json['chinaAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      workingHours: json['workingHours'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      'isActive': isActive,
      if (chinaAddress != null) 'chinaAddress': chinaAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (workingHours != null) 'workingHours': workingHours,
    };
  }
}

/// API response wrapper for branch list
class BranchListResponse {
  const BranchListResponse({required this.message, required this.data});

  final String message;
  final List<BranchModel> data;

  factory BranchListResponse.fromJson(Map<String, dynamic> json) {
    return BranchListResponse(
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => BranchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
