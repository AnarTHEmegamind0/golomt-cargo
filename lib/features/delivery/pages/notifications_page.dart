import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/core/design_system/components/empty_state.dart';
import 'package:core/features/delivery/models/driver_notification.dart';
import 'package:core/features/delivery/providers/driver_notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _searchQuery = '';
  _OrdersFilter _selectedFilter = _OrdersFilter.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverNotificationProvider>();
    final allNotifications = provider.notifications;
    final notifications = _filteredNotifications(allNotifications);

    return CargoBackdrop(
      light: true,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Захиалгууд',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _ViewToggle(onListTap: () {}, onGridTap: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _ActionPill(
                    icon: Icons.wallet_outlined,
                    label: 'Төлбөр төлөх',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ActionPill(
                    icon: Icons.local_shipping_outlined,
                    label: 'Хүргэлт захиалах',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SearchInput(
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Бүгд',
                    selected: _selectedFilter == _OrdersFilter.all,
                    onTap: () =>
                        setState(() => _selectedFilter = _OrdersFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Улаанбаатарт ирсэн',
                    selected: _selectedFilter == _OrdersFilter.arrived,
                    onTap: () =>
                        setState(() => _selectedFilter = _OrdersFilter.arrived),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Хүлээж авсан',
                    selected: _selectedFilter == _OrdersFilter.received,
                    onTap: () => setState(
                      () => _selectedFilter = _OrdersFilter.received,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (allNotifications.isEmpty)
              const EmptyState(
                title: 'Мэдэгдэл алга',
                description: 'Захиалгын шинэчлэлт энд харагдана.',
                icon: Icons.notifications_off_outlined,
              )
            else if (notifications.isEmpty)
              const EmptyState(
                title: 'Илэрц алга',
                description: 'Өөр хайлт эсвэл шүүлтүүр сонгоно уу.',
                icon: Icons.search_off_rounded,
              )
            else
              Column(
                children: [
                  for (final notification in notifications) ...[
                    if (_isGroupStart(notifications, notification))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.groupLabel,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (notification.groupLabel == 'Өнөөдөр')
                              TextButton(
                                onPressed: provider.markAllRead,
                                child: const Text('Бүгдийг уншсан болгох'),
                              ),
                          ],
                        ),
                      ),
                    Dismissible(
                      key: ValueKey(notification.id),
                      onDismissed: (_) => provider.dismiss(notification.id),
                      child: _OrderUpdateCard(notification: notification),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<DriverNotification> _filteredNotifications(
    List<DriverNotification> notifications,
  ) {
    final search = _searchQuery.trim().toLowerCase();

    return notifications.where((notification) {
      if (_selectedFilter == _OrdersFilter.arrived && notification.unread) {
        return false;
      }
      if (_selectedFilter == _OrdersFilter.received && !notification.unread) {
        return false;
      }

      if (search.isEmpty) return true;

      return notification.title.toLowerCase().contains(search) ||
          notification.subtitle.toLowerCase().contains(search);
    }).toList();
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

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.onListTap, required this.onGridTap});

  final VoidCallback onListTap;
  final VoidCallback onGridTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF08A1A), width: 1.4),
      ),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: onGridTap,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF08A1A),
              foregroundColor: Colors.white,
              minimumSize: const Size.square(40),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.grid_view_rounded),
          ),
          IconButton(
            onPressed: onListTap,
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF23252C),
              minimumSize: const Size.square(40),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.view_list_rounded),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9B9CA3)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5D8DF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Трак дугаар/Тэмдэглэл-р хайх',
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search_rounded),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF111319) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFF111319) : const Color(0xFF1F2432),
            width: 1.6,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : const Color(0xFF171A20),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _OrderUpdateCard extends StatelessWidget {
  const _OrderUpdateCard({required this.notification});

  final DriverNotification notification;

  @override
  Widget build(BuildContext context) {
    final badgeColor = notification.unread
        ? const Color(0xFFF08A1A)
        : const Color(0xFFB0B6C2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8DCE4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF464D5E)),
        ],
      ),
    );
  }
}

enum _OrdersFilter { all, arrived, received }
