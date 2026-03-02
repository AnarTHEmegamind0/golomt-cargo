import 'package:core/features/delivery/models/driver_notification.dart';
import 'package:flutter/foundation.dart';

class DriverNotificationProvider extends ChangeNotifier {
  final List<DriverNotification> _notifications = [
    DriverNotification(
      id: 'notif_1',
      title: 'Order ORD-31057 is ready for pickup',
      subtitle: 'Arka Bakehouse confirmed your handoff spot.',
      groupLabel: 'Today',
      createdAt: DateTime.now().subtract(const Duration(minutes: 11)),
    ),
    DriverNotification(
      id: 'notif_2',
      title: 'Customer asked for gate-side delivery',
      subtitle: 'Ikh Toiruu 34 has security gate constraints.',
      groupLabel: 'Today',
      createdAt: DateTime.now().subtract(const Duration(minutes: 46)),
    ),
    DriverNotification(
      id: 'notif_3',
      title: 'Weekly bonus updated',
      subtitle: 'You unlocked 14,500 MNT weekend boost.',
      groupLabel: 'Yesterday',
      createdAt: DateTime.now().subtract(const Duration(hours: 22)),
      unread: false,
    ),
  ];

  List<DriverNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => notification.unread).length;

  void markAllRead() {
    for (var index = 0; index < _notifications.length; index++) {
      _notifications[index] = _notifications[index].copyWith(unread: false);
    }
    notifyListeners();
  }

  void dismiss(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }
}
