import 'dart:async';

import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:core/features/delivery/repositories/delivery_repository.dart';
import 'package:flutter/material.dart';

class FakeDeliveryRepository implements DeliveryRepository {
  final List<DeliveryOrder> _orders = const [
    DeliveryOrder(
      id: 'ORD-31041',
      restaurantName: 'Nomad Гоймон Лаб',
      customerName: 'M. Tungalag',
      deliveryAddress: 'Ikh Toiruu 34, Chingeltei',
      etaMinutes: 21,
      earnings: 8.40,
      items: ['Халуун рамен', 'Гүнжидтэй салат'],
      instructions: 'Кофе шопын хажуугийн хаалгаар орно уу.',
      primaryColor: Color(0xFF8F3F3A),
      secondaryColor: Color(0xFFD79F84),
      imageHeroTag: 'hero_order_1',
    ),
    DeliveryOrder(
      id: 'ORD-31057',
      restaurantName: 'Arka Бэйкхаус',
      customerName: 'B. Saruul',
      deliveryAddress: 'Peace Avenue 12B, Sukhbaatar',
      etaMinutes: 16,
      earnings: 6.75,
      items: ['Фокачча сэт', 'Мөстэй латте'],
      instructions: 'Ирэхээс 1 минутын өмнө залгана уу.',
      primaryColor: Color(0xFF5A4D44),
      secondaryColor: Color(0xFFC5A792),
      imageHeroTag: 'hero_order_2',
      step: DeliveryStep.accepted,
    ),
    DeliveryOrder(
      id: 'ORD-31063',
      restaurantName: 'Urban Грилл',
      customerName: 'E. Bayarjargal',
      deliveryAddress: 'Tokyo Street 8, Khan-Uul',
      etaMinutes: 27,
      earnings: 10.20,
      items: ['Утаж болгосон махтай боул', 'Хийжүүлсэн ус'],
      instructions: 'Хүлээн авагч байхгүй бол ресепшнд үлдээнэ үү.',
      primaryColor: Color(0xFF384955),
      secondaryColor: Color(0xFF99AEB7),
      imageHeroTag: 'hero_order_3',
      step: DeliveryStep.pickedUp,
    ),
  ];

  @override
  Future<List<DeliveryOrder>> fetchActiveOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    return List<DeliveryOrder>.from(_orders);
  }

  @override
  Future<void> updateOrderStep({
    required String orderId,
    required DeliveryStep step,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(step: step);
  }

  @override
  Future<void> uploadProof({
    required String orderId,
    required String localPath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(proofImagePath: localPath);
  }
}
