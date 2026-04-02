import 'dart:async';

import 'package:core/features/home/models/pin_item.dart';
import 'package:core/features/home/repositories/pin_feed_repository.dart';
import 'package:flutter/material.dart';

class FakePinFeedRepository implements PinFeedRepository {
  @override
  Future<List<PinItem>> fetchPins() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return const [
      PinItem(
        id: 'pin_001',
        title: 'Felt storage wall with modular hooks',
        author: 'Anu-Erdene B.',
        board: 'Studio',
        aspectRatio: 0.72,
        likes: 418,
        primaryColor: Color(0xFFC64B45),
        secondaryColor: Color(0xFFF1B58A),
      ),
      PinItem(
        id: 'pin_002',
        title: 'Matte walnut kitchen with vertical lighting',
        author: 'Mungunzul T.',
        board: 'Interiors',
        aspectRatio: 0.95,
        likes: 691,
        primaryColor: Color(0xFF5B4A41),
        secondaryColor: Color(0xFFCBA58A),
      ),
      PinItem(
        id: 'pin_003',
        title: 'Editorial layout for perfume launch notes',
        author: 'Nomin O.',
        board: 'Branding',
        aspectRatio: 0.8,
        likes: 273,
        primaryColor: Color(0xFF2D3646),
        secondaryColor: Color(0xFF8B9CB5),
      ),
      PinItem(
        id: 'pin_004',
        title: 'Coffee corner with terracotta pendant set',
        author: 'Temuulen S.',
        board: 'Interiors',
        aspectRatio: 1.08,
        likes: 557,
        primaryColor: Color(0xFF8D5335),
        secondaryColor: Color(0xFFE2BE93),
      ),
      PinItem(
        id: 'pin_005',
        title: 'Quiet palette lookbook for spring commute',
        author: 'Enkhjin L.',
        board: 'Fashion',
        aspectRatio: 0.74,
        likes: 342,
        primaryColor: Color(0xFF6D7077),
        secondaryColor: Color(0xFFC3CCD4),
      ),
      PinItem(
        id: 'pin_006',
        title: 'Ceramic display ladder for boutique window',
        author: 'Gerelmaa V.',
        board: 'Studio',
        aspectRatio: 0.9,
        likes: 184,
        primaryColor: Color(0xFF6A5142),
        secondaryColor: Color(0xFFD7B597),
      ),
      PinItem(
        id: 'pin_007',
        title: 'Campaign storyboard for red bicycle series',
        author: 'Batchimeg R.',
        board: 'Branding',
        aspectRatio: 1.14,
        likes: 479,
        primaryColor: Color(0xFF9F2838),
        secondaryColor: Color(0xFFF0A8A6),
      ),
      PinItem(
        id: 'pin_008',
        title: 'Soft industrial desk nook with steel shelf',
        author: 'Enebish K.',
        board: 'Interiors',
        aspectRatio: 0.83,
        likes: 264,
        primaryColor: Color(0xFF48515C),
        secondaryColor: Color(0xFFA6B0BD),
      ),
    ];
  }
}
