import 'package:core/features/delivery/models/driver_notification.dart';
import 'package:flutter/foundation.dart';

class DriverNotificationProvider extends ChangeNotifier {
  final List<DriverNotification> _notifications = [
    DriverNotification(
      id: 'notif_1',
      title: 'ORD-31057 захиалга авахад бэлэн боллоо',
      subtitle: 'Арка Бэйкхаус таны хүлээлгэн өгөх цэгийг баталгаажууллаа.',
      groupLabel: 'Өнөөдөр',
      createdAt: DateTime.now().subtract(const Duration(minutes: 11)),
    ),
    DriverNotification(
      id: 'notif_2',
      title: 'Хэрэглэгч хаалган дээр хүлээлгэн өгөх хүсэлт илгээлээ',
      subtitle: 'Их тойруу 34 дээр хамгаалалтын хаалгатай тул анхаарна уу.',
      groupLabel: 'Өнөөдөр',
      createdAt: DateTime.now().subtract(const Duration(minutes: 46)),
    ),
    DriverNotification(
      id: 'notif_3',
      title: '7 хоногийн урамшуулал шинэчлэгдлээ',
      subtitle: 'Та амралтын нэмэгдэл 14,500₮ авах болзол хангалаа.',
      groupLabel: 'Өчигдөр',
      createdAt: DateTime.now().subtract(const Duration(hours: 22)),
      unread: false,
    ),
  ];

  List<DriverNotification> get notifications =>
      List.unmodifiable(_notifications);

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
