import 'package:core/core/assets/ship_assets.dart';
import 'package:flutter/material.dart';

/// Order status enum
enum OrderStatus { pending, processing, transit, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Хүлээгдэж буй';
      case OrderStatus.processing:
        return 'Боловсруулж буй';
      case OrderStatus.transit:
        return 'Замд';
      case OrderStatus.delivered:
        return 'Хүргэгдсэн';
      case OrderStatus.cancelled:
        return 'Цуцлагдсан';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFFBBF24);
      case OrderStatus.processing:
        return const Color(0xFF8B5CF6);
      case OrderStatus.transit:
        return const Color(0xFF3B82F6);
      case OrderStatus.delivered:
        return const Color(0xFF10B981);
      case OrderStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.processing:
        return Icons.inventory_2_rounded;
      case OrderStatus.transit:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String get shipAsset {
    switch (this) {
      case OrderStatus.pending:
        return ShipAssets.clockAndHome;
      case OrderStatus.processing:
        return ShipAssets.delivery;
      case OrderStatus.transit:
        return ShipAssets.truck;
      case OrderStatus.delivered:
        return ShipAssets.mailArrivedAndHand;
      case OrderStatus.cancelled:
        return ShipAssets.packageReturn;
    }
  }
}

/// Order model
class Order {
  const Order({
    required this.id,
    required this.trackingCode,
    required this.productName,
    required this.status,
    required this.createdAt,
    required this.price,
    required this.weight,
    this.rawStatus,
    this.deliveryAddress,
    this.estimatedDelivery,
    this.deliveredAt,
    this.imageUrl,
    this.isPaid = false,
    this.customerName,
    this.customerEmail,
  });

  final String id;
  final String trackingCode;
  final String productName;
  final OrderStatus status;
  final DateTime createdAt;
  final double price;
  final double weight; // in kg
  final String? rawStatus;
  final String? deliveryAddress;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final String? imageUrl;
  final bool isPaid;
  final String? customerName;
  final String? customerEmail;

  Order copyWith({
    String? trackingCode,
    String? productName,
    OrderStatus? status,
    DateTime? createdAt,
    double? price,
    double? weight,
    String? rawStatus,
    String? deliveryAddress,
    DateTime? estimatedDelivery,
    DateTime? deliveredAt,
    String? imageUrl,
    bool? isPaid,
    String? customerName,
    String? customerEmail,
  }) {
    return Order(
      id: id,
      trackingCode: trackingCode ?? this.trackingCode,
      productName: productName ?? this.productName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      rawStatus: rawStatus ?? this.rawStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isPaid: isPaid ?? this.isPaid,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
    );
  }

  bool get hasWeight => weight > 0;
  bool get hasPrice => price > 0;

  double get uiWeight => weight;
  double get uiPrice => price;
}
