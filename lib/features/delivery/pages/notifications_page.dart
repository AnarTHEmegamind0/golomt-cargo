import 'package:core/core/design_system/components/empty_state.dart';
import 'package:core/features/delivery/models/driver_notification.dart';
import 'package:core/features/delivery/providers/driver_notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverNotificationProvider>();
    final notifications = provider.notifications;

    if (notifications.isEmpty) {
      return const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: EmptyState(
            title: 'No notifications',
            description: 'New updates about your orders will appear here.',
            icon: Icons.notifications_off_outlined,
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              TextButton(
                onPressed: provider.markAllRead,
                child: const Text('Mark all read'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.unreadCount} unread',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          for (final notification in notifications) ...[
            if (_isGroupStart(notifications, notification)) ...[
              Text(
                notification.groupLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
            ],
            Dismissible(
              key: ValueKey(notification.id),
              onDismissed: (_) => provider.dismiss(notification.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE4DBD4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: notification.unread
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFFB9AFAB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _isGroupStart(
    List<DriverNotification> notifications,
    DriverNotification current,
  ) {
    final index = notifications.indexOf(current);
    if (index == 0) return true;
    return notifications[index - 1].groupLabel != current.groupLabel;
  }
}
