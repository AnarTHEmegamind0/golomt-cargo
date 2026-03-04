import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/core/design_system/components/empty_state.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CargoBackdrop(
        light: !isDark,
        child: SafeArea(
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: _fakeNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = _fakeNotifications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotificationCard(notification: notification),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.9),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Мэдэгдлүүд',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text('Бүгдийг уншсан'),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final _NotificationData notification;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? (notification.isRead
                  ? const Color(0xFF1C2537).withValues(alpha: 0.6)
                  : const Color(0xFF1C2537).withValues(alpha: 0.9))
            : (notification.isRead
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.95)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: notification.isRead
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFE4E8EE))
              : notification.color.withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(notification.icon, color: notification.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: notification.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? const Color(0xFF8B95A8)
                        : const Color(0xFF677186),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationData {
  const _NotificationData({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;
}

final _fakeNotifications = [
  const _NotificationData(
    title: 'Ачаа хүргэгдлээ',
    message: 'BD2024031501 дугаартай ачаа Улаанбаатар салбарт хүргэгдлээ.',
    time: '5 минутын өмнө',
    icon: Icons.check_circle_rounded,
    color: Color(0xFF10B981),
    isRead: false,
  ),
  const _NotificationData(
    title: 'Төлбөр амжилттай',
    message: 'Таны BD2024031502 захиалгын төлбөр амжилттай төлөгдлөө.',
    time: '2 цагийн өмнө',
    icon: Icons.payment_rounded,
    color: Color(0xFF8B5CF6),
    isRead: false,
  ),
  const _NotificationData(
    title: 'Ачаа замдаа гарлаа',
    message:
        'BD2024031503 дугаартай ачаа Хятадаас гарлаа. Хүлээгдэж буй хугацаа: 5 хоног',
    time: '1 өдрийн өмнө',
    icon: Icons.local_shipping_rounded,
    color: Color(0xFF3B82F6),
    isRead: true,
  ),
  const _NotificationData(
    title: 'Шинэ захиалга',
    message: 'BD2024031504 дугаартай захиалга амжилттай бүртгэгдлээ.',
    time: '2 өдрийн өмнө',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFFF59E0B),
    isRead: true,
  ),
  const _NotificationData(
    title: 'Урамшуулал',
    message: 'Таны дараагийн захиалгад 10% хөнгөлөлт эдлээрэй!',
    time: '3 өдрийн өмнө',
    icon: Icons.local_offer_rounded,
    color: Color(0xFFEC4899),
    isRead: true,
  ),
];
