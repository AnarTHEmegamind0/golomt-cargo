class DriverNotification {
  const DriverNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.groupLabel,
    required this.createdAt,
    this.unread = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final String groupLabel;
  final DateTime createdAt;
  final bool unread;

  DriverNotification copyWith({bool? unread}) {
    return DriverNotification(
      id: id,
      title: title,
      subtitle: subtitle,
      groupLabel: groupLabel,
      createdAt: createdAt,
      unread: unread ?? this.unread,
    );
  }
}
