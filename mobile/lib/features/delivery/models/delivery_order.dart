import 'package:flutter/material.dart';

enum DeliveryStep {
  pending,
  accepted,
  pickedUp,
  enRoute,
  arrived,
  proof,
  completed,
}

class DeliveryOrder {
  const DeliveryOrder({
    required this.id,
    required this.restaurantName,
    required this.customerName,
    required this.deliveryAddress,
    required this.etaMinutes,
    required this.earnings,
    required this.items,
    required this.instructions,
    required this.primaryColor,
    required this.secondaryColor,
    required this.imageHeroTag,
    this.step = DeliveryStep.pending,
    this.proofImagePath,
  });

  final String id;
  final String restaurantName;
  final String customerName;
  final String deliveryAddress;
  final int etaMinutes;
  final double earnings;
  final List<String> items;
  final String instructions;
  final Color primaryColor;
  final Color secondaryColor;
  final String imageHeroTag;
  final DeliveryStep step;
  final String? proofImagePath;

  DeliveryOrder copyWith({DeliveryStep? step, String? proofImagePath}) {
    return DeliveryOrder(
      id: id,
      restaurantName: restaurantName,
      customerName: customerName,
      deliveryAddress: deliveryAddress,
      etaMinutes: etaMinutes,
      earnings: earnings,
      items: items,
      instructions: instructions,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      imageHeroTag: imageHeroTag,
      step: step ?? this.step,
      proofImagePath: proofImagePath ?? this.proofImagePath,
    );
  }
}
