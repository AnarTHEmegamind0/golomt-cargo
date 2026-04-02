import 'package:flutter/material.dart';

class PinItem {
  const PinItem({
    required this.id,
    required this.title,
    required this.author,
    required this.board,
    required this.aspectRatio,
    required this.likes,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final String id;
  final String title;
  final String author;
  final String board;
  final double aspectRatio;
  final int likes;
  final Color primaryColor;
  final Color secondaryColor;
}
