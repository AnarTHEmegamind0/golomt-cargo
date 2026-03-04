import 'package:flutter/material.dart';

/// Branch/Warehouse location model
class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.chinaAddress,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.workingHours,
    required this.iconColor,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String address;
  final String chinaAddress;
  final double latitude;
  final double longitude;
  final String phone;
  final String workingHours;
  final Color iconColor;
  final String? description;
  final String? imageUrl;
  final bool isActive;

  Branch copyWith({
    String? name,
    String? address,
    String? chinaAddress,
    double? latitude,
    double? longitude,
    String? phone,
    String? workingHours,
    Color? iconColor,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) {
    return Branch(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      chinaAddress: chinaAddress ?? this.chinaAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      workingHours: workingHours ?? this.workingHours,
      iconColor: iconColor ?? this.iconColor,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
