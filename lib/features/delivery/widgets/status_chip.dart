import 'package:core/features/delivery/models/delivery_order.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.step});

  final DeliveryStep step;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (step) {
      DeliveryStep.pending => ('Хүлээгдэж буй', const Color(0xFFB54708)),
      DeliveryStep.accepted => ('Хүлээн авсан', const Color(0xFF175CD3)),
      DeliveryStep.pickedUp => ('Авсан', const Color(0xFF175CD3)),
      DeliveryStep.enRoute => ('Замд яваа', const Color(0xFF175CD3)),
      DeliveryStep.arrived => ('Ирсэн', const Color(0xFF087443)),
      DeliveryStep.proof => ('Баталгаа хэрэгтэй', const Color(0xFF9E1C3B)),
      DeliveryStep.completed => ('Дууссан', const Color(0xFF087443)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.14),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
